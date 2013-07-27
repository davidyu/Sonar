package gibber;
import gibber.commands.Command;
import gibber.commands.MoveCmd;

@:access(gibber.commands)
class CmdFactory
{
    @:isVar public var god : God;
    
    public function new( god : God ) {
            this.god = god;
    }
    
    public function createCmd( commandName : String, args : Array<Dynamic> ) : Command {
        switch ( commandName ) {
            case "move":
                return new MoveCmd( this, args );
            default:
                return null;
                
        }
    }
    
    
}