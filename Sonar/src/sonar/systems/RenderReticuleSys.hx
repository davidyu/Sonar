package sonar.systems;

import com.artemisx.Aspect;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import com.artemisx.EntitySystem;
import com.artemisx.utils.Bag;

import sonar.components.PosCmp;
import sonar.components.RenderCmp;
import sonar.components.ReticuleCmp;
import sonar.components.ControllerCmp;

import utils.Vec2;

class RenderReticuleSys extends EntitySystem
{
    public function new( quad : h2d.Sprite ) {
        super( Aspect.getAspectForAll( [ReticuleCmp, RenderCmp] ) );

        g2d = new h2d.Graphics( quad );
    }

    override public function initialize() : Void {
        posMapper = world.getMapper( PosCmp );
        renderMapper = world.getMapper( RenderCmp );
        reticuleMapper = world.getMapper( ReticuleCmp );
        controllerMapper = world.getMapper( ControllerCmp );
    }

    public function setCamera( e : Entity ) : Void {
        camera = e;
    }

    override public function processEntities( entities : Bag<Entity> ) : Void  {
        var e : Entity;
        var render : RenderCmp;
        var reticule : ReticuleCmp;
        var posCmp : PosCmp;
        var pos : Vec2;

        g2d.clear();

        if ( camera == null ) return;

        for ( i in 0...actives.size ) {
            e = actives.get( i );
            render = renderMapper.get( e );
            reticule = reticuleMapper.get( e );
            posCmp = posMapper.get( e );

            if ( controllerMapper.get( reticule.player ).torpedo != Guiding ) return;

            pos = Util.toScreen( SectorCoordinates( posCmp.pos, posCmp.sector ), camera );

            // top line
            g2d.beginFill( 0xffffff );
            g2d.drawRect( pos.x - 5, pos.y - 5, 10, 1 );
            g2d.endFill();

            // bottom line
            g2d.beginFill( 0xffffff );
            g2d.drawRect( pos.x - 5, pos.y + 5, 10, 1 );
            g2d.endFill();

            // left line
            g2d.beginFill( 0xffffff );
            g2d.drawRect( pos.x - 5, pos.y - 5, 1, 10 );
            g2d.endFill();

            // right line
            g2d.beginFill( 0xffffff );
            g2d.drawRect( pos.x + 5, pos.y - 5, 1, 10 );
            g2d.endFill();
        }
    }

    var reticuleMapper : ComponentMapper<ReticuleCmp>;
    var controllerMapper : ComponentMapper<ControllerCmp>;
    var posMapper : ComponentMapper<PosCmp>;
    var renderMapper : ComponentMapper<RenderCmp>;

    private var camera : Entity;
    private var g2d  : h2d.Graphics;
}
