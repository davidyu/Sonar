package ;

import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.Lib;
import gibber.God;

import h3d.scene.*;

#if debug
import com.sociodox.theminer.TheMiner;
#end

using gibber.Util;

class Main 
{
    static var engine : h3d.Engine;
    static var scene : h3d.scene.Scene;
    static var backscene : h2d.Scene;
    static var framebuffer : h2d.Sprite; // accumulator
    static var renderTarget : h2d.Tile; // intermediate
	static var time : Float;
    static var obj : h3d.scene.Mesh;

    static function update()
    {
        backscene.captureBitmap( renderTarget );
        engine.render( scene );
    }

    static function main()
    {
		time = 0;
        engine = new h3d.Engine();
        scene = new h3d.scene.Scene();
        backscene = new h2d.Scene();

        engine.onReady = function() {
            function p2( x : Int ) {
                var i = 1;
                while ( x > i ) {
                    i <<= 1;
                }
                return i;
            }

            var prim = new h3d.prim.Plan3D();
            var bmd = new hxd.BitmapData( p2( engine.width ), p2( engine.height ) );
            renderTarget = h2d.Tile.fromBitmap( bmd );

            // var tex = renderTarget.getTexture();
            var tex = h3d.mat.Texture.fromColor( 0xffffffff );
            var mat = new h3d.mat.MeshMaterial( tex );
            mat.depthWrite = false;
            mat.culling = None;

            scene.camera.pos.set( 0, 0, -10. );
            scene.camera.up.set( 0., 1, 0 );
            scene.camera.target.set( 0, 0, 0 );
            scene.camera.update();

            mat.lightSystem = {
                ambient : new h3d.Vector(0, 0, 0),
                dirs : [{ dir : new h3d.Vector(-0.3,-0.5,-1), color : new h3d.Vector(1,1,1) }],
                points : [{ pos : new h3d.Vector(1.5,0,0), color : new h3d.Vector(3,0,0), att : new h3d.Vector(0,0,1) }],
            }

            obj = new Mesh( prim, mat, scene );

            framebuffer = new h2d.Sprite( backscene );
            framebuffer.x = 0;
            framebuffer.y = 0;

            trace( "Starting up God" );
            var g = new God( Lib.current, framebuffer );

            hxd.System.setLoop( update );
        }

        engine.debug = true;
        engine.init();
        var stage = Lib.current.stage;
        stage.scaleMode = StageScaleMode.NO_SCALE;
        stage.align = StageAlign.TOP_LEFT;
        // entry point
#if debug
        stage.addChild( new TheMiner() );
#end
    }
}
