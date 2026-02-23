---
name: docs
description: Search and reference official FilamentPHP v5 documentation from local copy
---

# FilamentPHP v5 Documentation Reference Skill

## Overview

This skill searches the local copy of the official FilamentPHP v5 documentation to provide accurate, up-to-date information.

## Documentation Structure

```
references/
├── actions/
│   ├── 01-overview.md
│   ├── 02-modals.md
│   ├── 03-grouping-actions.md
│   ├── 04-create.md
│   ├── 05-edit.md
│   ├── 06-view.md
│   ├── 07-delete.md
│   ├── 08-replicate.md
│   ├── 09-force-delete.md
│   ├── 10-restore.md
│   ├── 11-import.md
│   └── 12-export.md
├── forms/
│   ├── 01-overview.md
│   ├── 02-text-input.md
│   ├── 03-select.md
│   ├── 04-checkbox.md
│   ├── 05-toggle.md
│   ├── 06-checkbox-list.md
│   ├── 07-radio.md
│   ├── 08-date-time-picker.md
│   ├── 09-file-upload.md
│   ├── 10-rich-editor.md
│   ├── 11-markdown-editor.md
│   ├── 12-repeater.md
│   ├── 13-builder.md
│   ├── 14-tags-input.md
│   ├── 15-textarea.md
│   ├── 16-key-value.md
│   ├── 17-color-picker.md
│   ├── 18-toggle-buttons.md
│   ├── 19-slider.md
│   ├── 20-code-editor.md
│   ├── 21-hidden.md
│   ├── 22-custom-fields.md
│   └── 23-validation.md
├── general/
│   ├── 01-introduction/
│   │   ├── 01-overview.md
│   │   ├── 02-installation.md
│   │   ├── 03-ai.md
│   │   ├── 04-optimizing-local-development.md
│   │   ├── 05-help.md
│   │   ├── 06-version-support-policy.md
│   │   └── 07-contributing.md
│   ├── 02-getting-started.md
│   ├── 03-resources/
│   │   ├── 01-overview.md
│   │   ├── 02-listing-records.md
│   │   ├── 03-creating-records.md
│   │   ├── 04-editing-records.md
│   │   ├── 05-viewing-records.md
│   │   ├── 06-deleting-records.md
│   │   ├── 07-managing-relationships.md
│   │   ├── 08-nesting.md
│   │   ├── 09-singular.md
│   │   ├── 10-global-search.md
│   │   ├── 11-widgets.md
│   │   ├── 12-custom-pages.md
│   │   └── 13-code-quality-tips.md
│   ├── 05-panel-configuration.md
│   ├── 06-navigation/
│   ├── 07-users/
│   ├── 08-styling/
│   ├── 09-advanced/
│   ├── 10-testing/
│   │   ├── 01-overview.md
│   │   ├── 02-testing-resources.md
│   │   ├── 03-testing-tables.md
│   │   ├── 04-testing-schemas.md
│   │   ├── 05-testing-actions.md
│   │   └── 06-testing-notifications.md
│   ├── 11-plugins/
│   ├── 12-components/
│   ├── 13-deployment.md
│   └── 14-upgrade-guide.md
├── infolists/
├── notifications/
├── schemas/
│   ├── 01-overview.md
│   ├── 02-layouts.md
│   ├── 03-sections.md
│   ├── 04-tabs.md
│   ├── 05-wizards.md
│   ├── 06-callouts.md
│   ├── 07-empty-states.md
│   ├── 08-primes.md
│   └── 09-custom-components.md
├── tables/
│   ├── 01-overview.md
│   ├── 02-columns/
│   ├── 03-filters/
│   ├── 04-actions.md
│   ├── 05-layout.md
│   ├── 06-summaries.md
│   ├── 07-grouping.md
│   ├── 08-empty-state.md
│   └── 09-custom-data.md
└── widgets/
```

## Search Workflow

1. Use `Glob` to find files matching the topic pattern
2. Use `Grep` to search for specific keywords across docs
3. Use `Read` to display relevant documentation sections
4. Summarize findings with code examples

## Topic Mapping

| Query About | Look In |
|-------------|---------|
| Installation | `references/general/01-introduction/02-installation.md` |
| Resources | `references/general/03-resources/` |
| Forms / Fields | `references/forms/` |
| Tables / Columns | `references/tables/` |
| Actions | `references/actions/` |
| Notifications | `references/notifications/` |
| Schemas | `references/schemas/` |
| Widgets | `references/widgets/` |
| Testing | `references/general/10-testing/` |
| Panel Config | `references/general/05-panel-configuration.md` |
| Navigation | `references/general/06-navigation/` |
| Upgrade v4→v5 | `references/general/14-upgrade-guide.md` |
| Import/Export | `references/actions/11-import.md`, `references/actions/12-export.md` |
| Relationships | `references/general/03-resources/07-managing-relationships.md` |
| Deployment | `references/general/13-deployment.md` |
| Plugins | `references/general/11-plugins/` |
| Styling | `references/general/08-styling/` |

## Online Reference

Official Filament v5 documentation: https://filamentphp.com/docs/5.x/introduction/overview
GitHub repository: https://github.com/filamentphp/filament (branch: 5.x)
