package gibber.systems;

import com.artemisx.Aspect;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import com.artemisx.systems.VoidEntitySystem;
import com.artemisx.utils.Bag;

import gibber.components.PosCmp;
import gibber.components.RenderCmp;

import gibber.Util;

import utils.Render;

using Lambda;

class RenderHUDSys extends VoidEntitySystem
{
    public function new( god: God, quad : h2d.Sprite ) {
        super();
        this.quad = quad;
        this.god = god;
    }

    override public function initialize() : Void {
        hxd.Res.loader = new hxd.res.Loader( hxd.res.EmbedFileSystem.create() );
        hudProggyFont = hxd.Res.ProggyTinySZ.build( 15, { antiAliasing: false } );
        tf = new h2d.Text( hudProggyFont, quad );
        tf.x = 20;
        tf.y = 20;
    }

    override public function processSystem() : Void  {
        tf.text = "Players connected: " + ( god.netPlayers.length + 1 );
    }

    var hudProggyFont : h2d.Font;
    var quad : h2d.Sprite;
    var tf : h2d.Text;
    var god : God;
}
