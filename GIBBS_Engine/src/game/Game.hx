package ;

import engine.gibber.components.LookCmp;
import engine.gibber.entities.Sector;
import engine.gibbs.Component;
import engine.gibbs.components.RenderCmp;
import engine.gibbs.Entity;
import engine.gibbs.subsystems.TickSys;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.Lib;

class Game 
{
	
	static function main() 
	{
		var s1 : Entity = new Sector();
		var look : LookCmp = new LookCmp();
		
		look.Look = "This is a place.";
		s1.attachComponent( look );
		
		trace( s1.getComponent( LookCmp ).Look );
	}
	
}