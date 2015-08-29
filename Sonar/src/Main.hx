package ;

import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.Lib;
import gibber.God;

import h3d.scene.*;
import h3d.mat.Pass;
import h3d.Matrix;
import h3d.col.Point;

#if debug
import com.sociodox.theminer.TheMiner;
#end

using gibber.Util;

class PostEffectsShader extends h3d.shader.ScreenShader {
    static var SRC = {
        @param var camera : {
            var proj : Mat4;
        };

        var tuv : Vec2;
        @param var time : Float;
        @param var screenres : Vec2;
        @param var tex : Sampler2D;

        // apply fisheye/CRT screen warp to UV coords; at flatness ~= 0, it's a circle.
        function crtwarp( uv : Vec2, flatness : Float ): Vec2 {
            var coord = ( uv - 0.5 ) * 2.0; // shift coordsys to ( -0.5 , 0.5 )
            coord *= 1.1;

            coord.x *= 1.0 + pow( ( abs( coord.y ) / flatness ), 2.0 );
            coord.y *= 1.0 + pow( ( abs( coord.x ) / flatness ), 2.0 );

            coord = ( coord / 2.0 ) + 0.5; // back to ( 0, 1 )
            return coord;
        }

        // sample with an offset to force a red-green shift on resulting texture
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
            color.rgb -= pow( sqrt( screenres.dot( screenres ) ) / sqrt( threshold.dot( threshold ) ), 0.3 ) * vec3( 0.11, 0.11, 0.11 );
            return color;
        }

        function fragment() {
            var uv = crtwarp( input.uv, 4.2 );
            var c = rgshift( tex, uv );

            if ( uv.x < 0 ) discard;
            if ( uv.y < 0 ) discard;
            if ( uv.x > 1 ) discard;
            if ( uv.y > 1 ) discard;

            // using screenspace coords forcibly produces a moire pattern, neat!
            c = darken( c, uv * screenres );
            c = scanline( c, uv * screenres );
            output.color = c;
        }
    };
}

class PostEffects extends h3d.pass.ScreenFx<PostEffectsShader> {
    public function new() {
        super( new PostEffectsShader() );
    }
}

class PostEffectsMaterial extends h3d.mat.Material{
    public var tex : h3d.mat.Texture;
    var pshader : PostEffectsShader;

    public function new( tex, w, h, camera: Matrix ) {
        this.tex = tex;
        pshader = new PostEffectsShader();
        pshader.tex = tex;
        pshader.camera.proj = camera;
        pshader.screenres = new h3d.Vector( w, h );
        addPass( new Pass( "default", null ) ).addShader( pshader );
        mainPass.culling = None;
        mainPass.blend(SrcAlpha, OneMinusSrcAlpha);
        super( pshader );
    }

    public function updateTime( newTime : Float ) {
        pshader.time = newTime;
    }

    /*
    override function setup( ctx : h3d.scene.RenderContext ) {
        super.setup(ctx);
    }
    */
}

class Screen extends CustomObject {

    public var tex(get,set) : h3d.mat.Texture;
    var sm : PostEffectsMaterial;

    public function new( tex : h3d.mat.Texture, parent, w, h, camera )
    {
        var prim = new h3d.prim.Quads( [ new Point( 0, 0 ), new Point( 1, 0 ), new Point( 1, 1 ), new Point( 0, 1 ) ] );
        prim.addTCoords();

        super( prim, sm = new PostEffectsMaterial( tex, w, h, camera ), parent );
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
        engine.clear();
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

            scene.camera.pos.set( 0, 0, 0.5 );

            // make orthographic camera bounds just at the edges of the cube
            scene.camera.orthoBounds = new h3d.col.Bounds();
            scene.camera.orthoBounds.xMin = -0.5;
            scene.camera.orthoBounds.yMin = -0.5;
            scene.camera.orthoBounds.xMax =  0.5;
            scene.camera.orthoBounds.yMax =  0.5;

            scene.camera.up.set( 0, -1, 0 );
            scene.camera.target.set( 0, 0, 0 );

            scene.camera.update();

            screen = new Screen( tex, scene, engine.width, engine.height, scene.camera.mproj );

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
