package gibber.gabby;
import com.artemisx.Entity;
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
}
