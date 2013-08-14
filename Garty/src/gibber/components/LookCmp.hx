package gibber.components;
import com.artemisx.Component;

@:rtti
class LookCmp implements Component
{

    public function new() {
        
    }
    
    @:isVar public var lookText ( default, default ) : String;
}
