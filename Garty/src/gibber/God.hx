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
    @:isVar public var entityBuilder ( default, null ) : EntityBuilder;
    @:isVar public var entityDeserializer ( default, null ) : EntityDeserializer;
    @:isVar public var sf ( default, null ) : ScriptFactory;
    @:isVar public var entityResolver ( default, null ) : EntityResolver;

    public function new( r : MovieClip ) {
        root = r;

        root.stage.addEventListener( flash.events.KeyboardEvent.KEY_DOWN, onEnterKey );
        root.stage.addEventListener( flash.events.MouseEvent.CLICK, onMouseClick );
        Key.init();
        root.addEventListener( flash.events.Event.ENTER_FRAME, tick );

        setupDebugConsole();

        world = new World();
        initializeSystems();

        SynTag.initialize( this );
        Util.init( this );

        cf = new CmdFactory( this );
        entityBuilder = new EntityBuilder( this );
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

        world.setSystem( new PosTrackerSys() ); // should be before anything that explicitly updates PosCmp
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

        world.setSystem( new ControllerSys() ); // this must be last to clear all controller states

        world.delta = 1000 / ( root.stage.frameRate ); //this is gross!
        world.initialize();
    }

    public function initializeEntities() : Void {
        sectors = new Array();

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

        sectors.push( entityBuilder.createVirtualSector( "sector0", new Vec2( 0, 0 ), [new Polygon( s1 )] ) );

        player = entityBuilder.createPlayer( "ship", sectors[0], new SynTag( "bob", ["bob", "player"], SynType.NOUN ), true );

        var cmdCmp = player.getComponent( CmdQueue );
    }

    public function tick( _ ) : Void {
        pollInput();
        world.process();
    }

    function pollInput() : Void {
        if ( Key.isDown( Keyboard.RIGHT ) ) {
            player.getComponent( ControllerCmp ).moveRight = true;
        }

        if ( Key.isDown( Keyboard.LEFT ) ){
            player.getComponent( ControllerCmp ).moveLeft = true;
        }

        if ( Key.isDown( Keyboard.UP ) ) {
            player.getComponent( ControllerCmp ).moveUp = true;
        }

        if ( Key.isDown( Keyboard.DOWN ) ) {
            player.getComponent( ControllerCmp ).moveDown = true;
        }
    }

    function onEnterKey( e : flash.events.KeyboardEvent ) : Void {
        switch ( e.keyCode ) {
            case Keyboard.SPACE:
                entityBuilder.createSonar( player.getComponent( PosCmp ).sector, player.getComponent( PosCmp ).pos );

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

    function onMouseClick( e : flash.events.MouseEvent ) : Void {
        //shoot a sonar particle in the direction of the mouse cursor
        var origin = player.getComponent( PosCmp ).pos;
        var direction = new Vec2( e.localX, e.localY ).sub( player.getComponent( PosCmp ).sector.getComponent( PosCmp ).pos ).sub( origin ); // wow
        entityBuilder.createSonarBeam( player.getComponent( PosCmp ).sector, origin, direction );
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

    var root : MovieClip;
    var inputTextfield : TextField;
    var baseTextFormat : TextFormat;
    public var outputTextfield : TextField;

    var parser : AdvancedParser;
    public var commander : Commander;
    public var sectors : Array<Entity>;
    public var player : Entity;
}

typedef P2 = { p1 : Entity, p2 : Entity };
