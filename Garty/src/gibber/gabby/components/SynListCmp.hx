package gibber.gabby.components;

import com.artemisx.Component;
import gibber.gabby.SynTag;

class SynListCmp implements Component
{
    @:isVar public var tag : SynTag;
    
    public function new( tag : SynTag ) {
        this.tag = tag;
    }
    
}