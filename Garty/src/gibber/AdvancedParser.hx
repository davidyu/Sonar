package gibber;
import com.artemisx.ComponentType;
import com.artemisx.Entity;
import gibber.components.CmdQueue;
import gibber.components.LookCmp;
import gibber.components.NameIdCmp;
import gibber.components.PortalCmp;
import gibber.components.RenderCmp;
import gibber.managers.NameRegistry;
import gibber.managers.ContainerMgr;
import gibber.managers.SynonymMgr;
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
        initialize();
    }
    
    public function initialize() : Void {
        posMapper = god.world.getMapper( PosCmp );
        nameMapper = god.world.getMapper( NameIdCmp );
        portalMapper = god.world.getMapper( PortalCmp );
    }
    
    public function parse( command : String ) : String {

        var words = command.split( " " );
        
        switch( words[0] ) {
//
            //case "go":
                //
                //if ( words.length > 1 ) {
                    //switch ( words[1] ) {
                        //case "-v", "-vec": //directly go to this new position
                            //if ( words.length == 4) {
                                //var newLoc = new Vec2( Std.parseFloat( words[2] ), Std.parseFloat( words[3] ) );
                                //god.commander.goToPosition( god.player, newLoc );
                                //return "";
                            //} else {
                                //god.debugPrintln( "Usage: go " + words[1] + " x y " );
                            //}
                        //case "through", "thru":
                            //var portals = god.entityResolver.globalResolve( words[2] );
                            //if ( portals != null ) {
                                //var destSector = portalMapper.get( portals[0] ).edges[0].pDest;
                                //god.commander.goToSector( god.player, destSector );
                            //}
                        //default:
                            //var destSectors = god.entityResolver.globalResolve( words[1] );
                            //if ( destSectors != null ) {
                                //god.commander.goToSector( god.player, destSectors[0] );
                            //} else {
                                //god.debugPrintln( "I don't understand that flag for 'go.'");
                            //}
                            //return "";
                    //}
                //}
//
                //var dest : Entity = null;
                //dest = god.world.getManager( NameRegistry ).getEntity( words[1] );
                //god.world.getManager( NameRegistry ).getEntity( words[1] );
                //god.commander.getPortalDest( god.player, words[1] );
                // this should work. Make the player go somewhere!
                //return "";

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
                var containees : Array<Entity> = containerMgr.getAllEntitiesOfContainer( sector );

                for ( obj in containees ) {
                    god.debugPrintln( nameMapper.get( obj ).name );
                }

                return "";

<<<<<<< HEAD
            case "take":

                var objName = words[1];

                var objs = god.entityResolver.globalResolve( objName );
                var newLoc:Entity = god.player;
                if ( objs != null ) {
                    var cmdCmp = god.player.getComponent( CmdQueue );
                    var posCmp = posMapper.get( objs[0] );
                    cmdCmp.enqueue( god.cf.createCmd( "move", [ newLoc, posCmp.pos, posCmp.sector] ) );
                    cmdCmp.enqueue( god.cf.createCmd( "take", [ objs[0], newLoc ] ) );
                } else {
                    god.debugPrintln( "No such item exists" );
                }

                return "";

            case "resolve":
                if ( words.length >= 2 ) {

                    if ( words[1] == "-p" ) {
                        var synonymMgr : SynonymMgr = god.world.getManager( SynonymMgr );
                        var syns = synonymMgr.getListOfRegisteredSynonyms(); 
                        god.debugPrint("{ ");
                        for ( syn in syns ) {
                            god.debugPrint( syn + " " );
                        }
                        god.debugPrint("}\n");
                        return "";
                    }

                    var synonym : String = words[1];
                    var synonymMgr : SynonymMgr = god.world.getManager( SynonymMgr );
                    for ( entity in synonymMgr.resolveSynonym( synonym ) ) {
                        god.debugPrintln( entity.getComponent( NameIdCmp ).name );
                    }
                } else {
                    god.debugPrintln( "usage: resolve <synonym> " );
                }
                return "";
            case "do":
                if ( words.length >= 2 ) {
                    // resolve third word, this is the target
                    // look through all of its Teracts and try to match
                }
||||||| merged common ancestors
            case "take":

                var objName = words[1];

                var objs = god.entityResolver.globalResolve( objName );
                var newLoc:Entity = god.player;
                if ( objs != null ) {
                    var cmdCmp = god.player.getComponent( CmdQueue );
                    var posCmp = posMapper.get( objs[0] );
                    cmdCmp.enqueue( god.cf.createCmd( "move", [ newLoc, posCmp.pos, posCmp.sector] ) );
                    cmdCmp.enqueue( god.cf.createCmd( "take", [ objs[0], newLoc ] ) );
                } else {
                    god.debugPrintln( "No such item exists" );
                }

                return "";

            case "resolve":
                if ( words.length >= 2 ) {

                    if ( words[1] == "-p" ) {
                        var synonymMgr : SynonymMgr = god.world.getManager( SynonymMgr );
                        var syns = synonymMgr.getListOfRegisteredSynonyms(); 
                        god.debugPrint("{ ");
                        for ( syn in syns ) {
                            god.debugPrint( syn + " " );
                        }
                        god.debugPrint("}\n");
                        return "";
                    }

                    var synonym : String = words[1];
                    var synonymMgr : SynonymMgr = god.world.getManager( SynonymMgr );
                    for ( entity in synonymMgr.resolveSynonym( synonym ) ) {
                        god.debugPrintln( entity.getComponent( NameIdCmp ).name );
                    }
                } else {
                    god.debugPrintln( "usage: resolve <synonym> " );
                }
                return "";
=======
            //case "take":
//
                //var objName = words[1];
//
                //var objs = god.entityResolver.globalResolve( objName );
                //var newLoc:Entity = god.player;
                //if ( objs != null ) {
                    //var cmdCmp = god.player.getComponent( CmdQueue );
                    //var posCmp = posMapper.get( objs[0] );
                    //cmdCmp.enqueue( god.cf.createCmd( "move", [ newLoc, posCmp.pos, posCmp.sector] ) );
                    //cmdCmp.enqueue( god.cf.createCmd( "take", [ objs[0], newLoc ] ) );
                //} else {
                    //god.debugPrintln( "No such item exists" );
                //}
//
                //return "";
//
            //case "resolve":
                //if ( words.length >= 2 ) {
//
                    //if ( words[1] == "-p" ) {
                        //var synonymMgr : SynonymMgr = god.world.getManager( SynonymMgr );
                        //var syns = synonymMgr.getListOfRegisteredSynonyms(); 
                        //god.debugPrint("{ ");
                        //for ( syn in syns ) {
                            //god.debugPrint( syn + " " );
                        //}
                        //god.debugPrint("}\n");
                        //return "";
                    //}
//
                    //var synonym : String = words[1];
                    //var synonymMgr : SynonymMgr = god.world.getManager( SynonymMgr );
                    //for ( entity in synonymMgr.resolveSynonym( synonym ) ) {
                        //god.debugPrintln( entity.getComponent( NameIdCmp ).name );
                    //}
                //} else {
                    //god.debugPrintln( "usage: resolve <synonym> " );
                //}
                //return "";
>>>>>>> 24b9f166fe223b90da85924ddf971224c233d674

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
    var posMapper : ComponentMapper<PosCmp>;
    var nameMapper : ComponentMapper<NameIdCmp>;
    var portalMapper : ComponentMapper<PortalCmp>;
    
}
