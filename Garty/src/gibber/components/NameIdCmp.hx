package gibber.components;
import com.artemisx.Component;
import com.artemisx.Entity;

@:rtti
class NameIdCmp implements Component
{
    @:isVar public var name ( default, default ) : String;
    
    public function new( name : String ) {
        this.name = name;
    }
    
    
}
