---
name: tables
description: Generate FilamentPHP v5 table configurations with columns, filters, actions, summaries, and grouping
---

# FilamentPHP v5 Tables Skill

## Overview

This skill generates table configurations for FilamentPHP v5 with columns, filters, actions, summaries, grouping, and advanced features.

## Documentation Reference

**CRITICAL:** Before generating tables, read:
- `skills/docs/references/tables/`

## Column Types Reference

### TextColumn
```php
use Filament\Tables\Columns\TextColumn;

TextColumn::make('name')
    ->searchable()
    ->sortable()
    ->limit(50)
    ->tooltip(fn (Model $record) => $record->name)
    ->description(fn (Model $record) => $record->email, position: 'below')
    ->weight(FontWeight::Bold)
    ->color('primary')
    ->copyable()
    ->copyMessage('Copied!')
    ->toggleable()

// Money formatting
TextColumn::make('price')->money('USD')

// Date formatting
TextColumn::make('created_at')
    ->dateTime('M j, Y H:i')
    ->since() // "2 hours ago"
    ->sortable()

// Badge
TextColumn::make('status')
    ->badge()
    ->color(fn (string $state): string => match ($state) {
        'draft' => 'gray',
        'reviewing' => 'warning',
        'published' => 'success',
        'rejected' => 'danger',
    })
    ->icon(fn (string $state): string => match ($state) {
        'draft' => 'heroicon-o-pencil',
        'published' => 'heroicon-o-check-circle',
        default => 'heroicon-o-clock',
    })

// Relationship
TextColumn::make('author.name')->searchable()->sortable()

// Counts
TextColumn::make('comments_count')
    ->counts('comments')
    ->sortable()

// Enum
TextColumn::make('status')
    ->formatStateUsing(fn (string $state) => str($state)->headline())

// Numeric
TextColumn::make('views')->numeric()->sortable()

// Word limit
TextColumn::make('description')->words(10)

// List of values
TextColumn::make('tags.name')
    ->badge()
    ->separator(',')
```

### IconColumn
```php
use Filament\Tables\Columns\IconColumn;

IconColumn::make('is_featured')
    ->boolean()

IconColumn::make('status')
    ->icon(fn (string $state): string => match ($state) {
        'draft' => 'heroicon-o-pencil',
        'reviewing' => 'heroicon-o-clock',
        'published' => 'heroicon-o-check-circle',
    })
    ->color(fn (string $state): string => match ($state) {
        'draft' => 'gray',
        'reviewing' => 'warning',
        'published' => 'success',
    })
```

### ImageColumn
```php
use Filament\Tables\Columns\ImageColumn;

ImageColumn::make('avatar')
    ->circular()
    ->size(40)
    ->defaultImageUrl(fn (Model $record) =>
        'https://ui-avatars.com/api/?name=' . urlencode($record->name))

ImageColumn::make('gallery')
    ->stacked()
    ->limit(3)
    ->limitedRemainingText()
```

### Inline Editing Columns
```php
use Filament\Tables\Columns\ToggleColumn;
use Filament\Tables\Columns\SelectColumn;
use Filament\Tables\Columns\TextInputColumn;
use Filament\Tables\Columns\CheckboxColumn;

ToggleColumn::make('is_active')
SelectColumn::make('status')->options([...])
TextInputColumn::make('sort_order')->rules(['required', 'integer'])
CheckboxColumn::make('is_featured')
```

### ColorColumn
```php
use Filament\Tables\Columns\ColorColumn;

ColorColumn::make('color')->copyable()
```

## Column Modifiers

```php
// Visibility
->toggleable()
->toggleable(isToggledHiddenByDefault: true)
->visible(fn () => auth()->user()->isAdmin())
->hidden()

// Sizing
->width('200px')
->grow(false)
->alignEnd()

// Styling
->color('danger')
->weight(FontWeight::Bold)
->size(TextColumn\TextColumnSize::Large)

// Extra attributes
->extraAttributes(['class' => 'font-mono'])
->extraHeaderAttributes(['class' => 'w-1/5'])

// Wrapping
->wrap()
->lineClamp(2)
```

## Filters Reference

### SelectFilter
```php
use Filament\Tables\Filters\SelectFilter;

SelectFilter::make('status')
    ->options([
        'draft' => 'Draft',
        'published' => 'Published',
        'archived' => 'Archived',
    ])
    ->multiple()
    ->default('published')
    ->label('Status')

SelectFilter::make('category')
    ->relationship('category', 'name')
    ->searchable()
    ->preload()
    ->multiple()
```

### TernaryFilter
```php
use Filament\Tables\Filters\TernaryFilter;

TernaryFilter::make('is_active')
    ->label('Active')
    ->trueLabel('Active only')
    ->falseLabel('Inactive only')
    ->placeholder('All')
```

