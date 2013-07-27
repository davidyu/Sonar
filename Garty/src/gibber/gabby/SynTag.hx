package gabby;

using Lambda;

class SynTag
{
    @:isVar public var name : String;
    @:isVar public var items : List<String>;
    
    public function new( name : String, synonymsList : List<String> ) {
        this.name = name;
        this.items = synonymsList;
    }
    
    public function isMatch( word : String ) : Bool {
        return items.exists( word );
    }
}