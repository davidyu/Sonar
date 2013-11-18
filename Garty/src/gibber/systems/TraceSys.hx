package gibber.systems;

import com.artemisx.Aspect;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import com.artemisx.EntitySystem;
import com.artemisx.utils.Bag;

import gibber.components.TimedEffectCmp;
import gibber.components.TraceCmp;

class TraceSys extends EntitySystem
{
    public function new() {
        super( Aspect.getAspectForAll( [TraceCmp, TimedEffectCmp] ) );
    }

    override public function initialize() : Void {
        timedEffectMapper = world.getMapper( TimedEffectCmp );
        traceMapper       = world.getMapper( TraceCmp );
    }

    override public function processEntities( entities : Bag<Entity> ) : Void  {
        var e : Entity;
        var time : TimedEffectCmp;
        var traceCmp : TraceCmp;

        for ( i in 0...actives.size ) {
            e = actives.get( i );
            time = timedEffectMapper.get( e );
            traceCmp = traceMapper.get( e );
            if ( time.processState == Process ) {
                traceCmp.fadeAcc *= traceCmp.fadeMultiplier;
                if ( traceCmp.fadeAcc <= TraceCmp.VESTIGIAL_THRESHOLD ) {
                    world.deleteEntity( e );
                }

                time.processState = Processed;
            }
        }
    }

    var timedEffectMapper : ComponentMapper<TimedEffectCmp>;
    var traceMapper       : ComponentMapper<TraceCmp>;
}
