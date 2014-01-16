package gibber.systems;

import com.artemisx.Aspect;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import com.artemisx.EntitySystem;
import com.artemisx.utils.Bag;

import flash.geom.ColorTransform;

import flash.display.BitmapData;
import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Bitmap;

import gibber.components.PosCmp;
import gibber.components.PosTrackerCmp;
import gibber.components.RenderCmp;
import gibber.components.TrailCmp;
import gibber.components.TimedEffectCmp;

import utils.Render;
import utils.Vec2;

using Lambda;

class RenderTrailSys extends EntitySystem
{
    public function new( root : MovieClip ) {
        super( Aspect.getAspectForAll( [TrailCmp, RenderCmp] ) );

        bmd       = new BitmapData( root.stage.stageWidth, root.stage.stageHeight, true, 0x00000000 );
        bitbuf    = new Bitmap( bmd );
        this.root = root;

        root.addChild( bitbuf );
    }

    override public function initialize() : Void {
        posMapper         = world.getMapper( PosCmp );
        posTrackerMapper  = world.getMapper( PosTrackerCmp );
        timedEffectMapper = world.getMapper( TimedEffectCmp );
        trailMapper       = world.getMapper( TrailCmp );
        fade              = new ColorTransform( 1.0, 1.0, 1.0, 0.9 );
        compensatingFades = 30;
    }

    override public function onInserted( e : Entity ) : Void {
    }

    override public function onRemoved( e : Entity ) : Void {
    }

    override public function processEntities( entities : Bag<Entity> ) : Void  {
        var e : Entity;
        var time : TimedEffectCmp;
        var trail : TrailCmp;
        var pos : PosCmp;
        var posTracker : PosTrackerCmp;
        var lastScreenPos : Vec2;
        var curScreenPos : Vec2;

        if ( actives.size > 0 || compensatingFades > 0 ) {
            bmd.colorTransform( bmd.rect, fade ); // fade out every update
            compensatingFades--;
        }

        for ( i in 0...actives.size ) {
            e   = actives.get( i );
            time = timedEffectMapper.get( e );
            trail = trailMapper.get( e );
            pos = posMapper.get( e );
            posTracker = posTrackerMapper.get( e );

            // implement brensenham to draw line from prev pos to current?
            // there should be a helper function (maybe it exists already) to get abs coords of a posCmp
            lastScreenPos = posTracker.getLastPosition().add( posMapper.get( pos.sector ).pos );
            curScreenPos = pos.pos.add( posMapper.get( pos.sector ).pos );

            // pass this into bresenham
            function plotPixelOnBmd( x: Int, y: Int ) {
                bmd.setPixel32( x, y, 0xffffffff );
            }

            Render.bresenham( Std.int( lastScreenPos.x ), Std.int( lastScreenPos.y ),
                              Std.int( curScreenPos.x ) , Std.int( curScreenPos.y ) ,
                              plotPixelOnBmd );

            compensatingFades = 30; // in case this is the final active entity; force the system to apply a few more fades before short-circuiting
        }
    }

    var renderMapper      : ComponentMapper<RenderCmp>;
    var trailMapper       : ComponentMapper<TrailCmp>;
    var posMapper         : ComponentMapper<PosCmp>;
    var timedEffectMapper : ComponentMapper<TimedEffectCmp>;
    var posTrackerMapper  : ComponentMapper<PosTrackerCmp>;

    private var root   : MovieClip;
    private var bitbuf : Bitmap;
    private var bmd    : BitmapData;
    private var fade   : ColorTransform;
    private var compensatingFades : Int;
}
