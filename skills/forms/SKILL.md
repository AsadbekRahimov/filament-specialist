---
name: forms
description: Generate FilamentPHP v5 form schemas with fields, validation, reactivity, and layout components
---

# FilamentPHP v5 Forms Skill

## Overview

This skill generates form schemas for FilamentPHP v5 following the official documentation patterns, including the new schema system, utility injection, and enhanced reactivity.

## Documentation Reference

**CRITICAL:** Before generating forms, read:
- `skills/docs/references/forms/`
- `skills/docs/references/schemas/`

## Workflow

### Step 1: Analyze Requirements
- Identify all form fields needed
- Determine field types based on data types
- Plan validation rules
- Design layout with sections, tabs, or grids

### Step 2: Choose Layout
**CRITICAL**: All form fields MUST be inside layout components. Never place fields at the root level.

### Step 3: Add Fields with Validation
### Step 4: Configure Reactivity
### Step 5: Handle Relationships

## Complete Field Reference

### Text Input
```php
use Filament\Forms\Components\TextInput;

TextInput::make('name')
    ->label('Full Name')
    ->required()
    ->maxLength(255)
    ->placeholder('Enter name...')
    ->helperText('Your legal name')
    ->prefix('Mr.')
    ->suffix('@example.com')
    ->prefixIcon('heroicon-o-user')

// Email
TextInput::make('email')->email()->unique(ignoreRecord: true)

// Password
TextInput::make('password')
    ->password()
    ->revealable()
    ->confirmed()
    ->minLength(8)
    ->dehydrated(fn (?string $state) => filled($state))
    ->required(fn (string $operation) => $operation === 'create')

// Numeric
TextInput::make('price')
    ->numeric()
    ->minValue(0)
    ->maxValue(99999)
    ->step(0.01)
    ->prefix('$')

// URL
TextInput::make('website')->url()->suffixIcon('heroicon-o-globe-alt')

// Phone
TextInput::make('phone')->tel()
```

### Select
```php
use Filament\Forms\Components\Select;

// Static options
Select::make('status')
    ->options([
        'draft' => 'Draft',
        'published' => 'Published',
        'archived' => 'Archived',
    ])
    ->default('draft')
    ->required()

// Relationship
Select::make('author_id')
    ->relationship('author', 'name')
    ->searchable()
    ->preload()
    ->createOptionForm([
        TextInput::make('name')->required(),
        TextInput::make('email')->email()->required(),
    ])

// Multiple
Select::make('tags')
    ->multiple()
    ->relationship('tags', 'name')
    ->preload()

// Grouped options
Select::make('category')
    ->options(fn () => Category::query()
        ->pluck('name', 'id'))
    ->searchable()
```

### Toggle & Checkbox
```php
use Filament\Forms\Components\Toggle;
use Filament\Forms\Components\Checkbox;

Toggle::make('is_active')
    ->label('Active')
    ->default(true)
    ->onColor('success')
    ->offColor('danger')

Checkbox::make('accept_terms')
    ->label('I accept the terms')
    ->required()
    ->accepted()
```

### Date & Time
```php
use Filament\Forms\Components\DateTimePicker;

DateTimePicker::make('published_at')
    ->native(false)
    ->displayFormat('M d, Y H:i')
    ->minDate(now())
    ->maxDate(now()->addYear())
    ->seconds(false)
    ->timezone('America/New_York')

// Date only
DateTimePicker::make('birth_date')->date()

// Time only
DateTimePicker::make('start_time')->time()
```

### File Upload
```php
use Filament\Forms\Components\FileUpload;

FileUpload::make('avatar')
    ->image()
    ->imageEditor()
    ->circleCropper()
    ->directory('avatars')
    ->maxSize(2048) // 2MB
    ->visibility('public')

FileUpload::make('attachments')
    ->multiple()
    ->reorderable()
    ->maxFiles(5)
    ->acceptedFileTypes(['application/pdf', 'image/*'])
    ->directory('attachments')
```

### Rich Editor
```php
use Filament\Forms\Components\RichEditor;

RichEditor::make('content')
    ->required()
    ->toolbarButtons([
        'bold', 'italic', 'underline', 'strike',
        'h2', 'h3',
        'bulletList', 'orderedList',
        'link', 'blockquote',
        'codeBlock',
        'attachFiles',
    ])
    ->fileAttachmentsDisk('public')
    ->fileAttachmentsDirectory('uploads')
    ->columnSpanFull()
```

### Repeater
```php
use Filament\Forms\Components\Repeater;

Repeater::make('items')
    ->schema([
        Grid::make(3)->schema([
            Select::make('product_id')
                ->relationship('product', 'name')
                ->required()
                ->searchable(),
            TextInput::make('quantity')
                ->numeric()
                ->required()
                ->default(1)
                ->minValue(1),
            TextInput::make('price')
                ->numeric()
                ->required()
                ->prefix('$'),
        ]),
    ])
    ->relationship() // Save to HasMany relationship
    ->collapsible()
    ->cloneable()
    ->reorderable()
    ->defaultItems(1)
    ->minItems(1)
    ->maxItems(10)
    ->itemLabel(fn (array $state): ?string => $state['product_id'] ?? null)
```

