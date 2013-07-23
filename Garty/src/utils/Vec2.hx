package utils;

class Vec2
{
    //public static function normalized( v : Vec2 ) {
        //return v.scale(
    //}
    public function new( x : Float=0, y : Float=0 ) : Void {
        this.x = x;
        this.y = y;
    }

    public inline function add( rhs : Vec2 ) : Vec2 {
        return new Vec2( x + rhs.x, y + rhs.y );
    }

    public inline function sub( rhs : Vec2 ) : Vec2 { 
        return new Vec2( x - rhs.x, y - rhs.y );
    }

    public inline function scale( factor : Float ) : Vec2 {
        return new Vec2( x * factor, y * factor );
    }

    public inline function normalize() : Vec2 {
        return this.scale( length() );
    }

    public inline function length() : Float {
        return Math.sqrt( lengthsq() ); 
    }

    public inline function lengthsq() : Float {
        return x * x + y * y; 
    }
    
    public inline function dot( v : Vec2 ) : Float {
        return x * v.x + y * v.y;
    }
    
    public inline function cross ( v : Vec2 ) : Float {
        return x * v.y - y * v.x;  
    }
    
    public inline function toString() : String {
        return "x: " + x + " y: " + y;
    }
    
    public inline static function getVecArray( arr : Array<Float> ) : Array<Vec2> {
        var i = 0;
        var ret : Array<Vec2> = new Array();
        
        if ( arr.length % 2 != 0 ) {
            throw "Odd number of elements";
        }
        
        while ( i < arr.length ) {
            ret.push( new Vec2( arr[i], arr[i + 1] ) );
            i += 2;
        }
        
        return ret;
    }

    @:isVar public var x : Float;
    @:isVar public var y : Float;


}