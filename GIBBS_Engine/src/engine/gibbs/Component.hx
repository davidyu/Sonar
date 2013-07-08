package engine.gibbs;

interface Component
{
    function initialize() : Void;
    function shutdown() : Void;
	
	function onAttach( e : Entity ) : Void;
	function onDetach( e : Entity ) : Void;
    //function HandleMessage( message : Message ); Void;
	
	public var entity( default, null ) : Entity;
}