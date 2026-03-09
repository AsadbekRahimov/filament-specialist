---
name: filament-infolist
description: Generate FilamentPHP v5 infolists for read-only data display with entries and layout components. Use when creating view pages, read-only displays, or data presentation interfaces.
allowed-tools: Bash, Glob, Grep, Read, Write, Edit
argument-hint: "<ModelName> with <entry1>, <entry2>, ..."
---

# Generate Filament v5 Infolist

## Process

1. **Consult Documentation**: Read `${CLAUDE_SKILL_DIR}/../filament-docs/references/infolists/`
2. **Analyze Model**: Determine which fields to display
3. **Select Entry Types**: Map data types to entry components
4. **Configure Layout**: Organize entries with layout components
5. **Add Modifiers**: Apply formatting, colors, and icons

## Entry Types

### TextEntry
```php
use Filament\Infolists\Components\TextEntry;

TextEntry::make('name')
    ->label('Full Name')
    ->weight(FontWeight::Bold)
    ->size(TextEntry\TextEntrySize::Large)
    ->copyable()
    ->copyMessage('Name copied')
    ->icon('heroicon-o-user')

TextEntry::make('email')
    ->copyable()
    ->icon('heroicon-o-envelope')
    ->url(fn (string $state) => "mailto:{$state}")

TextEntry::make('price')->money('USD')
TextEntry::make('created_at')->dateTime('M j, Y')
TextEntry::make('created_at')->since()
TextEntry::make('description')->markdown()
TextEntry::make('content')->html()
TextEntry::make('views')->numeric()
TextEntry::make('bio')->prose()

TextEntry::make('status')
    ->badge()
    ->color(fn (string $state) => match ($state) {
        'active' => 'success',
        'pending' => 'warning',
        'inactive' => 'danger',
    })

TextEntry::make('tags.name')
    ->badge()
    ->separator(',')
    ->color('info')
```

### IconEntry
```php
use Filament\Infolists\Components\IconEntry;

IconEntry::make('is_active')
    ->boolean()

IconEntry::make('status')
    ->icon(fn (string $state) => match ($state) {
        'active' => 'heroicon-o-check-circle',
        'pending' => 'heroicon-o-clock',
        'inactive' => 'heroicon-o-x-circle',
    })
    ->color(fn (string $state) => match ($state) {
        'active' => 'success',
        'pending' => 'warning',
        'inactive' => 'danger',
    })
```

### ImageEntry
```php
use Filament\Infolists\Components\ImageEntry;

ImageEntry::make('avatar')
    ->circular()
    ->size(80)
    ->defaultImageUrl('https://via.placeholder.com/80')

ImageEntry::make('gallery')
    ->stacked()
    ->limit(3)
```

### ColorEntry
```php
use Filament\Infolists\Components\ColorEntry;

ColorEntry::make('color')->copyable()
```

### KeyValueEntry
```php
use Filament\Infolists\Components\KeyValueEntry;

KeyValueEntry::make('metadata')
    ->keyLabel('Property')
    ->valueLabel('Value')
```

### RepeatableEntry
```php
use Filament\Infolists\Components\RepeatableEntry;

RepeatableEntry::make('comments')
    ->schema([
        TextEntry::make('author.name'),
        TextEntry::make('content'),
        TextEntry::make('created_at')->since(),
    ])
    ->columns(2)
```

### ViewEntry
```php
use Filament\Infolists\Components\ViewEntry;

ViewEntry::make('map')
    ->view('filament.infolists.entries.map-entry')
```

## Layout Components

```php
use Filament\Infolists\Components\Grid;
use Filament\Infolists\Components\Group;
use Filament\Infolists\Components\Section;
use Filament\Infolists\Components\Split;
use Filament\Schemas\Components\Fieldset;
use Filament\Schemas\Components\Tabs;

// Section
Section::make('Customer Details')
    ->description('Basic information')
    ->icon('heroicon-o-user')
    ->collapsible()
    ->schema([...])

// Tabs
Tabs::make('Details')
    ->tabs([
        Tabs\Tab::make('Overview')->schema([...]),
        Tabs\Tab::make('Activity')->schema([...]),
    ])

// Grid
Grid::make(2)->schema([...])
Grid::make(['md' => 2, 'xl' => 3])->schema([...])

// Split
Split::make([
    Section::make('Main')->schema([...]),
    Section::make('Sidebar')->schema([...]),
])

// Group
Group::make([
    TextEntry::make('name'),
    TextEntry::make('email'),
])
```

