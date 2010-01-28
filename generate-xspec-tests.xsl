<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns="http://www.w3.org/1999/XSL/TransformAlias"
  xmlns:test="http://www.jenitennison.com/xslt/unit-test"
  exclude-result-prefixes="#default test"
  xmlns:x="http://www.jenitennison.com/xslt/xspec"
  xmlns:o="http://www.w3.org/1999/XSL/TransformAliasAlias"
  xmlns:impl="urn:x-xspec:compile:xslt:impl">

<xsl:import href="generate-common-tests.xsl"/>
<xsl:import href="generate-tests-helper.xsl" />

<xsl:namespace-alias stylesheet-prefix="#default" result-prefix="xsl"/>

<xsl:preserve-space elements="x:space" />

<xsl:output indent="yes" encoding="ISO-8859-1" />  


<xsl:variable name="stylesheet-uri" as="xs:anyURI" 
  select="resolve-uri(/x:description/@stylesheet, base-uri(/x:description))" />  

<xsl:variable name="stylesheet" as="document-node()" 
  select="doc($stylesheet-uri)" />

<xsl:template match="/">
  <xsl:apply-templates select="." mode="x:generate-tests" />
</xsl:template>

<!-- *** x:generate-tests *** -->
<!-- Does the generation of the test stylesheet -->
  
<xsl:template match="x:description" mode="x:generate-tests">
  <xsl:variable name="pending" as="node()?"
  	select=".//@focus" />
  <stylesheet version="2.0">
    <xsl:apply-templates select="." mode="x:copy-namespaces" />
  	<import href="{$stylesheet-uri}" />
  	<import href="{resolve-uri('generate-tests-utils.xsl', static-base-uri())}"/>
    <!-- This namespace alias is used for when the testing process needs to test
         the generation of XSLT! -->
    <namespace-alias stylesheet-prefix="o" result-prefix="xsl" />
    <variable name="x:stylesheet-uri" as="xs:string" select="'{$stylesheet-uri}'" />
  	<output name="report" method="xml" indent="yes" />
    <xsl:apply-templates select="x:param" mode="x:generate-declarations" />
    <!--
    <template match="/">
      <call-template name="main" />
    </template>
    -->
    <template name="x:main">
      <message>
        <text>Testing with </text>
        <value-of select="system-property('xsl:product-name')" />
        <text><xsl:text> </xsl:text></text>
        <value-of select="system-property('xsl:product-version')" />
      </message>
    	<result-document format="report">
	      <processing-instruction name="xml-stylesheet">
	        <xsl:text>type="text/xsl" href="</xsl:text>
	        <xsl:value-of select="resolve-uri('format-xspec-report.xsl',
	          static-base-uri())" />
	        <xsl:text>"</xsl:text>
	      </processing-instruction>
	      <!-- This bit of jiggery-pokery with the $stylesheet-uri variable is so
	        that the URI appears in the trace report generated from running the
	        test stylesheet, which can then be picked up by stylesheets that
	        process *that* to generate a coverage report -->
	      <x:report stylesheet="{{$x:stylesheet-uri}}"
	        date="{{current-dateTime()}}">
	        <xsl:apply-templates mode="x:generate-calls">
	          <xsl:with-param name="pending" select="$pending" tunnel="yes" />
	        </xsl:apply-templates>
	      </x:report>
    	</result-document>
    </template>
    <xsl:apply-templates mode="x:generate-templates">
      <xsl:with-param name="pending" select="$pending" tunnel="yes" />
    </xsl:apply-templates>
  </stylesheet>
</xsl:template>

<!-- *** x:generate-calls *** -->
<!-- Generates the calls to the templates that perform the tests themselves --> 

<xsl:template match="x:pending" mode="x:generate-calls">
  <xsl:apply-templates mode="x:generate-calls">
    <xsl:with-param name="pending" select="x:label(.)" tunnel="yes" />
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="x:scenario" mode="x:generate-calls">
  <call-template name="x:{generate-id()}" />
</xsl:template>

<xsl:template match="x:expect" mode="x:generate-calls">
  <xsl:param name="pending" as="node()?" select="()" tunnel="yes" />
  <call-template name="x:{generate-id()}">
    <xsl:if test="empty($pending) and not(ancestor::x:scenario/@pending)">
      <with-param name="x:result" select="$impl:actual-result"/>
    </xsl:if>
  </call-template>
</xsl:template>  
  
<xsl:template match="*" mode="x:generate-calls" />

<!-- *** x:generate-templates *** -->
<!-- Generates the templates that perform the tests -->

