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
    
	public function onAdded( e : Entity ) : Void {
		
	}
	
	public function onRemoved( e : Entity ) : Void {
		
	}
	
    public function shutdown() : Void {
        
    }
	
	var renderManager : TickSys;
}