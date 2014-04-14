<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:ns2="http://www.w3.org/1999/xlink" xmlns:ead="urn:isbn:1-931666-22-9"
    exclude-result-prefixes="xs xsl xd ead ns2" version="2.0">

    <xsl:template name="combine-that-title-and-date">
        <li>
            <!--unittitle is context node-->
            <xsl:choose>
                <xsl:when test="ends-with(normalize-space(), '&quot;')">
                    <xsl:choose>
                        <xsl:when test="../ead:unitdate">
                            <xsl:apply-templates select="." mode="trailing-quote">
                                <xsl:with-param name="keep-existing-comma" select="false()"
                                    as="xs:boolean"/>
                            </xsl:apply-templates>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="." mode="trailing-quote"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when
                    test="*[last()][@render='doublequote' or @render='singlequote' or 
                    @render='bolddoublequote' or @render='boldsinglequote']">
                    <xsl:choose>
                        <xsl:when test="../ead:unitdate">
                            <xsl:apply-templates select=".">
                                <xsl:with-param name="add-comma" select="true()" as="xs:boolean"/>
                            </xsl:apply-templates>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="."/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
            <!--if there's no unittitle, then grab the title from the first ancestor that has a title-->
            <xsl:if test="not(normalize-space())">
                <xsl:apply-templates
                    select="ancestor::*[ead:did/ead:unittitle[normalize-space()]][1]/ead:did/ead:unittitle"/>
            </xsl:if>
            <!-- here, unitdates aren't required by the AT, so we need to test if one
                                exists before adding the first comma-->
            <xsl:if test="../ead:unitdate">
                <xsl:text>, </xsl:text>
            </xsl:if>
            <!--before representing the dates, they are grouped into three potential groups:
        1) single and inclusive dates that do not include the word "undated"
        2) any dates that include the word "undated"
        3) bulk dates (which cannot contain any free text date expressions, according to how the AT generates those)
    -->
            <xsl:apply-templates
                select="../ead:unitdate[not(contains(., 'undated'))][not(@type='bulk')]"
                mode="date-title-combine">
                <xsl:sort select="substring-before(@normal, '/')" data-type="number"/>
                <xsl:sort select="substring-after(@normal, '/')" data-type="number"/>
                <xsl:sort select="." data-type="text" order="ascending"/>
            </xsl:apply-templates>
            <xsl:if
                test="../ead:unitdate[preceding-sibling::ead:unitdate][(contains(., 'undated'))] or
                    ../ead:unitdate[following-sibling::ead:unitdate][(contains(., 'undated'))]">
                <xsl:text>, </xsl:text>
            </xsl:if>
            <xsl:apply-templates select="../ead:unitdate[(contains(., 'undated'))]"
                mode="date-title-combine">
                <xsl:sort select="substring-before(@normal, '/')" data-type="number"/>
                <xsl:sort select="substring-after(@normal, '/')" data-type="number"/>
                <xsl:sort select="." data-type="text" order="ascending"/>
            </xsl:apply-templates>
            <xsl:apply-templates select="../ead:unitdate[@type = 'bulk']" mode="date-title-combine">
                <xsl:sort select="substring-before(@normal, '/')" data-type="number"/>
                <xsl:sort select="substring-after(@normal, '/')" data-type="number"/>
                <xsl:sort select="." data-type="text" order="ascending"/>
            </xsl:apply-templates>
        </li>
    </xsl:template>

    <xsl:template match="ead:unitdate[not(@type='bulk')]" mode="date-title-combine">
        <xsl:apply-templates/>
        <xsl:if test="not(position() = last())">
            <xsl:text>, </xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:template match="ead:unitdate[@type='bulk']" mode="date-title-combine">
        <xsl:text> (</xsl:text>
        <xsl:apply-templates/>
        <xsl:if test="not(position() = last())">
            <xsl:text>, </xsl:text>
        </xsl:if>
        <xsl:text>)</xsl:text>
    </xsl:template>

    <xsl:template match="ead:unittitle/text()[last()]" mode="trailing-quote">
        <xsl:param name="keep-existing-comma" select="true()" as="xs:boolean"/>
        <xsl:choose>
            <xsl:when test="$keep-existing-comma eq false()">
                <xsl:value-of select="replace(., ',&quot;$', '&quot;')"/>
            </xsl:when>
            <xsl:when test="ends-with(., ',&quot;')">
                <xsl:value-of select="concat(., ' ')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="replace(., '&quot;$', ',&quot; ')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
