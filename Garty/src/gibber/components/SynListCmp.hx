package gibber.components;

import com.artemisx.Component;
import gibber.gabby.SynTag;

@:rtti
class SynListCmp implements Component
{
    @:isVar public var tag : SynTag;
    
    public function new( tag : SynTag ) {
        this.tag = tag;
    }
    
}
