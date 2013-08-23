package gibber.gabby;
import com.artemisx.Component;

using Lambda;
@:rtti
class SynTag implements Component
{
    @:isVar public var entityNameId : String; // The unique in game "word" all synonyms refer to
    @:isVar public var synonyms : Array<String>;
    
    public function new(  entityNameId : String, synonyms : Array<String> ) {
        this.entityNameId = entityNameId;
        this.synonyms = synonyms;
    }
    
    public function isMatch( word : String ) : Bool {
        return synonyms.exists( function( a ) { return word == a; } );
    }
}