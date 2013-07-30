package gibber;
import gibber.commands.Command;
import gibber.commands.MoveCmd;
import gibber.commands.TransitCmd;

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
                return new MoveCmd( this, args[0], args[1] );
            case "transit":
                return new TransitCmd( args[0], args[1] );
            default:
                return null;
                
        }
    }
    
    
}