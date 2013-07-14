package gcc;

import gcc.Lexer.Token;
import gcc.Lexer.Descriptor;

enum ParseLeaf {
    Verb(token: Token, index: Int);
    Noun(token: Token, index: Int);
    Adjective(token: Token, index: Int);
}

enum ParseTree {
    Leaf(val: ParseLeaf);
    Node(left: ParseTree, right: ParseTree);
}

class Parser {


}
