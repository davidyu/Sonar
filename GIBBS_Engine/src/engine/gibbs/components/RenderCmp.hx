package engine.gibbs.components;
import engine.gibbs.subsystems.TickSys;

class RenderCmp implements TickCmp
{
	public function new( manager : TickSys) {
		renderManager = manager;
	}
	
	public function update( deltaSeconds : Float ) : Void {
		
	}
	
	public function initialize() : Void {
        
    }
    
	public function onAttach( e : Entity ) : Void {
		
	}
	
	public function onDetach( e : Entity ) : Void {
		
	}
	
    public function shutdown() : Void {
        
    }
	
	public var entity : Entity;
	var renderManager : TickSys;
}