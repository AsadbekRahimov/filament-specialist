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

## Resource File Structure (v5)

In Filament v5, `make:filament-resource` generates a more organized file structure with
separate Schema and Table classes:

```
app/Filament/Resources/
└── Customers/
    ├── CustomerResource.php
    ├── Pages/
    │   ├── CreateCustomer.php
    │   ├── EditCustomer.php
    │   └── ListCustomers.php
    ├── Schemas/
    │   └── CustomerForm.php        # Separate form schema class (NEW in v5)
    └── Tables/
        └── CustomersTable.php      # Separate table config class (NEW in v5)
```

### Resource Class

```php
<?php

declare(strict_types=1);

namespace App\Filament\Resources;

use App\Filament\Resources\Customers\Pages;
use App\Filament\Resources\Customers\RelationManagers;
use App\Filament\Resources\Customers\Schemas\CustomerForm;
use App\Filament\Resources\Customers\Tables\CustomersTable;
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
        return CustomerForm::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return CustomersTable::configure($table);
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

### Separate Form Schema Class (NEW in v5)

```php
<?php

declare(strict_types=1);

namespace App\Filament\Resources\Customers\Schemas;

use Filament\Forms\Components\TextInput;
use Filament\Schemas\Schema;

class CustomerForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema->components([
            TextInput::make('name')->required(),
            TextInput::make('email')->email()->required(),
        ]);
    }
}
```

### Separate Table Config Class (NEW in v5)

```php
<?php

declare(strict_types=1);

namespace App\Filament\Resources\Customers\Tables;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class CustomersTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('name'),
                TextColumn::make('email'),
            ])
            ->filters([
                // Filters
            ])
            ->recordActions([
                EditAction::make(),
            ])
            ->toolbarActions([
                BulkActionGroup::make([
                    DeleteBulkAction::make(),
                ]),
            ]);
    }
}
```

### Inline Form/Table (Alternative)

You can also define forms and tables inline in the resource class:

```php
public static function form(Schema $schema): Schema
{
    return $schema->components([
        TextInput::make('name')->required(),
        TextInput::make('email')->email()->required(),
    ]);
}

public static function table(Table $table): Table
{
    return $table
        ->columns([
            TextColumn::make('name'),
            TextColumn::make('email'),
        ])
        ->recordActions([
            EditAction::make(),
        ])
        ->toolbarActions([
            BulkActionGroup::make([
                DeleteBulkAction::make(),
            ]),
        ]);
}
```

### Hiding Fields Based on Operation (v5)

```php
use Filament\Support\Enums\Operation;

TextInput::make('password')
    ->password()
    ->required()
    ->hiddenOn(Operation::Edit)

// Or the inverse:
TextInput::make('password')
    ->password()
    ->required()
    ->visibleOn(Operation::Create)
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
