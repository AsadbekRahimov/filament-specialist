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
TextInput::make('title')
    ->afterContent(
        Action::make('generateSlug')
            ->icon('heroicon-o-sparkles')
            ->action(function (Get $schemaGet, Set $schemaSet): void {
                $schemaSet('slug', str($schemaGet('title'))->slug());
            })
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
```php
use Filament\Actions\ImportAction;
use App\Filament\Imports\ProductImporter;

Action::make('import')
    ->action(ImportAction::make()
        ->importer(ProductImporter::class))
```

## Export Action (NEW in v5)
```php
use Filament\Actions\ExportAction;
use App\Filament\Exports\ProductExporter;

Action::make('export')
    ->action(ExportAction::make()
        ->exporter(ProductExporter::class))
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
    ->authorize('update')
    ->authorizationTooltip()
    ->visible(fn () => auth()->user()->can('update', $this->record))
```

### Action Grouping
```php
use Filament\Actions\ActionGroup;

ActionGroup::make([
    Action::make('edit'),
    Action::make('delete'),
])
->label('More')
->icon('heroicon-o-ellipsis-vertical')
->color('gray')
->button()
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
