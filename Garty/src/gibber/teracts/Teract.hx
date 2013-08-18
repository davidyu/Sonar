package gibber.teracts;
import com.artemisx.Entity;
import gibber.gabby.SynTag;

enum TMatch
{
    MATCH;
    NOMATCH;
}

interface Teract
{   
    var syns : SynTag;
    
    // Array of dynamic/string params seems like bad practice to me...maybe 
    function matchParams( invoker : Entity, invokees : Array<Entity>, params : Array<String> ) : { msg : String, match : TMatch };
    function executeEffect( invoker : Entity, invokees : Array<Entity>, params : Array<String> ) : String;
}