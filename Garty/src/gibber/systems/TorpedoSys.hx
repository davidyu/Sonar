package gibber.systems;

import com.artemisx.Aspect;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import com.artemisx.EntitySystem;
import com.artemisx.utils.Bag;

import gibber.components.TorpedoCmp;
import gibber.components.PosCmp;
import gibber.components.BounceCmp;

class TorpedoSys extends EntitySystem
{
    public function new() {
        super( Aspect.getAspectForAll( [TorpedoCmp, PosCmp] ) );
    }

    override public function initialize() : Void {
        torpedoMapper = world.getMapper( TorpedoCmp );
        posMapper     = world.getMapper( PosCmp );
        bounceMapper  = world.getMapper( BounceCmp );
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

            pos.dp = pos.dp.add( torpedo.target.sub( pos.pos ).normalize().mul( torpedo.accel ) ); // need to tweak tweak tweak

            if ( pos.dp.lengthsq() > torpedo.maxSpeed * torpedo.maxSpeed ) {
                pos.dp = pos.dp.normalize().mul( torpedo.maxSpeed );
            }

            switch ( bounce.lastTouched ) {
                case Edge( _, _ ):
                    world.deleteEntity( e );
                    return;
                default: 
            }
        }
    }

    var torpedoMapper : ComponentMapper<TorpedoCmp>;
    var posMapper     : ComponentMapper<PosCmp>;
    var bounceMapper  : ComponentMapper<BounceCmp>;
}
