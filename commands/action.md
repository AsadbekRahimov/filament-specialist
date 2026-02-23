---
description: Generate FilamentPHP v5 actions with modals, forms, confirmations, and business logic
allowed-tools: ["Bash", "Glob", "Grep", "Read", "Write", "Edit"]
argument-hint: "<ActionName> [with modal] [with form] [with confirmation]"
---

# Generate Filament v5 Action

## Process

1. **Consult Documentation**: Read `skills/docs/references/actions/`
2. **Determine Action Type**: Page action, table row action, bulk action, or header action
3. **Configure Trigger**: Button style, icon, color, label
4. **Add Modal**: Confirmation dialog, form data collection, or wizard
5. **Implement Logic**: Action handler with proper utility injection
6. **Add Authorization**: Visibility and policy-based access control

## Action Types

### Page Actions
```php
use Filament\Actions\Action;

protected function getHeaderActions(): array
{
    return [
        Action::make('export')
            ->icon('heroicon-o-arrow-down-tray')
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
        ->action(fn (Model $record) => $record->approve())
        ->visible(fn (Model $record) => $record->isPending()),
])
```

### Table Bulk Actions
```php
use Filament\Tables\Actions\BulkAction;
use Filament\Tables\Actions\BulkActionGroup;

->toolbarActions([
    BulkActionGroup::make([
        BulkAction::make('export_selected')
            ->icon('heroicon-o-arrow-down-tray')
            ->action(fn (Collection $records) => static::exportRecords($records))
            ->deselectRecordsAfterCompletion(),
    ]),
])
```

### Header Actions (Table)
```php
->toolbarActions([
    Tables\Actions\CreateAction::make(),
])
```

## Modal Actions

### Confirmation Modal
```php
Action::make('delete')
    ->color('danger')
    ->requiresConfirmation()
    ->modalHeading('Delete record')
    ->modalDescription('Are you sure you want to delete this record? This cannot be undone.')
    ->modalSubmitActionLabel('Yes, delete it')
    ->action(fn (Model $record) => $record->delete())
```

### Form Modal
```php
Action::make('send_email')
    ->icon('heroicon-o-envelope')
    ->schema([
        TextInput::make('subject')
            ->required()
            ->maxLength(255),
        Select::make('template')
            ->options([
                'welcome' => 'Welcome',
                'reminder' => 'Reminder',
                'notification' => 'Notification',
            ])
            ->required(),
        RichEditor::make('body')
            ->required(),
    ])
    ->action(function (array $data, Model $record): void {
        Mail::to($record->email)->send(
            new GenericEmail(
                subject: $data['subject'],
                body: $data['body'],
            )
        );

        Notification::make()
            ->title('Email sent successfully')
            ->success()
            ->send();
    })
```

### Wizard Modal
```php
Action::make('onboard')
    ->steps([
        Wizard\Step::make('Personal Info')
            ->schema([
                TextInput::make('name')->required(),
                TextInput::make('email')->email()->required(),
            ]),
        Wizard\Step::make('Address')
            ->schema([
                TextInput::make('street')->required(),
                TextInput::make('city')->required(),
                Select::make('country')->options([...])->required(),
            ]),
        Wizard\Step::make('Confirmation')
            ->schema([
                Placeholder::make('summary')
                    ->content('Please confirm the information above.'),
            ]),
    ])
    ->action(function (array $data): void {
        // Process all wizard data
    })
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

// Import/Export (NEW in v5)
use Filament\Actions\ImportAction;
use Filament\Actions\ExportAction;
```

## Advanced Features

### Rate Limiting
```php
Action::make('send')
    ->rateLimit(5) // 5 attempts per minute
    ->rateLimitedNotificationTitle('Too many attempts')
```

### Keyboard Shortcuts
```php
Action::make('save')
    ->keyBindings(['command+s', 'ctrl+s'])
```

### Trigger Styles
```php
Action::make('edit')
    ->button()           // Standard button
    ->link()             // Text link
    ->iconButton()       // Icon-only button
    ->badge()            // Badge style
    ->outlined()         // Outlined variant
    ->labeledFrom('md')  // Hide label below breakpoint
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
    ->authorize('update')          // Policy check
    ->authorizationTooltip()       // Show disabled tooltip
    ->visible(fn () => auth()->user()->isAdmin())
```

## Utility Injection Parameters

- `$data` - Modal form submission data
- `$record` - Associated Eloquent model
- `$arguments` - Passed action arguments
- `$livewire` - Current Livewire component
- `$action` - Current action instance
- `$schemaGet` / `$schemaSet` - Schema field access
- `$schemaOperation` - 'create', 'edit', or 'view'

## Complete Example

```php
<?php

declare(strict_types=1);

namespace App\Filament\Resources\OrderResource\Pages;

use App\Filament\Resources\OrderResource;
use App\Mail\InvoiceMail;
use Filament\Actions\Action;
use Filament\Forms\Components\RichEditor;
use Filament\Forms\Components\TextInput;
use Filament\Notifications\Notification;
use Filament\Resources\Pages\EditRecord;
use Illuminate\Support\Facades\Mail;

class EditOrder extends EditRecord
{
    protected static string $resource = OrderResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Action::make('send_invoice')
                ->icon('heroicon-o-envelope')
                ->color('info')
                ->schema([
                    TextInput::make('email')
                        ->email()
                        ->required()
                        ->default(fn () => $this->record->customer->email),
                    TextInput::make('subject')
                        ->required()
                        ->default(fn () => "Invoice #{$this->record->number}"),
                    RichEditor::make('message')
                        ->required(),
                ])
                ->action(function (array $data): void {
                    Mail::to($data['email'])->send(
                        new InvoiceMail($this->record, $data['subject'], $data['message'])
                    );

                    Notification::make()
                        ->title('Invoice sent')
                        ->success()
                        ->send();
                })
                ->rateLimit(3),

            Action::make('mark_completed')
                ->icon('heroicon-o-check-circle')
                ->color('success')
                ->requiresConfirmation()
                ->action(fn () => $this->record->markCompleted())
                ->visible(fn () => $this->record->status !== 'completed'),
        ];
    }
}
```
