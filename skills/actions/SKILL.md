---
name: actions
description: Generate FilamentPHP v5 actions with modals, CRUD operations, import/export, and business logic
---

# FilamentPHP v5 Actions Skill

## Overview

This skill generates actions for FilamentPHP v5 including page actions, table row actions, bulk actions, modal actions, CRUD actions, and the new import/export actions.

## Documentation Reference

**CRITICAL:** Before generating actions, read:
- `skills/docs/references/actions/`

## Action Types

### Page Header Actions
```php
use Filament\Actions\Action;

protected function getHeaderActions(): array
{
    return [
        Action::make('export')
            ->icon('heroicon-o-arrow-down-tray')
            ->color('gray')
            ->action(fn () => $this->export()),
    ];
}
```

### Table Row Actions
```php
use Filament\Tables\Actions\Action;

->recordActions([
    Action::make('approve')
        ->icon('heroicon-o-check-circle')
        ->color('success')
        ->requiresConfirmation()
        ->action(fn (Model $record) => $record->approve()),
])
```

### Table Bulk Actions
```php
use Filament\Tables\Actions\BulkAction;
use Filament\Tables\Actions\BulkActionGroup;

->toolbarActions([
    BulkActionGroup::make([
        BulkAction::make('export')
            ->icon('heroicon-o-arrow-down-tray')
            ->action(fn (Collection $records) => static::export($records))
            ->deselectRecordsAfterCompletion(),
    ]),
])
```

### Schema/Form Component Actions
```php
use Filament\Schemas\Components\Utilities\Get;
use Filament\Schemas\Components\Utilities\Set;

TextInput::make('title')
    ->afterContent(
        Action::make('generateSlug')
            ->icon('heroicon-o-sparkles')
            ->action(function (Get $schemaGet, Set $schemaSet): void {
                $schemaSet('slug', str($schemaGet('title'))->slug());
            })
    )

// Suffix action
TextInput::make('url')
    ->suffixAction(
        Action::make('visit')
            ->icon('heroicon-o-arrow-top-right-on-square')
            ->url(fn (Get $get) => $get('url'))
            ->openUrlInNewTab()
    )
```

### Infolist Entry Actions (NEW in v5)
```php
use Filament\Infolists\Components\Actions\Action;

TextEntry::make('email')
    ->afterContent(
        Action::make('send_email')
            ->icon('heroicon-o-envelope')
            ->action(fn (Model $record) => /* ... */)
    )
```

## Built-in CRUD Actions

```php
use Filament\Actions\CreateAction;
use Filament\Actions\EditAction;
use Filament\Actions\ViewAction;
use Filament\Actions\DeleteAction;
use Filament\Actions\ForceDeleteAction;
use Filament\Actions\RestoreAction;
use Filament\Actions\ReplicateAction;
```

## Import Action (NEW in v5)

### Generate Importer Class
```bash
php artisan make:filament-import ProductImporter
```

### Importer Class
```php
<?php

declare(strict_types=1);

namespace App\Filament\Imports;

use App\Models\Product;
use Filament\Actions\Imports\ImportColumn;
use Filament\Actions\Imports\Importer;
use Filament\Actions\Imports\Models\Import;

class ProductImporter extends Importer
{
    protected static ?string $model = Product::class;

    public static function getColumns(): array
    {
        return [
            ImportColumn::make('name')
                ->requiredMapping()
                ->rules(['required', 'max:255']),
            ImportColumn::make('sku')
                ->requiredMapping()
                ->rules(['required'])
                ->example('PROD-001'),
            ImportColumn::make('price')
                ->numeric()
                ->rules(['required', 'numeric', 'min:0']),
            ImportColumn::make('description')
                ->rules(['nullable', 'string']),
            ImportColumn::make('category')
                ->relationship(resolveUsing: 'name'),
            ImportColumn::make('is_active')
                ->boolean()
                ->rules(['boolean']),
        ];
    }

    public function resolveRecord(): ?Product
    {
        // Update existing or create new
        return Product::firstOrNew(['sku' => $this->data['sku']]);

        // Always create new
        // return new Product();
    }

    public static function getCompletedNotificationBody(Import $import): string
    {
        $body = 'Your product import has completed. ' . number_format($import->successful_rows) . ' rows imported.';

        if ($failedRowsCount = $import->getFailedRowsCount()) {
            $body .= ' ' . number_format($failedRowsCount) . ' rows failed.';
        }

        return $body;
    }
}
```

### Using Import Action
```php
use Filament\Actions\ImportAction;
use App\Filament\Imports\ProductImporter;

// As page header action
protected function getHeaderActions(): array
{
    return [
        ImportAction::make()
            ->importer(ProductImporter::class),
    ];
}

// As table toolbar action
->toolbarActions([
    Tables\Actions\ImportAction::make()
        ->importer(ProductImporter::class),
])
```

