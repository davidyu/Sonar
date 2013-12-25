package gibber.systems;

import com.artemisx.Aspect;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import com.artemisx.EntitySystem;
import com.artemisx.utils.Bag;

import gibber.components.BounceCmp;
import gibber.components.PosCmp;
import gibber.components.RegionCmp;
import gibber.components.RenderCmp;
import gibber.components.TimedEffectCmp;
import gibber.components.TrailCmp;
import gibber.components.TraceCmp;

import utils.Geo;
import utils.Polygon;
import utils.Vec2;
import utils.Math2;

class TrailSys extends EntitySystem
{
    public function new() {
        super( Aspect.getAspectForAll( [PosCmp, BounceCmp, TrailCmp, TimedEffectCmp] ) );
    }

    override public function initialize() : Void {
        posMapper         = world.getMapper( PosCmp );
        timedEffectMapper = world.getMapper( TimedEffectCmp );
        trailMapper       = world.getMapper( TrailCmp );
        regionMapper      = world.getMapper( RegionCmp );
        bounceMapper      = world.getMapper( BounceCmp );
    }

    override public function processEntities( entities : Bag<Entity> ) : Void  {
        var e : Entity;
        var time : TimedEffectCmp;
        var trail : TrailCmp;
        var pos : PosCmp;
        var bounce : BounceCmp;

        for ( i in 0...actives.size ) {
            e   = actives.get( i );
            time = timedEffectMapper.get( e );
            trail = trailMapper.get( e );
            pos = posMapper.get( e );
            bounce = bounceMapper.get( e );

            switch( time.processState ) {
                case Process( _ ):
                    switch ( bounce.bounced ) {
                        case JustBounced( a, b ):
                            //create trace
                            bounce.bounced = NoBounce;
                            createTrace( posMapper.get( pos.sector ).pos, Line( a, b ) );
                        default:
                    }
                    time.processState = Processed;
                default:
            }
        }
    }

    // creates a beautiful trace entity
    private function createTrace( pos : Vec2, displayType : IntersectResult ) {
        if ( displayType != None ) {
            var e = world.createEntity();

            var renderCmp = new RenderCmp( 0xffffff );
            var traceCmp = new TraceCmp( 0.5, displayType, pos );
            var timedEffectCmp = new TimedEffectCmp( 0, GlobalTickInterval );

            e.addComponent( renderCmp );
            e.addComponent( traceCmp );
            e.addComponent( timedEffectCmp );

            world.addEntity( e );
        }
    }

    var timedEffectMapper : ComponentMapper<TimedEffectCmp>;
    var trailMapper       : ComponentMapper<TrailCmp>;
    var posMapper         : ComponentMapper<PosCmp>;
    var bounceMapper      : ComponentMapper<BounceCmp>;
    var regionMapper      : ComponentMapper<RegionCmp>; // need to extract region polys from sector
}
