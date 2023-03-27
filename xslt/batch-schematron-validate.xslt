<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:sch="http://purl.oclc.org/dsdl/schematron"
    exclude-result-prefixes="xs"
    version="3.1">

    <xsl:param name="sources-base-dir-uri" required="yes" as="xs:anyURI"/>
    <xsl:param name="reports-base-dir-uri" required="yes" as="xs:anyURI"/>
    
    <xsl:template match="sch:schema">
        <xsl:variable name="compiled-schematron-stylesheet">
            <xsl:sequence select="
                transform(
                    map{
                        'source-node': .,
                        'stylesheet-location': '../lib/schxslt/xslt/2.0/pipeline-for-svrl.xsl',
                        'stylesheet-params': map{},
                        'enable-messages': true(),
                        'cache': true()
                    })?output"/>
        </xsl:variable>
        
        <xsl:variable name="source-uris" as="xs:anyURI*" select="uri-collection($sources-base-dir-uri || '?select=*.xml;recurse=yes')"/>
        <xsl:message expand-text="yes">Running Schematron validation of {count($source-uris)} files ...</xsl:message>
        
        <xsl:for-each select="$source-uris">
            <xsl:variable name="source-uri" as="xs:anyURI" select="."/>
            <xsl:variable name="svrl-report-uri" as="xs:anyURI" select="xs:anyURI(concat(string($reports-base-dir-uri), substring-after(string($source-uri), string($sources-base-dir-uri))))"/>
            <xsl:variable name="html-report-uri" as="xs:anyURI" select="xs:anyURI(replace(string($svrl-report-uri), '.xml', '.html'))"/>
            <xsl:message expand-text="yes">{position()} Validating {$source-uri}</xsl:message>
            <xsl:message expand-text="yes">→ SVRL report: {$svrl-report-uri}</xsl:message>
            <xsl:message expand-text="yes">→ HTML report: {$html-report-uri}</xsl:message>
            <xsl:variable name="svrl-report">
                <xsl:sequence select="
                    transform(
                        map{
                            'source-location': $source-uri,
                            'stylesheet-node': $compiled-schematron-stylesheet,
                            'stylesheet-params': map{},
                            'enable-messages': true(),
                            'cache': true()
                        })?output"/>"/>
            </xsl:variable>
            <xsl:result-document href="{$svrl-report-uri}" indent="yes">
                <xsl:value-of select="$svrl-report"/>
            </xsl:result-document>
            <xsl:result-document href="{$html-report-uri}">
                <xsl:sequence select="
                    transform(
                        map{
                            'source-node': $svrl-report,
                            'stylesheet-location': 'svrl-to-html.xslt',
                            'stylesheet-params': map{},
                            'enable-messages': true(),
                            'cache': true()
                        })?output"/>
            </xsl:result-document>
        </xsl:for-each>
        <!--<xsl:sequence select="uri-collection($reports-base-dir-uri || '?select=**/*.xml;recurse=yes')"/>-->
    </xsl:template>
</xsl:stylesheet>