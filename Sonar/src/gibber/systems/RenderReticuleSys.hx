package gibber.systems;

import com.artemisx.Aspect;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import com.artemisx.EntitySystem;
import com.artemisx.utils.Bag;

import gibber.components.PosCmp;
import gibber.components.RenderCmp;
import gibber.components.ReticuleCmp;

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
    }

    public function setCamera( e : Entity ) : Void {
        camera = e;
    }

    override public function processEntities( entities : Bag<Entity> ) : Void  {
        var e : Entity;
        var render : RenderCmp;
        var posCmp : PosCmp;
        var pos : Vec2;

        g2d.clear();

        if ( camera == null ) return;

        for ( i in 0...actives.size ) {
            e = actives.get( i );
            render = renderMapper.get( e );

            posCmp = posMapper.get( e );
            pos = Util.toScreen( SectorCoordinates( posCmp.pos, posCmp.sector ), camera );

            g2d.beginFill( 0xffffff );
            g2d.drawRect( pos.x - 5, pos.y - 5, 10, 10 );
            g2d.endFill();
        }
    }

    var posMapper : ComponentMapper<PosCmp>;
    var renderMapper : ComponentMapper<RenderCmp>;

    private var camera : Entity;
    private var g2d  : h2d.Graphics;
}
