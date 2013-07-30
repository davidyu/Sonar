package gibber.commands;
import com.artemisx.Entity;
import gibber.components.NameIdCmp;
import gibber.components.PosCmp;
import gibber.components.RegionCmp;
import gibber.gabby.PortalEdge;
import gibber.scripts.TransitScript;
import utils.Vec2;

class TransitCmd implements Command
{
    @:isVar public var mover( default, null ) : Entity;
    @:isVar public var edge : PortalEdge;
    @:isVar public var state : Command.TCmdRes;

   
    public function new( mover : Entity, portalEdge : PortalEdge ) {
        this.state = Command.TCmdRes.NEW;
        this.mover = mover;
        this.edge = portalEdge;
    }
    
    /* INTERFACE gibber.commands.Command */
    public function onStart() : Void {
        state = Command.TCmdRes.PENDING;
    }
    
    public function Execute() : Array<Dynamic> {
        var res : Array<Dynamic> = null;
        
        res = edge.transitScript.execute( mover, edge.pSrc, edge.pDest );
        
        state = Command.TCmdRes.PASS;
        return res;
    }
    
    public function onFinished() : Void {
        
    }
    
     // TODO
    var progressState : Int;
    
}