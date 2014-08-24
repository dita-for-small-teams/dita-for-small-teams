(: =====================================================

   Load DITA map and dependencies to eXist-db
   
   Author: W. Eliot Kimber

   ===================================================== :)
   
import module namespace xmldb="http://exist-db.org/xquery/xmldb";
import module namespace validation="http://exist-db.org/xquery/validation";   
import module namespace file="http://exist-db.org/xquery/file";


(: The directory load from: :)
declare variable $dir external;
declare variable $collection external;
declare variable $catalogURI external;

(: Create the specified collection directory if it does not already
   exist. Returns the creation report.
 :)
declare function local:mkCollectionDir($collection as xs:string,
                                       $dir as xs:string) as xs:string {
  let $tokens := tokenize($dir, '/')
  let $newDir := concat($collection, $tokens[1])
  return if (xmldb:collection-available($newDir))
            then true()
            else xmldb:create-collection($collection, $dir)                 
};

declare function local:loadFile($dir, $file as element(file:file)) as node()* {
    let $filename as xs:string := xs:string($file/@name)
    let $subdirs as xs:string := xs:string($file/@subdir)
    let $storeCollection := local:mkCollectionDir($collection, $subdirs)
    let $ext := tokenize($filename, '\\.')[last()]
    let $isXMl := $ext = ('xml', 'dita', 'ditamap')
    let $mimeType := if ($isXMl) then 'text/xml' else 'application/octet'
    
    let $fileURI := string-join(('file://', $dir, $subdirs, $filename), '/')

    let $inDoc := if ($isXMl)
                     then validation:jaxp-parse($fileURI, true(), ($catalogURI))
                     else xs:anyURI($fileURI)

    let $loadStatus := if ($storeCollection)
                          then xmldb:store($storeCollection, 
                                           $filename, 
                                           $inDoc,
                                           $mimeType)                                
                          else ''
    
    return (<file name="{$filename}" loadstatus="{$loadStatus}" collection="{$storeCollection}"/>)
};


<loadresult>{

let $dirlist := file:directory-list($dir, '**/*')
for $file in $dirlist/file:file
    return (if (not(starts-with(string($file/@name), '.'))) then local:loadFile($dir, $file) else '')

}</loadresult>


(: ==================== End of Module ================================= :)