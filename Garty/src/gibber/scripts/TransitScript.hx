package gibber.scripts;
import com.artemisx.Entity;
import gibber.components.PosCmp;
import gibber.components.RegionCmp;
import gibber.God;
import utils.Vec2;

using gibber.Util;

class TransitScript
{
    public function new( god : God ) {
        this.god = god;
    }
    
    public function execute( mover : Entity, pSrc : Entity, pDest : Entity ) : Array<Dynamic> {
        var playerPos = mover.getComponent( PosCmp );
        var srcSector = pSrc.getComponent( PosCmp ).sector;
        var destPosCmp = pDest.getComponent( PosCmp );
        var destSector = destPosCmp.sector;
        var srcRegion = srcSector.getComponent( RegionCmp );
        var destRegion = destSector.getComponent( RegionCmp );
        // Exit the room the player is currently in
        srcRegion.onExit( mover, destSector );
        // Enter the room the player will be in
        destRegion.onEnter( mover, playerPos.sector );
        
        playerPos.regionStack.clear();
        playerPos.regionStack.add( pDest );
        playerPos.pos = destPosCmp.pos;
        
        return ["moved to a sector", true];
    }
    
    var god : God;
}