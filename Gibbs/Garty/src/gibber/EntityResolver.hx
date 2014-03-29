package gibber;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import gibber.components.NameIdCmp;
import gibber.components.PosCmp;
import gibber.components.TeractNodeCmp;
import gibber.gabby.SynTag;
import gibber.AdvancedParser;
import gibber.God;
import gibber.managers.ContainerMgr;
import gibber.managers.SectorGraphMgr;
import gibber.managers.SynonymMgr;
import gibber.managers.WordsMgr;
import gibber.teracts.Teract;

using Lambda;

enum ResScope
{
    LOCAL;  // Resolve to current sector only
    GLOBAL; // Everything
}

typedef TeractMatch = 
{
    var teractOwner : Entity;
    var teract : Teract;
    var matchInfo : MatchInfo;
}

class EntityResolver
{

    public function new( god : God ) {
        this.god = god;
        initialize();
    }
    
    public function initialize() : Void {
        cm = god.world.getManager( ContainerMgr );
        sm = god.world.getManager( SynonymMgr );
        sgm = god.world.getManager( SectorGraphMgr );
        wm = god.world.getManager( WordsMgr ); // Man, I feel like a wm ( Words manager )
        
        nameMapper = god.world.getMapper( NameIdCmp );
        posMapper = god.world.getMapper( PosCmp );
        terMapper = god.world.getMapper( TeractNodeCmp );

    }
    
    // Looks at all entitiy in a container and matches against the word
    public function containerResolve( word : String, containers : Array<Entity> ) : Array<Entity> {
        var res = new Array<Entity>();
        
        for ( c in containers ) {
            var contained = cm.getAllEntitiesOfContainer( c );
            for ( e in contained ) {
                var ents = sm.resolveSynonym( word );
                if ( ents != null && ents.length > 0 ) {
                    for ( e in ents ) {
                        var nameCmp = nameMapper.get( e );
                        if ( nameCmp.syns.isMatch( word ) && !res.exists( function( v ) { return v.id == e.id; } ) ) {
                            res.push( e );
                        }
                    }
                }
            }
        }
        
        return res;
    }
    
    
    public function portalResolve( word : String, portalsInSectors : Array<Entity> ) : Array<Entity> {
        var res = new Array<Entity>();
        
        for ( s in portalsInSectors ) {
            var adjP = sgm.getAdjacentPortals( s );
            if ( adjP != null ) {
                for ( p in adjP ) {
                    var nameCmp = nameMapper.get( p );
                    if ( !res.exists( function( v ) { return v.id == p.id; } ) && nameCmp.syns.isMatch( word ) ) {
                        res.push( p );
                    }
                }
            }
        }
        
        return res;
    }
    
    // Matches against sectors adjacent to the src sector entities provided
    public function sectorResolve( word : String, sectors : Array<Entity> ) : Array<Entity> {
        var res = new Array<Entity>();
        
        for ( s in sectors ) {
            var adjS = sgm.getAdjacentSectors( s );
            if ( adjS != null ) {
                for ( s in adjS ) {
                    var nameCmp = nameMapper.get( s );
                    if ( !res.exists( function( v ) { return v.id == s.id; } ) && nameCmp.syns.isMatch( word ) ) {
                        res.push( s );
                    }
                }
            }
        }
        
        return res;
    }
    
    public function tehResolve( word : String, player : Entity ) : Entity {
        var res : Entity = null;
        var playerSector = posMapper.get( player ).sector;
        
        var ents = containerResolve( word, [playerSector] );
        if ( ents.length > 0 ) {
            if ( ents.length == 1 ) {
                return ents[0];
            } else {
                trace( "Ambiguous" );
            }
        }
        
        ents = sectorResolve( word, [playerSector] );
        if ( ents.length > 0 ) {
            if ( ents.length == 1 ) {
                return ents[0];
            } else {
                trace( "Ambiguous" );
            }
        }        
        
        ents = portalResolve( word, [playerSector] );
        if ( ents.length > 0 ) {
            if ( ents.length == 1 ) {
                return ents[0];
            } else {
                trace( "Ambiguous" );
            }
        }
       
        return res;
        
    }
    
