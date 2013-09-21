package gibber;

import com.artemisx.Entity;
import com.artemisx.ComponentMapper;
import com.artemisx.ComponentMapper;
import com.artemisx.ComponentType;

import gibber.gabby.SynTag;
import gibber.components.CmdQueue;
import gibber.components.LookCmp;
import gibber.components.NameIdCmp;
import gibber.components.PortalCmp;
import gibber.components.RenderCmp;
import gibber.managers.NameRegistry;
import gibber.managers.ContainerMgr;
import gibber.managers.SynonymMgr;
import gibber.managers.WordsMgr;
import gibber.teracts.Teract;
import gibber.components.PosCmp;
import gibber.components.ContainerCmp;
import utils.Vec2;

typedef InputCommand = {
    var targets : Array<Entity>;
    var action  : String;
}

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
        wordsMgr = god.world.getManager( WordsMgr );
        er = god.entityResolver;
    }

    public function parse( command : String ) : String {

        // tokenize
        var words = command.toLowerCase().split( " " );

        // parse into InputCommand
        var action : String = null;
        var targets : Array<Entity> = new Array<Entity>();
        for ( word in words ) {
            var isNoun = false;
            var isVerb = false;

            var tags = wordsMgr.getSynTags( word );
            if ( tags == null ) {
                continue;
            }

            for ( tag in tags ) {
                switch ( tag.type ) {
                    case SynType.NOUN:
                        isNoun = true;
                        // a little bit of sisiphus here...if we've already
                        // resolved it to a tag, we just need to resolve from Tag to Entity!
                        var resolvedEntity = er.tehResolve( word, god.player );
                        if ( resolvedEntity != null ) {
                            targets.push( resolvedEntity );
                        }
                        break;
                    case SynType.VERB:
                        if ( action != null ) {
                            trace( "error: already parsed action: " + action + " but now resolving " + word );
                        } else {
                            action = word;
                        }
                        isVerb = true;
                        break;
                    default:
                }
            }

            // check for ambiguity
            if ( targets.length == 0 && isNoun ) {
                god.debugPrintln( "Can't resolve " + word );
                return "";
            }
        }

        var input : InputCommand = { targets : targets, action : action };

        // parse/typecheck using tractMatch. Get the correct Teract and match it
        var teractMatch = er.resolveTeract( input, god.player, EntityResolver.ResScope.GLOBAL );
        if ( teractMatch != null ) {
            var msg = teractMatch.teract.executeEffect( god.player, input.targets, null );
            god.debugPrintln( msg.output );
        }

        switch( words[0] ) {
            case "clear":
                god.debugClear();
                return "";
        }

        return "";
    }

    var wordsMgr : WordsMgr;
    var god : God;
    var posMapper : ComponentMapper<PosCmp>;
    var nameMapper : ComponentMapper<NameIdCmp>;
    var portalMapper : ComponentMapper<PortalCmp>;
    var er : EntityResolver;
}
