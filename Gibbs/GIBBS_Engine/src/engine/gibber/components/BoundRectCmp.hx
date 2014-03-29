package engine.gibber.components;

class BoundRectCmp implements BoundsCmp
{

	public function new( x : Float=0, y : Float=0, w : Float=0, h : Float=0 ) {
		this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;
	}
	
	@:isVar public var x : Float;
	@:isVar public var y : Float;
	@:isVar public var w : Float;
	@:isVar public var h : Float;
	
}