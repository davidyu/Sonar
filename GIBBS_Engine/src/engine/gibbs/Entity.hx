package engine.gibbs;

interface Entity
{
    function attachComponent( component : Component, name : String ) : Void;
    function detachComponent( name : String ) : Component;
    function getComponent<T>() : T;
    function updateComponents() : Void;
    //function HandleMessage( message : Message ) : Void;
}