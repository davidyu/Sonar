import flash.Lib;
import flash.display.Sprite;
import flash.events.Event;

class Preloader extends Sprite
{
    public function new()
    {
        super();
        addEventListener( Event.ENTER_FRAME, onLoadProgress );
    }
    function onLoadProgress(event:Event):Void
    {
        var bytesLoaded = Lib.current.stage.loaderInfo.bytesLoaded;
        var bytesTotal = Lib.current.stage.loaderInfo.bytesTotal;
        var percentLoaded = bytesLoaded / bytesTotal;
        trace( "WTF" );
        trace( Std.int( percentLoaded * 100 ) + "%" );
        if ( percentLoaded == 1 )
        {
            removeEventListener( Event.ENTER_FRAME, onLoadProgress );
            Lib.current.removeChild( this );
            // startup hook
            Main.main();
        }
    }
    public static function main()
    {
        Lib.current.addChild( new Preloader() );
    }
}
