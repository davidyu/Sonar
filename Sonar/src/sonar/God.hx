package sonar;
import com.artemisx.Aspect;
import com.artemisx.Entity;
import com.artemisx.World;
import flash.display.MovieClip;
import flash.events.Event;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFieldType;
import flash.ui.Keyboard;
import flash.system.Security;
import sonar.components.ClientCmp;
import sonar.components.CmdQueue;
import sonar.components.ControllerCmp;
import sonar.components.PosCmp;
import sonar.components.ReticuleCmp;
import sonar.components.TakeCmp;
import sonar.managers.ContainerMgr;
import sonar.managers.NameRegistry;
import sonar.systems.CameraSys;
import sonar.systems.ClientSys;
import sonar.systems.CmdProcessSys;
import sonar.systems.ControllerSys;
import sonar.systems.DestructionSys;
import sonar.systems.ExplosionSys;
import sonar.systems.EntityAssemblySys;
import sonar.systems.InputSys;
import sonar.systems.GridSys;
import sonar.systems.PhysicsSys;
import sonar.systems.PosTrackerSys;
import sonar.systems.ReticuleSys;
import sonar.systems.RenderExplosionSys;
import sonar.systems.RenderHUDSys;
import sonar.systems.RenderSonarSys;
import sonar.systems.RenderSectorSys;
import sonar.systems.RenderGridSys;
import sonar.systems.RenderReticuleSys;
import sonar.systems.RenderSys;
import sonar.systems.RenderTorpedoSys;
import sonar.systems.RenderTrailSys;
import sonar.systems.RenderTraceSys;
import sonar.systems.SyncSys;
import sonar.systems.SonarSys;
import sonar.systems.TorpedoSys;
import sonar.systems.TraceSys;
import sonar.systems.TrailSys;
import sonar.systems.TransitRequestSys;
import sonar.systems.UIPhysicsSys;
import utils.Key;
import utils.Math2;
import utils.Polygon;
import utils.Vec2;

class God
{
    @:isVar public var world ( default, null ) : World;
    @:isVar public var entityAssembler ( default, null ): EntityAssemblySys;
    @:isVar public var entityDeserializer ( default, null ) : EntityDeserializer;

    public function new( r : MovieClip, q : h2d.Sprite ) {
        root = r;
        quad = q;

        root.stage.addEventListener( flash.events.KeyboardEvent.KEY_DOWN, onEnterKey );
        f = 0;
        root.addEventListener( flash.events.Event.ENTER_FRAME, tick );

        setupDebugConsole();

        world = new World();
        initializeSystems();

        Util.init( this );

        entityDeserializer = new EntityDeserializer( this );

        initializeEntities();
    }

    public function initializeSystems() : Void {
        var cm = new ContainerMgr();
        cm.registerAspect( "item", Aspect.getAspectForAll( [TakeCmp] ) );
        cm.registerAspect( "char", Aspect.getAspectForAll( [CmdQueue, PosCmp] ) );
        cm.registerAspect( "ret", Aspect.getAspectForAll( [ReticuleCmp] ) );

        world.setManager( cm );

        // don't really need these anymore; take them out
        world.setManager( new NameRegistry() ); // Needs to be last

        entityAssembler = world.setSystem( new EntityAssemblySys() );
        world.setSystem( new PosTrackerSys() ); // should be before anything that explicitly updates PosCmp
        world.setSystem( new CameraSys() );
        world.setSystem( new ClientSys( this ) );
        world.setSystem( new InputSys() );
        world.setSystem( new ControllerSys( this ) ); // this must follow InputSys to apply effects of controller states
        world.setSystem( new DestructionSys() );
        world.setSystem( new GridSys() );
        world.setSystem( new PhysicsSys() );
        world.setSystem( new CmdProcessSys() );
        world.setSystem( new ExplosionSys() );
        world.setSystem( new RenderGridSys( quad ) );
        world.setSystem( new ReticuleSys() );
        world.setSystem( new RenderExplosionSys( quad ) );
        world.setSystem( new RenderSectorSys( root ) );
        world.setSystem( new RenderSonarSys( quad ) );
        world.setSystem( new RenderTrailSys( quad ) );
        world.setSystem( new RenderSys( quad ) );
        world.setSystem( new RenderTorpedoSys( quad ) );
        world.setSystem( new RenderTraceSys( quad ) );
        world.setSystem( new RenderReticuleSys( quad ) );
        world.setSystem( new RenderHUDSys( this, quad ) );
        world.setSystem( new SyncSys() );
        world.setSystem( new SonarSys() );
        world.setSystem( new TorpedoSys() );
        world.setSystem( new TraceSys() );
        world.setSystem( new TrailSys() );
        world.setSystem( new UIPhysicsSys() );

        world.delta = 1000 / ( root.stage.frameRate ); //this is gross!
        world.initialize();
    }

