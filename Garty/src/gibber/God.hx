package gibber;
import com.artemisx.Entity;
import com.artemisx.World;
import flash.display.MovieClip;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.ui.Keyboard;
import gibber.systems.NameRegistry;
import gibber.systems.TransitRequestSys;

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
    }
    
    public function initializeSystems() : Void {
        world.setSystem( new NameRegistry() );
        world.setSystem( new TransitRequestSys() );
        
        world.initialize();
    }
    
    public function initializeEntities() : Void {
        sectors = new Array();
        
        sectors.push( entityBuilder.createSector( "sector1" ) );
        sectors.push( entityBuilder.createSector( "sector2" ) );
        sectors.push( entityBuilder.createSector( "sector3" ) );
        
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