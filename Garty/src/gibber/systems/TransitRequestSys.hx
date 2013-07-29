package gibber.systems;
import com.artemisx.Aspect;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import com.artemisx.EntitySystem;
import gibber.components.PosCmp;
import gibber.components.RegionCmp;
import gibber.components.TransitRequestCmp;

// All transits are queued as requests then handled batch.
class TransitRequestSys extends EntitySystem
{

    public function new() {
        super( Aspect.getAspectForOne( [TransitRequestCmp] ) );
    }
    
    override public function initialize() : Void {
        transitMapper = world.getMapper( TransitRequestCmp );
        posMapper = world.getMapper( PosCmp );
        regionMapper = world.getMapper( RegionCmp );
    }
    
    override public function process() : Void {
        var request : TransitRequestCmp;
        
        for ( i in 0...actives.size ) {
            request = transitMapper.get( actives.get( i ) );
            transit( request );
            world.deleteEntity( actives.get( i ) );
        }
    }
    
    // Starts transition to another sector. Returns true if transitioned
    private function transit( req : TransitRequestCmp ) : Bool {
        if ( req.transitScript == null || req.transitScript.execute()[0] == true ) {
            var playerPos = posMapper.get( req.mover );
            // Exit the room the player is currently in
            regionMapper.get( playerPos.sector ).onExit( req.mover, req.destSector );
            // Enter the room the player will be in
            regionMapper.get( req.destSector ).onEnter( req.mover, playerPos.sector );
            
            return true;
        }
        
        return false;
    }
    
    var posMapper : ComponentMapper<PosCmp>;
    var regionMapper : ComponentMapper<RegionCmp>;
    var transitMapper : ComponentMapper<TransitRequestCmp>;
    
    
}