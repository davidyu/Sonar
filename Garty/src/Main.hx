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

            var pts = new Array<h3d.col.Point>();
            pts.push( new h3d.col.Point( -1,  1, 0 ) );
            pts.push( new h3d.col.Point(  1,  1, 0 ) );
            pts.push( new h3d.col.Point(  1, -1, 0 ) );
            //pts.push( new h3d.col.Point( -1,  1, 0 ) );
            //pts.push( new h3d.col.Point(  1, -1, 0 ) );
            pts.push( new h3d.col.Point( -1, -1, 0 ) );

            var uvs = new Array<h3d.prim.UV>();
            uvs.push( new h3d.prim.UV( 0, 0 ) );
            uvs.push( new h3d.prim.UV( 1, 0 ) );
            uvs.push( new h3d.prim.UV( 1, 1 ) );
            //uvs.push( new h3d.prim.UV( 0, 0 ) );
            //uvs.push( new h3d.prim.UV( 0, 1 ) );
            uvs.push( new h3d.prim.UV( 0, 1 ) );

            var normals = new Array<h3d.col.Point>();
            normals.push( new h3d.col.Point( 0, 0, 1 ) );
            normals.push( new h3d.col.Point( 0, 0, 1 ) );
            normals.push( new h3d.col.Point( 0, 0, 1 ) );
            //normals.push( new h3d.col.Point( 0, 0, 1 ) );
            //normals.push( new h3d.col.Point( 0, 0, 1 ) );
            normals.push( new h3d.col.Point( 0, 0, 1 ) );

            // var prim = new h3d.prim.Quads( pts, uvs, normals );
            var prim = new h3d.prim.Cube();
            prim.translate( -0.5, -0.5, -0.5);
            prim.addUVs();
            prim.addNormals();
            var bmd = new hxd.BitmapData( p2( engine.width ), p2( engine.height ) );
            renderTarget = h2d.Tile.fromBitmap( bmd );

            var tex = renderTarget.getTexture();

            // sanity check
            // var tex = h3d.mat.Texture.fromColor( 0xffffffff );
            var mat = new h3d.mat.MeshMaterial( tex );

            scene.camera.pos.set( 0, 0, 1.375 ); // ***
            scene.camera.up.set( 0, -1, 0 );
            scene.camera.target.set( 0, 0, 0 );
            scene.camera.update();

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
