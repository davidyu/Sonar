package gibber;
import com.artemisx.Entity;
import com.artemisx.World;
import flash.display.MovieClip;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFieldType;
import flash.ui.Keyboard;
import gibber.components.CmdQueue;
import gibber.components.PortalCmp;
import gibber.components.PosCmp;
import gibber.gabby.PortalEdge;
import gibber.managers.ContainerMgr;
import gibber.managers.NameRegistry;
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
        world.setManager( new NameRegistry() );
        world.setManager( new ContainerMgr() );
        world.setManager( new SynonymMgr() );
        
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
        //var bridgeArray1 = Vec2.getVecArray( [0, 17, 135, 17, 135, 23, 0, 23, 0, 23] );
        //var vectorArray2 = Vec2.getVecArray( [135, 0, 165, 0, 165, 30, 135, 30] );
        sectors.push( entityBuilder.createSector( "sector0", new Vec2( 50, 200 ), [new Polygon( vectorArray1 )] ) );
        sectors.push( entityBuilder.createSector( "sector1", new Vec2( 80, 200 ), [ new Polygon( vectorArray1 )] ) );
        //sectors.push( entityBuilder.createSector( "sector2", new Vec2( 381, 200 ), [new Polygon( vectorArray1 ), new Polygon( bridgeArray1 ), new Polygon( vectorArray2 )] ) );

        portals.push( entityBuilder.createPortal( "door01", sectors[0], new Vec2( 25, 0 ) ) );
        portals.push( entityBuilder.createPortal( "door10", sectors[1], new Vec2( 0, 0 ) ) );
        
        player = entityBuilder.createPlayer( "Bob" );
        var chest = entityBuilder.createObject( "Old dusty chest", new Vec2( 20, 30 ) );
        
        entityBuilder.addRegionEdge( portals[0], sectors[1] );
        entityBuilder.addRegionEdge( portals[1], sectors[0] );
        
        //entityBuilder.addPortalEdges( portals[0], [new PortalEdge( portals[0], portals[1], scriptFactory.createScript( "transit" ) )] );
        //entityBuilder.addPortalEdges( portals[1], [new PortalEdge( portals[1], portals[0], scriptFactory.createScript( "transit" ) )] );
        
        var pCmp = portals[0].getComponent( PortalCmp );
        //var pCmp2 = portals[1].getComponent( PortalCmp );

        var cmdCmp = player.getComponent( CmdQueue );
        //cmdCmp.enqueue( cmdFactory.createCmd( "move", [player, new Vec2( 100, 20 )] ) );
        //cmdCmp.enqueue( cmdFactory.createCmd( "transit", player, pCmp.edges[0]] ) );
        //cmdCmp.enqueue( cmdFactory.createCmd( "move", [player, new Vec2( 100, 20 )] ) );
        //cmdCmp.enqueue( cmdFactory.createCmd( "transit", [player, pCmp2.edges[0]] ) );
        
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
