package gibber.components;
import com.artemisx.Component;
import com.artemisx.Entity;
import haxe.ds.GenericStack;
import utils.Vec2;

using gibber.Util;

class PosCmp implements Component
{
    @:isVar public var regionStack : GenericStack<Entity>;
    public var sector( get_sector, null ) : Entity;
    @:isVar public var pos :  Vec2;
    @:isVar public var dp :  Vec2;

    public function new( sec : Entity, pos : Vec2 ) {
        this.regionStack = new GenericStack<Entity>();
        this.regionStack.add( sec );
        
        this.pos = pos;
        this.dp = new Vec2();
    }
    
    function get_sector() : Entity {
        return regionStack.base();
    }
    
}