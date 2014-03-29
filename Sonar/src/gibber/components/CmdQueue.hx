package gibber.components;

import com.artemisx.Component;
import gibber.commands.Command;

class CmdQueue implements Component 
{
    public function new() {
        cmds = new List();
    }
    
    public function enqueue( cmd : Command ) : Void {
        cmds.add( cmd );
    }
    
    public function dequeue() : Command { 
        return cmds.pop();
    }
    
    public function first() : Command {
        return cmds.first();
    }
    
    public function clear() : Void {
        cmds.clear();
    }
    
    var cmds : List<Command>;
    
}
