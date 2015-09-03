package sonar.components;

import com.artemisx.Component;
import com.artemisx.Entity;
import sonar.managers.ContainerMgr;


// TODO Implement pos change relative to container
// i.e. Player has item. Player moves. Item sector coordinate should match player's.
@:rtti
class ContainableCmp implements Component
{
    @:isVar public var container ( default, null ) : Entity;
    @:isVar public var owner : Entity;
    
    public function new( mgr : ContainerMgr, owner : Entity, container : Entity = null ) {
        this.mgr = mgr;
        this.owner = owner;
        this.container = container;
    }
    
    var mgr : ContainerMgr;
}
