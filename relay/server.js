net = require( 'net' );

var clients = [];

var socket = net.createServer( function ( socket ) {
  socket.name = socket.remoteAddress + ":" + socket.remotePort;
  socket.id = clients.length;

  clients.push( socket );
  console.log( "connected to client " + socket.name );

  socket.on( 'connect', function( data ) {
    console.log( "connect event" );
    var clientID = new Buffer( [ 255, clients.indexOf( socket ) ] );
    socket.write( clientID ); // send the client ID
    var socketJoin = new Buffer( [ 254, clients.length - 1 ] );
    clients.forEach( function( client, clientIndex ) {
      if ( client == socket ) return;
      client.write( socketJoin );
      var clientAdd = new Buffer( [ 254, clientIndex ] );
      socket.write( clientAdd );
    } );
  } );

  socket.on( 'data', function( data ) {
    console.log( "|" + data.toString() + "|")
    if ( data == '<policy-file-request/>\0' ) {
      socket.setEncoding( "utf8" );
      socket.write( getCrossDomainPolicy() + '\0' );
    } else {
      relay( data, socket );
    }
  } );

  socket.on( 'end', function() {
    clients.splice( clients.indexOf( socket ), 1 );
    // relay leave event
    console.log( "client " + socket.name + " left the game." );
  } );

  function relay( data, sender ) {
    clients.forEach( function( client ) {
      if ( client == sender ) return;
      var posID = new Buffer( [ 253, sender.id ] );
      client.write( posID );
      client.write( data );
    } );
  }
} ).listen( process.env.PORT || 5000, null );

var policyServer = net.createServer( function ( socket ) {
  socket.setEncoding( "utf8" );
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
