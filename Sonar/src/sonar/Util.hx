package sonar;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import sonar.components.PosCmp;
import haxe.ds.GenericStack;
import haxe.ds.StringMap;
import utils.Vec2;

using Lambda;

enum Coordinates {
    ScreenCoordinates   ( p : Vec2, camera : Entity );
    WorldCoordinates    ( p : Vec2 );
    SectorCoordinates   ( p : Vec2, sector : Entity );
}

@:access(hscript)
class Util
{
    public static function init( g : God ) {
        god = g;
        posMapper = god.world.getMapper( PosCmp );
    }
    
    // remember that the camera also has a sector (DUH - DOY)
    public static function toScreen( coords : Coordinates, camera : Entity ) : Vec2 {
        switch ( coords ) {
            case ScreenCoordinates( p, camera_ ): // translates from camera_ to camera
                var world = p.add( posMapper.get( camera_ ).pos );
                return world.sub( posMapper.get( camera ).pos );
            case WorldCoordinates( p ):
                return p.sub( posMapper.get( camera ).pos );
            case SectorCoordinates( p, sector ):
                var world = p.add( posMapper.get( sector ).pos );
                return world.sub( posMapper.get( camera ).pos );
        }
    }

    public static function toWorld( coords : Coordinates ) : Vec2 {
        switch ( coords ) {
            case ScreenCoordinates( p, camera ):
                return p.add( posMapper.get( camera ).pos );
            case WorldCoordinates( p ):
                return p;
            case SectorCoordinates( p, sector ):
                return p.add( posMapper.get( sector ).pos );
        }
    }

    public static function toSector( coords : Coordinates, sector : Entity ) : Vec2 {
        switch ( coords ) {
            case ScreenCoordinates( p, camera ):
                var world = p.add( posMapper.get( camera ).pos );
                return world.sub( posMapper.get( sector ).pos );
            case WorldCoordinates( p ):
                return p.sub( posMapper.get( sector ).pos );
            case SectorCoordinates( p, localSector ):
                var world = p.add( posMapper.get( localSector ).pos );
                return world.sub( posMapper.get( sector ).pos );
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
