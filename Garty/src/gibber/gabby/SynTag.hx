package gibber.gabby;
import com.artemisx.Component;
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
    @:isVar public var type : SynTag;
    
    public function new( nameId : String, synonyms : Array<String>, type : SynType ) {
        this.nameId = nameId;
        this.synonyms = synonyms;
        
        wordsMgr.
    }
    
    public function isMatch( word : String ) : Bool {
        return synonyms.exists( function( a ) { return word == a; } );
    }
}