### Import Options
```php
ImportAction::make()
    ->importer(ProductImporter::class)
    ->csvDelimiter(';')          // Custom CSV delimiter
    ->chunkSize(500)             // Rows per chunk (default: 100)
    ->maxRows(10000)             // Maximum rows allowed
    ->job(CustomImportJob::class) // Custom job class
```

## Export Action (NEW in v5)

### Generate Exporter Class
```bash
php artisan make:filament-export ProductExporter
```

### Exporter Class
```php
<?php

declare(strict_types=1);

namespace App\Filament\Exports;

use App\Models\Product;
use Filament\Actions\Exports\ExportColumn;
use Filament\Actions\Exports\Exporter;
use Filament\Actions\Exports\Models\Export;

class ProductExporter extends Exporter
{
    protected static ?string $model = Product::class;

    public static function getColumns(): array
    {
        return [
            ExportColumn::make('name')
                ->label('Product Name'),
            ExportColumn::make('sku'),
            ExportColumn::make('price')
                ->formatStateUsing(fn (int $state): string =>
                    number_format($state / 100, 2)),
            ExportColumn::make('category.name')
                ->label('Category'),
            ExportColumn::make('is_active')
                ->label('Active')
                ->formatStateUsing(fn (bool $state): string =>
                    $state ? 'Yes' : 'No'),
            ExportColumn::make('created_at')
                ->label('Created Date'),
        ];
    }

    public static function getCompletedNotificationBody(Export $export): string
    {
        $body = 'Your product export has completed. ' . number_format($export->successful_rows) . ' rows exported.';

        if ($failedRowsCount = $export->getFailedRowsCount()) {
            $body .= ' ' . number_format($failedRowsCount) . ' rows failed.';
        }

        return $body;
    }
}
```

### Using Export Action
```php
use Filament\Actions\ExportAction;
use App\Filament\Exports\ProductExporter;

// As page header action
protected function getHeaderActions(): array
{
    return [
        ExportAction::make()
            ->exporter(ProductExporter::class),
    ];
}

// As table toolbar action
->toolbarActions([
    Tables\Actions\ExportAction::make()
        ->exporter(ProductExporter::class),
])
```

### Export Options
```php
ExportAction::make()
    ->exporter(ProductExporter::class)
    ->fileName(fn (Export $export): string => "products-{$export->getKey()}")
    ->fileDisk('s3')
    ->modifyQueryUsing(fn (Builder $query) => $query->where('is_active', true))
    ->columnMapping(false) // Disable column selection UI
```

## Modal Configuration

### Confirmation Modal
```php
Action::make('delete')
    ->color('danger')
    ->requiresConfirmation()
    ->modalHeading('Delete record')
    ->modalDescription('Are you sure? This cannot be undone.')
    ->modalSubmitActionLabel('Yes, delete')
    ->modalIcon('heroicon-o-trash')
    ->modalIconColor('danger')
```

### Form Modal
```php
Action::make('send_email')
    ->schema([
        TextInput::make('subject')->required(),
        RichEditor::make('body')->required(),
    ])
    ->action(function (array $data, Model $record): void {
        Mail::to($record->email)->send(new GenericMail($data));
    })
```

### Wizard Modal
```php
Action::make('onboard')
    ->steps([
        Wizard\Step::make('Info')
            ->schema([TextInput::make('name')->required()]),
        Wizard\Step::make('Address')
            ->schema([TextInput::make('city')->required()]),
    ])
    ->action(function (array $data): void { /* ... */ })
```

### Slide-over Modal
```php
Action::make('preview')
    ->slideOver()
    ->schema([...])
```

### Sticky Modal Header/Footer (v4.5+/v5)
```php
Action::make('edit')
    ->schema([/* ... many fields ... */])
    ->stickyModalHeader()  // Header stays visible when scrolling
    ->stickyModalFooter()  // Submit button stays visible when scrolling
```

## Trigger Styles

```php
->button()        // Standard button (default)
->link()          // Text link style
->iconButton()    // Icon-only circular button
->badge()         // Badge style
->outlined()      // Outlined variant
->size(Size::Large)  // Small, Medium, Large
->labeledFrom('md')  // Hide label below breakpoint
```

## Advanced Features

### Rate Limiting (NEW in v5)
```php
Action::make('send')
    ->rateLimit(5)  // 5 per minute
    ->rateLimitedNotificationTitle('Too many attempts!')
```

### Keyboard Shortcuts (NEW in v5)
```php
Action::make('save')
    ->keyBindings(['command+s', 'ctrl+s'])
```

### Client-side JavaScript
```php
Action::make('copy')
    ->actionJs(<<<'JS'
        navigator.clipboard.writeText($get('url'));
    JS)
```

### Authorization
```php
Action::make('edit')
    ->authorize('update')               // Check policy ability
    ->authorizationTooltip()            // Show tooltip when unauthorized
    ->visible(fn () => auth()->user()->can('update', $this->record))

// Custom unauthorized notification (v4.5+/v5)
Action::make('delete')
    ->authorize('delete')
    ->authorizationNotification(
        Notification::make()
            ->title('Cannot delete')
            ->body('You do not have permission to delete this record.')
            ->danger()
    )
```

