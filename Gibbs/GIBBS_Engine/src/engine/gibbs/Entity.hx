package engine.gibbs;

interface Entity 
{
    function attachCmp( component : Component ) : Void;
    function detachCmp<T>( type : Class<T> ) : T;
	function detachAll(): Void;
    function getCmp<T>( type : Class<T> ) : T;
	
    //function HandleMessage( message : Message ) : Void;
}