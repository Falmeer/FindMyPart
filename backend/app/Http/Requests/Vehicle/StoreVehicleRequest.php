<?php

namespace App\Http\Requests\Vehicle;

use Illuminate\Foundation\Http\FormRequest;

class StoreVehicleRequest extends FormRequest
{
    public function authorize(): bool { return true; }

    public function rules(): array
    {
        return [
            'brand' => 'required|string|max:100',
            'model' => 'required|string|max:100',
            'year' => 'required|integer|min:1980|max:2027',
            'engine' => 'nullable|string|max:100',
            'transmission' => 'nullable|in:Automatic,Manual',
            'mileage' => 'nullable|integer|min:0',
            'condition' => 'required|in:Used,Damaged,Parts Only',
            'vin' => 'nullable|string|size:17',
            'description' => 'required|string|min:10',
            'price' => 'nullable|numeric|min:0',
            'images' => 'nullable|array|max:10',
            'images.*' => 'image|mimes:jpeg,jpg,png,webp|max:5120',
        ];
    }
}
