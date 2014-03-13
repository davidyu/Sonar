package gibber.systems;

import com.artemisx.Aspect;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import com.artemisx.utils.Bag;
import com.artemisx.systems.IntervalEntitySystem;

import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.errors.Error;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.TextFormat;

import gibber.components.ClientCmp;
import gibber.components.PosCmp;
import gibber.components.NetworkPlayerCmp;

import gibber.systems.EntityAssemblySys;

import utils.Vec2;

class ClientSys extends IntervalEntitySystem
{
    public function new( god : God ) {
        this.god = god;
#if ( local || fdb )
        super( Aspect.getAspectForAll( [ClientCmp] ), 5.0 );
#else
        super( Aspect.getAspectForAll( [ClientCmp] ), 100.0 );
#end
    }

    override public function initialize() : Void {
        clientMapper = world.getMapper( ClientCmp );
        posMapper = world.getMapper( PosCmp );
        netPlayerMapper = world.getMapper( NetworkPlayerCmp );
        entityAssembler = world.getSystem( EntityAssemblySys );
    }

    override public function processEntities( entities : Bag<Entity> ) : Void  {
        var e : Entity;
        var d : ClientCmp;
        for ( i in 0...actives.size ) {
            e = actives.get( i );
            d = clientMapper.get( e );

            if ( d.socket.connected && d.socket.bytesAvailable > 0 ) {
                var serverOpcode = d.cache.serverOpcode == 0 ? d.socket.readUnsignedByte() : d.cache.serverOpcode;
                switch ( serverOpcode ) {
                    case 255: //ack
                        d.id = d.socket.readUnsignedByte();
                        trace( "my ID is " + d.id );
                        if ( d.id > 1 ) {
                            god.player = entityAssembler.createPlayer( "ship", god.sectors[0], new Vec2( 1080, 250 ) );
                        } else {
                            god.player = entityAssembler.createPlayer( "ship", god.sectors[0], new Vec2( 20, 20 ) );
                        }
                        entityAssembler.createCamera( god.sectors[0], new Vec2( 0, 0 ), god.player );
                    case 254: //join
                        var newClientID = d.socket.readUnsignedByte();
                        trace( "another client with ID " + newClientID + " joined this game." );
                        if ( newClientID > 1 ) {
                            god.netPlayers.push( entityAssembler.createNetworkPlayer( "enemy", god.sectors[0], new Vec2( 1080, 250 ), newClientID ) );
                        } else {
                            god.netPlayers.push( entityAssembler.createNetworkPlayer( "enemy", god.sectors[0], new Vec2( 20, 20 ), newClientID ) );
                        }
                    case 253: //relay data
                        var id : UInt, peerOpcode : UInt;
                        if ( d.socket.bytesAvailable >= 2 ) {
                            id = d.cache.id == 0 ? d.socket.readUnsignedByte() : d.cache.id;
                            peerOpcode = d.cache.peerOpcode == 0 ? d.socket.readUnsignedByte() : d.cache.peerOpcode;
                        } else {
                            d.cache.serverOpcode = serverOpcode;
                            return;
                        }

                        function getNetworkPlayerById( id ) {
                            for ( p in god.netPlayers ) {
                                if ( netPlayerMapper.get( p ).id == id ) {
                                    return p;
                                }
                            }
                            return null;
                        }

                        var netPlayer = getNetworkPlayerById( id );
                        if ( netPlayer == null ) {
                            trace( "can't find netPlayer...aborting" );
                            return;
                        }

                        switch ( peerOpcode ) {
                            case 2:
                                var len = d.cache.len == 0 ? d.socket.readUnsignedShort() : d.cache.len;
                                if ( d.cache.len != 0 ) {
                                    trace( 'checking if we now have $len bytes to read...' );
                                }
                                if ( d.socket.bytesAvailable >= len ) {
                                    if ( d.cache.len != 0 ) {
                                        trace( 'yes, we have ${d.socket.bytesAvailable} bytes to read!' );
                                    }
                                    try {
                                        var serializedPos = d.socket.readUTFBytes( len );
                                        var newPosCmp : PosCmp = haxe.Unserializer.run( serializedPos );
                                        var posCmp : PosCmp = posMapper.get( netPlayer );
                                        posCmp.pos = newPosCmp.pos;
                                        posCmp.dp = newPosCmp.dp;
                                    } catch ( e : Error ) {
                                        trace( "ERROR " + e );
                                    }
                                } else {
                                    trace( 'waiting until we have at least $len bytes to read...' );
                                    d.cache.serverOpcode = serverOpcode;
                                    d.cache.peerOpcode = peerOpcode;
                                    d.cache.id = id;
                                    d.cache.len = len;
                                    return;
                                }

                            case 3: // unidirectional sonar
                                var pos : Vec2 = haxe.Unserializer.run( d.socket.readUTF() );
                                entityAssembler.createSonar( netPlayer.id, netPlayer.getComponent( PosCmp ).sector, pos );
                            case 4: // directional sonar
                                var origin : Vec2 = haxe.Unserializer.run( d.socket.readUTF() );
                                var direction : Vec2 = haxe.Unserializer.run( d.socket.readUTF() );
                                entityAssembler.createSonarBeam( netPlayer.getComponent( PosCmp ).sector, origin, direction );
                            case 5: // torpedo
                                var origin : Vec2 = haxe.Unserializer.run( d.socket.readUTF() );
                                var target : Vec2 = haxe.Unserializer.run( d.socket.readUTF() );
                                entityAssembler.createTorpedo( netPlayer.id, StaticTarget( target ), netPlayer.getComponent( PosCmp ).sector, origin );

                            default: trace( "unknown peer opcode: " + peerOpcode );
                                     return;
                            // probably bad state
                        }

                    default:
                        trace( "unknown server opcode: " + serverOpcode );
                        return;
                        // probably bad state
                }
            }

            d.cache = { serverOpcode : 0, peerOpcode : 0, id : 0, len : 0 };

            if ( !d.socket.connected ) { //retry connection
                trace("ClientSys detects that socket is not connected...");
            }
        }
    }

