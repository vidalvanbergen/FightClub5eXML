[![GitHub release](https://img.shields.io/github/v/release/vidalvanbergen/fightclub5exml)](https://github.com/vidalvanbergen/FightClub5eXML/releases/latest)
[![Last Nightly](https://img.shields.io/github/last-commit/vidalvanbergen/FightClub5eXML?label=last%20nightly)](https://img.shields.io/github/last-commit/vidalvanbergen/fightclub5exml)


# Fight Club 5e XML

Creating XML files for all official D&D sources and unofficial homebrew compatible with Fight Club 5e and Game Master 5e apps for macOS, iOS, and Android.

## How-to Use This Repository

The files listed in this repository as-is are not compatible with Fight Club 5e. They are instead a collection of individual source files that must be compiled together into a "compendium". That resulting compendium can then be imported into and used by Fight Club 5e.

This document makes a distinction between a **compendium** file and a **collection** file. A compendium file is what you ultimately import into Fight Club 5e; it is an XML file that contains all of the source data and is in a format that Fight Club 5e can process. A collection file is the raw source data that exists within this repository, and is not in a format that can be imported into Fight Club 5e. You must first compile a collection file into a compendium file.

This repository contains several collection files which can be found within the `Collections` folder. It's worth opening some of those files and noting the data found within them along with their basic structure. Each of those collection files contain entries that point to raw source data file found within the `Sources` folder.

### Download and Extract the Repository to Your Computer

Click on the green "Code" button towards the top of the page, and then click on the "Download ZIP" button on the subsequent modal popup. Extract the ZIP archive to your `Documents` folder. On Windows, this will be `C:\Users\YOUR_USER_NAME\Documents`; on macOS, this will be `/Users/YOUR_USER_NAME/Documents`.

The location on your computer that you extract this repository to will be referred to as the **repository root** folder. The path to the repository root should be something like `C:\Users\YOUR_USER_NAME\Documents\FightClub5eXML-master` or `/Users/YOUR_USER_NAME/Documents/FightClub5eXML-master`.

### Install `xsltproc`

You will need to install the `xsltproc` program in order to compile a collection into a compendium.

#### Windows

1. Install `chocolatey` by following the [official instructions](https://chocolatey.org/install).
1. Open up PowerShell with administrative privileges, and execute the following: `choco install xsltproc`.

#### macOS

1. Install `homebrew` by following the [official instructions](https://brew.sh/).
1. Open up Terminal and install `libxslt`: `brew install libxslt`.

#### Linux

You should be able to use your distro's official package manager to install either `xsltproc` or `libxslt` if `xsltproc` isn't available as a standalone package.

### Compile a Collection Into a Compendium

Open a command-line terminal (such as PowerShell on Windows or Terminal on macOS) and navigate to the repository root. You can do so by executing `cd C:\Users\YOUR_USER_NAME\Documents\FightClub5eXML-master` on Windows, or `cd /Users/YOUR_USER_NAME/Documents/FightClub5eXML-master` on macOS.

Next, execute the `xsltproc` program to compile a collection file into a compendium file. For example, if you wanted to compile the `WotC_only.xml` collection, you would execute the following command:

```bash
xsltproc --xinclude -o Compendiums/WotC_only.xml Utilities/merge.xslt Collections/WotC_only.xml
```

After that command has completed, you should see a file called `WotC_only.xml` in the newly created `Compendiums` folder. You can then import it into Fight Club 5e.

#### Helper Script and Batching

The build-collection files are provided for your convenience to compile all the collections within your Collections directory into compendiums.

```
Usage: 

collections.sh [-2024] [-h/-?] [collection_names...]
./build-
  -2024   Remove '[2024]' from the generated compendiums.
  collection_names  Optional list of specific collections to compile.
  -h/-?   Display this help message.

If no collection names are provided, all XML files in the 'Collections' directory will be processed.
Examples:
  ./build-collections.sh                Compile all collections.
  ./build-collections.sh -2024          Compile all collections and remove '[2024]'.
  ./build-collections.sh collection1.xml  Compile only 'collection1.xml'.
  ./build-collections.sh -2024 collection1.xml collection2.xml  Compile 'collection1.xml' and 'collection2.xml' and remove '[2024]'.
  ```

For Windows, use `WIN-build-collections.bat  [-2024] [-h/-?] [collection_names...]`.

## Custom Content

See the [Sources README](SOURCES.md) to learn how to add your own homebrew content or build your own compendium from select source material.

## Contributing

If you'd like to contribute, feel free to fork the repository and submit pull requests with your changes. We are no longer accepting manual changes to the XML source files because these files are now generated from an external source.

## Additional Contributors

`@kinkofer` for XML generation systems to allow github collections to be auto generated.

`@felix_mil_` for XML creation tools [https://felixmil.shinyapps.io/compendiumbuildr/](https://felixmil.shinyapps.io/compendiumbuildr/).

`@rrgeorge` and `zamrod` for their JSON to XML scripts.

`@MrFarland` for Artificer Infusions and other XML.

`@fightclub5exml` and `@dragonahcas` for carrying the mantle.

`@zcdziura` for answering user's questions.

`@sheppe` for the Widows bat file.

`@the_archivist` for adding various sources to the compendium.  
(You can find their collection of compendiums on [patreon.com/archivist5](https://patreon.com/archivist5))

`@vidalvanbergen` for adding various sources and maintaining the compendium.

`@recco` for adding various homebrew sources to the compendium.

`@nikjft` for converting legacy content to the 2024 format and adding to the utilities.
