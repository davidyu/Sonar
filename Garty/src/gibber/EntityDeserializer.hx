// Deserializes select JSON objects into their classes.
// Currently tested on Vec2, and item_jar.json

package gibber;

import com.artemisx.Entity;
import haxe.Json;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.events.Event;
import utils.Vec2;

import haxe.ds.StringMap;

class EntityDeserializer
{
    @:isVar public var RESOURCE_PATH ( default, null ) : String = "../resource";
    @:isVar public var entityBuilder ( default, null ) : EntityBuilder;

    private var classpathTable : StringMap<String>;

    public function new( builder : EntityBuilder ) {
        entityBuilder = builder;

        if ( classpathTable == null ) {
            buildClasspathTable();
        }
    }

    private function buildClasspathTable() {
        classpathTable = new StringMap<String>();
        var data = haxe.Resource.getString( "classpaths" );

        var lines = data.split("\n");
        for ( line in lines ) {
            if ( line == "" ) break;
            var tuple = line.split(" ");
            var classname = tuple[0];
            var classpath = tuple[1];
            classpathTable.set( classname, classpath );
        }
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
                return entityBuilder.createObject( out.name, cast( out.pos, Vec2 ), out.lookText );

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
            // if we've got an entry for the class name, optimistically assume we can deserialize it
            if ( classpathTable.exists( field ) ) {
                var ctorParamValues = new Array<Dynamic>(); //alloc a list for constructor parameter values...
                var fieldValue = Reflect.field( obj, field );  //useful ctor data wrapped in JSON object...

                // following codes extract the right ctor params
                var clazz = Type.resolveClass( classpathTable.get( field ) ); //get class
                var rtti = Xml.parse( untyped clazz.__rtti  ).firstElement(); //get class rtti
                var infos = new haxe.rtti.XmlParser().processElement( rtti ); //get switchable rtti tree

                switch ( infos ) {
                    case TClassdecl( cl ):  // get class decl info in rtti
                        for ( f in cl.fields ) {
                            if ( f.name == "new" ) {  // get constructor info
                                switch ( f.type ) {
                                    case CFunction( params, _ ): // get constructor parameters
                                        for ( p in params ) {
                                            // for each parameter, find corresponding param in our JSON
                                            // object, and push that to our list of parameter values
                                            ctorParamValues.push( Reflect.field( fieldValue, p.name ) );
                                        }
                                    default:
                                }
                            }
                        }
                    default:
                }

                // build that shit! Pain in the arse.
                var instance = Type.createInstance( clazz, ctorParamValues );
                return instance;

            } else { //this field can't be deserialized into an instance of a class, so just keep it anon
                var aout = compile( Reflect.field( obj, field ) );
                Reflect.setField( out, field, aout );
            }
        }

        return out;
    }
}
