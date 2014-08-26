(: =====================================================

   Relative Path Utilities
   
   Provides functions for working with URLs.
   
   Author: W. Eliot Kimber
   
   Copyright (c) DITA For Small Teams
   Licensed under Apache License 2
   

   ===================================================== :)
   
module namespace relpath="http://dita-for-small-teams.org/xquery/modules/relpath-utils";

declare function relpath:base-uri($context as node()) as xs:string {
    let $baseUri as xs:string := string(base-uri($context))
    let $result as xs:string := if (starts-with($baseUri, 'file:///'))
                             then (concat('file:/', substring-after($baseUri, 'file:///')))
                             else $baseUri
    return $result
};

(: Encode a URI string, avoiding encoding of the path separators.

   This is necessary because fn:encode-for-uri() encodes everything, including
   "/" characers. It's not intended to be used on full URIs but only on 
   parts of URIs that need to be encoded.
:)
 declare function relpath:encodeUri($inUriString as xs:string) as xs:string {
    let $parts := tokenize($inUriString, '[#\?]')
    let $pathTokens as xs:string* := for $token in tokenize($parts[1], '/')
                                          return encode-for-uri($token)
    let $fragmentID := if (contains($inUriString, '#')) then $parts[2] else ''
    let $queryPart := if (contains($inUriString, '?'))
         then if (contains($inUriString, '#')) then $parts[3] else $parts[2]
         else ''
    let $escapedFragId as xs:string := if ($fragmentID) 
             then concat('#', encode-for-uri($fragmentID)) 
             else ''
    let $escapedQueryPart := if ($queryPart) then concat('?', $queryPart) else ''
    let $result  as xs:string := concat(string-join($pathTokens, '/'), $escapedFragId, $escapedQueryPart)
    return $result
};



(: ============== End of module ============== :)