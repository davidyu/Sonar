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

    override public function onInserted( e : Entity ) : Void {
    }

    override public function onRemoved( e : Entity ) : Void {
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
                    g2d.beginFill( render.colour, trace.fadeAcc );
                    g2d.lineStyle( 0 );
                    // needs to be fixed!
                    var aa = Util.worldCoords( a, pos.sector ).sub( posMapper.get( camera ).pos );
                    var bb = Util.worldCoords( b, pos.sector ).sub( posMapper.get( camera ).pos );
                    g2d.addPoint( aa.x, aa.y );
                    g2d.addPoint( bb.x, bb.y );
                    g2d.addPoint( bb.x + 1, bb.y + 1 );
                    g2d.addPoint( aa.x + 1, aa.y + 1 );
                    g2d.endFill();
                case Point( p ):
                    g2d.beginFill( render.colour, trace.fadeAcc );
                    g2d.lineStyle( 0 );
                    var pp = Util.worldCoords( p, pos.sector ).sub( posMapper.get( camera ).pos );
                    g2d.drawCircle( pp.x, pp.y, 1 );
                    g2d.endFill();
                case Mass( p, r ):
                    g2d.beginFill( render.colour, trace.fadeAcc );
                    g2d.lineStyle( 0 );
                    var pp = Util.worldCoords( p, pos.sector ).sub( posMapper.get( camera ).pos );
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
