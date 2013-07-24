package gibber.systems;

import com.artemisx.Aspect;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import com.artemisx.EntitySystem;
import com.artemisx.utils.Bag;
import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Sprite;
import gibber.components.RegionCmp;
import gibber.components.RenderCmp;
import utils.Polygon;

class RenderSectorSys extends EntitySystem
{
    public function new( root : MovieClip ) {
        super( Aspect.getAspectForAll( [RegionCmp, RenderCmp] ) );
        
        buffer = new Sprite();
        this.root = root;
        root.addChild( buffer );
    }
    
    override public function initialize() : Void {
        regionMapper = world.getMapper( RegionCmp );
        renderMapper = world.getMapper( RenderCmp );
    }
    
    override public function onInserted( e : Entity ) : Void {
        var renderCmp = renderMapper.get( e );
        renderCmp.sprite = new Sprite();
        root.addChild( renderCmp.sprite );
    }
    
    override public function onRemoved( e : Entity ) : Void {
        root.removeChild( renderMapper.get( e ).sprite );
    }
    
    override public function processEntities( entities : Bag<Entity> ) : Void  {
        var g : Graphics;
        var e : Entity;
        var region : RegionCmp;
        var render : RenderCmp;
        var polys : Array<Polygon>;
        var p : Polygon;
        var l;
        
        for ( i in 0...actives.size ) {
            e = actives.get( i );
            region = regionMapper.get( e );
            polys = region.polys;
            
            render = renderMapper.get( e );
            render.sprite.x = region.pos.x;
            render.sprite.y = region.pos.y;
            g = render.sprite.graphics;
            g.clear();
            
            for ( j in 0...polys.length ) {
                p = polys[j];
                
                g.beginFill( 0xffff00 );
                g.moveTo( p.edges[0].x, p.edges[0].y );
                for ( k in 0...p.edges.length ) {
                    g.lineTo( p.edges[k].x, p.edges[k].y );
                }
                g.endFill();
            }
        }
    }
    
    var regionMapper : ComponentMapper<RegionCmp>;
    var renderMapper : ComponentMapper<RenderCmp>;
    
    var root : MovieClip;
    var buffer : Sprite;
    
}