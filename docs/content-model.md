[GENERATED - REWRITE LATER]

# Entry

An Entry is the fundamental unit of content in Artifact.

Every published object is an Entry.

Examples include:

- Note
- Essay
- Photograph
- Book
- Log

An Entry consists of two parts:

- Metadata
- Body

Metadata describes the Entry.

The Body contains the actual content.

Artifact treats every Entry uniformly regardless of its Category or Type.

## Metadata

The filesystem is convenience. Metadata is authoritative.

```
            Explicit metadata
                  ▲
                  │
         Project defaults
                  ▲
                  │
      Filesystem conventions
                  ▲
                  │
        Built-in defaults
```

### Requiered

```
title:
date:
category:
type:
```

## Optional

```
author:
summary:
tags:
status:
updated:
slug:
```
