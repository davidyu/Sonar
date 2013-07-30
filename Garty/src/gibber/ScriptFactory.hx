package gibber;
import gibber.scripts.TransitScript;

class ScriptFactory
{

    public function new( god : God ) {
        this.god = god;
    }
    
    
    public function createScript( name : String ) : TransitScript {
        return new TransitScript( god );
    }
    var god : God;
    
}