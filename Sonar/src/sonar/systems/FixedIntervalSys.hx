package sonar.systems;

import com.artemisx.Aspect;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import com.artemisx.systems.IntervalEntitySystem;
import com.artemisx.utils.Bag;
import sonar.components.TimedEffectCmp;

class FixedIntervalSys extends IntervalEntitySystem
{
    public function new( aspect:Aspect, interval:Float )
    {
        super( Aspect.getAspectForAll( [ TimedEffectCmp ] ) );
    }

    override public function processEntities( entities : Bag<Entity> ) : Void  {
    }
}
