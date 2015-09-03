package sonar.scripts;
import com.artemisx.Entity;
import sonar.ScriptFactory;
import haxe.ds.StringMap;

class GenericScript implements Script
{
    @:isVar public var script : String;
    
    public function new( scriptBase : ScriptFactory, script : String ) {
        this.script = script;
        this.sb = scriptBase;
    }
    
    public function execute( params : StringMap<Dynamic>, outs : StringMap<Dynamic> ) : Script.ScriptRunInfo {
        return sb.executeScript( script, params, outs );
    }
    
    var sb : ScriptFactory;
}
