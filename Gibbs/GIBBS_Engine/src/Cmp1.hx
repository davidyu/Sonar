package ;
import engine.gibbs.Component;
import engine.gibbs.Entity;

class Cmp1 implements Component
{
    public function new( num : Int ) {
        this.num = num;
    }
    
    
    public function initialize() : Void {
        
    }
    
	public function onAttach( e : Entity ) : Void {
		
	}
	public function onDetach( e : Entity ) : Void {
		
	}
    public function shutdown() : Void {
        
    }
    
    public var num : Int;
    
}