net = require( 'net' );

var MAX_INSTANCES = 10;
var instances = [ [] ];

var gameServer = net.createServer( function ( socket ) {
  socket.setTimeout( 60 * 1000 ); // 1 minute timeout
  socket.setNoDelay( true );
  socket.name = socket.remoteAddress + ":" + socket.remotePort;

  var instance = instances[ instances.length - 1 ];
  socket.id = instance.length + 1; // start ids at 1

  if ( socket.id > 4 ) { // create new instance
    console.log( "NEW INSTANCE" );
    instances.push( [] );
    instance = instances[ instances.length - 1 ];
    socket.id = 1;
  }

  socket.instanceId = instances.length - 1;

  // set up some listeners for this socket
  socket.on( 'data', function( data ) {
    //console.log( "data of length " + data.readUInt16BE( 1 ) + ":|" + data.toString() + "|")
    if ( data == '<policy-file-request/>\0' ) {
      socket.write( getCrossDomainPolicy() + '\0' );
    } else {
      relay( data, socket );
    }
  } );

  socket.on( 'end', function() {
    var instance = instances[ socket.instanceId ];
    if ( socket.instanceId != 0 ) {
      instance.splice( instance.indexOf( socket ), 1 );
    }
    // relay leave event
    if ( instance.length == 0 ) instances.splice( instances.indexOf( instance ), 1 );
    console.log( "client " + socket.name + " left the game." );
  } );

  // acknowledge this socket's connection
  instances[ socket.instanceId ].push( socket );
  console.log( "connected to client " + socket.name );

  var clientID = new Buffer( [ 255, socket.id ] );
  socket.write( clientID ); // send the client ID
  var socketJoin = new Buffer( [ 254, socket.id ] );

  // broadcast this client's joining to every other client
  instance.forEach( function( client ) {
    if ( client == socket ) return;
    try {
      if ( client.writable ) {
        client.write( socketJoin );
      } else {
        console.log( client.id + " is not writable." );
      }
      var clientAdd = new Buffer( [ 254, client.id ] );
      if ( socket.writable ) {
        socket.write( clientAdd );
      } else {
        instance.splice( instance.indexOf( socket ), 1 );
        console.log( socket.id + " is not writable." );
      }
    } catch( err ) {
      console.log( "error broadcasting client joining : " + err );
    }
  } );

  function relay( data, sender ) {
    var instance = instances[ sender.instanceId ];
    instance.forEach( function( client ) {
      if ( client == sender ) return;
      var posID = new Buffer( [ 253, sender.id ] );
      try {
        if ( client.writable ) {
          client.write( posID );
          client.write( data );
          // console.log( posID.toString() + "   |   " + data.length + " | " + data.readUInt16BE(1) + " | " + data.toString() );
        } else {
          instance.splice( instance.indexOf( client ), 1 );
          console.log( client.id + " is not writable." );
        }
      } catch ( err ) {
        console.log( "cannot send message to " + client.id + ": " + err );
      }
    } );
  }
} ).listen( process.env.PORT || 5000, null );

var policyServer = net.createServer( function ( socket ) {
  socket.on( 'data', function( data ) {
    if ( data == "<policy-file-request/>\0" ) {
      socket.write( getCrossDomainPolicy() + '\0' );
      socket.end();
    }
  } );
} ).listen( 10000, null );

function getCrossDomainPolicy() {
  return policy = '<cross-domain-policy><allow-access-from domain="*" to-ports="*" /></cross-domain-policy>';
}
