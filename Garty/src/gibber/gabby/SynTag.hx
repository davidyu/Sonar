package gibber.gabby;
import com.artemisx.Component;

using Lambda;

class SynTag implements Component
{
    @:isVar public var name : String; // The id of the tag
    @:isVar public var entityNameId : String; // The unique in game "word" all synonyms refer to
    @:isVar public var synonyms : List<String>;
    
    public function new( name : String, entityNameId : String, synonyms : List<String> ) {
        this.name = name;
        this.synonyms = synonyms;
        this.entityNameId = entityNameId;
    }
    
    public function isMatch( word : String ) : Bool {
        return synonyms.exists( function( a ) { return word == a; } );
    }
}