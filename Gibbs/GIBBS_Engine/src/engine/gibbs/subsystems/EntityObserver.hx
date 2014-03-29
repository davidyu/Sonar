package engine.gibbs.subsystems;
import engine.gibbs.Component;
import engine.gibbs.Entity;

interface EntityObserver
{
	function onAdded( e : Entity ) : Void;
	function onDeleted( e : Entity ) : Void;
	function onAttachCmp( e : Entity, cmp : Component ) : Void;
}