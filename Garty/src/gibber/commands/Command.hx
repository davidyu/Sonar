package gibber.commands;

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
    function Execute() : Void;
    function onFinished() : Void;
}