package sonar.systems;

import com.artemisx.Aspect;
import com.artemisx.Component;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import com.artemisx.EntitySystem;
import com.artemisx.World;

import flash.utils.IDataInput2;
import flash.ui.Keyboard;

import sonar.components.ContainableCmp;
import sonar.components.StaticPosCmp;
import sonar.components.BoundCmp;
import sonar.components.BounceCmp;
import sonar.components.CameraCmp;
import sonar.components.ContainerCmp;
import sonar.components.ControllerCmp;
import sonar.components.ClientCmp;
import sonar.components.DestructibleCmp;
import sonar.components.InventoryCmp;
import sonar.components.InputCmp;
import sonar.components.ExplosionCmp;
import sonar.components.LookCmp;
import sonar.components.NameIdCmp;
import sonar.components.NetworkPlayerCmp;
import sonar.components.PosCmp;
import sonar.components.PosTrackerCmp;
import sonar.components.RegionCmp;
import sonar.components.RenderCmp;
import sonar.components.ReticuleCmp;
import sonar.components.SonarCmp;
import sonar.components.SyncCmp;
import sonar.components.TorpedoCmp;
import sonar.components.TraceCmp;
import sonar.components.TrailCmp;
import sonar.components.TimedEffectCmp;
import sonar.components.UICmp;
import sonar.managers.ContainerMgr;
import utils.Polygon;
import utils.Vec2;

using Lambda;

class EntityAssemblySys extends EntitySystem
{
    public function new() {
        super( Aspect.getEmpty() );
    }

    override public function initialize() : Void {
        containerMgr = world.getManager( ContainerMgr );
        regionMapper = world.getMapper( RegionCmp );
        posMapper = world.getMapper( PosCmp );
    }

    public function createNetworkPlayer( name: String, sector: Entity, position: Vec2, id: UInt ): Entity {
        var player = createPlayer( name, sector, position );
        var npCmp = new NetworkPlayerCmp( id );
#if ( debug && local )
        // render the network player in debug-local builds
#else
        player.removeComponent( RenderCmp ); // do not render the network player!
#end
        player.removeComponent( InputCmp ); // do not control the network player!
        player.removeComponent( SyncCmp ); // do not sync the network player!
        player.addComponent( npCmp );
        return player;
    }

    public function createPlayer( name: String, sector: Entity, position: Vec2 ): Entity {
        var e = world.createEntity();
        var lookCmp = new LookCmp();
        var nameCmp = new NameIdCmp( name );
        var posCmp = new PosCmp( sector, position );
        var renderCmp = new RenderCmp();
        var syncCmp = new SyncCmp();
        var controllerCmp = new ControllerCmp();
        var inventoryCmp = new InventoryCmp();
        var inputCmp = new InputCmp( Keyboard.UP, Keyboard.DOWN, Keyboard.LEFT, Keyboard.RIGHT,
                                     Keyboard.SPACE, Keyboard.SLASH, Keyboard.SHIFT, 1 );
        var containableCmp = new ContainableCmp( containerMgr, e, sector );
        var destructibleCmp = new DestructibleCmp( 1 );

        e.addComponent( lookCmp );
        e.addComponent( nameCmp );
        e.addComponent( posCmp );
        e.addComponent( renderCmp );
        e.addComponent( inventoryCmp );
        e.addComponent( inputCmp );
        e.addComponent( syncCmp );
        e.addComponent( containableCmp );
        e.addComponent( controllerCmp );
        e.addComponent( destructibleCmp );

        world.addEntity( e );

        return e;
    }

    public function createReticule( sector: Entity, player: Entity, start : Vec2 ) {
        var e = world.createEntity();
        var posCmp = new PosCmp( sector, start );
        var nameCmp = new NameIdCmp( "reticle" );
        var reticuleCmp = new ReticuleCmp( player );
        var renderCmp = new RenderCmp();
        var uiCmp = new UICmp();
        var containableCmp = new ContainableCmp( containerMgr, e, sector );

        e.addComponent( posCmp );
        e.addComponent( reticuleCmp );
        e.addComponent( renderCmp );
        e.addComponent( uiCmp );
        e.addComponent( nameCmp );
        e.addComponent( containableCmp );

        world.addEntity( e );

        return e;
    }

    public function createTorpedo( id : Int, target : TorpedoTarget, sector : Entity, origin : Vec2 ) : Entity {
        var e = world.createEntity();

        var posCmp = new PosCmp( sector, origin );
        var torpedoCmp = new TorpedoCmp( id, target, 2, 100 );
        var renderCmp = new RenderCmp();
        var bounceCmp = new BounceCmp( 1.0 );
        var posTrackerCmp = new PosTrackerCmp( LastPos );

        e.addComponent( posCmp );
        e.addComponent( torpedoCmp );
        e.addComponent( renderCmp );
        e.addComponent( bounceCmp );
        e.addComponent( posTrackerCmp );

        world.addEntity( e );
        return e;
    }

    // Look into this: I don't care about which sector I'm in when I'm creating a Sonar wave. It should ideally be inferred.
    public function createSonar( id : Int, sector : Entity, pos : Vec2 ) : Entity {
        var e = world.createEntity();

        var sonarCmp = new SonarCmp( id, 100.0, 100 );
        var posCmp = new PosCmp( sector, pos );
        var timedEffectCmp = new TimedEffectCmp( 1000, GlobalTickInterval );
        var renderCmp = new RenderCmp( 0xffffff );

        e.addComponent( timedEffectCmp );
        e.addComponent( sonarCmp );
        e.addComponent( posCmp );
        e.addComponent( renderCmp );

        world.addEntity( e );

        return e;
    }

