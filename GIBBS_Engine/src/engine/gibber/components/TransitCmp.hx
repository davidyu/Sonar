package engine.gibber.components;
import engine.gibber.entities.Sector;
import engine.gibber.scripts.Script;
import engine.gibbs.Component;
import engine.gibbs.Entity;

class TransitCmp implements Component
{

	public function new( s1 : Sector=null, s2 : Sector=null) {
		setSectors( s1, s2 );
	}
	
	public function setSectors( s1 : Sector, s2 : Sector ) : Void {
		sector1 = s1;
		sector2 = s2;
	}
	
	public function getDestSector( from : Sector ) : Sector {
		if ( from == sector1 ) {
			return sector2;
		} else if ( from == sector2 ) {
			return sector1;
		}
		
		throw "Not a valid from sector";
	}
	
	public function goToSector( e : Entity, from : Sector ) : Void {
		onEnterTransit( e );
		// If the entity is allowed to pass, execute onLeave
		if ( enterScript == null || enterScript.execute() ) {
			e.getCmp( PositionCmp ).currentSector = getDestSector( from );
			onLeaveTransit( e );
		}
		
	}
	
	public function initialize() : Void {
		
	}
	
	public function shutdown() : Void {
		
	}
	
	public function onAttach( e : Entity ) : Void {
		entity = e;
	}
	
	public function onDetach( e : Entity ) : Void {
		entity = null;
	}
	
	public var entity : Entity;
	
	
	
	private function onEnterTransit( e : Entity ) : Void {
		
	}
	
	private function onLeaveTransit( e : Entity ) : Void {
		
	}
	
	var sector1 : Sector;
	var sector2 : Sector;
	var enterScript : Script;
	
}