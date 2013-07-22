package gibber.managers;
import com.artemisx.Aspect;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import com.artemisx.EntitySystem;
import com.artemisx.managers.TagManager;
import gibber.components.CharCmp;
import gibber.components.EContainerCmp;
import gibber.components.NameIdCmp;
import gibber.components.PortalCmp;
import gibber.components.PosCmp;
import gibber.components.RegionCmp;
import gibber.components.TakeCmp;
import gibber.components.UsageCmp;
import haxe.ds.StringMap;
import haxe.ds.StringMap;

enum EType {
	CHAR;
	ITEM;
	OBJ;
	PORTAL;
	SECTOR;
}

// Name registry class used to cataloguing game entities.
// Invariant is the essential entity component signature
// e.g. a portal is defined as an entity with certain components that are expectet not to change
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
            register( nameCmp.name, e );
        }
    }

    var nameMapper : ComponentMapper<NameIdCmp>;
}