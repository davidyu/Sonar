package sonar.systems;

import com.artemisx.Aspect;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import com.artemisx.EntitySystem;
import com.artemisx.utils.Bag;

import sonar.components.TorpedoCmp;
import sonar.components.PosCmp;
import sonar.components.BounceCmp;

import sonar.systems.EntityAssemblySys;

import utils.Math2;
import gml.vector.Vec2f;

class TorpedoSys extends EntitySystem
{
    public function new() {
        super( Aspect.getAspectForAll( [TorpedoCmp, PosCmp] ) );
    }

    override public function initialize() : Void {
        torpedoMapper   = world.getMapper( TorpedoCmp );
        posMapper       = world.getMapper( PosCmp );
        bounceMapper    = world.getMapper( BounceCmp );
        entityAssembler = world.getSystem( EntityAssemblySys );
    }

    override public function processEntities( entities : Bag<Entity> ) : Void  {
        var e : Entity;
        var pos : PosCmp;
        var torpedo : TorpedoCmp;
        var bounce : BounceCmp;

        for ( i in 0...actives.size ) {
            e = actives.get( i );
            torpedo = torpedoMapper.get( e );
            pos = posMapper.get( e );
            bounce = bounceMapper.get( e );

            var target : Vec2f = switch ( torpedo.target ) {
                case StaticTarget( t ) : t;
                case DynamicTarget( e ) : posMapper.get( e ).pos;
            }

            pos.dp = pos.dp + ( torpedo.accel * ( ( target - pos.pos ).normalize() ) ); // need to tweak tweak tweak

            if ( pos.dp.lensq() > torpedo.maxSpeed * torpedo.maxSpeed ) {
                pos.dp = torpedo.maxSpeed * pos.dp.normalize();
            }

            // destruction conditions
            // met target
            if ( ( pos.pos - target ).lensq() <= 25.0 ) {
                world.deleteEntity( e );
                entityAssembler.createExplosionEffect( pos.sector, pos.pos );
                return;
            }

            switch ( bounce.lastTouched ) {
                case Edge( _, _ ):
                    world.deleteEntity( e );
                    entityAssembler.createExplosionEffect( pos.sector, pos.pos );
                    return;
                default: 
            }
        }
    }

    var torpedoMapper    : ComponentMapper<TorpedoCmp>;
    var posMapper        : ComponentMapper<PosCmp>;
    var bounceMapper     : ComponentMapper<BounceCmp>;
    var entityAssembler  : EntityAssemblySys;
}
