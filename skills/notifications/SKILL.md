---
name: notifications
description: Generate FilamentPHP v5 notifications including flash messages, database notifications, and broadcast notifications
---

# FilamentPHP v5 Notifications Skill

## Overview

This skill generates notifications for FilamentPHP v5 including flash (session) notifications, database notifications, and broadcast notifications with actions, custom icons, and colors.

## Documentation Reference

**CRITICAL:** Before generating notifications, read:
- `skills/docs/references/notifications/`

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
// In panel provider
$panel->databaseNotifications()
    ->databaseNotificationsPolling('30s') // Poll every 30 seconds
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
// In panel provider
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

// Button action
Action::make('view')
    ->button()
    ->url('/orders/123')
    ->openUrlInNewTab()

// Link action
Action::make('details')
    ->url('/orders/123')

// Close action
Action::make('dismiss')
    ->close()

// Mark as read
Action::make('mark_read')
    ->markAsRead()

// Mark as unread
Action::make('mark_unread')
    ->markAsUnread()

// Action colors
Action::make('approve')
    ->button()
    ->color('success')

// Dispatch events
Action::make('refresh')
    ->dispatch('refresh-data')

Action::make('load')
    ->dispatchTo('chart-widget', 'load-data', ['period' => 'month'])
```

## Custom Notification Views

```php
Notification::make()
    ->title('Custom notification')
    ->view('filament.notifications.custom-notification')
    ->viewData(['order' => $order])
    ->send();
```

## Notification Within Actions

Common pattern - send notification after action completes:

```php
use Filament\Actions\Action;
use Filament\Notifications\Notification;

Action::make('approve')
    ->requiresConfirmation()
    ->action(function (Model $record): void {
        $record->update(['status' => 'approved']);

        Notification::make()
            ->title('Order approved')
            ->success()
            ->send();

        // Also notify the customer
        Notification::make()
            ->title('Your order has been approved')
            ->body("Order #{$record->number} is now being processed.")
            ->sendToDatabase($record->customer);
    })
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
