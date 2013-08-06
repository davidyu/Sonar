package gibber;

import com.artemisx.Entity;
import haxe.Json;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.events.Event;
import utils.Vec2;

class EntityDeserializer
{
    @:isVar public var RESOURCE_PATH ( default, null ) : String = "../resource";
    @:isVar public var entityBuilder ( default, null ) : EntityBuilder;

    public function new( builder : EntityBuilder ) {
        entityBuilder = builder;
    }

    private function defaultDeserializeFromFile( data : String ) {
        return fromJson( data );
    }

    public function fromFile( file:String, ?processFile = null ) {

        if ( processFile == null ) {
            processFile = defaultDeserializeFromFile;
        }

#if flash
        var loader:URLLoader = new URLLoader();
        loader.load( new URLRequest( '$RESOURCE_PATH/$file' ) );
        loader.addEventListener( Event.COMPLETE, function( e : Event) {
            var entity = processFile( e.target.data );
        } );
#end
    }

    public function fromJson( json:String ) : Entity {
        var parsed = Json.parse( json );

        // recursively iterate over all fields in obj
        // topmost field special case: specifies EntityBuilder constructor

        switch ( Reflect.fields( parsed )[0] ) {
            case "Object":
                var info = parsed.Object;
                var out = compile( info );
                return entityBuilder.createObject( out.name, cast( out.pos, Vec2 ) );

            default:
                throw "cannot identify object constructor";
        }
    }

    // compiles a JSON dynamic into a meaningful Dynamic
    private function compile( obj:Dynamic ) : Dynamic {
        var out : Dynamic = {};

        // base case: String/int
        if ( Reflect.fields( obj ).length == 0 ) {
            return obj;
        }

        for ( field in Reflect.fields( obj ) ) {
            switch ( field ) {

                // base case: Vec2
                case "Vec2":
                    return new Vec2( obj.Vec2[0], obj.Vec2[1] );

                default:
                    var aout = compile( Reflect.field( obj, field ) );
                    Reflect.setField( out, field, aout );
            }
        }

        return out;
    }
}
