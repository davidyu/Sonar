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

import sonar.components.CameraCmp;
import sonar.components.PosCmp;
import sonar.components.PosTrackerCmp;
import sonar.components.RenderCmp;
import sonar.components.TrailCmp;

import sonar.Util;

import utils.Render;
import gml.vector.Vec2f;

using Lambda;

class RenderTrailSys extends EntitySystem
{
    public function new( quad : h2d.Sprite ) {
        super( Aspect.getAspectForAll( [TrailCmp, RenderCmp] ) );

        var trailExclusiveBuffer = new h2d.Sprite( quad );
        g2d = new h2d.Graphics( trailExclusiveBuffer );
    }

    override public function initialize() : Void {
        posMapper           = world.getMapper( PosCmp );
        renderMapper        = world.getMapper( RenderCmp );
        posTrackerMapper    = world.getMapper( PosTrackerCmp );
        trailMapper         = world.getMapper( TrailCmp );
        compensatingFades   = 30;
    }

    public function setCamera( e : Entity ) : Void {
        camera = e;
    }

    override public function processEntities( entities : Bag<Entity> ) : Void  {
        var e : Entity;
        var render : RenderCmp;
        var trail : TrailCmp;
        var pos : PosCmp;
        var posTracker : PosTrackerCmp;
        var lastScreenPos : Vec2f;
        var curScreenPos : Vec2f;

        if ( camera == null ) return;

        if ( actives.size > 0 || compensatingFades > 0 ) {
            // draw transluscent gray rect over (visible) screen, plus some buffer just in case we scroll
            g2d.clear();
            compensatingFades--;
        }

        for ( i in 0...actives.size ) {
            e   = actives.get( i );
            trail = trailMapper.get( e );
            pos = posMapper.get( e );
            posTracker = posTrackerMapper.get( e );
            render = renderMapper.get( e );

            lastScreenPos = Util.toScreen( SectorCoordinates( posTracker.getLastPosition(), pos.sector ), camera );
            curScreenPos = Util.toScreen( SectorCoordinates( pos.pos, pos.sector ), camera );

            function drawLine( p1: Vec2f, p2: Vec2f, dx = 1, dy = 1 ) {
                g2d.beginFill( 0xffffff );
                g2d.lineStyle( 0 );
                g2d.addPoint( p1.x, p1.y );
                g2d.addPoint( p2.x, p2.y );
                g2d.addPoint( p2.x + dx, p2.y + dy );
                g2d.addPoint( p1.x + dx, p1.y + dy );
                g2d.endFill();
            }

            // place lastScreenPos in center, use curScreenPos to categorize into octants
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
    var trailMapper       : ComponentMapper<TrailCmp>;
    var posMapper         : ComponentMapper<PosCmp>;
    var posTrackerMapper  : ComponentMapper<PosTrackerCmp>;

    private var compensatingFades : Int;
    private var g2d    : h2d.Graphics;

    private var camera : Entity;
}
