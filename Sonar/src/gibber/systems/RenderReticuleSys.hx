package gibber.systems;

import com.artemisx.Aspect;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import com.artemisx.EntitySystem;
import com.artemisx.utils.Bag;

import gibber.components.RenderCmp;
import gibber.components.ReticuleCmp;

class RenderReticuleSys extends EntitySystem
{
    public function new( quad : h2d.Sprite ) {
        super( Aspect.getAspectForAll( [ReticuleCmp, RenderCmp] ) );

        g2d = new h2d.Graphics( quad );
    }

    private var g2d  : h2d.Graphics;
}
