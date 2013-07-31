package ;

import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.Lib;
import gibber.components.TransitRequestCmp;
import gibber.God;
import gibber.scripts.GenericScript;
import haxe.ds.GenericStack;

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
        


    }

}