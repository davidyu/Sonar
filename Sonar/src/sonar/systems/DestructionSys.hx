package sonar.systems;

import com.artemisx.Aspect;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import com.artemisx.EntitySystem;
import com.artemisx.utils.Bag;

import sonar.components.DestructibleCmp;
import sonar.components.PosCmp;
import sonar.managers.ContainerMgr;

import utils.Geo;
import utils.Polygon;
import utils.Math2;
import gml.vector.Vec2f;

class DestructionSys extends EntitySystem
{
    public function new() {
        super( Aspect.getAspectForAll( [ DestructibleCmp, PosCmp ] ) );
    }

    override public function initialize() : Void {
        destructibleMapper = world.getMapper( DestructibleCmp );
        posMapper          = world.getMapper( PosCmp );
    }

    override public function processEntities( entities : Bag<Entity> ) : Void  {
        var e : Entity;
        var d : DestructibleCmp;
        var p : PosCmp;

        for ( i in 0...actives.size ) {
            e = actives.get( i );
            d = destructibleMapper.get( e );
            p = posMapper.get( e );

            switch( d.state ) {
                case Destroyed:
                    d.deaths++;
                    posMapper.get( e ).pos = new Vec2f( 0, 0 );
                    d.state = Respawning( 60 );
                case Respawning( n ):
                    if ( n > 0 ) {
                        d.state = Respawning( n - 1 );
                    } else {
                        d.state = Normal( 1 );
                    }
                default:
            }
        }
    }

    var posMapper          : ComponentMapper<PosCmp>;
    var destructibleMapper : ComponentMapper<DestructibleCmp>; // need to extract region polys from sector
}
