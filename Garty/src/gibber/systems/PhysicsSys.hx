package gibber.systems;
import com.artemisx.Aspect;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import com.artemisx.EntitySystem;
import com.artemisx.utils.Bag;
import gibber.components.PosCmp;
import gibber.components.RegionCmp;
import utils.Polygon;
import utils.Vec2;

class PhysicsSys extends EntitySystem
{
    public function new() {
        super( Aspect.getAspectForAll( [PosCmp] ) );
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
        var dist = 0.0;
        var minVec = new Vec2();
        var minDist = Math.POSITIVE_INFINITY;
        var isColl = true;
        
        for ( i in 0...actives.size ) {
            e = actives.get( i );
            
            posCmp = posMapper.get( e );
            posCmp.dp = posCmp.dp.scale( 0.8 );
            sectorPos = regionMapper.get( posCmp.sector ).pos;
            pos = posCmp.pos; // transform player pos in sector-local coord system
            newPos = pos.add( posCmp.dp );
            
            sectorPolys = regionMapper.get( posCmp.sector ).polys;
            
            for ( j in 0...sectorPolys.length ) {
                if ( sectorPolys[j].isPointinPolygon( newPos ) ) {
                    isColl = false;
                }
            }
            if ( isColl ) {
                for ( i in 0...sectorPolys.length ) {
                    collPoint = sectorPolys[i].getClosestPoint( newPos );
                    trace( collPoint );
                    dist = collPoint.sub( newPos ).lengthsq();
                    if ( dist < minDist ) {
                        minDist = dist;
                        minVec = collPoint;
                    }
                }
                trace("end" + minVec + newPos );
                newPos = minVec;
            }
            posCmp.pos = newPos;
            
            
        }
    }
    var once = true;

    var posMapper : ComponentMapper<PosCmp>;
    var regionMapper : ComponentMapper<RegionCmp>;

}