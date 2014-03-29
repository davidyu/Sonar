package gibber.systems;
import com.artemisx.Aspect;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import com.artemisx.EntitySystem;
import com.artemisx.utils.Bag;
import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Sprite;
import gibber.components.BoundCmp;
import gibber.components.CameraCmp;
import gibber.components.DestructibleCmp;
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
        super( Aspect.getAspectForAll( [PosCmp, RenderCmp] ).exclude( [RegionCmp, SonarCmp, TrailCmp, TraceCmp, TorpedoCmp, ExplosionCmp, BoundCmp] ) );

        g2d = new h2d.Graphics( quad );
    }

    override public function initialize() : Void {
        destructibleMapper = world.getMapper( DestructibleCmp );
        posMapper = world.getMapper( PosCmp );
        regionMapper = world.getMapper( RegionCmp );
        cameraMapper = world.getMapper( CameraCmp );
    }

    public function setCamera( e : Entity ) : Void {
        camera = e;
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

        if ( camera == null ) return;

        for ( i in 0...actives.size ) {
            compensatingClear = true;
            e = actives.get( i );

            posCmp = posMapper.get( e );
            pos = Util.screenCoords( posCmp.pos, camera, posCmp.sector );

            if ( destructibleMapper.get( e ) != null ) {
                var d = destructibleMapper.get( e );
                switch ( d.state ) {
                    case Respawning( n ): if ( n % 4 == 0 ) continue; // don't draw / flicker
                    default:
                }
            }
            g2d.beginFill( 0xffffff );
            g2d.drawCircle( pos.x, pos.y, 3 );
            g2d.endFill();
        }
    }

    var posMapper : ComponentMapper<PosCmp>;
    var regionMapper : ComponentMapper<RegionCmp>;
    var cameraMapper : ComponentMapper<CameraCmp>;
    var destructibleMapper : ComponentMapper<DestructibleCmp>;

    private var g2d : h2d.Graphics;
    private var compensatingClear : Bool;
    private var camera : Entity;
}
