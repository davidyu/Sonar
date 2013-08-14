package gibber.managers;

import com.artemisx.Aspect;
import com.artemisx.ComponentMapper;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import com.artemisx.Manager;
import gibber.components.ContainableCmp;
import gibber.components.ContainerCmp;
import gibber.components.NameIdCmp;
import gibber.components.PortalCmp;
import gibber.components.PosCmp;
import gibber.components.RegionCmp;

using Lambda;
using gibber.Util;

class SectorGraphMgr extends Manager
{
    public static var subsectorSig = Aspect.getAspectForAll( [NameIdCmp, RegionCmp] ).exclude( [ContainerCmp] );
    public static var sectorSig = Aspect.getAspectForAll( [NameIdCmp, ContainerCmp, RegionCmp] );
    public function new() {
        sectorIndex = new Array();
        adjMat = new Array();
    }
    
    override public function initialize() : Void {
        regionMapper = world.getMapper( RegionCmp );
        posMapper = world.getMapper( PosCmp );
        portalMapper = world.getMapper( PortalCmp );
    }
    
    override public function onAdded( e : Entity ) : Void {
        if ( Aspect.matches( sectorSig, e.componentBits ) ) {
            if ( !sectorIndex.exists( function(v) { return v.id == e.id; } ) ) {
                sectorIndex.push( e );
            } else {
                throw "Adding same sector twice to sector graph...";
            }
        } else if ( Aspect.matches( subsectorSig, e.componentBits ) ) {
            var portalCmp = portalMapper.get( e );
            
            for ( edge in portalCmp.edges ) {
                var indexI = sectorIndex.indexOf( edge.pSrc );
                
                if ( indexI != -1 ) {
                    if ( indexI > adjMat.length - 1 ) {
                        adjMat.realInsert( indexI, new Array() );
                    }
                    var indexJ = sectorIndex.indexOf( edge.pDest );
                    
                    if ( indexJ != -1 ) {
                        if ( indexJ > adjMat[indexI].length - 1 ) {
                            adjMat[indexI].realInsert( indexJ, [e] );
                        } else {
                            adjMat[indexI][indexJ].push( e );
                        }
                    } else {
                        throw "Dest sector not registered";
                    }
                } else {
                    throw "Src sector not registered";
                }
            }
        }
    }
    
    // 
    override public function onDeleted( e : Entity ) : Void {
        if ( Aspect.matches( sectorSig, e.componentBits ) ) {
            var index = sectorIndex.indexOf( e );
            if ( index != -1 ) {
                for ( i in 0...adjMat.length ) {
                    for ( k in 0...adjMat[i][index].length ) {
                        var portal = adjMat[i][index][k];
                        if ( portal != null ) {
                            // Maybe should just remove regionCmp here...
                            world.deleteEntity( portal );
                        }
                        adjMat[i][index][k] = null;
                    }
                    adjMat[i][index] = null;
                }
                for ( i in 0...adjMat[index].length ) {
                    for ( k in 0...adjMat[index][i].length ) {
                        var portal = adjMat[index][i];
                        if ( portal != null ) {
                            adjMat[index][i][k] = null;
                            // No need to delete here as containerMgr handles it
                            //world.deleteEntity( portal );
                        }
                    }
                }
                adjMat[index] = null;
                sectorIndex[index] = null;
                
            } else {
                trace("Hm... some sector wasn't added but detected upon deletion: " + e.id );
            }
        } else if ( Aspect.matches( subsectorSig, e.componentBits ) ) {
            var subRegionCmp = regionMapper.get( e );
            var indexI = sectorIndex.indexOf( subRegionCmp.parent );
            
            if ( subRegionCmp.parent != null ) {
                regionMapper.get( subRegionCmp.parent ).adj.remove( e );
            }
            if ( indexI != -1 ) {
                for ( re in subRegionCmp.adj ) {
                    var indexJ = sectorIndex.indexOf( re );
                    if ( indexJ != -1 ) {
                       adjMat[indexI][indexJ] = null;
                    } else {
                        trace( "Portal dest sector not registered. Possibly deleted before portal. e.id: " + e.id );
                    }
                }
            } else {
                trace( "Portal src sector not registered. Possibly deleted before portal e.id: " + e.id );
            }
            
        }
    }
    
    public function getEdges( srcSector : Entity, destSector : Entity ) : Array<Entity> {
        return adjMat[indexOf( srcSector )][indexOf( destSector )];
    }
    
    //public function getEdges( sector : Entity ) : Array<Entity> {
        //return null;
    //}
    
    public inline function indexOf( sector : Entity ) : Int {
        return sectorIndex.indexOf( sector );
    }
    
    // TODO
    override public function onChanged( e : Entity ) : Void {
        
    }
    
    var sectorIndex : Array<Entity>;
    var adjMat : Array<Array<Array<Entity>>>; // A[src][dest] -> array of portals from i to j
    var regionMapper : ComponentMapper<RegionCmp>;
    var posMapper : ComponentMapper<PosCmp>;
    var portalMapper : ComponentMapper<PortalCmp>;
}