# Generate Filament v5 Resource

## Process

1. **Consult Documentation**: Read `${CLAUDE_SKILL_DIR}/docs/references/general/03-resources/`
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

use Filament\Tables\Actions\BulkActionGroup;
use Filament\Tables\Actions\DeleteBulkAction;
use Filament\Tables\Actions\EditAction;
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

## Form Schema: Field Type Mapping

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

## Table: Column Type Mapping

| Display Need | Column Type |
|-------------|-------------|
| Text values | `TextColumn::make()` |
| Boolean/status | `IconColumn::make()->boolean()` |
| Images | `ImageColumn::make()` |
| Inline toggle | `ToggleColumn::make()` |
| Inline edit | `TextInputColumn::make()` or `SelectColumn::make()` |
| Colors | `ColorColumn::make()` |

## Relation Managers

```bash
php artisan make:filament-relation-manager ResourceName relationName titleAttribute
```

## Authorization

Create a policy and register it. Filament respects standard Laravel policy methods:
- `viewAny()`, `view()`, `create()`, `update()`, `delete()`
- `forceDelete()`, `restore()` (for soft deletes)

```bash
php artisan make:policy ProductPolicy --model=Product
```

```php
<?php

declare(strict_types=1);

namespace App\Policies;

use App\Models\Product;
use App\Models\User;

class ProductPolicy
{
    public function viewAny(User $user): bool
    {
        return $user->hasPermissionTo('view products');
    }

    public function view(User $user, Product $product): bool
    {
        return $user->hasPermissionTo('view products');
    }

    public function create(User $user): bool
    {
        return $user->hasPermissionTo('create products');
    }

    public function update(User $user, Product $product): bool
    {
        return $user->hasPermissionTo('edit products');
    }

    public function delete(User $user, Product $product): bool
    {
        return $user->hasPermissionTo('delete products');
    }
}
```

Enable strict authorization in the panel to throw exceptions for missing policies:
```php
$panel->strictAuthorization()
```

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

## Multi-Tenancy

### Scoping Resources to Tenant
```php
// Option 1: Automatic scoping via BelongsToTenant trait on model
use Filament\Models\Concerns\BelongsToTenant;

class Product extends Model
{
    use BelongsToTenant;
}

// Option 2: Manual query scoping in resource
public static function getEloquentQuery(): Builder
{
    return parent::getEloquentQuery()
        ->whereBelongsTo(Filament::getTenant());
}
```

### Automatically Set Tenant on Create
```php
// In CreateRecord page
protected function mutateFormDataBeforeCreate(array $data): array
{
    $data['team_id'] = Filament::getTenant()->id;
    return $data;
}
```

## Nested Resources

```bash
php artisan make:filament-resource Product --parent=CategoryResource
```

Nested resources display within a parent resource, e.g., `/categories/{category}/products`.

## Singular Resources

For models with only one record (e.g., settings):

```bash
php artisan make:filament-resource Settings --singular
```

## Global Search Configuration

```php
protected static ?string $recordTitleAttribute = 'name';

public static function getGloballySearchableAttributes(): array
{
    return ['name', 'sku', 'description', 'category.name'];
}

public static function getGlobalSearchResultDetails(Model $record): array
{
    return [
        'Category' => $record->category->name,
        'Price' => '$' . number_format($record->price / 100, 2),
    ];
}

public static function getGlobalSearchResultTitle(Model $record): string
{
    return "{$record->name} ({$record->sku})";
}

public static function getGlobalSearchResultUrl(Model $record): string
{
    return static::getUrl('edit', ['record' => $record]);
}

protected static int $globalSearchResultsLimit = 10;

public static function getGlobalSearchEloquentQuery(): Builder
{
    return parent::getGlobalSearchEloquentQuery()->with(['category']);
}
```

## Output

Generated files:
1. `app/Filament/Resources/{Model}Resource.php` - Resource class
2. `app/Filament/Resources/{Model}Resource/Pages/` - List, Create, Edit pages
3. `app/Filament/Resources/{Model}Resource/RelationManagers/` - Relation managers (if applicable)
4. `tests/Feature/Filament/{Model}ResourceTest.php` - Pest tests
