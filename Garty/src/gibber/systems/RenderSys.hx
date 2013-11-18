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
import gibber.Util;
import utils.Vec2;

using Lambda;

class RenderSys extends EntitySystem
{
    public function new( root : MovieClip ) {
        super( Aspect.getAspectForAll( [PosCmp, RenderCmp] ).exclude( [RegionCmp] ) );
        
        buffer = new Sprite();
        this.root = root;
        root.addChild( buffer );
        entitySpriteMap = new List();
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
        entitySpriteMap.add( { e : e, s : renderCmp.sprite } );
    }
    
    override public function onRemoved( e : Entity ) : Void {
        root.removeChild( renderMapper.get( e ).sprite );
    }
    
    override public function onChanged( e : Entity ) : Void {
        if ( renderMapper.getSafe( e ) == null ) {
           for ( v in entitySpriteMap ) {
               if ( v.e == e ) {
                   root.removeChild( v.s );
                   entitySpriteMap.remove( v );
               }
           }
           actives.remove( e );
        }
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
            pos = Util.worldCoords( posCmp.pos, posCmp.sector );
            
            g.beginFill( render.colour );
                g.drawCircle( pos.x, pos.y, 3 );
            g.endFill();
        }
    }
    
    var posMapper : ComponentMapper<PosCmp>;
    var renderMapper : ComponentMapper<RenderCmp>;
    var regionMapper : ComponentMapper<RegionCmp>;
    
    var root : MovieClip;
    var buffer : Sprite;
    var entitySpriteMap : List<{ e : Entity, s : Sprite }>;
    
    
}
