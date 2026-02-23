---
description: Generate comprehensive Pest tests for FilamentPHP v5 resources, forms, tables, actions, and authorization
allowed-tools: ["Bash", "Glob", "Grep", "Read", "Write", "Edit"]
argument-hint: "<ResourceName> [--with-auth] [--type=<resource|form|table|action>]"
---

# Generate Filament v5 Pest Tests

## Process

1. **Consult Documentation**: Read `skills/docs/references/general/10-testing/`
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

## Resource Tests (v5 Patterns)

### List Page Tests

```php
<?php

declare(strict_types=1);

use App\Filament\Resources\PostResource;
use App\Filament\Resources\PostResource\Pages\ListPosts;
use App\Models\Post;
use App\Models\User;
use Filament\Actions\DeleteAction;
use Filament\Tables\Actions\DeleteBulkAction;
use Filament\Testing\TestAction;

use function Pest\Livewire\livewire;

beforeEach(function () {
    $this->user = User::factory()->create(['is_admin' => true]);
    $this->actingAs($this->user);
});

it('can render the list page', function () {
    livewire(ListPosts::class)
        ->assertOk();
});

it('can list posts', function () {
    $posts = Post::factory()->count(10)->create();

    livewire(ListPosts::class)
        ->assertCanSeeTableRecords($posts);
});

it('can render post columns', function () {
    Post::factory()->create();

    livewire(ListPosts::class)
        ->assertCanRenderTableColumn('title')
        ->assertCanRenderTableColumn('status')
        ->assertCanRenderTableColumn('created_at');
});

it('can search posts by title', function () {
    $post = Post::factory()->create(['title' => 'Unique Search Term']);
    $otherPost = Post::factory()->create(['title' => 'Other Post']);

    livewire(ListPosts::class)
        ->searchTable('Unique Search Term')
        ->assertCanSeeTableRecords([$post])
        ->assertCanNotSeeTableRecords([$otherPost]);
});

it('can sort posts by title', function () {
    $posts = Post::factory()->count(3)->create();

    livewire(ListPosts::class)
        ->sortTable('title')
        ->assertCanSeeTableRecords($posts->sortBy('title'), inOrder: true)
        ->sortTable('title', 'desc')
        ->assertCanSeeTableRecords($posts->sortByDesc('title'), inOrder: true);
});

it('can filter posts by status', function () {
    $publishedPost = Post::factory()->create(['status' => 'published']);
    $draftPost = Post::factory()->create(['status' => 'draft']);

    livewire(ListPosts::class)
        ->filterTable('status', 'published')
        ->assertCanSeeTableRecords([$publishedPost])
        ->assertCanNotSeeTableRecords([$draftPost]);
});

it('can bulk delete posts', function () {
    $posts = Post::factory()->count(3)->create();

    livewire(ListPosts::class)
        ->selectTableRecords($posts->pluck('id')->toArray())
        ->callAction(TestAction::make(DeleteBulkAction::class)->table()->bulk());

    foreach ($posts as $post) {
        $this->assertModelMissing($post);
    }
});
```

### Create Page Tests

```php
<?php

declare(strict_types=1);

use App\Filament\Resources\PostResource\Pages\CreatePost;
use App\Models\Category;
use App\Models\Post;

use function Pest\Livewire\livewire;

it('can render the create page', function () {
    livewire(CreatePost::class)
        ->assertOk();
});

it('can create a post', function () {
    $category = Category::factory()->create();

    livewire(CreatePost::class)
        ->fillForm([
            'title' => 'New Post Title',
            'slug' => 'new-post-title',
            'content' => 'This is the post content.',
            'status' => 'draft',
            'category_id' => $category->id,
        ])
        ->call('create')
        ->assertHasNoFormErrors();

    $this->assertDatabaseHas(Post::class, [
        'title' => 'New Post Title',
        'slug' => 'new-post-title',
    ]);
});

it('validates required fields', function () {
    livewire(CreatePost::class)
        ->fillForm([
            'title' => '',
            'content' => '',
        ])
        ->call('create')
        ->assertHasFormErrors([
            'title' => 'required',
            'content' => 'required',
        ]);
});

it('validates unique slug', function () {
    Post::factory()->create(['slug' => 'existing-slug']);

    livewire(CreatePost::class)
        ->fillForm([
            'title' => 'New Post',
            'slug' => 'existing-slug',
            'content' => 'Content',
        ])
        ->call('create')
        ->assertHasFormErrors(['slug' => 'unique']);
});
```

### Edit Page Tests

```php
<?php

declare(strict_types=1);

use App\Filament\Resources\PostResource\Pages\EditPost;
use App\Models\Post;
use Filament\Actions\DeleteAction;

use function Pest\Livewire\livewire;

it('can render the edit page', function () {
    $post = Post::factory()->create();

    livewire(EditPost::class, ['record' => $post->getRouteKey()])
        ->assertOk();
});

it('can retrieve data', function () {
    $post = Post::factory()->create();

    livewire(EditPost::class, ['record' => $post->getRouteKey()])
        ->assertSchemaStateSet([
            'title' => $post->title,
            'slug' => $post->slug,
            'content' => $post->content,
        ]);
});

it('can update a post', function () {
    $post = Post::factory()->create();

    livewire(EditPost::class, ['record' => $post->getRouteKey()])
        ->fillForm([
            'title' => 'Updated Title',
            'slug' => 'updated-title',
            'content' => 'Updated content.',
        ])
        ->call('save')
        ->assertHasNoFormErrors();

    expect($post->refresh())
        ->title->toBe('Updated Title')
        ->slug->toBe('updated-title');
});

it('can delete a post', function () {
    $post = Post::factory()->create();

    livewire(EditPost::class, ['record' => $post->getRouteKey()])
        ->callAction(DeleteAction::class);

    $this->assertModelMissing($post);
});
```

