{{--
  Reusable country-code + phone input group.
  Variables: $name (field name), $codeName (code field name), $label, $required (bool, optional)
--}}
<div>
    <label class="block text-sm font-medium text-gray-700 mb-1.5">
        {{ $label }}{{ !empty($required) ? ' *' : '' }}
    </label>
    <div class="flex">
        <select name="{{ $codeName }}"
                class="flex-shrink-0 pl-2 pr-6 py-2 border border-r-0 border-gray-300 rounded-l-lg text-sm bg-gray-50 focus:outline-none focus:ring-2 focus:ring-blue-500">
            @php
                $codes = [
                    '+973' => '🇧🇭 +973',
                    '+966' => '🇸🇦 +966',
                    '+971' => '🇦🇪 +971',
                    '+965' => '🇰🇼 +965',
                    '+974' => '🇶🇦 +974',
                    '+968' => '🇴🇲 +968',
                    '+962' => '🇯🇴 +962',
                    '+961' => '🇱🇧 +961',
                    '+964' => '🇮🇶 +964',
                    '+20'  => '🇪🇬 +20',
                    '+91'  => '🇮🇳 +91',
                    '+92'  => '🇵🇰 +92',
                    '+63'  => '🇵🇭 +63',
                    '+880' => '🇧🇩 +880',
                    '+44'  => '🇬🇧 +44',
                    '+1'   => '🇺🇸 +1',
                ];
                $selected = old($codeName, '+973');
            @endphp
            @foreach($codes as $value => $label_text)
                <option value="{{ $value }}" {{ $selected === $value ? 'selected' : '' }}>{{ $label_text }}</option>
            @endforeach
        </select>
        <input type="text" name="{{ $name }}" value="{{ old($name) }}"
               placeholder="e.g. 33399330"
               {{ !empty($required) ? 'required' : '' }}
               class="w-full px-3 py-2 border border-gray-300 rounded-r-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500">
    </div>
</div>
