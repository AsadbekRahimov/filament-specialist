---
name: filament-notification
description: Generate FilamentPHP v5 notifications including flash messages, database notifications, and broadcast notifications with actions and custom styling. Use when implementing user notifications, alerts, or real-time updates.
allowed-tools: Bash, Glob, Grep, Read, Write, Edit
argument-hint: "<NotificationType> [flash|database|broadcast]"
---

# Generate Filament v5 Notifications

## Process

1. **Consult Documentation**: Read `${CLAUDE_SKILL_DIR}/../filament-docs/references/notifications/`
2. **Determine Type**: Flash (session), database, or broadcast notification
3. **Configure Content**: Title, body, icon, color
4. **Add Actions**: Buttons, links, mark-as-read
5. **Send**: To current user or to specific recipients

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
Notification::make()
    ->title('Record deleted')
    ->body('The post has been moved to trash.')
    ->success()
    ->actions([
        \Filament\Notifications\Actions\Action::make('undo')
            ->button()
            ->color('gray')
            ->url(route('posts.restore', $post)),
        \Filament\Notifications\Actions\Action::make('view')
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
php artisan notifications:table
php artisan migrate
```

Ensure your User model uses the `Notifiable` trait and enable in panel:
```php
$panel->databaseNotifications()
```

### Sending Database Notifications
```php
use Filament\Notifications\Notification;

$recipient = auth()->user();

Notification::make()
    ->title('New order received')
    ->body("Order #{$order->number} from {$order->customer->name}")
    ->icon('heroicon-o-shopping-bag')
    ->success()
    ->actions([
        \Filament\Notifications\Actions\Action::make('view')
            ->url(OrderResource::getUrl('edit', ['record' => $order]))
            ->button(),
        \Filament\Notifications\Actions\Action::make('mark_read')
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
```

### Unread Notification Count Badge
```php
$panel->databaseNotifications()
    ->unreadDatabaseNotificationsCount()
```

## Broadcast Notifications (Real-Time)

### Setup
```bash
composer require laravel/echo pusher/pusher-php-server
```

```php
$panel->broadcasting()
```

### Sending Real-Time Notifications
```php
Notification::make()
    ->title('New message from ' . $sender->name)
    ->body($message->excerpt)
    ->broadcast($recipient);
```

### Send Both Database + Broadcast
```php
Notification::make()
    ->title('New comment on your post')
    ->body($comment->body)
    ->success()
    ->actions([
        \Filament\Notifications\Actions\Action::make('view')
            ->url(PostResource::getUrl('edit', ['record' => $post])),
    ])
    ->sendToDatabase($recipient)
    ->broadcast($recipient);
```

## Notification Actions

```php
use Filament\Notifications\Actions\Action;

Action::make('view')->button()->url('/orders/123')->openUrlInNewTab()
Action::make('details')->url('/orders/123')
Action::make('dismiss')->close()
Action::make('mark_read')->markAsRead()
Action::make('mark_unread')->markAsUnread()
Action::make('approve')->button()->color('success')
Action::make('refresh')->dispatch('refresh-data')
Action::make('load')->dispatchTo('chart-widget', 'load-data', ['period' => 'month'])
```

## JavaScript Notification API (v4.5+/v5)

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
        new FilamentNotificationAction('View')
            .url('/files/123')
            .button(),
        new FilamentNotificationAction('Dismiss')
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

```php
use Filament\Notifications\Livewire\Notifications;
use Filament\Notifications\NotificationsPosition;

Notifications::position(NotificationsPosition::TopCenter);
// Options: TopLeft, TopCenter, TopRight, BottomLeft, BottomCenter, BottomRight

use Filament\Notifications\Livewire\DatabaseNotifications;
use Filament\Notifications\DatabaseNotificationsPosition;

DatabaseNotifications::position(DatabaseNotificationsPosition::Sidebar);
```

## Testing Notifications

```php
use Filament\Notifications\Notification;

it('sends notification on approval', function () {
    $order = Order::factory()->create(['status' => 'pending']);

    livewire(EditOrder::class, ['record' => $order->getRouteKey()])
        ->callAction('approve');

    Notification::assertSentTo($order->customer, function (Notification $notification) {
        return $notification->getTitle() === 'Your order has been approved';
    });
});
```

## Complete Example

```php
<?php

declare(strict_types=1);

namespace App\Services;

use App\Models\Order;
use App\Models\User;
use Filament\Notifications\Actions\Action;
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
                Action::make('mark_read')
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
