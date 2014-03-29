package engine.gibbs;
import engine.gibbs.subsystems.EntityObserver;

class Subsystem implements EntityObserver
{
    public function new() {

    }

    public function onAdded( e : Entity ) : Void {
    }

    public function onDeleted( e : Entity ) : Void {

    }

    public function onAttachCmp( e : Entity, cmp : Component ) : Void {

    }

    var entities : List<Entity>;
}
