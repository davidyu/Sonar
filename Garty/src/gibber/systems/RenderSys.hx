package gibber.systems;
import com.artemisx.Aspect;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import com.artemisx.EntitySystem;
import com.artemisx.utils.Bag;
import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Sprite;
import gibber.components.ExplosionCmp;
import gibber.components.PosCmp;
import gibber.components.RegionCmp;
import gibber.components.RenderCmp;
import gibber.components.SonarCmp;
import gibber.components.StaticPosCmp;
import gibber.components.TorpedoCmp;
import gibber.components.TrailCmp;
import gibber.Util;

import utils.Vec2;
import utils.Render;

import h2d.Tile;

using Lambda;

class RenderSys extends EntitySystem
{
    public function new( root : MovieClip, quad : h2d.Sprite ) {
        super( Aspect.getAspectForAll( [PosCmp, RenderCmp] ).exclude( [RegionCmp, SonarCmp, TrailCmp, TorpedoCmp, ExplosionCmp] ) );

        this.root = root;
        g2d = new h2d.Graphics( quad );
    }

    override public function initialize() : Void {
        posMapper = world.getMapper( PosCmp );
        renderMapper = world.getMapper( RenderCmp );
        regionMapper = world.getMapper( RegionCmp );
    }

    override public function onInserted( e : Entity ) : Void {
        var renderCmp = renderMapper.get( e );
        renderCmp.sprite = new Sprite();
        root.addChild( renderCmp.sprite );
    }

    override public function onRemoved( e : Entity ) : Void {
        root.removeChild( renderMapper.get( e ).sprite );
    }

    override public function onChanged( e : Entity ) : Void {
    }

    override public function processEntities( entities : Bag<Entity> ) : Void  {
        var g : Graphics;
        var e : Entity;
        var posCmp : PosCmp;
        var pos : Vec2;
        var sectorPos : Vec2;

        g2d.clear();
        
        for ( i in 0...actives.size ) {
            e = actives.get( i );
            var render = renderMapper.get( e );
            g = render.sprite.graphics;
            g.clear();
            
            posCmp = posMapper.get( e );
            pos = Util.worldCoords( posCmp.pos, posCmp.sector );
            
            g2d.beginFill( 0xffffff );
            g2d.drawCircle( pos.x, pos.y, 3, 6 );
            g2d.endFill();
        }
    }

    var posMapper : ComponentMapper<PosCmp>;
    var renderMapper : ComponentMapper<RenderCmp>;
    var regionMapper : ComponentMapper<RegionCmp>;

    var root : MovieClip;

    private var g2d : h2d.Graphics;
}
