package gibber;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import gibber.components.NameIdCmp;
import gibber.components.PosCmp;
import gibber.components.TeractNodeCmp;
import gibber.gabby.SynTag;
import gibber.God;
import gibber.managers.ContainerMgr;
import gibber.managers.SectorGraphMgr;
import gibber.managers.SynonymMgr;
import gibber.teracts.Teract;

using Lambda;

enum ResScope
{
    LOCAL;  // Resolve to current sector only
    NEAR;   // Current & adjacent
    GLOBAL; // Everything
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
    
    //public function wordsToTags( words : Array<String> ) : Array<SynTag> {
        //var res = new Array<SynTag>();
        //
        //for ( w in words ) {
            //if ( 
        //}
    //}
    
    public function resolveTeract( input : Array<SynTag>, invoker : Entity, nounEntities : Array<Entity>, scope : ResScope ) : { teractOwner : Entity, teract : Teract, matchInfo : MatchInfo } {
        var currentSector = posMapper.get( invoker ).sector;
        if ( invoker == null || currentSector == null ) {
            return null;
        }
        
        var res = null;
        var sectors = sgm.getAllSectors();
        
        // Look at everything inside each sector
        for ( s in sectors ) {
            var contained = cm.getAllEntitiesOfContainer( s );
            for ( e in contained ) {
                var teractCmp = terMapper.get( e );
                if ( teractCmp == null || e == invoker ) { continue; }
                
                for ( t in teractCmp.attached ) {
                    var match = t.matchParams( invoker, nounEntities, input );
                    if ( match.match == TMatch.MATCH ) {
                        return { teractOwner : e, teract : t, matchInfo : match };
                    }
                }
            }
        }
        
        // Look at sectors themselves
        for ( s in sectors ) {
            var teractCmp = terMapper.get( s );
            if ( teractCmp == null ) { continue; }
            
            for ( t in teractCmp.attached ) {
                var match = t.matchParams( invoker, nounEntities, input );
                if ( match.match == TMatch.MATCH ) {
                    return { teractOwner : s, teract : t, matchInfo : match };
                }
            }
        }
        
        // Look at invoker inventory
        // TODO
        
        var teractCmp = terMapper.get( invoker );
        if ( teractCmp != null ) {
            for ( t in teractCmp.attached ) {
                var match = t.matchParams( invoker, nounEntities, input );
                if ( match.match == TMatch.MATCH ) {
                    return { teractOwner : invoker, teract : t, matchInfo : match };
                }
            }
        }
        
        return res;
    }
    
    var god : God;
    var cm : ContainerMgr;
    var sgm : SectorGraphMgr;
    var sm : SynonymMgr;
    
    var nameMapper : ComponentMapper<NameIdCmp>;
    var posMapper : ComponentMapper<PosCmp>;
    var terMapper : ComponentMapper<TeractNodeCmp>;
    
}
