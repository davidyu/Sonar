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
    // hacky hack hack
    @:isVar public var torpedoCoolingDown = false;
    @:isVar public var blipCoolingDown = false;
    @:isVar public var pingCoolingDown = false;

    public function new( god: God, quad : h2d.Sprite ) {
        super();
        this.quad = quad;
        this.god = god;
    }

    override public function initialize() : Void {
        hxd.Res.loader = new hxd.res.Loader( hxd.res.EmbedFileSystem.create() );

        hudProggyFont = hxd.Res.ProggyTinySZ.build( 15, { antiAliasing: false } );
        hudPressStartFont = hxd.Res.PressStart2P.build( 8, { antiAliasing: false } );

        hudPlayersConnected = new h2d.Text( hudProggyFont, quad );
        hudPlayersConnected.x = 20;
        hudPlayersConnected.y = 20;

        hudReloadStatus = new h2d.Text( hudPressStartFont, quad );
        hudReloadStatus.x = 350;
        hudReloadStatus.y = 20;
    }


    override public function processSystem() : Void  {
        hudPlayersConnected.text = "Players connected: " + ( god.netPlayers.length + 1 );
        hudReloadStatus.text = "Torpedo: " + ( torpedoCoolingDown ? "reloading..." : "READY" ) + "\n" +
                               "Sonar  : " + ( blipCoolingDown ? "cooling..." : "READY" ) + "\n" +
                               "Ping   : " + ( pingCoolingDown ? "cooling..." : "READY" );
    }

    var hudProggyFont : h2d.Font;
    var hudPressStartFont: h2d.Font;
    var quad : h2d.Sprite;
    var hudPlayersConnected : h2d.Text;
    var hudReloadStatus : h2d.Text;
    var god : God;
}
