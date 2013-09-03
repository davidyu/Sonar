package gibber.teracts;
import com.artemisx.Aspect;
import com.artemisx.Entity;
import gibber.components.LookCmp;
import gibber.components.NameIdCmp;
import gibber.gabby.SynTag;
import gibber.God;
import gibber.scripts.GenericScript;
import gibber.scripts.Script;
import haxe.ds.StringMap;
import haxe.ds.StringMap;
import utils.Words;

class LookTeract implements Teract
{
    @:isVar public var syns : SynTag;
    @:isVar public var e : Entity;
    
    public function new( god : God, syns : SynTag ) {
        this.syns = syns;
        this.god = god;
    }
    
    /* INTERFACE gibber.gabby.Teract */
    public function matchParams( invoker : Entity, nounEntities : Array<Entity>, input : Array<SynTag> ) : Teract.MatchInfo {
        if ( nounEntities == null || nounEntities.length != 1 ) {
            return { msg : null, match : Teract.TMatch.NOMATCH };
        }
        
        var invokeeName = nounEntities[0].getComponent( NameIdCmp ).name;
        if ( nounEntities[0].getComponent( LookCmp ) != null ) {
            return { msg: null, match : Teract.TMatch.MATCH };
        } else {
            return { msg : null, match : Teract.TMatch.NOMATCH };
        }
    }
    
    public function executeEffect( invoker : Entity, invokees : Array<Entity>, params : StringMap<Dynamic> ) : gibber.scripts.Script.ScriptRunInfo {
        if ( lookScript == null ) {
            return { output : invokees[0].getComponent( LookCmp ).lookText, res : gibber.scripts.Script.ExeRes.PASS };
        } else {
            var outs : StringMap<Dynamic> = new StringMap();
            
            if ( params == null ) {
                params = new StringMap();
            }
            params.set( "invoker", invoker );
            
            params.set( "invokees", invokees );
            return lookScript.execute( params, outs );
        }
    }
    
    var god : God;
    var lookScript : GenericScript;
}