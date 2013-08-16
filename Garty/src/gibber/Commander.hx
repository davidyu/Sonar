package gibber;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import com.artemisx.World;
import gibber.commands.Command;
import gibber.components.ContainerCmp;
import gibber.components.CmdQueue;
import gibber.components.PosCmp;
import gibber.components.LookCmp;
import gibber.components.PortalCmp;
import gibber.components.RegionCmp;
import gibber.managers.NameRegistry;
import gibber.managers.SectorGraphMgr;
import utils.Vec2;

using Lambda;

class Commander
{
    public function new( g : God ) {
        god = g;
        initialize();
    }
    
    public function initialize() : Void {
        posMapper    = god.world.getMapper( PosCmp );
        regionMapper = god.world.getMapper( RegionCmp );
        portalMapper = god.world.getMapper( PortalCmp );
        graphMgr     = god.world.getManager( SectorGraphMgr );
    }

    public function goToPosition( mover : Entity, newLoc : Vec2 ) : Void {
        var curSector : Entity   = mover.getComponent( PosCmp ).sector;
        var moveCmd   : Command  = god.cf.createCmd( "move", [ mover, newLoc, curSector ] );
        var cq        : CmdQueue = mover.getComponent( CmdQueue );
        cq.enqueue( moveCmd );
    }

    public function goToSector( mover : Entity, destSector : Entity ) : Void {
        var posCmp = posMapper.get( mover );

        if ( destSector != null && posCmp.sector != destSector ) {
            var portals = graphMgr.getEdges( posCmp.sector, destSector );
            var portalCmp = portalMapper.get( portals[0] );
            var dest = posMapper.get( portalCmp.edges[0].pDest ).pos;
            var cq  = mover.getComponent( CmdQueue );
            
            cq.enqueue( god.cf.createCmd( "move", [ mover, dest, destSector] ) );
        } else {
            
        }
    }
    
    public function getSectorLook( sector : Entity ) : String {
        var look = sector.getComponent( LookCmp );
        
        return look.lookText;
    }
    
    var god : God;
    var graphMgr : SectorGraphMgr;
    var posMapper : ComponentMapper<PosCmp>;
    var regionMapper : ComponentMapper<RegionCmp>;
    var portalMapper : ComponentMapper<PortalCmp>;

}
