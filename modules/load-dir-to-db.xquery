(: =====================================================

   Load DITA map and dependencies to eXist-db
   
   Author: W. Eliot Kimber

   ===================================================== :)
   
import module namespace xmldb="http://exist-db.org/xquery/xmldb";
import module namespace validation="http://exist-db.org/xquery/validation";   
import module namespace file="http://exist-db.org/xquery/file";


(: The directory load from: :)
declare variable $dir external;
(: The collection to load into: :)
declare variable $collection external;
(: URI of entity resolution catalog to use for DTD resolution: :)
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

declare function local:loadFile($dir, 
                                $file as element(file:file),
                                $collectionDir) {
    let $filename as xs:string := xs:string($file/@name)
    let $subdirs as xs:string := xs:string($file/@subdir)
    let $storeCollection := local:mkCollectionDir($collectionDir, $subdirs)
    let $ext := tokenize($filename, "\.")[last()]
    let $isXML := $ext = ('xml', 'dita', 'ditamap')
    let $mimeType := if ($isXML) then 'text/xml' else 'application/octetstream'
    
    let $fileURI as xs:anyURI := xs:anyURI(string-join(('file:/', $dir, $subdirs, $filename), '/'))


    let $inDoc as document-node()? := if ($isXML)
                     then validation:jaxp-parse($fileURI, true(), (xs:anyURI($catalogURI))) 
                     else ()

    let $loadStatus := if ($storeCollection)
                          then xmldb:store($storeCollection, 
                                           $filename, 
                                           if ($inDoc) then $inDoc else $fileURI)
                          else 'collection creation failed'
    
    return (<file name="{$filename}" loadstatus="{$loadStatus}" collection="{$storeCollection}" fileURI="{$fileURI}"></file>)
};


<loadresult>{

let $dirlist := file:directory-list($dir, '**/*')
let $collectionDir := local:mkCollectionDir($collection, tokenize($dir, '/')[last()])

for $file in $dirlist/file:file
    return (if (not(starts-with(string($file/@name), '.'))) then local:loadFile($dir, $file, $collectionDir)
else '') }</loadresult>


(: ==================== End of Module ================================= :)