<xsl:template match="x:pending" mode="x:generate-templates">
  <xsl:apply-templates mode="x:generate-templates">
    <xsl:with-param name="pending" select="x:label(.)" tunnel="yes" />
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="x:scenario" mode="x:generate-templates">
  <xsl:param name="pending" as="node()?" select="()" tunnel="yes" />
  <xsl:param name="context" as="element(x:context)?" select="()" tunnel="yes" />
  <xsl:param name="call" as="element(x:call)?" select="()" tunnel="yes" />
  <xsl:variable name="new-pending" as="node()?" 
    select="if (@focus) then () else if (@pending) then @pending else $pending" />
  <xsl:variable name="new-context" as="element(x:context)?">
    <xsl:choose>
      <xsl:when test="x:context">
        <xsl:variable name="local-params" as="element(x:param)*" 
          select="x:context/x:param" />
        <x:context>
          <xsl:sequence select="$context/@*" />
          <xsl:sequence select="x:context/@*" />
          <xsl:sequence select="$context/x:param[not(@name = $local-params/@name)], $local-params" />
          <xsl:choose>
            <xsl:when test="x:context/(node() except x:param)">
              <xsl:sequence select="x:context/(node() except x:param)" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:sequence select="$context/(node() except x:param)" />
            </xsl:otherwise>
          </xsl:choose>
        </x:context>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$context" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="new-call" as="element(x:call)?">
    <xsl:choose>
      <xsl:when test="x:call">
        <xsl:variable name="local-params" as="element(x:param)*"
          select="x:call/x:param" />
        <x:call>
          <xsl:sequence select="$call/@*" />
          <xsl:sequence select="x:call/@*" />
          <xsl:sequence select="$call/x:param[not(@name = $local-params/@name)], $local-params" />
        </x:call>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$call" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <!-- We have to create these error messages at this stage because before now
       we didn't have merged versions of the environment -->
  <xsl:if test="$new-context/@href and ($new-context/node() except $new-context/x:param)">
    <xsl:message terminate="yes">
      <xsl:text>ERROR in scenario "</xsl:text>
      <xsl:value-of select="x:label(.)" />
      <xsl:text>": can't set the context document using both the href</xsl:text>
      <xsl:text> attribute and the content of &lt;context&gt;</xsl:text>
    </xsl:message>
  </xsl:if>
  <xsl:if test="$new-call/@template and $new-call/@function">
    <xsl:message terminate="yes">
      <xsl:text>ERROR in scenario "</xsl:text>
      <xsl:value-of select="x:label(.)" />
      <xsl:text>": can't call a function and a template at the same time</xsl:text>
    </xsl:message>
  </xsl:if>
  <xsl:if test="$new-context and $new-call/@function">
    <xsl:message terminate="yes">
      <xsl:text>ERROR in scenario "</xsl:text>
      <xsl:value-of select="x:label(.)" />
      <xsl:text>": can't set a context and call a function at the same time</xsl:text>
    </xsl:message>
  </xsl:if>
  <xsl:if test="x:expect and not($new-context) and not($new-call)">
    <xsl:message terminate="yes">
      <xsl:text>ERROR in scenario "</xsl:text>
      <xsl:value-of select="x:label(.)" />
      <xsl:text>": there are tests in this scenario but no call or context has been given</xsl:text>
    </xsl:message>
  </xsl:if>
  <template name="x:{generate-id()}">
  	<message>
  		<xsl:if test="exists($new-pending)">
  			<xsl:text>PENDING: </xsl:text>
  			<xsl:if test="$pending != ''">(<xsl:value-of select="normalize-space($pending)" />)</xsl:if>
  		</xsl:if>
  		<xsl:if test="parent::x:scenario"><xsl:text>..</xsl:text></xsl:if>
  		<xsl:value-of select="normalize-space(x:label(.))" />
  	</message>
    <x:scenario>
      <xsl:if test="exists($new-pending) and not(.//@focus)">
        <xsl:attribute name="pending" select="$pending" />
      </xsl:if>
    	<xsl:sequence select="x:label(.)" />
      <xsl:apply-templates select="x:context | x:call" mode="x:report" />
      <xsl:if test="empty($new-pending) and x:expect">
        <variable name="impl:actual-result" as="item()*">
          <xsl:choose>
            <xsl:when test="$new-call/@template">
              <!-- Set up variables containing the parameter values -->
              <xsl:apply-templates select="$new-call/x:param" mode="x:generate-tests" />
              <!-- Create the template call -->
              <xsl:variable name="template-call">
                <call-template name="{$new-call/@template}">
                  <xsl:for-each select="$new-call/x:param">
                    <with-param name="{@name}" select="${@name}">
                      <xsl:copy-of select="@tunnel, @as" />
                    </with-param>
                  </xsl:for-each>
                </call-template>
              </xsl:variable>
              <xsl:choose>
                <xsl:when test="$new-context">
                  <!-- Set up the $context variable -->
                  <xsl:apply-templates select="$new-context" mode="x:generate-tests" />
                  <!-- Switch to the context and call the template -->
                  <for-each select="$context">
                    <xsl:copy-of select="$template-call" />
                  </for-each>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:copy-of select="$template-call" />
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:when test="$new-call/@function">
              <!-- Set up variables containing the parameter values -->
              <xsl:apply-templates select="$new-call/x:param" mode="x:generate-tests" />
              <!-- Create the function call -->
              <sequence>
                <xsl:attribute name="select">
                  <xsl:value-of select="$new-call/@function" />
                  <xsl:text>(</xsl:text>
                  <xsl:for-each select="$new-call/x:param">
                    <xsl:sort select="xs:integer(@position)" />
                    <xsl:text>$</xsl:text>
                    <xsl:value-of select="if (@name) then @name else generate-id()" />
                    <xsl:if test="position() != last()">, </xsl:if>
                  </xsl:for-each>
                  <xsl:text>)</xsl:text>
                </xsl:attribute>
              </sequence>
            </xsl:when>
            <xsl:otherwise>
              <!-- Set up the $context variable -->
              <xsl:apply-templates select="$new-context" mode="x:generate-tests" />
              <!-- Set up variables containing the parameter values -->
              <xsl:apply-templates select="$new-context/x:param" mode="x:generate-tests" />
              <!-- Create the template call -->
              <apply-templates select="$context">
                <xsl:sequence select="$new-context/@mode" />
                <xsl:for-each select="$new-context/x:param">
                  <with-param name="{@name}" select="${@name}">
                    <xsl:copy-of select="@tunnel, @as" />
                  </with-param>
                </xsl:for-each>
              </apply-templates>
            </xsl:otherwise>
          </xsl:choose>      
        </variable>
        <call-template name="test:report-value">
          <with-param name="value" select="$impl:actual-result" />
          <with-param name="wrapper-name" select="'x:result'" />
          <with-param name="wrapper-ns" select="'http://www.jenitennison.com/xslt/xspec'" />
        </call-template>
      </xsl:if>
      <xsl:apply-templates mode="x:generate-calls">
        <xsl:with-param name="pending" select="$new-pending" tunnel="yes" />
      </xsl:apply-templates>
    </x:scenario>
  </template>
  <xsl:apply-templates mode="x:generate-templates">
    <xsl:with-param name="pending" select="$new-pending" tunnel="yes" />
    <xsl:with-param name="context" select="$new-context" tunnel="yes" />
    <xsl:with-param name="call" select="$new-call" tunnel="yes" />
  </xsl:apply-templates>
