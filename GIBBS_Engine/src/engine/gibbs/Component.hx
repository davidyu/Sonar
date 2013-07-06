package engine.gibbs;

interface Component
{
    function initialize() : Void;
    function update(): Void;
    function shutdown() : Void;
    //function HandleMessage( message : Message ); Void;
}