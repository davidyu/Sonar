package gibber.gabby;
import com.artemisx.Entity;
import gibber.components.PosCmp;
import gibber.scripts.TransitScript;

class PortalEdge
{
    @:isVar public var pSrc : Entity;
    @:isVar public var pDest : Entity;
    @:isVar public var transitScript : TransitScript;
    
    public function new( sourcePortal : Entity, destPortal : Entity, transitScript : TransitScript ) {
        this.pSrc = sourcePortal;
        this.pDest = destPortal;
        this.transitScript = transitScript;
    }
    
    public function getSrcSector() : Entity {
        return pSrc.getComponent( PosCmp ).sector;
    }
    
    public function getDestSector() : Entity {
        return pDest.getComponent( PosCmp ).sector;
    }
}
