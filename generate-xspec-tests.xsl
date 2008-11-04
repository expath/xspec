<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns="http://www.w3.org/1999/XSL/TransformAlias"
  xmlns:test="http://www.jenitennison.com/xslt/unit-test"
  exclude-result-prefixes="#default test"
  xmlns:s="http://www.jenitennison.com/xslt/xspec"
  xmlns:o="http://www.w3.org/1999/XSL/TransformAliasAlias">
  
<xsl:import href="generate-tests-helper.xsl" />
  
<xsl:namespace-alias stylesheet-prefix="#default" result-prefix="xsl"/>

<xsl:preserve-space elements="s:space" />

<xsl:output indent="yes" encoding="ISO-8859-1" />  


<xsl:variable name="stylesheet-uri" as="xs:anyURI" 
  select="resolve-uri(/s:description/@stylesheet, base-uri(/s:description))" />  

<xsl:variable name="stylesheet" as="document-node()" 
  select="doc($stylesheet-uri)" />

<xsl:template match="/">
  <xsl:apply-templates select="." mode="s:generate-tests" />
</xsl:template>

<xsl:template match="/" mode="s:generate-tests">
  <xsl:variable name="all-specs" as="element(s:description)+">
    <s:description>
      <xsl:apply-templates select="s:description" mode="s:copy-namespaces" />
      <xsl:copy-of select="s:description/@*" />
      <xsl:attribute name="stylesheet" select="$stylesheet-uri" />
      <xsl:apply-templates select="s:gather-specs(s:description)" mode="s:gather-specs" />
    </s:description>
  </xsl:variable>
  <xsl:variable name="unshared-scenarios" as="element(s:description)">
    <xsl:apply-templates select="$all-specs" mode="s:unshare-scenarios" />
  </xsl:variable>
  <xsl:apply-templates select="$unshared-scenarios" mode="s:generate-tests" />
</xsl:template>

<xsl:template match="s:description" mode="s:copy-namespaces">
  <xsl:variable name="e" as="element()" select="." />
  <xsl:for-each select="in-scope-prefixes($e)">
    <xsl:namespace name="{.}" select="namespace-uri-for-prefix(., $e)" />
  </xsl:for-each>
</xsl:template>

<xsl:function name="s:gather-specs" as="element(s:description)+">
  <xsl:param name="visit" as="element(s:description)+" />
  <xsl:variable name="imports" as="element(s:import)*"
    select="$visit/s:import" />
  <xsl:variable name="imported" as="element(s:description)*"
    select="document($imports/@href)/s:description" />
  <xsl:choose>
    <xsl:when test="empty($imported except $visit)">
      <xsl:sequence select="$visit" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="s:gather-specs($visit | $imported)" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:template match="s:description" mode="s:gather-specs">
  <xsl:apply-templates mode="s:gather-specs">
    <xsl:with-param name="xslt-version" tunnel="yes" 
    	select="if (@xslt-version) then @xslt-version else '2.0'" />
  	<xsl:with-param name="preserve-space" tunnel="yes"
  		select="for $qname in tokenize(@preserve-space, '\s+')
  		        return resolve-QName($qname, .)" />
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="s:scenario" mode="s:gather-specs">
  <xsl:param name="xslt-version" as="xs:string" tunnel="yes" required="yes" />
  <s:scenario xslt-version="{$xslt-version}">
    <xsl:copy-of select="@*" />
    <xsl:apply-templates mode="s:gather-specs" />
  </s:scenario>
</xsl:template>
  
<xsl:template match="s:*/@href" mode="s:gather-specs">
  <xsl:attribute name="href" select="resolve-uri(., base-uri(.))" />
</xsl:template>

<xsl:template match="text()[not(normalize-space())]" mode="s:gather-specs">
	<xsl:param name="preserve-space" as="xs:QName*" tunnel="yes" select="()" />
	<xsl:if test="node-name(parent::*) = $preserve-space">
		<s:space>
			<xsl:value-of select="." />
		</s:space>
	</xsl:if>
</xsl:template>

<xsl:template match="node()|@*" mode="s:gather-specs">
  <xsl:copy>
    <xsl:apply-templates select="node()|@*" mode="s:gather-specs" />
  </xsl:copy>
