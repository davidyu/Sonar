package gibber.components;
import com.artemisx.Component;
import com.artemisx.Entity;
import gibber.gabby.SynTag;

@:rtti
class NameIdCmp implements Component
{
    @:isVar public var name ( default, default ) : String;
    @:isVar public var syns : SynTag;
    
    public function new( name : String, syns : SynTag ) {
        this.name = name;
        this.syns = syns;
    }
    
    
}
