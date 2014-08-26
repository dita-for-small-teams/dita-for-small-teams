(: Test cases for the dita-utils XQuery module :)

import module namespace df="http://dita-for-small-teams.org/xquery/modules/dita-utils" at "file:/Users/ekimber/workspace/dita-for-small-teams/modules/util/dita-utils.xquery";

declare function local:assertEqualStr($test as xs:string, $cand as xs:string) {
   let $result as xs:boolean := $test = $cand
   return concat(if (not($result)) then 'FAIL: ' else 'Pass', 
           if (not($result))
                       then concat('Expected /', $test, '/, got /', $cand, '/') 
                       else '')
};

declare function local:assertTrue($cand as xs:boolean)  {
   let $result := $cand
   return concat(if (not($result)) then 'FAIL: ' else 'Pass', 
           if (not($result)) 
              then concat('Expected true(), got ', $cand, '()') 
              else '')
};


<result> {
  let $topic01 := doc("/db/apps/dita-test-01/content/epub-test/chapters/chapter_1.xml")
  let $topicElem := $topic01/*
  return (
    <test name="getNavtitleForTopic">{local:assertEqualStr('The Cyclone', df:getNavtitleForTopic($topicElem))}</test>,
    <test name="dfClass 1">{local:assertTrue(not(df:class($topicElem, 'topic/p')))}</test>,
    <test name="dfClass 2">{local:assertTrue(df:class($topicElem, 'topic/p'))}</test>,
    <test name="dfClass 3">{local:assertTrue(df:class($topicElem, 'topic/topic'))}</test>,
    ''
    )

}
</result>

(: End of module :)