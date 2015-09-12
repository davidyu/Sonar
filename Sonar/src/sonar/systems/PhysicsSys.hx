package sonar.systems;

import com.artemisx.Aspect;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import com.artemisx.EntitySystem;
import com.artemisx.utils.Bag;

import sonar.components.BoundCmp;
import sonar.components.BounceCmp;
import sonar.components.CameraCmp;
import sonar.components.PosCmp;
import sonar.components.RegionCmp;
import sonar.components.ReticuleCmp;
import sonar.components.StaticPosCmp;
import sonar.components.UICmp;

import utils.Polygon;
import gml.vector.Vec2f;

using Lambda;
using sonar.Util;
using utils.Geo;
using utils.Math2;

class PhysicsSys extends EntitySystem
{
    public function new() {
        super( Aspect.getAspectForAll( [PosCmp] ).exclude( [StaticPosCmp, CameraCmp, BoundCmp, UICmp] ) );
    }

    override public function initialize() : Void {
        posMapper = world.getMapper( PosCmp );
        regionMapper = world.getMapper( RegionCmp );
    }

    override public function processEntities( entities : Bag<Entity> ) : Void  {
        var e : Entity;
        var posCmp : PosCmp;    // Position component of entity
        var pos;                // Position of entity
        var newPos : Vec2f;      // Projected osition of entity after update
        var collPoint : Vec2f;   // Collision point with wall
        var sectorPolys : Array<Polygon>; // Walls
        var sectorPos : Vec2f;       // Origin of sector
        var isColl = true;

        for ( i in 0...actives.size ) {
            e = actives.get( i );
            posCmp = posMapper.get( e );
            if ( !posCmp.noDamping )
                posCmp.dp = 0.9 * posCmp.dp;
            newPos = posCmp.pos + posCmp.dp;

            // If entity is in an adjacent and nested region to the sector, add this region to player pos
            var sectorRegionCmp = regionMapper.get( posCmp.sector );
            for ( re in sectorRegionCmp.adj ) {
                var adjRegionCmp = regionMapper.get( re );
                var polys = adjRegionCmp.polys;
                for ( p in polys ) {
                    if ( !posCmp.regionsIn.exists( function( v ) { return re.id == v.id; } ) &&
                         p.isPointinPolygon( Util.toSector( SectorCoordinates( posCmp.pos, posCmp.sector ), re ) ) ) {
                        posCmp.regionsIn.push( re );
                        adjRegionCmp.onEnter( e, posCmp.sector );
                    }
                }
            }

            // Must reset for each entity
            var minDist = Math.POSITIVE_INFINITY;
            var dist = 0.0;
            var minVec = new Vec2f( newPos.x, newPos.y );
            var minSector = posCmp.sector;
            isColl = true;

                // Check if entity is in an adjacent region to its nested region (i.e. new sector)
            for ( re in posCmp.regionsIn ) {
                var reRegionCmp = regionMapper.get( re );
                var regions = reRegionCmp.adj;

                if ( !reRegionCmp.isOpen ) {
                    continue;
                }

                // This is actual loop that grabs adjacent sectors to current portal
                for ( adj in regions ) {
                    var adjRegionCmp = regionMapper.get( adj );
                    var polys = adjRegionCmp.polys;

                    for ( p in polys ) {
                        minVec = Util.toSector( SectorCoordinates( newPos, adj ), posCmp.sector );
                        if ( p.isPointinPolygon( minVec ) ) {
                            isColl = false;
                            minSector = adj;
                            posCmp.regionsIn.clear(); // todo Add exit first
                            break;
                        } else {
                            // Get distance between newPos and closest polygon for determining closest sector
                            var np = Util.toSector( SectorCoordinates( newPos, adj ), posCmp.sector );
                            collPoint = p.getClosestPoint( np );
                            dist = ( collPoint - np ).lensq();

                            if ( dist < minDist ) {
                                minDist = dist;
                                minVec = Util.toSector( SectorCoordinates( collPoint, adj ), posCmp.sector );
                                minSector = adj;
                            }
                        }
                    }
                    if ( !isColl ) { break; } // I wish haxe had a goto
                }
                if ( !isColl ) { break; }
            } // END Check if entity is in an adjacent region to its nested region (i.e. new sector)

            // Check for collisions within local sector
            if ( isColl ) {
                sectorPolys = sectorRegionCmp.polys;
                for ( p in sectorPolys ) {
                    if ( p.isPointinPolygon( newPos ) ) {
                        isColl = false;
                        minVec = new Vec2f( newPos.x, newPos.y );
                        break;
                    }
                }

                // If the position is out of bounds, move it to closest valid location
                if ( isColl ) {
                    for ( p in sectorPolys ) {
                        var res = p.getClosestPointAndEdge( newPos );
                        collPoint = Math2.EPSILON * ( ( res.point + res.edge.a - res.edge.b ).orthogonal().normalize() );
                        dist = ( collPoint - newPos ).lensq();
                        if ( dist < minDist ) {
                            minDist = dist;
                            minVec = collPoint;
                            minSector = posCmp.sector;
                            // reflect velocity if entity is a bouncer.
                            if ( e.getComponent( BounceCmp ) != null ) {
                                var edge = res.edge;
                                var dir = edge.a - edge.b;
                                var normal = dir.orthogonal().normalize();
                                var v = posCmp.dp;
                                var refl = v.reflect( normal );
                                posCmp.dp = refl;
                                e.getComponent( BounceCmp ).lastTouched = Edge( edge.a, edge.b, collPoint );
                            }
                        }
                    }
                }
            }

            // Handle new sector transition
            if ( minSector != posCmp.sector ) {
                minVec = Util.toSector( SectorCoordinates( newPos, minSector ), posCmp.sector );
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
                    if ( !p.isPointinPolygon( Util.toSector( WorldCoordinates( posCmp.pos ), re ) ) ) {
                        regionCmp.onExit( e, posCmp.sector );
                        posCmp.regionsIn.remove( re );
                    }
                }
            }

        } // end for ( i in actives.size)
    }
    var once = true;

    var posMapper : ComponentMapper<PosCmp>;
    var regionMapper : ComponentMapper<RegionCmp>;
    var bounceMapper : ComponentMapper<BounceCmp>;
}
