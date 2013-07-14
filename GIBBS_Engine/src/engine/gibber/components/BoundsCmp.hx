package engine.gibber.components;
import utils.Vec2;

/**
 * Component that defines a bounding area (for sector mostly)
 * 
 */
interface BoundsCmp
{
	function isWithin( pos : Vec2 ) : Bool;
}