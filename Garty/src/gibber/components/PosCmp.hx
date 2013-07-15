package gibber.components;
import com.artemisx.Component;
import com.artemisx.Entity;

class PosCmp implements Component
{

    public function new( sec : Entity ) {
        sector = sec;
    }
    
    @:isVar public var sector : Entity;

}