package sonar.commands;

enum TCmdRes 
{
    NEW;
    PENDING;
    PASS;
    FAIL;
    CRITICAL;
}

interface Command
{
    @:isVar var state : TCmdRes;
    function onStart() : Void;
    function Execute() : Array<Dynamic>;
    function onFinished() : Void;
}
