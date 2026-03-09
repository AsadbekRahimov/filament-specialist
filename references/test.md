# Generate Filament v5 Pest Tests

## Process

1. **Consult Documentation**: Read `${CLAUDE_SKILL_DIR}/docs/references/general/10-testing/`
2. **Analyze Resource**: Examine the resource class, form, and table configuration
3. **Generate Tests**: Create comprehensive test file
4. **Include Coverage**: CRUD operations, validation, table features, actions, and authorization

## Test Setup

### Base Test Configuration

```php
<?php

declare(strict_types=1);

namespace Tests;

use Illuminate\Foundation\Testing\TestCase as BaseTestCase;

abstract class TestCase extends BaseTestCase
{
    protected function setUp(): void
    {
        parent::setUp();

        $this->actingAs(\App\Models\User::factory()->create([
            'is_admin' => true,
        ]));
    }
}
```

### Pest Configuration

```php
// tests/Pest.php
uses(Tests\TestCase::class)->in('Feature');
uses(Illuminate\Foundation\Testing\RefreshDatabase::class)->in('Feature');
```

## Resource Page Tests

### List Page
```php
use App\Filament\Resources\PostResource\Pages\ListPosts;
use App\Models\Post;
use Filament\Testing\TestAction;
use Filament\Tables\Actions\DeleteBulkAction;

use function Pest\Livewire\livewire;

it('can render list page', function () {
    livewire(ListPosts::class)->assertOk();
});

it('can list records', function () {
    $posts = Post::factory()->count(10)->create();
    livewire(ListPosts::class)->assertCanSeeTableRecords($posts);
});

it('can search records', function () {
    $post = Post::factory()->create(['title' => 'Unique Search Term']);
    $other = Post::factory()->create(['title' => 'Other Post']);

    livewire(ListPosts::class)
        ->searchTable('Unique Search Term')
        ->assertCanSeeTableRecords([$post])
        ->assertCanNotSeeTableRecords([$other]);
});

it('can sort records', function () {
    $posts = Post::factory()->count(3)->create();

    livewire(ListPosts::class)
        ->sortTable('title')
        ->assertCanSeeTableRecords($posts->sortBy('title'), inOrder: true);
});

it('can filter records', function () {
    $published = Post::factory()->create(['status' => 'published']);
    $draft = Post::factory()->create(['status' => 'draft']);

    livewire(ListPosts::class)
        ->filterTable('status', 'published')
        ->assertCanSeeTableRecords([$published])
        ->assertCanNotSeeTableRecords([$draft]);
});

it('can bulk delete', function () {
    $posts = Post::factory()->count(3)->create();

    livewire(ListPosts::class)
        ->selectTableRecords($posts->pluck('id')->toArray())
        ->callAction(TestAction::make(DeleteBulkAction::class)->table()->bulk());

    foreach ($posts as $post) {
        $this->assertModelMissing($post);
    }
});
```

### Create Page
```php
use App\Filament\Resources\PostResource\Pages\CreatePost;
use App\Models\Post;

it('can render create page', function () {
    livewire(CreatePost::class)->assertOk();
});

it('can create record', function () {
    livewire(CreatePost::class)
        ->fillForm([
            'title' => 'New Post',
            'slug' => 'new-post',
            'content' => 'Post content',
            'status' => 'draft',
        ])
        ->call('create')
        ->assertHasNoFormErrors();

    $this->assertDatabaseHas(Post::class, ['title' => 'New Post']);
});

it('validates required fields', function () {
    livewire(CreatePost::class)
        ->fillForm(['title' => '', 'content' => ''])
        ->call('create')
        ->assertHasFormErrors(['title' => 'required', 'content' => 'required']);
});
```

### Edit Page
```php
use App\Filament\Resources\PostResource\Pages\EditPost;
use App\Models\Post;
use Filament\Actions\DeleteAction;

it('can render edit page', function () {
    $post = Post::factory()->create();
    livewire(EditPost::class, ['record' => $post->getRouteKey()])->assertOk();
});

it('can retrieve data', function () {
    $post = Post::factory()->create();

    livewire(EditPost::class, ['record' => $post->getRouteKey()])
        ->assertSchemaStateSet([
            'title' => $post->title,
            'slug' => $post->slug,
        ]);
});

it('can update record', function () {
    $post = Post::factory()->create();

    livewire(EditPost::class, ['record' => $post->getRouteKey()])
        ->fillForm(['title' => 'Updated Title'])
        ->call('save')
        ->assertHasNoFormErrors();

    expect($post->refresh()->title)->toBe('Updated Title');
});

it('can delete record', function () {
    $post = Post::factory()->create();

    livewire(EditPost::class, ['record' => $post->getRouteKey()])
        ->callAction(DeleteAction::class);

    $this->assertModelMissing($post);
});
```

## Schema/Form Testing (v5)

```php
// Field existence
->assertFormFieldExists('title')
->assertFormFieldDoesNotExist('nonexistent')

// Field visibility
->assertFormFieldVisible('title')
->assertFormFieldHidden('secret_field')

// Field state
->assertFormFieldEnabled('title')
->assertFormFieldDisabled('locked_field')

// Schema component existence (requires key())
->assertSchemaComponentExists('seo-section')
->assertSchemaComponentVisible('seo-section')

// Schema state (replaces assertFormSet in v5)
->assertSchemaStateSet(['title' => 'Expected Value'])
->assertSchemaStateSet(function (array $state): array {
    expect($state['slug'])->not->toContain(' ');
    return ['slug' => 'expected-slug'];
})
```

