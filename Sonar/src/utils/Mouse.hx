package utils;

import gml.vector.Vec2f;

// polling-friendly Mouse interface helper
// from a functional perspective, this is bad, because we're micromanaging all this state
// but for artemis and systems, this is a necessary evil
class Mouse {
    private static var initialized = false;
    private static var down : Bool;
    private static var pressed : Bool;
    private static var screenMousePos : Vec2f;

    public static function init() {
        if ( initialized ) return;
        var stage = flash.Lib.current.stage;
        screenMousePos = new Vec2f( 0, 0 );
        stage.addEventListener( flash.events.MouseEvent.MOUSE_DOWN, onMouse.bind( true ) );
        stage.addEventListener( flash.events.MouseEvent.MOUSE_UP, onMouse.bind( false ) );
        stage.addEventListener( flash.events.MouseEvent.CLICK, onMousePress );
        stage.addEventListener( flash.events.MouseEvent.MOUSE_MOVE, onMouseMove );
        stage.addEventListener( flash.events.Event.ENTER_FRAME, onEnterFrame );
        initialized = true;
    }

    static function onEnterFrame( _ ) {
        // reset state
        pressed = false; // we don't want the pressed event to span multiple frames in a polling paradigm. Think about it.
    }

    static function onMouseMove( e : flash.events.MouseEvent ) {
        screenMousePos.x = e.stageX;
        screenMousePos.y = e.stageY;
    }

    static function onMouse( down_, e : flash.events.MouseEvent ) {
        down = down_;
        screenMousePos.x = e.stageX;
        screenMousePos.y = e.stageY;
    }

    static function onMousePress( e : flash.events.MouseEvent ) {
        pressed = true;
        screenMousePos.x = e.stageX;
        screenMousePos.y = e.stageY;
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
