package engine.gibber.components;

import engine.gibbs.Component;
import engine.gibbs.Entity;

class LookCmp implements Component
{

	public function new() {
		
	}
	
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
	
	@:isVar public var entity : Entity;
	@:isVar public var Look( default, default ) : String;
	
}