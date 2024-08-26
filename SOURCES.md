# FightClub5e XML

This page is dedicated to helping you make your own XML files to be imported in the FightClub5e app. This is the tutorial found in the app but modified a bit, plus advice on how to add your own sources or homebrew to the repository.

- [FightClub5e XML](#fightclub5e-xml)
  - [Elements and Tags](#elements-and-tags)
  - [Terminology](#terminology)
  - [Creating an XML file](#creating-an-xml-file)
  - [Spells](#spells)
  - [Items and Equipment](#items-and-equipment)
  - [Bestiary](#bestiary)
  - [Races](#races)
  - [Classes](#classes)
  - [Backgrounds](#backgrounds)
  - [Feats](#feats)
- [The FightClub5eXML Github Repository](#the-fightclub5exml-github-repository)
  - [Adding a Source](#adding-a-source)
    - [Subclasses](#subclasses)
    - [Spells](#spells-1)
  - [Manual Validation](#manual-validation)
  - [Build Your Own Compendium](#build-your-own-compendium)
    - [Create a collection file](#create-a-collection-file)
    - [Execute the merge](#execute-the-merge)

## [Elements and Tags](#fightclub5e-xml)

The basic unit of an XMl document is an element. It consists of a start tag, content, and an end tag. The start tag is represented using ```<abc>```, while the end tag is represented using ```</abc>```. The "abc" is the element name that is between '&lt;' and '&gt;'. The description of that element is written between the start and end tags.

For example, ```<name>Wizard</name>```, is an element named, "name" and is set to "Wizard". If you're not using an element, you can either delete it or type it in this manner, '```<spells/>```'. It's usually used when you paste a template of something so you copy an element that you may or may not use in this way so that if you wish to use it, you simply delete the '/', type the content inside, and end it with the appropriate closing tag.

If you want to start a new paragraph and want to leave a line out (when writing item description, for example), you insert a '&lt;text /&gt;' element.

## [Terminology](#fightclub5e-xml)

The content for elements will consist of text, numbers, dice rolls, formulas, or otherwise specified values.

Here are the content we'll be using :

  - **ABC**. Any text may be inputted. There are a few characters that can't be used. &, &lt;, &gt;. These characters must be replaced with ```&amp;```, ```&lt;```, and ```&gt;```, respectively
  - **###**. Any number may be inputted. Only unformated numbers are acceptable, meaning remove any commas and other characters, except for dots for decimal point numbers.
  - **D20**. A dice roll formula. For example, "1d10+5", "5d6", or "3d3+1d7-2". Use 'd' to denote a die. + and - operators are acceptable. Remove any white spaces.
  - The | denotes that the element can take a specific value from the given list. Acceptable values are separated the | character.
  - Some elements take multiple values. Acceptable values are separated by commas.
  
</ul>

For example, when you see "name (ABC)" throughout the tutorial, that says the element's name is "name" and it takes text as its content, as in ```<name>Gandalf the Grey</name>```. "classes (ABC, ABC, ...)" says the classes element takes multiple text strings, as in, ```<classes>Fighter, Wizard</classes>```.

## [Creating an XML file](#fightclub5e-xml)

Making your own file is an easy but time-consuming job. But you've come to the right place if you want to learn how to do it!

First off you'll need a Text Editor. You can definitely write everything using the default text editor on your machine, but there are applications that make the process much easier. I recommend using [Visual Studio Code](https://code.visualstudio.com/) or [Sublime Text](https://www.sublimetext.com/) since they are easy to use and have a lot of great features. Now that you've downloaded a text editor, let's begin!

The file must begin with the following line: ```<?xml version="1.0" encoding="UTF-8"?>```. The first element needed is, "compendium". The element must contain an attribute named, "version" with its value set to "5". The content for the compendium element will be your lists of spells, items, creatures, races, classes, backgrounds, and/or feats.

This is what your file should currently look like:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<compendium version="5">
  your content
</compendium>
```

Remember that every opening tag needs an accompanying ending tag. The compendium element may optionally take the auto_indent attribute with a value set to "YES" or "NO." Yes means certain text descriptions elements will automatically indent paragraphs. Ex: ```<compendium version="5" auto_indent="NO">```

## [Spells](#fightclub5e-xml)

A spell is defined using an element named spell. Its content will consist of several elements, which will define your spell. The following is a list of elements that can be used:

  - **name** (ABC)
  - **level** (##)
  - **school** (A | C | D | EN | EV | I | N | T) Spell school
    - **A** = abjuration
    - **C** = conjuration
    - **D** = divination
    - **EN** = enchantment
    - **EV** = evocation
    - **I** = illusion
    - **N** = necromancy
    - **T** = transmutation<
  - **classes** (ABC, ABC, ...)
  - **ritual** (YES | NO) *This element may be left out if the spell is not a ritual.*
  - **time** (ABC) Casting time
  - **range** (ABC)
  - **components** (V, S, M (ABC))
    - **V** = vocal
    - **S** = somatic
    - **M** = material
    - **(ABC)** = A description of the material used by the spell. *Must be enclosed in parentheses.*
  - **duration** (ABC)
  - **text** (ABC) Spell description. *Multiple text elements may be inputted. Each one represents a paragraph. If the auto_indent attribute is set in the compendium element, paragraphs after the first will automatically indent the first line.*
  - **roll** (D20) Dice roll formulas. *Ability modifiers can be inputted using STR, DEX, CON, INT, WIS, and CHA. To input the class spell ability modifier, use SPELL.*

Spell example:
```xml
<spell>
  <name>Magic Missile</name>
  <level>1</level>
  <school>EV</school>
  <classes>Fighter (Eldritch Knight), Sorcerer, Wizard</classes>
  <time>1 action</time>
  <range>120 feet</range>
  <components>V, S</components>
  <duration>Instantaneous</duration>
  <text>You create three glowing darts of magical force. Each dart hits a creature of your choice that you can see within range. A dart deals 1d4+1 force damage to its target. The darts all strike simultaneously and you can direct them to hit one creature or several.</text>
  <text/>
  <text>At Higher Levels:</text>
  <text>When you cast this spell using a spell slot of 2nd level or higher, the spell creates one more dart for each slot above 1st.</text>
  <text/>
  <text>Source: Player's Handbook p. 257</text>
  <roll>1d4+1</roll>
  <roll>(1d4+1)+(1d4+1)+(1d4+1)</roll>
</spell>
```

For the Github repository, if you're adding a new class to a spell or want to add a new spell list, you can create a new XML file with spell names, and the class or classes you would like to add, as shown in the example below:

```xml
<spell>
  <name>Magic Missile</name>
  <classes>Bard (Esoteric)</classes>
</spell>
```

These will be merged during compilation into a single spell with all the additional classes.

## [Items and Equipment](#fightclub5e-xml)

An item is defined using an element named item. Its content can consist of the following elements:

  - **name** (ABC)
  - **type** (LA | MA | HA | S | M | R | A | RD | ST | WD | RG | P | SC | W | G | $) Item category
    - **LA** = light armor
    - **MA** = medium armor
    - **HA** = heavy armor
    - **S** = shield
    - **M** = melee weapon
    - **R** = ranged weapon
    - **A** = ammunition
    - **RD** = rod
    - **ST** = staff
    - **WD** = wand
    - **RG** = ring
    - **P** = potion
    - **SC** = scroll
    - **W** = wondrous item
    - **G** = adventuring gear
    - **$** = money, gems
  - **magic** (YES | NO) *This element may be left out if the item isn't magical.*
  - **detail** (ABC) *The rarity of the item and whether it requires attunement or not. This only appears on the iOS and macOS version, sadly.*
  - **value** (##) Gold value of the item
  - **weight** (##)
  - **text** (ABC) Item description. *Multiple text elements may be inputted. Each one represents a paragraph. If the auto_indent attribute is set in the compendium element, paragraphs after the first will automatically indent the first line.*
  - **ac** (##) Armor class
  - **strength** (##) Strength score required wear armor
  - **stealth** (YES | NO) Disadvantage on Stealth checks
  - **dmg1** (D20) One-handed weapon damage
  - **dmg2** (D20) Two-handed weapon damage
  - **dmgType** (B | P | S | A | C | F | FC | L | N | PS | R | T) Damage type
    - **B** = bludgeoning
    - **P** = piercing
    - **S** = slashing
    - **A** = acid
    - **C** = cold
    - **F** = fire
    - **FC** = force
    - **L** = lightning
    - **N** = necrotic
    - **PS** = poison
    - **R** = radiant
    - **T** = thunder
  - **property** (A, F, H, L, LD, R, S, T, 2H, V) Weapon properties. *Multiple values separated by commas allowed.*
    - **A** = ammunition
    - **F** = finesse
    - **H** = heavy
    - **L** = light
    - **LD** = loading
    - **R** = reach
    - **S** = special
    - **T** = thrown
    - **2H** = two-handed
    - **V** = versatile
    - **M** = martial weapon
  - **range** (##/##) Weapon range. *(short range/long range)*
  - **modifier** (ABC [+/-]##) Modifiers. *This element takes an attribute named "category". The category can be set to one of the following: ```bonus```, ```ability score```, ```ability modifier```, ```saving throw```, or ```skill```. The value for this element is the modifier name, followed by its value. For example, "weapon attack +1", "strength -1", or "ac +5". See the modifiers lists in the app for more valid values.*
  - **roll** (D20) Dice roll formulas. *Ability modifiers can be inputted using STR, DEX, CON, INT, WIS, CHA, and SPELL.*

Examples:
```xml
<item>
  <name>Plate Armor</name>
  <detail>uncommon</detail>
  <type>HA</type>
  <weight>65</weight>
  <value>1500.0</value>
  <property/>
  <ac>18</ac>
  <stealth>1</stealth>
  <strength>15</strength>
  <text>Plate consists of shaped, interlocking metal plates to cover the entire body. A suit of plate includes gauntlets, heavy leather boots, a visored helmet, and thick layers of padding underneath the armor. Buckles and straps distribute the weight over the body.</text>
  <text/>
  <text>The wearer has disadvantage on Stealth (Dexterity) checks.</text>
  <text/>
  <text>If the wearer has a Strength score lower than 15, their speed is reduced by 10 feet.</text>
  <text/>
  <text>Source:	Player's Handbook p. 145</text>
</item>

<item>
  <name>Longsword</name>
  <detail>common</detail>
  <type>M</type>
  <weight>3</weight>
  <value>15.0</value>
  <property>V,M</property>
  <dmg1>1d8</dmg1>
  <dmg2>1d10</dmg2>
  <dmgType>S</dmgType>
  <text>Versatile: This weapon can be used with one or two hands. A damage value in parentheses appears with the property—the damage when the weapon is used with two hands to make a melee Attack.</text>
  <text/>
  <text>Proficiency: martial, longsword</text>
  <text>Source:	Player's Handbook p. 149</text>
</item>

<item>
  <name>Longbow</name>
  <detail>common</detail>
  <type>R</type>
  <weight>2</weight>
  <value>50.0</value>
  <property>A,H,2H,M</property>
  <dmg1>1d8</dmg1>
  <dmgType>P</dmgType>
  <range>150/600</range>
  <text>Ammunition: You can use a weapon that has the ammunition property to make a ranged attack only if you have ammunition to fire from the weapon. Each time you attack with the weapon, you expend one piece of ammunition. Drawing the ammunition from a quiver, case, or other container is part of the attack (you need a free hand to load a one-handed weapon). At the end of the battle, you can recover half your expended ammunition by taking a minute to search the battlefield.</text>
  <text/>
  <text>If you use a weapon that has the ammunition property to make a melee attack, you treat the weapon as an improvised weapon (see "Improvised Weapons").</text>
  <text/>
  <text>Range: A weapon that can be used to make a ranged attack has a range shown in parentheses after the ammunition or thrown property. The range lists two numbers. The first is the weapon's normal range in feet, and the second indicates the weapon's maximum range. When attacking a target beyond normal range, you have disadvantage on the attack roll. You can't attack a target beyond the weapon's long range.</text>
  <text/>
  <text>Two-Handed: This weapon requires two hands when you attack with it.</text>
  <text/>
  <text>Heavy: Small creatures have disadvantage on attack rolls with heavy weapons. A heavy weapon's size and bulk make it too large for a Small creature to use effectively.</text>
  <text/>
  <text>Proficiency: martial, longbow
  <text>Source:	Player's Handbook p. 149</text>
</item>
```

## [Bestiary](#fightclub5e-xml)

Monsters, beast shapes, companions, familiars, etc. are defined using an element named monster. Its content can consist of the following elements:

  - **name** (ABC)
  - **size** (T | S | M | L | H | G) Creature size
    - **T** = tiny
    - **S** = small
    - **M** = medium
    - **L** = large
    - **H** = huge
    - **G** = gargantuan
  - **type** (ABC) Creature type
  - **alignment** (ABC)
  - **ac** (## (ABC)) *Armor class followed by armor type enclosed in parentheses.*
  - **hp** (## (D20)) *Default hp followed by hit dice formula enclosed in parentheses.*
  - **speed** (ABC)
  - **str** (##) Strength score
  - **dex** (##) Dexterity score
  - **con** (##) Constitution score
  - **int** (##) Intelligence score
  - **wis** (##) Wisdom score
  - **cha** (##) Charisma score
  - **save** (Str ##, Dex ##, ...) *Saving throws with modifiers separated by commas.*
  - **skill** (Skill Name [+/-]##, Skill Name [+/-]##, ...) *Skills with modifiers separated by commas, optional plus or minus.*
  - **vulnerable** (ABC) Damage vulnerabilities
  - **resist** (ABC) Damage resistances
  - **immune** (ABC) Damage immunities
  - **conditionImmune** (ABC) Conditional immunities
  - **senses** (ABC)
  - **passive** (##) Passive perception
  - **languages** (ABC)
  - **cr** (##) Challenge rating. *A number from 1 to 30, or 1/2, 1/4, 1/8, 0, or 00 (denotes CR 0 and 0 XP).*
  - **trait, action, reaction, legendary** *These elements take the following elements as content:*
    - **name** (ABC)
    - **recharge** (SHORT | LONG | #/Day | D#) How often the action can be used.
      - **SHORT** = Once per short rest
      - **LONG** = Once per long rest
      - **#/Day** = # times per day
      - **D#** = Roll a D6, if the number is # or higher the action is available.
    - **text** (ABC) Item description. *Multiple text elements may be inputted. Each one represents a paragraph. If the auto_indent attribute is set in the compendium element, paragraphs after the first will automatically indent the first line.*
    - **attack** (ABC|[+/-]##|D20) *Attacks consist of three parts, separated by the '|' character. The first part is the attack label, which takes a text string. The s second is a number representing the attack roll bonus. The last is the damage roll. All of these parts are optional and can be left empty.*
  - **spells** (ABC, ABC, ...) Spells prepared or known. *The spells need to be imported first for these to be shown.*
  - **slots** (###, ###, ###) Spell slots available for each increasing level.
  - **description** (ABC) Monster description. *Multiple description elements may be inputted. Each one represents a paragraph. If the auto_indent attribute is set in the compendium element, paragraphs after the first will automatically indent the first line.*
  - **environment** (ABC, ABC, ...) Environment where it may be found. *Only appears in Game Master.*

Monster example:
```xml
<monster>
  <name>Adult Red Dragon</name>
  <size>H</size>
  <type>dragon</type>
  <alignment>Chaotic Evil</alignment>
  <ac>19 (natural armor)</ac>
  <hp>256 (19d12+133)</hp>
  <speed>walk 40 ft., climb 40 ft., fly 80 ft.</speed>
  <str>27</str>
  <dex>10</dex>
  <con>25</con>
  <int>16</int>
  <wis>13</wis>
  <cha>21</cha>
  <save>Dex +6, Con +13, Wis +7, Cha +11</save>
  <skill>Perception +13, Stealth +6</skill>
  <passive>23</passive>
  <languages>Common, Draconic</languages>
  <cr>17</cr>
  <resist/>
  <immune>fire</immune>
  <vulnerable/>
  <conditionImmune/>
  <senses>blindsight 60 ft., darkvision 120 ft.</senses>
  <trait>
    <name>Legendary Resistance (3/Day)</name>
    <recharge>3/Day</recharge>
    <text>
If the dragon fails a saving throw, it can choose to succeed instead.</text>
  </trait>
  <action>
    <name>Multiattack</name>
    <text>
The dragon can use its Frightful Presence. It then makes three attacks: one with its bite and two with its claws.</text>
  </action>
  <action>
    <name>Bite</name>
    <text>
Melee Weapon Attack: +14 to hit, reach 10 ft., one target. Hit: 19 (2d10 + 8) piercing damage plus 7 (2d6) fire damage.</text>
    <attack>Bite|+14|2d10+8</attack>
  </action>
  <action>
    <name>Claw</name>
    <text>
Melee Weapon Attack: +14 to hit, reach 5 ft., one target. Hit: 15 (2d6 + 8) slashing damage.</text>
    <attack>Claw|+14|2d6+8</attack>
  </action>
  <action>
    <name>Tail</name>
    <text>
Melee Weapon Attack: +14 to hit, reach 15 ft., one target. Hit: 17 (2d8 + 8) bludgeoning damage.</text>
    <attack>Tail|+14|2d8+8</attack>
  </action>
  <action>
    <name>Frightful Presence</name>
    <text>
Each creature of the dragon's choice that is within 120 feet of the dragon and aware of it must succeed on a DC 19 Wisdom saving throw or become frightened for 1 minute. A creature can repeat the saving throw at the end of each of its turns, ending the effect on itself on a success. If a creature's saving throw is successful or the effect ends for it, the creature is immune to the dragon's Frightful Presence for the next 24 hours.</text>
  </action>
  <action>
    <name>Fire Breath (Recharge 5-6)</name>
    <text>
The dragon exhales fire in a 60-foot cone. Each creature in that area must make a DC 21 Dexterity saving throw, taking 63 (18d6) fire damage on a failed save, or half as much damage on a successful one.</text>
    <attack>Fire Breath (Recharge 5-6)||18d6</attack>
  </action>
  <legendary>
    <text>The dragon can take 3 legendary actions, choosing from the options below. Only one legendary action can be used at a time and only at the end of another creature's turn. The dragon regains spent legendary actions at the start of its turn.</text>
  </legendary>
  <legendary>
    <name>Detect</name>
    <text>
The dragon makes a Wisdom (Perception) check.</text>
  </legendary>
  <legendary>
    <name>Tail Attack</name>
    <text>
The dragon makes a tail attack.</text>
  </legendary>
  <legendary>
    <name>Wing Attack (Costs 2 Actions)</name>
    <text>
The dragon beats its wings. Each creature within 10 feet of the dragon must succeed on a DC 22 Dexterity saving throw or take 15 (2d6 + 8) bludgeoning damage and be knocked prone. The dragon can then fly up to half its flying speed.</text>
  </legendary>
  <legendary>
    <name>Lair Actions</name>
    <text>
On initiative count 20 (losing initiative ties), the dragon takes a lair action to cause one of the following effects; the dragon can't use the same effect two rounds in a row:</text>
<text/>
<text>	• Magma erupts from a point on the ground the dragon can see within 120 feet of it, creating a 20-foot-high, 5-foot-radius geyser. Each creature in the geyser's area must make a DC 15 Dexterity saving throw, taking 21 (6d6) fire damage on a failed save, or half as much damage on a successful one.</text>
<text/>
<text>	• A tremor shakes the lair in a 60-foot radius around the dragon. Each creature other than the dragon on the ground in that area must succeed on a DC 15 Dexterity saving throw or be knocked prone.</text>
<text/>
<text>	• Volcanic gases form a cloud in a 20-foot-radius sphere centered on a point the dragon can see within 120 feet of it. The sphere spreads a round corners, and its area is lightly obscured. It lasts until initiative count 20 on the next round. Each creature that starts its turn in the cloud must succeed on a DC 13 Constitution saving throw or be poisoned until the end of its turn. While poisoned in this way, a creature is incapacitated.</text>
  </legendary>
  <legendary>
    <name>Regional Effects</name>
    <text>
The region containing a legendary red dragon's lair is warped by the dragon's magic, which creates one or more of the following effects:</text>
<text/>
<text>	• Small earthquakes are common within 6 miles of the dragon's lair.</text>
<text/>
<text>	• Water sources within 1 mile of the lair are supernaturally warm and tainted by sulfur.</text>
<text/>
<text>	• Rocky fissures within 1 mile of the dragon's lair form portals to the Elemental Plane of Fire, allowing creatures of elemental fire into the world to dwell nearby.</text>
<text/>
<text>If the dragon dies, these effects fade over the course of 1d10 days.</text>
  </legendary>
  <description>True dragons are winged reptiles of ancient lineage and fearsome power. They are known and feared for their predatory cunning and greed, with the oldest dragons accounted as some of the most powerful creatures in the world. Dragons are also magical creatures whose innate power fuels their dreaded breath weapons and other preternatural abilities.

Many creatures, including wyverns and dragon turtles, have draconic blood. However, true dragons fall into the two broad categories of chromatic and metallic dragons. The black, blue, green, red, and white dragons are selfish, evil, and feared by all. The brass, bronze, copper, gold, and silver dragons are noble, good, and highly respected by the wise.

Though their goals and ideals vary tremendously, all true dragons covet wealth, hoarding mounds of coins and gathering gems, jewels, and magic items. Dragons with large hoards are loath to leave them for long, venturing out of their lairs only to patrol or feed.

True dragons pass through four distinct stages of life, from lowly wyrmlings to ancient dragons, which can live for over a thousand years. In that time, their might can become unrivaled and their hoards can grow beyond price.

Dragon Age Categories:
Category | Size | Age Range
Wyrmling | Medium | 5 years or less
Young | Large | 6-100 years
Adult | Huge | 101-800 years
Ancient | Gargantuan | 801 years or more

Source:	Monster Manual p. 98,
		Rise of Tiamat,
		Tales from the Yawning Portal,
		Ghosts of Saltmarsh,
		Explorer's Guide to Wildemount,
		Mythic Odysseys of Theros</description>
  <environment>mountain, hill</environment>
</monster>
```

## [Races](#fightclub5e-xml)

A race is defined using an element named race. Its content can consist of the following elements:

  - **name** (ABC)
  - **ability** (Str [+/-]##, Dex [+/-]##, ...) Ability score increases. A*bilities with increase amounts, separated by commas.*
  - **size** (T | S | M | L | H | G) Creature size
    - **T** = tiny
    - **S** = small
    - **M** = medium
    - **L** = large
    - **H** = huge
    - **G** = gargantuan
  - **speed** (##) Speed in feet
  - **spellAbility** Spellcasting ability. *Intelligence, Wisdom, etc.*
  - **proficiency** (ABC, ABC, ...) Saving throw and class skill proficiencies. *Enter names of abilities or skills separated by commas.*
  - **trait** Racial traits. *Multiple traits are allowed. The following elements may be used as content.*
    - **name** (ABC)
    - **text** (ABC) Trait description. *Multiple text elements may be inputted. Each one represents a paragraph. If the auto_indent attribute is set in the compendium element, paragraphs after the first will automatically indent the first line.*
    - **modifier** (ABC [+/-]##) Modifiers. *This element takes an attribute named "category". The category can be set to one of the following: bonus, ability score, ability modifier, saving throw, or skill. The value for this element is the modifier name, followed by its value. For example, "weapon attack +1", "strength -1", or "ac +5". See the modifiers lists in the app for more valid values.*

Race example:
```xml
<race>
  <name>Elf, Sea</name>
  <size>M</size>
  <speed>30</speed>
  <ability>Dex 2, Con 1</ability>
  <spellAbility/>
  <proficiency>Perception</proficiency>
  <trait>
    <name>Description</name>
    <text>Sea elves fell in love with the wild beauty of the ocean in the earliest days of the multiverse. While other elves traveled from realm to realm, sea elves navigated the currents and explored the waters of many worlds. Today these elves can be found wherever oceans exist, as well as in the Elemental Plane of Water.</text>
    <text/>
    <text>Like other elves, sea elves can live to be over 750 years old.</text>
    <text/>
    <text>Source:	Player's Handbook p. 23,</text>
    <text>		Mordenkainen's Tome of Foes p. 62,<text>
    <text>		Mordenkainen Presents: Monsters of the Multiverse p. 30</text>
  </trait>
  <trait>
    <name>Ability Score Increases</name>
    <text>Increase one ability score by 2 and increase a different score by 1, or increase three different scores by 1.</text>
  </trait>
  <trait>
    <name>Creature Type</name>
    <text>You are a Humanoid. You are also considered an elf for any prerequisite or effect that requires you to be an elf.</text>
  </trait>
  <trait>
    <name>Life Span</name>
    <text>Although elves reach physical maturity at about the same age as humans, the elven understanding of adulthood goes beyond physical growth to encompass worldly experience. An elf typically claims adulthood and an adult name around the age of 100 and can live to be 750 years old.</text>
  </trait>
  <trait>
    <name>Alignment</name>
    <text>Elves love freedom, variety, and self-expression, so they lean strongly toward the gentler aspects of chaos. They value and protect others' freedom as well as their own, and they are more often good than not.</text>
  </trait>
  <trait>
    <name>Size</name>
    <text>Elves range from under 5 to over 6 feet tall and have slender builds. Your size is Medium.</text>
    <text/>
    <text>To set your height and weight randomly, start with rolling a size modifier:</text>
    <text/>
    <text>Size modifier = 2d10</text>
    <text>Height = 4 feet + 6 inches + your size modifier in inches</text>
    <text>Weight in pounds = 90 + (1d4 × your size modifier)</text>
  </trait>
  <trait>
    <name>Speed</name>
    <text>Your walking speed is 30 feet, and you have a swimming speed equal to your walking speed.</text>
  </trait>
  <trait>
    <name>Child of the Sea</name>
    <text>You can breathe air and water, and you have resistance to cold damage.</text>
  </trait>
  <trait>
    <name>Darkvision</name>
    <text>You can see in dim light within 60 feet of you as if it were bright light, and in darkness as if it were dim light. You discern colors in that darkness only as shades of gray.</text>
  </trait>
  <trait>
    <name>Fey Ancestry</name>
    <text>You have advantage on saving throws you make to avoid or end the charmed condition on yourself.</text>
  </trait>
  <trait>
    <name>Friend of the Sea</name>
    <text>Aquatic animals have an extraordinary affinity with your people. You can communicate simple ideas to any Beast that has a swimming speed. It can understand your words, though you have no special ability to understand it in return.</text>
  </trait>
  <trait>
    <name>Keen Senses</name>
    <text>You have proficiency in the Perception skill.</text>
  </trait>
  <trait>
    <name>Trance</name>
    <text>You don't need to sleep, and magic can't put you to sleep. You can finish a long rest in 4 hours if you spend those hours in a trancelike meditation, during which you retain consciousness.</text>
    <text/>
    <text>Whenever you finish this trance, you can gain two proficiencies that you don't have, each one with a weapon or a tool of your choice selected from the Player's Handbook. You mystically acquire these proficiencies by drawing them from shared elven memory, and you retain them until you finish your next long rest.</text>
  </trait>
  <trait>
    <name>Languages</name>
    <text>Your character can speak, read, and write Common and one other language that you and your DM agree is appropriate for the character. The Player's Handbook offers a list of languages to choose from. The DM is free to modify that list for a campaign.</text>
  </trait>
</race>
```

## [Classes](#fightclub5e-xml)

A class is defined using an element named class. Its content can consist of the following elements:

  - **name** (ABC)
  - **hd** (##) Hit Die. Input the die number (i.e. 8 for a d8).
  - **proficiency** (ABC, ABC, ...) Saving throw and class skill proficiencies. *Enter names of abilities or skills separated by commas.*
  - **numSkills** (##) Number of class skills to be chosen from when creating a character.
  - **armor** (ABC) Armor and shield proficiencies.
  - **weapons** (ABC) Weapons proficiencies.
  - **tools** (ABC) Tool proficiencies.
  - **wealth** (D20) Starting wealth. *Enter a formula that determines a 1st-level character's starting gold.*
  - **spellAbility** Spellcasting ability. *Intelligence, Wisdom, etc.*
  - **slotsReset** (S | L) Spell slots reset type
    - **S** = short rests
    - **L** = long rests
  - **autolevel** Defines the spell slots and features attained at the given level. *To specify the level, declare an attribute named "level" with a number value. You can also specify if this level has the Ability Score Improvement feature using the "scoreImprovement" attribute with its value set to "YES".*
    - **slots** (##,##, ...) Spells slots. *Up to 10 numbers separated by commas that define the number spell slots available at this level. The first number is the number of cantrips known, followed by spell slots at 1st level, 2nd level, and so on. If spells are an option, the "optional" attribute can be used with its value set to "YES" (i.e. ```<slots optional="YES">```)."*
    - **feature** Class features gained at this level. *If feature is an option, the "optional" attribute can be used with its value set to "YES" (i.e. ```<feature optional="YES">```). Subclass features should be set to optional.*
      - **name** (ABC)
      - **text** (ABC) Feature description. *Multiple text elements may be inputted. Each one represents a paragraph. If the auto_indent attribute is set in the compendium element, paragraphs after the first will automatically indent the first line.*
      - **modifier** (ABC [+/-]##) Modifiers. *This element takes an attribute named "category". The category can be set to one of the following: bonus, ability score, ability modifier, saving throw, or skill. The value for this element is the modifier name, followed by its value. For example, "weapon attack +1", "strength -1", or "ac +5". See the modifiers lists in the app for more valid values.*
    - **counter** Tracker usage of class features (i.e. Rage or Ki Points)
      - **name** (ABC)
      - **value** (##) Starting value
      - **reset** (S | L) Reset type
        - **S** = short rests
        - **L** = long rests

Class example:
```xml
<class>
  <name>Ranger</name>
  <hd>10</hd>
  <proficiency>Strength, Dexterity, Animal Handling, Athletics, Insight, Investigation, Nature, Perception, Stealth, Survival</proficiency>
  <numSkills>3</numSkills>
  <armor>Light Armor, Medium Armor, Shields</armor>
  <weapons>Simple Weapons, Martial Weapons</weapons>
  <tools>None</tools>
  <wealth>5d4x10</wealth>
  <spellAbility>Wisdom</spellAbility>
  <slotsReset>L</slotsReset>
  <subclass>Ranger Archetype</subclass>

  <autolevel level="2"><slots>0, 2</slots></autolevel>
  <autolevel level="3"><slots>0, 3</slots></autolevel>
  <autolevel level="4"><slots>0, 3</slots></autolevel>
  <autolevel level="5"><slots>0, 4, 2</slots></autolevel>
  <autolevel level="6"><slots>0, 4, 2</slots></autolevel>
  <autolevel level="7"><slots>0, 4, 3</slots></autolevel>
  <autolevel level="8"><slots>0, 4, 3</slots></autolevel>
  <autolevel level="9"><slots>0, 4, 3, 2</slots></autolevel>
  <autolevel level="10"><slots>0, 4, 3, 2</slots></autolevel>
  <autolevel level="11"><slots>0, 4, 3, 3</slots></autolevel>
  <autolevel level="12"><slots>0, 4, 3, 3</slots></autolevel>
  <autolevel level="13"><slots>0, 4, 3, 3, 1</slots></autolevel>
  <autolevel level="14"><slots>0, 4, 3, 3, 1</slots></autolevel>
  <autolevel level="15"><slots>0, 4, 3, 3, 2</slots></autolevel>
  <autolevel level="16"><slots>0, 4, 3, 3, 2</slots></autolevel>
  <autolevel level="17"><slots>0, 4, 3, 3, 3, 1</slots></autolevel>
  <autolevel level="18"><slots>0, 4, 3, 3, 3, 1</slots></autolevel>
  <autolevel level="19"><slots>0, 4, 3, 3, 3, 2</slots></autolevel>
  <autolevel level="20"><slots>0, 4, 3, 3, 3, 2</slots></autolevel>

  <autolevel level="1">
    <feature optional="YES">
      <name>Starting Ranger</name>
      <text>As a 1st-level Ranger, you begin play with 10 + your Constitution modifier hit points.</text>
      <text/>
      <text>You are proficient with the following items, in addition to any proficiencies provided by your race or background.</text>
      <text/>
      <text>	• Armor: light armor, medium armor, shields</text>
      <text>	• Weapons: simple weapons, martial weapons</text>
      <text>	• Tools: none</text>
      <text>	• Skills: Choose 3 from Animal Handling, Athletics, Insight, Investigation, Nature, Perception, Stealth, Survival</text>
      <text/>
      <text>You begin play with the following equipment, in addition to any equipment provided by your background.</text>
      <text/>
      <text>	• (a) scale mail or (b) leather armor</text>
      <text>	• (a) two shortsword or (b) two simple melee weapons</text>
      <text>	• (a) a dungeoneer's pack or (b) an explorer's pack</text>
      <text>	• A longbow and a quiver of arrows (20)</text>
      <text/>
      <text>Alternatively, you may start with 5d4 × 10 gp and choose your own equipment.</text>
      <text/>
      <text>Source:	Player's Handbook p. 89</text>
    </feature>
  </autolevel>

  <autolevel level="1">
    <feature optional="YES">
      <name>Multiclass Ranger</name>
      <text>If your group uses the optional rule on multiclassing in the Player's Handbook, here's what you need to know if you choose ranger as one of your classes.</text>
      <text/>
      <text>Ability Score Minimum:</text>
      <text>As a multiclass character, you must have at least the following ability score(s) to take a level in this class, or to take a level in another class if you are already a ranger.</text>
      <text/>
      <text>	• Dexterity 13</text>
      <text>	• Wisdom 13</text>
      <text/>
      <text>Proficiencies Gained:</text>
      <text>If ranger isn't your initial class, here are the proficiencies you gain when you take your first level as a ranger.</text>
      <text/>
      <text>	• Armor: light armor, medium armor, shields</text>
      <text>	• Weapons: simple weapons, martial weapons</text>
      <text>	• Tools: none</text>
      <text>	• Skills: Choose 1 from Animal Handling, Athletics, Insight, Investigation, Nature, Perception, Stealth and Survival.</text>
      <text/>
      <text>Source:	Player's Handbook p. 89</text>
    </feature>
  </autolevel>

  <autolevel level="1">
    <feature>
      <name>Favored Enemy</name>
      <text>Beginning at 1st level, you have significant experience studying, tracking, hunting, and even talking to a certain type of enemy.</text>
      <text/>
      <text>Choose a type of favored enemy: aberrations, beasts, celestials, constructs, dragons, elementals, fey, fiends, giants, monstrosities, oozes, plants, or undead. Alternatively, you can select two races of humanoid (such as gnoll and orc) as favored enemies.</text>
      <text/>
      <text>You have advantage on Wisdom (Survival) checks to track your favored enemies, as well as on Intelligence checks to recall information about them.</text>
      <text/>
      <text>When you gain this feature, you also learn one language of your choice that is spoken by your favored enemies, if they speak one at all.</text>
      <text/>
      <text>You choose one additional favored enemy, as well as an associated language, at 6th and 14th level. As you gain levels, your choices should reflect the types of monsters you have encountered on your adventures.</text>
      <text/>
      <text>Source:	Player's Handbook p. 91</text>
    </feature>
  </autolevel>

...

  <autolevel level="4" scoreImprovement="YES">
    <feature>
      <name>Ability Score Improvement</name>
      <text>When you reach 4th level, you can increase one ability score of your choice by 2, or you can increase two ability scores of your choice by 1. As normal, you can't increase an ability score above 20 using this feature.</text>
      <text/>
      <text>If your DM allows the use of feats, you may instead take a feat.</text>
      <text/>
      <text>Source:	Player's Handbook p. 89</text>
    </feature>
  </autolevel>

...

  <autolevel level="20">
    <feature>
      <name>Foe Slayer</name>
      <text>At 20th level, you become an unparalleled hunter of your enemies. Once on each of your turns, you can add your Wisdom modifier to the attack roll or the damage roll of an attack you make against one of your favored enemies. You can choose to use this feature before or after the roll, but before any effects of the roll are applied.</text>
      <text/>
      <text>Source:	Player's Handbook p. 92</text>
    </feature>
  </autolevel>
</class>
```

For the Github repository, when you're adding a new subclass, you can create a new XML file with class features using the same name as the base class you want to add them to as shown in the example below:

```xml
<class>
  <name>Bard</name>
  <autolevel level="3">
    <feature optional="YES">
      <name>Bard College: College of ...</name>
      <text>...</text>
      <text/>
      <text>Source:	Tasha's Crucible of Everything Else p. 28</text>
    </feature>
    <feature optional="YES">
      <name>College of ...:</name>
      <text>...</text>
      <text/>
      <text>Source:	Tasha's Crucible of Everything Else p. 28</text>
    </feature>
  </autolevel>
  <autolevel level="6">
    <feature optional="YES">
      <name>College of ...:</name>
      <text>...</text>
      <text/>
      <text>Source:	Tasha's Crucible of Everything Else p. 28</text>
    </feature>
  </autolevel>
</class>
```

These will be merged during compilation into a single class with all the additional features.

## [Backgrounds](#fightclub5e-xml)

A backgrounds is defined using an element named background. Its content can consist of the following elements:

  - **name** (ABC)
  - **proficiency** (ABC, ABC, ...) Saving throw and skill proficiencies. *Enter names of abilities or skills separated by commas.*
  - **trait** Background traits. Multiple traits are allowed. *The following elements may be used as content.*
    - **name** (ABC)
    - **text** (ABC) Trait description. *Multiple text elements may be inputted. Each one represents a paragraph. If the auto_indent attribute is set in the compendium element, paragraphs after the first will automatically indent the first line.*
    - **modifier** (ABC [+/-]##) Modifiers. *This element takes an attribute named "category". The category can be set to one of the following: bonus, ability score, ability modifier, saving throw, or skill. The value for this element is the modifier name, followed by its value. For example, "weapon attack +1", "strength -1", or "ac +5". See the modifiers lists in the app for more valid values.*

Background example:
```xml
<background>
  <name>Acolyte</name>
  <proficiency>Insight, Religion</proficiency>
  <trait>
    <name>Description</name>
    <text>You have spent your life in the service of a temple to a specific god or pantheon of gods. You act as an intermediary between the realm of the holy and the mortal world, performing sacred rites and offering sacrifices in order to conduct worshipers into the presence of the divine. You are not necessarily a cleric—performing sacred rites is not the same thing as channeling divine power.</text>
    <text/>
    <text>Choose a god, a pantheon of gods, or some other quasi-divine being, and work with your DM to detail the nature of your religious service. The Gods of the Multiverse section contains a sample pantheon, from the Forgotten Realms setting. Were you a lesser functionary in a temple, raised from childhood to assist the priests in the sacred rites? Or were you a high priest who suddenly experienced a call to serve your god in a different way? Perhaps you were the leader of a small cult outside of any established temple structure, or even an occult group that served a fiendish master that you now deny.</text>
    <text/>
    <text>	• Skill Proficiencies: Insight, Religion</text>
    <text>	• Languages: Two of your choice</text>
    <text>	• Equipment: A holy symbol (a gift to you when you entered the priesthood), a prayer book or prayer wheel, 5 sticks of incense, vestments, a set of common clothes, and a belt pouch containing 15 gp</text>
    <text/>
    <text>Source:	Player's Handbook p. 127</text>
  </trait>
  <trait>
    <name>Feature: Shelter of the Faithful</name>
    <text>As an acolyte, you command the respect of those who share your faith, and you can perform the religious ceremonies of your deity. You and your adventuring companions can expect to receive free healing and care at a temple, shrine, or other established presence of your faith, though you must provide any material components needed for spells. Those who share your religion will support you (but only you) at a modest lifestyle.</text>
    <text/>
    <text>You might also have ties to a specific temple dedicated to your chosen deity or pantheon, and you have a residence there. This could be the temple where you used to serve, if you remain on good terms with it, or a temple where you have found a new home. While near your temple, you can call upon the priests for assistance, provided the assistance you ask for is not hazardous and you remain in good standing with your temple.</text>
  </trait>
  <trait>
    <name>Suggested Characteristics</name>
    <text>Acolytes are shaped by their experience in temples or other religious communities. Their study of the history and tenets of their faith and their relationships to temples, shrines, or hierarchies affect their mannerisms and ideals. Their flaws might be some hidden hypocrisy or heretical idea, or an ideal or bond taken to an extreme.</text>
    <text/>
    <text>d8 | Personality Trait</text>
    <text>1 | I idolize a particular hero of my faith, and constantly refer to that person's deeds and example.</text>
    <text>2 | I can find common ground between the fiercest enemies, empathizing with them and always working toward peace.</text>
    <text>3 | I see omens in every event and action. The gods try to speak to us, we just need to listen.</text>
    <text>4 | Nothing can shake my optimistic attitude.</text>
    <text>5 | I quote (or misquote) sacred texts and proverbs in almost every situation.</text>
    <text>6 | I am tolerant (or intolerant) of other faiths and respect (or condemn) the worship of other gods.</text>
    <text>7 | I've enjoyed fine food, drink, and high society among my temple's elite. Rough living grates on me.</text>
    <text>8 | I've spent so long in the temple that I have little practical experience dealing with people in the outside world.</text>
    <text/>
    <text>d6 | Ideal</text>
    <text>1 | Tradition. The ancient traditions of worship and sacrifice must be preserved and upheld. (Lawful)</text>
    <text>2 | Charity. I always try to help those in need, no matter what the personal cost. (Good)</text>
    <text>3 | Change. We must help bring about the changes the gods are constantly working in the world. (Chaotic)</text>
    <text>4 | Power. I hope to one day rise to the top of my faith's religious hierarchy. (Lawful)</text>
    <text>5 | Faith. I trust that my deity will guide my actions. I have faith that if I work hard, things will go well. (Lawful)</text>
    <text>6 | Aspiration. I seek to prove myself worthy of my god's favor by matching my actions against his or her teachings. (Any)</text>
    <text/>
    <text>d6 | Bond</text>
    <text>1 | I would die to recover an ancient relic of my faith that was lost long ago.</text>
    <text>2 | I will someday get revenge on the corrupt temple hierarchy who branded me a heretic.</text>
    <text>3 | I owe my life to the priest who took me in when my parents died.</text>
    <text>4 | Everything I do is for the common people.</text>
    <text>5 | I will do anything to protect the temple where I served.</text>
    <text>6 | I seek to preserve a sacred text that my enemies consider heretical and seek to destroy.</text>
    <text/>
    <text>d6 | Flaw</text>
    <text>1 | I judge others harshly, and myself even more severely.</text>
    <text>2 | I put too much trust in those who wield power within my temple's hierarchy.</text>
    <text>3 | My piety sometimes leads me to blindly trust those that profess faith in my god.</text>
    <text>4 | I am inflexible in my thinking.</text>
    <text>5 | I am suspicious of strangers and expect the worst of them.</text>
    <text>6 | Once I pick a goal, I become obsessed with it to the detriment of everything else in my life.</text>
  </trait>
</background>
```

## [Feats](#fightclub5e-xml)

A feat is defined using an element named feat. Its content can consist of the following elements:

  - **name** (ABC)
  - **prerequisite** (ABC)
  - **special** (ABC) Special traits. *See the app for the list of available traits.*
  - **text** (ABC) Feat description. *Multiple text elements may be inputted. Each one represents a paragraph. If the auto_indent attribute is set in the compendium element, paragraphs after the first will automatically indent the first line.*
  - **modifier** (ABC [+/-]##) Modifiers. *This element takes an attribute named "category". The category can be set to one of the following: bonus, ability score, ability modifier, saving throw, or skill. The value for this element is the modifier name, followed by its value. For example, "weapon attack +1", "strength -1", or "ac +5". See the modifiers lists in the app for more valid values.*

Feat example:
```xml
<feat>
  <name>Actor</name>
  <prerequisite/>
  <text>Skilled at mimicry and dramatics, you gain the following benefits:</text>
  <text/>
  <text>	• Increase your Charisma score by 1, to a maximum of 20.</text>
  <text/>
  <text>	• You have advantage on Charisma (Deception) and Charisma (Performance) checks when trying to pass yourself off as a different person.</text>
  <text/>
  <text>	• You can mimic the speech of another person or the sounds made by other creatures. You must have heard the person speaking, or heard the creature make the sound, for at least 1 minute. A successful Wisdom (Insight) check contested by your Charisma (Deception) check allows a listener to determine that the effect is faked.</text>
  <text/>
  <text>Source:	Player's Handbook p. 165</text>
  <modifier category="ability score">Charisma +1</modifier>
</feat>
```

# The FightClub5eXML Github Repository

## [Adding a Source](#fightclub5e-xml)

New material is added to D&D 5e quite frequently, especially through Unearthed Arcana which is typically used for beta testing. Keeping each source in its own file makes it easier to add new content and select which sources you want to include in your Compendium.

Each source is like its own Compendium, and could potentially be imported on its own, with two exceptions (classes and spells) which are explained below. The structure of the XML file should be:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<compendium version="5" auto_indent="NO">
	<!-- Items -->
	<!-- Races -->
	<!-- Classes -->
	<!-- Feats -->
	<!-- Backgrounds -->
	<!-- Spells -->
	<!-- Monsters -->
</compendium>
```

Add the specific elements under the appropriate comment (e.g. `<item>...</item>` goes under `<!-- Items -->`). See the Fight Club Import Tutorial for the format of each element, or use our existing sources as a foundation. You can also check out the schema we use for validation in `Utilities/compendium.xsd`.

When merged with other sources (see "Build Your Own Compendium" below), items, races, feats, backgrounds, and monsters are all added to the resulting Compendium. It's recommended that subraces be added as their own race. Classes and spells, however, are merged when their names match, making it easier to add subclasses without modifying existing sources.

For the repository, it's recommended to split the content of the sources into separate files, and put them into a subfolder named after the content you're adding to make them more manageable. The folder and file names may not contain spaces or quotes to be imported, files are tagged with an abbreviation of the content's name.

Example:  
- Tashas_Cauldron_of_Everything
  - bestiary-tce.xml
  - backgrounds-tce.xml
  - class-classname-tce.xml
  - feats-tce.xml
  - items-tce.xml
  - optionalfeatures-tce.xml (Used for special features such as fighting maneuvers, warlock invocations, monk techniques, etc. Usually as level 0 spells.)
  - races-tce.xml
  - spells-phb+tce.xml (Spell lists for subclasses that are merged with PHB content.)
  - spells-tce.xml

### [Subclasses](#fightclub5e-xml)

Adding a subclass in Fight Club is as easy as adding new `<autolevel>` tags to a class. When selecting sources for a Compendium, the merge finds classes with matching `<name>` tags and appends the `<autolevel>` tags to the end.

```xml
<class>
  <name>Barbarian</name>
  <autolevel level="3">
    <feature optional="YES">...</feature>
  </autolevel>
  ...
</class>
```

Because the rest of the class data is not included, this means you would need to include the original source of the class in your Compendium as well.

### [Spells](#fightclub5e-xml)

In the Fight Club compendium, spell lists are defined by the spell, not the class. If you want to add a spell to a class list, you would need to modify the spell's `<classes>` tag. This can be done without modifying the original spell by adding only the name and new class in your source XML. During the Compendium merge, the value of `<classes>` is concatenated to any matching spells.

New source:

```xml
<spell>
  <name>Acid Splash</name>
  <classes>Artificer</classes>
</spell>
```

Resulting merge with original source:

```xml
<spell>
  <name>Acid Splash</name>
  <level>0</level>
  <school>C</school>
  ...
  <classes>Fighter, Rogue, Sorcerer, Wizard, Artificer</classes>
  ...
</spell>
```

Just like classes, the original source would be required in order for the full spell details to appear in the Compendium.

## [Manual Validation](#fightclub5e-xml)

While you add to XML source files, you can manually validate the XML to catch any errors.

You can find an online XML Linter or use xmllint in the command line. The schema files are in the Utilities folder.

Here is an example, running xmllint at the top level of the repo, using the compendium schema to validate an XML file in Sources:

```bash
xmllint --noout --schema Utilities/compendium.xsd Sources/CoreRulebooks.xml
```

## [Build Your Own Compendium](#fightclub5e-xml)

### [Create a collection file](#fightclub5e-xml)

A collection file is an XML file that lists which sources you would like to merge into your custom Compendium. It must follow this format (assuming you create your file within the `Collections` directory):

```xml
<?xml version="1.0" encoding="UTF-8"?>
<collection>
  <doc href="../Sources/WizardsOfTheCoast/01_PlayersHandbook.xml" />
  <doc href="../Sources/WizardsOfTheCoast/02_DungeonMastersGuide.xml" />
  <doc href="../Sources/WizardsOfTheCoast/03_MonsterManual.xml" />
</collection>
```

You can have one or more `<doc>` tags. Each doc must reference an XML file with a `<compendium>` root element.

The name of the collection file will be the name of the final Compendium.

### [Execute the merge](#fightclub5e-xml)

With your collection in place, you're ready to build your Compendium by merging the sources together.

See the instructions to `Compile a Collection Into a Compendium` in the root-level [README](/README.md).
