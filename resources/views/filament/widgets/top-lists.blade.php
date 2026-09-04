<x-filament-widgets::widget>
    <div class="grid grid-cols-1 gap-4 lg:grid-cols-3">
        @php
            $lists = [
                ['title' => 'أفضل المتبرعين', 'icon' => 'heroicon-o-heart', 'items' => $this->getTopDonors()],
                ['title' => 'أفضل الجمعيات', 'icon' => 'heroicon-o-building-office-2', 'items' => $this->getTopCharities()],
                ['title' => 'المناطق ذات الأولوية', 'icon' => 'heroicon-o-map-pin', 'items' => $this->getPriorityZones()],
            ];
            $max = fn (array $items) => max(1, collect($items)->max('value') ?? 1);
        @endphp

        @foreach ($lists as $list)
            <x-filament::section>
                <x-slot name="heading">
                    <div class="flex items-center gap-2">
                        <x-filament::icon :icon="$list['icon']" class="h-5 w-5 text-primary-600" />
                        {{ $list['title'] }}
                    </div>
                </x-slot>

                @if (empty($list['items']))
                    <p class="text-sm text-gray-500 dark:text-gray-400">لا توجد بيانات كافية بعد.</p>
                @else
                    <ul class="flex flex-col gap-3">
                        @foreach ($list['items'] as $index => $item)
                            <li class="flex items-center gap-3">
                                <span class="flex h-6 w-6 shrink-0 items-center justify-center rounded-full bg-gray-100 text-xs font-medium dark:bg-gray-800">
                                    {{ $index + 1 }}
                                </span>
                                <div class="flex flex-1 flex-col gap-1">
                                    <div class="flex items-center justify-between text-sm">
                                        <span class="truncate font-medium">{{ $item['label'] }}</span>
                                        <span class="text-gray-500 dark:text-gray-400">{{ $item['value'] }}</span>
                                    </div>
                                    <div class="h-1.5 w-full overflow-hidden rounded-full bg-gray-100 dark:bg-gray-800">
                                        <div
                                            class="h-full rounded-full bg-primary-600"
                                            style="width: {{ ($item['value'] / $max($list['items'])) * 100 }}%"
                                        ></div>
                                    </div>
                                </div>
                            </li>
                        @endforeach
                    </ul>
                @endif
            </x-filament::section>
        @endforeach
    </div>
</x-filament-widgets::widget>
