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
import gibber.components.TraceCmp;

import gibber.Util;

import utils.Vec2;
import utils.Render;

import h2d.Tile;

using Lambda;

class RenderSys extends EntitySystem
{
    public function new( quad : h2d.Sprite ) {
        super( Aspect.getAspectForAll( [PosCmp, RenderCmp] ).exclude( [RegionCmp, SonarCmp, TrailCmp, TraceCmp, TorpedoCmp, ExplosionCmp] ) );

        g2d = new h2d.Graphics( quad );
    }

    override public function initialize() : Void {
        posMapper = world.getMapper( PosCmp );
        regionMapper = world.getMapper( RegionCmp );
    }

    override public function onInserted( e : Entity ) : Void {
    }

    override public function onRemoved( e : Entity ) : Void {
    }

    override public function onChanged( e : Entity ) : Void {
    }

    override public function processEntities( entities : Bag<Entity> ) : Void  {
        var e : Entity;
        var posCmp : PosCmp;
        var pos : Vec2;
        var sectorPos : Vec2;

        if ( actives.size > 0 && compensatingClear ) {
            g2d.clear();
            compensatingClear = false;
        }

        trace( actives.size );

        for ( i in 0...actives.size ) {
            compensatingClear = true;
            e = actives.get( i );

            posCmp = posMapper.get( e );
            pos = Util.worldCoords( posCmp.pos, posCmp.sector );

            g2d.beginFill( 0xffffff );
            g2d.drawCircle( pos.x, pos.y, 3 );
            g2d.endFill();
        }
    }

    var posMapper : ComponentMapper<PosCmp>;
    var regionMapper : ComponentMapper<RegionCmp>;

    private var g2d : h2d.Graphics;
    private var compensatingClear : Bool;
}
