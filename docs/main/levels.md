---
title: Page Levels
parent: Main Documentation
nav_order: 3
---

# Page Levels

Sometimes you will want to create a page with many children. First, it is recommended that you store related pages together in a directory. For example, in these docs, we keep all of the written documentation pages in the `./docs` directory, and each of the sections in subdirectories like `./docs/ui-components` and `./docs/utilities`. This gives us an organization like this:

{: .lh-0 }
```
┌─ ...
├─ (Jekyll files)
├─ docs
    ├─ configuration.md
    ├─ ui-components
        ├─ index.md (parent page)
        ├─ buttons.md
        ├─ callouts.md
        ├─ code
            ├─ index.md (parent page)
            └─ line-numbers.md
        ├─ labels.md
        ├─ tables.md
        └─ typography.md
    ├─ ...
    └─ MIGRATION.md
├─ index.md (home page)
├─ (Jekyll files)
└─ ...
```