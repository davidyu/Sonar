package gibber.components;
import com.artemisx.Component;

class NameIdCmp implements Component
{

    public function new( n : String ) {
        name = n;
    }
    
    @:isVar public var name ( default, default ) : String;
    
}