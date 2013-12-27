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
                                    trace( "-----------new intersect------------" );
                                    trace( "line:" + p + ", " + q );
                                    trace( "center:" + center );
                                    var ranges : Array<Range> = new Array<Range>(); // this will be the new set of culled ranges we add to sonar.cullRanges

                                    var rangeStart = pointToRadian( center, p );
                                    var rangeEnd   = pointToRadian( center, q );

                                    ranges.push( { start: rangeStart, end: rangeEnd } );
                                    trace( "range:" + Math2.radToDeg( rangeStart ) + ", " + Math2.radToDeg( rangeEnd ) );

                                    // compute culling for ranges
                                    for ( orng in sonar.cullRanges ) {
                                        for ( rng in ranges ) { // any new ranges pushed in this loop body will be checked again
                                            //rng     -----
                                            //orng  ---------
                                            if ( orng.start < rng.start && orng.end < rng.end ) {
                                                ranges.remove( rng );
                                            //rng    -----
                                            //orng  ----
                                            } else if ( orng.start < rng.start && orng.end < rng.end ) {
                                                ranges.remove( rng );
                                                ranges.push( { start: orng.end, end: rng.end } );
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
                                            trace( Math2.radToDeg( a.start )+ " " + Math2.radToDeg( a.end ) );
                                            // throw "range a should have been vetted!";
                                        }
#end
                                        return Math2.sign( a.start - b.start );
                                    } );

                                    for ( rng in ranges ) {
                                        function radianToPoint( origin, theta, invertedY : Bool = true ) : Vec2 {
                                            var direction = new Vec2( Math.sin( theta ), invertedY ? -Math.cos( theta ) : Math.cos( theta ) );

                                            trace( "reconstructed vector: " + direction );
                                            switch ( Math2.getRayLineIntersection( { origin: origin, direction: direction }, { a: p, b: q } ) ) {
                                                case Point( point ): return point;
                                                default:
                                                    trace( Math2.getRayLineIntersection( { origin: center, direction: direction }, { a: p, b: q } ) );
                                                    trace( direction );
                                                    return null;
                                            }
                                        }

                                        var a = radianToPoint( center, rng.start );
                                        var b = radianToPoint( center, rng.end );

                                        if ( a != null && b != null ) {
                                            createTrace( posMapper.get( sector ).pos, Line( a, b ) );
                                        } else {
                                            trace( Math2.radToDeg( rng.start )+ " " + Math2.radToDeg( rng.end ) );
                                            // throw "a trace could not be created";
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

    // returns f, where |f| is the shortest distance between a and b
    // and f > 0 if b follows a clockwise and f < 0 if a follows b clockwise
    private function radianDiff( a: Float, b: Float ): Float {
        var diff = b - a;
        if ( diff >  Math.PI ) diff -= Math.PI * 2; // as expected, b follows a CW, but we should go CCW for the smaller angle
        if ( diff < -Math.PI ) diff += Math.PI * 2; // edge case: going from a to b we pass the y-axis separating quadrants 1 and 4. So we apply a magical 360 error correcting factor
        return diff;
    }

    // convenience; made testing easier
    // returns f, where |f| is the shortest distance between a and b
    // and f > 0 if b follows a clockwise and f < 0 if a follows b clockwise
    private function degreeDiff( a: Float, b: Float ): Float {
        var diff = b - a;
        if ( diff >  180.0 ) diff -= 360.0; // as expected, b follows a CW, but we should go CCW for the smaller angle
        if ( diff < -180.0 ) diff += 360.0; // edge case: going from a to b we pass the y-axis separating quadrants 1 and 4. So we apply a magical 360 error correcting factor
        return diff;
    }

    private function pointToRadian( center: Vec2, point: Vec2, invertedY : Bool = true ) {
        // note that Y is inverted by default because for regular usage in screen space, it grows from 0 downwards
        var ratio : Float = ( point.x - center.x ) / ( invertedY ? ( center.y - point.y ) : ( point.y - center.y ) );
        var radian = Math.atan( ratio );

        // error correction: the ratio encodes only two signs, but we need to map to four quadrants (if left as-is, it will always map to the first and fourth quadrant)
        if ( ( point.x - center.x < 0 ) && ( invertedY ? ( center.y - point.y < 0 ) : ( point.y - center.y < 0 ) ) ) radian += Math.PI; // point in third quadrant, not the first
        if ( ( point.x - center.x > 0 ) && ( invertedY ? ( center.y - point.y < 0 ) : ( point.y - center.y < 0 ) ) ) radian -= Math.PI; // point in second quadrant, not the fourth

        // enforce 0 <= radian <= 2PI
        while ( radian > Math.PI * 2 ) {
            radian -= Math.PI * 2;
        }

        while ( radian < 0 ) {
            radian += Math.PI * 2;
        }

        return radian;
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
