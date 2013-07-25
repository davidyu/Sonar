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
import utils.Key;
import utils.Math2;
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
        Key.init();
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
        
        var vectorArray1 = Vec2.getVecArray( [0, 0, 30, 0, 45, 15, 30, 30, 0, 30, 0, 30 ] );
        var bridgeArray1 = Vec2.getVecArray( [0, 17, 135, 17, 135, 23, 0, 23, 0, 23] );
        var vectorArray2 = Vec2.getVecArray( [135, 0, 165, 0, 165, 30, 135, 30] );
        sectors.push( entityBuilder.createSector( "sector0", new Vec2( 50, 200 ), [new Polygon( vectorArray1 ), new Polygon( bridgeArray1 ), new Polygon( vectorArray2 )] ) );
        sectors.push( entityBuilder.createSector( "sector1", new Vec2( 0, 0 ), [] ) );
        sectors.push( entityBuilder.createSector( "sector2", new Vec2( 0, 0 ), [] ) );
        
        player = entityBuilder.createPlayer( "Bob" );
        
        var v1 = new Vec2(0, 0);
        var v2 = new Vec2(1, 1);
    }
    
    
    
    public function tick(_) : Void {
        input();
        world.process();
    }
    
    
    @:isVar public var world ( default, null ) : World;
    @:isVar public var entityBuilder ( default, null ) : EntityBuilder;
    
    function input() : Void {
        var speed = 2.0;
        
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
                outputTextfield.text += inputTextfield.text + "\n";
                parser.parse( inputTextfield.text );

                inputTextfield.text = "";
            case Keyboard.DELETE:
                outputTextfield.text = "";
                
            //case Keyboard.RIGHT:
                //player.getComponent( PosCmp ).dp.x = 2;
            //case Keyboard.LEFT:
                //player.getComponent( PosCmp ).dp.x = -2;
                
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