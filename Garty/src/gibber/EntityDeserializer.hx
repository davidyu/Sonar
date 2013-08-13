// Deserializes select JSON objects into their classes.
// Currently tested on Vec2, and item_jar.json

package gibber;

import com.artemisx.Component;
import com.artemisx.Entity;
import haxe.Json;
import gibber.managers.NameRegistry;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.events.Event;
import utils.Vec2;

import haxe.ds.StringMap;

class EntityDeserializer
{
    @:isVar public var RESOURCE_PATH ( default, null ) : String = "../resource";
    @:isVar private var entityBuilder ( default, null ) : EntityBuilder;
    @:isVar private var nameRegistry  ( default, null ) : NameRegistry;
    @:isVar private var god           ( default, null ) : God;

    private var classpathTable : StringMap<String>;

    public function new( god : God ) {
        entityBuilder = god.entityBuilder;
        nameRegistry = god.world.getManager( NameRegistry );
        this.god = god;

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
        // topmost field: specifies EntityBuilder method or vanilla "Entity"
        switch ( Reflect.fields( parsed )[0] ) {
            case "createObject":
                var info = parsed.Object;
                var out = recursiveCompile( info );

                // a bit of hardcoding here, should rid this case ASAP
                return entityBuilder.createObject( out.name, cast( out.pos, Vec2 ), out.lookText );

            case "Entity":
                var info = parsed.Entity;
                var componentDataArray : Array<Dynamic> = info.components;
                var components = new List<Component>();

                for ( cmpDat in componentDataArray ) {
                    var cmp = recursiveCompile( cmpDat );
                    components.push( cmp );
                }

                var entity = entityBuilder.createEntityWithCmps( components );
                return null;

            default:
                throw "cannot identify object constructor";
        }
    }

    // try to resolve a string prefixed with a special character
    private function resolve( str : String ) : Dynamic {

        var prefix     = str.charAt( 0 );
        var identifier = str.substr( 1 );

        switch ( prefix ) {
            case "$":
                return nameRegistry.getEntity( identifier );
            case "@":
                return god.world.getManager( Type.getClass( classpathTable.get( identifier ) ) );
            default:
        }

        return str;
    }

    // compiles a JSON dynamic into a meaningful Dynamic
    private function recursiveCompile( obj:Dynamic ) : Dynamic {
        var out : Dynamic = {};

        // base case: int/vanilla String/resolvable String
        if ( Reflect.fields( obj ).length == 0 ) {
            if ( Type.typeof( obj ) == TInt ) {
                return obj;
            } else {
                return resolve( obj );
            }
        }

        // recursive case:
        for ( field in Reflect.fields( obj ) ) {
            trace( field );
            // if we've got an entry for the class name, optimistically assume we can deserialize it
            if ( classpathTable.exists( field ) ) {
                var classname = field;
                var ctorParamList = new Array<Dynamic>(); //alloc a list for constructor parameter values...
                var packedData = Reflect.field( obj, classname );  //useful deserialized data wrapped in JSON object...

                // following codes extract the right ctor params
                var clazz = Type.resolveClass( classpathTable.get( classname ) ); //get class
                var rtti = Xml.parse( untyped clazz.__rtti  ).firstElement(); //get class rtti
                var infos = new haxe.rtti.XmlParser().processElement( rtti ); //get switchable rtti tree

                var instance = null;

                switch ( infos ) {
                    case TClassdecl( cl ):  // get class decl info in rtti

                        // pass 1: create an instance of the class
                        for ( f in cl.fields ) {
                            if ( f.name == "new" ) {  // get constructor info
                                switch ( f.type ) {
                                    case CFunction( params, _ ): // get constructor parameters
                                        for ( p in params ) {
                                            // for each parameter, find corresponding param in our JSON
                                            // object, compile it, and push that to our list of parameter
                                            // values
                                            var packedParamData = Reflect.field( packedData, p.name );

                                            // if we hit an optional parameter that's not defined in packedData, skip it
                                            if ( packedParamData == null ) {
                                                if ( p.opt ) {
                                                    continue;
                                                } else {
                                                    throw "[recursiveCompile] data for $classname missing field ${p.name}";
                                                }
                                            }

                                            var compiledParam = recursiveCompile( packedParamData );
                                            ctorParamList.push( compiledParam );
                                        }

                                        // instance that class! Pain in the arse.
                                        instance = Type.createInstance( clazz, ctorParamList );

                                    default:
                                }
                            }
                        }

                        // we should have an instance of the class by now, if not, abort abort abort
                        if ( instance == null ) {
                            return null;
                        }

                        // pass 2: fill in fields in the instance
                        for ( f in cl.fields ) {
                            switch ( f.type ) {
                                case CClass( fieldType, _ ):
                                    var packedFieldData = Reflect.field( packedData, f.name );
                                    // only fill in the field if our json object has the data
                                    if ( packedFieldData != null ) {
                                        var compiledField = recursiveCompile( packedFieldData );
                                        Reflect.setProperty( instance, f.name, compiledField );
                                    }
                                default:
                            }
                        }
                    default:
                }

                return instance;

            } else { //this field can't be deserialized into an instance of a class, so abort: just keep it anon
                var aout = recursiveCompile( Reflect.field( obj, field ) );
                Reflect.setField( out, field, aout );
            }
        }

        return out;
    }
}
