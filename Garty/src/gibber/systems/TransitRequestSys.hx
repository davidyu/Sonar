package gibber.systems;
import com.artemisx.Aspect;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import com.artemisx.EntitySystem;
import gibber.components.TransitRequestCmp;

// All transits are queued as requests then handled batch.
class TransitRequestSys extends EntitySystem
{

    public function new() {
        super( Aspect.getAspectForOne( [TransitRequestCmp] ) );
    }
    
    override public function initialize() : Void {
        transitMapper = world.getMapper( TransitRequestCmp );
    }
    
    override public function process() : Void {
        var request : TransitRequestCmp;
        
        for ( tr in actives ) {
            request = transitMapper.get( tr );
            transit( request.mover, request.srcSector, request.destSector );
            
        }
        
    }
    
    private function onEnter( mover : Entity, srcSector : Entity, destSector : Entity ) : Void {
        
    }
    
    private function onExit( mover : Entity, srcSector : Entity, destSector : Entity ) : Void {
        
    }
    
    // Starts transition to another sector. Returns true if transitioned
    private function transit( mover : Entity, srcSector : Entity, destSector : Entity ) : Bool {
        onExit( mover, srcSector, destSector );
        
        if ( transitScript == null || transitScript.execute()[0] == true ) {
            onEnter( mover, srcSector, destSector );
            return true;
        }
        
        return false;
    }

    var transitMapper : ComponentMapper<TransitRequestCmp>;
    
}