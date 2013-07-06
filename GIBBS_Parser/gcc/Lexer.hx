package gcc;

enum TokenType {
    Noun;
    Verb;
    Article;
    Adjective;
    Unknown;
}

enum Token {
    Noun(val: String);
    Verb(val: String);
    Article(val: String);
    Adjective(val: Descriptor);
    Unknown(val: String);
}

enum Descriptor {
    Number(val: Int);           //3 apple bars vs 1 apple bar
    Description(val: String);   //green lantern vs blue lantern
}

class Lexer {

    private static var dict:Map<String, TokenType>;

    //to be implemented. XML? Script?
    public static function loadDictionary(file:String):Void {

    }

    #if debug
    //start of HACK HACK HACK
    public static function loadDebugDictionary():Void {
        //hack hack hack
        dict = new Map<String, TokenType>();

        var verbs:Array<String> =
            [ "run", "grab", "take", "jump", "go" ];

        var nouns:Array<String> =
            [ "mug", "glass", "pistol", "gun", "bat", "hammer", "crowbar", "item" ];

        for (verb in verbs) {
            dict.set(verb, TokenType.Verb);
        }

        for (noun in nouns) {
            dict.set(noun, TokenType.Noun);
        }
    }
    //end of HACK HACK HACK
    #end

    public static function lex(line:String):Array<Token> {

        #if debug
        if (dict == null) {
            loadDebugDictionary();
        }
        #end

        var words:Array<String> = line.split(" ");
        var tokens:Array<Token>  = new Array<Token>();

        for (word in words) {
            tokens.push(tokenize(word));
        }

        return tokens;
    }

    private static inline function tokenize(word:String):Token {
        return switch getType(word) {
            case TokenType.Noun: Token.Noun(word);
            case TokenType.Verb: Token.Verb(word);
            case TokenType.Adjective: Token.Adjective(Descriptor.Description(word)); //hack; don't worry about numerals for now
            case TokenType.Article: Token.Article(word);
            case TokenType.Unknown: Token.Unknown(word);
        }
    }

    private static function getType(word:String):TokenType {
        if (dict.exists(word)) {
            return dict.get(word);
        }
        return TokenType.Unknown;
    }
}
