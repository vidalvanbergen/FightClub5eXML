<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  xmlns:str="http://exslt.org/strings"
  extension-element-prefixes="exsl str">

  <xsl:output method="xml" indent="yes" />


  <!-- Merge the compendiums together -->
  <xsl:template match="collection">
    <xsl:variable name="compendium" select="document(doc/@href)/compendium" />

    <compendium version="5" auto_indent="NO">
      <xsl:call-template name="classes-with-subclasses">
        <xsl:with-param name="compendium" select="$compendium"/>
      </xsl:call-template>

      <xsl:call-template name="spells-extendable">
        <xsl:with-param name="compendium" select="$compendium"/>
      </xsl:call-template>

      <xsl:copy-of select="$compendium/item" />
      <xsl:copy-of select="$compendium/race" />
      <xsl:copy-of select="$compendium/feat" />
      <xsl:copy-of select="$compendium/background" />
      <xsl:copy-of select="$compendium/monster" />
    </compendium>
  </xsl:template>


  <!-- Merges subclasses into classes -->
  <xsl:template name="classes-with-subclasses">
    <xsl:param name="compendium"/>
    <xsl:variable name="classes" select="$compendium/class" />

    <xsl:for-each select="$classes">
      <xsl:choose>
        <!-- Check if there's a duplicate -->
        <xsl:when test="count($classes[name = current()/name]) &gt; 1">
          <!-- Use the original class that includes the "hd" element -->
          <!-- Important: Subclasses should only contain "name" and "autolevel" elements -->
          <xsl:if test="hd">
            <class>
              <xsl:copy-of select="name | hd | proficiency | spellAbility | numSkills | armor | weapons | tools | wealth | slotsReset"/>

              <xsl:variable name="matching-classes" select="$classes[name = current()/name]"/>
              <xsl:copy-of select="$matching-classes/trait"/>
              <xsl:copy-of select="$matching-classes/autolevel"/>

            </class>
          </xsl:if>
        </xsl:when>
        <!-- If no duplicate, copy in the whole class -->
        <xsl:otherwise>
          <xsl:copy-of select="." />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>


  <!-- Merges spell classes -->
  <xsl:template name="spells-extendable">
    <xsl:param name="compendium"/>
    <xsl:variable name="spells" select="$compendium/spell" />

    <xsl:for-each select="$spells">
      <xsl:choose>
        <!-- Check if there's a duplicate -->
        <xsl:when test="count($spells[name = current()/name]) &gt; 1">
          <!-- Use the original spell that includes the "level" element -->
          <!-- Important: Duplicate spells should only contain "name" and "classes" elements -->
          <xsl:if test="level">

            <!-- Gather combination of all classes in comma separated list -->
            <xsl:variable name="class_list">
              <xsl:for-each select="$spells[name = current()/name]/classes">
                <xsl:if test="position() > 1">,</xsl:if>
                <xsl:value-of select="."/>
              </xsl:for-each>
            </xsl:variable>

            <spell>
              <xsl:copy-of select="name | level | school | ritual | time | range | components | duration"/>

              <!-- Merge classes into comma-separated list -->
              <classes>
                <xsl:variable name="tokens" select="str:tokenize(str:replace($class_list, ', ', ','), ',')" />
                <xsl:variable name="deduped">
                  <xsl:for-each select="$tokens">
                    <xsl:variable name="cls" select="normalize-space(.)" />
                    <xsl:if test="not(preceding-sibling::*[normalize-space(.) = $cls])">
                      <class><xsl:value-of select="$cls"/></class>
                    </xsl:if>
                  </xsl:for-each>
                </xsl:variable>
                <xsl:for-each select="exsl:node-set($deduped)/class">
                  <xsl:value-of select="."/>
                  <xsl:if test="position() != last()">, </xsl:if>
                </xsl:for-each>
              </classes>

              <xsl:copy-of select="text"/>
              <xsl:copy-of select="special | modifier | roll"/>
            </spell>
          </xsl:if>
        </xsl:when>
        <!-- If no duplicate, copy in the whole spell -->
        <xsl:otherwise>
          <xsl:copy-of select="." />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

</xsl:transform>
