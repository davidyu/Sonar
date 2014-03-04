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

class PostEffectsShader extends h3d.impl.Shader {
#if flash 
    static var SRC = {
        var input : {
            pos : Float3,
            uv : Float2,
        };

        var tuv : Float2;

        function vertex( mproj:Matrix ) {
            out = input.pos.xyzw*mproj;
            tuv =  input.uv;
        }

        function fragment( tex : Texture ) {
            var c : Float4 = [ 0, 0, 0, 1. ];
            c.r = tex.get([ tuv.x - 0.003, tuv.y ] ).r;
            c.g = tex.get([ tuv.x, tuv.y ] ).g;
            c.b = tex.get([ tuv.x + 0.003, tuv.y ] ).b;
            out = c;
        }
    };

#else
static var VERTEX = "
    attribute vec3 pos;
    uniform mat4 mproj;
    attribute vec2 uv;

    varying vec2 tuv;

    void main(void) {
        gl_Position = vec4(pos,1)*mproj;
        tuv = uv;
    }";

static var FRAGMENT = "
    uniform sampler2D tex;
    varying vec2 tuv;
    void main(void) {
        gl_FragColor = texture2D(tex, tuv);
        //gl_FragColor = vec4(1,1,1,1);
    }
";
#end
}

class PostEffectsMaterial extends h3d.mat.Material{
    public var tex : h3d.mat.Texture;
    var pshader : PostEffectsShader;

    public function new(tex) {
        this.tex = tex;
        pshader = new PostEffectsShader();
        depthTest = h3d.mat.Data.Compare.Always;
        culling = None;

        super( pshader );
    }

    override function setup( ctx : h3d.scene.RenderContext ) {
        super.setup(ctx);
        pshader.tex = tex;
        pshader.mproj = ctx.camera.m;
    }
}

class Screen extends CustomObject {

    public var tex(get,set) : h3d.mat.Texture;
    var sm : PostEffectsMaterial;

    public function new( tex : h3d.mat.Texture, parent )
    {
        var prim = new h3d.prim.Cube();
        prim.translate( -0.5, -0.5, -0.5);
        prim.addUVs();
        prim.addNormals();

        super( prim, sm = new PostEffectsMaterial( tex ), parent );
    }

    function get_tex() {
        return sm.tex;
    }

    function set_tex( v ) {
        return sm.tex = v;
    }
}

class Main 
{
    static var engine : h3d.Engine;
    static var scene : h3d.scene.Scene;
    static var backscene : h2d.Scene;
    static var framebuffer : h2d.Sprite; // accumulator
    static var renderTarget : h2d.Tile; // intermediate
	static var time : Float;

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

            var prim = new h3d.prim.Cube();
            prim.translate( -0.5, -0.5, -0.5);
            prim.addUVs();
            prim.addNormals();

            var bmd = new hxd.BitmapData( p2( engine.width ), p2( engine.height ) );
            renderTarget = h2d.Tile.fromBitmap( bmd );

            var tex = renderTarget.getTexture();

            // sanity check
            // var tex = h3d.mat.Texture.fromColor( 0xffffffff );
            var screen = new Screen( tex, scene );

            scene.camera.pos.set( 0, 0, 1. );

            // make orthographic camera bounds just at the edges of the cube
            scene.camera.orthoBounds = new h3d.col.Bounds();
            scene.camera.orthoBounds.xMin = -0.5;
            scene.camera.orthoBounds.yMin = -0.5;
            scene.camera.orthoBounds.xMax =  0.5;
            scene.camera.orthoBounds.yMax =  0.5;

            scene.camera.up.set( 0, -1, 0 );
            scene.camera.target.set( 0, 0, 0 );

            scene.camera.update();

            /*
            scene.camera.pos.set( 0, 0, 1.375 ); // ***
            scene.camera.update();
            */

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
