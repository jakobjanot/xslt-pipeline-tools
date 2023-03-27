<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="3.1">

    <xsl:template name="batch-transform" visibility="public">
        <xsl:param name="inputs-base-dir-uri" as="xs:anyURI" required="yes"/>
        <xsl:param name="outputs-base-dir-uri" as="xs:anyURI" required="yes"/>
        <xsl:param name="stylesheet-uris" as="xs:anyURI*" required="yes"/>
        <xsl:param name="debug-base-dir-uri" as="xs:anyURI" required="yes"/>
        <xsl:param name="verbose" as="xs:boolean?"/>
        <xsl:param name="debug" as="xs:boolean?"/>
        <xsl:variable name="input-uris" as="xs:anyURI*" select="uri-collection($inputs-base-dir-uri || '?select=*.xml;recurse=yes')"/>
        <xsl:message expand-text="yes">Transforming {count($input-uris)} files with a cascade of {count($stylesheet-uris)} stylesheets...</xsl:message>
        <xsl:for-each select="$input-uris">
            <xsl:variable name="input-uri" as="xs:anyURI" select="."/>
            <xsl:variable name="output-uri" as="xs:anyURI" select="xs:anyURI(concat(string($outputs-base-dir-uri), substring-after(string($input-uri), string($inputs-base-dir-uri))))"/>
            <xsl:choose>
                <xsl:when test="doc-available($output-uri)">
                    <xsl:message expand-text="yes">{position()} Skipping {$input-uri} → {$output-uri}. Output file already exists.</xsl:message>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message expand-text="yes">{position()} Transforming {$input-uri} → {$output-uri}</xsl:message>
                    <xsl:call-template name="cascade-transform-uri">
                        <xsl:with-param name="input-uri" select="$input-uri"/>
                        <xsl:with-param name="output-uri" select="$output-uri"/>
                        <xsl:with-param name="stylesheet-uris" select="$stylesheet-uris"/>
                        <xsl:with-param name="debug-dir-uri" select="xs:anyURI(replace(concat(string($debug-base-dir-uri), substring-after(string($input-uri), string($inputs-base-dir-uri))), '.xml', '/'))"/>
                        <xsl:with-param name="verbose" select="$verbose"/>
                        <xsl:with-param name="debug" select="$debug"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
        <!--<xsl:sequence select="uri-collection($outputs-base-dir-uri || '?select=**/*.xml;recurse=yes')"/>-->
    </xsl:template>

    <xsl:template name="cascade-transform-uri" as="empty-sequence()" visibility="public">
        <xsl:param name="input-uri" as="xs:anyURI" required="yes"/>
        <xsl:param name="output-uri" as="xs:anyURI" required="yes"/>
        <xsl:param name="stylesheet-uris" as="xs:anyURI+" required="yes"/>
        <xsl:param name="debug-dir-uri" as="xs:anyURI" required="yes"/>
        <xsl:param name="verbose" as="xs:boolean?"/>
        <xsl:param name="debug" as="xs:boolean?"/>
        <xsl:result-document href="{$output-uri}">
            <xsl:call-template name="transform-next-step">
                <xsl:with-param name="input" select="doc($input-uri)"/>
                <xsl:with-param name="stylesheet-uris" select="$stylesheet-uris"/>
                <xsl:with-param name="step" select="1"/>
                <xsl:with-param name="debug-dir-uri" select="$debug-dir-uri"/>
                <xsl:with-param name="verbose" select="$verbose"/>
                <xsl:with-param name="debug" select="$debug"/>
            </xsl:call-template>
        </xsl:result-document>
    </xsl:template>

    <xsl:template name="parse-manifest" visibility="public">
        <xsl:param name="manifest" as="node()"/>
        <xsl:sequence select="$manifest//*/(@href|@stylesheet)/resolve-uri(., base-uri(.))"/>
    </xsl:template>

    <xsl:template name="parse-manifest-uri" visibility="public">
        <xsl:param name="manifest-uri" as="xs:anyURI"/>
        <xsl:call-template name="parse-manifest">
            <xsl:with-param name="manifest" select="doc($manifest-uri)"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="transform-next-step" as="document-node()" visibility="private">
        <xsl:param name="input" as="node()" required="yes"/>
        <xsl:param name="stylesheet-uris" as="xs:anyURI+" required="yes"/>
        <xsl:param name="step" as="xs:integer?" required="yes"/>
        <xsl:param name="debug-dir-uri" as="xs:anyURI" required="yes"/>
        <xsl:param name="verbose" as="xs:boolean?"/>
        <xsl:param name="debug" as="xs:boolean?"/>
        <xsl:variable name="current-stylesheet-number" as="xs:integer" select="if ($step) then $step else 1"/>
        <xsl:variable name="current-stylesheet-uri" as="xs:anyURI" select="$stylesheet-uris[1]"/>
        <xsl:variable name="remaining-stylesheet-uris" as="xs:anyURI*" select="$stylesheet-uris[position() gt 1]"/>
        <xsl:variable name="current-stylesheet-name" select="substring-before(tokenize($current-stylesheet-uri, '/')[last()], '.xsl')"/>
        <xsl:if test="$verbose = true()">
            <xsl:message expand-text="yes">{$current-stylesheet-number}. Stylesheet {$current-stylesheet-name} applied</xsl:message>
        </xsl:if>
        <xsl:variable name="output">
            <xsl:sequence select="
                transform(
                    map{
                    'source-node': $input,
                    'stylesheet-location': $current-stylesheet-uri,
                    'stylesheet-params': map{},
                    'enable-messages': true(),
                    'cache': true()
                })?output"/>
        </xsl:variable>
        <xsl:if test="$debug = true()">
            <xsl:variable name="current-debug-file-uri" select="resolve-uri(concat($step, '-', $current-stylesheet-name, '.xml'), $debug-dir-uri)" as="xs:anyURI"/>
            <xsl:result-document href="{$current-debug-file-uri}">
                <xsl:message expand-text="yes">Dumping {$current-debug-file-uri}</xsl:message>
                <xsl:value-of select="$output"/>
            </xsl:result-document>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="count($remaining-stylesheet-uris) = 0">
                <xsl:sequence select="$output"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="transform-next-step">
                    <xsl:with-param name="input" select="$output"/>
                    <xsl:with-param name="stylesheet-uris" select="$remaining-stylesheet-uris"/>
                    <xsl:with-param name="step" select="$step + 1"/>
                    <xsl:with-param name="debug-dir-uri" select="$debug-dir-uri"/>
                    <xsl:with-param name="verbose" select="$verbose"/>
                    <xsl:with-param name="debug" select="$debug"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>