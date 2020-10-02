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
              <xsl:value-of select="marc:datafield[@tag='040']/marc:subfield[@code='a']"/><xsl:value-of select="marc:controlfield[@tag='005']"/>
            </xsl:element>
<!--            <controlfield tag="001"><xsl:value-of select="marc:datafield[@tag='024']/marc:subfield[@code='a']"/></controlfield> -->
            <xsl:if test="not(marc:controlfield/@tag='003')">
              <xsl:element name="controlfield" namespace="http://www.loc.gov/MARC21/slim">
                <xsl:attribute name="tag">003</xsl:attribute>
                <xsl:text>MiU</xsl:text>
              </xsl:element>
            </xsl:if>
          </xsl:if>
          <xsl:apply-templates select="node()[not(name()='leader')]"/>
        </xsl:copy>
    </xsl:template>



    <xsl:template match="marc:controlfield[@tag='005']">
      <xsl:element name="controlfield" namespace="http://www.loc.gov/MARC21/slim">
        <xsl:attribute name="tag">003</xsl:attribute>
        <xsl:text>MiU</xsl:text>
      </xsl:element>
      <xsl:text>&#xa;</xsl:text>
      <xsl:text>&#09;</xsl:text>
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="node()"/>
      </xsl:copy>
    </xsl:template>

    <!-- print ISBNs must be in $z. Assume print if not specified. -->
    <xsl:template match="marc:datafield[@tag='020']/marc:subfield/@code[.='a']">
      <xsl:choose>
        <xsl:when test="not(../../marc:subfield[@code='q'])">
          <xsl:attribute name="code">z</xsl:attribute>
        </xsl:when>
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
        <xsl:when test="contains(../../marc:subfield[@code='q'], 'cloth') or contains(..,'cloth')">
          <xsl:attribute name="code">z</xsl:attribute>
        </xsl:when>
        <xsl:when test=".='9780472117826' or .='9780472119448' or .='9780472072538' or .='0472072536' or .='9780472052530' or .='0472052535'">
          <xsl:attribute name="code">z</xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="code">a</xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:template>

    <xsl:template match="marc:datafield[@tag='020']/marc:subfield/@code[.='z']">
      <xsl:choose>
        <xsl:when test="contains(../../marc:subfield[@code='q'], 'eBook') or contains(..,'eBook')">
          <xsl:attribute name="code">a</xsl:attribute>
        </xsl:when>
        <xsl:when test="contains(../../marc:subfield[@code='q'], 'ebook') or contains(..,'ebook')">
          <xsl:attribute name="code">a</xsl:attribute>
        </xsl:when>
        <xsl:when test="contains(../../marc:subfield[@code='q'], 'e-book') or contains(..,'e-book')">
          <xsl:attribute name="code">a</xsl:attribute>
        </xsl:when>
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
