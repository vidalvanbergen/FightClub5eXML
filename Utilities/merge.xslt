<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  xmlns:set="http://exslt.org/sets"
  xmlns:str="http://exslt.org/strings">
  <xsl:output method="xml" indent="yes" />


  <!-- Merge the compendiums together -->
  <xsl:template match="collection">
    <compendium version="5" auto_indent="NO">
      <xsl:variable name="compendium" select="document(doc/@href)/compendium" />

      <xsl:copy-of select="$compendium/item" />
      <xsl:copy-of select="$compendium/race" />

      <xsl:call-template name="classes-with-subclasses" />

      <xsl:copy-of select="$compendium/feat" />
      <xsl:copy-of select="$compendium/background" />

      <xsl:call-template name="spells-extendable" />

      <xsl:copy-of select="$compendium/monster" />
    </compendium>
  </xsl:template>


  <!-- Merges subclasses into classes -->
  <xsl:template name="classes-with-subclasses">
    <xsl:variable name="compendium" select="document(doc/@href)/compendium" />
    <xsl:variable name="classes" select="$compendium/class" />

    <xsl:for-each select="$classes">
      <xsl:choose>
        <!-- Check if there's a duplicate -->
        <xsl:when test="count($classes[name = current()/name]) &gt; 1">
          <!-- Use the original class that includes the "hd" element -->
          <!-- Important: Subclasses should only contain "name" and "autolevel" elements -->
          <xsl:if test="hd">
            <class>
              <xsl:copy-of select="name" />
              <xsl:copy-of select="hd" />
              <xsl:copy-of select="proficiency" />
              <xsl:copy-of select="spellAbility" />
              <xsl:copy-of select="numSkills" />
              <xsl:copy-of select="armor" />
              <xsl:copy-of select="weapons" />
              <xsl:copy-of select="tools" />
              <xsl:copy-of select="wealth" />
              <xsl:copy-of select="slotsReset" />
              <xsl:copy-of select="subclass" />

              <!-- Not supported by Fight Club 5e -->
              <xsl:for-each select="$classes[name = current()/name]">
                <xsl:copy-of select="trait" />
              </xsl:for-each>

              <xsl:for-each select="$classes[name = current()/name]">
                <xsl:copy-of select="autolevel" />
              </xsl:for-each>
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
    <xsl:variable name="compendium" select="document(doc/@href)/compendium" />
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
              <xsl:for-each select="$spells[name = current()/name]">
                <xsl:if test="position() > 1">,</xsl:if>
                <xsl:for-each select="classes">
                  <xsl:value-of select="." />
                </xsl:for-each>
              </xsl:for-each>
            </xsl:variable>

            <spell>
              <xsl:copy-of select="name" />
              <!-- <count_dupes><xsl:value-of select="count($spells[name =
              current()/name])"/></count_dupes> -->

              <xsl:copy-of select="level" />
              <xsl:copy-of select="school" />
              <xsl:copy-of select="ritual" />
              <xsl:copy-of select="time" />
              <xsl:copy-of select="range" />
              <xsl:copy-of select="components" />
              <xsl:copy-of select="duration" />

              <!-- Merge classes into comma-separated list -->
              <classes>
                <xsl:for-each select="str:tokenize(str:replace($class_list, ', ', ','), ',')">
                  <xsl:if test="position() > 1">, </xsl:if>
                  <xsl:value-of select="." />
                </xsl:for-each>
              </classes>

              <xsl:copy-of select="text" />
              <xsl:copy-of select="roll" />
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
