package gibber;
import com.artemisx.Entity;
import com.artemisx.World;
import flash.display.MovieClip;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.ui.Keyboard;
import gibber.components.PosCmp;
import gibber.managers.NameRegistry;
import gibber.systems.PhysicsSys;
import gibber.systems.RenderSectorSys;
import gibber.systems.RenderSys;
import gibber.systems.TransitRequestSys;
import utils.Polygon;
import utils.Vec2;

class God
{
    public function new( r : MovieClip ) {
        root = r;
        
        world = new World();
        entityBuilder = new EntityBuilder( this );
        
        parser = new AdvancedParser( this );
        commander = new Commander( this );
        
        inputTextfield = new TextField();
        inputTextfield.type = TextFieldType.INPUT;
        inputTextfield.width = root.stage.stageWidth;
        inputTextfield.height = 50;
        inputTextfield.y = root.stage.stageHeight - inputTextfield.height;
        inputTextfield.background = true;
        inputTextfield.backgroundColor = 0xB0EFF7;
        inputTextfield.textColor = 0xF29746;
        
        root.addChild( inputTextfield );
        
        outputTextfield = new TextField();
        outputTextfield.type = TextFieldType.INPUT;
        outputTextfield.width = root.stage.stageWidth;
        outputTextfield.height = root.stage.stageHeight - inputTextfield.height;
        outputTextfield.textColor = 0xF29746;
        
        root.addChild( outputTextfield );
        
        // Events
        root.stage.addEventListener( flash.events.KeyboardEvent.KEY_DOWN, onEnterKey );
        root.addEventListener( flash.events.Event.ENTER_FRAME, tick );
        
        
        initializeSystems();
        initializeEntities();
        
        entityBuilder.testPolygon();
    }

    public function initializeSystems() : Void {
        world.setManager( new NameRegistry() );
        
        world.setSystem( new TransitRequestSys() );
        world.setSystem( new PhysicsSys() );
        world.setSystem( new RenderSectorSys( root ) );
        world.setSystem( new RenderSys( root ) );
        
        world.initialize();
    }
    
    public function initializeEntities() : Void {
        sectors = new Array();
        
        var vectorArray1 = Vec2.getVecArray( [0, 0, 30, 0, 30, 30, 0, 30] );
        var vectorArray2 = Vec2.getVecArray( [35, 0, 65, 0, 65, 30, 35, 30] );
        sectors.push( entityBuilder.createSector( "sector1", new Vec2( 0, 0 ), [new Polygon( vectorArray1 ), new Polygon( vectorArray2 )] ) );
        sectors.push( entityBuilder.createSector( "sector2", new Vec2( 0, 0 ), [] ) );
        sectors.push( entityBuilder.createSector( "sector3", new Vec2( 0, 0 ), [] ) );
        
        player = entityBuilder.createPlayer( "Bob" );
    }
    
    
    
    public function tick(_) : Void {
        world.process();
    }
    
    
    @:isVar public var world ( default, null ) : World;
    @:isVar public var entityBuilder ( default, null ) : EntityBuilder;
    
    function onEnterKey( e : flash.events.KeyboardEvent ) : Void {
        switch ( e.keyCode ) {
            case Keyboard.ENTER:
                outputTextfield.text += inputTextfield.text + "\n";
                parser.parse( inputTextfield.text );

                inputTextfield.text = "";
            case Keyboard.DELETE:
                outputTextfield.text = "";
                
            case Keyboard.RIGHT:
                player.getComponent( PosCmp ).dp.x = 2;
        }
        
        
    }
    
    var root : MovieClip;
    var inputTextfield : TextField;
    public var outputTextfield : TextField;
    
    var parser : AdvancedParser;
    
    public var commander : Commander;
    
    public var sectors : Array<Entity>;
    public var player : Entity;
    
}