---
name: dashboard
description: Generate FilamentPHP v5 dashboard pages with widgets, tabs, filters, and custom content
---

# FilamentPHP v5 Dashboard Skill

## Overview

This skill generates dashboard pages for FilamentPHP v5 with widgets, multi-tab layouts, filters, and custom content.

## Documentation Reference

**CRITICAL:** Before generating dashboards, read:
- `skills/docs/references/widgets/`
- `skills/docs/references/general/03-resources/11-widgets.md`

## Default Dashboard

```php
<?php

declare(strict_types=1);

namespace App\Filament\Pages;

use App\Filament\Widgets;
use Filament\Pages\Dashboard as BaseDashboard;

class Dashboard extends BaseDashboard
{
    protected static ?string $navigationIcon = 'heroicon-o-home';

    public function getWidgets(): array
    {
        return [
            Widgets\StatsOverview::class,
            Widgets\RevenueChart::class,
            Widgets\LatestOrders::class,
        ];
    }

    public function getColumns(): int | string | array
    {
        return 2;
    }
}
```

## Multi-Tab Dashboard

```php
<?php

declare(strict_types=1);

namespace App\Filament\Pages;

use App\Filament\Widgets;
use Filament\Pages\Dashboard as BaseDashboard;
use Filament\Schemas\Components\Tabs\Tab;

class Dashboard extends BaseDashboard
{
    public function getTabs(): array
    {
        return [
            'overview' => Tab::make('Overview')
                ->icon('heroicon-o-chart-bar'),
            'analytics' => Tab::make('Analytics')
                ->icon('heroicon-o-presentation-chart-line'),
            'reports' => Tab::make('Reports')
                ->icon('heroicon-o-document-chart-bar'),
        ];
    }

    public function getWidgets(): array
    {
        return match ($this->activeTab) {
            'analytics' => [
                Widgets\TrafficChart::class,
                Widgets\ConversionChart::class,
            ],
            'reports' => [
                Widgets\MonthlyReport::class,
            ],
            default => [
                Widgets\StatsOverview::class,
                Widgets\RevenueChart::class,
                Widgets\LatestOrders::class,
            ],
        };
    }
}
```

## Dashboard with Filters

```php
<?php

declare(strict_types=1);

namespace App\Filament\Pages;

use Filament\Forms\Components\DatePicker;
use Filament\Forms\Components\Select;
use Filament\Pages\Dashboard as BaseDashboard;
use Filament\Pages\Dashboard\Concerns\HasFiltersForm;
use Filament\Schemas\Schema;

class Dashboard extends BaseDashboard
{
    use HasFiltersForm;

    public function filtersForm(Schema $schema): Schema
    {
        return $schema->components([
            Select::make('period')
                ->options([
                    'today' => 'Today',
                    'week' => 'This Week',
                    'month' => 'This Month',
                    'quarter' => 'This Quarter',
                    'year' => 'This Year',
                ])
                ->default('month'),
            DatePicker::make('startDate'),
            DatePicker::make('endDate'),
        ]);
    }
}
```

## Widget Using Dashboard Filters

```php
<?php

declare(strict_types=1);

namespace App\Filament\Widgets;

use Filament\Widgets\Concerns\InteractsWithPageFilters;
use Filament\Widgets\StatsOverviewWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class FilteredStats extends StatsOverviewWidget
{
    use InteractsWithPageFilters;

    protected function getStats(): array
    {
        $startDate = $this->filters['startDate'] ?? null;
        $endDate = $this->filters['endDate'] ?? null;

        $query = Order::query()
            ->when($startDate, fn ($q) => $q->where('created_at', '>=', $startDate))
            ->when($endDate, fn ($q) => $q->where('created_at', '<=', $endDate));

        return [
            Stat::make('Orders', $query->count()),
            Stat::make('Revenue', '$' . number_format($query->sum('total') / 100, 2)),
        ];
    }
}
```

## Custom Page

```php
<?php

declare(strict_types=1);

namespace App\Filament\Pages;

use Filament\Pages\Page;

class Settings extends Page
{
    protected static ?string $navigationIcon = 'heroicon-o-cog-6-tooth';
    protected static ?string $navigationGroup = 'Settings';
    protected static string $view = 'filament.pages.settings';
}
```

## Registration in Panel Provider

```php
->pages([
    Dashboard::class,
])
->widgets([
    Widgets\StatsOverview::class,
    Widgets\RevenueChart::class,
])
```
