package gibber;
import com.artemisx.Entity;
import gibber.gabby.SynTag;
import gibber.managers.SynonymMgr;
import utils.Polygon;
import utils.Vec2;

using Lambda;

class TestBed
{

    public function new( g ) {
        god = g;
    }
    
    public function run() : Void {
        mgr = god.world.getManager( SynonymMgr );
        entityBuilder = god.entityBuilder;
        initializeEntities();
    }
    
    public function initializeEntities() : Void {
    }
    
    public function tick() : Void {
        var i = 0;
    }
    var god : God;
    var entityBuilder : EntityBuilder;
    var player : Entity;
    var sectors : Array<Entity>;
    var mgr : SynonymMgr;
    
}