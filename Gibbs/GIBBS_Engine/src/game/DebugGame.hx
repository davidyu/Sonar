package game;

class DebugGame
{
	
	public function new( r ) {
		root = r;
		root.addEventListener( flash.events.Event.ENTER_FRAME, tick );
	}
	
	function tick() : Void {
		
	}
	var root		: flash.display.MovieClip;
	
}