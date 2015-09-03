package sonar.components;
import com.artemisx.Component;
import com.artemisx.Entity;
import sonar.scripts.TransitScript;

class TransitRequestCmp implements Component
{

    public function new( mover : Entity, destSector : Entity, transit : TransitScript=null ) {
        this.mover = mover;
        this.destSector = destSector;
        
        this.transitScript = transit;
    }
    
    @:isVar public var mover( default, null ) : Entity;
    @:isVar public var destSector( default, null ) : Entity;
    
    @:isVar public var transitScript( default, null ) : TransitScript;

    // TODO
    var progressState : Int;
    
}
