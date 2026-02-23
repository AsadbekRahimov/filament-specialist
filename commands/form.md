---
description: Create FilamentPHP v5 form schemas with fields, validation, layout components, and reactivity
allowed-tools: ["Bash", "Glob", "Grep", "Read", "Write", "Edit"]
argument-hint: "<FormDescription> with <field1>, <field2>, ..."
---

# Create Filament v5 Form Schema

## Process

1. **Consult Documentation**: Read `skills/docs/references/forms/`
2. **Analyze Requirements**: Determine field types, validation, and layout
3. **Generate Schema**: Build form schema with proper layout components
4. **Add Validation**: Apply validation rules
5. **Add Reactivity**: Configure live() fields and conditional visibility

## Field Type Mapping

| Data Type | Filament Field | Import |
|-----------|---------------|--------|
| string (short) | `TextInput::make()` | `Filament\Forms\Components\TextInput` |
| string (long) | `Textarea::make()` | `Filament\Forms\Components\Textarea` |
| string (html) | `RichEditor::make()` | `Filament\Forms\Components\RichEditor` |
| string (code) | `CodeEditor::make()` | `Filament\Forms\Components\CodeEditor` |
| enum/choice | `Select::make()` | `Filament\Forms\Components\Select` |
| boolean | `Toggle::make()` | `Filament\Forms\Components\Toggle` |
| boolean | `Checkbox::make()` | `Filament\Forms\Components\Checkbox` |
| date | `DateTimePicker::make()` | `Filament\Forms\Components\DateTimePicker` |
| file/image | `FileUpload::make()` | `Filament\Forms\Components\FileUpload` |
| array (repeating) | `Repeater::make()` | `Filament\Forms\Components\Repeater` |
| array (blocks) | `Builder::make()` | `Filament\Forms\Components\Builder` |
| array (tags) | `TagsInput::make()` | `Filament\Forms\Components\TagsInput` |
| array (key-value) | `KeyValue::make()` | `Filament\Forms\Components\KeyValue` |
| color | `ColorPicker::make()` | `Filament\Forms\Components\ColorPicker` |
| number (range) | `Slider::make()` | `Filament\Forms\Components\Slider` |
| radio choice | `Radio::make()` | `Filament\Forms\Components\Radio` |
| multi-select | `CheckboxList::make()` | `Filament\Forms\Components\CheckboxList` |
| toggle group | `ToggleButtons::make()` | `Filament\Forms\Components\ToggleButtons` |
| hidden | `Hidden::make()` | `Filament\Forms\Components\Hidden` |

## Layout Components

| Component | Class | Use Case |
|-----------|-------|----------|
| Section | `Section::make()` | Group fields with heading |
| Tabs | `Tabs::make()` | Tabbed field groups |
| Grid | `Grid::make()` | Multi-column layouts |
| Fieldset | `Fieldset::make()` | Bordered field groups |
| Wizard | `Wizard::make()` | Multi-step forms |
| Flex | `Flex::make()` | Sidebar/flexible layouts (NEW in v5) |
| FusedGroup | `FusedGroup::make()` | Fused fields (NEW in v5) |

### NEW in v5

| Field/Component | Class | Use Case |
|----------------|-------|----------|
| ModalTableSelect | `ModalTableSelect::make()` | Pick from table modal |
| FusedGroup | `FusedGroup::make()` | Visually fused inputs |
| Flex | `Flex::make()` | Flexible sidebar patterns |

## Example: Complete Form

