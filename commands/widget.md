---
description: Create FilamentPHP v5 dashboard widgets including stats, charts, and table widgets
allowed-tools: ["Bash", "Glob", "Grep", "Read", "Write", "Edit"]
argument-hint: "<WidgetName> as <stats|chart|table|custom>"
---

# Create Filament v5 Widget

## Process

1. **Consult Documentation**: Read `skills/docs/references/widgets/`
2. **Determine Widget Type**: Stats overview, chart, table, or custom
3. **Generate Base**: Use `php artisan make:filament-widget`
4. **Implement Logic**: Configure data sources and display
5. **Register Widget**: Add to panel provider or resource page

## Artisan Commands

```bash
# Stats overview widget
php artisan make:filament-widget StatsOverview --stats-overview

# Chart widget
php artisan make:filament-widget RevenueChart --chart

# Table widget
php artisan make:filament-widget LatestOrders --table

# Custom widget
php artisan make:filament-widget Welcome

# Resource-specific widget
php artisan make:filament-widget CustomerStats --resource=CustomerResource
```

## Stats Overview Widget

```php
<?php

declare(strict_types=1);

namespace App\Filament\Widgets;

use App\Models\Order;
use App\Models\User;
use Filament\Widgets\StatsOverviewWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class StatsOverview extends StatsOverviewWidget
{
    protected function getStats(): array
    {
        return [
            Stat::make('Total Users', User::count())
                ->description('32 new this week')
                ->descriptionIcon('heroicon-m-arrow-trending-up')
                ->color('success')
                ->chart([7, 3, 4, 5, 6, 3, 5, 8]),

            Stat::make('Revenue', '$' . number_format(Order::sum('total') / 100, 2))
                ->description('7% increase')
                ->descriptionIcon('heroicon-m-arrow-trending-up')
                ->color('success'),

            Stat::make('Pending Orders', Order::where('status', 'pending')->count())
                ->description('3 urgent')
                ->descriptionIcon('heroicon-m-exclamation-triangle')
                ->color('warning'),
        ];
    }
}
```

## Chart Widget

```php
<?php

declare(strict_types=1);

namespace App\Filament\Widgets;

use App\Models\Order;
use Filament\Widgets\ChartWidget;
use Flowframe\Trend\Trend;
use Flowframe\Trend\TrendValue;

class RevenueChart extends ChartWidget
{
    protected static ?string $heading = 'Revenue';

    protected static ?string $pollingInterval = '30s';

    protected static ?string $maxHeight = '300px';

    public ?string $filter = 'month';

    protected function getFilters(): ?array
    {
        return [
            'week' => 'Last Week',
            'month' => 'Last Month',
            'quarter' => 'Last Quarter',
            'year' => 'This Year',
        ];
    }

    protected function getData(): array
    {
        $start = match ($this->filter) {
            'week' => now()->subWeek(),
            'month' => now()->subMonth(),
            'quarter' => now()->subQuarter(),
            'year' => now()->startOfYear(),
        };

        $data = Trend::model(Order::class)
            ->between(start: $start, end: now())
            ->perDay()
            ->sum('total');

        return [
            'datasets' => [
                [
                    'label' => 'Revenue',
                    'data' => $data->map(fn (TrendValue $value) => $value->aggregate / 100),
                    'fill' => true,
                    'backgroundColor' => 'rgba(59, 130, 246, 0.1)',
                    'borderColor' => 'rgb(59, 130, 246)',
                ],
            ],
            'labels' => $data->map(fn (TrendValue $value) => $value->date),
        ];
    }

    protected function getType(): string
    {
        return 'line'; // line, bar, doughnut, pie, radar, polarArea, scatter, bubble
    }
}
```

## Table Widget

```php
<?php

declare(strict_types=1);

namespace App\Filament\Widgets;

use App\Models\Order;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;
use Filament\Widgets\TableWidget;

class LatestOrders extends TableWidget
{
    protected int | string | array $columnSpan = 'full';

    protected static ?int $sort = 2;

    public function table(Table $table): Table
    {
        return $table
            ->query(Order::query()->latest()->limit(5))
            ->columns([
                TextColumn::make('number')
                    ->searchable(),
                TextColumn::make('customer.name')
                    ->searchable(),
                TextColumn::make('total')
                    ->money('USD'),
                TextColumn::make('status')
                    ->badge()
                    ->color(fn (string $state) => match ($state) {
                        'pending' => 'warning',
                        'completed' => 'success',
                        'cancelled' => 'danger',
                    }),
                TextColumn::make('created_at')
                    ->dateTime()
                    ->since(),
            ])
            ->paginated(false);
    }
}
```

## Widget Configuration

```php
// Sort order (lower = higher on page)
protected static ?int $sort = 1;

// Column span (1, 2, 3, or 'full')
protected int | string | array $columnSpan = 'full';

// Polling interval
protected static ?string $pollingInterval = '10s';

// Lazy loading
protected static bool $isLazy = true;

// Conditional visibility
public static function canView(): bool
{
    return auth()->user()->isAdmin();
}
```

## Registration

### In Panel Provider
```php
->widgets([
    Widgets\StatsOverview::class,
    Widgets\RevenueChart::class,
    Widgets\LatestOrders::class,
])
```

### In Resource Pages
```php
// In resource class
public static function getWidgets(): array
{
    return [
        Widgets\CustomerStats::class,
    ];
}

// In ListRecords page
protected function getHeaderWidgets(): array
{
    return [
        Widgets\CustomerStats::class,
    ];
}
```
