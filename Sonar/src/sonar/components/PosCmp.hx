package sonar.components;
import com.artemisx.Component;
import com.artemisx.Entity;
import gml.vector.Vec2f;

using sonar.Util;

@:rtti
class PosCmp implements Component
{
    @:isVar public var regionsIn : List<Entity>;
    @:isVar public var sector : Entity;
    @:isVar public var pos :  Vec2f;
    @:isVar public var dp :  Vec2f; //aka velocity
    @:isVar public var noDamping : Bool;

    public function new( sec : Entity, pos : Vec2f, noDamping : Bool = false ) {
        this.regionsIn = new List<Entity>();
        this.sector = sec;

        this.noDamping = noDamping;

        this.pos = pos;
        this.dp = new Vec2f( 0, 0 );
    }

    function hxSerialize( s : haxe.Serializer ) {
        s.serialize( pos );
        s.serialize( dp );
    }

    function hxUnserialize( s : haxe.Unserializer ) {
        pos = s.unserialize();
        dp = s.unserialize();
    }
}
