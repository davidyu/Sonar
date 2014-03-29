package gibber.managers;
import com.artemisx.Manager;
import gibber.gabby.SynTag;
import haxe.ds.StringMap;
import haxe.ds.StringMap;

using Lambda;

class WordsMgr extends Manager
{

    public function new() {
        allSyns = new List();
        synsToTags = new StringMap();
    }
    
    public function register( synTag : SynTag ) : Void {
        if ( !allSyns.exists( function( v ) { return synTag.nameId == v.nameId; } ) ) {
            // Add syntag to registry
            allSyns.add( synTag );
            
            // Create records to lookup tag thru synonyms
            for ( s in synTag.synonyms ) {
                var tags = synsToTags.get( s );
                if ( tags == null ) {
                    tags = new Array<SynTag>();
                    synsToTags.set( s, tags );
                }
                if ( !tags.exists( function( v ) { return synTag.nameId == v.nameId; } ) ) {
                    tags.push( synTag );
                }
            }
        } else {
            trace( synTag.nameId + " already exists" );
            throw "Attempted to register syntag that already exists.";
        }
    }
    
    public function unregister( synTag : SynTag ) : Void {
        //TODO
    }
    
    public function getSynTags( synonym : String ) : Array<SynTag> {
        return synsToTags.get( synonym );
    }
    
    var allSyns : List<SynTag>;
    var synsToTags : StringMap<Array<SynTag>>;
    
}
