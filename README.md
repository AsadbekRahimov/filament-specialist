# Filament v5 Specialist - Claude Code Skill

Expert FilamentPHP v5 assistant for Claude Code. Generates resources, forms, tables, actions, widgets, infolists, schemas, and Pest tests following official Filament v5 documentation patterns.

## Installation

Add this skill to your Claude Code project or personal skills:

```bash
# As a project skill (in your project root)
git clone <this-repo> .claude/skills/filament-specialist

# Or as a personal skill
git clone <this-repo> ~/.claude/skills/filament-specialist
```

## Requirements

- PHP 8.2+
- Laravel 11.28+
- FilamentPHP v5.x
- Livewire v4.0+
- Tailwind CSS v4.1+
- Pest testing framework

## Skills (Slash Commands)

| Command | Description |
|---------|-------------|
| `/filament-resource` | Generate a complete CRUD resource |
| `/filament-form` | Create form schemas with fields and validation |
| `/filament-table` | Create table configurations with columns and filters |
| `/filament-action` | Generate actions with modals and logic |
| `/filament-widget` | Create dashboard widgets |
| `/filament-infolist` | Generate read-only data displays |
| `/filament-test` | Generate Pest tests for Filament components |
| `/filament-notification` | Create flash, database, and broadcast notifications |
| `/filament-dashboard` | Create dashboard pages with widgets |
| `/filament-docs` | Search official FilamentPHP v5 documentation |
| `/filament-diagnose` | Diagnose and fix FilamentPHP errors |

## Background Knowledge

The `filament-specialist` skill is automatically loaded as background knowledge when Claude detects you're working with FilamentPHP. It provides core principles, v5 patterns, and workflow guidance.

## Usage Examples

```
/filament-resource Product --generate --soft-deletes
/filament-form UserRegistration with name, email, password, avatar
/filament-table OrdersTable with status filter and date sorting
/filament-action SendInvoice with email modal
/filament-widget RevenueChart as line chart
/filament-test ProductResource --with-auth
/filament-diagnose "Table columns not showing"
```

## Structure

```
.claude/skills/
├── filament-resource/SKILL.md      # CRUD resource generation
├── filament-form/SKILL.md          # Form schemas and fields
├── filament-table/SKILL.md         # Table configurations
├── filament-action/SKILL.md        # Actions, modals, import/export
├── filament-widget/SKILL.md        # Dashboard widgets
├── filament-infolist/SKILL.md      # Read-only data displays
├── filament-test/SKILL.md          # Pest test generation
├── filament-notification/SKILL.md  # Notification system
├── filament-dashboard/SKILL.md     # Dashboard pages
├── filament-docs/                  # Documentation search
│   ├── SKILL.md
│   ├── rebuildFilamentDocs.sh      # Populate references from GitHub
│   └── references/                 # Local FilamentPHP v5 docs
├── filament-diagnose/SKILL.md      # Error diagnosis
└── filament-specialist/SKILL.md    # Background knowledge (auto-loaded)
```

## Documentation

Run the `rebuildFilamentDocs.sh` script to populate the documentation references directory with the official FilamentPHP v5 documentation from GitHub:

```bash
bash .claude/skills/filament-docs/rebuildFilamentDocs.sh
```

## Features

- **Documentation Integration**: References official FilamentPHP v5 documentation
- **Resource Generation**: Complete CRUD resources with forms, tables, and relation managers
- **Schema-Based UI**: Leverages the new v5 schema system for forms and infolists
- **Form Builder**: All 20+ field types with validation, reactivity, and utility injection
- **Table Builder**: Columns, filters, actions, summaries, grouping, and custom data
- **Actions**: Modal actions, CRUD actions, import/export, bulk actions, rate limiting
- **Widgets**: Stats overview, charts, tables, and custom widgets
- **Infolists**: Read-only data display with entries and layout components
- **Notifications**: Flash, database, and broadcast notifications
- **Testing**: Comprehensive Pest test generation for all components
- **Diagnosis**: Error identification and troubleshooting

## Filament v5 vs v4

Filament v5 has **no new Filament-specific features** over v4. The major version bump is solely for
**Livewire v4 compatibility**. Features ship to both v4 and v5 in parallel. The features documented
in this skill are available in Filament v4.x (4.5+) and v5.x.

### Key Dependency Changes (v4 -> v5)
- **Livewire v4**: Required (was v3 in Filament v4)
- **Tailwind CSS v4**: Required (was v3 in Filament v4)

### Notable Features (available in both v4.5+ and v5)
- **Schemas package**: Foundational package for building UIs declaratively
- **Import/Export actions**: Built-in import and export functionality
- **Code editor field**: Code syntax editor form field
- **Slider field**: Range slider input field
- **ModalTableSelect**: Pick records from a table modal
- **Flex layout**: Sidebar patterns and flexible layouts
- **FusedGroup**: Visually fused input groups
- **Enhanced reactivity**: `afterStateUpdatedJs()`, `hiddenJs()`, `partiallyRenderComponentsAfterStateUpdated()`
- **Type-safe Get**: `$get->string()`, `$get->integer()`, `$get->float()`, etc.
- **RichEditor enhancements**: JSON storage, merge tags, mentions, floating toolbars, text colors
- **Rate limiting**: Built-in action rate limiting
- **Keyboard shortcuts**: Action keyboard bindings support
- **TestAction helper**: `TestAction::make()` for cleaner testing syntax
- **Clusters**: Hierarchical navigation grouping
- **Resource sub-navigation**: `getRecordSubNavigation()`
- **Dashboard FilterAction**: Modal-based filter alternative
