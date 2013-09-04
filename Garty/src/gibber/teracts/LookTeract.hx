package gibber.teracts;
import com.artemisx.Aspect;
import com.artemisx.Entity;
import gibber.components.LookCmp;
import gibber.components.NameIdCmp;
import gibber.gabby.SynTag;
import gibber.God;
import gibber.scripts.GenericScript;
import haxe.ds.StringMap;
import haxe.ds.StringMap;
import utils.Words;

class LookTeract implements Teract
{
    @:isVar public var syns : SynTag;
    
    public function new( god : God, syns : SynTag ) {

        if ( syns == null ) {
            // mildly useless for now
            this.syns = new SynTag( "LookTeract", [ "observe", "examine", "look", "check out", "look at", "see" ])
        } else {
            this.syns = syns;
        }
        this.god = god;
    }
    
    /* INTERFACE gibber.gabby.Teract */
    public function matchParams( invoker : Entity, invokees : Array<Entity>, params : Array<String> ) : { msg : String, match : Teract.TMatch } {
        // hmm...this seems incomplete
        var invokeeName = invokees[0].getComponent( NameIdCmp ).name;
        if ( invokees[0].getComponent( LookCmp ) != null ) {
            return { msg: null, match : Teract.TMatch.MATCH };
        } else {
            return { msg : null, match : Teract.TMatch.NOMATCH };
        }
    }
    
    public function executeEffect( invoker : Entity, invokees : Array<Entity>, params : StringMap<Dynamic> ) : String {
        var outs : StringMap<Dynamic> = new StringMap();
        
        if ( params == null ) {
            params = new StringMap();
        }
        params.set( "invoker", invoker );
        params.set( "invokees", invokees );
        
        if ( lookScript == null ) {
            return invokees[0].getComponent( LookCmp ).lookText;
        } else {
            return lookScript.execute( params, outs );
        }
    }
    
    var god : God;
    var lookScript : GenericScript;
}
