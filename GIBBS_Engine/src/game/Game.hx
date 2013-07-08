package game;

import engine.gibber.components.EntityListCmp;
import engine.gibber.components.EntityListCmp;
import engine.gibber.components.LookCmp;
import engine.gibber.components.PositionCmp;
import engine.gibber.components.TransitCmp;
import engine.gibber.entities.Player;
import engine.gibber.entities.Portal;
import engine.gibber.entities.Sector;
import engine.gibber.StinkyMisc;
import engine.gibbs.Component;
import engine.gibbs.components.RenderCmp;
import engine.gibbs.Entity;
import engine.gibbs.subsystems.TickSys;
import engine.gibber.EntityBuilder;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.Lib;


//typedef Test = haxe.macro.Type.ClassType<engine.gibber.components.EntityListCmp_engine_gibber_entities_Portal, {}>;
//typedef Fields = haxe.macro.MacroType<[my.Macro.getFields("file.txt")]>;
class Game 
{
	static function main() 
	{	
		var s1 = EntityBuilder.buildSector();
		var s2 = EntityBuilder.buildSector();

		var portal = EntityBuilder.buildPortal( s1, s2 );
		
		var p = EntityBuilder.buildPlayer();
		var pos : PositionCmp = p.getCmp( PositionCmp );
		pos.currentSector = s1;

		trace ("The player is in sector with this description: " + pos.currentSector.getCmp( LookCmp ).Look );
		
		trace("Entering door...");
		var somePortal = pos.currentSector.getCmp( StinkyMisc.EntityListPortalClass ).getHead();
		pos.enterPortal( somePortal );
		
		trace ("The player is in sector with this description: " + pos.currentSector.getCmp( LookCmp ).Look );
		
	}
	
}