</xsl:template>

<!--
    Generate the following:

        <template name="x:...">
           <param name="x:result" required="yes"/>       # if not pending
           <message>
              Running (pending?) assertion...
           </message>
           # if not pending
              <variable name="impl:expected" ...>   # depend on content, @href and @select
              # if @test, evaluate it with result as context node then
              #   if it is not a boolean, compare it to $impl:expected
              # if no @test, compare result to $impl:expected
           # fi
           <x:test>
              ...
           </x:test>
        </template>
-->
<xsl:template match="x:expect" mode="x:generate-templates">
  <xsl:param name="pending" as="node()?" select="()" tunnel="yes" />
  <xsl:param name="context" as="element(x:context)?" required="yes" tunnel="yes" />
  <xsl:param name="call" as="element(x:call)?" required="yes" tunnel="yes" />  
  <template name="x:{generate-id()}">
    <xsl:if test="empty($pending)">
      <param name="x:result" required="yes"/>
    </xsl:if>
    <message>
      <xsl:if test="exists($pending)">
        <xsl:text>PENDING: </xsl:text>
        <xsl:if test="normalize-space($pending) != ''">(<xsl:value-of select="normalize-space($pending)" />)</xsl:if>
      </xsl:if>
      <xsl:text>    </xsl:text>
      <xsl:value-of select="normalize-space(x:label(.))" />
    </message>
    <xsl:if test="empty($pending)">
      <xsl:variable name="version" as="xs:double" 
        select="(ancestor-or-self::*[@xslt-version]/@xslt-version, 2.0)[1]" />
      <xsl:apply-templates select="." mode="test:generate-variable-declarations">
        <xsl:with-param name="var" select="'impl:expected'" />
      </xsl:apply-templates>
      <xsl:choose>
        <xsl:when test="@test">
          <variable name="impl:test-items" as="item()*">
            <choose>
              <!-- From trying this out, it seems like it's useful for the test
                   to be able to test the nodes that are generated in the
                   $x:result as if they were *children* of the context node.
                   Have to experiment a bit to see if that really is the case.                   
                   TODO: To remove. Use directly $x:result instead.  See issue 14. -->
              <when test="$x:result instance of node()+">
                <document>
                  <copy-of select="$x:result" />
                </document>
              </when>
              <otherwise>
                <sequence select="$x:result" />
              </otherwise>
            </choose>
          </variable>
          <variable name="impl:test-result" as="item()*">
             <choose>
                <when test="count($impl:test-items) eq 1">
                   <for-each select="$impl:test-items">
                      <sequence select="{ @test }" version="{ $version }"/>
                   </for-each>
                </when>
                <otherwise>
                   <sequence select="{ @test }" version="{ $version }"/>
                </otherwise>
             </choose>
          </variable>
          <!-- TODO: A predicate should always return exactly one boolean, or
               this is an error.  See issue 5.-->
          <variable name="impl:boolean-test" as="xs:boolean"
            select="$impl:test-result instance of xs:boolean" />
          <variable name="impl:successful" as="xs:boolean"
            select="if ($impl:boolean-test) then $impl:test-result
                    else test:deep-equal($impl:expected, $impl:test-result, {$version})" />
        </xsl:when>
        <xsl:otherwise>
          <variable name="impl:successful" as="xs:boolean" 
            select="test:deep-equal($impl:expected, $x:result, {$version})" />
        </xsl:otherwise>
      </xsl:choose>
      <if test="not($impl:successful)">
        <message>
          <xsl:text>      FAILED</xsl:text>
        </message>
      </if>
    </xsl:if>
    <x:test>
      <xsl:choose>
        <xsl:when test="exists($pending)">
          <xsl:attribute name="pending" select="$pending" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="successful" select="'{$impl:successful}'" />
        </xsl:otherwise>
      </xsl:choose>
      <xsl:sequence select="x:label(.)"/>
      <xsl:if test="@test and empty($pending)">
         <if test="not($impl:boolean-test)">
            <call-template name="test:report-value">
               <with-param name="value"        select="$impl:test-result"/>
               <with-param name="wrapper-name" select="'x:result'"/>
               <with-param name="wrapper-ns"   select="'http://www.jenitennison.com/xslt/xspec'"/>
            </call-template>
         </if>
      </xsl:if>
      <xsl:if test="empty($pending)">
         <call-template name="test:report-value">
            <with-param name="value"        select="$impl:expected"/>
            <with-param name="wrapper-name" select="'x:expect'"/>
            <with-param name="wrapper-ns"   select="'http://www.jenitennison.com/xslt/xspec'"/>
         </call-template>
      </xsl:if>
    </x:test>
 </template>
