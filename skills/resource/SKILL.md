---
name: resource
description: Generate complete FilamentPHP v5 CRUD resources following official documentation patterns
---

# FilamentPHP v5 Resource Generation Skill

## Overview

This skill generates complete CRUD resources for FilamentPHP v5 including the resource class, form schema, table configuration, pages, relation managers, and tests.

## Documentation Reference

**CRITICAL:** Before generating resources, read:
- `skills/docs/references/general/03-resources/`

## Workflow

### Step 1: Gather Requirements
- Model name and namespace
- Database fields and types
- Relationships (HasMany, BelongsTo, BelongsToMany, etc.)
- Authorization requirements
- Soft deletes needed?
- View page needed?

### Step 2: Generate Base Resource
```bash
php artisan make:filament-resource ModelName [--generate] [--simple] [--soft-deletes] [--view]
```

### Step 3: Customize Form Schema

Map database columns to appropriate Filament field types:

| DB Type | Filament Field |
|---------|---------------|
| varchar/string | `TextInput::make()` |
| text/longtext | `Textarea::make()` or `RichEditor::make()` |
| boolean/tinyint | `Toggle::make()` or `Checkbox::make()` |
| integer/bigint | `TextInput::make()->numeric()` |
| decimal/float | `TextInput::make()->numeric()` |
| date | `DateTimePicker::make()` |
| datetime/timestamp | `DateTimePicker::make()` |
| enum | `Select::make()->options([...])` |
| json (array) | `Repeater::make()` or `KeyValue::make()` |
| json (blocks) | `Builder::make()` |
| foreign key | `Select::make()->relationship()` |

**CRITICAL**: All form fields MUST be wrapped in layout components (Section, Grid, Tabs). Never place fields at the root level.

### Step 4: Customize Table

Map fields to column types:

| Display Need | Column Type |
|-------------|-------------|
| Text values | `TextColumn::make()` |
| Boolean/status | `IconColumn::make()->boolean()` |
| Images | `ImageColumn::make()` |
| Inline toggle | `ToggleColumn::make()` |
| Inline edit | `TextInputColumn::make()` or `SelectColumn::make()` |
| Colors | `ColorColumn::make()` |

### Step 5: Add Relation Managers
```bash
php artisan make:filament-relation-manager ResourceName relationName titleAttribute
```

### Step 6: Configure Pages

Standard pages: List, Create, Edit
Optional pages: View, ManageRelatedRecords

### Step 7: Add Authorization

Create a policy and register it. Filament respects standard Laravel policy methods:
- `viewAny()`, `view()`, `create()`, `update()`, `delete()`
- `forceDelete()`, `restore()` (for soft deletes)

## Resource Configuration Options

```php
// Navigation
protected static ?string $navigationIcon = 'heroicon-o-rectangle-stack';
protected static ?string $navigationLabel = 'Products';
protected static ?string $navigationGroup = 'Shop';
protected static ?int $navigationSort = 1;
protected static ?string $navigationParentItem = 'Products';

// Model labels
protected static ?string $modelLabel = 'product';
protected static ?string $pluralModelLabel = 'products';

// Record title (for global search)
protected static ?string $recordTitleAttribute = 'name';

// Global search
protected static ?string $recordTitleAttribute = 'name';
public static function getGloballySearchableAttributes(): array
{
    return ['name', 'sku', 'description'];
}

// Query customization
public static function getEloquentQuery(): Builder
{
    return parent::getEloquentQuery()
        ->withoutGlobalScopes([SoftDeletingScope::class]);
}
```

## Listing Page Tabs (NEW in v5)

```php
use Filament\Resources\Pages\ListRecords\Tab;

public function getTabs(): array
{
    return [
        'all' => Tab::make(),
        'active' => Tab::make()
            ->modifyQueryUsing(fn (Builder $query) => $query->where('active', true))
            ->badge(Customer::query()->where('active', true)->count())
            ->badgeColor('success'),
        'inactive' => Tab::make()
            ->modifyQueryUsing(fn (Builder $query) => $query->where('active', false)),
    ];
}

public function getDefaultActiveTab(): string | int | null
{
    return 'active';
}
```

## Record Sub-Navigation (NEW in v5)

```php
public static function getRecordSubNavigation(Page $page): array
{
    return $page->generateNavigationItems([
        Pages\ViewCustomer::class,
        Pages\EditCustomer::class,
        Pages\ManageCustomerAddresses::class,
    ]);
}

protected static ?SubNavigationPosition $subNavigationPosition = SubNavigationPosition::End;
```

## Clusters (NEW in v5)

Group resources under a cluster for hierarchical navigation:

```php
// In resource class
protected static ?string $cluster = SettingsCluster::class;
```

## Wizard-Based Creation

```php
class CreateCategory extends CreateRecord
{
    use CreateRecord\Concerns\HasWizard;

    protected function getSteps(): array
    {
        return [
            Step::make('Name')->schema([
                TextInput::make('name')->required()->live()
                    ->afterStateUpdated(fn ($state, Set $set) =>
                        $set('slug', Str::slug($state))),
                TextInput::make('slug')->required()->unique(ignoreRecord: true),
            ]),
            Step::make('Details')->schema([
                RichEditor::make('description')->columnSpanFull(),
            ]),
        ];
    }
}
```

## Section-Level Save (Edit Pages)

```php
Section::make('Settings')
    ->schema([...])
    ->footerActions([
        fn (string $operation): Action => Action::make('save')
            ->action(function (Section $component, EditRecord $livewire) {
                $livewire->saveFormComponentOnly($component);
                Notification::make()->title('Saved')->success()->send();
            })
            ->visible($operation === 'edit'),
    ])
```

## Output

Generated files:
1. Resource class with form and table
2. List, Create, Edit page classes
3. Relation managers (if relationships exist)
4. Pest test file