</xsl:template>

<!-- *** s:unshare-scenarios *** -->
<!-- This mode resolves all the <like> elements to bring in the scenarios that
     they specify -->

<xsl:template match="s:description" mode="s:unshare-scenarios">
  <s:description>
    <xsl:apply-templates select="." mode="s:copy-namespaces" />
    <xsl:copy-of select="@*" />
    <xsl:apply-templates select="* except s:scenario[@shared = 'yes']" mode="s:unshare-scenarios" />
  </s:description>
</xsl:template>

<xsl:template match="s:scenario" mode="s:unshare-scenarios">
  <s:scenario>
    <xsl:copy-of select="@* except @shared" />
    <xsl:apply-templates mode="s:unshare-scenarios" />
  </s:scenario>
</xsl:template>

<xsl:key name="scenarios" match="s:scenario" use="@label" />

<xsl:template match="s:like" mode="s:unshare-scenarios">
  <xsl:apply-templates select="key('scenarios', @label)/*" mode="s:unshare-scenarios" />
</xsl:template>

<xsl:template match="s:pending" mode="s:unshare-scenarios">
  <s:pending>
    <xsl:copy-of select="@*" />
    <xsl:apply-templates select="* except s:scenario[@shared = 'yes']" mode="s:unshare-scenarios" />
  </s:pending>
</xsl:template>

<xsl:template match="*" mode="s:unshare-scenarios">
  <xsl:copy-of select="." />
</xsl:template>
  
<!-- *** s:generate-tests *** -->
<!-- Does the generation of the test stylesheet -->
  
<xsl:template match="s:description" mode="s:generate-tests">
  <xsl:variable name="pending" as="xs:string?"
    select="if (.//@focus) then string((.//@focus)[1]) else ()" />
  <stylesheet version="2.0">
    <xsl:apply-templates select="." mode="s:copy-namespaces" />
  	<import href="{$stylesheet-uri}" />
  	<import href="{resolve-uri('generate-tests-utils.xsl', static-base-uri())}"/>
    <!-- This namespace alias is used for when the testing process needs to test
         the generation of XSLT! -->
    <namespace-alias stylesheet-prefix="o" result-prefix="xsl" />
    <variable name="s:stylesheet-uri" as="xs:string" select="'{$stylesheet-uri}'" />
  	<output name="report" method="xml" indent="yes" />
    <xsl:apply-templates select="s:param" mode="s:generate-declarations" />
    <!--
    <template match="/">
      <call-template name="main" />
    </template>
    -->
    <template name="s:main">
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
	      <s:report stylesheet="{{$s:stylesheet-uri}}"
	        date="{{current-dateTime()}}">
	        <xsl:apply-templates mode="s:generate-calls">
	          <xsl:with-param name="pending" select="$pending" tunnel="yes" />
	        </xsl:apply-templates>
	      </s:report>
    	</result-document>
    </template>
    <xsl:apply-templates mode="s:generate-templates">
      <xsl:with-param name="pending" select="$pending" tunnel="yes" />
    </xsl:apply-templates>
  </stylesheet>
</xsl:template>

<!-- *** s:generate-calls *** -->
<!-- Generates the calls to the templates that perform the tests themselves --> 

<xsl:template match="s:pending" mode="s:generate-calls">
  <xsl:apply-templates mode="s:generate-calls">
    <xsl:with-param name="pending" select="if (@label) then string(@label) else ''" tunnel="yes" />
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="s:scenario" mode="s:generate-calls">
  <call-template name="s:{generate-id()}" />
</xsl:template>

<xsl:template match="s:expect" mode="s:generate-calls">
  <xsl:param name="pending" as="xs:string?" select="()" tunnel="yes" />
  <call-template name="s:{generate-id()}">
    <xsl:if test="empty($pending) and not(ancestor::s:scenario/@pending)">
      <with-param name="actual-result" select="$actual-result" />
    </xsl:if>
  </call-template>
</xsl:template>  
  
<xsl:template match="*" mode="s:generate-calls" />

<!-- *** s:generate-templates *** -->
<!-- Generates the templates that perform the tests -->

