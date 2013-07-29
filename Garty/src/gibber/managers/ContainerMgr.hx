package gibber.managers;

import com.artemisx.Aspect;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import com.artemisx.Manager;
import gibber.components.ContainableCmp;
import gibber.components.ContainerCmp;
import gibber.components.NameIdCmp;
import gibber.components.PosCmp;
import gibber.components.RegionCmp;
import gibber.components.TakeCmp;
import haxe.ds.StringMap;

class ContainerMgr extends Manager
{
    public function new() {
        containerEntities = new StringMap();
        entityContainer = new StringMap();
    }
    
    override public function initialize() : Void {
        nameMapper = world.getMapper( NameIdCmp );
        containableMapper = world.getMapper( ContainableCmp );
    }
    
    override public function onAdded( e : Entity ) : Void {
        var containerSig = Aspect.getAspectForAll( [ContainerCmp, NameIdCmp] );
        var objSig       = Aspect.getAspectForAll( [NameIdCmp, ContainableCmp, PosCmp] );
        
        if ( Aspect.matches( containerSig, e.componentBits ) ) {
            var eName = nameMapper.get( e ).name;
            var entities = containerEntities.get( eName );

            if ( entities == null ) {
                containerEntities.set( eName, new Array() );
            } else {
                throw "Adding same container entity twice: " + eName;
            }
        } else if ( Aspect.matches( objSig, e.componentBits ) ) {
            // Get item's container entity thru TakeCmp, and set both hashes
            var container = containableMapper.get( e ).container;
            var eName = nameMapper.get( e ).name;

            if ( container != null ) {
                entityContainer.set( eName, container ); // Set contianer for entity
                containerEntities.get( nameMapper.get( container ).name ).push( e ); // Add entity to container
            } else {
                throw "Invalid container for entity: " + eName;
            }
        }
    }
    
    override public function onDeleted( e : Entity ) : Void {
        var nameCmp = nameMapper.getSafe( e );
        
        if ( nameCmp == null ) {
            return;
        }
        
        var name = nameCmp.name;
        var entities = containerEntities.get( name );
        
        if ( entities != null ) {
            for ( e in entities ) {
                entityContainer.remove( name );
            }
            
            containerEntities.remove( name );
            return;
        }
        
        var container = entityContainer.get( name );
        
        if ( !containerEntities.get( nameMapper.get( container ).name ).remove( e ) ) {
            throw "Removing entity that doesn't exist in container: " + name;
        };
    }
    
    public function changeContainerOfEntity( e : Entity, oldContainer : Entity, newContainer : Entity ) : Void {
        getEntitiesOfContainer( oldContainer ).remove( e );
        entityContainer.set( nameMapper.get( e ).name, newContainer );
    }
    
    public function getEntitiesOfContainer( container : Entity ) : Array<Entity> {
        return containerEntities.get( nameMapper.get( container ).name );
    }
    
    public function getContainerOfEntity( e : Entity ) : Entity {
        return entityContainer.get( nameMapper.get( e ).name );
    }
    
    var containerEntities : StringMap<Array<Entity>>;
    var entityContainer : StringMap<Entity>;
    
    var nameMapper : ComponentMapper<NameIdCmp>;
    var containableMapper : ComponentMapper<ContainableCmp>;
    
}