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
	
	@:isVar public var x : Float;
	@:isVar public var y : Float;
	
	
}