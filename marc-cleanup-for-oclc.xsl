<xsl:stylesheet version="1.0"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:marc="http://www.loc.gov/MARC21/slim"
 exclude-result-prefixes="marc">
    <!-- classic XSL Identity Transform: https://en.wikipedia.org/wiki/Identity_transform -->
    <xsl:template match="node()|@*">
      <xsl:copy>
         <xsl:apply-templates select="node()|@*"/>
      </xsl:copy>
    </xsl:template>

    <xsl:template match="marc:record">
        <xsl:copy>
          <xsl:apply-templates select="@*"/>
          <xsl:apply-templates select="node()[name()='leader']"/>
          <xsl:if test="not(marc:controlfield/@tag='001')">
            <xsl:element name="controlfield" namespace="http://www.loc.gov/MARC21/slim">
              <xsl:attribute name="tag">001</xsl:attribute>
              <xsl:value-of select="marc:datafield[@tag='024']/marc:subfield[@code='a']"/>
            </xsl:element>
<!--            <controlfield tag="001"><xsl:value-of select="marc:datafield[@tag='024']/marc:subfield[@code='a']"/></controlfield> -->
          </xsl:if>
          <xsl:apply-templates select="node()[not(name()='leader')]"/>
        </xsl:copy>
    </xsl:template>

    <!-- replace OCN with something unique we can legally use. Let's use the DOI. -->
    <xsl:template match="marc:controlfield[@tag='001']">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:value-of select="../marc:datafield[@tag='024']/marc:subfield[@code='a'][contains(., '10.3998')]"/>
      </xsl:copy>
    </xsl:template>


    <xsl:template match="marc:datafield[@tag='020']/marc:subfield/@code[.='a']">
      <xsl:choose>
        <xsl:when test="contains(../../marc:subfield[@code='q'], 'print') or contains(..,'print')">
          <xsl:attribute name="code">z</xsl:attribute>
        </xsl:when>
        <xsl:when test="contains(../../marc:subfield[@code='q'], 'cover') or contains(..,'cover')">
          <xsl:attribute name="code">z</xsl:attribute>
        </xsl:when>
        <xsl:when test="contains(../../marc:subfield[@code='q'], 'paper') or contains(..,'paper')">
          <xsl:attribute name="code">z</xsl:attribute>
        </xsl:when>
        <xsl:when test="contains(../../marc:subfield[@code='q'], 'pbk') or contains(..,'pbk')">
          <xsl:attribute name="code">z</xsl:attribute>
        </xsl:when>
        <xsl:when test="contains(../../marc:subfield[@code='q'], 'hard') or contains(..,'hard')">
          <xsl:attribute name="code">z</xsl:attribute>
        </xsl:when>
        <xsl:when test="'9780472117826' or '9780472119448' or '9780472072538' or '0472072536' or '9780472052530' or '0472052535'">
          <xsl:attribute name="code">z</xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="code">a</xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:template>


    <xsl:template match="marc:datafield[@tag='020']/marc:subfield/@code[.='z']">
      <xsl:choose>
        <xsl:when test="contains(../../marc:subfield[@code='q'], 'electronic') or contains(..,'electronic')">
          <xsl:attribute name="code">a</xsl:attribute>
        </xsl:when>
        <xsl:when test="contains(../../marc:subfield[@code='q'], 'open access') or contains(..,'open access')">
          <xsl:attribute name="code">a</xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="code">z</xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
