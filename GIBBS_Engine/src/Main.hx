package ;

import engine.gibbs.Component;
import engine.gibbs.components.RenderCmp;
import engine.gibbs.Entity;
import engine.gibbs.subsystems.TickSys;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.Lib;

class Main 
{
	
	static function main() 
	{
		var stage = Lib.current.stage;
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		// entry point
        var cmp : Component = new Cmp1( 1 ) ;
        
        var ent : Entity = new Ent();
        ent.attachCmp( cmp );
        var i : Int = ent.getCmp( Cmp1 ).num;
		
		var sys = new TickSys();
		var v  = new RenderCmp( sys );
        
        trace( i );
	}
	
}