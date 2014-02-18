package gibber.systems;

import com.artemisx.Aspect;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import com.artemisx.utils.Bag;
import com.artemisx.systems.IntervalEntitySystem;

import gibber.components.ClientCmp;
import gibber.components.SyncCmp;
import gibber.components.PosCmp;
import gibber.systems.EntityAssemblySys;

import flash.utils.ByteArray;

import utils.Vec2;

class SyncSys extends IntervalEntitySystem
{
    public function new() {
#if ( local || fdb )
        super( Aspect.getAspectForOne( [ ClientCmp, SyncCmp ] ), 100.0 );
#else
        super( Aspect.getAspectForOne( [ ClientCmp, SyncCmp ] ), 1000.0 );
#end
    }

    override public function initialize() : Void {
        clientMapper = world.getMapper( ClientCmp );
        syncMapper = world.getMapper( SyncCmp );
        posMapper = world.getMapper( PosCmp );
        entityAssembler = world.getSystem( EntityAssemblySys );
        buffer = new ByteArray();
    }

    override public function processEntities( entities : Bag<Entity> ) : Void  {
        var e : Entity;
        var c : ClientCmp;
        var s : SyncCmp;

        for ( i in 0...actives.size ) {
            e = actives.get( i );
            s = syncMapper.get( e );
            if ( s != null ) { // entity we need to sync
                var serializedPos : String = haxe.Serializer.run( posMapper.get( e ) );
                buffer.writeByte( 2 );
                buffer.writeShort( serializedPos.length );
                buffer.writeUTFBytes( serializedPos );
            }
        }

        for ( i in 0...actives.size ) {
            e = actives.get( i );
            c = clientMapper.get( e );
            if ( c != null ) { // entity with socket
                var socket = c.socket;
                if ( socket.connected && socket.bytesPending == 0 ) {
                    socket.writeBytes( buffer, 0, buffer.length );
                    socket.flush();
                    buffer.clear();
                } else {
                    socket.flush();
                }
            }
        }

        buffer.clear();
    }

    private var clientMapper : ComponentMapper<ClientCmp>;
    private var syncMapper : ComponentMapper<SyncCmp>;
    private var posMapper : ComponentMapper<PosCmp>;
    private var entityAssembler : EntityAssemblySys;

    private var buffer : ByteArray;
}
