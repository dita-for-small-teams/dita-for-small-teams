(: Queries for DITA Content :)

<result>{

let $elems := collection("/db/apps/dita-test-01/content/d4p")//*[@class != '']

  for $elem in $elems return name($elem)
}</result>