package gibber.systems;

import com.artemisx.Aspect;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import com.artemisx.EntitySystem;
import com.artemisx.utils.Bag;

import gibber.components.PosCmp;
import gibber.components.RegionCmp;
import gibber.components.RenderCmp;
import gibber.components.SonarCmp;
import gibber.components.TimedEffectCmp;
import gibber.components.TraceCmp;


import utils.Geo;
import utils.Polygon;
import utils.Vec2;

class SonarSys extends EntitySystem
{
    public function new() {
        super( Aspect.getAspectForAll( [PosCmp, SonarCmp, TimedEffectCmp] ) );
    }

    override public function initialize() : Void {
        posMapper         = world.getMapper( PosCmp );
        timedEffectMapper = world.getMapper( TimedEffectCmp );
        sonarMapper       = world.getMapper( SonarCmp );
        regionMapper      = world.getMapper( RegionCmp );
    }

    override public function processEntities( entities : Bag<Entity> ) : Void  {
        var e : Entity;

        var time : TimedEffectCmp;
        var sonar : SonarCmp;
        var center : Vec2;
        var sector : Entity;

        for ( i in 0...actives.size ) {
            e = actives.get( i );
            time = timedEffectMapper.get( e );
            sonar = sonarMapper.get( e );
            center = posMapper.get( e ).pos;

            if ( time.processState == Process ) {
                var radius : Float = sonar.growthRate * ( time.internalAcc / 1000.0 );
                if ( radius > sonar.maxRadius ) {
                    radius = sonar.maxRadius;
                }

                var sector = posMapper.get( e ).sector;
                var sectorPolys = regionMapper.get( sector ).polys;
                for ( p in sectorPolys ) {
                    for ( k in 0...p.verts.length - 1 ) {
                        // do an intersection test against each edge of the polygon; create a trace for each intersection occurrence
                        var intersect = Geo.lineCircleIntersect( { center: center, radius: radius }, { a: p.verts[k], b: p.verts[k + 1] } );
                        //trace( 'performing intersection test with { c : $center, r : $radius } and { a : ${p.verts[k]}, b : ${p.verts[k + 1]} }' );
                        if ( intersect != None ) {
                            createTrace( posMapper.get( sector ).pos, intersect );
                        }
                    }
                }

                time.processState = Processed;
            }
        }
    }

    // creates a beautiful trace entity
    private function createTrace( pos : Vec2, displayType : IntersectResult ) {
        if ( displayType != None ) {
            var e = world.createEntity();

            var renderCmp = new RenderCmp( 0xffffff );
            var traceCmp = new TraceCmp( 0.5, displayType, pos );
            var timedEffectCmp = new TimedEffectCmp( 0, GlobalTickInterval );

            e.addComponent( renderCmp );
            e.addComponent( traceCmp );
            e.addComponent( timedEffectCmp );

            world.addEntity( e );
        }
    }

    var timedEffectMapper : ComponentMapper<TimedEffectCmp>;
    var sonarMapper       : ComponentMapper<SonarCmp>;
    var posMapper         : ComponentMapper<PosCmp>;
    var regionMapper      : ComponentMapper<RegionCmp>; // need to extract region polys from sector
}
