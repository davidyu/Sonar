net = require( 'net' );

var clients = [];

var socket = net.createServer( function ( socket ) {
  socket.name = socket.remoteAddress + ":" + socket.remotePort;
  clients.push( socket );
  console.log( "connected to client " + socket.name );

  var clientID = new Buffer( [ 255, clients.length - 1 ] );
  socket.write( clientID );
  var clientJoinMsg = new Buffer( [ 254, clients.length - 1 ] );
  relay( clientJoinMsg, socket );

  socket.on( 'data', function( data ) {
    opcode = new Buffer( [ 100 ] );
    console.log( data );
    //relay( socket.name + ">" + data, socket );
  } );

  socket.on( 'end', function() {
    clients.splice( clients.indexOf( socket ), 1 );
    // relay leave event
    console.log( "client " + socket.name + " left the game." );
  } );

  function relay( data, sender ) {
    clients.forEach( function( client ) {
      if ( client == sender ) return;
      client.write( data );
    } );
  }
} ).listen( 5000 );