## Table Testing (v5)

```php
// Column existence and visibility
->assertTableColumnExists('title')
->assertTableColumnVisible('title')
->assertTableColumnHidden('internal_notes')

// Column rendering
->assertCanRenderTableColumn('title')
->assertCanNotRenderTableColumn('hidden_column')

// Column state
->assertTableColumnStateSet('title', 'Expected', record: $post)
->assertTableColumnFormattedStateSet('price', '$10.00', record: $post)

// Column metadata
->assertTableColumnHasDescription('name', 'Description', $record, 'below')
->assertTableColumnHasExtraAttributes('name', ['class' => 'font-bold'], $record)

// Filter assertions
->assertTableFilterExists('status')
->assertTableFilterVisible('status')
->assertTableFilterHidden('internal')

// Summary assertions
->assertTableColumnSummarySet('price', 'sum', 1000)
->assertTableColumnSummarySet('rating', 'average', 4.5)

// Record count
->assertCountTableRecords(10)
```

## Action Testing (v5 with TestAction)

```php
use Filament\Testing\TestAction;

// Page actions
->callAction('publish')
->assertActionExists('publish')
->assertActionVisible('publish')
->assertActionHidden('delete')
->assertActionEnabled('publish')
->assertActionDisabled('locked_action')
->assertActionHalted('incomplete')

// Table row actions
->callAction(TestAction::make('delete')->table($record))
->callAction(TestAction::make('edit')->table($record))

// Table header actions
->callAction(TestAction::make('create')->table())

// Bulk actions
->selectTableRecords($ids)
->callAction(TestAction::make('delete')->table()->bulk())

// Schema component actions
->callAction(TestAction::make('generate')->schemaComponent('slug'))

// Action with form data
->callAction('send', data: ['email' => 'test@example.com'])
->assertHasNoActionErrors()

// Action with validation errors
->callAction('send', data: ['email' => 'invalid'])
->assertHasActionErrors(['email' => 'email'])

// Mount action (keep modal open)
->mountAction('send')
->assertSchemaStateSet(['email' => 'default@example.com'])
->callMountedAction()

// Action properties
->assertActionHasLabel('send', 'Send Email')
->assertActionHasIcon('send', 'heroicon-o-envelope')
->assertActionHasColor('delete', 'danger')
->assertActionHasUrl('website', 'https://example.com')
->assertActionsExistInOrder(['edit', 'delete'])

// Nested actions (action within action modal)
->callAction([
    TestAction::make('view')->table($record),
    TestAction::make('send')->schemaComponent('email'),
])
```

## Notification Testing

```php
use Filament\Notifications\Notification;

Notification::assertSentTo($user, function (Notification $notification) {
    return $notification->getTitle() === 'Order shipped';
});
```

## Repeater & Builder Testing

```php
use Filament\Forms\Components\Repeater;
use Filament\Forms\Components\Builder;

// Repeater
$undoFake = Repeater::fake();
livewire(EditPost::class, ['record' => $post->getRouteKey()])
    ->assertSchemaStateSet([
        'items' => [
            ['name' => 'Item 1'],
            ['name' => 'Item 2'],
        ],
    ]);
$undoFake();

// Builder
$undoFake = Builder::fake();
livewire(EditPost::class, ['record' => $post->getRouteKey()])
    ->assertSchemaStateSet([
        'content' => [
            ['type' => 'heading', 'data' => ['text' => 'Hello']],
            ['type' => 'paragraph', 'data' => ['text' => 'World']],
        ],
    ]);
$undoFake();
```

## Wizard Testing

```php
->goToNextWizardStep()
->assertHasFormErrors(['title'])

->goToWizardStep(2)
->assertWizardCurrentStep(2)

->goToPreviousWizardStep()
->assertWizardCurrentStep(1)
```

## Authorization Tests

```php
it('prevents unauthorized access', function () {
    $user = User::factory()->create(['is_admin' => false]);
    $this->actingAs($user);

    livewire(ListPosts::class)->assertForbidden();
});

it('prevents unauthorized creation', function () {
    $user = User::factory()->create(['is_admin' => false]);
    $this->actingAs($user);

    livewire(CreatePost::class)->assertForbidden();
});

it('prevents unauthorized editing', function () {
    $user = User::factory()->create(['is_admin' => false]);
    $post = Post::factory()->create();
    $this->actingAs($user);

    livewire(EditPost::class, ['record' => $post->getRouteKey()])
        ->assertForbidden();
});
```

## Relation Manager Tests

```php
use App\Filament\Resources\PostResource\RelationManagers\CommentsRelationManager;

livewire(CommentsRelationManager::class, [
    'ownerRecord' => $post,
    'pageClass' => EditPost::class,
])
    ->assertOk()
    ->assertCanSeeTableRecords($post->comments);
```

## Multi-Panel & Tenant Testing

```php
use Filament\Facades\Filament;

Filament::setCurrentPanel('app');
Filament::setTenant($team);
Filament::bootCurrentPanel();
```

## Widget Tests

```php
it('can render stats widget', function () {
    livewire(StatsOverview::class)->assertOk();
});

it('can render table widget', function () {
    $posts = Post::factory()->count(5)->create();
    livewire(LatestPosts::class)
        ->assertOk()
        ->assertCanSeeTableRecords($posts);
});
```

## Output

Generated tests include:
1. Page rendering tests
2. CRUD operation tests
3. Form validation tests
4. Table feature tests (search, sort, filter)
5. Action tests (with TestAction)
6. Authorization tests
7. Widget tests
8. Relation manager tests
