package sonar.components;
import com.artemisx.Component;

// @dyu TODO: implement synchronized "channels"...and perhaps do away with CustomTickInterval
enum TickInterval {
    GlobalTickInterval; //generally 30-60fps, see compile.hxml
    CustomTickInterval( delta : UInt ); //ms
    GlobalTickIntervalWithModifier( factor : Float );
    SynchronizedChannel( channelId : UInt );
}

enum ProcessState {
    Wait( lastProcessed : UInt );
    Process( expiring : Bool );
    Processed;
}

@:rtti
class TimedEffectCmp implements Component
{
    @:isVar public var duration  : UInt; //the entity that has this cmp expires (and is therefore deleted) at the end of its duration; 0 means it exists forever
    @:isVar public var tickInterval : TickInterval; //allows the user to specify custom tick intervals

    //should only be accessed by select Systems
    @:isVar public var processState    : ProcessState; //used as a "shared state" for systems to know whether to process the entity
    @:isVar public var internalAcc : UInt; //time (in ms) accumulator to determine if we've reached the cmp/entity's time-to-live AND to determine when we should process the entity

    public function new( duration : UInt, tickInterval : TickInterval ) {
        this.duration        = duration;
        this.tickInterval    = tickInterval;
        this.internalAcc     = 0;
        this.processState    = Processed; //let TimedEffectSys resolve this
    }
}
