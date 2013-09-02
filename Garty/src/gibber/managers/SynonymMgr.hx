package gibber.managers;

import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import com.artemisx.Manager;
import com.artemisx.managers.TagManager;
import gibber.components.NameIdCmp;
import gibber.God;
import haxe.ds.IntMap;
import haxe.ds.ObjectMap;
import haxe.ds.StringMap;
import haxe.ds.StringMap;

/*
 * This class manages synonyms for any entity with a NameIdCmp 
 * Named entities will have a corresponding Synonym entity created
 * *outside* of this class. When the Synonym entity is added to the world,
 * we automatically register all the synonyms in this manager. Synonym 
 * entities are not deleted manually; when a Named entity is deleted,
 * we delete the corresponding Synonym entity for it.
 * Be careful as onAdded and onDeleted are not symmetrical because of this.
 */
class SynonymMgr extends TagManager
{

    public function new() {
        super();
        synonymsFromEntity = new IntMap();
        entitiesFromSynonyms = new StringMap();
    }
    
    override public function initialize() {
        nameMapper = world.getMapper( NameIdCmp );
        
        nameRegistry = world.getManager( NameRegistry );
    }

    public function getRegisteredSynonyms() : Iterator<String> {
        return entitiesFromSynonyms.keys();
    }

    public function getListOfRegisteredSynonyms() : List<String> {
        var keys : Iterator<String> = getRegisteredSynonyms();
        var keyList : List<String> = new List<String>();

        while ( keys.hasNext() ) {
            keyList.push( keys.next() );
        }

        return keyList;
    }

    override public function onAdded( e : Entity ) : Void {
        var nameCmp = nameMapper.getSafe( e );
        
        if ( nameCmp == null ) {
            return;
        }
        
        if ( !entitiesByTag.exists( nameCmp.name ) ) {
            register( nameCmp.name, e );
        } else {
            #if debug
            trace( "Attempted to add entity to name registry that already exists" + nameCmp.name );
            #end
        }
        
        var entityNameId = nameCmp.name;
        var syns = new Array<String>();
                
        for ( s in nameCmp.syns.synonyms ) {
            syns.push( s ); // Add synonym reference to entity
            
            var record = entitiesFromSynonyms.get( s );
            if ( record == null ) {
                record = new Array<Entity>();
            }
            
            record.push( e );
            entitiesFromSynonyms.set( s, record );

        }
        synonymsFromEntity.set( e.id, syns );

    }
    
    override public function onChanged( e : Entity ) : Void {
        // TODO Handle case where syns are dynamically attached
    }
    
    override public function onDeleted( e : Entity ) : Void {
        var nameCmp = nameMapper.getSafe( e );
        
        if ( nameCmp == null ) {
            return;
        }
        
        synonymsFromEntity.remove( e.id );

        for ( s in nameCmp.syns.synonyms ) {
            var record = entitiesFromSynonyms.get( s );
            record.remove( e );
        }
        
        super.onDeleted( e );
    }
    
    public function resolveSynonym( s : String ) : Array<Entity> {
        return entitiesFromSynonyms.get( s );
    }
    
    var nameRegistry : NameRegistry;
    var nameMapper : ComponentMapper<NameIdCmp>;
    
    var synonymsFromEntity : IntMap<Array<String>>;
    var entitiesFromSynonyms : StringMap<Array<Entity>>;

    
}
