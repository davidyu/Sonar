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

class PostEffectsShader extends hxsl.Shader {

#if flash 
    static var SRC = {
        @input var input : {
            pos : Vec3,
            uv : Vec2,
        };

        @global var camera : {
            var proj : Mat4;
        };

        var output : {
            var position : Vec4;
            var color : Vec4;
        };

        var tuv : Vec2;
        var time : Float;
        var screenres : Vec2;
        @param var tex : Sampler2D;

        function vertex() {
            output.position = vec4( input.pos.xyz, 1 ) * camera.proj;
            tuv =  input.uv;
        }

        // apply fisheye/CRT screen warp to UV coords; at flatness ~= 0, it's a circle.
        function crtwarp( uv : Vec2, flatness : Float ): Vec2 {
            var coord = ( uv - 0.5 ) * 2.0; // shift coordsys to ( -0.5 , 0.5 )
            coord *= 1.1;

            coord.x *= 1.0 + pow( ( abs( coord.y ) / flatness ), 2.0 );
            coord.y *= 1.0 + pow( ( abs( coord.x ) / flatness ), 2.0 );

            coord = ( coord / 2.0 ) + 0.5; // back to ( 0, 1 )
            return coord;
        }

        // sampling trick to force a red-green shift on resulting texture
        function rgshift( tex : Sampler2D, uv : Vec2 ): Vec4 {
            var c : Vec4 = vec4( 0, 0, 0, 1 );
            c.r = tex.get( uv - vec2( 0.003, 0 ) ).r;
            c.g = tex.get( uv ).g;
            c.b = tex.get( uv + vec2( 0.003, 0 ) ).b;
            return c;
        }

        // make scanlines by subtracting from rgb
        function scanline( color : Vec4, screenspace : Vec2 ): Vec4 {
            color.rgb -= sin( ( screenspace.y + ( time * 29.0 ) ) ) * 0.02;
            return color;
        }

        // darken corners
        function darken( color : Vec4, screenspace : Vec2 ): Vec4 {
            var threshold : Vec2 = min( screenspace, screenres - screenspace );
            color.rgb -= pow( length( screenres ) / length( threshold ), 0.3 ) * vec3( 0.11, 0.11, 0.11 );
            return color;
        }

        function fragment() {
            var uv = crtwarp( tuv, 4.2 );
            var c = rgshift( tex, uv );

            // discard
            c *= uv.x > 0 ? 1 : 0;
            c *= uv.y > 0 ? 1 : 0;
            c *= uv.x < 1 ? 1 : 0;
            c *= uv.y < 1 ? 1 : 0;

            // using screenspace coords forcibly produces a moire pattern, neat!
            c = darken( c, uv * screenres );
            c = scanline( c, uv * screenres );
            output.color = c;
        }
    };

#else
    // do nothing
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

    public function new( tex ) {
        this.tex = tex;
        pshader = new PostEffectsShader();
        mainPass.culling = None;
        mainPass.blend(SrcAlpha, OneMinusSrcAlpha);
        super( pshader );
    }

    public function updateTime( newTime : Float ) {
        pshader.time = newTime;
    }

    override function setup( ctx : h3d.scene.RenderContext ) {
        super.setup(ctx);
        pshader.tex = tex;
        pshader.mproj = ctx.camera.m;
        pshader.screenres = new h3d.Vector( ctx.engine.width, ctx.engine.height );
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

    public function updateTime( newTime ) {
        sm.updateTime( newTime );
    }

    function get_tex() {
        return sm.tex;
    }

    function set_tex( v ) {
        return sm.tex = v;
    }
}

class Main extends flash.display.Sprite
{
    static var engine : h3d.Engine;
    static var scene : h3d.scene.Scene;
    static var backscene : h2d.Scene;
    static var framebuffer : h2d.Sprite; // accumulator
    static var renderTarget : h2d.Tile; // intermediate
    static var time : Float;
    static var screen : Screen;

    static function update()
    {
        backscene.captureBitmap( renderTarget );
        engine.render( scene );
        screen.updateTime( time );
        time += 1 / Lib.current.stage.frameRate;
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

            var bmd = new hxd.BitmapData( p2( engine.width ), p2( engine.height ) );
            renderTarget = h2d.Tile.fromBitmap( bmd );

            // sanity check
            // var tex = h3d.mat.Texture.fromColor( 0xffffffff );
            var tex = renderTarget.getTexture();

            screen = new Screen( tex, scene );
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
