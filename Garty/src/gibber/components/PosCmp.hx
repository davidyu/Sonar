package gibber.components;
import com.artemisx.Component;
import com.artemisx.Entity;
import utils.Vec2;

class PosCmp implements Component
{
    @:isVar public var sector : Entity;
	@:isVar var pos :  Vec2;

    public function new( sec : Entity ) {
        sector = sec;
    }
    

}