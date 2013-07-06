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
    
	public function onAdded( e : Entity ) : Void {
		
	}
	public function onRemoved( e : Entity ) : Void {
		
	}
    public function shutdown() : Void {
        
    }
    
    public var num : Int;
    
}