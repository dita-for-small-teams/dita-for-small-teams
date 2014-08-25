(: Test directory-list() :)

import module namespace file="http://exist-db.org/xquery/file";

(: The directory load from: :)
declare variable $dir external;
<testresult>{
let $dirlist := file:directory-list($dir, '**/*')

for $file in $dirlist/file:file
    return $file 
}</testresult>

