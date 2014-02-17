package utils.test;

import flash.utils.ByteArray;

class CheckFlashUtils extends haxe.unit.TestCase {
    public function testByteArray() {
        var ba = new ByteArray();
        ba.writeShort( 140 );
        ba.position = 0;
        assertEquals( ba.readUnsignedShort(), 140 );

        ba.clear();

        ba.writeByte( 2 );
        ba.writeShort( 140 );
        ba.position = 0;
        assertEquals( ba.readUnsignedByte(), 2 );
        assertEquals( ba.readUnsignedShort(), 140 );
    }

    // NOTE: failTests are not actually run as tests! They are just here to serve as
    // examples of what NOT to do.
    // fails, because AS3 made some design decisions
    public function failTestByteArrayToStringRoundTrip() {
        var ba = new ByteArray();
        var bb = new ByteArray();

        ba.writeByte( 2 );
        ba.writeShort( 140 );

        bb.writeUTFBytes( ba.toString() );
        bb.position = 0;
        assertEquals( bb.readUnsignedByte(), 2 );
        assertEquals( bb.readUnsignedShort(), 140 );

        bb.clear();
        ba.clear();
    }

    // fails, presumably because the bytes form some character, which is stored differently when we
    // write the string to bb
    public function failTestByteArrayToUTFRoundTrip() {
        var ba = new ByteArray();
        var bb = new ByteArray();

        ba.writeByte( 2 );
        ba.writeShort( 140 );

        ba.position = 0;

        assertEquals( ba.bytesAvailable, 3 );

        bb.writeUTFBytes( ba.readUTFBytes( ba.bytesAvailable ) );

        bb.position = 0;
        assertEquals( bb.bytesAvailable, 3 );

        assertEquals( bb.readUnsignedByte(), 2 );
        assertEquals( bb.readUnsignedShort(), 140 );

        bb.clear();
        ba.clear();
    }

    // works
    public function testByteArraySimpleRoundTrip() {
        var ba = new ByteArray();
        var bb = new ByteArray();

        ba.writeByte( 2 );
        ba.writeShort( 140 );

        ba.position = 0;
        assertEquals( ba.bytesAvailable, 3 );

        bb.writeByte( ba.readByte() );
        bb.writeShort( ba.readShort() );

        bb.position = 0;
        assertEquals( bb.bytesAvailable, 3 );

        assertEquals( bb.readUnsignedByte(), 2 );
        assertEquals( bb.readUnsignedShort(), 140 );

        bb.clear();
        ba.clear();
    }

    // passes -- do this
    public function testByteArrayByteReadRoundTrip() {
        var ba = new ByteArray();
        var bb = new ByteArray();

        ba.writeByte( 2 );
        ba.writeShort( 140 );

        ba.position = 0;
        assertEquals( ba.bytesAvailable, 3 );
        assertEquals( ba.length, 3 );

        ba.readBytes( bb, 0, ba.length );

        bb.position = 0;
        assertEquals( bb.bytesAvailable, 3 );

        assertEquals( bb.readUnsignedByte(), 2 );
        assertEquals( bb.readUnsignedShort(), 140 );

        bb.clear();
        ba.clear();
    }
}
