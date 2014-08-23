(: Load files to eXist DB via XQuery :)
xquery version "3.0";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
import module namespace xmldb="http://exist-db.org/xquery/xmldb";
import module namespace validation="http://exist-db.org/xquery/validation";

<result>{

let $log-in := xmldb:login("/db", "admin", "admin")
let $uri := xs:anyURI('file:/Users/ekimber/workspace/dita4publishers-work/sample_data/20000_leagues/20000_leagues.ditamap')
let $doc := doc($uri)

let $catalogURI := xs:anyURI('file:///Applications/oxygen/frameworks/dita/DITA-OT/catalog-dita.xml')
(:
let $jaxpDoc := validation:jaxp-parse($doc, true(), ($catalogURI))
:)
let $jaxpDoc := validation:jaxp-parse($uri, true(), ($catalogURI))
let $validationReport := validation:jaxp-report($doc, true(), ($catalogURI))

let $resultDoc := $jaxpDoc

(:
return  ($jaxpDoc)
:)
(: If validation is set to "on" then $doc reflects defaulted attributes: 
return  ($doc)

:)
(:
:)
let $storeResult := (: 'not stored' :) xmldb:store('/db/apps/dita-test-01/content/d4p/20000_leagues', '20000_leagues.ditamap', $resultDoc)  (: :)
return ('validationReport=', $validationReport,
        '&#x0a;storeResult=', $storeResult,
        '&#x0a;resultDoc=', $resultDoc,
        '&#x0a;grammarCache=', validation:show-grammar-cache(),
        ''
        )
(:
return  ($jaxpDoc 
         ,  )
:)

}</result>