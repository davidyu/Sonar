package gibber.components;
import com.artemisx.Component;
import com.artemisx.Entity;
import gibber.scripts.TransitScript;
import gibber.scripts.VoidExecuteScript;

class PortalCmp implements Component
{

    public function new( s1 : Entity, s2 : Entity,  transitScript : TransitScript = null ) {
		this.s1 = s1;
		this.s2 = s2;
        this.transitScript = transitScript;
    }
	
	// Returns s2 given s1, or s1 given s2
	public function getDestSector( s : Entity ) : Entity {
		if ( s == s1 ) { 
			return s2;
		} else if ( s == s2 ) {
			return s1;
		}
		throw "Invalid portal source";
	}
    
	var s1 : Entity;
	var s2 : Entity;
    var transitScript : TransitScript;
}