// Deserializes select JSON objects into their classes.

package sonar;

import com.artemisx.Component;
import com.artemisx.Manager;
import com.artemisx.Entity;
import haxe.Json;
import sonar.managers.NameRegistry;
import sonar.managers.ContainerMgr;
import sonar.systems.EntityAssemblySys;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.events.Event;
import utils.Vec2;

import haxe.ds.StringMap;

class EntityDeserializer
{
    // I believe some of these can be "default values" that don't need to be specified in the JSON,
    // because the designer shouldn't need to think about the internals of the engine when creating
    // an object
    @:isVar public var RESOURCE_PATH ( default, null ) : String = "../resource";
    @:isVar private var entityAssembler ( default, null ) : EntityAssemblySys;
    @:isVar private var nameRegistry  ( default, null ) : NameRegistry;
    @:isVar private var god           ( default, null ) : God;
    @:isVar private var containerMgr  ( default, null ) : ContainerMgr;

    private var classpathTable : StringMap<String>;

    public function new( god : God ) {
        entityAssembler = god.entityAssembler;
        nameRegistry = god.world.getManager( NameRegistry );
        containerMgr = god.world.getManager( ContainerMgr );
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

    private function defaultDeserializeFromFile( data : String, filename : String ) {
        try {
            var deserialized = fromJson( data );
#if debug
            trace( 'finished deserializing $filename.' );
#end
            return deserialized;
        } catch ( errorMsg : String ) {
            trace( 'error deserializing $filename: $errorMsg' );
            return null;
        }
    }

    public function fromFile( file:String, ?processFile = null ) {

        if ( processFile == null ) {
            processFile = defaultDeserializeFromFile;
        }

#if flash
        var loader:URLLoader = new URLLoader();
        loader.load( new URLRequest( '$RESOURCE_PATH/$file' ) );
        loader.addEventListener( Event.COMPLETE, function( e : Event) {
            var entity = processFile( e.target.data, '$RESOURCE_PATH/$file' );
        } );
#end
    }

    public function fromJson( json:String ) : Entity {
        var parsed = Json.parse( json );

        // recursively iterate over all fields in obj
        // topmost field: specifies EntityBuilder method or vanilla "Entity"
        switch ( Reflect.fields( parsed )[0] ) {
            case "Entity":
                var info = parsed.Entity;
                var componentDataArray : Array<Dynamic> = info.components;
                var components = new List<Component>();

                for ( cmpDat in componentDataArray ) {
                    if ( cmpDat == null ) {
                        trace("Dave: I want to see this! Here's the full printout of info:");
                        trace( info );
                    }
                    var cmp = recursiveCompile( cmpDat );
                    components.push( cmp );
                }

                var entity = entityAssembler.createEntityWithCmps( components );
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
                // right now this just gets me the property of this class, but I need a way to get
                // any manager from God. Using GetManager doesn't work, because it requires an argument
                // that's strongly typed and resolveClass returns a Class<Dynamic>
                return Reflect.getProperty( this, identifier );
            case "#":
                // this an enum
                // syntax: #ENUM_TYPE:Enum_Value
                var enumVal  = identifier.substr( identifier.indexOf( ":" ) + 1 );
                var enumTypeStr = identifier.substr( 0, identifier.indexOf( ":" ) );

                var enumType = Type.resolveEnum( "sonar.gabby.SynType" );

                // create the enum, not the string
                return Type.createEnum( enumType, enumVal );
            default:
        }

        return str;
    }

    // compiles a JSON dynamic into a meaningful Dynamic
    private function recursiveCompile( obj:Dynamic ) : Dynamic {
        // base case: int/vanilla String/resolvable String
        if ( Reflect.fields( obj ).length == 0 ) {
            if ( Type.typeof( obj ) == TInt ) {
                return obj;
            } else {
                return resolve( obj );
            }
        } else if ( Reflect.fields( obj ).length == 1 ) { // recursive case ( key->data store in obj )
            var key = Reflect.fields( obj )[0];
            // if we've got an entry for the class name, optimistically assume we can deserialize it
            if ( classpathTable.exists( key ) ) {
                var classname = key;
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
                        for ( f in cl.fields ) {      // iterate over fields, but only extract...
                            if ( f.name == "new" ) {  // constructor function
                                switch ( f.type ) {
                                    case CFunction( params, _ ): // get constructor parameters
                                        for ( p in params ) {
                                            // for each parameter, find corresponding param in our JSON
                                            // object, compile it, and push that to our list of parameter
                                            // values
                                            var packedParamData = Reflect.field( packedData, p.name );

                                            // if we hit an optional parameter that's not defined in packedData, skip it
                                            if ( !Reflect.hasField( packedData, p.name ) ) {
                                                if ( p.opt ) {
                                                    continue;
                                                } else {
                                                    var errorMsg = '[recursiveCompile] data for $classname missing field ${p.name}';
                                                    throw errorMsg;
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

                        // pass 2: fill in the rest of the fields in the instance
                        for ( f in cl.fields ) {
                            switch ( f.type ) {
                                case CClass( fieldType, _ ):
                                    var packedFieldData = Reflect.field( packedData, f.name );
                                    // only fill in the field if our json object has the data
                                    // and if it hasn't been filled in by the constructor
                                    if ( packedFieldData != null && Reflect.getProperty( instance, f.name ) == null ) {
                                        var compiledField = recursiveCompile( packedFieldData );
                                        Reflect.setProperty( instance, f.name, compiledField );
                                    }
                                default:
                            }
                        }
                    default:
                }

                return instance;

            } else { // there are no known classpaths for this class

                // first, try a series of hardcoded classe allocations
                // these classes DO NOT have rtti defs so we could not dynamically construct them in the first place
                // if there is a solution (EG: a compiler flag to add rtti to every class - which may be bad for performance), let David know, or write it.

                var arrayDeclaration : EReg = ~/Array<(.+)>|Array$/;
                var listDeclaration  : EReg = ~/List<(.+)>|List$/;

                if ( arrayDeclaration.match( key ) ) {
                    // it's an array!
                    var array = null;
                    var type = arrayDeclaration.matched( 1 );

                    if ( type != null ) { // extract the type, if possible
                        switch ( type ) {
                            case "String":
                                array = new Array<String>();
                            default:
                                trace( "new strongly typed Array not implemented: " + type );
                                array = new Array();
                        }
                    } else {
                        array = new Array();
                    }

                    var arrayPackedData = Reflect.field( obj, key );
                    for ( index in Reflect.fields( arrayPackedData ) ) {
                        array.push( Reflect.field( arrayPackedData, index ) );
                    }

                    return array;

                } else if ( listDeclaration.match( key ) ) {
                    var list = null;
                    var type = listDeclaration.matched( 1 );

                    if ( type != null ) {
                        switch ( type ) {
                            case "String":
                                list = new List<String>();
                            default:
                                trace( "new strongly typed List not implemented: " + type );
                                list = new List();
                        }
                    } else {
                        list = new List();
                    }

                    var listPackedData = Reflect.field( obj, key );
                    for ( index in Reflect.fields( listPackedData ) ) {
                        list.push( Reflect.field( listPackedData, index ) );
                    }

                    return list;

                } else { //can't do anything, just return a dynamic object
                    var out : Dynamic = {};
                    var compiledObj = recursiveCompile( Reflect.field( obj, key ) );
                    Reflect.setField( out, key, compiledObj );
                    return out;
                }
            }
        } else { //an undeclared array! Deserialize it to a (generic) list. This could cause problems
            trace( 'Warning: uncaught array with contents " + obj + ". Deserializing to a list...' );
            var list = new List();
            for ( index in Reflect.fields( obj ) ) {
                list.add( Reflect.field( obj, index ) );
            }

            return list;
        }

        throw "We should never be here! You need to return in the new code path you just added";
    }
}
