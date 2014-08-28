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
declare function relpath:newFile($parentPath as xs:string, $childFile as xs:string) as xs:string {
  let $result := if (matches($childFile, '^(/|[a-z]+:)'))
     then $childFile
     else if ($parentPath = '/')
          then relpath:getAbsolutePath(concat($parentPath, $childFile))
          else 
            let $tempParentPath := if (ends-with($parentPath, '/') and $parentPath != '/') 
                  then substring($parentPath, 1, string-length($parentPath) - 1) 
                  else $parentPath
            let $parentTokens := tokenize($tempParentPath, '/')
            let $firstToken := $parentTokens[1]
            let $childTokens := tokenize($childFile, '/')
            let $tempPath := string-join(($parentTokens, $childTokens), '/')
            return if ($firstToken = '..') 
              then $tempPath 
              else relpath:getAbsolutePath($tempPath)
  return $result
};

(: Gets the absolute path for a relative path :)
declare function relpath:getAbsolutePath($sourcePath as xs:string) as xs:string {
  let $pathTokens := tokenize($sourcePath, '/')
  let $baseResult := string-join(relpath:makePathAbsolute($pathTokens, ()), '/')
  let $baseResult2 := if (ends-with($baseResult, '/')) 
                 then substring($baseResult, 1, string-length($baseResult) -1) 
                 else $baseResult
  let $result := if (starts-with($sourcePath, '/') and not(starts-with($baseResult2, '/')))
                    then concat('/', $baseResult2)
                    else $baseResult2
  return $result
};

(: Makes a relative path absolute. :)
declare function relpath:makePathAbsolute($pathTokens as xs:string*, 
                                          $resultTokens as xs:string*) as xs:string* {
   let $result := if (count($pathTokens) = 0)
                             then $resultTokens
                             else if ($pathTokens[1] = '.')
                                  then relpath:makePathAbsolute($pathTokens[position() > 1], $resultTokens)
                                  else if ($pathTokens[1] = '..')
                                       then relpath:makePathAbsolute($pathTokens[position() > 1], $resultTokens[position() lt last()])
                                       else relpath:makePathAbsolute($pathTokens[position() > 1], ($resultTokens, $pathTokens[1]))
  return $result
};

(: Gets the resource part of a URI, that is, everything before any '#' or '?' :)
declare function relpath:getResourcePartOfUri($uriString as xs:string) as xs:string {
  let $result := if (contains($uriString, '#')) 
                    then substring-before($uriString, '#') 
                    else if (contains($uriString, '?'))
                            then substring-before($uriString, '?')
                            else $uriString
  return $result
};

(: Gets the fragment ID part of a URI, if any (the part following '#' and preceding
   any '?' :)
declare function relpath:getFragmentId($uri as xs:string) as xs:string {
  let $baseFragid := if (contains($uri, '#'))
          then substring-after($uri, '#')
          else ''
  let $result := if (contains($baseFragid, '?')) 
      then substring-before($baseFragid, '?') 
      else $baseFragid
  return $result
};

(: Converts a Windows filename into a URL :)
declare function relpath:toUrl($filepath as xs:string) as xs:string {
  let $url := if (contains($filepath, '\'))
                 then translate($filepath, '\', '/')
                 else $filepath
  let $fileUrl := if (matches($url, '^[a-zA-Z]:'))
                     then concat('file:/', $url)
                     else $url
  return $fileUrl
};

(: alculate relative path that gets from from source path to target path.

        Given:
        
        [1]  Target: /A/B/C
        Source: /A/B/C/X
        
        Return: "X"
        
        [2]  Target: /A/B/C
        Source: /E/F/G/X
        
        Return: "/E/F/G/X"
        
        [3]  Target: /A/B/C
        Source: /A/D/E/X
        
        Return: "../../D/E/X"
        
        [4]  Target: /A/B/C
        Source: /A/X
        
        Return: "../../X"
:)

declare function relpath:getRelativePath($source as xs:string,
                                         $target as xs:string) as xs:string {
  let $effectiveSource := if (ends-with($source, '/') and string-length($source) > 1) 
            then substring($source, 1, string-length($source) - 1) 
            else $source
  let $sourceTokens := 
        tokenize((if (starts-with($effectiveSource, '/')) 
                    then substring-after($effectiveSource, '/') 
                    else $effectiveSource), '/')
  let $targetTokens := 
      tokenize((if (starts-with($target, '/')) 
                   then substring-after($target, '/') 
                   else $target), '/')
  let $result := 
     if ((count($sourceTokens) > 0 and count($targetTokens) > 0) and 
                      (($sourceTokens[1] != $targetTokens[1]) and 
                       (contains($sourceTokens[1], ':') or contains($targetTokens[1], ':'))))
        then $target
     else 
       let $resultTokens := relpath:analyzePathTokens($sourceTokens, $targetTokens, ())
       return string-join($resultTokens, '/')
  return $result
};

(: Compare source and target tokens to determine relative
   pathing.
   
   Returns the tokens of the relative path.
 :)
declare function relpath:analyzePathTokens($sourceTokens as xs:string*, 
                                           $targetTokens as xs:string*,
                                           $resultTokens as xs:string*) as xs:string* {
  let $result :=
    if (count($sourceTokens) = 0)
       then ($resultTokens, $targetTokens)
    else
       if ((count($targetTokens) > 0) and ($sourceTokens[1] = $targetTokens[1]))
          then relpath:analyzePathTokens($sourceTokens[position() > 1], $targetTokens[position() > 1], $resultTokens)
          else 
            let $goUps := for $token in $sourceTokens return '..'
            return string-join(($resultTokens, $goUps, $targetTokens), '/')
                                         
  return $result
};

















(: ============== End of module ============== :)