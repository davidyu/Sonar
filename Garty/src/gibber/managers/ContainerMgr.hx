package gibber.managers;

import com.artemisx.Aspect;
import com.artemisx.ComponentMapper;
import com.artemisx.Entity;
import com.artemisx.Manager;
import com.artemisx.utils.Bitset;
import gibber.components.ContainableCmp;
import gibber.components.ContainerCmp;
import gibber.components.NameIdCmp;
import gibber.components.PosCmp;
import gibber.components.RegionCmp;
import gibber.components.TakeCmp;
import haxe.ds.ObjectMap;
import haxe.ds.StringMap;
import haxe.ds.StringMap;

using Lambda;

class ContainerMgr extends Manager
{
    public function new() {
        containerEntities = new StringMap();
        entityContainer = new StringMap();
        aspectMap = new Array();
    }
    
    override public function initialize() : Void {
        nameMapper = world.getMapper( NameIdCmp );
        containableMapper = world.getMapper( ContainableCmp );
    }
    
    override public function onAdded( e : Entity ) : Void {
        var containerSig = Aspect.getAspectForAll( [NameIdCmp, ContainerCmp] );
        var objSig       = Aspect.getAspectForAll( [NameIdCmp, ContainableCmp] );
        
        if ( Aspect.matches( containerSig, e.componentBits ) ) {
            var eName = nameMapper.get( e ).name;
            var entities = containerEntities.get( eName );

            if ( entities == null ) {
                containerEntities.set( eName, new StringMap() );
            } else {
                throw "Adding same container entity twice: " + eName;
            }
        }
        
        var aspectName = getAspectName( e.componentBits );
        
        if ( Aspect.matches( objSig, e.componentBits ) && aspectName != null ) {
            // Get item's container entity thru ContainableCmp, and set both hashes
            var container = containableMapper.get( e ).container;
            var eName = nameMapper.get( e ).name;

            if ( container != null ) {
                var cName = nameMapper.get( container ).name;
                var containerEnts = containerEntities.get( cName );
                var entArr = containerEnts.get( aspectName );
                
                if ( entArr == null ) {
                    entArr = new Array<Entity>();
                    containerEnts.set( aspectName, entArr );
                }
                entArr.push( e );                   // Add entity to container
                entityContainer.set( eName, container );  // Set container for entity
            } else {
                throw "Invalid container for entity: " + eName + ", aspect: " + aspectName + ", container: " + container;
            }
        }
    }
    
    override public function onDeleted( e : Entity ) : Void {
        var containerSig = Aspect.getAspectForAll( [NameIdCmp, ContainerCmp] );
        var objSig       = Aspect.getAspectForAll( [NameIdCmp, ContainableCmp] );
        
        if ( Aspect.matches( containerSig, e.componentBits ) ) {
            var eName = nameMapper.get( e ).name;
            var entities = containerEntities.get( eName );

            if ( entities != null ) {
                for ( map in entities ) {
                    for ( item in map.iterator() ) {
                        entityContainer.remove( nameMapper.get( item ).name );
                        world.deleteEntity( item );
                    }
                }
                containerEntities.remove( eName );
            } else {
                throw "Container not registered but deleted... " + eName;
            }
        }
        
        var aspectName = getAspectName( e.componentBits );
        
        if ( Aspect.matches( objSig, e.componentBits ) && aspectName != null ) {
            // Get item's container entity thru ContainableCmp, and set both hashes
            var container = containableMapper.get( e ).container;
            var eName = nameMapper.get( e ).name;

            if ( container != null ) {
                var cName = nameMapper.get( container ).name;
                var containerEnts = containerEntities.get( cName );
                if ( containerEnts != null ) {
                    var entArr = containerEnts.get( aspectName );
                
                    if ( !entArr.remove( e ) ) {
                        throw "Didn't deleted entity cause couldn't find...";
                    }
                }

                entityContainer.remove( nameMapper.get( e ).name );
            } else {
                throw "Containable not registered but deleted: " + eName + ", aspect: " + aspectName + ", container: " + container;
            }
        }
        //var nameCmp = nameMapper.getSafe( e );
        //
        //if ( nameCmp == null ) {
            //return;
        //}
        //
        //var name = nameCmp.name;
        //var entities = containerEntities.get( name );
        //
        //if ( entities != null ) {
            //for ( i in entities ) {
                //entityContainer.remove( name );
                //world.deleteEntity( i );
            //}
            //
            //containerEntities.remove( name );
            //return;
        //}
        //
        //var container = entityContainer.get( name );
        //
        //if ( !containerEntities.get( nameMapper.get( container ).name ).get( getAspectName( e.componentBits ) ).remove( e ) ) {
            //throw "Removing entity that doesn't exist in container: " + name;
        //};
    }
    
    //TODO IMPLEMENT THIS - need to remove entities that don't match signature, and add entities that match
    override public function onChanged( e : Entity ) {
        
    }

    public function getAspectName( toMatch : Bitset ) : String {
        for ( a in aspectMap ) {
            if ( Aspect.matches( a.aspect, toMatch ) ) {
                return a.name;
            }
        }
        return null;
    }

    // All calls should happen before entities are created
    // Aspect signatures must be unique and non-overlapping
    // TODO Perhaps should check if same aspect is given for two different names
    public function registerAspect( n : String , a : Aspect ) : Void {
        if ( !aspectMap.exists( function(v) { return v.aspect.equals( a ) || v.name == n; } ) ) {
            aspectMap.push( { name : n , aspect : a } );
        } else {
            throw "Aspect of name or signature already exists";
        }
    }
    
    public function changeContainerOfEntity( e : Entity, oldContainer : Entity, newContainer : Entity ) : Void {
        //getEntitiesOfContainer( oldContainer ).remove( e );
        //entityContainer.set( nameMapper.get( e ).name, newContainer );
    }
    
    public function getAllEntitiesOfContainer( container : Entity ) : Array<Entity> {
        var res = new Array<Entity>();
        var maps = containerEntities.get( nameMapper.get( container ).name );
        
        for ( el in maps.iterator() ) {
            res.concat( el );
        }
        return res;
    }
    
    public function getEntitiesOfContainer( container : Entity, aspect : Aspect ) : Array<Entity> {
        for ( a in aspectMap ) {
            var cont = containerEntities.get( nameMapper.get( container ).name );
            if ( cont != null && Aspect.fufills( a.aspect, aspect ) ) {
                return cont.get( a.name );
            }
        }
        return null;
    }
    
    public function getContainerOfEntity( e : Entity ) : Entity {
        return entityContainer.get( nameMapper.get( e ).name );
    }
    
    var containerEntities : StringMap<StringMap<Array<Entity>>>;
    var entityContainer : StringMap<Entity>;
    
    var nameMapper : ComponentMapper<NameIdCmp>;
    var containableMapper : ComponentMapper<ContainableCmp>;
    
    var aspectMap : Array<{ aspect : Aspect, name : String}>;
    
    
}