package gibber.components;
import com.artemisx.Component;
import com.artemisx.Entity;
import gibber.scripts.TransitScript;

class PortalCmp implements Component
{

    public function new( transit : Script=null ) {
        transitScript = transit;
    }
    
    var transitScript : TransitScript;
}