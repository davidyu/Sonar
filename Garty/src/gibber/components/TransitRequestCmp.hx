package gibber.components;
import com.artemisx.Component;
import com.artemisx.Entity;
import gibber.scripts.TransitScript;

class TransitRequestCmp implements Component
{

    public function new( mover : Entity, srcSector : Entity, destSector : Entity, 
                         transit : TransitScript=null ) {
        this.mover = mover;
        this.srcSector = srcSector;
        this.destSector = destSector;
        
        this.transitScript = transit;
    }
    
    @:isVar var mover( default, null ) : Entity;
    @:isVar var srcSector( default, null ) : Entity;
    @:isVar var destSector( default, null ) : Entity;
    
    var transitScript : TransitScript;
    
}