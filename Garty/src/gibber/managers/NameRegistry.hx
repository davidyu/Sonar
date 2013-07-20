package gibber.systems;
import com.artemisx.Aspect;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import com.artemisx.EntitySystem;
import com.artemisx.managers.TagManager;
import gibber.components.NameIdCmp;
import haxe.ds.StringMap;
import haxe.ds.StringMap;

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