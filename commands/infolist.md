---
description: Generate FilamentPHP v5 infolists for read-only data display with entries and layout components
allowed-tools: ["Bash", "Glob", "Grep", "Read", "Write", "Edit"]
argument-hint: "<ModelName> with <entry1>, <entry2>, ..."
---

# Generate Filament v5 Infolist

## Process

1. **Consult Documentation**: Read `skills/docs/references/infolists/`
2. **Analyze Model**: Determine which fields to display
3. **Select Entry Types**: Map data types to entry components
4. **Configure Layout**: Organize entries with layout components
5. **Add Modifiers**: Apply formatting, colors, and icons

## Entry Types

| Entry | Class | Use Case |
|-------|-------|----------|
| Text | `TextEntry::make()` | Display any text |
| Icon | `IconEntry::make()` | Boolean/status icons |
| Image | `ImageEntry::make()` | Image display |
| Color | `ColorEntry::make()` | Color swatches |
| KeyValue | `KeyValueEntry::make()` | Key-value pairs |
| Repeatable | `RepeatableEntry::make()` | Repeated data groups |
| View | `ViewEntry::make()` | Custom Blade view |

## Layout Components

| Component | Class | Use Case |
|-----------|-------|----------|
| Section | `Section::make()` | Group entries with heading |
| Tabs | `Tabs::make()` | Tabbed entry groups |
| Grid | `Grid::make()` | Multi-column layouts |
| Fieldset | `Fieldset::make()` | Bordered entry groups |
| Split | `Split::make()` | Side-by-side layouts |
| Group | `Group::make()` | Logical grouping |

## Complete Example

```php
<?php

declare(strict_types=1);

namespace App\Filament\Resources\OrderResource\Pages;

use App\Filament\Resources\OrderResource;
use Filament\Infolists\Components\Grid;
use Filament\Infolists\Components\Group;
use Filament\Infolists\Components\IconEntry;
use Filament\Infolists\Components\ImageEntry;
use Filament\Infolists\Components\KeyValueEntry;
use Filament\Infolists\Components\RepeatableEntry;
use Filament\Infolists\Components\Section;
use Filament\Infolists\Components\TextEntry;
use Filament\Infolists\Infolist;
use Filament\Resources\Pages\ViewRecord;
use Filament\Schemas\Components\Tabs;

class ViewOrder extends ViewRecord
{
    protected static string $resource = OrderResource::class;

    public function infolist(Infolist $infolist): Infolist
    {
        return $infolist->schema([
            Tabs::make('Order Details')
                ->tabs([
                    Tabs\Tab::make('Overview')
                        ->schema([
                            Section::make('Order Information')
                                ->schema([
                                    Grid::make(3)->schema([
                                        TextEntry::make('number')
                                            ->label('Order Number')
                                            ->weight('bold')
                                            ->copyable(),
                                        TextEntry::make('status')
                                            ->badge()
                                            ->color(fn (string $state) => match ($state) {
                                                'pending' => 'warning',
                                                'processing' => 'info',
                                                'completed' => 'success',
                                                'cancelled' => 'danger',
                                            }),
                                        TextEntry::make('created_at')
                                            ->dateTime(),
                                    ]),
                                ]),
                            Section::make('Customer')
                                ->schema([
                                    Grid::make(2)->schema([
                                        TextEntry::make('customer.name'),
                                        TextEntry::make('customer.email')
                                            ->copyable()
                                            ->icon('heroicon-o-envelope'),
                                        TextEntry::make('customer.phone')
                                            ->icon('heroicon-o-phone'),
                                        IconEntry::make('customer.is_verified')
                                            ->boolean(),
                                    ]),
                                ]),
                        ]),
                    Tabs\Tab::make('Items')
                        ->schema([
                            RepeatableEntry::make('items')
                                ->schema([
                                    Grid::make(4)->schema([
                                        ImageEntry::make('product.image')
                                            ->circular(),
                                        TextEntry::make('product.name'),
                                        TextEntry::make('quantity'),
                                        TextEntry::make('price')
                                            ->money('USD'),
                                    ]),
                                ]),
                        ]),
                    Tabs\Tab::make('Metadata')
                        ->schema([
                            KeyValueEntry::make('metadata'),
                        ]),
                ])
                ->columnSpanFull(),
        ]);
    }
}
```

## Entry Modifiers

```php
// Formatting
TextEntry::make('price')->money('USD')
TextEntry::make('created_at')->dateTime('M j, Y')
TextEntry::make('created_at')->since()
TextEntry::make('description')->markdown()
TextEntry::make('content')->html()
TextEntry::make('items_count')->numeric()

// Styling
TextEntry::make('status')
    ->badge()
    ->color('success')
    ->icon('heroicon-o-check')
    ->weight('bold')
    ->size(TextEntry\TextEntrySize::Large)

// Conditional display
TextEntry::make('notes')
    ->visible(fn (?string $state) => filled($state))
    ->placeholder('No notes')

// Labels
TextEntry::make('name')
    ->label('Full Name')
    ->helperText('Customer legal name')

// Copyable
TextEntry::make('api_key')
    ->copyable()
    ->copyMessage('API key copied')
```
