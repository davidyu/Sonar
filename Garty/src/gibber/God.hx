package gibber;
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
import gibber.components.ClientCmp;
import gibber.components.CmdQueue;
import gibber.components.ControllerCmp;
import gibber.components.PosCmp;
import gibber.components.TakeCmp;
import gibber.managers.ContainerMgr;
import gibber.managers.NameRegistry;
import gibber.managers.SectorGraphMgr;
import gibber.systems.CameraSys;
import gibber.systems.ClientSys;
import gibber.systems.CmdProcessSys;
import gibber.systems.ControllerSys;
import gibber.systems.ExplosionSys;
import gibber.systems.EntityAssemblySys;
import gibber.systems.InputSys;
import gibber.systems.GridSys;
import gibber.systems.PhysicsSys;
import gibber.systems.PosTrackerSys;
import gibber.systems.RenderExplosionSys;
import gibber.systems.RenderSonarSys;
import gibber.systems.RenderSectorSys;
import gibber.systems.RenderGridSys;
import gibber.systems.RenderSys;
import gibber.systems.RenderTorpedoSys;
import gibber.systems.RenderTrailSys;
import gibber.systems.RenderTraceSys;
import gibber.systems.SyncSys;
import gibber.systems.SonarSys;
import gibber.systems.TimedEffectSys;
import gibber.systems.TorpedoSys;
import gibber.systems.TraceSys;
import gibber.systems.TrailSys;
import gibber.systems.TransitRequestSys;
import utils.Key;
import utils.Math2;
import utils.Polygon;
import utils.Vec2;

class God
{
    @:isVar public var world ( default, null ) : World;
    @:isVar public var cf ( default, null ) : CmdFactory;
    @:isVar public var entityAssembler ( default, null ): EntityAssemblySys;
    @:isVar public var entityDeserializer ( default, null ) : EntityDeserializer;
    @:isVar public var sf ( default, null ) : ScriptFactory;

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

        cf = new CmdFactory( this );
        entityDeserializer = new EntityDeserializer( this );

        commander = new Commander( this );
        sf = new ScriptFactory( this );

        initializeEntities();
    }

    public function initializeSystems() : Void {
        var cm = new ContainerMgr();
        cm.registerAspect( "item", Aspect.getAspectForAll( [TakeCmp] ) );
        cm.registerAspect( "char", Aspect.getAspectForAll( [CmdQueue, PosCmp] ) );

        world.setManager( cm );
        world.setManager( new SectorGraphMgr() );

        // don't really need these anymore; take them out
        world.setManager( new NameRegistry() ); // Needs to be last

        entityAssembler = world.setSystem( new EntityAssemblySys() );
        world.setSystem( new PosTrackerSys() ); // should be before anything that explicitly updates PosCmp
        world.setSystem( new CameraSys() );
        world.setSystem( new ClientSys( this ) );
        world.setSystem( new InputSys() );
        world.setSystem( new ControllerSys( this ) ); // this must follow InputSys to apply effects of controller states
        world.setSystem( new GridSys() );
        world.setSystem( new PhysicsSys() );
        world.setSystem( new CmdProcessSys() );
        world.setSystem( new ExplosionSys() );
        world.setSystem( new RenderExplosionSys( root ) );
        world.setSystem( new RenderGridSys( quad ) );
        world.setSystem( new RenderSectorSys( root ) );
        world.setSystem( new RenderSonarSys( quad ) );
        world.setSystem( new RenderTrailSys( root ) );
        world.setSystem( new RenderSys( quad ) );
        world.setSystem( new RenderTorpedoSys( root ) );
        world.setSystem( new RenderTraceSys( quad ) );
        world.setSystem( new SyncSys() );
        world.setSystem( new SonarSys() );
        world.setSystem( new TorpedoSys() );
        world.setSystem( new TimedEffectSys() );
        world.setSystem( new TraceSys() );
        world.setSystem( new TrailSys() );

        world.delta = 1000 / ( root.stage.frameRate ); //this is gross!
        world.initialize();
    }

    public function initializeEntities() : Void {
        sectors = new Array();
        netPlayers = new Array();

        /*
         * map: the Hammer

            x    x   x   xxx   xxx    x   x    x
           144  256 426              854 1024 1136
                         500    780
                        448      832
            0----1         4----5         8----9   y: 144
            |        2----3      6----7        |   y: 225
            |                                  |
            |       17-----16 13-----12        |   y: 279
           19---18          | |           11---10  y: 360
                            | |
                            | |
                            | |
                           15-14                   y: 576

                            x x
                          640-+20
        */

        var s1 = Vec2.getVecArray( [ 144, 144, 256, 144, /* p2 */ 426, 225, 448, 225, 500, 144,
                                    /* p5 */ 780, 144, 832, 225, 854, 225, /* p8 */ 1024, 144, 1136, 144,
                                    /* p10 */ 1136, 360, 1024, 360, 854, 279, /* p13 */ 660, 279,
                                    /* p14 */ 660, 576, 620, 576, 620, 279, /* p17 */ 426, 279,
                                    /* p18 */ 256, 360, 144, 360, 144, 144 ] );

        sectors.push( entityAssembler.createVirtualSector( "sector0", new Vec2( 0, 0 ), [new Polygon( s1 )] ) );

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

    public var commander : Commander;
    public var outputTextfield : TextField;
    public var sectors : Array<Entity>;
    public var player : Entity;
    public var client : Entity;

    public var netPlayers : Array<Entity>;
}

typedef P2 = { p1 : Entity, p2 : Entity };