## Entry Modifiers

```php
// Label
->label('Customer Name')
->hiddenLabel()
->inlineLabel()

// Visibility (server-side)
->visible(fn (?string $state) => filled($state))
->hidden(fn () => ! auth()->user()->isAdmin())

// Client-side visibility - NO server round-trip (v4.5+/v5)
->hiddenJs(<<<'JS'
    $get('role') !== 'staff'
JS)
->visibleJs(<<<'JS'
    $get('role') === 'staff'
JS)

// Placeholder
->placeholder('Not provided')
->default('N/A')

// Tooltip
->tooltip('Click to copy')

// Helper text
->helperText('This is the customer\'s primary email')

// Column span
->columnSpan(2)
->columnSpanFull()

// Text handling
->limit(50)             // Character limit
->words(10)             // Word limit
->lineClamp(2)          // CSS line clamp
->wrap(false)           // Prevent wrapping

// Date tooltips (v4.5+/v5)
->since()->dateTooltip()        // "2h ago" with full date tooltip
->since()->dateTimeTooltip()    // "2h ago" with datetime tooltip
->dateTime()->sinceTooltip()    // Datetime with relative tooltip
```

## Entry Slots (v4.5+/v5)

```php
use Filament\Actions\Action;

TextEntry::make('name')
    ->aboveLabel('Required field')
    ->afterLabel(Action::make('help')->icon('heroicon-o-question-mark-circle'))
    ->belowContent('This is the user\'s legal name.')

// Available slots:
// aboveLabel(), beforeLabel(), afterLabel(), belowLabel()
// aboveContent(), beforeContent(), afterContent(), belowContent()
```

## Complete Example

```php
public function infolist(Infolist $infolist): Infolist
{
    return $infolist->schema([
        Tabs::make('Order Details')
            ->tabs([
                Tabs\Tab::make('Overview')
                    ->icon('heroicon-o-shopping-bag')
                    ->schema([
                        Section::make('Order Information')
                            ->schema([
                                Grid::make(3)->schema([
                                    TextEntry::make('number')
                                        ->label('Order #')
                                        ->weight(FontWeight::Bold)
                                        ->copyable(),
                                    TextEntry::make('status')
                                        ->badge()
                                        ->color(fn (string $state) => match ($state) {
                                            'pending' => 'warning',
                                            'processing' => 'info',
                                            'shipped' => 'primary',
                                            'completed' => 'success',
                                            'cancelled' => 'danger',
                                        }),
                                    TextEntry::make('created_at')
                                        ->dateTime()
                                        ->since(),
                                ]),
                            ]),
                        Section::make('Customer')
                            ->schema([
                                Grid::make(2)->schema([
                                    TextEntry::make('customer.name'),
                                    TextEntry::make('customer.email')
                                        ->copyable()
                                        ->icon('heroicon-o-envelope'),
                                ]),
                            ]),
                    ]),
                Tabs\Tab::make('Items')
                    ->icon('heroicon-o-list-bullet')
                    ->schema([
                        RepeatableEntry::make('items')
                            ->schema([
                                ImageEntry::make('product.image')
                                    ->circular()
                                    ->size(40),
                                TextEntry::make('product.name'),
                                TextEntry::make('quantity'),
                                TextEntry::make('unit_price')->money('USD'),
                                TextEntry::make('total')->money('USD'),
                            ])
                            ->columns(5),
                    ]),
                Tabs\Tab::make('Metadata')
                    ->icon('heroicon-o-code-bracket')
                    ->schema([
                        KeyValueEntry::make('metadata'),
                    ]),
            ])
            ->columnSpanFull(),
    ]);
}
```
