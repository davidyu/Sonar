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
    
    public static inline function worldCoords( pos : Vec2, sector : Entity ) : Vec2 {
        return pos.add( posMapper.get( sector ).pos );
    }
    
    public static inline function sectorCoords( pos : Vec2, ref : Entity, tar : Entity ) : Vec2 {
        return localCoords( worldCoords( pos, ref ), tar );
    }
    
    public static inline function localCoords( pos : Vec2, local : Entity ) : Vec2 {
        var p = posMapper.get( local );
        return pos.sub( posMapper.get( local ).pos );
    }
    
    // Dunno how to do with generic...
    public static inline function realInsert<T>( a : Array<T>, i : Int, v : T ) : Void {
        while ( i >= a.length ) {
            a.push( null );
        }
        a[i] = v;
    }
    
    
    public static function clear( s : List<Entity> ) : Void {
        while ( !s.isEmpty() ) {
            s.pop();
        }
    }
    
    static var god : God;
    static var posMapper : ComponentMapper<PosCmp>;
    
}