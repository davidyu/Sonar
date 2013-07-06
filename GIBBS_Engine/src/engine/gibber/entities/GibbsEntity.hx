package engine.gibber.entities;
import engine.gibbs.Component;
import engine.gibbs.Entity;

/**
 * ...
 * @author ...
 */
class GibbsEntity implements Entity
{
	
	public function new() {
        components = new Map();
    }
    
    public function attachComponent( component : Dynamic ) : Void {
		#if debug
			var type = Type.getClass( component );
			if ( components.exists( Type.getClassName( type ) ) ) {
				throw "Component of this type " + Type.getClassName( type ) + " already exists.";
			}
		#end
        components.set( Type.getClassName( Type.getClass ( component ) ), component );
    }
    
    public function detachComponent<T>( type : Class<T> ) : Void {
		var exists : Bool = components.remove( Type.getClassName( type ) );
		#if debug
			if ( !exists ) {
				throw "Component of this type " + Type.getClassName( type ) + " does not exist.";
			}
		#end
    }
    
    public function getComponent<T>( type : Class<T> ) : T {
        return cast components.get( Type.getClassName( type ) );
    }
    
    var components : Map<String, Component>;
	
}