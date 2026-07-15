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

# Embed form/table in the resource class instead of separate files
php artisan make:filament-resource Customer --embed-schemas --embed-table

# Nested resource (scoped inside a parent resource via a relationship)
php artisan make:filament-resource Lesson --nested
```

## Resource File Structure (v5)

In Filament v5, `make:filament-resource` generates an organized file structure with
separate Schema and Table classes. Note the resource directory is part of the namespace:

```
app/Filament/Resources/
└── Customers/
    ├── CustomerResource.php        # App\Filament\Resources\Customers
    ├── Pages/
    │   ├── CreateCustomer.php      # App\Filament\Resources\Customers\Pages
    │   ├── EditCustomer.php
    │   └── ListCustomers.php
    ├── Schemas/
    │   └── CustomerForm.php        # App\Filament\Resources\Customers\Schemas
    └── Tables/
        └── CustomersTable.php      # App\Filament\Resources\Customers\Tables
```

### Resource Class

```php
<?php

declare(strict_types=1);

namespace App\Filament\Resources\Customers;

use App\Filament\Resources\Customers\Pages;
use App\Filament\Resources\Customers\RelationManagers;
use App\Filament\Resources\Customers\Schemas\CustomerForm;
use App\Filament\Resources\Customers\Tables\CustomersTable;
use App\Models\Customer;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Tables\Table;

class CustomerResource extends Resource
{
    protected static ?string $model = Customer::class;

    protected static BackedEnum|string|null $navigationIcon = 'heroicon-o-users';

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

### Separate Form Schema Class

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

### Separate Table Config Class

**CRITICAL**: All action classes are in the unified `Filament\Actions` namespace.
`Filament\Tables\Actions\*` does NOT exist in v5.

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
| date | `DatePicker::make()` |
| datetime/timestamp | `DateTimePicker::make()` |
| enum | `Select::make()->options([...])` |
| json (array) | `Repeater::make()` or `KeyValue::make()` |
| json (blocks) | `Builder::make()` |
| foreign key | `Select::make()->relationship()` |

Organize form fields with layout components (Section, Grid, Tabs) from
`Filament\Schemas\Components` for well-structured forms.

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

```php
use Filament\Schemas\Schema;

// Note: relation manager form() is an INSTANCE method (not static)
public function form(Schema $schema): Schema
{
    return $schema->components([...]);
}
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
use BackedEnum;
use UnitEnum;

// Navigation
protected static BackedEnum|string|null $navigationIcon = 'heroicon-o-rectangle-stack';
protected static ?string $navigationLabel = 'Products';
protected static string|UnitEnum|null $navigationGroup = 'Shop';
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

## Listing Page Tabs

**Note**: List page tabs use the Schema `Tab` class (NOT `Filament\Resources\Components\Tab`).

```php
use Filament\Schemas\Components\Tabs\Tab;
use Illuminate\Database\Eloquent\Builder;

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

## Record Sub-Navigation

```php
use Filament\Pages\Enums\SubNavigationPosition;
use Filament\Resources\Pages\Page;

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

## Clusters

Group resources under a cluster for hierarchical navigation:

```bash
php artisan make:filament-cluster Settings
```

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
use Filament\Actions\Action;
use Filament\Notifications\Notification;
use Filament\Resources\Pages\EditRecord;
use Filament\Schemas\Components\Section;

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

**IMPORTANT**: Filament does NOT ship a `BelongsToTenant` model trait. Do not invent one.

### Automatic Scoping
Once tenancy is configured on the panel, Filament **automatically scopes all resource
queries** to the current tenant using the ownership relationship:

```php
$panel
    ->tenant(Team::class)
    // Custom ownership relationship name (default is derived from tenant model):
    // ->tenant(Team::class, ownershipRelationship: 'owner')
    // ->tenant(Team::class, slugAttribute: 'slug')
    ->tenantRegistration(RegisterTeam::class);
```

New records created through resources automatically get associated with the current tenant.

### Scoping Non-Resource Queries
For models used outside resources (e.g. in widgets or custom pages), apply a global
scope via middleware:

```php
use Filament\Facades\Filament;
use Illuminate\Database\Eloquent\Builder;

class ApplyTenantScopes
{
    public function handle(Request $request, Closure $next): mixed
    {
        Author::addGlobalScope(
            fn (Builder $query) => $query->whereBelongsTo(Filament::getTenant()),
        );

        return $next($request);
    }
}
```

### Opting a Resource Out of Tenant Scoping
```php
use Filament\Resources\Resource;

// In a service provider's boot() method:
Resource::scopeToTenant(false);
```

## Nested Resources

```bash
php artisan make:filament-resource Lesson --nested
```

Nested resources display within a parent resource's relation manager or relation page,
e.g., `/courses/{course}/lessons/{lesson}`. They require a relation manager or relation
page on the parent resource to be accessible.

## Singular Resources

There is no built-in "singular resource" flag. For single-record pages (settings,
homepage, profile), create a custom page with a form:

```bash
php artisan make:filament-page ManageHomepage
```

The page class should contain:
- A public `?array $data = []` property bound via `statePath('data')`
- A `mount()` method that loads the record and fills the form
- A `form(Schema $schema): Schema` method defining the schema
- A `save()` method that validates via `getState()` and creates/updates the record

For app settings, prefer the official Spatie Settings plugin
(`filament/spatie-laravel-settings-plugin`).

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
1. `app/Filament/Resources/{Model}s/{Model}Resource.php` - Resource class
2. `app/Filament/Resources/{Model}s/Pages/` - List, Create, Edit pages
3. `app/Filament/Resources/{Model}s/Schemas/` - Form schema class
4. `app/Filament/Resources/{Model}s/Tables/` - Table config class
5. `app/Filament/Resources/{Model}s/RelationManagers/` - Relation managers (if applicable)
6. `tests/Feature/Filament/{Model}ResourceTest.php` - Pest tests
