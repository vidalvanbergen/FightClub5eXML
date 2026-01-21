# Fight Club 5 (FC5) Player Compendium v0.9.1
by @Stuartcmackey

First, I am very thankful to everyone in the subreddit and discord for putting together this amazing system, especailly u/galiphile. Even though it is based on Standard 5e, it truly is a game all it's own.

With that preface, adapting the system to work in the popular Fight Club 5 app has been daunting, but a labor of love. u/toddmoonbounce was very helpful with some Excel techcasting to create much of the XML in a much more automatic process than my manual copy-and-paste method.

This is nearly complete (thus v0.9.1), so I will start with what it does not contain:

  1. Only about 50+ species

  2. No "enhanced" items

  3. It is missing the latest 1 or 2 backgrounds and 1 or 2 archetypes

I wanted to get it out as-is, since I've become much busier.

Here it is: https://drive.google.com/open?id=1-LWtNGzXcetitlAJ2sSt0_U9hN4EGXxI

I am pretty new to 5e and FC5, so I looked at how some of the standard 5e XML was setup and adapted those practices.
What's Included Summary

  * All Classes and all archetype Features' descriptions (with a few tiny exceptions) are included and set as optional or not, as appropriate.

  * Features that grant a single bonus or feature, not a choice, as allowed by Fight Club.

  * All Ability Score Increase levels are set to "YES"

  * Fighting Styles, Discoveries, Maneuvers, etc. are included at each level where you are allowed an additional choice (but not on every level for class features allowed to change every level), usually at the bottom. (with the exception of some features like Discovery (Tactician): Fighting Style)

  * Archetypal and Species Power Variants are included in the Form "Power Name (type)(archetype)*." or "Power Name (Species)*"

  * My attempt to fix obvious typos as best I could, but I mostly just copied-and-pasted.

## What Is Not Included

  * Most noticeably, descriptions for creating your Droid or Beast for archetypes that allow creation of one. This seemed too complicated. I plan to create either monsters or Classes for them in the future, I'm not sure which will work better.

  * Spell Slots.

  * Features that don't have a way to be setup in advance, such as choosing your proficiencies.

  * Engineer's Modifications. Since there are so many there isn't really a way to implement them in the app. I plan on creating Species and Classes for droid companions, however.

  * Most of the "flavor text" from Classes and Species is not included.

## Adaptations

Below are the modifications and recommended work-arounds for getting your Star Wars 5e characters created with Fight Club 5.
Skills

The first thing worth noting is that there is no way to change the names of the standard built-in 5e skills in Fight Club. But to help with your math, and since it worked, I chose to remap 3 of the Star Wars 5e skills to a different 5e skill as follows (with my logic/way-to-remmeber):

  * History = Lore (seemed pretty obvious)

  * Arcana = Technology (Arcana is Magic, any sufficiently advanced technology is... well, you know)

  * Religion = Piloting (How many pilots have said "I pray this works!"?)

Where ever these skills are mentioned, I have written them with the converted skill in parenthesis like this: Lore* (History), etc.
Force- and Tech-casting
Powers

All PHB force and tech powers are in the XML file and more or less work as you'd expect, complete with the appropriate die rolls. Where powers "level up," the die rolls for spells at all levels are included.

Since a handful of powers have the same name as their 5e counterpart (such as Acid Splash), all powers' names are appended. Force Powers are appended (alignment force) and tech powers (tech).

I considered making things like Gunslinger tricks, etc. as "spells" but instead included them as features. (If anyone thinks that might work better, I am open to suggestions)
Class Features

All classes and class features from the PHB and EC are available as of the completion of this document. All Ability Score Improvements that normally happen at Level 4, 8, etc. are set to "YES" when you level up. All Class Features that level up at multiple levels are also listed at those levels, renamed and reworded as appropriate (i.e. At 7th Level, Operatives have a feature named "Sneak Attack (4d6)" and the wording is adjusted accordingly). Lots of the class features that would show in the Class Table are included as features as well, such as Superiority Die Increases and Maneuvers Known, but not traits that change every level, such as powers known, or traits you can swap out every level, like maneuvers, etc. I strongly encourage you to have a printout or the website open when creating a character or leveling up. Some classes have a lot of choices!

As explained above, most classes that have Archetypes that can be either Force- or Tech-casters have their ability default to WIS. But is can be changed per the instructions below. Engineers and Scouts are the exception and are set to INT.

Here is a longer version fo the readme: https://drive.google.com/open?id=13vgorr21wFS_KHnjHJ5BFcT5Uf_uTf-Odqhy7RB1ygA
