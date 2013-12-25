package gibber.systems;

import com.artemisx.Aspect;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import com.artemisx.EntitySystem;
import com.artemisx.utils.Bag;

import gibber.components.PosCmp;
import gibber.components.RegionCmp;
import gibber.components.RenderCmp;
import gibber.components.TimedEffectCmp;
import gibber.components.TrailCmp;

import utils.Geo;
import utils.Polygon;
import utils.Vec2;
import utils.Math2;

class TrailSys extends EntitySystem
{
    public function new() {
        super( Aspect.getAspectForAll( [PosCmp, TrailCmp, TimedEffectCmp] ) );
    }

    override public function initialize() : Void {
        posMapper         = world.getMapper( PosCmp );
        timedEffectMapper = world.getMapper( TimedEffectCmp );
        trailMapper       = world.getMapper( TrailCmp );
        regionMapper      = world.getMapper( RegionCmp );
    }

    override public function processEntities( entities : Bag<Entity> ) : Void  {
        var e : Entity;
        var time : TimedEffectCmp;
        var trail : TrailCmp;
        var pos : PosCmp;

        for ( i in 0...actives.size ) {
            e   = actives.get( i );
            time = timedEffectMapper.get( e );
            trail = trailMapper.get( e );
            pos = posMapper.get( e );

            switch( time.processState ) {
                case Process( _ ):
                    // get velocity and set poscmp to that velocity
                    time.processState = Processed;
                default:
            }
        }
    }

    var timedEffectMapper : ComponentMapper<TimedEffectCmp>;
    var trailMapper       : ComponentMapper<TrailCmp>;
    var posMapper         : ComponentMapper<PosCmp>;
    var regionMapper      : ComponentMapper<RegionCmp>; // need to extract region polys from sector
}
