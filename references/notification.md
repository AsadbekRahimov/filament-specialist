# Generate Filament v5 Notifications

## Process

1. **Consult Documentation**: Read `${CLAUDE_SKILL_DIR}/docs/references/notifications/`
2. **Determine Type**: Flash (session), database, or broadcast notification
3. **Configure Content**: Title, body, icon, color
4. **Add Actions**: Buttons, links, mark-as-read
5. **Send**: To current user or to specific recipients

**CRITICAL**: Notification action buttons use the unified `Filament\Actions\Action` class.
`Filament\Notifications\Actions\Action` does NOT exist in v5.

## Flash Notifications (Session)

### Basic Notification
```php
use Filament\Notifications\Notification;

Notification::make()
    ->title('Record saved')
    ->success()
    ->send();
```

### Full Configuration
```php
Notification::make()
    ->title('Order shipped')
    ->body('Order #12345 has been shipped to the customer.')
    ->icon('heroicon-o-truck')
    ->iconColor('success')
    ->color('success')
    ->duration(5000) // milliseconds (default: 6000)
    ->send();
```

### Status Types
```php
Notification::make()->title('Success')->success()->send();
Notification::make()->title('Warning')->warning()->send();
Notification::make()->title('Error')->danger()->send();
Notification::make()->title('Info')->info()->send();
```

### With Actions
```php
use Filament\Actions\Action;
use Filament\Notifications\Notification;

Notification::make()
    ->title('Record deleted')
    ->body('The post has been moved to trash.')
    ->success()
    ->actions([
        Action::make('undo')
            ->button()
            ->color('gray')
            ->url(route('posts.restore', $post)),
        Action::make('view')
            ->button()
            ->url(route('posts.index')),
    ])
    ->send();
```

### Persistent Notification
```php
Notification::make()
    ->title('Server error')
    ->body('Please check the logs.')
    ->danger()
    ->persistent() // Won't auto-dismiss
    ->send();
```

## Database Notifications

### Setup
```bash
php artisan make:notifications-table
php artisan migrate
```

Ensure your User model uses the `Notifiable` trait and enable in panel:
```php
$panel->databaseNotifications()
```

### Sending Database Notifications
```php
use Filament\Actions\Action;
use Filament\Notifications\Notification;

$recipient = auth()->user();

Notification::make()
    ->title('New order received')
    ->body("Order #{$order->number} from {$order->customer->name}")
    ->icon('heroicon-o-shopping-bag')
    ->success()
    ->actions([
        Action::make('view')
            ->url(OrderResource::getUrl('edit', ['record' => $order]))
            ->button(),
        Action::make('markAsRead')
            ->markAsRead(),
    ])
    ->sendToDatabase($recipient);
```

### Send to Multiple Users
```php
$admins = User::where('is_admin', true)->get();

Notification::make()
    ->title('New report available')
    ->sendToDatabase($admins);
```

### Database Notification Polling
```php
$panel->databaseNotifications()
    ->databaseNotificationsPolling('30s')

// Disable polling (e.g. when using websockets):
$panel->databaseNotifications()
    ->databaseNotificationsPolling(null)
```

### Positioning the Database Notifications Modal
```php
use Filament\Enums\DatabaseNotificationsPosition;

$panel->databaseNotifications(position: DatabaseNotificationsPosition::Sidebar)
```

## Broadcast Notifications (Real-Time)

