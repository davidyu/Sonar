package gibber.systems;
import com.artemisx.Aspect;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import com.artemisx.EntitySystem;
import com.artemisx.utils.Bag;
import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Sprite;
import gibber.components.PosCmp;
import gibber.components.RegionCmp;
import gibber.components.RenderCmp;
import gibber.components.StaticPosCmp;
import utils.Vec2;

class RenderSys extends EntitySystem
{
    public function new( root : MovieClip ) {
        super( Aspect.getAspectForAll( [PosCmp, RenderCmp] ).exclude( [RegionCmp] ) );
        
        buffer = new Sprite();
        this.root = root;
        root.addChild( buffer );
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
    
    override public function processEntities( entities : Bag<Entity> ) : Void  {
        var g : Graphics;
        var e : Entity;
        var posCmp : PosCmp;
        var pos : Vec2;
        var sectorPos : Vec2;
        
        for ( i in 0...actives.size ) {
            e = actives.get( i );
            var render = renderMapper.get( e );
            g = render.sprite.graphics;
            g.clear();
            
            posCmp = posMapper.get( e );
            pos = posCmp.pos;
            sectorPos = posMapper.get( posCmp.sector ).pos;
            
            g.moveTo( sectorPos.x, sectorPos.y );
            g.beginFill( render.colour );
                g.drawCircle( sectorPos.x + pos.x, sectorPos.y + pos.y, 3 );
            g.endFill();
        }
    }
    
    var posMapper : ComponentMapper<PosCmp>;
    var renderMapper : ComponentMapper<RenderCmp>;
    var regionMapper : ComponentMapper<RegionCmp>;
    
    var root : MovieClip;
    var buffer : Sprite;
    
    
}