### Action Grouping
```php
use Filament\Actions\ActionGroup;

// Dropdown menu (default)
ActionGroup::make([
    Action::make('edit'),
    Action::make('delete'),
])
->label('More')
->icon('heroicon-o-ellipsis-vertical')
->color('gray')
->button()

// Button group (no dropdown, side-by-side buttons)
ActionGroup::make([
    Action::make('approve')->color('success'),
    Action::make('reject')->color('danger'),
])
->buttonGroup()

// Dropdown placement
ActionGroup::make([...])
    ->dropdownPlacement('bottom-end') // top, bottom, left, right + -start/-end

// Dividers between items
ActionGroup::make([
    Action::make('edit'),
    Action::make('duplicate'),
    ActionGroup::DIVIDER,
    Action::make('delete')->color('danger'),
])
```

### Nested Action Modals (v4.5+/v5)
```php
// Child modal overlays parent instead of closing it
Action::make('edit')
    ->schema([
        TextInput::make('name'),
        Select::make('category_id')
            ->afterContent(
                Action::make('createCategory')
                    ->schema([
                        TextInput::make('name')->required(),
                    ])
                    ->action(function (array $data, Set $set): void {
                        $category = Category::create($data);
                        $set('category_id', $category->id);
                    })
                    ->overlayParentActions() // Keep parent modal visible behind
            ),
    ])

// Cancel parent actions when child action runs
Action::make('review')
    ->schema([...])
    ->action(function (array $data): void {
        // ...
    })
    ->registerModalActions([
        Action::make('reject')
            ->requiresConfirmation()
            ->action(function (Model $record): void {
                $record->reject();
            })
            ->cancelParentActions() // Close parent modal chain
    ])

// Access parent action data from nested actions via $mountedActions
Action::make('parent')
    ->schema([TextInput::make('name')])
    ->registerModalActions([
        Action::make('child')
            ->action(function (array $mountedActions): void {
                $parentData = $mountedActions[0]->getFormData();
            }),
    ])
```

### After Action Side Effects
```php
Action::make('approve')
    ->action(function (Model $record): void {
        $record->approve();

        // Notification
        Notification::make()
            ->title('Approved successfully')
            ->success()
            ->send();
    })
    ->successRedirectUrl(fn () => route('orders.index'))
    ->after(fn () => $this->refreshFormData(['status']))
```

## Utility Injection

- `$data` - Modal form data
- `$record` - Eloquent model
- `$arguments` - Passed arguments
- `$livewire` - Component instance
- `$action` - Action instance
- `$schemaGet` / `$schemaSet` - Schema field access
- `$schemaOperation` - 'create' | 'edit' | 'view'

## Complete Example

```php
<?php

declare(strict_types=1);

namespace App\Filament\Resources\InvoiceResource\Pages;

use App\Filament\Resources\InvoiceResource;
use App\Mail\InvoiceMail;
use Filament\Actions;
use Filament\Actions\Action;
use Filament\Forms\Components\RichEditor;
use Filament\Forms\Components\TextInput;
use Filament\Notifications\Notification;
use Filament\Resources\Pages\EditRecord;
use Illuminate\Support\Facades\Mail;

class EditInvoice extends EditRecord
{
    protected static string $resource = InvoiceResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Action::make('send_invoice')
                ->icon('heroicon-o-paper-airplane')
                ->color('info')
                ->schema([
                    TextInput::make('email')
                        ->email()
                        ->required()
                        ->default(fn () => $this->record->client->email),
                    TextInput::make('subject')
                        ->required()
                        ->default(fn () => "Invoice #{$this->record->number}"),
                    RichEditor::make('message')
                        ->required()
                        ->default(fn () => view('emails.invoice-default', [
                            'invoice' => $this->record,
                        ])->render()),
                ])
                ->action(function (array $data): void {
                    Mail::to($data['email'])->send(
                        new InvoiceMail($this->record, $data)
                    );

                    $this->record->update(['sent_at' => now()]);

                    Notification::make()
                        ->title('Invoice sent successfully')
                        ->success()
                        ->send();
                })
                ->rateLimit(3)
                ->keyBindings(['command+shift+s']),

            Action::make('mark_paid')
                ->icon('heroicon-o-banknotes')
                ->color('success')
                ->requiresConfirmation()
                ->modalDescription('This will mark the invoice as paid.')
                ->action(fn () => $this->record->markAsPaid())
                ->visible(fn () => ! $this->record->is_paid),

            Action::make('download_pdf')
                ->icon('heroicon-o-arrow-down-tray')
                ->color('gray')
                ->url(fn () => route('invoices.pdf', $this->record))
                ->openUrlInNewTab(),

            Actions\DeleteAction::make(),
        ];
    }
}
```
