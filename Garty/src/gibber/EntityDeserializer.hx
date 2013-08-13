// Deserializes select JSON objects into their classes.
// Currently tested on Vec2, and item_jar.json

package gibber;

import com.artemisx.Component;
import com.artemisx.Entity;
import haxe.Json;
import gibber.managers.NameRegistry;
import gibber.managers.ContainerMgr;
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
    @:isVar private var containerMgr  ( default, null ) : ContainerMgr;

    private var classpathTable : StringMap<String>;

    public function new( god : God ) {
        entityBuilder = god.entityBuilder;
        nameRegistry = god.world.getManager( NameRegistry );
        containerMgr = god.world.getManager( ContainerMgr );

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

        // @Desktop TODO: UGLY! Fix this logic
        switch ( Reflect.fields( parsed )[0] ) {
            case "Object":
                var info = parsed.Object;
                var out = compile( info );
                return entityBuilder.createObject( out.name, cast( out.pos, Vec2 ), out.lookText );

            case "Entity":
                var info = parsed.Entity;
                var componentDataArray : Array<Dynamic> = info.components;
                var components = new List<Component>();

                for ( cmpDat in componentDataArray ) {
                    var cmp = compile( cmpDat );
                    components.push( cmp );
                }

                var entity = entityBuilder.createEntityWithCmps( components );
                return null;
                //var out = compile( info );

            default:
                throw "cannot identify object constructor";
        }
    }

    // compiles a JSON dynamic into a meaningful Dynamic
    private function compile( obj:Dynamic ) : Dynamic {
        var out : Dynamic = {};

        // base case: String/int/unique ID <= this is not even being called!
        if ( Reflect.fields( obj ).length == 0 ) {
            // unsafe. If object is not int, it can be enum, float, function, bool, object, etc...
            // this is an entity
            if ( Type.typeof( obj ) == TInt ) {
                return obj;
            } else {
                // @desktop TODO: UGLY, redesign logic and architecture
                switch ( obj.charAt(0) ) {
                    case "#":
                        var entityName = obj.substr( 1 );
                        return nameRegistry.getEntity( entityName );
                    case "$":
                        var fieldName = obj.substr( 1 );
                        return Reflect.getProperty( this, fieldName );
                    default: return obj; //can't do anything
                }
            }
        }

        for ( field in Reflect.fields( obj ) ) {
            // if we've got an entry for the class name, optimistically assume we can deserialize it
            if ( classpathTable.exists( field ) ) {
                var classname = field;
                var ctorParamList = new Array<Dynamic>(); //alloc a list for constructor parameter values...
                var packedData = Reflect.field( obj, classname );  //useful deserialized data wrapped in JSON object...

                // following codes extract the right ctor params
                var clazz = Type.resolveClass( classpathTable.get( classname ) ); //get class
                var rtti = Xml.parse( untyped clazz.__rtti  ).firstElement(); //get class rtti
                var infos = new haxe.rtti.XmlParser().processElement( rtti ); //get switchable rtti tree

                // pass 1: create an instance of the class
                var instance = null;

                switch ( infos ) {
                    case TClassdecl( cl ):  // get class decl info in rtti
                        for ( f in cl.fields ) {
                            if ( f.name == "new" ) {  // get constructor info
                                switch ( f.type ) {
                                    case CFunction( params, _ ): // get constructor parameters
                                        for ( p in params ) {
                                            // for each parameter, find corresponding param in our JSON
                                            // object, compile it, and push that to our list of parameter
                                            // values
                                            var paramData = Reflect.field( packedData, p.name );

                                            // if we hit an optional parameter that's not defined in packedData, skip it
                                            if ( paramData == null ) {
                                                if ( p.opt ) {
                                                    continue;
                                                } else {
                                                    throw "data for $classname missing field ${p.name}";
                                                }
                                            }

                                            var compiledParam = compile( Reflect.field( packedData, p.name ) );
                                            ctorParamList.push( compiledParam );
                                        }

                                        // instance that class! Pain in the arse.
                                        instance = Type.createInstance( clazz, ctorParamList );

                                    default:
                                }
                            }
                        }
                    default:
                }

                if ( instance == null ) {
                    return null;
                }

                // pass 2: fill in fields in the instance
                switch ( infos ) {
                    case TClassdecl( cl ):  // get class decl info in rtti
                        for ( f in cl.fields ) {
                            switch ( f.type ) {
                                case CClass( fieldType, _ ):
                                    var packedField = Reflect.field( packedData, f.name );
                                    if ( packedField != null ) {
                                        // should err here? Or is it assumption that if field not defined, don't set it?
                                        var compiledField = compile( packedField );
                                        Reflect.setProperty( instance, f.name, compiledField );
                                    }
                                default:
                            }
                        }
                    default:
                }

                return instance;

            } else { //this field can't be deserialized into an instance of a class, so just keep it anon
                var aout = compile( Reflect.field( obj, field ) );
                Reflect.setField( out, field, aout );
            }
        }

        return out;
    }
}
