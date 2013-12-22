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
import utils.Math2;

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

            switch( time.processState ) {
                case Process( false ):
                    var radius : Float = sonar.growthRate * ( time.internalAcc / 1000.0 );
                    if ( radius > sonar.maxRadius ) {
                        radius = sonar.maxRadius;
                    }

                    var sector = posMapper.get( e ).sector;
                    var sectorPolys = regionMapper.get( sector ).polys;

                    // reveal portions of the sector walls that are "hit" by sonar
                    for ( p in sectorPolys ) {
                        for ( k in 0...p.verts.length - 1 ) {
                            // do an intersection test against each edge of the polygon; create a trace for each intersection occurrence
                            var intersect = Geo.lineCircleIntersect( { center: center, radius: radius }, { a: p.verts[k], b: p.verts[k + 1] } );
                            //trace( 'performing intersection test with { c : $center, r : $radius } and { a : ${p.verts[k]}, b : ${p.verts[k + 1]} }' );
                            switch ( intersect ) {
                                case Line( p, q ):
                                    var ranges : Array<Range> = new Array<Range>(); // this will be the new set of culled ranges we add to sonar.cullRanges

                                    var rangeStart = Math.atan( ( p.x - center.x ) / ( p.y - center.y ) );
                                    var rangeEnd = Math.atan( ( q.x - center.x ) / ( q.y - center.y ) );

                                    ranges.push( { start: rangeStart, end: rangeEnd } );

                                    // compute culling for ranges
                                    for ( orng in sonar.cullRanges ) {
                                        for ( rng in ranges ) { // any new ranges pushed in this loop body will be checked again
                                            //rng     -----
                                            //orng  ---------
                                            if ( orng.start < rng.start && orng.end > rng.end ) {
                                                ranges.remove( rng );
                                            //rng    -----
                                            //orng  ----
                                            } else if ( orng.start < rng.start && orng.end < rng.end ) {
                                                ranges.remove( rng );
                                                ranges.push( { start: orng.start, end: rng.end } );
                                            //rng  ----
                                            //orng   -----
                                            } else if ( orng.start > rng.start && orng.end > rng.end ) {
                                                ranges.remove( rng );
                                                ranges.push( { start: rng.start, end: orng.start } );
                                            //rng  ---------
                                            //orng   -----
                                            } else if ( orng.start > rng.start && orng.end < rng.end ) {
                                                ranges.remove( rng );
                                                ranges.push( { start: rng.start, end: orng.start } );
                                                ranges.push( { start: orng.end, end: rng.end } );
                                            }
                                        }
                                    }

                                    sonar.cullRanges = sonar.cullRanges.concat( ranges );
                                    sonar.cullRanges.sort( function( a : Range, b : Range ):Int {
#if debug
                                        // do simple sanity checks here
                                        if ( ( a.start < b.start && a.end > b.end ) ||
                                             ( a.start < b.start && a.end < b.end ) ||
                                             ( a.start > b.start && a.end > b.end ) ||
                                             ( a.start > b.start && a.end < b.end ) ) {
                                            throw "range a should have been vetted!";
                                        }
#end
                                        return Math2.sign( a.start - b.start );
                                    } );

                                    for ( rng in ranges ) {
                                        function radianToPoint( theta ) : Vec2 {
                                            var direction = new Vec2( Math.sin( theta ), Math.cos( theta ) );

                                            switch ( Math2.getRayLineIntersection( { origin: center, direction: direction }, { a: p, b: q } ) ) {
                                                case Point( point ): return point;
                                                default:             trace( Math2.getRayLineIntersection( { origin: center, direction: direction }, { a: p, b: q } ) ); return null;
                                            }
                                        }

                                        var a = radianToPoint( rng.start );
                                        var b = radianToPoint( rng.end );

                                        if ( a != null && b != null ) {
                                            createTrace( posMapper.get( sector ).pos, Line( a, b ) );
                                        } else {
                                            throw "a trace could not be created";
                                        }
                                    }
                                case Point( _ ):
                                    createTrace( posMapper.get( sector ).pos, intersect );
                                default:
                            } // end switch( intersect )
                        } // end for iterating over p.verts
                    } // end for iterating over sectorPolys

                    time.processState = Processed;
                case Process( true ): //expiring sonar, clear its obscuredRange array
                    time.processState = Processed;
                default:
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
