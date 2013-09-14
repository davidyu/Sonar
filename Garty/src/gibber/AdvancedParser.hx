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
        er = god.entityResolver;
    }

    public function parse( command : String ) : String {

        var words = command.toLowerCase().split( " " );
        var tagged = er.wordsToTags( words );
        var teractMatch = er.resolveTeract( tagged.tags, god.player, tagged.nouns, EntityResolver.ResScope.GLOBAL );
        if ( teractMatch != null ) {
            var msg = teractMatch.teract.executeEffect( god.player, tagged.nouns, null );
            god.debugPrintln( msg.output );
        }

        switch( words[0] ) {
            case "clear":
                god.debugClear();
                return "";
        }

        return "";
    }

    var god : God;
    var posMapper : ComponentMapper<PosCmp>;
    var nameMapper : ComponentMapper<NameIdCmp>;
    var portalMapper : ComponentMapper<PortalCmp>;
    var er : EntityResolver;
}
