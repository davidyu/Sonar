package gibber.components;

import com.artemisx.Component;
import com.artemisx.Entity;
import gibber.managers.ContainerMgr;

class ContainableCmp implements Component
{
    @:isVar public var container ( default, set_container ) : Entity;
    @:isVar public var parent( default, default ) : Entity;
    
    public function new( mgr : ContainerMgr, parent : Entity, container : Entity = null ) {
        this.container = container;
        this.parent = parent;
        this.mgr = mgr;
    }
    
    var mgr : ContainerMgr;
    
    function set_container( newContainer : Entity ) : Entity {
        mgr.changeContainerOfEntity( parent, container, newContainer );
    }
    
}
