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
import gibber.gabby.SynTag;
import gibber.managers.ContainerMgr;
import gibber.managers.NameRegistry;
import gibber.managers.SectorGraphMgr;
import gibber.managers.SynonymMgr;
import gibber.managers.WordsMgr;
import gibber.systems.CmdProcessSys;
import gibber.systems.ControllerSys;
import gibber.systems.ClientSys;
import gibber.systems.EntityAssemblySys;
import gibber.systems.InputSys;
import gibber.systems.PhysicsSys;
import gibber.systems.PosTrackerSys;
import gibber.systems.RenderSonarSys;
import gibber.systems.RenderSectorSys;
import gibber.systems.RenderSys;
import gibber.systems.RenderTrailSys;
import gibber.systems.RenderTraceSys;
import gibber.systems.SonarSys;
import gibber.systems.TimedEffectSys;
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
    @:isVar public var entityResolver ( default, null ) : EntityResolver;

    public function new( r : MovieClip ) {
        root = r;

        root.stage.addEventListener( flash.events.KeyboardEvent.KEY_DOWN, onEnterKey );
        f = 0;
        root.addEventListener( flash.events.Event.ENTER_FRAME, tick );

        setupDebugConsole();

        world = new World();
        initializeSystems();

        SynTag.initialize( this );
        Util.init( this );

        cf = new CmdFactory( this );
        entityDeserializer = new EntityDeserializer( this );

        commander = new Commander( this );
        sf = new ScriptFactory( this );
        entityResolver = new EntityResolver( this );
        parser = new AdvancedParser( this );

        initializeEntities();
    }

    public function initializeSystems() : Void {
        var cm = new ContainerMgr();
        cm.registerAspect( "item", Aspect.getAspectForAll( [TakeCmp] ) );
        cm.registerAspect( "char", Aspect.getAspectForAll( [CmdQueue, PosCmp] ) );

        world.setManager( cm );
        world.setManager( new SectorGraphMgr() );

        // don't really need these anymore
        world.setManager( new SynonymMgr() );
        world.setManager( new WordsMgr() ); // Needs to be last
        world.setManager( new NameRegistry() ); // Needs to be last

        entityAssembler = world.setSystem( new EntityAssemblySys() );
        world.setSystem( new PosTrackerSys() ); // should be before anything that explicitly updates PosCmp
        world.setSystem( new ClientSys( this ) );
        world.setSystem( new InputSys() );
        world.setSystem( new ControllerSys( this ) ); // this must follow InputSys to apply effects of controller states
        world.setSystem( new PhysicsSys() );
        world.setSystem( new CmdProcessSys() );
        world.setSystem( new RenderSectorSys( root ) );
        world.setSystem( new RenderSonarSys( root ) );
        world.setSystem( new RenderTrailSys( root ) );
        world.setSystem( new RenderSys( root ) );
        world.setSystem( new RenderTraceSys( root ) );
        world.setSystem( new SonarSys() );
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

#if local
        Security.loadPolicyFile( "xmlsocket://localhost:10000" );
        client = entityAssembler.createClient( "localhost", 5000 );
#else
        Security.loadPolicyFile( "xmlsocket://168.62.40.105:10000" );
        client = entityAssembler.createClient( "168.62.40.105", 5000 );
#end
    }

    public function tick( _ ) : Void {
        world.process();
        if ( ++f % 24 == 0 ) {
            sendEntityPositions();
            f = 0;
        }
    }

    function sendEntityPositions() : Void {
        var socket = client.getComponent( ClientCmp ).socket;
        var serializedPos : String = haxe.Serializer.run( player.getComponent( PosCmp ) );
        if ( socket.connected ) {
            socket.writeByte( 2 );
            socket.writeShort( serializedPos.length );
            socket.writeUTFBytes( serializedPos );
            socket.flush();
        }
    }

    public function sendSonarBeamCreationEvent( origin : Vec2, direction : Vec2 ) : Void {
        var socket = client.getComponent( ClientCmp ).socket;
        var originSerialized : String = haxe.Serializer.run( origin );
        var directionSerialized : String = haxe.Serializer.run( direction );
        if ( socket.connected ) {
            socket.writeByte( 4 );
            socket.writeShort( originSerialized.length );
            socket.writeShort( directionSerialized.length );
            socket.writeUTFBytes( originSerialized );
            socket.writeUTFBytes( directionSerialized );
            socket.flush();
        }
    }

    public function sendSonarCreationEvent( pos : Vec2 ) {
        var socket = client.getComponent( ClientCmp ).socket;
        var posSerialized : String = haxe.Serializer.run( pos );
        if ( socket.connected ) {
            socket.writeByte( 3 );
            socket.writeShort( posSerialized.length );
            socket.writeUTFBytes( posSerialized );
            socket.flush();
        }
    }

    function onEnterKey( e : flash.events.KeyboardEvent ) : Void {
        switch ( e.keyCode ) {
            case Keyboard.ENTER:
                var line = inputTextfield.text;
                inputTextfield.text = "";
                debugPrintln( line, true );

                if ( line != "" ) {
                    parser.parse( line );
                }

            case Keyboard.DELETE:
                debugClear();
        }
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
        inputTextfield.background = true;
        inputTextfield.backgroundColor = 0x000000;
        inputTextfield.textColor = 0x000000;

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
    var inputTextfield : TextField;
    var baseTextFormat : TextFormat;

    var parser : AdvancedParser;
    public var commander : Commander;
    public var outputTextfield : TextField;
    public var sectors : Array<Entity>;
    public var player : Entity;
    public var client : Entity;

    public var netPlayers : Array<Entity>;
}

typedef P2 = { p1 : Entity, p2 : Entity };
