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
			var type : EType;
			
			// Determine entity type from its component signature
			// May want to factor this into a separate method
			if ( Aspect.matches( Aspect.getAspectForAll( [ PosCmp, CharCmp ] ), e.componentBits ) ) {
				type = EType.CHAR;
			} else if ( Aspect.matches( Aspect.getAspectForAll( [UsageCmp, TakeCmp] ), e.componentBits ) ) {
				type = EType.ITEM;
			} else if ( Aspect.matches( Aspect.getAspectForAll( [UsageCmp] ).exclude( [TakeCmp] ), e.componentBits ) ) {
				type = EType.OBJ;
			} else if ( Aspect.matches( Aspect.getAspectForAll( [PortalCmp] ), e.componentBits ) ) {
				type = EType.PORTAL;
			} else if ( Aspect.matches( Aspect.getAspectForAll( [EContainerCmp, RegionCmp] ), e.componentBits ) ) {
				type = EType.SECTOR;
			} else {
				return;
			}
			
			registerEntity( type, nameCmp.name, e );
		}
		
    }
	
	public function registerEntity( type : EType, tag : String, e : Entity ) : Void {
		tag = Std.string( type ) + ":" + tag;
		super.register( tag, e );
	}
	
	public function unregisterEntityFromTag( type : EType, tag : String, e : Entity ) : Void {
		tag = Std.string( type ) + ":" + tag;
		super.unregister( tag );
	}
	
    var nameMapper : ComponentMapper<NameIdCmp>;
    
}