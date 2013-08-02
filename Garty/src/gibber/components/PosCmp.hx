package gibber.components;
import com.artemisx.Component;
import com.artemisx.Entity;
import haxe.ds.GenericStack;
import utils.Vec2;

using gibber.Util;

class PosCmp implements Component
{
    @:isVar public var regionsIn : List<Entity>;
    @:isVar public var sector ( default, default ) : Entity;
    @:isVar public var pos :  Vec2;
    @:isVar public var dp :  Vec2;

    public function new( sec : Entity, pos : Vec2 ) {
        this.regionsIn = new List<Entity>();
        this.sector = sec;
        
        this.pos = pos;
        this.dp = new Vec2();
    }
    
}