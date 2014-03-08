package gibber.systems;

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

import gibber.components.CameraCmp;
import gibber.components.PosCmp;
import gibber.components.PosTrackerCmp;
import gibber.components.RenderCmp;
import gibber.components.TrailCmp;

import gibber.Util;

import utils.Render;
import utils.Vec2;

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
        var lastScreenPos : Vec2;
        var curScreenPos : Vec2;

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

            lastScreenPos = Util.screenCoords( posTracker.getLastPosition(), camera, pos.sector );
            curScreenPos = Util.screenCoords( pos.pos, camera, pos.sector );

            g2d.beginFill( 0xffffff );
            g2d.lineStyle( 0 );
            g2d.addPoint( lastScreenPos.x, lastScreenPos.y );
            g2d.addPoint( curScreenPos.x, curScreenPos.y );
            g2d.addPoint( curScreenPos.x + 1, curScreenPos.y + 1 );
            g2d.addPoint( lastScreenPos.x + 1, lastScreenPos.y + 1 );
            g2d.endFill();

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
