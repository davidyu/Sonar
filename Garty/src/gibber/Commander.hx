package gibber;
import com.artemisx.Entity;
import com.artemisx.World;
import gibber.components.LookCmp;
import gibber.systems.NameRegistry;

class Commander
{

    public function new( g : God ) {
        god = g;
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