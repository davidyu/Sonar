package gibber.systems;

import com.artemisx.Aspect;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import com.artemisx.EntitySystem;
import com.artemisx.utils.Bag;

import gibber.components.DestructibleCmp;
import gibber.components.PosCmp;
import gibber.managers.ContainerMgr;

import utils.Geo;
import utils.Polygon;
import utils.Vec2;
import utils.Math2;

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
                    posMapper.get( e ).pos = new Vec2( 0, 0 );
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
