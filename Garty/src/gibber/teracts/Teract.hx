package gibber.teracts;
import com.artemisx.Entity;
import gibber.gabby.SynTag;
import gibber.scripts.Script;
import haxe.ds.StringMap;

enum TMatch
{
    MATCH;
    NOMATCH;
}

typedef MatchInfo =
{
    var msg : String;
    var match : TMatch;
}

interface Teract
{   
    var syns : SynTag;
    var e : Entity;
    
    // Array of dynamic/string params seems like bad practice to me...maybe 
    function matchParams( invoker : Entity, nounEntities : Array<Entity>, input : Array<SynTag> ) : MatchInfo;
    function executeEffect( invoker : Entity, invokees : Array<Entity>, params : StringMap<Dynamic> ) : gibber.scripts.Script.ScriptRunInfo;
}