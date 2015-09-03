package sonar.systems;

import com.artemisx.Aspect;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import com.artemisx.EntitySystem;
import com.artemisx.utils.Bag;

import sonar.components.BounceCmp;
import sonar.components.PosCmp;
import sonar.components.PosTrackerCmp;

import utils.Vec2;

class PosTrackerSys extends EntitySystem
{
    public function new() {
        super( Aspect.getAspectForAll( [ PosCmp, PosTrackerCmp ] ) );
    }

    override public function initialize() : Void {
        posMapper        = world.getMapper( PosCmp );
        posTrackerMapper = world.getMapper( PosTrackerCmp );
    }

    override public function processEntities( entities : Bag<Entity> ) : Void  {
        var e : Entity;
        var posCmp : PosCmp;    // Position component of entity
        var posTracker : PosTrackerCmp;

        for ( i in 0...actives.size ) {
            e = actives.get( i );
            posCmp = posMapper.get( e );
            posTracker = posTrackerMapper.get( e );
            posTracker.setLastPosition( posCmp.pos );
        }
    }

    var posMapper : ComponentMapper<PosCmp>;
    var posTrackerMapper : ComponentMapper<PosTrackerCmp>;
}
