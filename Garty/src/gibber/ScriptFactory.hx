package gibber;
import gibber.scripts.TransitScript;
import haxe.ds.StringMap;
import hscript.Parser;
import hscript.Interp;

using gibber.Util;

class ScriptFactory
{

    public function new( god : God ) {
        this.god = god;
        parser = new hscript.Parser();
        interp = new hscript.Interp();
        
        initialize();
    }
    
    public function initialize() : Void {
        //interp.variables.set( "God", God );
        interp.variables.set( "god", god );
    }
        
    
    
    public function createScript( name : String ) : TransitScript {
        return new TransitScript( god );
    }
    
    
    public function executeScript( script : String, params : StringMap<Dynamic>, outs : StringMap<Dynamic> ) : String {
        var i = interp.interpCopy();
        i.variables.set( "outs", outs );
        
        for ( k in params.keys() ) {
            i.variables.set( k, params.get( k ) );
        }
        
        return i.execute( parser.parseString( script ) );
    }
    
    var god : God;
    var parser : hscript.Parser;
    var interp : hscript.Interp;
    
   
    
}