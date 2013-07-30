package gibber.components;
import com.artemisx.Component;
import com.artemisx.Entity;
import gibber.gabby.PortalEdge;
import gibber.scripts.TransitScript;
import gibber.scripts.VoidExecuteScript;

class PortalCmp implements Component
{
    @:isVar public var edges : Array<PortalEdge>;
    
    public function new( edges : Array<PortalEdge> = null ) {
        if ( edges == null ) {
            edges = new Array();
        }
        this.edges = edges;
    }
    
}
