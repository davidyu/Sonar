package gibber.components;

import com.artemisx.Aspect;
import com.artemisx.Component;
import com.artemisx.Entity;

class ContainerCmp implements Component
{
    @:isVar public var portals : Array<Entity>;
    @:isVar public var objects : Array<Entity>;

    public function new( ports : Array<Entity> = null, objs : Array<Entity> = null ) {
        portals = ports;
        objects = objs;
        
        if ( ports == null ) {
            portals = new Array();
        }
        
        if ( objs == null ) {
            objs = new Array();
        }
    }


}