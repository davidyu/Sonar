package gibber.components;

import com.artemisx.Component;
import com.artemisx.Entity;
import gibber.teracts.Teract;

class TeractNodeCmp implements Component
{
    @:isVar public var attached : Array<Teract>;
    
    public function new( attached : Array<Teract> = null ) {
        if ( attached == null ) {
            attached = new Array<Teract>();
        }
        this.attached = attached;
    }
    
}