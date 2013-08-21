package gibber.components;
import com.artemisx.Component;
import com.artemisx.Entity;
import gibber.gabby.SynTag;

@:rtti
class NameIdCmp implements Component
{
    @:isVar public var tagEntityRef : Entity;
    @:isVar public var name ( default, default ) : String;
    @:isVar public var syns : SynTag;
    
    public function new( n : String ) {
        this.name = n;
    }
    
    
}
