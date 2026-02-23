---
description: Diagnose and fix common FilamentPHP v5 errors and issues
allowed-tools: ["Bash", "Glob", "Grep", "Read", "Write", "Edit"]
argument-hint: "<error message or description of the issue>"
---

# Diagnose FilamentPHP v5 Issues

## Process

1. **Identify the Error**: Parse the error message or issue description
2. **Check Common Issues**: Cross-reference with known Filament v5 issues
3. **Consult Documentation**: Read relevant v5 documentation
4. **Provide Solution**: Fix with code changes or configuration adjustments
5. **Log Solution**: Document the fix for future reference

## Diagnostic Methodology

### Step 1: Error Classification
- PHP Fatal/Syntax Error
- Livewire/Alpine.js Error
- Filament Configuration Error
- Database/Migration Error
- Authorization/Policy Error
- Asset/Styling Error

### Step 2: Information Gathering
- Read the full error stack trace
- Check the relevant resource/page class
- Verify model relationships
- Check panel provider configuration
- Verify Filament version compatibility

### Step 3: Apply Fix
- Make targeted code changes
- Clear caches if needed
- Rebuild assets if needed

## Common Issues and Solutions

### 1. Resource Not Appearing in Navigation
**Symptoms**: Resource exists but doesn't show in sidebar
**Causes**:
- Resource not discovered (wrong namespace)
- Authorization prevents viewing (`viewAny` policy method)
- Resource hidden via `$shouldRegisterNavigation = false`
- Wrong panel provider

**Solution**:
```php
// Check namespace matches panel discovery
// app/Filament/Resources/ for default admin panel

// Check policy
public function viewAny(User $user): bool
{
    return true; // Or appropriate authorization
}

// Verify panel provider discoverResources path
->discoverResources(
    in: app_path('Filament/Resources'),
    for: 'App\\Filament\\Resources'
)
```

### 2. Form Fields Not Saving
**Symptoms**: Form submits but data not persisted
**Causes**:
- Field name doesn't match database column
- Field marked as `dehydrated(false)`
- Missing `$fillable` on model
- Relationship not configured properly

**Solution**:
```php
// Ensure model has fillable
protected $fillable = ['name', 'email', 'status'];

// Or use guarded
protected $guarded = [];

// Check field name matches column
TextInput::make('name') // Must match DB column
```

### 3. Table Columns Not Displaying
**Symptoms**: Table renders but columns are empty
**Causes**:
- Column name doesn't match model attribute
- Relationship not loaded
- Accessor not defined
- Column hidden by default

**Solution**:
```php
// Use dot notation for relationships
TextColumn::make('author.name')

// Ensure relationship exists on model
public function author(): BelongsTo
{
    return $this->belongsTo(User::class, 'author_id');
}
```

### 4. Livewire Component Not Found
**Symptoms**: `Unable to find component` or similar error
**Causes**:
- Class not autoloaded
- Cache stale
- Wrong namespace

**Solution**:
```bash
php artisan filament:cache-components
# or
php artisan cache:clear
php artisan view:clear
composer dump-autoload
```

### 5. Actions Not Working
**Symptoms**: Action button visible but nothing happens on click
**Causes**:
- Missing `action()` callback
- Action halted without reason
- JavaScript error in browser
- Rate limit exceeded

**Solution**:
```php
// Ensure action has handler
Action::make('approve')
    ->action(function (Model $record): void {
        $record->update(['status' => 'approved']);

        Notification::make()
            ->title('Approved')
            ->success()
            ->send();
    })
```

### 6. Validation Not Triggering
**Symptoms**: Form submits without validation
**Causes**:
- Validation rules not set on fields
- Wrong method called (e.g., `call('save')` vs `call('create')`)
- Field not in form schema

**Solution**:
```php
TextInput::make('title')
    ->required()
    ->maxLength(255)
    ->unique(ignoreRecord: true)
```

### 7. Upgrade v4 to v5 Issues
**Context**: Filament v5 has NO new Filament-specific features over v4. The major version bump is
solely for Livewire v4 compatibility. Features continue to ship to both v4 and v5 in parallel.

