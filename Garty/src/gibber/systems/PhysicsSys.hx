package gibber.systems;
import com.artemisx.Aspect;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import com.artemisx.EntitySystem;
import com.artemisx.utils.Bag;
import gibber.components.PosCmp;
import gibber.components.RegionCmp;
import gibber.components.StaticPosCmp;
import utils.Polygon;
import utils.Vec2;

using Lambda;
using gibber.Util;
using utils.Geo;

class PhysicsSys extends EntitySystem
{
    public function new() {
        super( Aspect.getAspectForAll( [PosCmp] ).exclude( [StaticPosCmp] ) );
    }

    override public function initialize() : Void {
        posMapper = world.getMapper( PosCmp );
        regionMapper = world.getMapper( RegionCmp );
    }

    override public function processEntities( entities : Bag<Entity> ) : Void  {
        var e : Entity;         
        var posCmp : PosCmp;    // Position component of entity
        var pos;                // Position of entity
        var newPos : Vec2;      // Projected osition of entity after update
        var collPoint : Vec2;   // Collision point with wall
        var sectorPolys : Array<Polygon>; // Walls
        var sectorPos : Vec2;       // Origin of sector
        var isColl = true;
        
        for ( i in 0...actives.size ) {
            e = actives.get( i );
            
            posCmp = posMapper.get( e );
            posCmp.dp = posCmp.dp.scale( 0.8 );
            newPos = posCmp.pos.add( posCmp.dp );
                        
            // If entity is in an adjacent and nested region to the sector, add this region to player pos
            var sectorRegionCmp = regionMapper.get( posCmp.sector );
            
            for ( re in sectorRegionCmp.adj ) {
                var adjRegionCmp = regionMapper.get( re );
                var polys = adjRegionCmp.polys;
                
                for ( p in polys ) {
                    if ( !posCmp.regionsIn.exists( function( v ) { return re.id == v.id; } ) && p.isPointinPolygon( Util.sectorCoords( posCmp.pos, posCmp.sector, re ) ) ) {
                        posCmp.regionsIn.push( re );
                        adjRegionCmp.onEnter( e, posCmp.sector );
                        
                    }
                }
            }
            
            // Must reset for each entity
            var minDist = Math.POSITIVE_INFINITY; 
            var dist = 0.0;
            var minVec = newPos.clone();
            var minSector = posCmp.sector;
            isColl = true;

            // Check if entity is in an adjacent region to its nested region (i.e. new sector)
            for ( re in posCmp.regionsIn ) {
                var reRegionCmp = regionMapper.get( re );
                var regions = reRegionCmp.adj;
                
                if ( !reRegionCmp.isOpen ) {
                    continue;
                }
                
                var str = "";
                for ( adj in regions ) {
                    str += adj.id + ", ";
                }
                trace( str );
                // This is actual loop that grabs adjacent sectors to current portal
                for ( adj in regions ) {
                    var adjRegionCmp = regionMapper.get( adj );
                    var polys = adjRegionCmp.polys;
                    
                    for ( p in polys ) {
                        minVec = Util.sectorCoords( newPos, posCmp.sector, adj );
                        if ( p.isPointinPolygon( minVec ) ) {
                            isColl = false;
                            minSector = adj;                            
                            posCmp.regionsIn.clear(); // todo Add exit first
                            break;  
                        } else {
                            // Get distance between newPos and closest polygon for determining closest sector
                            var np = Util.sectorCoords( newPos, posCmp.sector, adj );
                            collPoint = p.getClosestPoint( np );
                            dist = collPoint.sub( np ).lengthsq();

                            if ( dist < minDist ) {
                                minDist = dist;
                                minVec = Util.sectorCoords( collPoint, posCmp.sector, adj );
                                minSector = adj;
                            }
                        }
                    }
                    if ( !isColl ) { break; } // I wish haxe had a goto
                }
                if ( !isColl ) { break; }
            }
            
            // Check for collisions within local sector
            if ( isColl ) {
                sectorPolys = sectorRegionCmp.polys;
                for ( p in sectorPolys ) {
                    if ( p.isPointinPolygon( newPos ) ) {
                        isColl = false;
                        minVec = newPos.clone();
                        break;
                    }
                }
                
                // If the position is out of bounds, move it to closest valid location
                if ( isColl ) {
                    for ( p in sectorPolys ) {
                        collPoint = p.getClosestPoint( newPos );
                        dist = collPoint.sub( newPos ).lengthsq();
                        if ( dist < minDist ) {
                            minDist = dist;
                            minVec = collPoint.clone();
                            minSector = posCmp.sector;
                        }
                    }
                }
            }
            
            // Handle new sector transition
            if ( minSector != posCmp.sector ) {
                minVec = Util.sectorCoords( newPos, posCmp.sector, minSector );
                posCmp.sector = minSector;
                while ( !posCmp.regionsIn.isEmpty() ) {
                    regionMapper.get( posCmp.regionsIn.pop() ).onExit( e, posCmp.sector );
                }
            }
            
            newPos = minVec;
            posCmp.pos = newPos;
            
            // Check if entity is no  an adjacent region to its nested region (i.e. new sector)
            for ( re in posCmp.regionsIn ) {
                var regionCmp = regionMapper.get( re );
                var polys = regionCmp.polys;
                
                for ( p in polys ) {
                    if ( !p.isPointinPolygon( Util.localCoords( posCmp.pos, re ) ) ) {
                        regionCmp.onExit( e, posCmp.sector );
                        posCmp.regionsIn.remove( re );
                    }
                }
            }   
        }
    }
    var once = true;

    var posMapper : ComponentMapper<PosCmp>;
    var regionMapper : ComponentMapper<RegionCmp>;

}
