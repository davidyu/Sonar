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

import gibber.components.PosCmp;
import gibber.components.RenderCmp;
import gibber.components.SonarCmp;
import gibber.components.TimedEffectCmp;

import utils.Vec2;
import utils.Math2;

//@dyu: FINISH THIS
class RenderSonarSys extends EntitySystem
{
    public function new( root : MovieClip ) {
        super( Aspect.getAspectForAll( [SonarCmp, RenderCmp] ) );

        bmd    = new BitmapData( root.stage.stageWidth, root.stage.stageHeight, true, 0x00000000 );
        bitbuf = new Bitmap( bmd );
        this.root = root;

        root.addChild( bitbuf );
    }

    override public function initialize() : Void {
        posMapper         = world.getMapper( PosCmp );
        sonarMapper       = world.getMapper( SonarCmp );
        timedEffectMapper = world.getMapper( TimedEffectCmp );
        renderMapper      = world.getMapper( RenderCmp );
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
        var e : Entity;
        var render : RenderCmp;
        var sonar : SonarCmp;
        var time : TimedEffectCmp;
        var pos : PosCmp;
        var screenTransform : Vec2;

        if ( actives.size > 0 )
            bmd.fillRect( bmd.rect, 0x00000000 );

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
                bmd.setPixel32( x, y, 0xffffff | alpha );
            }

            if ( sonar.cullRanges.length == 0 ) {
                drawArc( pos.pos.add( screenTransform ), radius, 0, 1.0, plotPixelOnBmd ); //just draw circle
            } else {
                for ( i in 0...sonar.cullRanges.length ) {
                    var r1 = sonar.cullRanges[i];
                    var r2 = i == sonar.cullRanges.length - 1 ? sonar.cullRanges[0] : sonar.cullRanges[i + 1];
                    var diff = r2.start - r1.end; // invariant: r2.start comes after (clockwise) r1.end
                    if ( diff < 0 ) diff += 2 * Math.PI;
                    if ( diff > 2 * Math.PI ) diff -= 2 * Math.PI;
                    drawArc( pos.pos.add( screenTransform ), radius, r1.end / ( 2 * Math.PI ), diff / ( 2 * Math.PI ), plotPixelOnBmd );
                }
            }
        }
    }

    private function drawArc( center, radius : Float, startAngle : Float, arcAngle : Float, plot: Int->Int-> Void ){
        var steps = Std.int( arcAngle * 100 ); //adaptive sampling FTW!
        startAngle -= .25;
        var twoPI = 2 * Math.PI;
        var angleStep = arcAngle/steps;
        var xx : Int = Std.int( center.x + Math.cos( startAngle * twoPI ) * radius );
        var yy : Int = Std.int( center.y + Math.sin( startAngle * twoPI ) * radius );
        var x : Int = xx;
        var y : Int = yy;
        for ( i in 1...steps + 1 ) {
            var angle = startAngle + i * angleStep;
            xx = Std.int( center.x + Math.cos( angle * twoPI ) * radius );
            yy = Std.int( center.y + Math.sin( angle * twoPI ) * radius );
            bresenham( x, y, xx, yy, plot );
            x = xx;
            y = yy;
        }
    }

    private function bresenham( x0, y0, x1, y1, plot: Int->Int-> Void ) {
        var dx : Float = Math.abs( x1 - x0 );
        var dy : Float = Math.abs( y1 - y0 );

        var xStep : Int = 0;
        var yStep : Int = 0;

        // this takes care of all possible slopes
        if ( x0 < x1 ) xStep = 1 else xStep = -1;
        if ( y0 < y1 ) yStep = 1 else yStep = -1;

        var err : Float = dx - dy; // in the vanilla algorithm, if Math.abs(err) > 0.5 then we increment y by yStep

        while ( true ) {
            plot( x0, y0 );
            if ( x0 == x1 && y0 == y1 ) break;

            var e2 = err * 2;
            if ( e2 > -dy ) { // -> 2dx > dy ( slope is greater than 1/2 )
                err -= dy;
                x0 += xStep;
            }

            if ( x0 == x1 && y0 == y1 ) {
                plot( x0, y0 );
                break;
            }

            if ( e2 < dx ) { // -> 2dy > dx ( slope is less than 2 )
                err += dx;
                y0 += yStep;
            }
        }
    }

    var renderMapper      : ComponentMapper<RenderCmp>;
    var sonarMapper       : ComponentMapper<SonarCmp>;
    var posMapper         : ComponentMapper<PosCmp>;
    var timedEffectMapper : ComponentMapper<TimedEffectCmp>;

    private var root   : MovieClip;
    private var bmd    : BitmapData;
    private var bitbuf : Bitmap;
}
