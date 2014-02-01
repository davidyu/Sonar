package gibber.systems;

import com.artemisx.Aspect;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import com.artemisx.utils.Bag;
import com.artemisx.systems.IntervalEntitySystem;

import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.TextFormat;

import gibber.components.ClientCmp;
import gibber.components.PosCmp;
import gibber.components.NetworkPlayerCmp;

import utils.Vec2;

class ClientSys extends IntervalEntitySystem
{
    public function new( god : God ) {
        this.god = god;
        super( Aspect.getAspectForAll( [ClientCmp] ), 100.0 );
    }

    override public function initialize() : Void {
        clientMapper = world.getMapper( ClientCmp );
        posMapper = world.getMapper( PosCmp );
        netPlayerMapper = world.getMapper( NetworkPlayerCmp );
    }

    override public function processEntities( entities : Bag<Entity> ) : Void  {
        var e : Entity;
        var d : ClientCmp;
        for ( i in 0...actives.size ) {
            e = actives.get( i );
            d = clientMapper.get( e );

            while ( d.socket.connected && d.socket.bytesAvailable > 0 ) {
                var opcode = d.socket.readUnsignedByte();
                switch ( opcode ) {
                    case 255: //ack
                        d.id = d.socket.readUnsignedByte();
                        trace( "my ID is " + d.id );
                        if ( d.id > 0 ) {
                            god.player = god.entityBuilder.createPlayer( "ship", god.sectors[0], new Vec2( 1080, 250 ) );
                        } else {
                            god.player = god.entityBuilder.createPlayer( "ship", god.sectors[0], new Vec2( 20, 20 ) );
                        }
                    case 254: //join
                        var newClientID = d.socket.readUnsignedByte();
                        trace( "another client with ID " + newClientID + " joined this game." );
                        if ( newClientID > 0 ) {
                            god.netPlayers.push( god.entityBuilder.createNetworkPlayer( "enemy", god.sectors[0], new Vec2( 1080, 250 ), newClientID ) );
                        } else {
                            god.netPlayers.push( god.entityBuilder.createNetworkPlayer( "enemy", god.sectors[0], new Vec2( 20, 20 ), newClientID ) );
                        }
                    case 253: //relay data
                        var id = d.socket.readUnsignedByte();
                        var opcode = d.socket.readUnsignedByte();

                        if ( opcode != 1 ) break;

                        var up = d.socket.readUnsignedByte() > 0;
                        var down = d.socket.readUnsignedByte() > 0;
                        var left = d.socket.readUnsignedByte() > 0;
                        var right = d.socket.readUnsignedByte() > 0;

                        // update entity with id
                        for ( p in god.netPlayers ) {
                            if ( netPlayerMapper.get( p ).id == id ) {
                                var pos : PosCmp = posMapper.get( p );

                                if ( up ) {
                                    pos.dp.y = -1.0;
                                }

                                if ( down ) {
                                    pos.dp.y = 1.0;
                                }

                                if ( left ) {
                                    pos.dp.x = -1.0;
                                }

                                if ( right ) {
                                    pos.dp.x = 1.0;
                                }
                            }
                        }
                    default:
                        trace( "unknown server opcode: " + opcode );
                }
            }

            if ( !d.socket.connected ) { //retry connection
                trace("disconnected...trying to reconnect...");
                d.socket.connect( d.host, d.port );
            }
        }
    }

    private var god : God;
    private var clientMapper : ComponentMapper<ClientCmp>;
    private var posMapper : ComponentMapper<PosCmp>;
    private var netPlayerMapper : ComponentMapper<NetworkPlayerCmp>;
}