    public function initializeEntities() : Void {
        sectors = new Array();
        netPlayers = new Array();

        /*
         * map: square
         *           +-------+
         *           |       |
         * +---+     |       |     +---+
         * |   |-----|       |-----|   |
         * +---+     |       |     +---+
         *           |       |
         *           +-------+
        */

        var hammer = Vec2.getVecArray( [ 144, 144, 256, 144, /* p2 */ 426, 225, 448, 225, 500, 144,
                                    /* p5 */ 780, 144, 832, 225, 854, 225, /* p8 */ 1024, 144, 1136, 144,
                                    /* p10 */ 1136, 360, 1024, 360, 854, 279, /* p13 */ 660, 279,
                                    /* p14 */ 660, 576, 620, 576, 620, 279, /* p17 */ 426, 279,
                                    /* p18 */ 256, 360, 144, 360, 144, 144 ] );

        var baseSquare = Vec2.getVecArray( [ 144, 144,
                                             744, 144,
                                             744, 744,
                                             144, 744,
                                             144, 144 ] );

        var innerSquare = Vec2.getVecArray( [ 600, 600,
                                              650, 600,
                                              650, 650,
                                              600, 650,
                                              600, 600 ] );

        sectors.push( entityAssembler.createVirtualSector( "sector0", new Vec2( 0, 0 ), [ new Polygon( baseSquare ), new Polygon( baseSquare ) ] ) );

#if ( local )
        Security.loadPolicyFile( "xmlsocket://localhost:10000" );
        client = entityAssembler.createClient( "localhost", 5000 );
#else
        Security.loadPolicyFile( "xmlsocket://sonargame.cloudapp.net:10000" );
        client = entityAssembler.createClient( "sonargame.cloudapp.net", 5000 );
#end
        entityAssembler.createGridReferenceBound( sectors[0], new Vec2( 0, 0 ) );
    }

    public function tick( _ ) : Void {
        world.process();
    }

    function onEnterKey( e : flash.events.KeyboardEvent ) : Void {
    }

    //debugger console methods
    public function setupDebugConsole() : Void {
        baseTextFormat = new TextFormat();
        baseTextFormat.font = "Helvetica";
        baseTextFormat.size = 24;

        inputTextfield = new TextField();
        inputTextfield.type = TextFieldType.INPUT;
        inputTextfield.width = root.stage.stageWidth;
        inputTextfield.height = 50;
        inputTextfield.y = root.stage.stageHeight - inputTextfield.height;
        inputTextfield.defaultTextFormat = baseTextFormat;
        inputTextfield.background = false;
        inputTextfield.textColor = 0xffffff;

        root.addChild( inputTextfield );

        outputTextfield = new TextField();
        outputTextfield.type = TextFieldType.DYNAMIC;
        outputTextfield.defaultTextFormat = baseTextFormat;
        outputTextfield.width = root.stage.stageWidth;
        outputTextfield.height = root.stage.stageHeight - inputTextfield.height;
        outputTextfield.textColor = 0xffffff;

        root.addChild( outputTextfield );
    }

    public function debugPrint( str ) {
        outputTextfield.text += str;
    }

    public function debugPrintln( str, ?fromInput=false ) {
        var prefix = " →  ";

        if ( fromInput ) {
            prefix = " ←  ";
        }

        debugPrint( prefix + str + "\n" );
    }

    public function debugClear() {
        outputTextfield.text = "";
    }


    var f : UInt;

    var root : MovieClip;
    var quad : h2d.Sprite;
    var inputTextfield : TextField;
    var baseTextFormat : TextFormat;

    public var outputTextfield : TextField;
    public var sectors : Array<Entity>;
    public var player : Entity;
    public var client : Entity;

    public var netPlayers : Array<Entity>;
}

typedef P2 = { p1 : Entity, p2 : Entity };