</xsl:template>

<xsl:template match="*" mode="x:generate-templates" />

<!-- *** x:generate-declarations *** -->
<!-- Code to generate parameter declarations -->
<xsl:template match="x:param" mode="x:generate-declarations">
  <xsl:apply-templates select="." mode="test:generate-variable-declarations">
    <xsl:with-param name="var" select="@name" />
    <xsl:with-param name="type" select="'param'" />
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="x:space" mode="test:create-xslt-generator">
  <text><xsl:value-of select="." /></text>
</xsl:template>  
  

<!-- *** x:generate-tests *** -->
<!-- Helper code for the tests -->

<xsl:template match="x:context" mode="x:generate-tests">
	<xsl:variable name="context" as="element(x:context)">
		<x:context>
			<xsl:sequence select="@*" />
			<xsl:sequence select="node() except x:param" />
		</x:context>
	</xsl:variable>
  <xsl:apply-templates select="$context" mode="test:generate-variable-declarations">
    <xsl:with-param name="var" select="'context'" />
  </xsl:apply-templates>
</xsl:template>  

<xsl:template match="x:param" mode="x:generate-tests">
  <xsl:apply-templates select="." mode="test:generate-variable-declarations">
    <xsl:with-param name="var" select="if (@name) then @name else generate-id()" />
  </xsl:apply-templates>
</xsl:template>  

<xsl:template match="x:context | x:param" mode="x:report">
  <xsl:element name="x:{local-name()}">
  	<xsl:apply-templates select="@*" mode="x:report" />
    <xsl:apply-templates mode="test:create-xslt-generator" />
  </xsl:element>
</xsl:template>
  
<xsl:template match="x:call" mode="x:report">
  <x:call>
    <xsl:copy-of select="@*" />
    <xsl:apply-templates mode="x:report" />
  </x:call>
</xsl:template>

<xsl:template match="@select" mode="x:report">
	<xsl:attribute name="select"
		select="replace(replace(., '\{', '{{'), '\}', '}}')" />
</xsl:template>

<xsl:template match="@*" mode="x:report">
	<xsl:sequence select="." />
</xsl:template>

<xsl:function name="x:label" as="node()?">
	<xsl:param name="labelled" as="element()" />
	<xsl:choose>
		<xsl:when test="exists($labelled/x:label)">
			<xsl:sequence select="$labelled/x:label" />
		</xsl:when>
		<xsl:otherwise>
			<x:label><xsl:value-of select="$labelled/@label" /></x:label>
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

</xsl:stylesheet>
