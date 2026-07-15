# artifact

A small markdown-based publishing system.

This project is my attempt to learn Markdown, Makefiles and whatnot. The build process takes .md files and converts them into .html. Along the way, metadata is extracted to generate archives, indexes, and other lists that can be sorted chronologically or organized in different ways.

This project currently uses Pandoc, GNU Make, and a handful of standar Unix tools.

## Project Structure

```
content/    Source content
scripts/    Build scripts
site/        Generated website
```

## Building

```sh
make
```

The generated site will be written to `site/`.

## Goals

- Learn by building.
- Keep the toolchain understandable.
- Produce clean, semantic HTML.
- Own every part of the publishing process.

## License

MIT