package gibber.components;
import com.artemisx.Component;
import com.artemisx.Entity;
import gibber.gabby.Region;
import gibber.scripts.VoidExecuteScript;
import utils.Polygon;
import utils.Vec2;

class RegionCmp implements Component
{
    @:isVar public var polys ( default, default ) : Array<Polygon>;
    @:isVar public var parent : Entity;
    @:isVar public var owner : Entity;
    @:isVar public var portals : Array<Entity>;
    
    public function new( polygonAreas : Array<Polygon> = null, enter : VoidExecuteScript=null, exit : VoidExecuteScript=null ) {
        enterScript = enter;
        exitScript = exit;
        
        if ( polygonAreas == null ) {
            polygonAreas = new Array<Polygon>();
        }
        
        this.polys = polygonAreas;
        this.portals = new Array();
    }
    
    public function onEnter( mover : Entity, fromSector : Entity ) : Void {
        if ( enterScript != null ) {
            enterScript.execute();
        }
    }
    
    public function onExit( mover : Entity, toSector : Entity ) : Void {
        if ( exitScript != null ) {
            exitScript.execute();
        }
    }
    
    var enterScript : VoidExecuteScript;
    var exitScript : VoidExecuteScript;

}