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

(: Get the name component of a path (the last path token). :)
declare function relpath:getName($sourcePath as xs:string) as xs:string {
  let $result := tokenize($sourcePath, '/')[last()]
  return $result
};

(: Get the name part (filename with any extension removed). :)
declare function relpath:getNamePart($sourcePath as xs:string) as xs:string {
  let $fullName := relpath:getName($sourcePath)
  let $result := if (contains($fullName, '.'))
                    then string-join(tokenize($fullName, '\.')[position() lt last()], '.')
                    else $fullName
  return $result
};

(: Get the extension part of the filename, if any. :)
declare function relpath:getExtension($sourcePath as xs:string) as xs:string {
  let $fullName := relpath:getName($sourcePath)
  let $result := if (contains($fullName, '.'))
      then tokenize($fullName, '\.')[last()]
      else ''
   return $result
};

(: As for Java File.getParent(): returns all but the last
   components of the path. :)
declare function relpath:getParent($sourcePath as xs:string) as xs:string {
  let $fullName := relpath:getName($sourcePath)
  let $result := string-join(tokenize($sourcePath, '/')[position() lt last()], '/')
  return $result
};

(: As for Java File(File, path)): Returns a new a absolute path representing
   the new file. File must be a path (because XSLT has no way to distinguish
   a file from a directory). :)
declare function relpath:newFile($sourcePath as xs:string) as xs:string {
  let $fullName := relpath:getName($sourcePath)
  let $result := if (contains($fullName, '.'))
                    then tokenize($fullName, '\.')[last()]
                    else ''
  return $result
};





















(: ============== End of module ============== :)