package engine.gibber.components;

import engine.gibber.entities.Portal;
import engine.gibber.entities.Sector;
import engine.gibbs.Component;
import engine.gibbs.components.TickCmp;
import engine.gibbs.Entity;
import engine.gibbs.subsystems.TickSys;
import utils.Vec2;

class PositionCmp implements TickCmp
{

	public function new() {
		pos = new Vec2();
	}
	
	public function setDestination( dest : Vec2 ) : Void {
		destPos = dest;
	}
	
	public function enterPortal( portal : Portal ) : Void {
		portal.getCmp( TransitCmp ).goToSector( entity, currentSector );
	}
	
	public function update( deltaSeconds : Float ) : Void {
		var dt = 3.0;
		var delta =  pos.sub( destPos );
		// Assuming no collision
		if ( delta.lengthsq() > 1.0 ) {
				delta = delta.normalize().scale( dt );
		}
	}
	
	/* INTERFACE engine.gibbs.Component */
	
	public function initialize() : Void {
		
	}
	
	public function shutdown() : Void {
		
	}
	
	public function onAttach( e : Entity ) : Void {
		entity = e;
	}
	
	public function onDetach( e : Entity ) : Void {
		entity = null;
	}
	
	@:isVar public var entity( default, null ) : Entity;
	@:isVar public var pos( default, null ) : Vec2;
	@:isVar public var destPos( default, null ) : Vec2;
	@:isVar public var currentSector( default, default ) : Sector;
	
}