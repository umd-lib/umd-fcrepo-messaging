<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet [ <!ENTITY lf "&#x0a;"> ]>

<xsl:stylesheet
    xmlns:beans="http://www.springframework.org/schema/beans"
    xmlns:camel="http://camel.apache.org/schema/spring"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:puml="urn:uuid:00000000-0000-0000-000000000000#"
    version="2.0">
  <xsl:output method="text" indent="no"/>

  <xsl:template match="/">
    <xsl:text># Camel Route Context: </xsl:text><xsl:value-of select="//camel:routeContext/@id"/>
    <xsl:text>&lf;&lf;</xsl:text>
    <xsl:text>## Java Beans</xsl:text>
    <xsl:text>&lf;&lf;</xsl:text>
    <xsl:apply-templates select="beans:beans/beans:bean"/>
    <xsl:text>## Routes</xsl:text>
    <xsl:text>&lf;&lf;</xsl:text>
    <xsl:apply-templates select="beans:beans/camel:routeContext"/>
  </xsl:template>

  <xsl:template match="beans:bean">
    <xsl:text>### </xsl:text>
    <xsl:value-of select="@id"/>
    <xsl:text>&lf;&lf;</xsl:text>
    <xsl:text>#### Class</xsl:text>
    <xsl:text>&lf;&lf;</xsl:text>
    <xsl:text>* `</xsl:text><xsl:value-of select="@class"/><xsl:text>`</xsl:text>
    <xsl:text>&lf;&lf;</xsl:text>
    <xsl:if test="beans:property">
      <xsl:text>#### Properties</xsl:text>
      <xsl:text>&lf;&lf;</xsl:text>
      <xsl:for-each select="beans:property">
        <xsl:value-of select="concat('* `', @name, '`&lf;')"/>
        <xsl:if test="@value">
          <xsl:value-of select="concat(' = `', @value, '`')"/>
        </xsl:if>
        <xsl:text>&lf;</xsl:text>
      </xsl:for-each>
      <xsl:text>&lf;</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="camel:routeContext">
    <xsl:for-each select="camel:route">
      <xsl:text>* [</xsl:text>
      <xsl:value-of select="@id"/>
      <xsl:text>](#</xsl:text>
      <xsl:value-of select="translate(@id, '.', '-')"/>
      <xsl:text>)&lf;</xsl:text>
    </xsl:for-each>
    <xsl:text>&lf;</xsl:text>
    <xsl:apply-templates select="camel:route"/>
  </xsl:template>

  <xsl:function name="puml:extract-vars">
    <xsl:param name="items"/>
    <xsl:for-each select="$items">
      <xsl:for-each select="tokenize(., '\$\{|\}')">
        <xsl:if test="position() mod 2 = 0">
          <xsl:value-of select="."/>
        </xsl:if>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:function>

  <xsl:template match="camel:route">
    <xsl:text>### </xsl:text><xsl:value-of select="@id"/><xsl:text>&lf;</xsl:text>
    <xsl:text>&lf;</xsl:text>
    <xsl:value-of select="normalize-space(@description)"/><xsl:text>&lf;</xsl:text>
    <xsl:text>&lf;</xsl:text>
    <xsl:text>#### Source Endpoint&lf;&lf;</xsl:text>
    <xsl:text>* `</xsl:text><xsl:value-of select="camel:from/@uri"/><xsl:text>`&lf;</xsl:text>
    <xsl:text>&lf;</xsl:text>

    <xsl:if test=".//camel:to or .//camel:recipientList">
      <xsl:text>#### Destination Endpoints&lf;&lf;</xsl:text>
      <xsl:for-each select="distinct-values(.//camel:to/@uri)">
        <xsl:text>* `</xsl:text><xsl:value-of select="."/><xsl:text>`&lf;</xsl:text>
      </xsl:for-each>
      <xsl:for-each select="distinct-values(.//camel:recipientList/camel:header)">
        <xsl:text>* Recipient list from header `</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>`&lf;</xsl:text>
      </xsl:for-each>
      <xsl:text>&lf;</xsl:text>
    </xsl:if>

    <xsl:if test=".//camel:simple[contains(., 'sysenv.')]">
      <xsl:text>#### Required Environment Variables&lf;&lf;</xsl:text>
      <xsl:for-each select="distinct-values(puml:extract-vars(.//camel:simple))[starts-with(., 'sysenv.')]">
        <xsl:text>* `</xsl:text>
        <xsl:value-of select="tokenize(., '\.')[2]"/>
        <xsl:text>`&lf;</xsl:text>
      </xsl:for-each>
      <xsl:text>&lf;</xsl:text>
    </xsl:if>

    <xsl:if test=".//camel:simple[contains(., 'header.') or contains(., 'headers.')]">
      <xsl:text>#### Required Headers&lf;&lf;</xsl:text>
      <xsl:for-each select="distinct-values(puml:extract-vars(.//camel:simple))[starts-with(., 'header.') or starts-with(., 'headers.')]">
        <xsl:text>* `</xsl:text>
        <xsl:value-of select="tokenize(., '\.')[2]"/>
        <xsl:text>`&lf;</xsl:text>
      </xsl:for-each>
      <xsl:for-each select="distinct-values(.//camel:recipientList/camel:header)">
        <xsl:text>* `</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>`&lf;</xsl:text>
      </xsl:for-each>
      <xsl:text>&lf;</xsl:text>
    </xsl:if>

    <xsl:if test=".//camel:simple[contains(., 'exchangeProperty.')]">
      <xsl:text>#### Required Exchange Properties&lf;&lf;</xsl:text>
      <xsl:for-each select="distinct-values(puml:extract-vars(.//camel:simple))[starts-with(., 'exchangeProperty.')]">
        <xsl:text>* `</xsl:text>
        <xsl:value-of select="tokenize(., '\.')[2]"/>
        <xsl:text>`&lf;</xsl:text>
      </xsl:for-each>
      <xsl:text>&lf;</xsl:text>
    </xsl:if>

    <xsl:text>```plantuml&lf;</xsl:text>

    <xsl:call-template name="puml:endpoint">
      <xsl:with-param name="uri" select="camel:from/@uri"/>
    </xsl:call-template>

    <xsl:call-template name="puml:control">
      <xsl:with-param name="id" select="@id"/>
    </xsl:call-template>

    <xsl:for-each select=".//camel:process">
      <xsl:call-template name="puml:entity">
        <xsl:with-param name="id" select="@ref"/>
      </xsl:call-template>
    </xsl:for-each>

    <xsl:for-each select=".//camel:to[@uri]">
      <xsl:call-template name="puml:endpoint">
        <xsl:with-param name="uri" select="@uri"/>
      </xsl:call-template>
    </xsl:for-each>

    <xsl:apply-templates select="camel:from|camel:to|camel:choice|camel:multicast|camel:setHeader|camel:setBody|camel:removeHeaders|camel:process|camel:stop|camel:recipientList|camel:filter"/>

    <xsl:text>```&lf;</xsl:text>
    <xsl:text>&lf;</xsl:text>
  </xsl:template>

  <xsl:template name="puml:endpoint">
    <xsl:param name="uri"/>
    <xsl:variable name="baseUri" select="substring-before($uri, '?')"/>
    <xsl:variable name="queryString" select="substring-after($uri, '?')"/>
    <xsl:choose>
      <xsl:when test="starts-with($uri, 'activemq:')">
        <xsl:text>queue</xsl:text>
      </xsl:when>
      <xsl:when test="starts-with($uri, 'fcrepomq:')">
        <xsl:text>queue</xsl:text>
      </xsl:when>
      <xsl:when test="starts-with($uri, 'jdbc:')">
        <xsl:text>database</xsl:text>
      </xsl:when>
      <xsl:when test="starts-with($uri, 'file:')">
        <xsl:text>collections</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>boundary</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text> "</xsl:text>
    <xsl:choose>
      <xsl:when test="$baseUri != ''">
        <xsl:value-of select="$baseUri"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$uri"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>" &lt;&lt;endpoint>>&lf;</xsl:text>
  </xsl:template>

  <xsl:template name="puml:control">
    <xsl:param name="id"/>
    <xsl:text>control "</xsl:text>
    <xsl:value-of select="$id"/>
    <xsl:text>" &lt;&lt;route>>&lf;</xsl:text>
  </xsl:template>

  <xsl:template name="puml:entity">
    <xsl:param name="id"/>
    <xsl:text>entity "</xsl:text>
    <xsl:value-of select="$id"/>
    <xsl:text>" &lt;&lt;processor>>&lf;</xsl:text>
  </xsl:template>

  <xsl:template name="match-var">
    <xsl:param name="prefix"/>
    <xsl:param name="string"/>
    <xsl:param name="seen" select="''"/>
    <xsl:variable name="value" select="substring-before(substring-after($string, $prefix), '}')"/>
    <xsl:if test="not(contains($seen, $value))">
      <xsl:text>* `</xsl:text>
      <xsl:value-of select="$value"/>
      <xsl:text>`&lf;</xsl:text>
    </xsl:if>
    <xsl:variable name="rest" select="substring-after(substring-after($string, $prefix), '}')"/>
    <xsl:if test="contains($rest, $prefix)">
      <xsl:call-template name="match-var">
        <xsl:with-param name="prefix" select="$prefix"/>
        <xsl:with-param name="string" select="$rest"/>
        <xsl:with-param name="seen" select="concat($seen, ' ', $value)"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template match="camel:from">
    <xsl:variable name="baseUri" select="substring-before(@uri, '?')"/>
    <xsl:variable name="queryString" select="substring-after(@uri, '?')"/>
    <xsl:choose>
      <xsl:when test="$baseUri != ''">
        <xsl:call-template name="puml:message">
          <xsl:with-param name="from" select="$baseUri"/>
          <xsl:with-param name="to" select="../@id"/>
          <xsl:with-param name="label" select="$queryString"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="puml:message">
          <xsl:with-param name="from" select="@uri"/>
          <xsl:with-param name="to" select="../@id"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="camel:choice">
    <xsl:apply-templates select="camel:when|camel:otherwise"/>
    <xsl:text>end&lf;</xsl:text>
  </xsl:template>

  <xsl:template match="camel:when">
    <xsl:choose>
      <xsl:when test="preceding-sibling::camel:when">
        <xsl:text>else</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>alt</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="@description"><xsl:value-of select="@description"/></xsl:when>
      <xsl:otherwise><xsl:apply-templates select="camel:simple|camel:header"/></xsl:otherwise>
    </xsl:choose>
    <xsl:text>&lf;</xsl:text>
    <xsl:apply-templates select="camel:choice|camel:multicast|camel:filter|camel:to|camel:setHeader|camel:setProperty|camel:removeHeaders|camel:process|camel:stop|camel:recipientList"/>
  </xsl:template>

  <xsl:template match="camel:otherwise">
    <xsl:text>else otherwise&lf;</xsl:text>
    <xsl:apply-templates select="camel:choice|camel:multicast|camel:filter|camel:to|camel:setHeader|camel:setProperty|camel:removeHeaders|camel:process|camel:stop|camel:recipientList"/>
  </xsl:template>

  <xsl:template match="camel:filter">
    <xsl:if test="@note">
      <xsl:text>note over </xsl:text>
      <xsl:value-of select="puml:quote(ancestor::camel:route/@id)"/>
      <xsl:text>&lf;</xsl:text>
      <xsl:call-template name="puml:multiline-text">
        <xsl:with-param name="words" select="tokenize(normalize-space(@note))"/>
        <xsl:with-param name="current-length">0</xsl:with-param>
        <xsl:with-param name="max-length">60</xsl:with-param>
      </xsl:call-template>
      <xsl:text>&lf;</xsl:text>
      <xsl:text>endnote&lf;</xsl:text>
    </xsl:if>
    <xsl:text>opt </xsl:text>
    <xsl:choose>
      <xsl:when test="@description"><xsl:value-of select="@description"/></xsl:when>
      <xsl:otherwise><xsl:apply-templates select="camel:simple|camel:header"/></xsl:otherwise>
    </xsl:choose>
    <xsl:text>&lf;</xsl:text>
    <xsl:apply-templates select="camel:pipeline|camel:multicast|camel:filter|camel:to|camel:setHeader|camel:setProperty|camel:setBody|camel:removeHeaders|camel:process|camel:stop"/>
    <xsl:text>end&lf;</xsl:text>
  </xsl:template>

  <xsl:template match="camel:pipeline">
    <xsl:text>group pipeline&lf;</xsl:text>
    <xsl:apply-templates select="*"/>
    <xsl:text>end&lf;</xsl:text>
  </xsl:template>

  <xsl:template match="camel:multicast">
    <xsl:text>group multicast</xsl:text>
    <xsl:if test="@parallelProcessing = 'true'">
      <xsl:text> parallel</xsl:text>
    </xsl:if>
    <xsl:text>&lf;</xsl:text>
    <xsl:apply-templates select="camel:to|camel:filter|camel:pipeline"/>
    <xsl:text>end&lf;</xsl:text>
  </xsl:template>

  <xsl:template match="camel:to">
    <xsl:choose>
      <xsl:when test="starts-with(@uri, 'http:')">
        <!-- synchronous -->
        <xsl:call-template name="puml:message">
          <xsl:with-param name="from" select="ancestor::camel:route/@id"/>
          <xsl:with-param name="to" select="@uri"/>
        </xsl:call-template>
        <xsl:call-template name="puml:message">
          <xsl:with-param name="from" select="@uri"/>
          <xsl:with-param name="to" select="ancestor::camel:route/@id"/>
          <xsl:with-param name="link">--></xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="starts-with(@uri, 'activemq:')">
        <!-- asynchronous -->
        <xsl:call-template name="puml:message">
          <xsl:with-param name="from" select="ancestor::camel:route/@id"/>
          <xsl:with-param name="to" select="@uri"/>
          <xsl:with-param name="link">->></xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="puml:message">
          <xsl:with-param name="from" select="ancestor::camel:route/@id"/>
          <xsl:with-param name="to" select="@uri"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="camel:setBody">
    <xsl:call-template name="puml:message">
      <xsl:with-param name="from" select="ancestor::camel:route/@id"/>
      <xsl:with-param name="to" select="ancestor::camel:route/@id"/>
      <xsl:with-param name="label">
        <xsl:text> Set body = </xsl:text><xsl:apply-templates select="camel:simple|camel:constant"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="camel:setHeader">
    <xsl:call-template name="puml:message">
      <xsl:with-param name="from" select="ancestor::camel:route/@id"/>
      <xsl:with-param name="to" select="ancestor::camel:route/@id"/>
      <xsl:with-param name="label">
        <xsl:text>Set header </xsl:text>
        <xsl:value-of select="@name"/>
        <xsl:choose>
          <xsl:when test="camel:header">
            <xsl:text> to </xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text> = </xsl:text>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="camel:simple|camel:constant|camel:header|camel:groovy"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="camel:setProperty">
    <xsl:call-template name="puml:message">
      <xsl:with-param name="from" select="ancestor::camel:route/@id"/>
      <xsl:with-param name="to" select="ancestor::camel:route/@id"/>
      <xsl:with-param name="label">
        <xsl:text>Set property </xsl:text>
        <xsl:value-of select="@name"/>
        <xsl:choose>
          <xsl:when test="camel:header">
            <xsl:text> to </xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text> = </xsl:text>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="camel:simple|camel:constant|camel:header|camel:groovy"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="camel:removeHeaders">
    <xsl:call-template name="puml:message">
      <xsl:with-param name="from" select="ancestor::camel:route/@id"/>
      <xsl:with-param name="to" select="ancestor::camel:route/@id"/>
      <xsl:with-param name="label">
        <xsl:choose>
          <xsl:when test="@pattern = '*'">
            <xsl:text>Remove all headers</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>Remove headers matching </xsl:text><xsl:value-of select="@pattern"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="@excludePattern">
          <xsl:text> except </xsl:text><xsl:value-of select="@excludePattern"/>
        </xsl:if>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="camel:simple">
    <xsl:value-of select="substring(normalize-space(.), 0, 100)"/>
    <xsl:if test="string-length(normalize-space(.)) > 100">...</xsl:if>
  </xsl:template>

  <xsl:template match="camel:constant">
    <xsl:text>"</xsl:text>
    <xsl:value-of select="substring(normalize-space(.), 0, 100)"/>
    <xsl:if test="string-length(normalize-space(.)) > 100">...</xsl:if>
    <xsl:text>"</xsl:text>
  </xsl:template>

  <xsl:template match="camel:header">
    <xsl:text>header </xsl:text>
    <xsl:value-of select="substring(normalize-space(.), 0, 100)"/>
    <xsl:if test="string-length(normalize-space(.)) > 100">...</xsl:if>
  </xsl:template>

  <xsl:template match="camel:groovy">
    <xsl:text>Groovy script [</xsl:text>
    <xsl:value-of select="substring(normalize-space(.), 0, 100)"/>
    <xsl:if test="string-length(normalize-space(.)) > 100">...</xsl:if>
    <xsl:text>]</xsl:text>
  </xsl:template>

  <xsl:template match="camel:process">
    <xsl:call-template name="puml:execution">
      <xsl:with-param name="from" select="ancestor::camel:route/@id"/>
      <xsl:with-param name="to" select="@ref"/>
      <xsl:with-param name="returns">
        <xsl:if test="starts-with(@description, 'returns: ')">
          <xsl:value-of select="substring-after(@description, 'returns: ')"/>
        </xsl:if>
      </xsl:with-param>
      <xsl:with-param name="process">
        <xsl:if test="@description and not(starts-with(@description, 'returns: '))">
          <xsl:value-of select="@description"/>
        </xsl:if>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="camel:stop">
    <xsl:value-of select="puml:quote(ancestor::camel:route/@id)"/>
    <xsl:text> -x </xsl:text>
    <xsl:value-of select="puml:quote(ancestor::camel:route/@id)"/>
    <xsl:text> : STOP&lf;</xsl:text>
  </xsl:template>

  <xsl:template match="camel:recipientList">
    <xsl:text>boundary "{</xsl:text>
    <xsl:apply-templates select="camel:header|camel:simple|camel:constant"/>
    <xsl:text>}" &lt;&lt;dynamic endpoint>>&lf;</xsl:text>
    <xsl:call-template name="puml:message">
      <xsl:with-param name="from" select="ancestor::camel:route/@id"/>
      <xsl:with-param name="to">
        <xsl:text>{</xsl:text>
        <xsl:apply-templates select="camel:header|camel:simple|camel:constant"/>
        <xsl:text>}</xsl:text>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:function name="puml:quote">
    <xsl:param name="value"/>
    <xsl:text>"</xsl:text>
    <xsl:value-of select="$value"/>
    <xsl:text>"</xsl:text>
  </xsl:function>

  <xsl:template name="puml:message">
    <xsl:param name="from"/>
    <xsl:param name="to"/>
    <xsl:param name="link" select="'->'"/>
    <xsl:param name="label" select="''"/>
    <xsl:value-of select="puml:quote($from)"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="$link"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="puml:quote($to)"/>
    <xsl:if test="$label">
      <xsl:text> : </xsl:text>
      <xsl:value-of select="$label"/>
    </xsl:if>
    <xsl:text>&lf;</xsl:text>
  </xsl:template>

  <xsl:template name="puml:execution">
    <xsl:param name="from"/>
    <xsl:param name="to"/>
    <xsl:param name="label" select="''"/>
    <xsl:param name="returns" select="''"/>
    <xsl:param name="process" select="''"/>
    <xsl:value-of select="puml:quote($from)"/>
    <xsl:text> -> </xsl:text>
    <xsl:value-of select="puml:quote($to)"/>
    <xsl:if test="$label != ''">
      <xsl:text> : </xsl:text>
      <xsl:value-of select="$label"/>
    </xsl:if>
    <xsl:text>&lf;</xsl:text>
    <xsl:if test="$process != ''">
      <xsl:text>rnote over </xsl:text>
      <xsl:value-of select="puml:quote($to)"/>
      <xsl:text>&lf;</xsl:text>
      <xsl:value-of select="replace($process, '&lf; +', '&lf;')"/>
      <xsl:text>&lf;</xsl:text>
      <xsl:text>endrnote&lf;</xsl:text>
    </xsl:if>
    <xsl:text>&lf;</xsl:text>
    <xsl:value-of select="puml:quote($to)"/>
    <xsl:text> --> </xsl:text>
    <xsl:value-of select="puml:quote($from)"/>
    <xsl:if test="$returns">
      <xsl:text> : </xsl:text>
      <xsl:value-of select="$returns"/>
    </xsl:if>
    <xsl:text>&lf;</xsl:text>
  </xsl:template>

  <xsl:template name="puml:multiline-text">
    <xsl:param name="words"/>
    <xsl:param name="current-length"/>
    <xsl:param name="max-length"/>
    <xsl:if test="not(empty($words))">
      <xsl:choose>
        <xsl:when test="$current-length >= $max-length">
          <xsl:text>&lf;</xsl:text>
          <xsl:value-of select="$words[1]"/>
          <xsl:text> </xsl:text>
          <xsl:call-template name="puml:multiline-text">
            <xsl:with-param name="words" select="subsequence($words, 2)"/>
            <xsl:with-param name="current-length" select="string-length($words[1])"/>
            <xsl:with-param name="max-length" select="$max-length"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$words[1]"/>
          <xsl:text> </xsl:text>
          <xsl:call-template name="puml:multiline-text">
            <xsl:with-param name="words" select="subsequence($words, 2)"/>
            <xsl:with-param name="current-length" select="$current-length + 1 + string-length($words[1])"/>
            <xsl:with-param name="max-length" select="$max-length"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
