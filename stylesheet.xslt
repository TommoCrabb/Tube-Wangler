<?xml version="1.0"?>

<!-- If you want to edit this file, take special note of the stupid fuckin' "dir" and "xsl" appended to the front of every fuckin' word. 
It took me a full day of tinkering to work that out. Yes, it turns out, referencing XML namespaces in XSLT stylesheets is a giant fuckin' pain in the arse! -->

<xsl:stylesheet version="1.0"
	xmlns:yt="http://www.youtube.com/xml/schemas/2015" 
	xmlns:media="http://search.yahoo.com/mrss/" 
	xmlns:dir="http://www.w3.org/2005/Atom"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="text"/>
	<xsl:template match="/">
		<xsl:apply-templates select="/dir:feed/dir:entry"/>
	</xsl:template>
	<xsl:template match="dir:entry">
		<xsl:value-of select="dir:link/@href"/>
		<xsl:text> # </xsl:text>
		<xsl:value-of select="dir:published"/>
		<xsl:text>||</xsl:text>
		<xsl:value-of select="/dir:feed/dir:title"/>
		<xsl:text>||</xsl:text>
		<xsl:value-of select="dir:title"/>
		<xsl:text>&#10;</xsl:text>
	</xsl:template>
</xsl:stylesheet>
