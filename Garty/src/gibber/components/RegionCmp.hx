package gibber.components;
import com.artemisx.Component;
import com.artemisx.Entity;
import gibber.scripts.VoidExecuteScript;
import utils.Polygon;
import utils.Vec2;

class RegionCmp implements Component
{
    @:isVar public var polys ( default, default ) : Array<Polygon>;
    @:isVar public var pos ( default, default ) : Vec2;

    public function new( pos : Vec2, polygonAreas : Array<Polygon> = null, enter : VoidExecuteScript=null, exit : VoidExecuteScript=null ) {
        enterScript = enter;
        exitScript = exit;
        
        if ( polygonAreas != null ) {
            polys = polygonAreas;
        } else {
            polys = new Array();
        }
        
        this.pos = pos;
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