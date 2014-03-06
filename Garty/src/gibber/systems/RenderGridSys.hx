package gibber.systems;

import com.artemisx.Aspect;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import com.artemisx.EntitySystem;
import com.artemisx.utils.Bag;

import gibber.components.BoundCmp;
import gibber.components.CameraCmp;
import gibber.components.PosCmp;
import gibber.components.RenderCmp;

import gibber.Util;

import utils.Vec2;
import utils.Render;

import h2d.Tile;

using Lambda;

class RenderGridSys extends EntitySystem
{
    public function new( quad : h2d.Sprite ) {
        super( Aspect.getAspectForAll( [BoundCmp, PosCmp, RenderCmp] ) );
        g2d = new h2d.Graphics( quad );
    }

    override public function initialize() : Void {
        posMapper = world.getMapper( PosCmp );
        cameraMapper = world.getMapper( CameraCmp );
        boundMapper  = world.getMapper( BoundCmp );
        renderMapper = world.getMapper( RenderCmp );
    }

    public function setCamera( e : Entity ) : Void {
        camera = e;
    }

    override public function processEntities( entities : Bag<Entity> ) : Void  {
        var e : Entity;
        var render : RenderCmp;

        g2d.clear();

        if ( camera == null ) return;

        for ( i in 0...actives.size ) {
            e = actives.get( i );
            render = renderMapper.get( e );

            var pos = posMapper.get( e ).pos;
            var offset = pos.sub( posMapper.get( camera ).pos );

            // capture w and h of grid cell for use...ugh
            var bound : { w : Float, h : Float } = switch( boundMapper.get( e ).bound ) {
                case Rect( w, h ): { w: w, h: h };
                default: { w : 5, h : 5 };
            };

            var screenW = flash.Lib.current.stage.stageWidth;
            var screenH = flash.Lib.current.stage.stageHeight;

            // horizontal gridlines
            for ( h in -2...Std.int( screenH / bound.h ) + 2 ) {
                g2d.beginFill( render.colour );
                g2d.drawRect( offset.x, h * bound.h + offset.y, screenW + 4 * bound.w, 1 );
                g2d.endFill();
            }

            // vertical gridlines
            for ( v in -2...Std.int( screenW / bound.w ) + 2 ) {
                g2d.beginFill( render.colour );
                g2d.drawRect( v * bound.w + offset.x, offset.y, 1, screenH + 4 * bound.h );
                g2d.endFill();
            }
        }
    }

    var boundMapper  : ComponentMapper<BoundCmp>;
    var posMapper : ComponentMapper<PosCmp>;
    var cameraMapper : ComponentMapper<CameraCmp>;
    var renderMapper : ComponentMapper<RenderCmp>;

    private var g2d : h2d.Graphics;
    private var compensatingClear : Bool;
    private var camera : Entity;
}
