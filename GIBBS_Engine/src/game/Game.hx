package ;

import engine.gibber.components.LookCmp;
import engine.gibber.components.PositionCmp;
import engine.gibber.components.TransitCmp;
import engine.gibber.entities.Sector;
import engine.gibbs.Component;
import engine.gibbs.components.RenderCmp;
import engine.gibbs.Entity;
import engine.gibbs.subsystems.TickSys;
import engine.gibber.EntityBuilder;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.Lib;

class Game 
{
	
	static function main() 
	{	
		var s1 = EntityBuilder.buildSector();
		var s2 = EntityBuilder.buildSector();
		var t = new TransitCmp( s1, s2 );
		s1.attachComponent( t );
		
		var p = EntityBuilder.buildPlayer();
		var pos : PositionCmp = p.getComponent( PositionCmp );
		pos.currentSector = s1;
		
		trace ("The player is in sector with this description: " + pos.currentSector.getComponent( LookCmp ).Look );
		
		trace("Entering door...");
		pos.currentSector.getComponent( TransitCmp ).goToSector( p, pos.currentSector );
		
		trace ("The player is in sector with this description: " + pos.currentSector.getComponent( LookCmp ).Look );
		
		
		//var v = new Vec2( 1, 2 );
		//var v2 = new Vec2( 2, 3 );
		//
		//trace();
		
	}
	
}