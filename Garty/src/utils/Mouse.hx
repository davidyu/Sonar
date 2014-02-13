package utils;

import utils.Vec2;

// polling-friendly Mouse interface helper
// from a functional perspective, this is bad, because we're micromanaging all this state
// but for artemis and systems, this is a necessary evil
class Mouse {
    private static var initialized = false;
    private static var down : Bool;
    private static var pressed : Bool;
    private static var screenMousePos : Vec2;

    public static function init() {
        if ( initialized ) return;
        var stage = flash.Lib.current.stage;
        screenMousePos = new Vec2( 0, 0 );
        stage.addEventListener( flash.events.MouseEvent.MOUSE_DOWN, onMouse.bind( true ) );
        stage.addEventListener( flash.events.MouseEvent.MOUSE_UP, onMouse.bind( false ) );
        stage.addEventListener( flash.events.MouseEvent.CLICK, onMousePress );
        stage.addEventListener( flash.events.Event.ENTER_FRAME, onEnterFrame );
        initialized = true;
    }

    static function onEnterFrame( _ ) {
        // reset state
        pressed = false; // we don't want the pressed event to span multiple frames in a polling paradigm. Think about it.
    }

    static function onMouse( down_, e : flash.events.MouseEvent ) {
        down = down_;
        screenMousePos = new Vec2( e.localX, e.localY );
    }

    static function onMousePress( e : flash.events.MouseEvent ) {
        pressed = true;
        screenMousePos = new Vec2( e.localX, e.localY );
    }

    public static function isDown() {
        return down;
    }

    public static function isUp() {
        return !down;
    }

    public static function wasPressed() {
        return !down && pressed;
    }

    public static function getMouseCoords() {
        return screenMousePos;
    }
}
