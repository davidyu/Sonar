package gibber.managers;
import com.artemisx.Manager;
import gibber.gabby.SynTag;
import haxe.ds.StringMap;
import haxe.ds.StringMap;

using Lambda;

class WordsMgr extends Manager
{

    public function new() {
        super();
        allSyns = new List();
        synsToTags = new StringMap();
    }
    
    public function register( synTag : SynTag ) : Void {
        if ( !allSyns.exists( function( v ) { return synTag.nameId == v.nameId; } ) ) {
            allSyns.add( synTag );
        } else {
            throw "Attempted to register syntag that already exists.";
        }
    }
    
    public function unregister( synTag : SynTag ) : Void {
        
    }
    
    var allSyns : List<SynTag>;
    var synsToTags : StringMap<Array<SynTag>>;
    
}