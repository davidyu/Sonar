package gibber.systems;

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

import gibber.components.PosCmp;
import gibber.components.RenderCmp;
import gibber.components.ExplosionCmp;
import gibber.components.TimedEffectCmp;

import utils.Math2;
import utils.Render;
import utils.Vec2;

class RenderExplosionSys extends EntitySystem
{
    public function new( root : MovieClip ) {
        super( Aspect.getAspectForAll( [ExplosionCmp, RenderCmp] ) );

        bmd    = new BitmapData( root.stage.stageWidth, root.stage.stageHeight, true, 0x000000ff );
        bitbuf = new Bitmap( bmd );
        this.root = root;

        root.addChild( bitbuf );
    }

    override public function initialize() : Void {
        fade              = new ColorTransform( 1.0, 1.0, 1.0, 0.9 );
        posMapper         = world.getMapper( PosCmp );
        explosionMapper   = world.getMapper( ExplosionCmp );
        timedEffectMapper = world.getMapper( TimedEffectCmp );
        compensatingFades = 30;
    }

    override public function onInserted( e : Entity ) : Void {
    }

    override public function onRemoved( e : Entity ) : Void {
    }

    override public function processEntities( entities : Bag<Entity> ) : Void  {
        var e : Entity;
        var explosion : ExplosionCmp;
        var time : TimedEffectCmp;
        var pos : PosCmp;
        var screenTransform : Vec2;

        if ( actives.size == 0 ) {
            bmd.colorTransform( bmd.rect, fade ); // fade out every update
        } else {
            bmd.fillRect( bmd.rect, 0x000000ff ); // fade out every update
        }

        for ( i in 0...actives.size ) {
            e = actives.get( i );
            explosion = explosionMapper.get( e );
            time = timedEffectMapper.get( e );
            pos = posMapper.get( e );

            var radius : Float = explosion.growthRate * ( time.internalAcc / 1000.0 );

            screenTransform = posMapper.get( pos.sector ).pos;

            function plotPixelOnBmd( x: Int, y: Int ) {
                bmd.setPixel32( x, y, 0xffffffff );
            }

            var centerOnScreen : Vec2 = pos.pos.add( screenTransform );

            // draw circle outline
            Render.drawArc( centerOnScreen, radius, 0, 1.0, plotPixelOnBmd );
            // fill it
            if ( radius > 1 ) {
                bmd.floodFill( Std.int( centerOnScreen.x ), Std.int( centerOnScreen.y ), 0xffffffff );
            }
        }
    }

    var explosionMapper   : ComponentMapper<ExplosionCmp>;
    var posMapper         : ComponentMapper<PosCmp>;
    var timedEffectMapper : ComponentMapper<TimedEffectCmp>;

    private var root   : MovieClip;
    private var bmd    : BitmapData;
    private var bitbuf : Bitmap;
    private var fade   : ColorTransform;
    private var compensatingFades : Int;
}
