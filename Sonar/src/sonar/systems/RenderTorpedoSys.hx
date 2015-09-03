package sonar.systems;

import com.artemisx.Aspect;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import com.artemisx.EntitySystem;
import com.artemisx.utils.Bag;

import flash.geom.ColorTransform;

import flash.display.BitmapData;
import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Bitmap;

import sonar.components.PosCmp;
import sonar.components.PosTrackerCmp;
import sonar.components.RenderCmp;
import sonar.components.TorpedoCmp;

import utils.Render;
import utils.Vec2;

using Lambda;

class RenderTorpedoSys extends EntitySystem
{
    public function new( quad : h2d.Sprite ) {
        super( Aspect.getAspectForAll( [TorpedoCmp, RenderCmp, PosCmp, PosTrackerCmp] ) );
        g2d = new h2d.Graphics( quad );
    }

    override public function initialize() : Void {
        posMapper         = world.getMapper( PosCmp );
        posTrackerMapper  = world.getMapper( PosTrackerCmp );
        torpedoMapper     = world.getMapper( TorpedoCmp );
        compensatingFades = 30;
    }

    public function setCamera( e : Entity ) : Void {
        camera = e;
    }

    override public function processEntities( entities : Bag<Entity> ) : Void  {
        var e : Entity;
        var torpedo : TorpedoCmp;
        var pos : PosCmp;
        var posTracker : PosTrackerCmp;
        var lastScreenPos : Vec2;
        var curScreenPos : Vec2;

        if ( actives.size > 0 || compensatingFades > 0 ) {
            g2d.clear();
            compensatingFades--;
        }

        if ( camera == null ) return;

        for ( i in 0...actives.size ) {
            e = actives.get( i );
            torpedo = torpedoMapper.get( e );
            pos = posMapper.get( e );
            posTracker = posTrackerMapper.get( e );

            lastScreenPos = Util.toScreen( SectorCoordinates( posTracker.getLastPosition(), pos.sector ), camera );
            curScreenPos = Util.toScreen( SectorCoordinates( pos.pos, pos.sector ), camera );

            function drawLine( p1, p2, dx = 1, dy = 1 ) {
                g2d.beginFill( 0xff0000 );
                g2d.lineStyle( 0 );
                g2d.addPoint( p1.x, p1.y );
                g2d.addPoint( p2.x, p2.y );
                g2d.addPoint( p2.x + dx, p2.y + dy );
                g2d.addPoint( p1.x + dx, p1.y + dy );
                g2d.endFill();
            }

            if ( curScreenPos.x > lastScreenPos.x ) { // right hemisphere
                var dy = Math.abs( curScreenPos.y - lastScreenPos.y ),
                    dx = Math.abs( curScreenPos.x - lastScreenPos.x );
                if ( curScreenPos.y < lastScreenPos.y ) { // top right quadrant
                    if ( dy > dx ) { // top octant
                        drawLine( curScreenPos, lastScreenPos, 1, 0 );
                    } else { // bottom octant
                        drawLine( curScreenPos, lastScreenPos, 0, 1 );
                    }
                } else { // bottom right quadrant
                    if ( dy > dx ) { // bottom octant
                        drawLine( curScreenPos, lastScreenPos, 1, 0 );
                    } else { // top octant
                        drawLine( curScreenPos, lastScreenPos, 0, 1 );
                    }
                }
            } else { // left hemisphere
                var dy = Math.abs( curScreenPos.y - lastScreenPos.y ),
                    dx = Math.abs( curScreenPos.x - lastScreenPos.x );
                if ( curScreenPos.y < lastScreenPos.y ) { // top left quadrant
                    if ( dy > dx ) { // top octant
                        drawLine( curScreenPos, lastScreenPos, -1, 0 );
                    } else { // bottom octant
                        drawLine( curScreenPos, lastScreenPos, 0, -1 );
                    }
                } else { // bottom left quadrant
                    if ( dy > dx ) { // bottom octant
                        drawLine( curScreenPos, lastScreenPos, -1, 0 );
                    } else { // top octant
                        drawLine( curScreenPos, lastScreenPos, 0, -1 );
                    }
                }
            }

            compensatingFades = 30; // in case this is the final active entity; force the system to apply a few more fades before short-circuiting
        }
    }

    var renderMapper      : ComponentMapper<RenderCmp>;
    var torpedoMapper     : ComponentMapper<TorpedoCmp>;
    var posMapper         : ComponentMapper<PosCmp>;
    var posTrackerMapper  : ComponentMapper<PosTrackerCmp>;

    private var compensatingFades : Int;
    private var g2d    : h2d.Graphics;

    private var camera : Entity;
}
