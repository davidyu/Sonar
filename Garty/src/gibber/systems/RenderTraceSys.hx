package gibber.systems;

import com.artemisx.Aspect;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import com.artemisx.EntitySystem;
import com.artemisx.utils.Bag;

import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Sprite;

import gibber.components.CameraCmp;
import gibber.components.PosCmp;
import gibber.components.RenderCmp;
import gibber.components.TraceCmp;

class RenderTraceSys extends EntitySystem
{
    public function new( quad : h2d.Sprite ) {
        super( Aspect.getAspectForAll( [TraceCmp, RenderCmp] ) );

        g2d = new h2d.Graphics( quad );
    }

    override public function initialize() : Void {
        cameraMapper = world.getMapper( CameraCmp );
        renderMapper = world.getMapper( RenderCmp );
        traceMapper  = world.getMapper( TraceCmp );
        posMapper    = world.getMapper( PosCmp );
    }

    public function setCamera( e : Entity ) : Void {
        camera = e;
    }

    override public function processEntities( entities : Bag<Entity> ) : Void  {
        var e : Entity;
        var render : RenderCmp;
        var trace : TraceCmp;
        var pos : PosCmp;

        if ( actives.size > 0 || compensatingClear ) {
            g2d.clear();
        }

        if ( camera == null ) {
            trace( "didn't acquire camera! This won't work." );
        }

        for ( i in 0...actives.size ) {
            compensatingClear = true;
            e = actives.get( i );
            render = renderMapper.get( e );
            trace = traceMapper.get( e );
            pos = posMapper.get( e );

            switch ( trace.traceType ) {
                case Line( a, b ):
                    function drawLine( p1, p2, dx = 1, dy = 1 ) {
                        g2d.beginFill( render.colour, trace.fadeAcc );
                        g2d.lineStyle( 0 );
                        g2d.addPoint( p1.x, p1.y );
                        g2d.addPoint( p2.x, p2.y );
                        g2d.addPoint( p2.x + dx, p2.y + dy );
                        g2d.addPoint( p1.x + dx, p1.y + dy );
                        g2d.endFill();
                    }

                    var aa = Util.screenCoords( a, camera, pos.sector );
                    var bb = Util.screenCoords( b, camera, pos.sector );

                    if ( aa.x > bb.x ) { // right hemisphere
                        var dy = Math.abs( aa.y - bb.y ),
                            dx = Math.abs( aa.x - bb.x );
                        if ( aa.y < bb.y ) { // top right quadrant
                            if ( dy > dx ) { // top octant
                                drawLine( aa, bb, 1, 0 );
                            } else { // bottom octant
                                drawLine( aa, bb, 0, 1 );
                            }
                        } else { // bottom right quadrant
                            if ( dy > dx ) { // bottom octant
                                drawLine( aa, bb, 1, 0 );
                            } else { // top octant
                                drawLine( aa, bb, 0, 1 );
                            }
                        }
                    } else { // left hemisphere
                        var dy = Math.abs( aa.y - bb.y ),
                            dx = Math.abs( aa.x - bb.x );
                        if ( aa.y < bb.y ) { // top left quadrant
                            if ( dy > dx ) { // top octant
                                drawLine( aa, bb, -1, 0 );
                            } else { // bottom octant
                                drawLine( aa, bb, 0, -1 );
                            }
                        } else { // bottom left quadrant
                            if ( dy > dx ) { // bottom octant
                                drawLine( aa, bb, -1, 0 );
                            } else { // top octant
                                drawLine( aa, bb, 0, -1 );
                            }
                        }
                    }

                    g2d.addPoint( aa.x, aa.y );
                    g2d.addPoint( bb.x, bb.y );
                    g2d.addPoint( bb.x + 1, bb.y + 1 );
                    g2d.addPoint( aa.x + 1, aa.y + 1 );
                case Point( p ):
                    g2d.beginFill( render.colour, trace.fadeAcc );
                    g2d.lineStyle( 0 );
                    var pp = Util.screenCoords( p, camera, pos.sector );
                    g2d.drawCircle( pp.x, pp.y, 1 );
                    g2d.endFill();
                case Mass( p, r ):
                    g2d.beginFill( render.colour, trace.fadeAcc );
                    g2d.lineStyle( 0 );
                    var pp = Util.screenCoords( p, camera, pos.sector );
                    g2d.drawCircle( pp.x, pp.y, r );
                    g2d.endFill();
            }
        }
    }

    var renderMapper : ComponentMapper<RenderCmp>;
    var traceMapper  : ComponentMapper<TraceCmp>;
    var posMapper    : ComponentMapper<PosCmp>;
    var cameraMapper : ComponentMapper<CameraCmp>;

    private var g2d  : h2d.Graphics;
    private var compensatingClear : Bool;
    private var camera : Entity;
}
