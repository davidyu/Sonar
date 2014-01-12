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

        buffer = new Sprite();
        this.root = root;

        root.addChild( buffer );
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

        for ( i in 0...actives.size ) {
            e = actives.get( i );
            sonar = sonarMapper.get( e );
            time = timedEffectMapper.get( e );
            render = renderMapper.get( e );
            pos = posMapper.get( e );

            var radius : Float = sonar.growthRate * ( time.internalAcc / 1000.0 );

            render.sprite.x = posMapper.get( pos.sector ).pos.x; //too much lambda lifting
            render.sprite.y = posMapper.get( pos.sector ).pos.y;

            var g = render.sprite.graphics;
            g.clear();

            g.lineStyle( 2.0, render.colour, 1.0 - time.internalAcc / time.duration );

            if ( sonar.cullRanges.length == 0 ) {
                g.drawCircle( pos.pos.x, pos.pos.y, radius ); //just draw circle
            } else if ( sonar.cullRanges.length == 1 ) {
                var start = sonar.cullRanges[0].end;
                var range = sonar.cullRanges[0].start - sonar.cullRanges[0].end;
                if ( range < Math.PI ) {
                    range -= 2 * Math.PI;
                } else if ( range > -Math.PI ) {
                    range += 2 * Math.PI;
                }
                drawArc( g, pos.pos, radius, start / ( 2 * Math.PI ), range / ( 2 * Math.PI ) );
            } else {
                for ( i in 0...sonar.cullRanges.length ) {
                    var r1 = sonar.cullRanges[i];
                    var r2 = i == sonar.cullRanges.length - 1 ? sonar.cullRanges[0] : sonar.cullRanges[i + 1];
                    drawArc( g, pos.pos, radius, r1.end / ( 2 * Math.PI ), ( r2.start - r1.end ) / ( 2 * Math.PI ) );
                }
            }
        }
    }

    private function drawArc( g, center, radius : Float, startAngle : Float, arcAngle : Float, steps = 20 ){
        startAngle -= .25;
        var twoPI = 2 * Math.PI;
        var angleStep = arcAngle/steps;
        var xx = center.x + Math.cos( startAngle * twoPI ) * radius;
        var yy = center.y + Math.sin( startAngle * twoPI ) * radius;
        g.moveTo( xx, yy );
        for ( i in 1...steps + 1 ) {
            var angle = startAngle + i * angleStep;
            xx = center.x + Math.cos( angle * twoPI ) * radius;
            yy = center.y + Math.sin( angle * twoPI ) * radius;
            g.lineTo( xx, yy );
        }
    }

    var renderMapper      : ComponentMapper<RenderCmp>;
    var sonarMapper       : ComponentMapper<SonarCmp>;
    var posMapper         : ComponentMapper<PosCmp>;
    var timedEffectMapper : ComponentMapper<TimedEffectCmp>;

    private var root   : MovieClip;
    private var buffer : Sprite;
}
