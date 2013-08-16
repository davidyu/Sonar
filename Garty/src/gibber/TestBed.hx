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
        sectors = new Array();
        
        var vectorArray1 = Vec2.getVecArray( [0, 0, 30, 0, 45, 15, 30, 30, 0, 30, 0, 30 ] );
        var bridgeArray1 = Vec2.getVecArray( [0, 17, 135, 17, 135, 23, 0, 23, 0, 23] );
        var vectorArray2 = Vec2.getVecArray( [135, 0, 165, 0, 165, 30, 135, 30] );
        sectors.push( entityBuilder.createSector( "sector4", new Vec2( 50, 200 ), [new Polygon( vectorArray1 ), new Polygon( bridgeArray1 ), new Polygon( vectorArray2 )] ) );
        sectors.push( entityBuilder.createSector( "sector5", new Vec2( 0, 0 ), [] ) );
        sectors.push( entityBuilder.createSector( "sector6", new Vec2( 0, 0 ), [] ) );
        
        player = entityBuilder.createPlayer( "Bob" , sectors[0] );
        var syns = new List<String>();
        syns.push("player");
        syns.push("me");
        syns.push("Bob");
        entityBuilder.createWordRef( new SynTag( "tag1", "Bob", syns ) );
        var syns2 = new List<String>();
        syns2.push("lalala");
        syns2.push("player");
        entityBuilder.createWordRef( new SynTag( "tag2", "Testa", syns2 ) );
        
        var v1 = new Vec2(0, 0);
        var v2 = new Vec2(1, 1);
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