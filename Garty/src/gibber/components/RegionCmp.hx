package gibber.components;
import com.artemisx.Component;
import com.artemisx.Entity;
import gibber.scripts.VoidExecuteScript;
import utils.Vec2;

class RegionCmp implements Component
{
    public function new( enter : VoidExecuteScript=null, exit : VoidExecuteScript=null ) {
        enterScript = enter;
        exitScript = exit;
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

    //var polys : Array<
    @:isVar var pos : Vec2;
    
}