    // TODO Dave you have knowledge with parsing and language structure. 
    // This function can be expanded to a separate class if you have any ideas
    // for improvement.
    // Parses user input into an array of syntags
    public function wordsToTags( words : Array<String> ) : { tags : Array<SynTag>, nouns : Array<Entity> } {
        var res = new Array<SynTag>();
        var nounsEntities = new Array<Entity>();

        for ( w in words ) {
            var synTags = wm.getSynTags( w );
            if ( synTags == null ) { continue; }
            // Maybe there is better way to resolve ambiguous synonyms..
            // example use case "jump the guard (aka rob him of his possessions)" vs. jump the fence 
            // -> entirely different meanings. We don't want to try to mug a fence
            for ( t in synTags ) {
                res.push( t );

                switch ( t.type ) {
                    case SynType.NOUN:
                        nounsEntities.push( sm.getEntity( t.nameId ) );
                    default:
                        
                }
            }
        }
        trace( res );
        trace( nounsEntities );
        return { tags : res, nouns : nounsEntities };
    }

    public function resolveTeract( input : InputCommand, invoker : Entity, scope : ResScope ) : TeractMatch {
        var currentSector = posMapper.get( invoker ).sector;
        if ( invoker == null || currentSector == null ) {
            return null;
        }

        var res : TeractMatch = null;
        var sectors = sgm.getAllSectors();
        var matchInvalids = new Array<TeractMatch>();

        for ( s in sectors ) {
            var contained = cm.getAllEntitiesOfContainer( s );
            for ( e in contained ) {
                var teractCmp = terMapper.get( e );
                if ( teractCmp == null || e == invoker ) { continue; }

                for ( t in teractCmp.attached ) {
                    var synsLst : Array<SynTag> = wm.getSynTags( input.action );
                    trace( synsLst );
                    trace( t );
                    trace( t.syns );
                    if ( !synsLst.exists( function( syns ) { return syns == t.syns; } ) ) {
                        continue;
                    }

                    var match = t.matchParams( invoker, input.targets );
                    var tres = { teractOwner : e, teract : t, matchInfo : match };
                    switch ( match.match ) {
                        case TMatch.MATCH:
                            return tres;
                        case TMatch.MATCH_INVALID:
                            matchInvalids.push( tres );
                    default:
                    }
                }
            }
        }

        // Look at sectors themselves
        for ( s in sectors ) {
            var teractCmp = terMapper.get( s );
            if ( teractCmp == null ) { continue; }

            for ( t in teractCmp.attached ) {
                var synsLst : Array<SynTag> = wm.getSynTags( input.action );
                if ( !synsLst.exists( function( syns ) { return syns == t.syns; } ) ) {
                    continue;
                }

                var match = t.matchParams( s, input.targets );
                var tres = { teractOwner : invoker, teract : t, matchInfo : match };
                switch ( match.match ) {
                    case TMatch.MATCH:
                        return tres;
                    case TMatch.MATCH_INVALID:
                        matchInvalids.push( tres );
                    default:
                }
            }
        }

        // Look at invoker inventory
        // TODO
        var teractCmp = terMapper.get( invoker );
        if ( teractCmp != null ) {
            for ( t in teractCmp.attached ) {
                var synsLst : Array<SynTag> = wm.getSynTags( input.action );
                if ( !synsLst.exists( function( syns ) { return syns == t.syns; } ) ) {
                    continue;
                }

                var match = t.matchParams( invoker, input.targets );
                var tres = { teractOwner : invoker, teract : t, matchInfo : match };
                switch ( match.match ) {
                    case TMatch.MATCH:
                        return tres;
                    case TMatch.MATCH_INVALID:
                        matchInvalids.push( tres );
                    default:
                }
            }
        }
        return res;
    }

    var god : God;
    var cm : ContainerMgr;
    var sgm : SectorGraphMgr;
    var sm : SynonymMgr;
    var wm : WordsMgr;

    var nameMapper : ComponentMapper<NameIdCmp>;
    var posMapper : ComponentMapper<PosCmp>;
    var terMapper : ComponentMapper<TeractNodeCmp>;
}
