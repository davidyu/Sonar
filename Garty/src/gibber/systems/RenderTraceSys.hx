package gibber.systems;

import com.artemisx.Aspect;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import com.artemisx.EntitySystem;
import com.artemisx.utils.Bag;

import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Sprite;

import gibber.components.RenderCmp;
import gibber.components.TraceCmp;

class RenderTraceSys extends EntitySystem
{
    public function new( root : MovieClip ) {
        super( Aspect.getAspectForAll( [TraceCmp, RenderCmp] ) );

        buffer = new Sprite();
        this.root = root;

        root.addChild( buffer );
    }

    override public function initialize() : Void {
        renderMapper = world.getMapper( RenderCmp );
        traceMapper  = world.getMapper( TraceCmp );
    }

    override public function onInserted( e : Entity ) : Void {
        var renderCmp = renderMapper.get( e );
        renderCmp.sprite = new Sprite();
        root.addChild( renderCmp.sprite );
    }

    override public function onRemoved( e : Entity ) : Void {
        root.removeChild( renderMapper.get( e ).sprite );
    }

    override public function processEntities( entities : Bag<Entity> ) : Void  {
        var e : Entity;
        var render : RenderCmp;
        var trace : TraceCmp;

        for ( i in 0...actives.size ) {
            e = actives.get( i );
            render = renderMapper.get( e );
            trace = traceMapper.get( e );

            render.sprite.x = trace.pos.x;
            render.sprite.y = trace.pos.y;

            var g = render.sprite.graphics;
            g.clear();

            switch ( trace.traceType ) {
                case Line( a, b ):
                    g.lineStyle( 1, render.colour, trace.fadeAcc );
                    g.moveTo( a.x, a.y );
                    g.lineTo( b.x, b.y );
                case Point( p ):
                    g.beginFill( render.colour, trace.fadeAcc );
                    g.drawCircle( p.x, p.y, 1 );
                case None: throw "You should not have a trace of type None! What is going on?";
            }
        }
    }

    var renderMapper : ComponentMapper<RenderCmp>;
    var traceMapper  : ComponentMapper<TraceCmp>;

    private var root   : MovieClip;
    private var buffer : Sprite;
}