### Builder (Block-based content)
```php
use Filament\Forms\Components\Builder;

Builder::make('content')
    ->blocks([
        Builder\Block::make('heading')
            ->schema([
                TextInput::make('content')->required(),
                Select::make('level')
                    ->options(['h2' => 'H2', 'h3' => 'H3', 'h4' => 'H4'])
                    ->default('h2'),
            ]),
        Builder\Block::make('paragraph')
            ->schema([
                RichEditor::make('content')->required(),
            ]),
        Builder\Block::make('image')
            ->schema([
                FileUpload::make('url')->image()->required(),
                TextInput::make('alt')->required(),
            ]),
    ])
    ->collapsible()
    ->blockNumbers(false)
```

### Other Fields
```php
// Textarea
Textarea::make('notes')->rows(4)->maxLength(1000)

// Tags Input
TagsInput::make('tags')->separator(',')

// Key-Value
KeyValue::make('metadata')
    ->keyLabel('Property')
    ->valueLabel('Value')
    ->reorderable()

// Color Picker
ColorPicker::make('color')->rgba()

// Toggle Buttons
ToggleButtons::make('status')
    ->options(['draft' => 'Draft', 'published' => 'Published'])
    ->icons(['draft' => 'heroicon-o-pencil', 'published' => 'heroicon-o-check'])
    ->colors(['draft' => 'warning', 'published' => 'success'])
    ->inline()

// Slider
Slider::make('rating')->min(0)->max(100)->step(5)

// Code Editor (NEW in v5)
CodeEditor::make('code')->language('php')

// Hidden
Hidden::make('user_id')->default(fn () => auth()->id())

// Radio
Radio::make('plan')
    ->options(['basic' => 'Basic', 'pro' => 'Pro', 'enterprise' => 'Enterprise'])
    ->descriptions([
        'basic' => 'Best for small teams',
        'pro' => 'Best for growing teams',
        'enterprise' => 'Best for large organizations',
    ])
    ->inline()

// Checkbox List
CheckboxList::make('technologies')
    ->options(['php' => 'PHP', 'js' => 'JavaScript', 'python' => 'Python'])
    ->columns(3)
    ->searchable()
```

## Layout Components

```php
use Filament\Schemas\Components\Section;
use Filament\Schemas\Components\Tabs;
use Filament\Schemas\Components\Grid;
use Filament\Schemas\Components\Fieldset;
use Filament\Schemas\Components\Split;
use Filament\Schemas\Components\Wizard;

// Section
Section::make('Personal Information')
    ->description('Enter the user details')
    ->icon('heroicon-o-user')
    ->collapsible()
    ->collapsed(false)
    ->schema([...])

// Tabs
Tabs::make('Tabs')
    ->tabs([
        Tabs\Tab::make('General')->icon('heroicon-o-cog')->schema([...]),
        Tabs\Tab::make('Details')->icon('heroicon-o-document')->schema([...]),
    ])
    ->columnSpanFull()

// Grid
Grid::make(2)->schema([...])  // 2 columns
Grid::make(['md' => 2, 'xl' => 3])->schema([...])  // Responsive

// Wizard
Wizard::make([
    Wizard\Step::make('Account')->schema([...]),
    Wizard\Step::make('Address')->schema([...]),
    Wizard\Step::make('Confirm')->schema([...]),
])
```

## Reactivity & State Management

```php
// Live updates (re-render on change)
TextInput::make('title')
    ->live()
    ->afterStateUpdated(fn (Set $set, ?string $state) =>
        $set('slug', str($state)->slug()))

// Live on blur (better performance)
TextInput::make('title')
    ->live(onBlur: true)

// Debounced live
TextInput::make('search')
    ->live(debounce: 500)

// Client-side only (NEW in v5)
TextInput::make('title')
    ->afterStateUpdatedJs(<<<'JS'
        $set('slug', $get('title').toLowerCase().replaceAll(' ', '-'))
    JS)

// Conditional visibility
TextInput::make('company_name')
    ->visible(fn (Get $get) => $get('type') === 'business')

// Conditional requirement
TextInput::make('tax_id')
    ->required(fn (Get $get) => $get('type') === 'business')

// Computed state
TextInput::make('total')
    ->formatStateUsing(fn (Get $get) =>
        $get('quantity') * $get('price'))
```

## Utility Injection Parameters

Functions accept these injectable parameters:
- `$state` - current field value
- `Get $get` - retrieve other field values
- `Set $set` - modify other field values
- `$record` - current Eloquent model (null on create)
- `$operation` - 'create' | 'edit' | 'view'
- `$livewire` - component instance
- `$component` - current field instance

## Relationship Handling

```php
// BelongsTo via Select
Select::make('author_id')
    ->relationship('author', 'name')

// BelongsToMany via Select (multiple)
Select::make('tags')
    ->multiple()
    ->relationship('tags', 'name')

// BelongsToMany via CheckboxList
CheckboxList::make('roles')
    ->relationship('roles', 'name')

// HasMany via Repeater
Repeater::make('addresses')
    ->relationship()
    ->schema([...])

// HasOne/MorphOne via Section
Section::make('Address')
    ->relationship('address')
    ->schema([...])
```
