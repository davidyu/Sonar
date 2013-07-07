package utils;

class Vec2
{

	public function new( x : Float=0, y : Float=0 ) : Void {
		this.x = x;
		this.y = y;
	}
	
	public function add( rhs : Vec2 ) : Vec2 {
		return new Vec2( x + rhs.x, y + rhs.y );
	}
	
	public function sub( rhs : Vec2 ) : Vec2 { 
		return new Vec2( x - rhs.x, y - rhs.y );
	}
	
	@:isVar public var x : Float;
	@:isVar public var y : Float;
	
	
}