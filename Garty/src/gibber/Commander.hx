package gibber;
import com.artemisx.Entity;
import com.artemisx.World;
import gibber.commands.Command;
import gibber.components.ContainerCmp;
import gibber.components.CmdQueue;
import gibber.components.PosCmp;
import gibber.components.LookCmp;
import gibber.components.PortalCmp;
import gibber.managers.NameRegistry;
import utils.Vec2;

using Lambda;

class Commander
{
    public function new( g : God ) {
        god = g;
    }

    public function goToPosition( mover : Entity, newLoc : Vec2 ) : Void {
        var curSector : Entity   = mover.getComponent( PosCmp ).sector;
        var moveCmd   : Command  = god.cmdFactory.createCmd( "move", [ mover, newLoc, curSector ] );
        var cq        : CmdQueue = mover.getComponent( CmdQueue );
        cq.enqueue( moveCmd );
    }

    public function goToSector( mover : Entity, destSectorName : String ) : Void {
        var destSector = god.world.getManager( NameRegistry ).getEntity( destSectorName );
        
        if ( destSector != null ) {
            god.entityBuilder.createTransitRequest( mover, destSector, null );
            god.outputTextfield.text += getSectorLook( destSector ) + "\n";
        } else {
            
        }
    }
    
    public function getSectorLook( sector : Entity ) : String {
        var look = sector.getComponent( LookCmp );
        
        return look.lookText;
    }
    
    var god : God;

}
