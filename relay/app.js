net = require( 'net' );

var clients = [];

var socket = net.createServer( function ( socket ) {
  socket.name = socket.remoteAddress + ":" + socket.remotePort;
  socket.id = clients.length;
  clients.push( socket );
  console.log( "connected to client " + socket.name );

  var clientID = new Buffer( [ 255, clients.length - 1 ] );
  socket.write( clientID );
  var clientJoinMsg = new Buffer( [ 254, clients.length - 1 ] );
  relay( clientJoinMsg, socket );

  socket.on( 'data', function( data ) {
    console.log( data );
    relay( data, socket );
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
} ).listen( process.env.PORT || 80, null );
