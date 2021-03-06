package sonar.systems;

import com.artemisx.Aspect;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import com.artemisx.EntitySystem;
import com.artemisx.utils.Bag;

import sonar.components.InputCmp;
import sonar.components.NetworkPlayerCmp;
import sonar.components.PosCmp;
import sonar.components.RegionCmp;
import sonar.components.RenderCmp;
import sonar.components.SonarCmp;
import sonar.components.TimedEffectCmp;
import sonar.components.TraceCmp;

import sonar.managers.ContainerMgr;

import sonar.systems.EntityAssemblySys;

import utils.Geo;
import utils.Polygon;
import gml.vector.Vec2f;
import utils.Math2;

using utils.RadianHelper;

class SonarSys extends EntitySystem
{
    public function new() {
        super( Aspect.getAspectForAll( [PosCmp, SonarCmp, TimedEffectCmp] ) );
    }

    override public function initialize() : Void {
        posMapper         = world.getMapper ( PosCmp );
        timedEffectMapper = world.getMapper ( TimedEffectCmp );
        sonarMapper       = world.getMapper ( SonarCmp );
        regionMapper      = world.getMapper ( RegionCmp );
        containerMgr      = world.getManager( ContainerMgr );
        entityAssembler   = world.getSystem ( EntityAssemblySys );
    }

    override public function onInserted( e : Entity ) : Void {
        trace( "now we have " + actives.size + " active sonars." );
    }

    override public function onRemoved( e : Entity ) : Void {
        trace( "now we have " + actives.size + " active sonars." );
    }

    override public function processEntities( entities : Bag<Entity> ) : Void  {
        var e : Entity;

        var time : TimedEffectCmp;
        var sonar : SonarCmp;
        var center : Vec2f;
        var sector : Entity;

        for ( i in 0...actives.size ) {
            e = actives.get( i );
            time = timedEffectMapper.get( e );
            sonar = sonarMapper.get( e );
            center = posMapper.get( e ).pos;

            dbgtrace( time.processState );
            switch( time.processState ) {
                case Process( false ):
                    var radius : Float = sonar.growthRate * ( time.internalAcc / 1000.0 );
                    if ( radius > sonar.maxRadius ) {
                        radius = sonar.maxRadius;
                    }

                    var sector = posMapper.get( e ).sector;
                    var sectorPolys = regionMapper.get( sector ).polys;

                    // check for intersection against player entities
                    for ( e in containerMgr.getAllEntitiesOfContainer( sector ) ) {
                        if ( e.id == sonar.playerId ) continue; //skip me
                        var p : Vec2f = posMapper.get( e ).pos;
                        if ( Geo.isPointInCircle( { center: center, radius: radius }, p ) ) {
                            entityAssembler.createTrace( sector, Mass( p, 3 ) );
                        }
                    }

                    // reveal portions of the sector walls that are "hit" by sonar
                    for ( poly in sectorPolys ) {
                        for ( k in 0...poly.verts.length - 1 ) {
                            // do an intersection test against each edge of the polygon; create a trace for each intersection occurrence
                            var intersect = Geo.lineCircleIntersect( { center: center, radius: radius }, { a: poly.verts[k], b: poly.verts[k + 1] } ); //wrap
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

                                    dbgtrace( "-------starting to cull ranges---------: " );
                                    dbgtrace( "for " + Line( p, q ) );
                                    dbgtrace( "already " + sonar.cullRanges.length + " segments to cull" );
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
#if debug
                                                        dbgtrace( "reconstructed range " + rngToString( rng ) );
                                                        dbgtrace( "new ranges: " + rngToString( { start: rng.start, end: orng.start } ) + " and " + rngToString( { start: orng.end, end: rng.end } ) );
                                                    } else {
                                                        dbgtrace( "error reconstructing range " + rngToString( rng ) );
#end
                                                    }
                                                //rng   ===---
                                                //orng  ----
                                                } else if ( radianDiff( orng.start, rng.start ) >= 0 && radianDiff( orng.end, rng.start ) < 0 && radianDiff( orng.end, rng.end ) > error ) {
                                                    ranges.push( { start: orng.end, end: rng.end } );
                                                    if ( ranges.remove( rng ) ) {
                                                        tryAgain = true;
#if debug
                                                        dbgtrace( "reconstructed range " + rngToString( rng ) );
                                                        dbgtrace( "new range: " + rngToString( { start: orng.end, end: rng.end } ) );
                                                    } else {
                                                        dbgtrace( "error reconstructing range " + rngToString( rng ) );
#end
                                                    }
                                                //rng  ----===
                                                //orng   -----
                                                } else if ( radianDiff( orng.start, rng.start ) < -error && radianDiff( orng.start, rng.end ) > 0 && radianDiff( orng.end, rng.end ) <= 0 ) {
                                                    ranges.push( { start: rng.start, end: orng.start } );
                                                    if ( ranges.remove( rng ) ) {
                                                        tryAgain = true;
#if debug
                                                        dbgtrace( "reconstructed range " + rngToString( rng ) );
                                                        dbgtrace( "new range: " + rngToString( { start: rng.start, end: orng.start } ) );
                                                    } else {
                                                        dbgtrace( "error reconstructing range " + rngToString( rng ) );
#end
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    sonar.cullRanges = sonar.cullRanges.concat( ranges );
#if debug
                                    dbgtrace( "-------ranges to draw---------: " );
#end
                                    for ( rng in ranges ) {
#if debug
                                        dbgtrace( rngToString( rng ) );
#end
                                        function radianToPoint( origin, theta, invertedY : Bool = true ) : Vec2f {
                                            var direction = new Vec2f( Math.sin( theta ), invertedY ? -Math.cos( theta ) : Math.cos( theta ) );

                                            switch ( Math2.getRayLineIntersection( { origin: origin, direction: direction }, { a: poly.verts[k], b: poly.verts[k + 1] } ) ) {
                                                case Point( point ): return point;
                                                default: return null;
                                            }
                                        }

                                        var a = radianToPoint( center, rng.start );
                                        var b = radianToPoint( center, rng.end );

                                        if ( a != null && b != null ) {
                                            entityAssembler.createTrace( sector, Line( a, b ) );
#if debug
                                        } else {
                                            dbgtrace( "this range could not be created" );
#end
                                        }
                                    }
                                case Point( p ):
                                    entityAssembler.createTrace( sector, Point( p ) );
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

#if debug
            dbgtrace("----culled range list----");
            for ( s in sonar.cullRanges ) {
                dbgtrace( rngToString( s ) );
            }
#end
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

    private function pointToRadian( center: Vec2f, point: Vec2f, invertedY : Bool = true ): Float {
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

    private function dbgtrace( str : Dynamic ) {
        if ( false ) {
            trace( str );
        }
    }

    var timedEffectMapper : ComponentMapper<TimedEffectCmp>;
    var sonarMapper       : ComponentMapper<SonarCmp>;
    var posMapper         : ComponentMapper<PosCmp>;
    var regionMapper      : ComponentMapper<RegionCmp>; // need to extract region polys from sector

    var entityAssembler   : EntityAssemblySys;

    var containerMgr      : ContainerMgr;
}
