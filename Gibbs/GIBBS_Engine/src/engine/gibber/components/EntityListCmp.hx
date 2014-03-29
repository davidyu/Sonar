package engine.gibber.components;

import engine.gibbs.Component;
import engine.gibbs.Entity;
import haxe.xml.Fast;
/*
 * By using parameterized, we avoid creating multiple ListCmps (e.g. ItemList, DoodadList)
 * By using generic, we bypass the one-component-type restriction
 */

@:generic class EntityListCmp<T> implements Component
{ 
	public function hello() {
		trace ( Type.getClassName( Type.getClass( this ) ) );
	}
	public function new() {
		list = new List();
	}
	
	public function getHead() : T {
		return list.first();
	}
	
	public function add( item : T ) : Void {
		list.add( item );
	}
	
	public function remove( item : T ) : Void {
		list.remove( item );
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
	
	public var entity : Entity;
	
	private var list : List<T>;
}