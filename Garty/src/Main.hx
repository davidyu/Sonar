package ;

import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.Lib;
import gibber.components.TransitRequestCmp;
import gibber.systems.TransitRequestSys;


class Main 
{

    static function main()
    {
        var stage = Lib.current.stage;
        stage.scaleMode = StageScaleMode.NO_SCALE;
        stage.align = StageAlign.TOP_LEFT;
        // entry point
        
        trace("hello");
        var t = new TransitRequestCmp(null, null, null);
        var b = new TransitRequestSys();
    }

}