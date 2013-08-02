package gibber;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import gibber.components.PosCmp;
import haxe.ds.GenericStack;
import utils.Vec2;

class Util
{
    public static function init( g : God ) {
        god = g;
        posMapper = god.world.getMapper( PosCmp );
    }
    
    public static function worldCoords( pos : Vec2, sector : Entity ) : Vec2 {
        return pos.add( posMapper.get( sector ).pos );
    }
    
    public static function sectorCoords( pos : Vec2, oldSector : Entity, newSector : Entity ) : Vec2 {
        return localCoords( worldCoords( pos, oldSector ), newSector );
    }
    
    public static function localCoords( pos : Vec2, local : Entity ) : Vec2 {
        var p = posMapper.get( local );
        return pos.sub( posMapper.get( local ).pos );
    }
    
    public static function peek( s : GenericStack<Entity> ) : Entity {
        return s.head.elt;
    }
    
    public static function base( s : GenericStack<Entity> ) : Entity {
        var st = s.head;
        var ret = null;
        
        while ( st != null ) {
            ret = st.elt;
            st = st.next;
        }
        return ret;
    }
    
    public static function clear( s : List<Entity> ) : Void {
        while ( !s.isEmpty() ) {
            s.pop();
        }
    }
    
    static var god : God;
    static var posMapper : ComponentMapper<PosCmp>;
    
}