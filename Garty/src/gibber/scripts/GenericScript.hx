package gibber.scripts;
import com.artemisx.Entity;
import gibber.ScriptFactory;

class GenericScript implements Script
{
    @:isVar public var codes : String;
    
    public function new( scriptBase : ScriptFactory, codes : String ) {
        this.codes = codes;
        this.scriptBase = scriptBase;
    }
    
    public function execute( invoker : Entity, invokees : Array<Entity>, params : Array<String> ) : { msg : String,  res : Script.ExeRes, outs : Array<Dynamic> } {
        return null;
    }
    
    var scriptBase : ScriptFactory;
    
}