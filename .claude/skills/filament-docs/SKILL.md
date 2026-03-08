---
name: filament-docs
description: Search and reference official FilamentPHP v5 documentation from local copy. Use when looking up Filament API details, checking v5 patterns, or finding specific documentation.
allowed-tools: Bash, Glob, Grep, Read
argument-hint: "<topic or keyword to search>"
---

# Search Filament v5 Documentation

## Process

1. **Identify Topic**: Map the user's query to documentation sections
2. **Search References**: Look in the local documentation copy at `${CLAUDE_SKILL_DIR}/references/`
3. **Provide Answer**: Return relevant documentation with code examples

## Documentation Directory Map

| Topic | Directory |
|-------|-----------|
| Overview / Introduction | `references/general/01-introduction/` |
| Getting Started | `references/general/02-getting-started.md` |
| Resources | `references/general/03-resources/` |
| Panel Configuration | `references/general/05-panel-configuration.md` |
| Navigation | `references/general/06-navigation/` |
| Users / Auth | `references/general/07-users/` |
| Styling / Themes | `references/general/08-styling/` |
| Advanced | `references/general/09-advanced/` |
| Testing | `references/general/10-testing/` |
| Plugins | `references/general/11-plugins/` |
| Components | `references/general/12-components/` |
| Deployment | `references/general/13-deployment.md` |
| Upgrade Guide | `references/general/14-upgrade-guide.md` |
| Actions | `references/actions/` |
| Forms / Fields | `references/forms/` |
| Infolists | `references/infolists/` |
| Notifications | `references/notifications/` |
| Schemas | `references/schemas/` |
| Tables | `references/tables/` |
| Widgets | `references/widgets/` |

## Common Lookups

| Looking for... | Check |
|----------------|-------|
| Form fields | `references/forms/` |
| Table columns | `references/tables/02-columns/` |
| Table filters | `references/tables/03-filters/` |
| Validation | `references/forms/23-validation.md` |
| Relations | `references/general/03-resources/07-managing-relationships.md` |
| Testing | `references/general/10-testing/` |
| Actions | `references/actions/01-overview.md` |
| Modals | `references/actions/02-modals.md` |
| Import/Export | `references/actions/11-import.md`, `references/actions/12-export.md` |
| Notifications | `references/notifications/` |
| Schema layouts | `references/schemas/` |
| Panel config | `references/general/05-panel-configuration.md` |
| Custom pages | `references/general/06-navigation/` |
| Widgets | `references/widgets/` |
| Upgrade v4->v5 | `references/general/14-upgrade-guide.md` |

## Search Workflow

1. Use `Glob` to find files matching the topic
2. Use `Grep` to search for specific keywords
3. Use `Read` to display relevant documentation sections
4. Summarize findings for the user

## Online Documentation

Official Filament v5 documentation: https://filamentphp.com/docs/5.x/introduction/overview
