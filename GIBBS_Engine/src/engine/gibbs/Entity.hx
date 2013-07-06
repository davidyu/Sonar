package engine.gibbs;

interface Entity 
{
    function attachComponent( component : Component ) : Void;
    function detachComponent<T>( type : Class<T> ) : Void;
    function getComponent<T>( type : Class<T> ) : T;
    //function HandleMessage( message : Message ) : Void;
}