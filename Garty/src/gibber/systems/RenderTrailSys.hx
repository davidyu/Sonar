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
import gibber.components.SonarCmp;
import gibber.components.TimedEffectCmp;

class RenderTrailSys extends EntitySystem
{
    public function new( root : MovieClip ) {
        super( Aspect.getAspectForAll( [RenderCmp] ) );

        bmd       = new BitmapData( root.stage.stageWidth, root.stage.stageHeight, false, 0xcccccc );
        bitbuf    = new Bitmap( bmd );
        this.root = root;

        root.addChild( bitbuf );
    }

    override public function initialize() : Void {
        posMapper         = world.getMapper( PosCmp );
    }

    override public function onInserted( e : Entity ) : Void {
    }

    override public function onRemoved( e : Entity ) : Void {
    }

    override public function processEntities( entities : Bag<Entity> ) : Void  {
      var ct: ColorTransform = new ColorTransform( 1.0, 1.0, 1.0, 1.0, Math.random() * 255, Math.random() * 255, Math.random() * 255 );
      bmd.fillRect( bmd.rect, ct.color );
    }

    var renderMapper      : ComponentMapper<RenderCmp>;
    var posMapper         : ComponentMapper<PosCmp>;
    var timedEffectMapper : ComponentMapper<TimedEffectCmp>;

    private var root   : MovieClip;
    private var bitbuf : Bitmap;
    private var bmd    : BitmapData;
}
