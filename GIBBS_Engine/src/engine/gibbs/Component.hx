package engine.gibbs;

interface Component
{
    function initialize() : Void;
    function shutdown() : Void;
	
	function onAdded( e : Entity ) : Void;
	function onRemoved( e : Entity ) : Void;
    //function HandleMessage( message : Message ); Void;
}