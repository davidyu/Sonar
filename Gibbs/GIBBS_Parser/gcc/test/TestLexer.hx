package gcc.test;

class TestLexer extends haxe.unit.TestCase {
    public function testBasic() {
        var line:String = "grab glass";
        var tokens:Array<gcc.Lexer.Token> = Lexer.lex(line);

        assertTrue(Type.enumEq(tokens[0], gcc.Lexer.Token.Verb("grab")));
        assertTrue(Type.enumEq(tokens[1], gcc.Lexer.Token.Noun("glass")));
    }
}
