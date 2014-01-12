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

using utils.RadianHelper;

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
                    for ( poly in sectorPolys ) {
                        for ( k in 0...poly.verts.length - 1 ) {
                            // do an intersection test against each edge of the polygon; create a trace for each intersection occurrence
                            var intersect = Geo.lineCircleIntersect( { center: center, radius: radius }, { a: poly.verts[k], b: poly.verts[k + 1] } ); //wrap
                            //trace( 'performing intersection test with { c : $center, r : $radius } and { a : ${p.verts[k]}, b : ${p.verts[k + 1]} }' );
                            switch ( intersect ) {
                                case Line( p, q ):
                                    var ranges : Array<Range> = new Array<Range>(); // this will be the new set of culled ranges we add to sonar.cullRanges

                                    var rangeStart = pointToRadian( center, p );
                                    var rangeEnd   = pointToRadian( center, q );

                                    if ( radianDiff( rangeStart, rangeEnd ) < 0 ) { // normalize: we never do >180 degree reveals for a single edge.
                                        var temp = rangeStart;
                                        rangeStart = rangeEnd;
                                        rangeEnd = temp;
                                    }

                                    ranges.push( { start: rangeStart, end: rangeEnd } );

                                    trace( "-------starting to cull ranges---------: " );
                                    trace( "for " + Line( p, q ) );
                                    trace( "already " + sonar.cullRanges.length + " segments to cull" );
                                    var tryAgain = true;
                                    var error: Float = 0.004; // allow 0.25 degree of error
                                    // compute culling for ranges
                                    while( tryAgain ) {
                                        tryAgain = false;
                                        for ( orng in sonar.cullRanges ) {
                                            for ( rng in ranges ) {
                                                //rng   ==-----==
                                                //orng  ---------
                                                if ( radianDiff( orng.start, rng.start ) >= 0 && radianDiff( orng.end, rng.start ) < 0 &&
                                                     radianDiff( orng.end, rng.end ) <= 0     && radianDiff( orng.start, rng.end ) > 0 ) {
                                                    ranges.remove( rng );
                                                //rng  ---------
                                                //orng   -----
                                                } else if ( radianDiff( orng.start, rng.start ) < -error && radianDiff( orng.start, rng.end ) > 0 &&   // orng.start between rng.start and rng.end
                                                            radianDiff( orng.end, rng.end ) > error      && radianDiff( orng.end, rng.start ) < 0 ) {  // orng.end between rng.start and rng.end
                                                    ranges.push( { start: rng.start, end: orng.start } );
                                                    ranges.push( { start: orng.end, end: rng.end } );
                                                    if ( ranges.remove( rng ) ) {
                                                        tryAgain = true;
                                                        trace( "reconstructed range " + rngToString( rng ) );
                                                        trace( "new ranges: " + rngToString( { start: rng.start, end: orng.start } ) + " and " + rngToString( { start: orng.end, end: rng.end } ) );
                                                    } else {
                                                        trace( "error reconstructing range " + rngToString( rng ) );
                                                    }
                                                //rng   ===---
                                                //orng  ----
                                                } else if ( radianDiff( orng.start, rng.start ) >= 0 && radianDiff( orng.end, rng.start ) < 0 && radianDiff( orng.end, rng.end ) > error ) {
                                                    ranges.push( { start: orng.end, end: rng.end } );
                                                    if ( ranges.remove( rng ) ) {
                                                        tryAgain = true;
                                                        trace( "reconstructed range " + rngToString( rng ) );
                                                        trace( "new range: " + rngToString( { start: orng.end, end: rng.end } ) );
                                                    } else {
                                                        trace( "error reconstructing range " + rngToString( rng ) );
                                                    }
                                                //rng  ----===
                                                //orng   -----
                                                } else if ( radianDiff( orng.start, rng.start ) < -error && radianDiff( orng.start, rng.end ) > 0 && radianDiff( orng.end, rng.end ) <= 0 ) {
                                                    ranges.push( { start: rng.start, end: orng.start } );
                                                    if ( ranges.remove( rng ) ) {
                                                        tryAgain = true;
                                                        trace( "reconstructed range " + rngToString( rng ) );
                                                        trace( "new range: " + rngToString( { start: rng.start, end: orng.start } ) );
                                                    } else {
                                                        trace( "error reconstructing range " + rngToString( rng ) );
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    sonar.cullRanges = sonar.cullRanges.concat( ranges );

                                    trace( "-------ranges to draw---------: " );
                                    for ( rng in ranges ) {
                                        trace( rngToString( rng ) );
                                        function radianToPoint( origin, theta, invertedY : Bool = true ) : Vec2 {
                                            var direction = new Vec2( Math.sin( theta ), invertedY ? -Math.cos( theta ) : Math.cos( theta ) );

                                            switch ( Math2.getRayLineIntersection( { origin: origin, direction: direction }, { a: poly.verts[k], b: poly.verts[k + 1] } ) ) {
                                                case Point( point ): return point;
                                                default:
                                                    //trace( Math2.getRayLineIntersection( { origin: center, direction: direction }, { a: poly.verts[k], b: poly.verts[k + 1] } ) );
                                                    //trace( direction );
                                                    return null;
                                            }
                                        }

                                        var a = radianToPoint( center, rng.start );
                                        var b = radianToPoint( center, rng.end );

                                        if ( a != null && b != null ) {
                                            createTrace( posMapper.get( sector ).pos, Line( a, b ) );
                                        } else {
                                            trace( "this range could not be created" );
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
            } // end switch on time.processState (wow! how gross!)

            // sort cull ranges
            sonar.cullRanges.sort( function( a : Range, b : Range ):Int {
                return Math2.sign( a.start - b.start );
            } );
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

    private function pointToRadian( center: Vec2, point: Vec2, invertedY : Bool = true ): Float {
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

    // fucking piece of shit helper method
    private function rngToString( rng: Range ): String {
        return Std.int( Math2.radToDeg( rng.start ) ) + " to " + Std.int( Math2.radToDeg( rng.end ) );
    }

    // creates a beautiful trace entity
    private function createTrace( pos : Vec2, displayType : IntersectResult ) {
        if ( displayType != None ) {
            var e = world.createEntity();

            var renderCmp = new RenderCmp( 0xffffff );
            var traceCmp = new TraceCmp( 0.8, displayType, pos );
            var timedEffectCmp = new TimedEffectCmp( 1000, GlobalTickInterval );

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
