package gibber.commands;
import com.artemisx.ComponentMapper;
import com.artemisx.Aspect;
import com.artemisx.Entity;
import gibber.components.NameIdCmp;
import gibber.components.PosCmp;
import gibber.components.ContainableCmp;
import gibber.components.RegionCmp;
import gibber.gabby.PortalEdge;

class TakeCmd implements Command
{
    @:isVar public var obj   ( default, null ) : Entity;
    @:isVar public var oldLoc( default, null ) : Entity;
    @:isVar public var newLoc( default, null ) : Entity;
    @:isVar public var state : Command.TCmdRes;

    public function new( cf : CmdFactory, obj : Entity, oldLoc : Entity, newLoc : Entity ) {
        this.state = Command.TCmdRes.NEW;
        this.newLoc = newLoc;
        this.oldLoc = oldLoc;
        this.obj = obj;

        this.containerMapper = cf.god.world.getMapper( ContainerCmp );
        this.nameMapper = cf.god.world.getMapper( NameIdCmp );
    }

    public function onStart() : Void {
        //check object is actually containable
        var objSig       = Aspect.getAspectForAll( [NameIdCmp, ContainableCmp, PosCmp] );

        if ( Aspect.matches( objSig, obj.componentBits ) ) {
            state = Command.TCmdRes.PENDING;
        } else {
            state = Command.TCmdRes.FAIL;
        }
    }

    public function Execute() : Array<Dynamic> {
        var containerSig = Aspect.getAspectForAll( [ContainerCmp, NameIdCmp] );

        if ( Aspect.matches( containerSig, newLoc.componentBits ) ) {
            containableMapper.get( obj ).container = newLoc;
            state = Command.TCmdRes.PASS;
            return [ "moved to " + nameMapper.get( newLoc ).name, true ];
        }

        state = Command.TCmdRes.FAIL;
        return [ "location that " + nameMapper.get( obj ).name + " is being moved to is not a container.", false ];
    }
    
    public function onFinished() : Void {
        
    }

    var containableMapper : ComponentMapper<ContainableCmp>;
    var nameMapper : NameMapper<NameIdCmp>;
}