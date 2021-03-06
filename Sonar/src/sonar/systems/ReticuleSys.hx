package sonar.systems;

import com.artemisx.Aspect;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import com.artemisx.EntitySystem;
import com.artemisx.utils.Bag;

import sonar.components.ReticuleCmp;
import sonar.components.PosCmp;
import sonar.Util;

import utils.Mouse;

class ReticuleSys extends EntitySystem
{
    public function new() {
        super( Aspect.getAspectForAll( [ ReticuleCmp, PosCmp ] ) );
    }

    override public function initialize() : Void {
        reticuleMapper = world.getMapper( ReticuleCmp );
        posMapper      = world.getMapper( PosCmp );
    }

    public function setCamera( e : Entity ) : Void {
        camera = e;
    }

    override public function processEntities( entities : Bag<Entity> ) : Void  {
        var e : Entity;
        var r : ReticuleCmp;
        var p : PosCmp;

        for ( i in 0...actives.size ) {
            e = actives.get( i );
            r = reticuleMapper.get( e );
            p = posMapper.get( e );

            if ( camera != null ) {
                var targetPos = Util.toSector( ScreenCoordinates( Mouse.getMouseCoords(), camera ), p.sector );
                p.dp = ( targetPos - p.pos ) / 10; // shitty way

                // clamp
                if ( p.dp.lensq() > r.maxSpeed ) {
                    p.dp * ( r.maxSpeed / p.dp.len() );
                }
            }
        }
    }

    var posMapper      : ComponentMapper<PosCmp>;
    var reticuleMapper : ComponentMapper<ReticuleCmp>;

    private var camera : Entity;
}
