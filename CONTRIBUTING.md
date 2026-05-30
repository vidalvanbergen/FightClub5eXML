# Contributing to FightClub5eXML

Thanks for helping improve this project.

## Quick Start Workflow

1. Fork the repository and create a feature branch.
2. Make your changes in `Sources/` and/or `Collections/`.
3. Run `xmllint` validation for all touched XML files.
4. Build affected collection(s) as a test.
5. Open a PR and include your validation/build output.

## Before You Start

- Read `README.md` for build basics and `SOURCES.md` for XML structure guidance.
- Keep changes scoped and focused on a specific source, collection, or docs task.
- Treat `Sources/` and `Collections/` as the source of truth.
- Do not manually edit generated outputs in `Compendiums/`.

## Repository Conventions

### Source files (`Sources/`)

- Add new content in source XML files under the appropriate source folder.
- Prefer small, type-specific files when possible (for example `spells-*.xml`, `items-*.xml`, `bestiary-*.xml`).
- Keep naming consistent with existing patterns in that folder.
- Preserve existing formatting style and tag order used nearby.
- Every exported entry should include a source citation line.

### New source placement (`Sources/`)

- Follow the existing hierarchy under `Sources/` (edition/group/source-pack) used by nearby content.
- Place new source directory in the nearest matching directory.
- Name the new source directory according to its source's name, replacing spaces with `_` underscores.
- Prefer type-specific splits for maintainability, such as:
  - `spells-*.xml`
  - `items-*.xml`, `items-base-*.xml`, `items-magic--*.xml`
  - `bestiary-*.xml`
  - `feats-*.xml`
  - `backgrounds-*.xml`
  - `races-*.xml` or `species-*.xml`
  - `class-classname-*.xml`
  - `optionalfeatures-*.xml`
- Avoid large monolithic source files unless there is a clear repository-consistent reason.

### Collection files (`Collections/`)

- Update only the collection files needed for your change.
- Maintain existing include style (`<doc .../>` and/or `<xi:include .../>`) used in the target file.
- Avoid broad rewiring of collection trees unless explicitly required.

## Local Validation (Required)

Run validation for each XML file you touched.

### 1) Validate touched source/compendium XML files

```bash
xmllint --noout --schema Utilities/compendium.xsd <path-to-compendium-xml>
```

### 2) Validate touched collection files (with XInclude)

```bash
xmllint --noout --xinclude --schema Utilities/collection.xsd <path-to-collection-xml>
```

If `xmllint` is not installed, follow the OS-specific setup steps in `README.md` first.

## Building for Testing (Recommended)

Build the changed collection(s) to verify the merge still works.

```bash
./build-collections.sh <collection_name.xml>
```

Or build one collection manually:

```bash
xsltproc --xinclude -o Compendiums/<output>.xml Utilities/merge.xslt Collections/<collection>.xml
```

If `xsltproc` is not installed, follow the OS-specific setup steps in `README.md` first.

## Content Quality Expectations

- Avoid OCR artifacts or flattened formatting when importing from PDFs.
- Keep paragraphs readable; avoid broken line-wrap fragments.
- For subclass content, split features by level using `autolevel` blocks.
- Add the source's name to each added item, include page numbers when available.
- Use source type suffixes in source citations as `(Homebrew)`, `(Indie)`, or `(ThirdParty)`.
- Use short tags in entry names only for features, feats, backgrounds, spells, and subclasses:
  - `(HB)` for homebrew entries
  - `(TP)` for third-party entries
- When adding third party or homebrew classes, use a short source name in the class's name.
- Placement format:
  - Entry name tag goes at the end of the `<name>` value.
  - Source type suffix goes in the source citation text line.
- Examples:
  - Spell name: `Storm Lash (TP)`
  - Feat name: `Arcane Pugilist (HB)`
  - Class name: `Witch (Valda)`
  - Source line: `Source: Tome of Arcane Steel p. 42 (ThirdParty)`
  - Source line: `Source: Kestrel's Field Notes p. 7 (Homebrew)`

## Pull Request Guidelines

Please include:

- A short description of what was changed and why.
- Which files were modified (source files, collection files, docs).
- Validation commands run and their result.
- Build/test command(s) run and result (if applicable).
- Any known limitations, assumptions, or follow-up tasks.

Keep PRs small and reviewable when possible.

## Commit Guidance

- Use clear commit messages that describe intent (not just file lists).
- Group related changes together; avoid mixing unrelated edits.

## Need Help?

- Check nearby files in the same source family for style and structure examples.
- Visit the [Compendium Crucible](https://discord.gg/HSaKtrPHKe) Discord server for more direct help.

Thanks again for contributing.
