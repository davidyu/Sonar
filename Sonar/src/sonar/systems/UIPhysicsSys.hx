// UIPhysicsSys: a system for computing and applying movement transforms
// to UI entities. In particular, collisions are not processed

package sonar.systems;

import com.artemisx.Aspect;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import com.artemisx.EntitySystem;
import com.artemisx.utils.Bag;

import sonar.components.PosCmp;
import sonar.components.UICmp;

import utils.Polygon;

using Lambda;
using sonar.Util;
using utils.Geo;
using utils.Math2;

class UIPhysicsSys extends EntitySystem
{
    public function new() {
        super( Aspect.getAspectForAll( [UICmp, PosCmp] ) );
    }

    override public function initialize() : Void {
        posMapper = world.getMapper( PosCmp );
    }

    override public function processEntities( entities : Bag<Entity> ) : Void  {
        var e : Entity;
        var posCmp : PosCmp;    // Position component of entity

        for ( i in 0...actives.size ) {
            e = actives.get( i );
            posCmp = posMapper.get( e );
            if ( !posCmp.noDamping )
                posCmp.dp = posCmp.dp.scale( 0.9 );
            posCmp.pos = posCmp.pos.add( posCmp.dp );
        }
    }

    var posMapper : ComponentMapper<PosCmp>;
}
