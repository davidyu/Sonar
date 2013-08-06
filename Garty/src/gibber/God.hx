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
import gibber.components.PortalCmp;
import gibber.components.PosCmp;
import gibber.components.TakeCmp;
import gibber.gabby.PortalEdge;
import gibber.managers.ContainerMgr;
import gibber.managers.NameRegistry;
import gibber.managers.SectorGraphMgr;
import gibber.managers.SynonymMgr;
import gibber.systems.CmdProcessSys;
import gibber.systems.PhysicsSys;
import gibber.systems.RenderSectorSys;
import gibber.systems.RenderSys;
import gibber.systems.TransitRequestSys;
import utils.Key;
import utils.Math2;
import utils.Polygon;
import utils.Vec2;

class God
{
    @:isVar public var world ( default, null ) : World;
    @:isVar public var cmdFactory ( default, null ) : CmdFactory;
    @:isVar public var entityBuilder ( default, null ) : EntityBuilder;
    @:isvar public var entityDeserializer ( default, null ) : EntityDeserializer;
    @:isVar public var scriptFactory ( default, null ) : ScriptFactory;
    
    public function new( r : MovieClip ) {
        root = r;
        
        // Events
        root.stage.addEventListener( flash.events.KeyboardEvent.KEY_DOWN, onEnterKey );
        Key.init();
        root.addEventListener( flash.events.Event.ENTER_FRAME, tick );
        
        setupConsole();
        
        world = new World();
        initializeSystems();
        
        Util.init( this );

        cmdFactory = new CmdFactory( this );
        entityBuilder = new EntityBuilder( this );
        entityDeserializer = new EntityDeserializer( entityBuilder );

        parser = new AdvancedParser( this );
        commander = new Commander( this );
        scriptFactory = new ScriptFactory( this );
        
        initializeEntities();
        
        //this.testBed = new TestBed(this);
        //testBed.run();
    }
    
    public function setupConsole() : Void {
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
        inputTextfield.backgroundColor = 0xB0EFF7;
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

    public function initializeSystems() : Void {
        var cm = new ContainerMgr();
        cm.registerAspect( "item", Aspect.getAspectForAll( [TakeCmp] ) );
        cm.registerAspect( "portal", Aspect.getAspectForAll( [PortalCmp] ) );
        cm.registerAspect( "char", Aspect.getAspectForAll( [CmdQueue, PosCmp] ) );
        
        world.setManager( cm );
        world.setManager( new SectorGraphMgr() );
        world.setManager( new SynonymMgr() );
        world.setManager( new NameRegistry() ); // Needs to be last

        
        //world.setSystem( new TransitRequestSys() );
        world.setSystem( new PhysicsSys() );
        world.setSystem( new CmdProcessSys() );
        world.setSystem( new RenderSectorSys( root ) );
        world.setSystem( new RenderSys( root ) );
        
        world.initialize();
    }

    public function initializeEntities() : Void {
        sectors = new Array();
        portals = new Array();
        
        var vectorArray1 = Vec2.getVecArray( [0, 0, 30, 0, /*45, 15,*/ 30, 30, 0, 30, 0, 30 ] );
        sectors.push( entityBuilder.createSector( "sector0", new Vec2( 50, 200 ), [new Polygon( vectorArray1 )] ) );
        sectors.push( entityBuilder.createSector( "sector1", new Vec2( 80, 200 ), [ new Polygon( vectorArray1 )] ) );

        portals.push( entityBuilder.createPortal( "door01", sectors[0], new Vec2( 25, 0 ) ) );
        portals.push( entityBuilder.createPortal( "door10", sectors[1], new Vec2( 0, 0 ) ) );

        player = entityBuilder.createPlayer( "Bob" );
        var chest = entityBuilder.createObject( "Old dusty chest", new Vec2( 20, 30 ) );

        entityDeserializer.fromFile( "item_jar.json" );

        var edge = new PortalEdge( portals[0], portals[1], scriptFactory.createScript( "transit" ) );
        entityBuilder.addPortalEdges( portals[0], [edge] );
        entityBuilder.addPortalEdges( portals[1], [new PortalEdge( portals[1], portals[0], scriptFactory.createScript( "transit" ) )] );

        var cmdCmp = player.getComponent( CmdQueue );
        var p0PosCmp = portals[0].getComponent( PosCmp );
        var p1PosCmp = portals[1].getComponent( PosCmp );
    }
        
    public function tick(_) : Void {
        input();
        world.process();
        //testBed.tick();
        
    }
    
    function input() : Void {
        var speed = 1.0;
        
        if ( Key.isDown( Keyboard.RIGHT ) ) {
            player.getComponent( PosCmp ).dp.x = speed;
        } if ( Key.isDown( Keyboard.LEFT ) ){
            player.getComponent( PosCmp ).dp.x = -speed;
        } if ( Key.isDown( Keyboard.UP ) ) {
            player.getComponent( PosCmp ).dp.y = -speed;
        } if ( Key.isDown( Keyboard.DOWN ) ) {
            player.getComponent( PosCmp ).dp.y = speed;
        }
    }
    
    function onEnterKey( e : flash.events.KeyboardEvent ) : Void {
        switch ( e.keyCode ) {
            case Keyboard.ENTER:
                var line = inputTextfield.text;
                inputTextfield.text = "";
                debugPrintln( line, true );
                parser.parse( line );

            case Keyboard.DELETE:
                debugClear();

            //case Keyboard.RIGHT:
                //player.getComponent( PosCmp ).dp.x = 2;
            //case Keyboard.LEFT:
                //player.getComponent( PosCmp ).dp.x = -2;
        }
    }

    //debug convenience methods
    public function debugPrint( str )
    {
        outputTextfield.text += str;
    }

    public function debugPrintln( str, ?fromInput=false )
    {
        var prefix = " →  ";

        if ( fromInput ) {
            prefix = " ←  ";
        }

        debugPrint( prefix + str + "\n" );
    }

    public function debugClear()
    {
        outputTextfield.text = "";
    }

    var root : MovieClip;
    var inputTextfield : TextField;
    var baseTextFormat : TextFormat;
    public var outputTextfield : TextField;
    var testBed : TestBed;

    
    var parser : AdvancedParser;
    
    public var commander : Commander;
    
    public var sectors : Array<Entity>;
    public var portals : Array<Entity>;
    public var player : Entity;
    
}
