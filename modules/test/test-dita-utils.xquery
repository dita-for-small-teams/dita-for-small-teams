(: Test cases for the dita-utils XQuery module :)

import module namespace df="http://dita-for-small-teams.org/xquery/modules/dita-utils" at "file:/Users/ekimber/workspace/dita-for-small-teams/modules/util/dita-utils.xquery";
import module namespace relpath="http://dita-for-small-teams.org/xquery/modules/relpath-utils" at "file:/Users/ekimber/workspace/dita-for-small-teams/modules/util/relpath-utils.xquery";

declare variable $thisModuleUri external;

declare function local:assertEqualStr($test as xs:string, $cand as xs:string) {
   let $result as xs:boolean := $test = $cand
   return concat(if (not($result)) then 'FAIL: ' else 'Pass', 
           if (not($result))
                       then concat('Expected "', $test, '", got "', $cand, '"') 
                       else '')
};

declare function local:assertNotEqualStr($test as xs:string, $cand as xs:string) {
   let $result as xs:boolean := $test != $cand
   return concat(if (not($result)) then 'FAIL: ' else 'Pass', 
           if (not($result))
                       then concat('Candidate string "', $cand, '" equals "', $test, '"') 
                       else '')
};

declare function local:assertTrue($cand as xs:boolean)  {
   let $result := $cand
   return concat(if (not($result)) then 'FAIL: ' else 'Pass', 
           if (not($result)) 
              then concat('Expected true(), got ', $cand, '()') 
              else '')
};

declare function local:testGetRelativePath() {
 let $testDataUri := relpath:newFile(relpath:getParent($thisModuleUri), 
 'getRelativePathTest.xml')
 let $testData := doc($testDataUri)
 for $testCase at $pos in $testData/*/test
      let $negate := string($testCase/@negate) = 'true'
      let $result := string($testCase/result)
      let $source := string($testCase/source)
      let $target := string($testCase/target)
      let $response := relpath:getRelativePath($source, $target)
      return (<test name="relpath:getRelativePath {$pos}"
          pass="{if ($negate) 
                    then not(local:assertEqualStr($result, $response))
                    else local:assertEqualStr($result, $response)}"
      />)
};

<result> {
  let $topic01 := doc("/db/apps/dita-test-01/content/epub-test/chapters/chapter_1.xml")
  let $topicElem := $topic01/*
  return (
    <test name="relpath:getBaseUri">{local:assertEqualStr('/db/apps/dita-test-01/content/epub-test/chapters/chapter_1.xml',
                                     relpath:base-uri($topicElem/*[1]))}</test>,
    <test name="relpath:encodeUri 1">{local:assertEqualStr('/foo/bar%20baz/fred#fragid?queryparam=value',
                                     relpath:encodeUri('/foo/bar baz/fred#fragid?queryparam=value'))}</test>,
    <test name="relpath:encodeUri 2">{local:assertEqualStr('/foo/bar%20baz/fred#fragid%5B2%5D',
                                     relpath:encodeUri('/foo/bar baz/fred#fragid[2]'))}</test>,
    <test name="relpath:encodeUri 3">{local:assertEqualStr('/foo/bar%20baz/fred?queryparam=value',
                                     relpath:encodeUri('/foo/bar baz/fred?queryparam=value'))}</test>,
    <test name="getNavtitleForTopic">{local:assertEqualStr('The Cyclone', df:getNavtitleForTopic($topicElem))}</test>,
    <test name="df:class 1">{local:assertTrue(not(df:class($topicElem, 'topic/p')))}</test>,
    <test name="df:class 2">{local:assertTrue(not(df:class($topicElem, 'topic/p')))}</test>,
    <test name="df:class 3">{local:assertTrue(df:class($topicElem, 'topic/topic'))}</test>,
    <test name="df:class 4">{local:assertTrue(df:class($topicElem, 'chapter/chapter'))}</test>,
    <test name="getBaseClass 1">{local:assertEqualStr('topic/topic', df:getBaseClass($topicElem))}</test>,
    <test name="getBaseClass 2">{local:assertNotEqualStr('chapter/chapter', df:getBaseClass($topicElem))}</test>,
    <test name="getHTMLClass 1">{local:assertEqualStr('chapter', df:getHtmlClass($topicElem))}</test>,
    <test name="getHTMLClass 2">{local:assertEqualStr('para-first', df:getHtmlClass($topicElem/body/p[1]))}</test>,
    <test name="relpath:getName 1">{local:assertEqualStr('filename.ext', 
        relpath:getName('/foo/bar/filename.ext'))}</test>,
    <test name="relpath:getName 2">{local:assertEqualStr('filename.ext', 
        relpath:getName('filename.ext'))}</test>,
    <test name="relpath:getNamePart 1">{local:assertEqualStr('filename', 
        relpath:getNamePart('/foo/bar/filename.ext'))}</test>,
    <test name="relpath:getExtension 1">{local:assertEqualStr('ext', 
        relpath:getExtension('/foo/bar/filename.ext'))}</test>,
    <test name="relpath:getParent 1">{local:assertEqualStr('/foo/bar', 
        relpath:getParent('/foo/bar/filename.ext'))}</test>,
    <test name="relpath:newFile 1">{local:assertEqualStr('/foo/bar/filename.ext', 
        relpath:newFile('/foo/bar', 'filename.ext'))}</test>,
    <test name="relpath:newFile 2">{local:assertEqualStr('filename.ext', 
        relpath:newFile('', 'filename.ext'))}</test>,
    <test name="relpath:newFile 3">{local:assertEqualStr('/filename.ext', 
        relpath:newFile('/', 'filename.ext'))}</test>,
    <test name="relpath:getResourcePartOfUri 1">{local:assertEqualStr('/filename.ext', 
        relpath:getResourcePartOfUri('/filename.ext#someid'))}</test>,
    <test name="relpath:getResourcePartOfUri 2">{local:assertEqualStr('/filename.ext', 
        relpath:getResourcePartOfUri('/filename.ext?param=value'))}</test>,
    <test name="relpath:getResourcePartOfUri 3">{local:assertEqualStr('/filename.ext', 
        relpath:getResourcePartOfUri('/filename.ext#someid?param=value'))}</test>,
    <test name="relpath:getFragmentId 1">{local:assertEqualStr('', 
        relpath:getFragmentId('/filename.ext?param=value'))}</test>,
    <test name="relpath:getFragmentId 2">{local:assertEqualStr('someid', 
        relpath:getFragmentId('/filename.ext#someid'))}</test>,
    <test name="relpath:getFragmentId 3">{local:assertEqualStr('someid', 
        relpath:getFragmentId('/filename.ext#someid?param=value'))}</test>,
    <test name="relpath:toUrl 1">{local:assertEqualStr('/foo/bar/filename.ext', 
        relpath:toUrl('/foo/bar/filename.ext'))}</test>,
    <test name="relpath:toUrl 2">{local:assertEqualStr('/foo/bar/filename.ext', 
        relpath:toUrl('\foo\bar\filename.ext'))}</test>,
    <test name="relpath:toUrl 3">{local:assertEqualStr('file:/c:/foo/bar/filename.ext', 
        relpath:toUrl('c:\foo\bar\filename.ext'))}</test>,
    <test name="relpath:toUrl 4">{local:assertEqualStr('http://foo/bar/filename.ext', 
        relpath:toUrl('http://foo/bar/filename.ext'))}</test>,
    local:testGetRelativePath(),
    
    ''
    )

}
</result>

(: End of module :)