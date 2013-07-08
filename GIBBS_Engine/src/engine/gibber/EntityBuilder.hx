package engine.gibber;
import engine.gibber.components.EntityListCmp;
import engine.gibber.components.LookCmp;
import engine.gibber.components.PositionCmp;
import engine.gibber.components.TransitCmp;
import engine.gibber.entities.Player;
import engine.gibber.entities.Portal;
import engine.gibber.entities.Sector;
import haxe.macro.Context;
import haxe.macro.Expr;

class EntityBuilder
{
	public static function buildSector() : Sector {
		var s1 : Sector = new Sector();
		var look : LookCmp = new LookCmp();
		var portals = new EntityListCmp<Portal>();
		
		look.Look = "This is a random number in this sector:" + Std.random( 500 );
		
		s1.attachCmp( look );
		s1.attachCmp( portals );
		
		return s1;
	}
	
	public static function buildPlayer() : Player {
		var p = new Player();
		p.attachCmp( new PositionCmp() );
		
		return p;
	}
	
	public static function buildPortal( s1 : Sector, s2 : Sector ) : Portal {
		var e = new Portal();
		var transit = new TransitCmp( s1, s2 );
		var look : LookCmp = new LookCmp();
		
		look.Look = "This is a door";
		
		e.attachCmp( transit );
		e.attachCmp( look );
		
		s1.getCmp( EntityListHelper.PortalEntityList ).add( e );
		s2.getCmp( EntityListHelper.PortalEntityList ).add( e );
		
		return e;
	}
	
	macro public static function test( e : Expr ) {
		return Context.makeExpr( e, Context.currentPos() );
	}
	
}
