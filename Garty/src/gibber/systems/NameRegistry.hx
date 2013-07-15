package gibber.systems;
import com.artemisx.Aspect;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import com.artemisx.EntitySystem;
import gibber.components.NameIdCmp;
import haxe.ds.StringMap;
import haxe.ds.StringMap;

class NameRegistry extends EntitySystem
{

    public function new() {
        super( Aspect.getAspectForOne( [NameIdCmp] ) );
        nameHash = new StringMap();
    }
    
    public function getEntity( nameId : String ) : Entity {
        return nameHash.get( nameId );
    }
    
    override public function initialize() : Void {
        nameMapper = world.getMapper( NameIdCmp );
    }
    
    override public function checkProcessing() : Bool {
        return false;
    }
    
    override public function onInserted( e : Entity ) : Void {
        trace( e.listComponents() );
        nameHash.set( nameMapper.get( e ).name, e );
    }
    
    override public function onRemoved( e : Entity ) : Void {
        nameHash.remove( nameMapper.get( e ).name );
    }
    
    var nameHash : StringMap<Entity>;
    var nameMapper : ComponentMapper<NameIdCmp>;
    
}