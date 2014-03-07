package gibber.systems;

import com.artemisx.Aspect;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import com.artemisx.EntitySystem;
import com.artemisx.utils.Bag;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.ColorTransform;
import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Sprite;

import gibber.components.CameraCmp;
import gibber.components.PosCmp;
import gibber.components.RenderCmp;
import gibber.components.SonarCmp;
import gibber.components.TimedEffectCmp;

import utils.Math2;
import utils.Render;
import utils.Vec2;

class RenderSonarSys extends EntitySystem
{
    public function new( quad : h2d.Sprite ) {
        super( Aspect.getAspectForAll( [SonarCmp, RenderCmp] ) );

        bmd    = new hxd.BitmapData( flash.Lib.current.stage.stageWidth, flash.Lib.current.stage.stageHeight );
        tile   = h2d.Tile.fromBitmap( bmd );
        bitbuf = new h2d.Bitmap( tile, quad );
    }

    override public function initialize() : Void {
        posMapper         = world.getMapper( PosCmp );
        sonarMapper       = world.getMapper( SonarCmp );
        timedEffectMapper = world.getMapper( TimedEffectCmp );
        renderMapper      = world.getMapper( RenderCmp );
    }

    public function setCamera( e : Entity ) : Void {
        camera = e;
    }

    override public function processEntities( entities : Bag<Entity> ) : Void  {
        var e : Entity;
        var render : RenderCmp;
        var sonar : SonarCmp;
        var time : TimedEffectCmp;
        var pos : PosCmp;
        var screenTransform : Vec2;

        if ( actives.size > 0 ) {
            bmd.fill( 0, 0, bmd.width, bmd.height, 0x00000000 ); //clear
        }

        if ( camera == null ) return;

        for ( i in 0...actives.size ) {
            e = actives.get( i );
            sonar = sonarMapper.get( e );
            time = timedEffectMapper.get( e );
            render = renderMapper.get( e );
            pos = posMapper.get( e );

            var radius : Float = sonar.growthRate * ( time.internalAcc / 1000.0 );

            screenTransform = posMapper.get( pos.sector ).pos;

            function plotPixelOnBmd( x: Int, y: Int ) {
                var alpha = Std.int( ( 1.0 - time.internalAcc / time.duration ) * 255 ) << 24;
                var cameraPos = posMapper.get( camera ).pos;
                var screenx = Std.int( x - cameraPos.x );
                var screeny = Std.int( y - cameraPos.y );
                bmd.setPixel( screenx, screeny, 0xffffff | alpha );
            }

            if ( sonar.cullRanges.length == 0 ) {
                Render.drawArc( pos.pos.add( screenTransform ), radius, 0, 1.0, plotPixelOnBmd ); //just draw circle
            } else {
                for ( i in 0...sonar.cullRanges.length ) {
                    var r1 = sonar.cullRanges[i];
                    var r2 = i == sonar.cullRanges.length - 1 ? sonar.cullRanges[0] : sonar.cullRanges[i + 1];
                    var diff = r2.start - r1.end; // invariant: r2.start comes after (clockwise) r1.end
                    if ( diff < 0 ) diff += 2 * Math.PI;
                    if ( diff > 2 * Math.PI ) diff -= 2 * Math.PI;
                    Render.drawArc( pos.pos.add( screenTransform ), radius, r1.end / ( 2 * Math.PI ), diff / ( 2 * Math.PI ), plotPixelOnBmd );
                }
            }
        }

        tile.getTexture().uploadBitmap( bmd );
    }

    var renderMapper      : ComponentMapper<RenderCmp>;
    var sonarMapper       : ComponentMapper<SonarCmp>;
    var posMapper         : ComponentMapper<PosCmp>;
    var timedEffectMapper : ComponentMapper<TimedEffectCmp>;

    private var bmd    : hxd.BitmapData;
    private var tile   : h2d.Tile;
    private var bitbuf : h2d.Bitmap;

    private var camera : Entity;
}
