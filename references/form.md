# Create Filament v5 Form Schema

## Process

1. **Consult Documentation**: Read `${CLAUDE_SKILL_DIR}/docs/references/forms/`
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

### NEW in v5

| Field/Component | Class | Use Case |
|----------------|-------|----------|
| ModalTableSelect | `ModalTableSelect::make()` | Pick from table modal |
| FusedGroup | `FusedGroup::make()` | Visually fused inputs |
| Flex | `Flex::make()` | Flexible sidebar patterns |

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

// Password (v5: use saved() instead of dehydrated())
TextInput::make('password')
    ->password()
    ->revealable()
    ->confirmed()
    ->minLength(8)
    ->saved(fn (?string $state): bool => filled($state))
    ->required(fn (string $operation) => $operation === 'create')
    ->dehydrateStateUsing(fn (string $state): string => Hash::make($state))

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
        ['bold', 'italic', 'underline', 'strike'],
        ['h2', 'h3'],
        ['bulletList', 'orderedList', 'blockquote'],
        ['link', 'table', 'attachFiles'],
    ])
    ->fileAttachmentsDisk('public')
    ->fileAttachmentsDirectory('uploads')
    ->columnSpanFull()

// NEW in v5: Store as JSON (TipTap format)
RichEditor::make('content')->json()

// NEW in v5: Custom text colors
RichEditor::make('content')
    ->textColors([
        '#ef4444' => 'Red',
        '#10b981' => 'Green',
        '#0ea5e9' => 'Sky',
    ])
    ->customTextColors()

// NEW in v5: Merge tags
RichEditor::make('content')
    ->mergeTags(['name', 'email', 'today'])

// NEW in v5: Mentions
use Filament\Forms\Components\RichEditor\MentionProvider;

RichEditor::make('content')
    ->mentions([
        MentionProvider::make('@')
            ->items([1 => 'Jane Doe', 2 => 'John Smith']),
    ])

// NEW in v5: Resizable images
RichEditor::make('content')->resizableImages()

// NEW in v5: Floating toolbars
RichEditor::make('content')
    ->floatingToolbars([
        'paragraph' => ['bold', 'italic', 'underline', 'link'],
        'table' => ['tableAddColumnBefore', 'tableAddColumnAfter', 'tableDelete'],
    ])
```

### ModalTableSelect (NEW in v5)
```php
use Filament\Forms\Components\ModalTableSelect;

ModalTableSelect::make('category_id')
    ->relationship('category', 'name')
    ->tableConfiguration(CategoriesTable::class)

// Multiple selection
ModalTableSelect::make('categories')
    ->relationship('categories', 'name')
    ->multiple()
    ->tableConfiguration(CategoriesTable::class)
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

// NEW in v5: Simple repeater (single field)
Repeater::make('invitations')
    ->simple(
        TextInput::make('email')->email()->required(),
    )

// NEW in v5: Table repeater layout
use Filament\Forms\Components\Repeater\TableColumn;

Repeater::make('members')
    ->table([
        TableColumn::make('Name'),
        TableColumn::make('Role')->width('200px'),
    ])
    ->schema([
        TextInput::make('name')->required(),
        Select::make('role')->options([...])->required(),
    ])
    ->compact()

// NEW in v5: Extra item actions
Repeater::make('members')
    ->schema([TextInput::make('email')->email()])
    ->extraItemActions([
        Action::make('sendEmail')
            ->icon('heroicon-o-envelope')
            ->action(function (array $arguments, Repeater $component): void {
                $itemData = $component->getItemState($arguments['item']);
                // Send email...
            }),
    ])

// Prevent duplicate selections across items
Select::make('role')
    ->options([...])
    ->disableOptionsWhenSelectedInSiblingRepeaterItems()
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

**CRITICAL**: All form fields MUST be inside layout components. Never place fields at the root level.

