---
title: EDM Apple Support
parent: Main Navigation
nav_order: 1
---

# EDM Apple Support

To specify a page order, you can use the `nav_order` parameter in the front matter of the pages.

## Example: using `nav_order`
{: .text-delta }


For Apple support including Apple School Manager (ASM), WorkSpace One (WS1) and Munki (Manaed Software Center) 

email mailto:baz-applesupport@foo.edu

ServiceNow Assignment group:
`ESD - Enterprise Apple Management`


{: .warning }
The order of pages with equal `nav_order` parameters is unstable: it may change with each build.

By default, all Capital letters come before all lowercase letters; you can add `nav_sort: case_insensitive` in the configuration file to ignore the case.[^case-insensitive]

