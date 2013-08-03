package gibber;
import com.artemisx.Entity;
import gibber.components.CmdQueue;
import gibber.components.LookCmp;
import gibber.components.NameIdCmp;
import gibber.managers.NameRegistry;
import gibber.managers.ContainerMgr;
import com.artemisx.Entity;
import com.artemisx.ComponentMapper;
import com.artemisx.ComponentMapper;
import gibber.components.PosCmp;
import gibber.components.ContainerCmp;
import utils.Vec2;

class AdvancedParser
{

    public function new( g : God ) {
        god = g;
    }
    
    public function parse( command : String ) : String {

        var posMapper : ComponentMapper<PosCmp> = god.world.getMapper( PosCmp );
        var nameMapper : ComponentMapper<NameIdCmp> = god.world.getMapper( NameIdCmp );
        var words = command.split( " " );
        
        switch( words[0] ) {

            case "go":
                
                if ( words.length > 1 ) {
                    switch ( words[1] ) {
                        case "-v", "-vec": //directly go to this new position
                            if ( words.length == 4) {
                                var newLoc = new Vec2( Std.parseFloat( words[2] ), Std.parseFloat( words[3] ) );
                                god.commander.goToPosition( god.player, newLoc );
                                return "";
                            } else {
                                god.debugPrintln( "Usage: go " + words[1] + " x y " );
                            }
                        default:
                            god.debugPrintln( "I don't understand that flag for 'go.'");
                            return "";
                    }
                }

                var dest : Entity = null;
                dest = god.world.getManager( NameRegistry ).getEntity( words[1] );
                god.world.getManager( NameRegistry ).getEntity( words[1] );
                //god.commander.getPortalDest( god.player, words[1] );
                // this should work. Make the player go somewhere!
                return "";

            case "ls":

                //get sector
                var sector : Entity = ( posMapper.get( god.player ) ).sector;

                if ( words.length > 1 ) {
                    switch ( words[1] ) {
                        case "-inventory", "-i", "-player", "-p":
                            sector = god.player;
                        default:
                            god.debugPrintln( "I don't understand that flag for 'ls.'" );
                            return "";
                    }
                }

                //get objects
                var containerMgr:ContainerMgr = god.world.getManager( ContainerMgr );
                var containees : Array<Entity> = containerMgr.getEntitiesOfContainer( sector );

                for ( obj in containees ) {
                    god.debugPrintln( nameMapper.get( obj ).name );
                }

                return "";

            case "take":

                var objName = words[1];

                var obj:Entity = god.world.getManager( NameRegistry ).getEntity( objName );
                var newLoc:Entity = god.player;

                var cmdCmp = god.player.getComponent( CmdQueue );
                cmdCmp.enqueue( god.cmdFactory.createCmd( "take", [ god.cmdFactory, obj, newLoc ] ) );

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
