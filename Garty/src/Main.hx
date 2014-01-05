package ;

import com.artemisx.Aspect;
import com.artemisx.utils.Bitset;
import com.artemisx.World;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.Lib;
import gibber.components.CharCmp;
import gibber.components.ContainableCmp;
import gibber.components.NameIdCmp;
import gibber.components.PosCmp;
import gibber.components.RegionCmp;
import gibber.components.RenderCmp;
import gibber.components.TakeCmp;
import gibber.components.TransitRequestCmp;
import gibber.gabby.SynTag;
import gibber.God;
import gibber.scripts.GenericScript;
import gibber.teracts.LookTeract;
import haxe.ds.GenericStack;
import haxe.Unserializer;
import utils.Words;

#if debug
import com.sociodox.theminer.TheMiner;
#end

using gibber.Util;

class Test
{
    public function new() {
        v = 10;
    }
    public var v : Int;
}

class Best
{
    public var t : Test;
    public function new() {
        t = new Test();
        t.v = 30;
    }
}

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
