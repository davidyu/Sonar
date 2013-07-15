package gibber;
import gibber.components.LookCmp;

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
                god.commander.goToSector( god.player, words[1] );
                return "";
        }
        
        return "";
    }
    
    var god : God;
    
}