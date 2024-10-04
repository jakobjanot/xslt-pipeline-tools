<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:m="http://ns.karnovgroup.com/pipeline"
    exclude-result-prefixes="xs m"
    version="3.1">

    <xsl:include href="xslt-cascade.xslt"/>

    <xsl:param name="inputs-base-dir-uri" as="xs:anyURI" select="resolve-uri('inputs', base-uri())"/>
    <xsl:param name="outputs-base-dir-uri" as="xs:anyURI" select="resolve-uri('outputs', base-uri())"/>
    <xsl:param name="debug-base-dir-uri" as="xs:anyURI" select="resolve-uri('debug', base-uri())"/>
    <xsl:param name="verbose" as="xs:boolean" select="false()"/>
    <xsl:param name="debug" as="xs:boolean" select="true()"/>

    <xsl:template match="/">
        <xsl:variable name="stylesheet-uris" as="xs:anyURI*">
            <xsl:call-template name="parse-manifest">
                <xsl:with-param name="manifest-uri" select="base-uri()"/>
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

        <results>
            <xsl:if test="$debug">
                <debug>
                    <xsl:sequence select="uri-collection($debug-base-dir-uri || '?select=**/*.xml;recurse=yes')"/>
                </debug>
            </xsl:if>
            <outputs>
                <xsl:sequence select="uri-collection($debug-base-dir-uri || '?select=**/*.xml;recurse=yes')"/>
            </outputs>
        </results>
    </xsl:template>
</xsl:stylesheet>