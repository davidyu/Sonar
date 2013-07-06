package gcc;

enum TokenType {
    Noun;
    Verb;
    Article;
    Adjective;
}

enum Token {
    Noun(val: String);
    Verb(val: String);
    Article(val: String);
    Adjective(val: Descriptor);
}

enum Descriptor {
    Number(val: Int);           //3 apple bars vs 1 apple bar
    Description(val: String);   //green lantern vs blue lantern
}

class Lexer {

    //start of HACK HACK HACK
    private static var verbs:Array<String> =
        [ "run", "grab", "take", "jump", "go" ];

    private static var nouns:Array<String> =
        [ "mug", "glass", "pistol", "gun", "bat", "hammer", "crowbar", "item" ];

    private static var dict:Map<String, TokenType>;

    public static function loadDictionary():Void {
        //hack hack hack
        dict = new Map<String, TokenType>();

        for (verb in verbs) {
            dict.set(verb, TokenType.Verb);
        }

        for (noun in nouns) {
            dict.set(noun, TokenType.Noun);
        }
    }
    //end of HACK HACK HACK

    public static function lex(line:String):Array<Token> {

        var words:Array<String> = line.split(" ");
        var tokens:Array<Token>  = new Array<Token>();

        for (word in words) {
            tokens.push(tokenize(word));
        }

        return tokens;
    }

    private static function tokenize(word:String):Token {
        return switch getType(word) {
            case TokenType.Noun: Token.Noun(word);
            case TokenType.Verb: Token.Verb(word);
            case TokenType.Adjective: Token.Adjective(Descriptor.Description(word)); //hack; don't worry about numerals for now
            case TokenType.Article: Token.Article(word);
        }
    }

    private static function getType(word:String):TokenType {
        return dict.get(word);
    }
}