### View Page Tests

```php
it('can render the view page', function () {
    $post = Post::factory()->create();

    livewire(ViewPost::class, ['record' => $post->getRouteKey()])
        ->assertOk();
});

it('displays post data in infolist', function () {
    $post = Post::factory()->create([
        'title' => 'Test Post',
        'status' => 'published',
    ]);

    livewire(ViewPost::class, ['record' => $post->getRouteKey()])
        ->assertSee('Test Post')
        ->assertSee('published');
});
```

## Schema/Form Testing (v5)

```php
it('has expected form fields', function () {
    livewire(CreatePost::class)
        ->assertFormFieldExists('title')
        ->assertFormFieldExists('slug')
        ->assertFormFieldExists('content')
        ->assertFormFieldExists('status');
});

it('can check field visibility', function () {
    livewire(CreatePost::class)
        ->assertFormFieldVisible('title')
        ->assertFormFieldEnabled('title');
});

it('can check schema components', function () {
    livewire(CreatePost::class)
        ->assertSchemaComponentExists('seo-section');
});
```

## Table Testing (v5)

```php
it('has expected table columns', function () {
    livewire(ListPosts::class)
        ->assertTableColumnExists('title')
        ->assertTableColumnVisible('title')
        ->assertTableColumnHidden('updated_at');
});

it('can check column state', function () {
    $post = Post::factory()->create(['title' => 'My Post']);

    livewire(ListPosts::class)
        ->assertTableColumnStateSet('title', 'My Post', record: $post);
});

it('has expected filters', function () {
    livewire(ListPosts::class)
        ->assertTableFilterExists('status')
        ->assertTableFilterVisible('status');
});
```

## Action Testing (v5 with TestAction)

```php
use Filament\Testing\TestAction;

it('can call page action', function () {
    $post = Post::factory()->create(['status' => 'draft']);

    livewire(EditPost::class, ['record' => $post->getRouteKey()])
        ->callAction('publish');

    expect($post->refresh()->status)->toBe('published');
});

it('can call table row action', function () {
    $post = Post::factory()->create();

    livewire(ListPosts::class)
        ->callAction(TestAction::make('delete')->table($post));

    $this->assertModelMissing($post);
});

it('can call action with form data', function () {
    $post = Post::factory()->create();

    livewire(EditPost::class, ['record' => $post->getRouteKey()])
        ->callAction('send_notification', data: [
            'subject' => 'Test Subject',
            'message' => 'Test Message',
        ])
        ->assertHasNoActionErrors();
});

it('action visibility is correct', function () {
    $draftPost = Post::factory()->create(['status' => 'draft']);
    $publishedPost = Post::factory()->create(['status' => 'published']);

    livewire(EditPost::class, ['record' => $draftPost->getRouteKey()])
        ->assertActionVisible('publish');

    livewire(EditPost::class, ['record' => $publishedPost->getRouteKey()])
        ->assertActionHidden('publish');
});
```

## Authorization Tests

```php
it('prevents unauthorized users from viewing list', function () {
    $user = User::factory()->create(['is_admin' => false]);
    $this->actingAs($user);

    livewire(ListPosts::class)
        ->assertForbidden();
});

it('prevents unauthorized users from creating', function () {
    $user = User::factory()->create(['is_admin' => false]);
    $this->actingAs($user);

    livewire(CreatePost::class)
        ->assertForbidden();
});

it('prevents unauthorized users from editing', function () {
    $user = User::factory()->create(['is_admin' => false]);
    $post = Post::factory()->create();
    $this->actingAs($user);

    livewire(EditPost::class, ['record' => $post->getRouteKey()])
        ->assertForbidden();
});
```

## Relation Manager Tests (v5)

```php
use App\Filament\Resources\PostResource\RelationManagers\CommentsRelationManager;

it('can render relation manager', function () {
    $post = Post::factory()->create();

    livewire(CommentsRelationManager::class, [
        'ownerRecord' => $post,
        'pageClass' => EditPost::class,
    ])->assertOk();
});

it('can list related comments', function () {
    $post = Post::factory()->create();
    $comments = Comment::factory()->count(3)->create(['post_id' => $post->id]);

    livewire(CommentsRelationManager::class, [
        'ownerRecord' => $post,
        'pageClass' => EditPost::class,
    ])->assertCanSeeTableRecords($comments);
});
```

## Widget Tests

```php
it('can render stats widget', function () {
    livewire(StatsOverview::class)
        ->assertOk();
});

it('can render table widget', function () {
    $posts = Post::factory()->count(5)->create();

    livewire(LatestPosts::class)
        ->assertOk()
        ->assertCanSeeTableRecords($posts);
});
```

## Repeater Testing (v5)

```php
use Filament\Forms\Components\Repeater;

it('can test repeater state', function () {
    $undoRepeaterFake = Repeater::fake();

    $post = Post::factory()->create();
    $post->quotes()->create(['content' => 'First quote']);
    $post->quotes()->create(['content' => 'Second quote']);

    livewire(EditPost::class, ['record' => $post->getRouteKey()])
        ->assertSchemaStateSet([
            'quotes' => [
                ['content' => 'First quote'],
                ['content' => 'Second quote'],
            ],
        ]);

    $undoRepeaterFake();
});
```

## Multi-Panel & Multi-Tenant Testing

```php
use Filament\Facades\Filament;

// Set panel for testing
Filament::setCurrentPanel('app');

// Set tenant for multi-tenant tests
Filament::setTenant($team);
Filament::bootCurrentPanel();
```
