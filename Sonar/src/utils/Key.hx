package utils;

class Key {
    private static var initialized = false;

    static var kcodes = new Array<Null<Int>>();

    static var ktime = 0;

    public static function init() {
        if ( initialized ) return;
        var stage = flash.Lib.current.stage;
        stage.addEventListener(flash.events.KeyboardEvent.KEY_DOWN, onKey.bind( true ));
        stage.addEventListener(flash.events.KeyboardEvent.KEY_UP,onKey.bind(false));
        stage.addEventListener(flash.events.Event.DEACTIVATE,function(_) kcodes = new Array());
        stage.addEventListener(flash.events.Event.ENTER_FRAME,onEnterFrame);
        initialized = true;
    }

    static function onEnterFrame(_) {
        ktime++;
    }

    static function onKey( down, e : flash.events.KeyboardEvent ) {
        event(e.keyCode,down);
    }

    public static function event( code, down ) {
        kcodes[code] = down ? ktime : null;
    }


	public static function isDown(c) {
		return kcodes[c] != null;
	}

	public static function isToggled(c) {
		return kcodes[c] == ktime;
	}
}
