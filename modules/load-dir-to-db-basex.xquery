(: =====================================================

   Load DITA map and dependencies to BaseX
   
   Author: W. Eliot Kimber

   ===================================================== :)
   
(: import module namespace db="http://basex.org/modules/db"; :)

declare variable $db external;
(: The directory load from: :)
declare variable $dir external;
(: The collection to load into: :)
declare variable $collection external;
(: URI of entity resolution catalog to use for DTD resolution: :)
declare variable $catalogURI external;

declare variable $xmlLoadOptions as element() := 
<options>
  <catfile value='{$catalogURI}'/>
  <dtd value='true'/>
  <chop value='false'/>
  <skipcorrupt value='true'/>
  <createfilter value="*.xml,*.dita,*.ditamap,*.ditaval"/>
</options>;

for $file in (file:list($dir, false(), '*.xml,*.dita,*.ditamap,*.ditaval'))
    let $fullDir :=  concat($dir, '/', $file)
    return if (file:is-file($file)) then db:replace($db, $file, $fullDir, $xmlLoadOptions) else (),

for $file in (file:list($dir, true()))
    let $fullDir :=  concat($dir, '/', $file)
    (:return if (file:is-dir($fullDir)) then <cmd>{(concat('db:replace("',$db,'","', $fullDir, '","',$file, '",'), $xmlLoadOptions,')')}</cmd> else () :)
    return if (file:is-dir($fullDir)) then db:replace($db, $file, $fullDir, $xmlLoadOptions) else ()



(: ==================== End of Module ================================= :)