```php
<?php

declare(strict_types=1);

use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\FileUpload;
use Filament\Forms\Components\Grid;
use Filament\Forms\Components\Repeater;
use Filament\Forms\Components\RichEditor;
use Filament\Forms\Components\Section;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Components\Tabs;

public static function form(Schema $schema): Schema
{
    return $schema->components([
        Tabs::make('Tabs')
            ->tabs([
                Tabs\Tab::make('General')
                    ->schema([
                        Section::make('Basic Information')
                            ->schema([
                                Grid::make(2)->schema([
                                    TextInput::make('name')
                                        ->required()
                                        ->maxLength(255)
                                        ->live(onBlur: true)
                                        ->afterStateUpdated(function (Set $set, ?string $state) {
                                            $set('slug', str($state)->slug());
                                        }),
                                    TextInput::make('slug')
                                        ->required()
                                        ->maxLength(255)
                                        ->unique(ignoreRecord: true),
                                ]),
                                RichEditor::make('description')
                                    ->required()
                                    ->columnSpanFull(),
                            ]),
                        Section::make('Details')
                            ->schema([
                                Grid::make(3)->schema([
                                    Select::make('category_id')
                                        ->relationship('category', 'name')
                                        ->searchable()
                                        ->preload()
                                        ->createOptionForm([
                                            TextInput::make('name')->required(),
                                        ])
                                        ->required(),
                                    Select::make('status')
                                        ->options([
                                            'draft' => 'Draft',
                                            'published' => 'Published',
                                            'archived' => 'Archived',
                                        ])
                                        ->default('draft')
                                        ->required(),
                                    DateTimePicker::make('published_at')
                                        ->native(false),
                                ]),
                            ]),
                    ]),
                Tabs\Tab::make('Media')
                    ->schema([
                        Section::make('Images')
                            ->schema([
                                FileUpload::make('featured_image')
                                    ->image()
                                    ->imageEditor()
                                    ->directory('posts/featured'),
                            ]),
                    ]),
                Tabs\Tab::make('SEO')
                    ->schema([
                        Section::make('SEO Settings')
                            ->schema([
                                TextInput::make('meta_title')
                                    ->maxLength(60),
                                TextInput::make('meta_description')
                                    ->maxLength(160),
                                Repeater::make('meta_tags')
                                    ->schema([
                                        Grid::make(2)->schema([
                                            TextInput::make('key')->required(),
                                            TextInput::make('value')->required(),
                                        ]),
                                    ])
                                    ->collapsible()
                                    ->defaultItems(0),
                            ]),
                    ]),
            ])
            ->columnSpanFull(),
    ]);
}
```

## Validation Rules

```php
TextInput::make('email')
    ->email()
    ->required()
    ->unique(ignoreRecord: true)
    ->maxLength(255)

TextInput::make('price')
    ->numeric()
    ->minValue(0)
    ->maxValue(99999)
    ->prefix('$')

TextInput::make('password')
    ->password()
    ->confirmed()
    ->minLength(8)
    ->revealable()

FileUpload::make('document')
    ->acceptedFileTypes(['application/pdf', 'image/*'])
    ->maxSize(10240) // 10MB
    ->required()
```

## Reactivity Patterns

```php
// Re-render on change (server round-trip)
TextInput::make('title')
    ->live()
    ->afterStateUpdated(fn (Set $set, ?string $state) =>
        $set('slug', str($state)->slug())
    )

// Client-side only - NO server round-trip (NEW in v5)
TextInput::make('title')
    ->afterStateUpdatedJs(<<<'JS'
        $set('slug', ($state ?? '').replaceAll(' ', '-').toLowerCase())
    JS)

// Client-side visibility - NO server round-trip (NEW in v5)
Toggle::make('is_admin')
    ->hiddenJs(<<<'JS'
        $get('role') !== 'staff'
    JS)

// Partial rendering - only re-render specific fields (NEW in v5)
TextInput::make('title')
    ->live()
    ->partiallyRenderComponentsAfterStateUpdated(['slug'])

// Type-safe Get (NEW in v5)
TextInput::make('total')
    ->visible(fn (Get $get) => $get->float('price') > 0)

// Conditional visibility (server-side)
TextInput::make('other_reason')
    ->visible(fn (Get $get) => $get('reason') === 'other')

// Conditional field based on operation
TextInput::make('password')
    ->required(fn (string $operation) => $operation === 'create')
    ->saved(fn (?string $state): bool => filled($state))
```
