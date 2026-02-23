---
description: Generate a complete FilamentPHP v5 CRUD resource with form, table, pages, and relation managers
allowed-tools: ["Bash", "Glob", "Grep", "Read", "Write", "Edit"]
argument-hint: "<ModelName> [--generate] [--simple] [--soft-deletes] [--view]"
---

# Generate Filament v5 Resource

## Process

1. **Consult Documentation**: Read `skills/docs/references/general/03-resources/`
2. **Analyze Model**: Examine the Eloquent model for fields, relationships, and casts
3. **Generate Base**: Use `php artisan make:filament-resource`
4. **Customize Form**: Build form schema with appropriate fields and validation
5. **Customize Table**: Configure columns, filters, and actions
6. **Add Relations**: Create relation managers for HasMany/BelongsToMany
7. **Add Authorization**: Implement model policies
8. **Generate Tests**: Create Pest tests for all CRUD operations

## Artisan Command

```bash
# Basic resource
php artisan make:filament-resource Customer

# With auto-generated form and table from DB schema
php artisan make:filament-resource Customer --generate

# Simple resource (single page with modals)
php artisan make:filament-resource Customer --simple

# With soft deletes support
php artisan make:filament-resource Customer --soft-deletes

# With view page
php artisan make:filament-resource Customer --view

# Generate model, migration, and factory together
php artisan make:filament-resource Customer --model --migration --factory
```

## Resource Structure (v5)

```php
<?php

declare(strict_types=1);

namespace App\Filament\Resources;

use App\Filament\Resources\CustomerResource\Pages;
use App\Filament\Resources\CustomerResource\RelationManagers;
use App\Models\Customer;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Tables\Table;

class CustomerResource extends Resource
{
    protected static ?string $model = Customer::class;

    protected static ?string $navigationIcon = 'heroicon-o-users';

    protected static ?string $recordTitleAttribute = 'name';

    public static function form(Schema $schema): Schema
    {
        return $schema->components([
            // Form fields defined here or in separate schema class
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                // Table columns
            ])
            ->filters([
                // Filters
            ])
            ->recordActions([
                Tables\Actions\EditAction::make(),
            ])
            ->toolbarActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function getRelations(): array
    {
        return [
            // RelationManagers\OrdersRelationManager::class,
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListCustomers::route('/'),
            'create' => Pages\CreateCustomer::route('/create'),
            'edit' => Pages\EditCustomer::route('/{record}/edit'),
        ];
    }
}
```

## Form Field Reference

| Field Type | Class | Use Case |
|-----------|-------|----------|
| Text | `TextInput::make()` | Names, titles, short text |
| Textarea | `Textarea::make()` | Longer text without formatting |
| Rich Editor | `RichEditor::make()` | Formatted content |
| Select | `Select::make()` | Dropdowns, relationships |
| Checkbox | `Checkbox::make()` | Boolean toggles |
| Toggle | `Toggle::make()` | On/off switches |
| Radio | `Radio::make()` | Single choice from options |
| CheckboxList | `CheckboxList::make()` | Multiple selections |
| DateTimePicker | `DateTimePicker::make()` | Dates and times |
| FileUpload | `FileUpload::make()` | File/image uploads |
| Repeater | `Repeater::make()` | Repeating field groups |
| Builder | `Builder::make()` | Block-based content |
| TagsInput | `TagsInput::make()` | Tag input |
| KeyValue | `KeyValue::make()` | Key-value pairs |
| ColorPicker | `ColorPicker::make()` | Color selection |
| ToggleButtons | `ToggleButtons::make()` | Button-style toggles |
| Slider | `Slider::make()` | Range slider |
| CodeEditor | `CodeEditor::make()` | Code with syntax highlighting |
| Hidden | `Hidden::make()` | Hidden fields |

## Table Column Reference

| Column Type | Class | Use Case |
|------------|-------|----------|
| Text | `TextColumn::make()` | Display text values |
| Icon | `IconColumn::make()` | Boolean/status icons |
| Image | `ImageColumn::make()` | Thumbnails |
| Toggle | `ToggleColumn::make()` | Inline toggle |
| Select | `SelectColumn::make()` | Inline select |
| TextInput | `TextInputColumn::make()` | Inline editing |
| Checkbox | `CheckboxColumn::make()` | Inline checkbox |
| Color | `ColorColumn::make()` | Color swatches |

## Output

Generated files:
1. `app/Filament/Resources/{Model}Resource.php` - Resource class
2. `app/Filament/Resources/{Model}Resource/Pages/` - List, Create, Edit pages
3. `app/Filament/Resources/{Model}Resource/RelationManagers/` - Relation managers (if applicable)
4. `tests/Feature/Filament/{Model}ResourceTest.php` - Pest tests
