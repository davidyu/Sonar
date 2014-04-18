package gibber;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import gibber.components.PosCmp;
import haxe.ds.GenericStack;
import haxe.ds.StringMap;
import hscript.Interp;
import utils.Vec2;

using Lambda;

enum Coordinates {
    ScreenCoordinates   ( p : Vec2 );
    WorldCoordinates    ( p : Vec2 );
    SectorCoordinates   ( p : Vec2 );
}

@:access(hscript)
class Util
{
    public static function init( g : God ) {
        god = g;
        posMapper = god.world.getMapper( PosCmp );
    }
    
    public static function worldCoords( pos : Vec2, sector : Entity ) : Vec2 {
        return pos.add( posMapper.get( sector ).pos );
    }

    // if @sector is passed into screenCoords, we'll do a conversion into world space before
    // turning it into screen space
    public static function screenCoords( pos : Vec2, camera : Entity, ?sector : Entity ) : Vec2 {
        var p = pos.sub( posMapper.get( camera ).pos );
        if ( sector != null && sector != posMapper.get( camera ).sector ) {
            p = worldCoords( p, sector );
        }
        return p;
    }

    // reverses screenCoords
    public static function screenToWorld( pos : Vec2, camera : Entity ) : Vec2 {
        var p = pos.add( posMapper.get( camera ).pos );
        return p;
    }
    
    public static function sectorCoords( pos : Vec2, ref : Entity, tar : Entity, ?camera : Entity ) : Vec2 {
        return localCoords( worldCoords( pos, ref ), tar );
    }
    
    public static function localCoords( pos : Vec2, local : Entity ) : Vec2 {
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
    
    public static function mapCopy<V>( m : StringMap<V> ) : StringMap<V> {
        var res = new StringMap<V>();
        for ( key in res.keys() ) {
            res.set( key, res.get( key ) );
        }
        
        return res;
    }
    
    
    public static function interpCopy( i : Interp ) : Interp {
        var res = new Interp();
        res.variables = mapCopy( i.variables );
        res.locals = mapCopy( i.locals );
        res.binops = mapCopy( i.binops );
        res.declared = i.declared.copy();
        return res;
    }
    
    static var god : God;
    static var posMapper : ComponentMapper<PosCmp>;
    
}