    public function sendFireTorpedoEvent( pos : Vec2, target : Vec2 ) {
        var socket = god.client.getComponent( ClientCmp ).socket;
        var posSerialized : String = haxe.Serializer.run( pos );
        var targetSerialized : String = haxe.Serializer.run( target );
        if ( socket.connected ) {
            socket.writeByte( 5 );
            socket.writeShort( posSerialized.length );
            socket.writeUTFBytes( posSerialized );
            socket.writeShort( targetSerialized.length );
            socket.writeUTFBytes( targetSerialized );
            socket.flush();
        }
    }

    public function sendSonarBeamCreationEvent( origin : Vec2, direction : Vec2 ) : Void {
        var socket = god.client.getComponent( ClientCmp ).socket;
        var originSerialized : String = haxe.Serializer.run( origin );
        var directionSerialized : String = haxe.Serializer.run( direction );
        if ( socket.connected ) {
            socket.writeByte( 4 );
            socket.writeUTF( originSerialized );
            socket.writeUTF( directionSerialized );
            socket.flush();
        }
    }

    public function sendSonarCreationEvent( pos : Vec2 ) {
        var socket = god.client.getComponent( ClientCmp ).socket;
        var posSerialized : String = haxe.Serializer.run( pos );
        if ( socket.connected ) {
            socket.writeByte( 3 );
            socket.writeShort( posSerialized.length );
            socket.writeUTFBytes( posSerialized );
            socket.flush();
        }
    }

    private var god : God;
    private var clientMapper : ComponentMapper<ClientCmp>;
    private var posMapper : ComponentMapper<PosCmp>;
    private var netPlayerMapper : ComponentMapper<NetworkPlayerCmp>;
    private var entityAssembler : EntityAssemblySys;
}
