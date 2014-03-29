package engine.gibber.entities;
import engine.gibbs.Component;
import engine.gibbs.Entity;
import haxe.ds.ObjectMap;

class GibbsEntity implements Entity
{
	public function new() {
        components = new Map(); 
    }
    
    public function attachCmp( component : Component ) : Void {
		#if debug
			var type = Type.getClass( component );
			if ( components.exists( Type.getClassName( type ) ) ) {
				throw "Component of this type " + Type.getClassName( type ) + " already exists.";
			}
		#end
		component.onAttach( this );
        components[Type.getClassName( Type.getClass ( component ) )] = component;
		
    }
    
    public function detachCmp<T>( type : Class<T> ) : T {
		var name = Type.getClassName( type );
		var component = components.get( name );
			
		#if debug
			if ( component != null ) {
				throw "Component of this type " + name + " does not exist.";
			}
		#end
		component.onDetach( this );
		components.remove( name );
		
		return cast component;
		
    }
	
	public function detachAll(): Void {
		var component;
		
		for ( c in components.keys() ) {
			component = components[c];
			component.onDetach( this );
			components.remove( c );
		}
	}
    
    public function getCmp<T>( type : Class<T> ) : T {
        return cast components[Type.getClassName( type )];
    }
    
    var components : Map<String, Component>;
	
}