package engine.gibber;
import engine.gibber.components.LookCmp;
import engine.gibber.components.PositionCmp;
import engine.gibber.components.TransitCmp;
import engine.gibber.entities.Player;
import engine.gibber.entities.Sector;

class EntityBuilder
{
	public static function buildSector() : Sector {
		var s1 : Sector = new Sector();
		var look : LookCmp = new LookCmp();
		
		look.Look = "This is a random number in this sector:" + Std.random( 500 );
		s1.attachComponent( look );
		
		return s1;
	}
	
	public static function buildPlayer() : Player {
		var p = new Player();
		p.attachComponent( new PositionCmp() );
		
		return p;
	}
	
}