```php
use Filament\Schemas\Components\Section;
use Filament\Schemas\Components\Tabs;
use Filament\Schemas\Components\Grid;
use Filament\Schemas\Components\Fieldset;
use Filament\Schemas\Components\Flex;
use Filament\Schemas\Components\FusedGroup;
use Filament\Schemas\Components\Wizard;

// Section
Section::make('Personal Information')
    ->description('Enter the user details')
    ->icon('heroicon-o-user')
    ->collapsible()
    ->collapsed(false)
    ->schema([...])

// Section aside layout (heading/description on left, fields on right)
Section::make('Rate limiting')
    ->description('Prevent abuse')
    ->aside()
    ->schema([...])

// NEW in v5: Section secondary styling
Section::make('Notes')
    ->schema([...])->secondary()->compact()

// NEW in v5: Section header/footer actions
Section::make('Settings')
    ->afterHeader([Action::make('reset')])
    ->footer([Action::make('save')])
    ->schema([...])

// Tabs
Tabs::make('Tabs')
    ->tabs([
        Tabs\Tab::make('General')->icon('heroicon-o-cog')->schema([...]),
        Tabs\Tab::make('Details')->icon('heroicon-o-document')->badge(5)->schema([...]),
    ])
    ->columnSpanFull()

// NEW in v5: Vertical tabs
Tabs::make('Settings')->tabs([...])->vertical()

// NEW in v5: Persist tab in URL query string
Tabs::make('Settings')->tabs([...])->persistTabInQueryString('settings-tab')

// Grid
Grid::make(2)->schema([...])  // 2 columns
Grid::make(['md' => 2, 'xl' => 3])->schema([...])  // Responsive

// NEW in v5: Container queries (responsive within parent, not viewport)
Grid::make()
    ->gridContainer()
    ->columns(['@md' => 3, '@xl' => 4])
    ->schema([...])

// NEW in v5: Flex layout (sidebar patterns)
Flex::make([
    Section::make([
        TextInput::make('title'),
        Textarea::make('content'),
    ]),
    Section::make([
        Toggle::make('is_published'),
        Toggle::make('is_featured'),
    ])->grow(false),
])->from('md')

// NEW in v5: FusedGroup (fuse fields together visually)
FusedGroup::make([
    TextInput::make('city')->placeholder('City'),
    Select::make('country')->options([...])->placeholder('Country'),
])->label('Location')->columns(2)

// Fieldset
Fieldset::make('Address')
    ->columns(['default' => 1, 'md' => 2])
    ->schema([...])

// Fieldset without border
Fieldset::make('Address')->contained(false)->schema([...])

// Dense spacing
Fieldset::make('Dense')->dense()->schema([...])

// Wizard
Wizard::make([
    Wizard\Step::make('Account')->schema([...]),
    Wizard\Step::make('Address')->schema([...]),
    Wizard\Step::make('Confirm')->schema([...]),
])

// Column span & start
TextInput::make('bio')->columnSpanFull()
TextInput::make('name')->columnStart(['sm' => 2, 'xl' => 3])
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

// Client-side JS updates - NO server round-trip (NEW in v5)
TextInput::make('title')
    ->afterStateUpdatedJs(<<<'JS'
        $set('slug', ($state ?? '').replaceAll(' ', '-').toLowerCase())
    JS)

// Client-side visibility - NO server round-trip (NEW in v5)
Toggle::make('is_admin')
    ->hiddenJs(<<<'JS'
        $get('role') !== 'staff'
    JS)

// Or the inverse:
Toggle::make('is_admin')
    ->visibleJs(<<<'JS'
        $get('role') === 'staff'
    JS)

// Partial rendering - only re-render specific components (NEW in v5)
TextInput::make('title')
    ->live()
    ->partiallyRenderComponentsAfterStateUpdated(['slug'])

// Skip render entirely - just run the hook
TextInput::make('counter')
    ->live()
    ->skipRenderAfterStateUpdated()

// Conditional visibility (server-side)
TextInput::make('company_name')
    ->visible(fn (Get $get) => $get('type') === 'business')

// Conditional requirement
TextInput::make('tax_id')
    ->required(fn (Get $get) => $get('type') === 'business')

// Computed state
TextInput::make('total')
    ->formatStateUsing(fn (Get $get) =>
        $get('quantity') * $get('price'))

// Dynamic fields based on select (key() for re-rendering)
Select::make('type')
    ->options(['employee' => 'Employee', 'freelancer' => 'Freelancer'])
    ->live()
    ->afterStateUpdated(fn (Select $component) => $component
        ->getContainer()
        ->getComponent('dynamicFields')
        ->getChildSchema()
        ->fill())

Grid::make(2)
    ->schema(fn (Get $get): array => match ($get('type')) {
        'employee' => [TextInput::make('employee_number')->required()],
        'freelancer' => [TextInput::make('hourly_rate')->numeric()->required()],
        default => [],
    })
    ->key('dynamicFields')
```

## Utility Injection Parameters

Functions accept these injectable parameters:
- `$state` - current field value
- `$rawState` - raw (unformatted) field value
- `Get $get` - retrieve other field values
- `Set $set` - modify other field values
- `$record` - current Eloquent model (null on create)
- `$operation` - 'create' | 'edit' | 'view'
- `$livewire` - component instance
- `$component` - current field instance

### Type-safe Get (NEW in v5)
```php
use Filament\Schemas\Components\Utilities\Get;

function (Get $get) {
    $get->string('email');                         // string
    $get->integer('age');                          // int
    $get->float('price');                          // float
    $get->boolean('is_admin');                     // bool
    $get->array('tags');                           // array
    $get->date('published_at');                    // Carbon
    $get->enum('status', StatusEnum::class);       // enum
    $get->filled('email');                         // bool
    $get->blank('email');                          // bool

    // Nullable variants
    $get->string('email', isNullable: true);       // ?string
}
```

### JavaScript Dynamic Content (NEW in v5)
```php
use Filament\Schemas\JsContent;

TextInput::make('greeting')
    ->label(JsContent::make(<<<'JS'
        ($get('name') === 'John') ? 'Hello, John!' : 'Hello, stranger!'
    JS))
```

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

// HasOne/MorphOne via Group (no visual wrapper)
Group::make()
    ->relationship('customer')
    ->schema([
        TextInput::make('name')->required(),
        TextInput::make('email')->email()->required(),
    ])

// Conditional relationship save (NEW in v5)
Group::make()
    ->relationship(
        'customer',
        condition: fn (?array $state): bool => filled($state['name']),
    )
    ->schema([
        TextInput::make('name'),
        TextInput::make('email')->requiredWith('name'),
    ])

// BelongsToMany pivot data
Select::make('primaryTechnologies')
    ->relationship(name: 'technologies', titleAttribute: 'name')
    ->multiple()
    ->pivotData(['is_primary' => true])
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

## Complete Example

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
