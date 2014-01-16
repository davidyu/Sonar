package ;

import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.Lib;
import gibber.God;

#if debug
import com.sociodox.theminer.TheMiner;
#end

using gibber.Util;

class Main 
{
    static function main()
    {
        var stage = Lib.current.stage;
        stage.scaleMode = StageScaleMode.NO_SCALE;
        stage.align = StageAlign.TOP_LEFT;
        // entry point
        trace( "Starting up God" );
        var g = new God( Lib.current );
#if debug
        stage.addChild( new TheMiner() );
#end
    }
}