    public function createExplosionEffect( sector : Entity, pos : Vec2 ) : List<Entity> {
        var explosions = new List<Entity>();
        var mainExplosion = createSingleExplosion( sector, pos, 20, Math.random() * 30 + 20 ) ;
        explosions.add( mainExplosion );
        for ( i in 0...Std.int( Math.random() * 4 ) ) {
            var e = createSingleExplosion( sector, pos.add( new Vec2( Math.random() * 40 - 20, Math.random() * 40 - 20 ) ), 7, Math.random() * 5 + 5 ) ;
            explosions.add( e );
        }
        return explosions;
    }

    public function createSingleExplosion( sector : Entity, pos : Vec2, ?growthRate : Float, ?size : Float ) : Entity {
        var e = world.createEntity();

        var explosionCmp = new ExplosionCmp( growthRate == null ? Math.random() * 15 + 15 : growthRate, size == null ? Math.random() * 30 + 20 : size );
        var staticPosCmp = new StaticPosCmp();
        var posCmp = new PosCmp( sector, pos );
        var timedEffectCmp = new TimedEffectCmp( 1000, GlobalTickInterval );
        var renderCmp = new RenderCmp( 0xffffff );

        e.addComponent( timedEffectCmp );
        e.addComponent( explosionCmp );
        e.addComponent( staticPosCmp );
        e.addComponent( posCmp );
        e.addComponent( renderCmp );

        world.addEntity( e );

        return e;
    }

    public function createClient( host : String, port : UInt ) {
        var e = world.createEntity();
        var client = new ClientCmp( host, port );

        e.addComponent( client );

        world.addEntity( e );

        return e;
    }

    // ugh: bad parameters again; see above.
    public function createSonarBeam( id : Int, sector : Entity, pos: Vec2, direction : Vec2 ) : Entity {
        var e = world.createEntity();

        var posCmp = new PosCmp( sector, pos, true );
        var posTrackerCmp = new PosTrackerCmp( LastPos );
        posCmp.dp = direction.normalize().mul( 9.0 );
        var trailCmp = new TrailCmp( id, direction );
        var timedEffectCmp = new TimedEffectCmp( 2000, GlobalTickInterval );
        var renderCmp = new RenderCmp( 0xffffff );
        var bounceCmp = new BounceCmp( 1.0 );

        e.addComponent( timedEffectCmp );
        e.addComponent( trailCmp );
        e.addComponent( posCmp );
        e.addComponent( posTrackerCmp );
        e.addComponent( renderCmp );
        e.addComponent( bounceCmp );

        world.addEntity( e );

        return e;
    }

    public function createCamera( sector: Entity, pos: Vec2, ?target : Entity ) {
        var e = world.createEntity();

        var posCmp = new PosCmp( sector, pos );
        var camCmp = new CameraCmp( target == null ? StaticTarget( pos, sector ) : DynamicTarget( target ) );

        e.addComponent( posCmp );
        e.addComponent( camCmp );
        world.addEntity( e );
    }

    public function createGridReferenceBound( sector : Entity, pos : Vec2 ) {
        var e = world.createEntity();

        var renderCmp = new RenderCmp( 0x34608D );
        var posCmp = new PosCmp( sector, pos );
        var boundCmp = new BoundCmp( Rect( 20, 20 ) );

        e.addComponent( renderCmp );
        e.addComponent( posCmp );
        e.addComponent( boundCmp );

        world.addEntity( e );
    }

    public function createTrace( sector : Entity, traceType : TraceType ) {
        var e = world.createEntity();

        var renderCmp = new RenderCmp( 0xffffff );
        var posCmp = new PosCmp( sector, new Vec2( 0, 0 ) );
        var traceCmp = new TraceCmp( 0.8, traceType );
        var timedEffectCmp = new TimedEffectCmp( 1000, GlobalTickInterval );

        e.addComponent( renderCmp );
        e.addComponent( posCmp );
        e.addComponent( traceCmp );
        e.addComponent( timedEffectCmp );

        world.addEntity( e );
    }

    // returns a sector without the RenderCmp
    public function createVirtualSector( name : String, pos : Vec2, polygonAreas : Array<Polygon> ) : Entity {
        var e = createSector( name, pos, polygonAreas ).removeComponent( RenderCmp );
        return e;
    }

    public function createSector( name : String, pos : Vec2, polygonAreas : Array<Polygon> ) : Entity {
        var e = world.createEntity();
        var nameCmp = new NameIdCmp( name );
        var posCmp = new PosCmp( e, pos );
        var staticCmp = new StaticPosCmp();
        var lookCmp = new LookCmp();
        var regionCmp = new RegionCmp( polygonAreas );
        var renderCmp = new RenderCmp( 0x00ffff );
        var containerCmp = new ContainerCmp();

        lookCmp.lookText = "This is some room #" + Std.random(1000);

        e.addComponent( nameCmp );
        e.addComponent( posCmp );
        e.addComponent( staticCmp );
        e.addComponent( lookCmp );
        e.addComponent( regionCmp );
        e.addComponent( renderCmp );
        e.addComponent( containerCmp );

        world.addEntity( e );

        return e;
    }

    public function createEntityWithCmps( cmps : List<Component> ) {
        var e = world.createEntity();

        for ( cmp in cmps ) {
            e.addComponent( cmp );
        }

        world.addEntity( e );
        return e;
    }

    var containerMgr : ContainerMgr;
    var regionMapper : ComponentMapper<RegionCmp>;
    var posMapper : ComponentMapper<PosCmp>;
}
