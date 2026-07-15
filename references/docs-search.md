# Search Filament v5 Documentation

## Process

1. **Identify Topic**: Map the user's query to documentation sections
2. **Search References**: Look in the local documentation copy at `${CLAUDE_SKILL_DIR}/docs/references/`
3. **Provide Answer**: Return relevant documentation with code examples

## Documentation Directory Map

Local copies are created by `bash ${CLAUDE_SKILL_DIR}/docs/rebuildFilamentDocs.sh`:
the main `docs/` folder becomes `general/`, each package's docs keep the package name.

| Topic | Directory |
|-------|-----------|
| Overview / Introduction / AI tooling | `references/general/01-introduction/` |
| Getting Started | `references/general/02-getting-started.md` |
| Resources | `references/general/03-resources/` |
| Panel Configuration | `references/general/05-panel-configuration.md` |
| Navigation / Custom Pages / Clusters | `references/general/06-navigation/` |
| Users / Auth / MFA / Tenancy | `references/general/07-users/` |
| Styling / Themes | `references/general/08-styling/` |
| Advanced (render hooks, assets, enums, security) | `references/general/09-advanced/` |
| Testing | `references/general/10-testing/` |
| Plugins | `references/general/11-plugins/` |
| Components (standalone usage) | `references/general/12-components/` |
| Deployment | `references/general/13-deployment.md` |
| Upgrade Guide (v4 → v5) | `references/general/14-upgrade-guide.md` |
| Actions | `references/actions/` |
| Forms / Fields | `references/forms/` |
| Infolists | `references/infolists/` |
| Notifications | `references/notifications/` |
| Schemas (layouts, sections, tabs, wizards) | `references/schemas/` |
| Tables | `references/tables/` |
| Widgets & Dashboards | `references/widgets/` |
| Query Builder | `references/query-builder/` |
| Support (enums, colors, icons) | `references/support/` |

## Common Lookups

| Looking for... | Check |
|----------------|-------|
| Form fields | `references/forms/` (one file per field, e.g. `03-select.md`) |
| Validation | `references/forms/23-validation.md` |
| Table columns | `references/tables/02-columns/` |
| Table filters | `references/tables/03-filters/` |
| Table actions | `references/tables/04-actions.md` |
| Table layout / responsive | `references/tables/05-layout.md` |
| Summaries / Grouping | `references/tables/06-summaries.md`, `07-grouping.md` |
| Relations | `references/general/03-resources/07-managing-relationships.md` |
| Nested / singular resources | `references/general/03-resources/08-nesting.md`, `09-singular.md` |
| Global search | `references/general/03-resources/10-global-search.md` |
| Testing | `references/general/10-testing/` |
| Actions overview | `references/actions/01-overview.md` |
| Modals | `references/actions/02-modals.md` |
| Import/Export | `references/actions/11-import.md`, `references/actions/12-export.md` |
| Notifications | `references/notifications/` |
| Schema layouts (Grid, Flex, Section) | `references/schemas/02-layouts.md`, `03-sections.md` |
| Tabs / Wizards | `references/schemas/04-tabs.md`, `05-wizards.md` |
| Panel config | `references/general/05-panel-configuration.md` |
| Custom pages | `references/general/06-navigation/02-custom-pages.md` |
| Clusters | `references/general/06-navigation/04-clusters.md` |
| Multi-tenancy | `references/general/07-users/03-tenancy.md` |
| Widgets / Charts / Stats | `references/widgets/` |
| Upgrade v4 -> v5 | `references/general/14-upgrade-guide.md` |

## Search Workflow

1. Use `Glob` to find files matching the topic
2. Use `Grep` to search for specific keywords
3. Use `Read` to display relevant documentation sections
4. Summarize findings for the user

## Online Documentation

Official Filament v5 documentation: https://filamentphp.com/docs/5.x/introduction/overview
