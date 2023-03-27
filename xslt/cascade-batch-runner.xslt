<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:m="http://www.corbas.co.uk/ns/transforms/data"
    exclude-result-prefixes="m xs"
    version="3.1">

    <xsl:include href="xslt-cascade.xslt"/>

    <xsl:param name="inputs-base-dir-uri" required="yes" as="xs:anyURI"/>
    <xsl:param name="outputs-base-dir-uri" required="yes" as="xs:anyURI"/>
    <xsl:param name="debug-base-dir-uri" required="yes" as="xs:anyURI"/>
    <xsl:param name="verbose" as="xs:boolean" select="false()"/>
    <xsl:param name="debug" as="xs:boolean" select="false()"/>

    <xsl:template match="m:manifest">
        <xsl:variable name="stylesheet-uris" as="xs:anyURI*">
            <xsl:call-template name="parse-manifest">
                <xsl:with-param name="manifest" select="."/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:call-template name="batch-transform">
            <xsl:with-param name="inputs-base-dir-uri" select="$inputs-base-dir-uri"/>
            <xsl:with-param name="outputs-base-dir-uri" select="$outputs-base-dir-uri"/>
            <xsl:with-param name="stylesheet-uris" select="$stylesheet-uris"/>
            <xsl:with-param name="debug-base-dir-uri" select="$debug-base-dir-uri"/>
            <xsl:with-param name="verbose" select="$verbose"/>
            <xsl:with-param name="debug" select="$debug"/>
        </xsl:call-template>
    </xsl:template>
</xsl:stylesheet>