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
**Symptoms**: Various errors after upgrading
**Common Breaking Changes**:
- `Filament\Forms\Components\Card` → `Filament\Schemas\Components\Section`
- `Filament\Forms\Components\Placeholder` → Prime components
- Table actions API changed to `->recordActions()` and `->toolbarActions()`
- Schema system replaces some form patterns
- Livewire v4 required (lifecycle hook changes)
- Tailwind CSS v4 required

**Solution**:
```bash
# Run the automated upgrade tool
composer require filament/upgrade:"^5.0" -W --dev
vendor/bin/filament-v5
composer require filament/filament:"^5.0" -W --no-update
composer update
composer remove filament/upgrade --dev
```

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
