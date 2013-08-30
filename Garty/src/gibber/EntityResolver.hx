package gibber;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import gibber.components.NameIdCmp;
import gibber.God;
import gibber.managers.ContainerMgr;
import gibber.managers.SectorGraphMgr;
import gibber.managers.SynonymMgr;

using Lambda;

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
    
    // Matches against sectors and portals adjacent to the src sector entities provided
    public function mapResolve( word : String, sectors : Array<Entity> ) : Array<Entity> {
        var res = new Array<Entity>();
        for ( s in sectors ) {
            var adjP = sgm.getAdjacentPortals( s );
            if ( adjP != null ) {
                for ( p in adjP ) {
                    var nameCmp = nameMapper.get( p );
                    if ( !res.exists( function( v ) { return v.id == p.id; } ) && nameCmp.syns.isMatch( word ) ) {
                        res.push( p );
                    }
                }
            }
            
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
    
    public function globalResolve( name : String ) : Array<Entity> {
        var e = sm.getEntity( name );
        var res = null;
        
        if ( e != null ) {
            res = [e];
        }
        return res;
    }
    
    
    public function resolve( name : String ) : Array<Entity> {
        return null;
    }
    
    var god : God;
    var cm : ContainerMgr;
    var sgm : SectorGraphMgr;
    var sm : SynonymMgr;
    
    var nameMapper : ComponentMapper<NameIdCmp>;
    
}
