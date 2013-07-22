package gibber.systems;
import com.artemisx.Aspect;
import com.artemisx.ComponentMapper;
import com.artemisx.EntitySystem;
import gibber.components.PosCmp;

class PhysicsSys extends EntitySystem
{
    public function new() {
        super( Aspect.getAspectForAll( [PosCmp] );
    }

    override public function intialize() : Void {
        physMapper = world.getMapper( PosCmp );
    }

    override public function process() : Void {
        
    }

    var physMapper : ComponentMapper<PosCmp>;

}