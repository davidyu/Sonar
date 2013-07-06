package ;
import engine.gibbs.Component;
import engine.gibbs.Entity;
import haxe.ds.ObjectMap;

class Ent implements Entity
{

    public function new() {
        components = new Map();
    }
    
    public function attachComponent( component : Dynamic ) : Void {
		trace( Type.getClass( component ) );
        components.set( Type.getClassName( Type.getClass ( component ) ), component );
    }
    
    public function detachComponent( name : String ) : Component {
        return null;
    }
    
    public function getComponent<T>( type : Class<T> ) : T {
        return cast components.get( Type.getClassName( type ) );
    }
    
    public function updateComponents() : Void {
        
    }
    
    var components : Map<String, Component>;
    
}