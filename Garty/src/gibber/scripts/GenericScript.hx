package gibber.scripts;
import com.artemisx.Entity;
import gibber.ScriptFactory;
import haxe.ds.StringMap;

class GenericScript implements Script
{
    @:isVar public var script : String;
    
    public function new( scriptBase : ScriptFactory, script : String ) {
        this.script = script;
        this.sb = scriptBase;
    }
    
    public function execute( params : StringMap<Dynamic>, outs : StringMap<Dynamic> ) : String {
        return sb.executeScript( script, params, outs );
    }
    
    var sb : ScriptFactory;
}