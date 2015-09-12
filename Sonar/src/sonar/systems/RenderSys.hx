package sonar.systems;
import com.artemisx.Aspect;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import com.artemisx.EntitySystem;
import com.artemisx.utils.Bag;
import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Sprite;
import sonar.components.BoundCmp;
import sonar.components.CameraCmp;
import sonar.components.DestructibleCmp;
import sonar.components.ExplosionCmp;
import sonar.components.PosCmp;
import sonar.components.RegionCmp;
import sonar.components.RenderCmp;
import sonar.components.ReticuleCmp;
import sonar.components.SonarCmp;
import sonar.components.StaticPosCmp;
import sonar.components.TorpedoCmp;
import sonar.components.TrailCmp;
import sonar.components.TraceCmp;

import sonar.Util;

import gml.vector.Vec2f;
import utils.Render;

import h2d.Tile;

using Lambda;

class RenderSys extends EntitySystem
{
    public function new( quad : h2d.Sprite ) {
        super( Aspect.getAspectForAll( [PosCmp, RenderCmp] ).exclude( [RegionCmp, SonarCmp, TrailCmp, TraceCmp, TorpedoCmp, ExplosionCmp, BoundCmp, ReticuleCmp] ) );

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
        var pos : Vec2f;
        var sectorPos : Vec2f;

        if ( actives.size > 0 && compensatingClear ) {
            g2d.clear();
            compensatingClear = false;
        }

        if ( camera == null ) return;

        for ( i in 0...actives.size ) {
            compensatingClear = true;
            e = actives.get( i );

            posCmp = posMapper.get( e );
            pos = Util.toScreen( SectorCoordinates( posCmp.pos, posCmp.sector ), camera );

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
