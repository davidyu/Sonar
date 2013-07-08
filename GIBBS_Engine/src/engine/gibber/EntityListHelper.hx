package engine.gibber;
import engine.gibber.components.EntityListCmp;
import engine.gibber.entities.Portal;

// worst code ever
// D: not that bad after a bit of rebranding!
class EntityListHelper
{
	public static var PortalEntityList = Type.getClass( new EntityListCmp<Portal>() );
	
}