### Custom Filter with Form
```php
use Filament\Tables\Filters\Filter;
use Filament\Forms\Components\DatePicker;

Filter::make('created_at')
    ->form([
        DatePicker::make('from')->label('From'),
        DatePicker::make('until')->label('Until'),
    ])
    ->query(function (Builder $query, array $data): Builder {
        return $query
            ->when($data['from'], fn (Builder $q, $date) =>
                $q->whereDate('created_at', '>=', $date))
            ->when($data['until'], fn (Builder $q, $date) =>
                $q->whereDate('created_at', '<=', $date));
    })
    ->indicateUsing(function (array $data): array {
        $indicators = [];
        if ($data['from'] ?? null) {
            $indicators[] = 'From: ' . Carbon::parse($data['from'])->toFormattedDateString();
        }
        if ($data['until'] ?? null) {
            $indicators[] = 'Until: ' . Carbon::parse($data['until'])->toFormattedDateString();
        }
        return $indicators;
    })
```

### TrashedFilter
```php
use Filament\Tables\Filters\TrashedFilter;

TrashedFilter::make()
```

## Actions Reference

### Row Actions
```php
->recordActions([
    Tables\Actions\ViewAction::make(),
    Tables\Actions\EditAction::make(),
    Tables\Actions\DeleteAction::make(),

    // Custom action
    Tables\Actions\Action::make('approve')
        ->icon('heroicon-o-check-circle')
        ->color('success')
        ->requiresConfirmation()
        ->action(fn (Model $record) => $record->approve())
        ->visible(fn (Model $record) => $record->isPending()),
])
```

### Bulk Actions
```php
->toolbarActions([
    Tables\Actions\BulkActionGroup::make([
        Tables\Actions\DeleteBulkAction::make(),

        Tables\Actions\BulkAction::make('export')
            ->icon('heroicon-o-arrow-down-tray')
            ->action(fn (Collection $records) => static::export($records))
            ->deselectRecordsAfterCompletion(),
    ]),
])
```

## Summaries

```php
use Filament\Tables\Columns\Summarizers\Average;
use Filament\Tables\Columns\Summarizers\Count;
use Filament\Tables\Columns\Summarizers\Range;
use Filament\Tables\Columns\Summarizers\Sum;

TextColumn::make('price')
    ->money('USD')
    ->summarize([
        Sum::make()->money('USD')->label('Total'),
        Average::make()->money('USD')->label('Avg'),
    ])

TextColumn::make('name')
    ->summarize(Count::make())

TextColumn::make('rating')
    ->summarize(Range::make())
```

## Grouping

```php
use Filament\Tables\Grouping\Group;

->groups([
    Group::make('status')
        ->collapsible()
        ->titlePrefixedWithLabel(false),
    Group::make('category.name')
        ->label('Category')
        ->orderQueryUsing(fn (Builder $query, string $direction) =>
            $query->orderBy('categories.name', $direction)),
])
->defaultGroup('status')
```

## Table Configuration

```php
->defaultSort('created_at', 'desc')
->striped()
->paginated([10, 25, 50, 100])
->defaultPaginationPageOption(25)
->paginationMode(PaginationMode::Simple)
->reorderable('sort_order')
->deferLoading()
->poll('10s')
->queryStringIdentifier('users')
->recordUrl(fn (Model $record): string => route('posts.show', $record))
->openRecordUrlInNewTab()
->recordClasses(fn (Model $record) => match ($record->status) {
    'draft' => 'opacity-50',
    default => '',
})
->persistFiltersInSession()
->persistSearchInSession()
->persistColumnSearchesInSession()
```

## Responsive Table Layouts

### Stacked on Mobile
```php
use Filament\Tables\Columns\Layout\Split;
use Filament\Tables\Columns\Layout\Stack;

->columns([
    Split::make([
        ImageColumn::make('avatar')
            ->circular()
            ->grow(false),
        TextColumn::make('name')
            ->searchable()
            ->sortable()
            ->weight(FontWeight::Bold),
        TextColumn::make('email')
            ->searchable(),
        TextColumn::make('status')
            ->badge()
            ->grow(false),
    ]),
])
```

### Stack Layout
```php
->columns([
    Split::make([
        ImageColumn::make('avatar')
            ->circular()
            ->grow(false),
        Stack::make([
            TextColumn::make('name')
                ->weight(FontWeight::Bold),
            TextColumn::make('email')
                ->color('gray'),
        ]),
        TextColumn::make('status')
            ->badge()
            ->grow(false),
    ]),
])
```

### Grid Layout
```php
use Filament\Tables\Columns\Layout\Grid;

->columns([
    Grid::make(['md' => 2, 'xl' => 3])
        ->schema([
            Stack::make([
                ImageColumn::make('image'),
                TextColumn::make('name')->weight(FontWeight::Bold),
                TextColumn::make('price')->money('USD'),
            ]),
        ]),
])
->contentGrid(['md' => 2, 'xl' => 3])
```

### Panel Layout
```php
use Filament\Tables\Columns\Layout\Panel;

->columns([
    Split::make([
        TextColumn::make('name'),
        TextColumn::make('status')->badge(),
    ]),
    Panel::make([
        TextColumn::make('description'),
    ])->collapsible(),
])
```

### Stacked on Mobile Shortcut
```php
TextColumn::make('email')
    ->stackedOnMobile()

// Equivalent to hiding on mobile and showing in split layout
```

## Empty State

```php
->emptyStateHeading('No records found')
->emptyStateDescription('Create your first record to get started.')
->emptyStateIcon('heroicon-o-document')
->emptyStateActions([
    Tables\Actions\Action::make('create')
        ->label('Create record')
        ->url(route('...'))
        ->icon('heroicon-o-plus'),
])
```
