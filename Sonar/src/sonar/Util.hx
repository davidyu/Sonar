package sonar;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import sonar.components.PosCmp;
import haxe.ds.GenericStack;
import haxe.ds.StringMap;
import gml.vector.Vec2f;

using Lambda;

enum Coordinates {
    ScreenCoordinates   ( p : Vec2f, camera : Entity );
    WorldCoordinates    ( p : Vec2f );
    SectorCoordinates   ( p : Vec2f, sector : Entity );
}

@:access(hscript)
class Util
{
    public static function init( g : God ) {
        god = g;
        posMapper = god.world.getMapper( PosCmp );
    }
    
    // remember that the camera also has a sector (DUH - DOY)
    public static function toScreen( coords : Coordinates, camera : Entity ) : Vec2f {
        switch ( coords ) {
            case ScreenCoordinates( p, camera_ ): // translates from camera_ to camera
                var world = p + posMapper.get( camera_ ).pos;
                return world - posMapper.get( camera ).pos;
            case WorldCoordinates( p ):
                return p - posMapper.get( camera ).pos;
            case SectorCoordinates( p, sector ):
                var world = p + posMapper.get( sector ).pos;
                return world - posMapper.get( camera ).pos;
        }
    }

    public static function toWorld( coords : Coordinates ) : Vec2f {
        switch ( coords ) {
            case ScreenCoordinates( p, camera ):
                return p + posMapper.get( camera ).pos;
            case WorldCoordinates( p ):
                return p;
            case SectorCoordinates( p, sector ):
                return p +  posMapper.get( sector ).pos;
        }
    }

    public static function toSector( coords : Coordinates, sector : Entity ) : Vec2f {
        switch ( coords ) {
            case ScreenCoordinates( p, camera ):
                var world = p + posMapper.get( camera ).pos;
                return world - posMapper.get( sector ).pos;
            case WorldCoordinates( p ):
                return p - posMapper.get( sector ).pos;
            case SectorCoordinates( p, localSector ):
                var world = p +  posMapper.get( localSector ).pos;
                return world - posMapper.get( sector ).pos;
        }
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
    
    
    static var god : God;
    static var posMapper : ComponentMapper<PosCmp>;
    
}
