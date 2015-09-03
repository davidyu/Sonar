package sonar.systems;

import com.artemisx.Aspect;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import com.artemisx.EntitySystem;
import com.artemisx.utils.Bag;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.ColorTransform;
import flash.geom.Rectangle;
import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Sprite;

import sonar.components.PosCmp;
import sonar.components.RenderCmp;
import sonar.components.ExplosionCmp;
import sonar.components.TimedEffectCmp;

import utils.Math2;
import utils.Render;
import utils.Vec2;

class RenderExplosionSys extends EntitySystem
{
    public function new( quad : h2d.Sprite ) {
        super( Aspect.getAspectForAll( [ExplosionCmp, RenderCmp] ) );

        g2d = new h2d.Graphics( quad );
    }

    override public function initialize() : Void {
        posMapper         = world.getMapper( PosCmp );
        explosionMapper   = world.getMapper( ExplosionCmp );
        timedEffectMapper = world.getMapper( TimedEffectCmp );
        compensatingClear = true;
    }

    public function setCamera( e : Entity ) : Void {
        camera = e;
    }

    override public function processEntities( entities : Bag<Entity> ) : Void  {
        var e : Entity;
        var explosion : ExplosionCmp;
        var time : TimedEffectCmp;
        var pos : PosCmp;
        var screenTransform : Vec2;

        if ( actives.size > 0 || compensatingClear ) {
            g2d.clear();
            compensatingClear = false;
        }

        if ( camera == null ) return;

        for ( i in 0...actives.size ) {
            compensatingClear = true;
            e = actives.get( i );
            explosion = explosionMapper.get( e );
            time = timedEffectMapper.get( e );
            pos = posMapper.get( e );

            var radius : Float = explosion.growthRate * ( time.internalAcc / 1000.0 );
            if ( radius > explosion.maxRadius ) {
                radius = explosion.maxRadius;
            }
            var center = Util.toScreen( SectorCoordinates( pos.pos, pos.sector ), camera );

            g2d.beginFill( 0xffffff );
            g2d.drawCircle( center.x, center.y, radius );
            g2d.endFill();
        }
    }

    var explosionMapper   : ComponentMapper<ExplosionCmp>;
    var posMapper         : ComponentMapper<PosCmp>;
    var timedEffectMapper : ComponentMapper<TimedEffectCmp>;

    private var g2d : h2d.Graphics;
    private var compensatingClear : Bool;
    private var camera : Entity;
}
