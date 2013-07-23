package gibber.components;
import com.artemisx.Component;
import com.artemisx.Entity;
import utils.Vec2;

class PosCmp implements Component
{
    @:isVar public var sector : Entity;
    @:isVar public var pos :  Vec2;
    @:isVar public var dp :  Vec2;

    public function new( sec : Entity, pos : Vec2 ) {
        this.sector = sec;
        this.pos = pos;
        this.dp = new Vec2();
    }
}