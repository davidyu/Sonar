package sonar.systems;

import com.artemisx.Aspect;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import com.artemisx.EntitySystem;
import com.artemisx.utils.Bag;

import sonar.components.BoundCmp;
import sonar.components.CameraCmp;
import sonar.components.PosCmp;

import utils.Vec2;

class GridSys extends EntitySystem
{
    public function new() {
        super( Aspect.getAspectForOne( [BoundCmp, CameraCmp] ) );
    }

    override public function initialize() : Void {
        boundMapper  = world.getMapper( BoundCmp );
        cameraMapper = world.getMapper( CameraCmp );
        posMapper    = world.getMapper( PosCmp );
    }

    // wrap the position of the grid reference entity such that it always contains
    // the camera. We can then refer to the position to calculate an offset when drawing
    // the grid in screen-space

    // this is a bit WTF-y, so don't lose sleep trying to reunderstand it (rewrite it if it
    // becomes too confusing in the future; there are definitely better ways to do this)
    override public function processEntities( entities : Bag<Entity> ) : Void  {
        var e : Entity;
        var cameraPosc : PosCmp = null;

        for ( i in 0...actives.size ) {
            e = actives.get( i );
            if ( cameraMapper.get( e ) != null ) {
                cameraPosc = posMapper.get( e );
            }
        }

        if ( cameraPosc == null ) return;

        for ( i in 0...actives.size ) {

            e = actives.get( i );
            if ( boundMapper.get( e ) != null ) {

                var boundPosc = posMapper.get( e );
                if ( cameraPosc.sector == boundPosc.sector ) {
                    var cameraPos = cameraPosc.pos;
                    var boundPos = boundPosc.pos;

                    switch ( boundMapper.get( e ).bound ) {
                        case Rect( w, h ):
                            if ( cameraPos.x < boundPos.x ) boundPos.x = cameraPos.x - w;
                            if ( cameraPos.x > boundPos.x + w ) boundPos.x = cameraPos.x;
                            if ( cameraPos.y < boundPos.y ) boundPos.y = cameraPos.y - h;
                            if ( cameraPos.y > boundPos.y + h ) boundPos.y = cameraPos.y;
                        default:
                    }
                }
            }
        }
    }

    var boundMapper  : ComponentMapper<BoundCmp>;
    var cameraMapper : ComponentMapper<CameraCmp>;
    var posMapper    : ComponentMapper<PosCmp>;
}