<xsl:template match="s:pending" mode="s:generate-templates">
  <xsl:apply-templates mode="s:generate-templates">
    <xsl:with-param name="pending" select="if (@label) then string(@label) else ''" tunnel="yes" />
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="s:scenario" mode="s:generate-templates">
  <xsl:param name="pending" as="xs:string?" select="()" tunnel="yes" />
  <xsl:param name="context" as="element(s:context)?" select="()" tunnel="yes" />
  <xsl:param name="call" as="element(s:call)?" select="()" tunnel="yes" />
  <xsl:variable name="new-pending" as="xs:string?" 
    select="if (@focus) then () else if (@pending) then @pending else $pending" />
  <xsl:variable name="new-context" as="element(s:context)?">
    <xsl:choose>
      <xsl:when test="s:context">
        <xsl:variable name="local-params" as="element(s:param)*" 
          select="s:context/s:param" />
        <s:context>
          <xsl:sequence select="$context/@*" />
          <xsl:sequence select="s:context/@*" />
          <xsl:sequence select="$context/s:param[not(@name = $local-params/@name)], $local-params" />
          <xsl:choose>
            <xsl:when test="s:context/(node() except s:param)">
              <xsl:sequence select="s:context/(node() except s:param)" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:sequence select="$context/(node() except s:param)" />
            </xsl:otherwise>
          </xsl:choose>
        </s:context>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$context" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="new-call" as="element(s:call)?">
    <xsl:choose>
      <xsl:when test="s:call">
        <xsl:variable name="local-params" as="element(s:param)*"
          select="s:call/s:param" />
        <s:call>
          <xsl:sequence select="$call/@*" />
          <xsl:sequence select="s:call/@*" />
          <xsl:sequence select="$call/s:param[not(@name = $local-params/@name)], $local-params" />
        </s:call>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$call" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <!-- We have to create these error messages at this stage because before now
       we didn't have merged versions of the environment -->
  <xsl:if test="$new-context/@href and ($new-context/node() except $new-context/s:param)">
    <xsl:message terminate="yes">
      <xsl:text>ERROR in scenario "</xsl:text>
      <xsl:value-of select="@label" />
      <xsl:text>": can't set the context document using both the href</xsl:text>
      <xsl:text> attribute and the content of &lt;context&gt;</xsl:text>
    </xsl:message>
  </xsl:if>
  <xsl:if test="$new-call/@template and $new-call/@function">
    <xsl:message terminate="yes">
      <xsl:text>ERROR in scenario "</xsl:text>
      <xsl:value-of select="@label" />
      <xsl:text>": can't call a function and a template at the same time</xsl:text>
    </xsl:message>
  </xsl:if>
  <xsl:if test="$new-context and $new-call/@function">
    <xsl:message terminate="yes">
      <xsl:text>ERROR in scenario "</xsl:text>
      <xsl:value-of select="@label" />
      <xsl:text>": can't set a context and call a function at the same time</xsl:text>
    </xsl:message>
  </xsl:if>
  <xsl:if test="s:expect and not($new-context) and not($new-call)">
    <xsl:message terminate="yes">
      <xsl:text>ERROR in scenario "</xsl:text>
      <xsl:value-of select="@label" />
      <xsl:text>": there are tests in this scenario but no call or context has been given</xsl:text>
    </xsl:message>
  </xsl:if>
  <template name="s:{generate-id()}">
  	<message>
  		<xsl:if test="exists($new-pending)">
  			<xsl:text>PENDING: </xsl:text>
  			<xsl:if test="$pending != ''">(<xsl:value-of select="$pending" />)</xsl:if>
  		</xsl:if>
  		<xsl:if test="parent::s:scenario"><xsl:text>..</xsl:text></xsl:if>
  		<xsl:value-of select="@label" />
  	</message>
    <s:scenario label="{@label}">
      <xsl:if test="exists($new-pending) and not(.//@focus)">
        <xsl:attribute name="pending" select="$pending" />
      </xsl:if>
      <xsl:apply-templates select="s:context | s:call" mode="s:report" />
      <xsl:if test="empty($new-pending) and s:expect">
        <variable name="actual-result" as="item()*">
          <xsl:choose>
            <xsl:when test="$new-call/@template">
              <!-- Set up variables containing the parameter values -->
              <xsl:apply-templates select="$new-call/s:param" mode="s:generate-tests" />
              <!-- Create the template call -->
              <xsl:variable name="template-call">
                <call-template name="{$new-call/@template}">
                  <xsl:for-each select="$new-call/s:param">
                    <with-param name="{@name}" select="${@name}">
                      <xsl:copy-of select="@tunnel, @as" />
                    </with-param>
                  </xsl:for-each>
                </call-template>
              </xsl:variable>
              <xsl:choose>
                <xsl:when test="$new-context">
                  <!-- Set up the $context variable -->
                  <xsl:apply-templates select="$new-context" mode="s:generate-tests" />
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
              <xsl:apply-templates select="$new-call/s:param" mode="s:generate-tests" />
              <!-- Create the function call -->
              <sequence>
                <xsl:attribute name="select">
                  <xsl:value-of select="$new-call/@function" />
                  <xsl:text>(</xsl:text>
                  <xsl:for-each select="$new-call/s:param">
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
              <xsl:apply-templates select="$new-context" mode="s:generate-tests" />
              <!-- Set up variables containing the parameter values -->
              <xsl:apply-templates select="$new-context/s:param" mode="s:generate-tests" />
              <!-- Create the template call -->
              <apply-templates select="$context">
                <xsl:sequence select="$new-context/@mode" />
                <xsl:for-each select="$new-context/s:param">
                  <with-param name="{@name}" select="${@name}">
                    <xsl:copy-of select="@tunnel, @as" />
                  </with-param>
                </xsl:for-each>
              </apply-templates>
            </xsl:otherwise>
          </xsl:choose>      
        </variable>
        <call-template name="test:report-value">
          <with-param name="value" select="$actual-result" />
          <with-param name="wrapper-name" select="'s:result'" />
          <with-param name="wrapper-ns" select="'http://www.jenitennison.com/xslt/xspec'" />
        </call-template>
      </xsl:if>
      <xsl:apply-templates mode="s:generate-calls">
        <xsl:with-param name="pending" select="$new-pending" tunnel="yes" />
      </xsl:apply-templates>
    </s:scenario>
  </template>
  <xsl:apply-templates mode="s:generate-templates">
    <xsl:with-param name="pending" select="$new-pending" tunnel="yes" />
    <xsl:with-param name="context" select="$new-context" tunnel="yes" />
    <xsl:with-param name="call" select="$new-call" tunnel="yes" />
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="s:expect" mode="s:generate-templates">
  <xsl:param name="pending" as="xs:string?" select="()" tunnel="yes" />
  <xsl:param name="context" as="element(s:context)?" required="yes" tunnel="yes" />
  <xsl:param name="call" as="element(s:call)?" required="yes" tunnel="yes" />  
  <template name="s:{generate-id()}">
    <xsl:if test="empty($pending)">
      <param name="actual-result" as="item()*" required="yes" />
    </xsl:if>
    <message>
      <xsl:if test="exists($pending)">
        <xsl:text>PENDING: </xsl:text>
        <xsl:if test="$pending != ''">(<xsl:value-of select="$pending" />)</xsl:if>
      </xsl:if>
      <xsl:text>    </xsl:text>
      <xsl:value-of select="@label" />
    </message>
    <xsl:if test="empty($pending)">
      <xsl:variable name="version" as="xs:double" 
        select="(ancestor-or-self::*[@xslt-version]/@xslt-version, 2.0)[1]" />
      <xsl:apply-templates select="." mode="test:generate-variable-declarations">
        <xsl:with-param name="var" select="'expected-result'" />
      </xsl:apply-templates>
      <xsl:choose>
        <xsl:when test="@test">
          <variable name="test-items" as="item()*">
            <choose>
              <!-- From trying this out, it seems like it's useful for the test
                to be able to test the nodes that are generated in the
                $actual-result as if they were *children* of the context node.
                Have to experiment a bit to see if that really is the case. -->
              <when test="$actual-result instance of node()+">
                <document>
                  <copy-of select="$actual-result" />
                </document>
              </when>
              <otherwise>
                <sequence select="$actual-result" />
              </otherwise>
            </choose>
          </variable>
          <variable name="test-result" as="item()*">
            <for-each select="$test-items">
              <sequence select="{@test}" version="{$version}" />
            </for-each>
          </variable>
          <variable name="boolean-test" as="xs:boolean"
            select="$test-result instance of xs:boolean" />
          <variable name="successful" as="xs:boolean"
            select="if ($boolean-test) then $test-result
                    else test:deep-equal($expected-result, $test-result, {$version})" />
        </xsl:when>
        <xsl:otherwise>
          <variable name="successful" as="xs:boolean" 
            select="test:deep-equal($expected-result, $actual-result, {$version})" />
        </xsl:otherwise>
      </xsl:choose>
      <if test="not($successful)">
        <message>
          <xsl:text>      FAILED</xsl:text>
        </message>
      </if>
    </xsl:if>
    <s:test>
      <xsl:attribute name="label" select="replace(@label, '\{', '{{')" />
      <xsl:choose>
        <xsl:when test="exists($pending)">
          <xsl:attribute name="pending" select="$pending" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="successful" select="'{$successful}'" />
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="@test and empty($pending)">
        <if test="not($boolean-test)">
          <call-template name="test:report-value">
            <with-param name="value" select="$test-result" />
            <with-param name="wrapper-name" select="'s:result'" />
            <with-param name="wrapper-ns" select="'http://www.jenitennison.com/xslt/xspec'" />
          </call-template>
        </if>
      </xsl:if>
      <!--
      <s:expect>
        <xsl:for-each select="@* except @label">
          <xsl:attribute name="{name()}" namespace="{namespace-uri()}"
            select="replace(., '\{', '{{')" />
        </xsl:for-each>
        <xsl:apply-templates select="node()" mode="test:create-xslt-generator" />
        <xsl:apply-templates select="node()" mode="test:create-xslt-generator" />
      </s:expect>
      -->
    	<xsl:if test="empty($pending)">
    		<call-template name="test:report-value">
    			<with-param name="value" select="$expected-result" />
    			<with-param name="wrapper-name" select="'s:expect'" />
    			<with-param name="wrapper-ns" select="'http://www.jenitennison.com/xslt/xspec'" />
    		</call-template>
    	</xsl:if>
    </s:test>
  </template>
</xsl:template>

<xsl:template match="*" mode="s:generate-templates" />

<!-- *** s:generate-declarations *** -->
<!-- Code to generate parameter declarations -->
<xsl:template match="s:param" mode="s:generate-declarations">
  <xsl:apply-templates select="." mode="test:generate-variable-declarations">
    <xsl:with-param name="var" select="@name" />
    <xsl:with-param name="type" select="'param'" />
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="s:space" mode="test:create-xslt-generator">
  <text><xsl:value-of select="." /></text>
</xsl:template>  
  

<!-- *** s:generate-tests *** -->
<!-- Helper code for the tests -->

<xsl:template match="s:context" mode="s:generate-tests">
	<xsl:variable name="context" as="element(s:context)">
		<s:context>
			<xsl:sequence select="@*" />
			<xsl:sequence select="node() except s:param" />
		</s:context>
	</xsl:variable>
  <xsl:apply-templates select="$context" mode="test:generate-variable-declarations">
    <xsl:with-param name="var" select="'context'" />
  </xsl:apply-templates>
</xsl:template>  

<xsl:template match="s:param" mode="s:generate-tests">
  <xsl:apply-templates select="." mode="test:generate-variable-declarations">
    <xsl:with-param name="var" select="if (@name) then @name else generate-id()" />
  </xsl:apply-templates>
</xsl:template>  

<xsl:template match="s:context | s:param" mode="s:report">
  <xsl:element name="s:{local-name()}">
    <xsl:copy-of select="@*" />
    <xsl:apply-templates mode="test:create-xslt-generator" />
  </xsl:element>
</xsl:template>
  
<xsl:template match="s:call" mode="s:report">
  <s:call>
    <xsl:copy-of select="@*" />
    <xsl:apply-templates mode="s:report" />
  </s:call>
</xsl:template>
  
</xsl:stylesheet>
