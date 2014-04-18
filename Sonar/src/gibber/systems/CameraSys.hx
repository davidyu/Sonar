package gibber.systems;

import com.artemisx.Aspect;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import com.artemisx.EntitySystem;
import com.artemisx.utils.Bag;

import gibber.components.CameraCmp;
import gibber.components.PosCmp;

import gibber.systems.RenderSys;
import gibber.systems.RenderTraceSys;
import gibber.systems.RenderGridSys;

import utils.Vec2;

class CameraSys extends EntitySystem
{
    public function new() {
        super( Aspect.getAspectForAll( [CameraCmp, PosCmp] ) );
    }

    override public function initialize() : Void {
        cameraMapper = world.getMapper( CameraCmp );
        posMapper    = world.getMapper( PosCmp );
    }

    override public function onInserted( e : Entity ) : Void {
        world.getSystem( RenderSys ).setCamera( e );
        world.getSystem( RenderSonarSys ).setCamera( e );
        world.getSystem( RenderExplosionSys ).setCamera( e );
        world.getSystem( RenderGridSys ).setCamera( e );
        world.getSystem( RenderTorpedoSys ).setCamera( e );
        world.getSystem( RenderTraceSys ).setCamera( e );
        world.getSystem( RenderTrailSys ).setCamera( e );
        world.getSystem( ControllerSys ).setCamera( e );
        world.getSystem( ReticuleSys ).setCamera( e );
    }

    override public function processEntities( entities : Bag<Entity> ) : Void  {
        var e : Entity;
        var camera : CameraCmp;
        var camPos : PosCmp;

        for ( i in 0...actives.size ) {
            e = actives.get( i );
            camera = cameraMapper.get( e );
            camPos = posMapper.get( e );

            switch ( camera.target ) {
                case StaticTarget( pos, sector ):
                case DynamicTarget( t ):
                    var tpos = posMapper.get( t );
                    if ( tpos != null ) {
                        var fudgeCenterOffset = new Vec2( camera.viewportW/2, camera.viewportH/2 ); // centers target
                        camPos.pos = Util.toWorld( SectorCoordinates( tpos.pos, tpos.sector ) ).sub( fudgeCenterOffset );
                    } else {
                        throw "can't track a target without a posCmp!";
                    }
            }
        }
    }

    var cameraMapper : ComponentMapper<CameraCmp>;
    var posMapper    : ComponentMapper<PosCmp>;
}
