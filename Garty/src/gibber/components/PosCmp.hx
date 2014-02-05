package gibber.components;
import com.artemisx.Component;
import com.artemisx.Entity;
import utils.Vec2;

using gibber.Util;

@:rtti
class PosCmp implements Component
{
    @:isVar public var regionsIn : List<Entity>;
    @:isVar public var sector ( default, default ) : Entity;
    @:isVar public var pos :  Vec2;
    @:isVar public var dp :  Vec2; //aka velocity
    @:isVar public var noDamping : Bool;

    public function new( sec : Entity, pos : Vec2, noDamping : Bool = false ) {
        this.regionsIn = new List<Entity>();
        this.sector = sec;

        this.noDamping = noDamping;

        this.pos = pos;
        this.dp = new Vec2();
    }

    function hxSerialize( s : haxe.Serializer ) {
        s.serialize(regionsIn);
        s.serialize(pos);
        s.serialize(dp);
    }

    function hxUnserialize( s : haxe.Unserializer ) {
        regionsIn = s.unserialize();
        pos = s.unserialize();
        dp = s.unserialize();
    }
}
