package gibber.gabby;
import com.artemisx.Component;
import com.artemisx.Entity;
import gibber.God;
import gibber.managers.WordsMgr;

using Lambda;

enum SynType
{
    VERB;
    NOUN;       // IFF has corresponding entity
    MODIFIER;
}

@:rtti
class SynTag implements Component
{
    @:isVar public static var wordsMgr : WordsMgr;
    @:isVar public var nameId : String; // The unique in game "word" all synonyms refer to
    @:isVar public var synonyms : Array<String>;
    @:isVar public var type : SynType;
    
    public static function initialize( god : God ) : Void {
        wordsMgr = god.world.getManager( WordsMgr );
    }
    
    // Finds a syntag that matches the synonym within an entity
    public static function matchSyntag( synonym : String, entity : Entity ) : SynTag {
        var res : SynTag = null;
        return res;
    }
    
    public function new( nameId : String, synonyms : Array<String>, type : SynType ) {
        this.nameId = nameId;
        this.synonyms = synonyms;
        this.type = type;
        
        wordsMgr.register( this );
    }
    
    public function isMatch( word : String ) : Bool {
        return synonyms.exists( function( a ) { return word == a; } );
    }
    
    public function toString() : String {
        var str = "SynTag<" + type + ">(" + nameId + "): ";
        for ( s in synonyms ) {
            str += s + ", ";
        }
        if ( str.length > nameId.length + 3 ) {
            str = str.substr( 0, str.length - 2 );
        }
        return str;
    }
}
