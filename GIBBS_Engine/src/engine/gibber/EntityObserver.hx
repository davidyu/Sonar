package engine.gibber;
import engine.gibbs.Component;
import engine.gibbs.Entity;

interface EntityObserver
{
	function onChanged( e : Entity, c : Component ) : Void;
	function onAdded( e : Entity ) : Void;
	function onDelete( e : Entity )
}	