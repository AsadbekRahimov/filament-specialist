---
description: Create FilamentPHP v5 table configurations with columns, filters, actions, and summaries
allowed-tools: ["Bash", "Glob", "Grep", "Read", "Write", "Edit"]
argument-hint: "<TableDescription> with <columns>, <filters>, <actions>"
---

# Create Filament v5 Table Configuration

## Process

1. **Consult Documentation**: Read `skills/docs/references/tables/`
2. **Analyze Model**: Determine displayable fields and relationships
3. **Configure Columns**: Set up column types with formatting
4. **Add Filters**: Create filters for data filtering
5. **Add Actions**: Configure row and bulk actions
6. **Configure Layout**: Set pagination, sorting, and grouping

## Column Types

| Column | Class | Use Case |
|--------|-------|----------|
| Text | `TextColumn::make()` | Display any text |
| Icon | `IconColumn::make()` | Boolean/status icons |
| Image | `ImageColumn::make()` | Thumbnails |
| Toggle | `ToggleColumn::make()` | Inline toggle |
| Select | `SelectColumn::make()` | Inline dropdown |
| TextInput | `TextInputColumn::make()` | Inline text editing |
| Checkbox | `CheckboxColumn::make()` | Inline checkbox |
| Color | `ColorColumn::make()` | Color swatches |

## Column Modifiers

```php
TextColumn::make('title')
    ->searchable()
    ->sortable()
    ->limit(50)
    ->tooltip(fn (Model $record) => $record->title)
    ->description(fn (Model $record) => $record->subtitle)
    ->weight(FontWeight::Bold)
    ->color('primary')
    ->copyable()
    ->badge()

TextColumn::make('price')
    ->money('USD')
    ->sortable()

TextColumn::make('created_at')
    ->dateTime()
    ->since()
    ->sortable()

TextColumn::make('status')
    ->badge()
    ->color(fn (string $state): string => match ($state) {
        'draft' => 'gray',
        'reviewing' => 'warning',
        'published' => 'success',
        'rejected' => 'danger',
    })

IconColumn::make('is_featured')
    ->boolean()

ImageColumn::make('avatar')
    ->circular()
    ->defaultImageUrl(fn (Model $record) => 'https://ui-avatars.com/api/?name=' . $record->name)

// Relationship columns
TextColumn::make('author.name')
    ->searchable()
    ->sortable()
```

## Filters

```php
use Filament\Tables\Filters\Filter;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Filters\TernaryFilter;
use Filament\Tables\Filters\TrashedFilter;

->filters([
    // Simple boolean filter
    Filter::make('is_featured')
        ->query(fn (Builder $query) => $query->where('is_featured', true)),

    // Select filter
    SelectFilter::make('status')
        ->options([
            'draft' => 'Draft',
            'published' => 'Published',
            'archived' => 'Archived',
        ])
        ->multiple(),

    // Relationship filter
    SelectFilter::make('category')
        ->relationship('category', 'name')
        ->searchable()
        ->preload(),

    // Ternary (yes/no/any)
    TernaryFilter::make('is_active'),

    // Soft deletes
    TrashedFilter::make(),

    // Date filter with form
    Filter::make('created_at')
        ->form([
            DatePicker::make('created_from'),
            DatePicker::make('created_until'),
        ])
        ->query(function (Builder $query, array $data): Builder {
            return $query
                ->when($data['created_from'], fn (Builder $q, $date) =>
                    $q->whereDate('created_at', '>=', $date))
                ->when($data['created_until'], fn (Builder $q, $date) =>
                    $q->whereDate('created_at', '<=', $date));
        }),
])
```

## Actions

```php
use Filament\Tables\Actions\Action;
use Filament\Tables\Actions\BulkAction;
use Filament\Tables\Actions\BulkActionGroup;
use Filament\Tables\Actions\DeleteAction;
use Filament\Tables\Actions\DeleteBulkAction;
use Filament\Tables\Actions\EditAction;
use Filament\Tables\Actions\ViewAction;

->recordActions([
    ViewAction::make(),
    EditAction::make(),
    DeleteAction::make(),

    // Custom row action
    Action::make('publish')
        ->icon('heroicon-o-check')
        ->color('success')
        ->requiresConfirmation()
        ->action(fn (Model $record) => $record->update(['status' => 'published']))
        ->visible(fn (Model $record) => $record->status === 'draft'),
])
->toolbarActions([
    BulkActionGroup::make([
        DeleteBulkAction::make(),

        // Custom bulk action
        BulkAction::make('publish_selected')
            ->icon('heroicon-o-check')
            ->requiresConfirmation()
            ->action(fn (Collection $records) =>
                $records->each->update(['status' => 'published']))
            ->deselectRecordsAfterCompletion(),
    ]),
])
```

## Complete Table Example

```php
public static function table(Table $table): Table
{
    return $table
        ->columns([
            ImageColumn::make('avatar')->circular(),
            TextColumn::make('name')->searchable()->sortable(),
            TextColumn::make('email')->searchable()->copyable(),
            TextColumn::make('role')->badge(),
            IconColumn::make('is_active')->boolean(),
            TextColumn::make('created_at')->dateTime()->sortable()->toggleable(isToggledHiddenByDefault: true),
        ])
        ->filters([
            SelectFilter::make('role')
                ->options(['admin' => 'Admin', 'user' => 'User']),
            TernaryFilter::make('is_active'),
        ])
        ->recordActions([
            EditAction::make(),
            DeleteAction::make(),
        ])
        ->toolbarActions([
            BulkActionGroup::make([
                DeleteBulkAction::make(),
            ]),
        ])
        ->defaultSort('created_at', 'desc')
        ->striped()
        ->paginated([10, 25, 50, 100])
        ->defaultPaginationPageOption(25);
}
```

## Advanced Features

```php
// Reorderable rows
->reorderable('sort_order')
->defaultSort('sort_order')

// Clickable rows
->recordUrl(fn (Model $record): string => route('posts.show', $record))

// Deferred loading
->deferLoading()

// Polling for updates
->poll('10s')

// Grouping
->groups([
    Group::make('status')
        ->collapsible(),
    Group::make('category.name')
        ->label('Category'),
])

// Summaries
->columns([
    TextColumn::make('price')
        ->money('USD')
        ->summarize([
            Sum::make()->money('USD')->label('Total'),
            Average::make()->money('USD')->label('Average'),
        ]),
    TextColumn::make('name')
        ->summarize(Count::make()),
])

// Empty state
->emptyStateHeading('No posts yet')
->emptyStateDescription('Create your first post to get started.')
->emptyStateIcon('heroicon-o-document-text')
->emptyStateActions([
    Action::make('create')
        ->label('Create post')
        ->url(route('filament.admin.resources.posts.create'))
        ->icon('heroicon-o-plus'),
])
```
