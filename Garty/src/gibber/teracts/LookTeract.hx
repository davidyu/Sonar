package gibber.teracts;
import com.artemisx.Aspect;
import com.artemisx.Entity;
import gibber.components.LookCmp;
import gibber.components.NameIdCmp;
import gibber.gabby.SynTag;
import gibber.God;
import gibber.scripts.GenericScript;
import utils.Words;

class LookTeract implements Teract
{
    @:isVar public var syns : SynTag;
    
    function new( god : God, syns : SynTag ) {
        this.syns = syns;
        this.god = god;
    }
    
    /* INTERFACE gibber.gabby.Teract */
    public function matchParams( invoker : Entity, invokees : Array<Entity>, params : Array<String> ) : { msg : String, match : Teract.TMatch } {
        var invokeeName = invokees[0].getComponent( NameIdCmp ).name;
        if ( invokees[0].getComponent( LookCmp ) != null ) {
            return { msg: null, match : Teract.TMatch.MATCH };
        } else {
            return { msg : null, match : Teract.TMatch.NOMATCH };
        }
    }
    
    public function executeEffect( invoker : Entity, invokees : Array<Entity>, params : Array<String> ) : String {
        if ( lookScript == null ) {
            return invokees[0].getComponent( LookCmp ).lookText;
        } else {
            return lookScript.execute( invoker, invokees, params ).msg;
        }
    }
    
    var god : God;
    var lookScript : GenericScript;
}