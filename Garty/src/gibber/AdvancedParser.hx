package gibber;
import com.artemisx.Entity;
import gibber.components.LookCmp;
import gibber.components.NameIdCmp;
import gibber.managers.NameRegistry;
import gibber.managers.ContainerMgr;
import com.artemisx.Entity;
import com.artemisx.ComponentMapper;
import com.artemisx.ComponentMapper;
import gibber.components.PosCmp;
import gibber.components.ContainerCmp;

class AdvancedParser
{

    public function new( g : God ) {
        god = g;
    }
    
    public function parse( command : String ) : String {
        var words = command.split( " " );
        
        switch( words[0] ) {
            case "go":
                var dest : Entity = null;
                
                dest = god.world.getManager( NameRegistry ).getEntity( words[1] );
                
                god.world.getManager( NameRegistry ).getEntity( words[1] );
                //god.commander.getPortalDest( god.player, words[1] );
                return "";

            case "ls":

                //get sector
                var posMapper : ComponentMapper<PosCmp> = god.world.getMapper( PosCmp );
                var sector : Entity = ( posMapper.get( god.player ) ).sector;

                //get objects
                var containerMgr:ContainerMgr = god.world.getManager( ContainerMgr );
                var containees : Array<Entity> = containerMgr.getEntitiesOfContainer( sector );

                god.debugPrintln(Std.string(containees.length));

                var nameMapper : ComponentMapper<NameIdCmp> = god.world.getMapper( NameIdCmp );
                for ( obj in containees ) {
                    god.debugPrintln( nameMapper.get( obj ).name );
                }

                return "";

            case "clear":
                god.debugClear();
                return "";

            default:
                god.debugPrintln( "I'm sorry Dave, I can't let you do that." );

        }
        
        return "";
    }
    
    var god : God;
    
}
