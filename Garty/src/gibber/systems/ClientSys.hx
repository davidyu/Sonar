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

import utils.Vec2;

class ClientSys extends IntervalEntitySystem
{
    public function new( god : God ) {
        this.god = god;
        super( Aspect.getAspectForAll( [ClientCmp] ), 100.0 );
    }

    override public function initialize() : Void {
        clientMapper = world.getMapper( ClientCmp );

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
                    case 255:
                        d.id = d.socket.readUnsignedByte();
                        trace( "my ID is " + d.id );
                        if ( d.id > 0 ) {
                            god.player = god.entityBuilder.createPlayer( "ship", god.sectors[0], new Vec2( 1080, 250 ) );
                        } else {
                            god.player = god.entityBuilder.createPlayer( "ship", god.sectors[0], new Vec2( 20, 20 ) );
                        }
                    case 254:
                        var newClientID = d.socket.readUnsignedByte();
                        trace( "another client with ID " + newClientID + " joined this game." );
                        if ( newClientID > 0 ) {
                            god.entityBuilder.createNetworkPlayer( "enemy", god.sectors[0], new Vec2( 1080, 250 ), newClientID );
                        } else {
                            god.entityBuilder.createNetworkPlayer( "enemy", god.sectors[0], new Vec2( 20, 20 ), newClientID );
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
}
