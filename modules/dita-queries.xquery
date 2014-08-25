(: Queries for DITA Content :)

<result>{

let $elems := collection("/db/apps/dita-test-01/content")/*

  for $elem in $elems return (<topic tagname="{name($elem)}" 
              uri="{document-uri(root($elem))}" 
              id="{$elem/@id}"
              class="{$elem/@class}"/>)  
}</result>