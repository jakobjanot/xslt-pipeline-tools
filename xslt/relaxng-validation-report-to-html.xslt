<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:c="http://www.w3.org/ns/xproc-step">
    
    <xsl:output method="html" indent="yes"/>
    
    <xsl:template match="/">
        <html xmlns="http://www.w3.org/1999/xhtml">
            <head>
                <title>RELAX NG validation report</title>
                <style>
                    body {margin:8px;}
                </style>
            </head>
            <body>
                <h1>RELAX NG validation report</h1>
                <div>Errors: <xsl:value-of select="count(.//c:errors/c:error)"/></div>
                <xsl:for-each select=".//c:errors/c:error">
                    <ul>
                        <xsl:variable name="error-lines" select="tokenize(.,'; ')"/>

                        <xsl:for-each select="$error-lines">
                            <xsl:if test="not(starts-with(., 'systemId: ') or starts-with(., 'lineNumber:') or starts-with(., 'columnNumber:')) and . != 'org.xml.sax.SAXParseException'">
                                <li><xsl:value-of select="."/></li>
                            </xsl:if>
                        </xsl:for-each>
                    </ul>
                </xsl:for-each>
            </body>
        </html>
    </xsl:template>
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
