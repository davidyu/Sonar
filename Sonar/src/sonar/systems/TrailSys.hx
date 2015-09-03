package sonar.systems;

import com.artemisx.Aspect;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import com.artemisx.EntitySystem;
import com.artemisx.utils.Bag;

import sonar.components.BounceCmp;
import sonar.components.PosCmp;
import sonar.components.RegionCmp;
import sonar.components.RenderCmp;
import sonar.components.TimedEffectCmp;
import sonar.components.TrailCmp;
import sonar.components.TraceCmp;
import sonar.components.UICmp;
import sonar.managers.ContainerMgr;
import sonar.systems.EntityAssemblySys;

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
        entityAssembler   = world.getSystem( EntityAssemblySys );
        containerMgr      = world.getManager( ContainerMgr );
    }

    override public function processEntities( entities : Bag<Entity> ) : Void  {
        var e : Entity;
        var time : TimedEffectCmp;
        var trail : TrailCmp;
        var pos : PosCmp;
        var bounce : BounceCmp;
        var sector : Entity;

        for ( i in 0...actives.size ) {
            e   = actives.get( i );
            time = timedEffectMapper.get( e );
            trail = trailMapper.get( e );
            pos = posMapper.get( e );
            bounce = bounceMapper.get( e );
            sector = posMapper.get( e ).sector;

            switch( time.processState ) {
                case Process( _ ):
                    for ( e in containerMgr.getAllEntitiesOfContainer( sector ) ) {
                        if ( e.id == trail.playerId ) continue; //skip me
                        if ( e.getComponent( UICmp ) != null ) continue; // skip UI components
                        var p : Vec2 = posMapper.get( e ).pos;
                        if ( Geo.isPointInCircle( { center: p, radius: 6 }, pos.pos ) ) {
                            entityAssembler.createTrace( sector, Mass( p, 3 ) );
                            // bounce back
                            pos.dp = pos.dp.mul( -1 );
                        }
                    }

                    switch ( bounce.lastTouched ) {
                        case Edge( a, b, collisionPt ):
                            // create trace
                            var toA = a.sub( collisionPt ).normalize();
                            var toB = b.sub( collisionPt ).normalize();
                            var traceLen = 40.0;

                            var aa = collisionPt.add( toA.mul( traceLen / 2 ) );
                            var bb = collisionPt.add( toB.mul( traceLen / 2 ) );

                            // bb overshot
                            if ( b.sub( aa ).lengthsq() < bb.sub( aa ).lengthsq() ) bb = b;

                            // aa overshot
                            if ( a.sub( bb ).lengthsq() < aa.sub( bb ).lengthsq() ) aa = a;

                            entityAssembler.createTrace( pos.sector, Line( aa, bb ) );

                            // reset last touched so we don't create it again
                            bounce.lastTouched = Nothing;
                        default:
                    }
                    time.processState = Processed;
                default:
            }
        }
    }

    var timedEffectMapper : ComponentMapper<TimedEffectCmp>;
    var trailMapper       : ComponentMapper<TrailCmp>;
    var posMapper         : ComponentMapper<PosCmp>;
    var bounceMapper      : ComponentMapper<BounceCmp>;
    var regionMapper      : ComponentMapper<RegionCmp>; // need to extract region polys from sector

    var entityAssembler   : EntityAssemblySys;

    var containerMgr      : ContainerMgr;
}
