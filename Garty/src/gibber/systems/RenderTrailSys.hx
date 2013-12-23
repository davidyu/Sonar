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
import gibber.components.RenderCmp;
import gibber.components.TrailCmp;
import gibber.components.TimedEffectCmp;

class RenderTrailSys extends EntitySystem
{
    public function new( root : MovieClip ) {
        super( Aspect.getAspectForAll( [TrailCmp, RenderCmp] ) );

        bmd = new BitmapData( root.stage.stageWidth, root.stage.stageHeight, true, 0xff000000 );
        bitbuf    = new Bitmap( bmd );
        this.root = root;

        root.addChild( bitbuf );
    }

    override public function initialize() : Void {
        posMapper         = world.getMapper( PosCmp );
        timedEffectMapper = world.getMapper( TimedEffectCmp );
        trailMapper       = world.getMapper( TrailCmp );
        fade              = new ColorTransform( 1.0, 1.0, 1.0, 0.9 );
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

        bmd.colorTransform( bmd.rect, fade ); // fade out every frame

        for ( i in 0...actives.size ) {
            e   = actives.get( i );
            time = timedEffectMapper.get( e );
            trail = trailMapper.get( e );
            pos = posMapper.get( e );

            // implement brensenham to draw line from prev pos to current?
            bmd.setPixel32( Std.int( pos.pos.x ), Std.int( pos.pos.y ), 0xffffffff ); // won't work until we have localToGloba, etc
        }
    }

    var renderMapper      : ComponentMapper<RenderCmp>;
    var trailMapper       : ComponentMapper<TrailCmp>;
    var posMapper         : ComponentMapper<PosCmp>;
    var timedEffectMapper : ComponentMapper<TimedEffectCmp>;

    private var root   : MovieClip;
    private var bitbuf : Bitmap;
    private var bmd    : BitmapData;
    private var fade   : ColorTransform;
}
