package gibber;
import com.artemisx.Entity;
import gibber.components.LookCmp;
import gibber.managers.NameRegistry;

class AdvancedParser
{

    public function new( g : God ) {
        god = g;
    }
    
    public function parse( command : String ) : String {
        var words = command.split( " " );
        
        if ( words.length < 2 ) {
            return "";
        }
        
        switch( words[0] ) {
            case "go":
				var dest : Entity = null;
				
				dest = god.world.getManager( NameRegistry ).getEntity( words[1] );
				
				god.world.getManager( NameRegistry ).getEntity( words[1] );
                //god.commander.getPortalDest( god.player, words[1] );
                return "";
        }
        
        return "";
    }
    
    var god : God;
    
}