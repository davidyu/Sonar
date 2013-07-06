package ;
import engine.gibbs.Component;
import engine.gibbs.Entity;

class Ent implements Entity
{

    public function new() {
        components = new List();
    }
    
    public function attachComponent( component : Component, name : String ) : Void {
        components.add( component );
    }
    
    public function detachComponent( name : String ) : Component {
        return null;
    }
    
    public function getComponent<T>() : T {
        return null;
    }
    
    public function updateComponents() : Void {
        
    }
    
    var components : Map<String, Component>;
    
}