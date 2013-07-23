package gibber.systems;

import com.artemisx.Aspect;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import com.artemisx.EntitySystem;
import com.artemisx.utils.Bag;
import flash.display.MovieClip;
import flash.display.Sprite;
import gibber.components.RegionCmp;
import utils.Polygon;

class RenderSectorSys extends EntitySystem
{
    public function new( root : MovieClip ) {
        super( Aspect.getAspectForAll( [RegionCmp] ) );
        
        buffer = new Sprite();
        this.root = root;
        root.addChild( buffer );
    }
    
    override public function initialize() : Void {
        regionMapper = world.getMapper( RegionCmp );
    }
    
    override public function processEntities( entities : Bag<Entity> ) : Void  {
        var g = buffer.graphics;
        var e : Entity;
        var region : RegionCmp;
        var polys : Array<Polygon>;
        var p : Polygon;
        var l;
        
        for ( i in 0...actives.size ) {
            e = actives.get( i );
            region = regionMapper.get( e );
            polys = region.polys;
            
            g.moveTo( region.pos.x, region.pos.y );
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
    
    var root : MovieClip;
    var buffer : Sprite;
    
}