package gibber.systems;
import com.artemisx.Aspect;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import com.artemisx.EntitySystem;
import com.artemisx.utils.Bag;
import flash.display.MovieClip;
import flash.display.Sprite;
import gibber.components.PosCmp;
import gibber.components.RegionCmp;
import utils.Vec2;

class RenderSys extends EntitySystem
{
    public function new( root : MovieClip ) {
        super( Aspect.getAspectForAll( [PosCmp] ) );
        
        buffer = new Sprite();
        this.root = root;
        root.addChild( buffer );
    }
    
    override public function initialize() : Void {
        posMapper = world.getMapper( PosCmp );
    }
    
    override public function processEntities( entities : Bag<Entity> ) : Void  {
        var g = buffer.graphics;
        var e : Entity;
        var pos : Vec2;
        
        g.clear();
        
        for ( i in 0...actives.size ) {
            e = actives.get( i );
            pos = posMapper.get( e ).pos;
            
            g.beginFill( 0xff00 );
                g.drawCircle( pos.x, pos.y, 3 );
            g.endFill();
        }
        
        
        
    }
    
    var posMapper : ComponentMapper<PosCmp>;
    
    var root : MovieClip;
    var buffer : Sprite;
    
    
}