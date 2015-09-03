package sonar.commands;
import com.artemisx.ComponentMapper;
import com.artemisx.Aspect;
import com.artemisx.Entity;
import sonar.CmdFactory;
import sonar.components.NameIdCmp;
import sonar.components.PosCmp;
import sonar.components.ContainableCmp;
import sonar.components.RegionCmp;
import sonar.components.RenderCmp;
import sonar.gabby.PortalEdge;
import sonar.components.ContainerCmp;

@:rtti
class TakeCmd implements Command
{
    @:isVar public var obj   ( default, null ) : Entity;
    @:isVar public var oldLoc( default, null ) : Entity;
    @:isVar public var newLoc( default, null ) : Entity;
    @:isVar public var state : Command.TCmdRes;

    public function new( cf : CmdFactory, obj : Entity, newLoc : Entity ) {
        this.state = Command.TCmdRes.NEW;
        this.newLoc = newLoc;
        this.obj = obj;
        this.cf = cf;

        this.containerMapper = cf.god.world.getMapper( ContainerCmp );
        this.containableMapper = cf.god.world.getMapper( ContainableCmp );
        this.nameMapper = cf.god.world.getMapper( NameIdCmp );
    }

    public function onStart() : Void {
        //check object is actually containable
        //TODO @desktop: remove this when new ContainerManager is checked in
        var objSig       = Aspect.getAspectForAll( [NameIdCmp, ContainableCmp, PosCmp] );

        if ( Aspect.matches( objSig, obj.componentBits ) ) {
            oldLoc = containableMapper.get( obj ).container;
            state = Command.TCmdRes.PENDING;
        } else {
            state = Command.TCmdRes.FAIL;
        }
    }

    public function Execute() : Array<Dynamic> {
        var containerSig = Aspect.getAspectForAll( [ContainerCmp, NameIdCmp] );

        state = Command.TCmdRes.FAIL;

        return [ "moving containers is NOT implemented.", false ];
    }
    
    public function onFinished() : Void {
        obj.removeComponent( RenderCmp );
        
    }

    var cf : CmdFactory;
    var containerMapper : ComponentMapper<ContainerCmp>;
    var containableMapper : ComponentMapper<ContainableCmp>;
    var nameMapper : ComponentMapper<NameIdCmp>;
}
