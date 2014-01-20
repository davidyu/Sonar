package gibber.systems;

import com.artemisx.Aspect;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import com.artemisx.utils.Bag;
import com.artemisx.systems.IntervalEntitySystem;

import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.TextFormat;

import gibber.components.DebugClientCmp;

class DebugClientSys extends IntervalEntitySystem
{
    public function new( root : MovieClip ) {
        this.root = root;
        super( Aspect.getAspectForAll( [DebugClientCmp] ), 100.0 );
    }

    override public function initialize() : Void {
        var baseTextFormat = new TextFormat();
        baseTextFormat.font = "Helvetica";
        baseTextFormat.size = 24;

        out  = new TextField();
        out.type = TextFieldType.DYNAMIC;
        out.defaultTextFormat = baseTextFormat;
        out.width  = root.stage.stageWidth / 3;
        out.height = root.stage.stageHeight;
        out.x = 2 * root.stage.stageWidth / 3;
        out.y = 0;
        out.textColor = 0xffffff;

        root.addChild( out );

        out.text += "debug client output:";
        debugClientMapper = world.getMapper( DebugClientCmp );
    }

    override public function processEntities( entities : Bag<Entity> ) : Void  {
        var e : Entity;
        var d : DebugClientCmp;
        for ( i in 0...actives.size ) {
            e = actives.get( i );
            d = debugClientMapper.get( e );
            while ( d.socket.connected && d.socket.bytesAvailable > 0 ) {
                out.text += d.socket.readUTFBytes( 1 );
            }
        }
    }

    private var debugClientMapper : ComponentMapper<DebugClientCmp>;
    private var out    : TextField;
    private var root   : MovieClip;
    private var buffer : Sprite;
}
