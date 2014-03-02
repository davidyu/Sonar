package ;

import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.Lib;
import gibber.God;

import h3d.scene.*;

#if debug
import com.sociodox.theminer.TheMiner;
#end

using gibber.Util;

class Main 
{
    static var engine : h3d.Engine;
    static var scene : h2d.Scene;
    static var backscene : h2d.Scene;
    static var framebuffer : h2d.Sprite; // accumulator
    static var bitbuf : h2d.Bitmap; // intermediate
    static var frame : h2d.Sprite;

    static function update()
    {
        backscene.captureBitmap( bitbuf.tile );
        engine.render( scene );
    }

    static function main()
    {
        engine = new h3d.Engine();
        scene = new h2d.Scene();
        backscene = new h2d.Scene();

        engine.onReady = function() {
            frame = new h2d.Sprite( scene );
            frame.x = 0;
            frame.y = 0;

            var bmd = new hxd.BitmapData( engine.width, engine.height );
            var tile = h2d.Tile.fromBitmap( bmd );
            bitbuf = new h2d.Bitmap( tile, frame );

            framebuffer = new h2d.Sprite( backscene );
            framebuffer.x = 0;
            framebuffer.y = 0;

            trace( "Starting up God" );
            var g = new God( Lib.current, framebuffer );

            hxd.System.setLoop( update );
        }

        engine.init();
        var stage = Lib.current.stage;
        stage.scaleMode = StageScaleMode.NO_SCALE;
        stage.align = StageAlign.TOP_LEFT;
        // entry point
#if debug
        stage.addChild( new TheMiner() );
#end
    }
}
