# Filament v5 Specialist - Claude Code Skill

Expert FilamentPHP v5 assistant for Claude Code. Generates resources, forms, tables, actions, widgets, infolists, schemas, and Pest tests following official Filament v5 documentation patterns.

## Requirements

- PHP 8.2+
- Laravel 11.28+
- FilamentPHP v5.x
- Livewire v4.0+
- Tailwind CSS v4.1+
- Pest testing framework

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

## Commands

| Command | Description |
|---------|-------------|
| `/filament:resource` | Generate a complete CRUD resource |
| `/filament:form` | Create form schemas with fields and validation |
| `/filament:table` | Create table configurations with columns and filters |
| `/filament:action` | Generate actions with modals and logic |
| `/filament:widget` | Create dashboard widgets |
| `/filament:infolist` | Generate read-only data displays |
| `/filament:test` | Generate Pest tests for Filament components |
| `/filament:diagnose` | Diagnose and fix FilamentPHP errors |
| `/filament:docs` | Search official FilamentPHP v5 documentation |
| `/filament:dashboard` | Create dashboard pages with widgets |

## Usage Examples

```
/filament:resource Product --generate --soft-deletes
/filament:form UserRegistration with name, email, password, avatar
/filament:table OrdersTable with status filter and date sorting
/filament:action SendInvoice with email modal
/filament:widget RevenueChart as line chart
/filament:test ProductResource --with-auth
/filament:diagnose "Table columns not showing"
```

## Documentation

Run the `skills/docs/rebuildFilamentDocs.sh` script to populate the `skills/docs/references/` directory with the official FilamentPHP v5 documentation from GitHub.

## Key Changes from Filament v4

- **Schemas package**: New foundational package for building UIs declaratively
- **Livewire v4**: Requires Livewire v4.0+ (was v3 in Filament v4)
- **Tailwind CSS v4**: Requires Tailwind CSS v4.1+ (was v3 in Filament v4)
- **Schema-based components**: Forms and infolists now share the schemas foundation
- **Prime components**: New static content renderers (text, images, buttons)
- **Import/Export actions**: Built-in import and export functionality
- **Code editor field**: New code syntax editor form field
- **Slider field**: New range slider input field
- **Callout schema component**: New callout/alert layout component
- **Enhanced reactivity**: `afterStateUpdatedJs()`, `partiallyRenderComponentsAfterStateUpdated()`
- **Rate limiting**: Built-in action rate limiting
- **Keyboard shortcuts**: Action keyboard bindings support
- **TestAction helper**: New `TestAction::make()` for cleaner testing syntax
