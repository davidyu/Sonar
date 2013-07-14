package engine.gibbs.subsystems;
import engine.gibbs.Subsystem;

class TickSys extends Subsystem
{
    public function new() {
        super();
    }

    public function update( deltaSeconds : Float ) : Void {

    }

    public override function onAdded( e : Entity ) : Void {
        //Dave: you seem to want to do something here...
        //if ( entities.map
    }

    public override function onDeleted( e : Entity ) : Void {

    }
}
