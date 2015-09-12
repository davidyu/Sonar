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
import sonar.components.ControllerCmp;
import sonar.components.PosCmp;
import sonar.components.ReticuleCmp;
import sonar.managers.ContainerMgr;
import sonar.systems.CameraSys;
import sonar.systems.ClientSys;
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
import sonar.systems.UIPhysicsSys;
import utils.Key;
import utils.Math2;
import utils.Polygon;
import gml.vector.Vec2f;

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
        cm.registerAspect( "char", Aspect.getAspectForAll( [PosCmp] ) );
        cm.registerAspect( "ret", Aspect.getAspectForAll( [ReticuleCmp] ) );

        world.setManager( cm );

        entityAssembler = world.setSystem( new EntityAssemblySys() );
        world.setSystem( new PosTrackerSys() ); // should be before anything that explicitly updates PosCmp
        world.setSystem( new CameraSys() );
        world.setSystem( new ClientSys( this ) );
        world.setSystem( new InputSys() );
        world.setSystem( new ControllerSys( this ) ); // this must follow InputSys to apply effects of controller states
        world.setSystem( new DestructionSys() );
        world.setSystem( new GridSys() );
        world.setSystem( new PhysicsSys() );
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

        var hammer = [ new Vec2f( 144, 144 )
                     , new Vec2f( 256, 144 )
                     , new Vec2f( 426, 225 )
                     , new Vec2f( 448, 225 )
                     , new Vec2f( 500, 144 )
                     , new Vec2f( 780, 144 )
                     , new Vec2f( 832, 225 )
                     , new Vec2f( 854, 225 )
                     , new Vec2f( 1024, 144 )
                     , new Vec2f( 1136, 144 )
                     , new Vec2f( 1136, 360 )
                     , new Vec2f( 1024, 360 )
                     , new Vec2f( 854, 279 )
                     , new Vec2f( 660, 279 )
                     , new Vec2f( 660, 576 )
                     , new Vec2f( 620, 576 )
                     , new Vec2f( 620, 279 )
                     , new Vec2f( 426, 279 )
                     , new Vec2f( 256, 360 )
                     , new Vec2f( 144, 360 )
                     , new Vec2f( 144, 144 ) ];

        var baseSquare = [ new Vec2f( 144, 144 )
                         , new Vec2f( 744, 144 )
                         , new Vec2f( 744, 744 )
                         , new Vec2f( 144, 744 )
                         , new Vec2f( 144, 144 ) ];

        var innerSquare = [ new Vec2f( 600, 600 )
                          , new Vec2f( 650, 600 )
                          , new Vec2f( 650, 650 )
                          , new Vec2f( 600, 650 )
                          , new Vec2f( 600, 600 ) ];

        sectors.push( entityAssembler.createVirtualSector( "sector0", new Vec2f( 0, 0 ), [ new Polygon( baseSquare ), new Polygon( baseSquare ) ] ) );

#if ( local )
        Security.loadPolicyFile( "xmlsocket://localhost:10000" );
        client = entityAssembler.createClient( "localhost", 5000 );
#else
        Security.loadPolicyFile( "xmlsocket://sonargame.cloudapp.net:10000" );
        client = entityAssembler.createClient( "sonargame.cloudapp.net", 5000 );
#end
        entityAssembler.createGridReferenceBound( sectors[0], new Vec2f( 0, 0 ) );
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