### Setup
Requires [Laravel Echo](https://laravel.com/docs/broadcasting#client-side-installation)
plus a server-side websockets integration (Pusher, Laravel Reverb, etc.). See the
"Setting up websockets in a panel" section of the broadcast notifications docs.

### Sending Real-Time Notifications
```php
Notification::make()
    ->title('New message from ' . $sender->name)
    ->body($message->excerpt)
    ->broadcast($recipient);
```

### Send Both Database + Broadcast
```php
use Filament\Actions\Action;

Notification::make()
    ->title('New comment on your post')
    ->body($comment->body)
    ->success()
    ->actions([
        Action::make('view')
            ->url(PostResource::getUrl('edit', ['record' => $post])),
    ])
    ->sendToDatabase($recipient)
    ->broadcast($recipient);
```

## Notification Actions

```php
use Filament\Actions\Action;

Action::make('view')->button()->url('/orders/123')->openUrlInNewTab()
Action::make('details')->url('/orders/123')
Action::make('dismiss')->close()
Action::make('markAsRead')->markAsRead()
Action::make('markAsUnread')->markAsUnread()
Action::make('approve')->button()->color('success')
Action::make('refresh')->dispatch('refresh-data')
Action::make('load')->dispatchTo('chart-widget', 'load-data', ['period' => 'month'])
```

## JavaScript Notification API

Send notifications from client-side JavaScript:

```js
// Basic notification
new FilamentNotification()
    .title('Saved!')
    .success()
    .send()

// Full configuration
new FilamentNotification()
    .title('Link copied')
    .body('The URL has been copied to your clipboard.')
    .icon('heroicon-o-clipboard-document')
    .iconColor('success')
    .color('success')
    .duration(3000)
    .send()

// With actions
new FilamentNotification()
    .title('File uploaded')
    .success()
    .actions([
        new FilamentNotificationAction('view')
            .button()
            .url('/files/123')
            .openUrlInNewTab(),
        new FilamentNotificationAction('dismiss')
            .color('gray')
            .close(),
    ])
    .send()
```

### Usage in actionJs()
```php
Action::make('copy_url')
    ->icon('heroicon-o-clipboard')
    ->actionJs(<<<'JS'
        navigator.clipboard.writeText($get('url')).then(() => {
            new FilamentNotification()
                .title('URL copied!')
                .success()
                .send()
        })
    JS)
```

## Notification Positioning

Configure in a service provider or middleware using alignment methods
(there is NO `NotificationsPosition` enum):

```php
use Filament\Notifications\Livewire\Notifications;
use Filament\Support\Enums\Alignment;
use Filament\Support\Enums\VerticalAlignment;

Notifications::alignment(Alignment::Start);            // Start | Center | End
Notifications::verticalAlignment(VerticalAlignment::End); // Start | Center | End
```

## Testing Notifications

```php
use function Pest\Livewire\livewire;

it('sends notification on approval', function () {
    $order = Order::factory()->create(['status' => 'pending']);

    livewire(EditOrder::class, ['record' => $order->getRouteKey()])
        ->callAction('approve')
        ->assertNotified('Order approved');
});

// Assert against a full notification object:
use Filament\Notifications\Notification;

livewire(CreatePost::class)
    ->call('create')
    ->assertNotified(
        Notification::make()
            ->success()
            ->title('Post created'),
    );

// Outside a Livewire test:
Notification::assertNotified('Order approved');

// Or via the namespaced helper:
use function Filament\Notifications\Testing\assertNotified;

assertNotified();
```

## Complete Example

```php
<?php

declare(strict_types=1);

namespace App\Services;

use App\Models\Order;
use App\Models\User;
use Filament\Actions\Action;
use Filament\Notifications\Notification;

class OrderNotificationService
{
    public function notifyNewOrder(Order $order): void
    {
        $admins = User::where('is_admin', true)->get();

        Notification::make()
            ->title('New Order #' . $order->number)
            ->body(sprintf(
                '%s placed an order for $%s',
                $order->customer->name,
                number_format($order->total / 100, 2),
            ))
            ->icon('heroicon-o-shopping-bag')
            ->success()
            ->actions([
                Action::make('view')
                    ->label('View Order')
                    ->url(route('filament.admin.resources.orders.edit', $order))
                    ->button(),
                Action::make('markAsRead')
                    ->markAsRead(),
            ])
            ->sendToDatabase($admins)
            ->broadcast($admins);
    }

    public function notifyOrderShipped(Order $order): void
    {
        Notification::make()
            ->title('Your order has shipped!')
            ->body("Order #{$order->number} is on its way.")
            ->icon('heroicon-o-truck')
            ->info()
            ->actions([
                Action::make('track')
                    ->label('Track Shipment')
                    ->url($order->tracking_url)
                    ->button()
                    ->openUrlInNewTab(),
            ])
            ->sendToDatabase($order->customer);
    }
}
```
