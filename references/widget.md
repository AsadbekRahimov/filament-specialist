# Create Filament v5 Widget

## Process

1. **Consult Documentation**: Read `${CLAUDE_SKILL_DIR}/docs/references/widgets/`
2. **Determine Widget Type**: Stats overview, chart, table, or custom
3. **Generate Base**: Use `php artisan make:filament-widget`
4. **Implement Logic**: Configure data sources and display
5. **Register Widget**: Add to panel provider or resource page

## Artisan Commands

```bash
php artisan make:filament-widget StatsOverview --stats-overview
php artisan make:filament-widget RevenueChart --chart
php artisan make:filament-widget LatestOrders --table
php artisan make:filament-widget Welcome
php artisan make:filament-widget OrderStats --resource=OrderResource
```

## Stats Overview Widget

```php
<?php

declare(strict_types=1);

namespace App\Filament\Widgets;

use App\Models\Customer;
use App\Models\Order;
use Filament\Widgets\StatsOverviewWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class StatsOverview extends StatsOverviewWidget
{
    protected function getStats(): array
    {
        return [
            Stat::make('Total Customers', Customer::count())
                ->description('12 new this week')
                ->descriptionIcon('heroicon-m-arrow-trending-up')
                ->color('success')
                ->chart([7, 3, 4, 5, 6, 3, 5, 8])
                ->url(route('filament.admin.resources.customers.index')),

            Stat::make('Revenue', '$' . number_format(Order::sum('total') / 100, 2))
                ->description('7% increase from last month')
                ->descriptionIcon('heroicon-m-arrow-trending-up')
                ->color('success'),

            Stat::make('Pending Orders', Order::where('status', 'pending')->count())
                ->description('3 need attention')
                ->descriptionIcon('heroicon-m-exclamation-triangle')
                ->color('warning'),

            Stat::make('Avg Order Value', '$' . number_format(Order::avg('total') / 100, 2))
                ->description('$5 more than last month')
                ->descriptionIcon('heroicon-m-arrow-trending-up')
                ->color('info'),
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
    protected ?string $heading = 'Monthly Revenue';
    protected ?string $description = 'Revenue trend over time';
    protected static ?string $maxHeight = '300px';
    protected static ?string $pollingInterval = '30s';

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
        return 'line';
    }
}
```

### Chart Types
- `line` - Line chart
- `bar` - Bar chart
- `doughnut` - Doughnut chart
- `pie` - Pie chart
- `radar` - Radar chart
- `polarArea` - Polar area chart
- `scatter` - Scatter plot
- `bubble` - Bubble chart

### Multiple Datasets
```php
protected function getData(): array
{
    return [
        'datasets' => [
            [
                'label' => 'Revenue',
                'data' => [2500, 3000, 3500, 4000, 3800, 4200],
                'borderColor' => 'rgb(59, 130, 246)',
            ],
            [
                'label' => 'Expenses',
                'data' => [1500, 1800, 2000, 1900, 2100, 2300],
                'borderColor' => 'rgb(239, 68, 68)',
            ],
        ],
        'labels' => ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
    ];
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
            ->query(Order::query()->latest()->limit(10))
            ->columns([
                TextColumn::make('number')->searchable(),
                TextColumn::make('customer.name')->searchable(),
                TextColumn::make('total')->money('USD'),
                TextColumn::make('status')
                    ->badge()
                    ->color(fn (string $state) => match ($state) {
                        'pending' => 'warning',
                        'processing' => 'info',
                        'completed' => 'success',
                        'cancelled' => 'danger',
                    }),
                TextColumn::make('created_at')->dateTime()->since(),
            ])
            ->paginated(false);
    }
}
```

## Widget Configuration

```php
// Sort order (lower = higher on dashboard)
protected static ?int $sort = 1;

// Column span
protected int | string | array $columnSpan = 'full';  // 'full', 1, 2, 3
protected int | string | array $columnSpan = [
    'md' => 2,
    'xl' => 3,
];

// Polling
protected static ?string $pollingInterval = '10s';
protected static ?string $pollingInterval = null; // Disable

// Lazy loading
protected static bool $isLazy = true;

// Visibility
public static function canView(): bool
{
    return auth()->user()->isAdmin();
}
```

## Dashboard Registration

### In Panel Provider
```php
->widgets([
    StatsOverview::class,
    RevenueChart::class,
    LatestOrders::class,
])
```

### In Resource Pages
```php
// Resource class
public static function getWidgets(): array
{
    return [CustomerStats::class];
}

// List page
protected function getHeaderWidgets(): array
{
    return [CustomerStats::class];
}

protected function getFooterWidgets(): array
{
    return [CustomerActivity::class];
}
```

## Dashboard Filters

```php
// In Dashboard page
use Filament\Pages\Dashboard\Concerns\HasFiltersForm;

class Dashboard extends BaseDashboard
{
    use HasFiltersForm;

    public function filtersForm(Schema $schema): Schema
    {
        return $schema->components([
            DatePicker::make('startDate'),
            DatePicker::make('endDate'),
        ]);
    }
}

// In Widget
use Filament\Widgets\Concerns\InteractsWithPageFilters;

class FilteredStats extends StatsOverviewWidget
{
    use InteractsWithPageFilters;

    protected function getStats(): array
    {
        $startDate = $this->filters['startDate'] ?? null;
        $endDate = $this->filters['endDate'] ?? null;
        // Use filters in queries...
    }
}
```
