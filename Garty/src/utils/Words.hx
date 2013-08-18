package utils;

class Words
{
    public static function wordsInOrder( ordered : Array<String>, all : Array<String> ) : Bool {
        var aIndex = 0;
        
        if ( all.length < ordered.length ) {
            return false;
        }
        
        for ( o in ordered ) {
            while ( aIndex < all.length ) {
                if ( o == all[aIndex++] ) {
                    break;
                }
            }
            if ( aIndex >= all.length ) {
                return false;
            }
        }
        return true;
    }
}