**Symptoms**: Various errors after upgrading
**Key Breaking Changes**:
- Livewire v4 required (lifecycle hook changes, `wire:model` behavior change)
- Tailwind CSS v4 required (biggest hurdle for custom themes)
- `wire:model` no longer responds to events bubbling from child elements (add `.deep` if needed)
- Component tags must be self-closing: `<livewire:component />` (not `<livewire:component>`)
- Config keys renamed: `layout` → `component_layout`
- `wire:transition` now uses View Transitions API (`.opacity` / `.duration` modifiers removed)

**Solution**:
```bash
# Step 1: Run the automated upgrade tool
composer require filament/upgrade:"^5.0" -W --dev
vendor/bin/filament-v5

# Step 2: Update filament dependency
composer require filament/filament:"^5.0" -W --no-update
composer update

# Step 3: Remove upgrade tool
composer remove filament/upgrade --dev
```

**Notes**:
- If you have custom Livewire components, also follow the Livewire v4 upgrade guide
- Some third-party plugins may not support v5 yet; check compatibility first
- The Filament team pushes features to both v4 and v5, so no rush to upgrade

## Cache Clearing Commands

```bash
php artisan filament:cache-components
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear
php artisan optimize:clear
composer dump-autoload
```

### 8. Multi-Tenancy Issues
**Symptoms**: Resources showing records from all tenants, or "403 Forbidden" errors
**Causes**:
- Tenant not set on model creation
- Missing `BelongsToTenant` trait
- Tenant relationship not defined
- `canAccessTenant()` returning false

**Solution**:
```php
// Option 1: Use trait on model
use Filament\Models\Concerns\BelongsToTenant;

class Product extends Model
{
    use BelongsToTenant;
}

// Option 2: Manually scope in resource
public static function getEloquentQuery(): Builder
{
    return parent::getEloquentQuery()
        ->whereBelongsTo(Filament::getTenant());
}

// Set tenant on creation
protected function mutateFormDataBeforeCreate(array $data): array
{
    $data['team_id'] = Filament::getTenant()->id;
    return $data;
}
```

### 9. Assets Not Loading / Styles Broken
**Symptoms**: Filament pages appear unstyled or JavaScript not working
**Causes**:
- Assets not published
- Tailwind CSS v4 conflict with custom theme
- Vite not configured correctly

**Solution**:
```bash
# Publish and rebuild assets
php artisan filament:assets
npm run build

# If using custom theme, ensure Tailwind v4 compatible
# Check vite.config.js includes Filament plugin
```

### 10. Relation Manager Not Showing
**Symptoms**: Relation manager tab/section missing from edit/view page
**Causes**:
- Not registered in resource `getRelations()`
- Relationship doesn't exist on model
- Authorization prevents viewing

**Solution**:
```php
// Register in resource
public static function getRelations(): array
{
    return [
        RelationManagers\OrdersRelationManager::class,
    ];
}

// Ensure relationship exists on model
public function orders(): HasMany
{
    return $this->hasMany(Order::class);
}
```

### 11. Custom Page Not Routing
**Symptoms**: Custom page returns 404
**Causes**:
- Not registered in resource `getPages()`
- Route slug conflict
- Missing route cache clear

**Solution**:
```php
public static function getPages(): array
{
    return [
        'index' => Pages\ListCustomers::route('/'),
        'create' => Pages\CreateCustomer::route('/create'),
        'edit' => Pages\EditCustomer::route('/{record}/edit'),
        'activity' => Pages\CustomerActivity::route('/{record}/activity'),
    ];
}
```
```bash
php artisan route:clear
```

## Debug Checklist

1. Check PHP version (8.2+ required)
2. Check Laravel version (11.28+ required)
3. Check Filament version (`composer show filament/filament`)
4. Check Livewire version (v4.0+ required)
5. Verify panel provider is registered in `config/app.php`
6. Check file permissions
7. Clear all caches
8. Check browser console for JS errors
9. Check Laravel log (`storage/logs/laravel.log`)
10. Verify database migrations are up to date
