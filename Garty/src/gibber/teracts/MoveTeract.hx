package gibber.teracts;
import com.artemisx.Aspect;
import com.artemisx.Entity;
import gibber.components.NameIdCmp;
import gibber.components.RegionCmp;
import gibber.gabby.SynTag;
import gibber.God;
import gibber.scripts.GenericScript;
import gibber.scripts.Script;
import haxe.ds.StringMap;
import haxe.ds.StringMap;
import utils.Words;

@:rtti
class MoveTeract implements Teract
{
    @:isVar public var syns : SynTag;
    @:isVar public var e : Entity;
    
    public function new( god : God, syns : SynTag ) {

        if ( syns == null ) {
        } else {
            this.syns = syns;
        }
        this.god = god;
    }

    /* INTERFACE gibber.gabby.Teract */
    public function matchParams( invoker : Entity, nounEntities : Array<Entity> ) : Teract.MatchInfo {
        if ( nounEntities == null || nounEntities.length != 1 ) {
            return { msg : null, match : Teract.TMatch.NOMATCH };
        }

        if ( nounEntities[0].getComponent( RegionCmp ) != null ) {
            return { msg: null, match : Teract.TMatch.MATCH };
        } else {
            return { msg : null, match : Teract.TMatch.NOMATCH };
        }
    }

    public function executeEffect( invoker : Entity, invokees : Array<Entity>, params : StringMap<Dynamic> ) : gibber.scripts.Script.ScriptRunInfo {
        if ( walkScript == null ) {
            god.commander.goToSector( invoker, invokees[0] );
            var invokeeName = invokees[0].getComponent( NameIdCmp ).name;
            return { output : 'moving to $invokeeName', res : gibber.scripts.Script.ExeRes.PASS };
        } else {
            var outs : StringMap<Dynamic> = new StringMap();

            if ( params == null ) {
                params = new StringMap();
            }
            params.set( "invoker", invoker );

            params.set( "invokees", invokees );
            return walkScript.execute( params, outs );
        }
    }

    var god : God;
    var walkScript : GenericScript;
}
