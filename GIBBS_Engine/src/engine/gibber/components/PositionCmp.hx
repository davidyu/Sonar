package engine.gibber.components;

import engine.gibber.entities.Sector;
import engine.gibbs.Component;
import engine.gibbs.Entity;
import utils.Vec2;

class PositionCmp implements Component
{

	public function new() {
		pos = new Vec2();
	}
	
	/* INTERFACE engine.gibbs.Component */
	
	public function initialize() : Void {
		
	}
	
	public function shutdown() : Void {
		
	}
	
	public function onAdded( e : Entity ) : Void {
		
	}
	
	public function onRemoved( e : Entity ) : Void {
		
	}
	
	@:isVar public var pos : Vec2;
	@:isVar public var currentSector : Sector;
	
}