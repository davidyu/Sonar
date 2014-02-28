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
    static var spr : h2d.Sprite;

    static function update()
    {
        engine.render( scene );
    }

    static function main()
    {
        engine = new h3d.Engine();
        scene = new h2d.Scene();

        engine.onReady = function() {
            spr = new h2d.Sprite( scene );
            spr.x = 0;
            spr.y = 0;

            trace( "Starting up God" );
            var g = new God( Lib.current, spr );

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
