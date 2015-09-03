package sonar.managers;
import com.artemisx.Aspect;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import com.artemisx.EntitySystem;
import com.artemisx.managers.TagManager;
import sonar.components.CharCmp;
import sonar.components.ContainerCmp;
import sonar.components.NameIdCmp;
import sonar.components.PosCmp;
import sonar.components.RegionCmp;
import sonar.components.TakeCmp;
import sonar.components.UsageCmp;
import haxe.ds.StringMap;
import haxe.ds.StringMap;

enum EType {
    CHAR;
    ITEM;
    OBJ;
    SECTOR;
}

// Name registry class used to cataloguing game entities.
// Invariant is the essential entity component signature
class NameRegistry extends TagManager
{
    public function new() {
        super();
    }

    override public function initialize() {
        nameMapper = world.getMapper( NameIdCmp );
    }

    override public function onAdded( e : Entity ) : Void {
        var nameCmp = nameMapper.getSafe( e );
        
        if ( nameCmp != null ) {
            if ( !entitiesByTag.exists( nameCmp.name ) ) {
                register( nameCmp.name, e );
            } else {
                #if debug
                trace( "Attempted to add entity to name registry that already exists" + nameCmp.name );
                #end
            }
        }
    }

    var nameMapper : ComponentMapper<NameIdCmp>;
}
