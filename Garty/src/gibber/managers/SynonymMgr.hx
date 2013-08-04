package gibber.managers;

import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import com.artemisx.Manager;
import gibber.components.NameIdCmp;
import gibber.components.SynListCmp;
import gibber.God;
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
class SynonymMgr extends Manager
{

    public function new() {
        synonymsFromEntity = new StringMap();
        entitiesFromSynonyms = new StringMap();
    }
    
    override public function initialize() {
        tagMapper = world.getMapper( SynListCmp );
        nameMapper = world.getMapper( NameIdCmp );
        
        nameRegistry = world.getManager( NameRegistry );
    }

    override public function onAdded( e : Entity ) : Void {
        var tagCmp = tagMapper.getSafe( e );
        
        if ( tagCmp == null ) {
            return;
        }
        
        var entityNameId = tagCmp.tag.entityNameId;
        var syns = synonymsFromEntity.get( entityNameId );
        
        if ( syns == null ) {
            syns = new List();
            synonymsFromEntity.set( entityNameId, syns );
        }
        
        for ( s in tagCmp.tag.synonyms ) {
            syns.push( s ); // Add synonym reference to entity
            
            var record = entitiesFromSynonyms.get( s );
            if ( record == null ) {
                var list = new List<String>();
                entitiesFromSynonyms.set( s, list );
                record = list;
            }
            
            record.push( entityNameId );
        }
    }
    
    override public function onDeleted( e : Entity ) : Void {
        var nameCmp = nameMapper.getSafe( e );
        
        if ( nameCmp == null ) {
            return;
        }
        
        var tagCmp = tagMapper.getSafe( nameRegistry.getEntity( nameCmp.name ) );
        
        if ( tagCmp == null ) {
            return;
        }
        
        var tag = tagCmp.tag;
        var syns = synonymsFromEntity.get( tag.entityNameId );

        for ( s in tag.synonyms ) {
            syns.remove( s );
            var record = entitiesFromSynonyms.get( s );
            record.remove( tag.entityNameId );
        }
        
        world.deleteEntity( nameCmp.tagEntityRef ); // Delete the tag entity linked to named entity
        nameCmp.tagEntityRef = null;
    }
    
    var nameRegistry : NameRegistry;
    
    var tagMapper : ComponentMapper<SynListCmp>;
    var nameMapper : ComponentMapper<NameIdCmp>;
    
    var synonymsFromEntity : StringMap<List<String>>;
    var entitiesFromSynonyms : StringMap<List<String>>;

    
}