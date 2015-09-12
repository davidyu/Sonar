package sonar.systems;

import com.artemisx.Aspect;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import com.artemisx.EntitySystem;
import com.artemisx.utils.Bag;

import sonar.components.DestructibleCmp;
import sonar.components.InputCmp;
import sonar.components.NetworkPlayerCmp;
import sonar.components.PosCmp;
import sonar.components.RegionCmp;
import sonar.components.ExplosionCmp;
import sonar.components.TimedEffectCmp;
import sonar.managers.ContainerMgr;

import utils.Geo;
import utils.Polygon;
import gml.vector.Vec2f;
import utils.Math2;

class ExplosionSys extends EntitySystem
{
    public function new() {
        super( Aspect.getAspectForAll( [PosCmp, ExplosionCmp, TimedEffectCmp] ) );
    }

    override public function initialize() : Void {
        destructibleMapper = world.getMapper( DestructibleCmp );
        posMapper          = world.getMapper( PosCmp );
        timedEffectMapper  = world.getMapper( TimedEffectCmp );
        explosionMapper    = world.getMapper( ExplosionCmp );
        regionMapper       = world.getMapper( RegionCmp );
        containerMgr       = world.getManager( ContainerMgr );
    }

    override public function processEntities( entities : Bag<Entity> ) : Void  {
        var e : Entity;

        var time : TimedEffectCmp;
        var explosion : ExplosionCmp;
        var center : Vec2f;
        var sector : Entity;

        for ( i in 0...actives.size ) {
            e = actives.get( i );
            time = timedEffectMapper.get( e );
            explosion = explosionMapper.get( e );
            center = posMapper.get( e ).pos;

            switch( time.processState ) {
                case Process( false ):
                    var radius : Float = explosion.growthRate * ( time.internalAcc / 1000.0 );
                    if ( radius > explosion.maxRadius ) {
                        radius = explosion.maxRadius;
                    }

                    var sector = posMapper.get( e ).sector;

                    // check for collision against player entities
                    for ( e in containerMgr.getAllEntitiesOfContainer( sector ) ) {
                        var p : Vec2f = posMapper.get( e ).pos;
                        if ( Geo.isPointInCircle( { center: center, radius: radius }, p ) ) {
                            var d = destructibleMapper.get( e );
                            if ( d != null ) {
                                switch ( d.state ) {
                                    case Normal( _ ) : d.state = Destroyed;
                                    default:
                                }
                            }
                        }
                    }

                    time.processState = Processed;
                case Process( true ): //expiring sonar, clear its obscuredRange array
                    time.processState = Processed;
                default:
            } // end switch on time.processState (wow! how gross!)
        }
    }

    var timedEffectMapper  : ComponentMapper<TimedEffectCmp>;
    var explosionMapper    : ComponentMapper<ExplosionCmp>;
    var posMapper          : ComponentMapper<PosCmp>;
    var regionMapper       : ComponentMapper<RegionCmp>; // need to extract region polys from sector
    var destructibleMapper : ComponentMapper<DestructibleCmp>; // need to extract region polys from sector

    var containerMgr      : ContainerMgr;
}
