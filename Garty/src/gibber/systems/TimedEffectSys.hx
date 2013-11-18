package gibber.systems;

import com.artemisx.Aspect;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import com.artemisx.EntitySystem;
import com.artemisx.utils.Bag;
import gibber.components.TimedEffectCmp;

class TimedEffectSys extends EntitySystem
{
    private var acc : UInt; //"probably" reduces floating point errors; come back to this if it causes any problems

    public function new() {
        super( Aspect.getAspectForAll( [TimedEffectCmp] ) );
        acc = 0;
    }

    override public function initialize() : Void {
        timedEffectMapper = world.getMapper( TimedEffectCmp );
    }

    override private function checkProcessing()
    {
        if ( world.delta == null ) {
#if debug
            throw "No counter set up with world! All TimedEffectCmps will fail! You MUST set world.delta if you want to use TimedEffectSys";
#else
            world.delta = 1000/30.0; //fill w/ some bogus frame rate, so it will at least continue
#end
        }

        acc += Std.int( world.delta );
        return true;
    }

    override public function processEntities( entities : Bag<Entity> ) : Void  {
        var e : Entity;
        var worldDelta : UInt = Std.int( world.delta );
        var time : TimedEffectCmp;

        for ( i in 0...actives.size) {
            e = actives.get( i );
            time = timedEffectMapper.get( e );

            time.internalAcc += worldDelta;
            if ( time.internalAcc >= time.duration ) {
                world.deleteEntity( e );
                return;
            }

            switch ( time.processState ) {
                case Processed:
                    time.processState = Wait( acc - worldDelta ); //compensate; probably processed exactly one frame ago; or...not...this is tricky and we have to make sure that TimedEffectsSys is either the FIRST or LAST system to call process

                case Wait( lastProcessed ):
                    var interval : UInt = switch ( time.tickInterval ) {
                        case GlobalTickInterval                  : worldDelta;
                        case CustomTickInterval( delta )         : delta;
                        case GlobalTickIntervalWithModifier( m ) : Std.int( worldDelta * m );
                        default                                  : worldDelta; //@dyu TODO: implement synchronized "channels"
                    };

                    if ( acc - lastProcessed >= interval ) {
                        time.processState = Process;
                    }

                case Process:
#if debug
                    throw "an entity with TimedEffect component did not get processed!";
#end
            }
        }
    }

    var timedEffectMapper : ComponentMapper<TimedEffectCmp>;
}
