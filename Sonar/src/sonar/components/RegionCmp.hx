package sonar.components;
import com.artemisx.Component;
import com.artemisx.Entity;
import utils.Polygon;

class RegionCmp implements Component
{
    @:isVar public var polys ( default, default ) : Array<Polygon>;
    @:isVar public var parent : Entity;
    @:isVar public var owner : Entity;
    @:isVar public var adj : Array<Entity>;
    @:isVar public var isOpen : Bool;

    public function new( polygonAreas : Array<Polygon> = null, parent : Entity=null ) {
        if ( polygonAreas == null ) {
            polygonAreas = new Array<Polygon>();
        }

        this.polys = polygonAreas;
        this.parent = parent;
        this.adj = new Array();
        this.isOpen = true;
    }

    public function onEnter( mover : Entity, fromSector : Entity ) : Void {
    }

    public function onExit( mover : Entity, toSector : Entity ) : Void {
    }
}
