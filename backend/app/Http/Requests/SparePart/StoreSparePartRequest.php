<?php

namespace App\Http\Requests\SparePart;

use Illuminate\Foundation\Http\FormRequest;

class StoreSparePartRequest extends FormRequest
{
    public function authorize(): bool { return true; }

    public function rules(): array
    {
        return [
            'category_id' => 'required|exists:categories,id',
            'name' => 'required|string|max:255',
            'condition' => 'required|in:New,Used,Refurbished',
            'price' => 'required|numeric|min:0',
            'quantity' => 'nullable|integer|min:1',
            'description' => 'required|string|min:10',
            'compatibility' => 'nullable|string|max:255',
            'has_warranty' => 'nullable|boolean',
            'images' => 'nullable|array|max:10',
            'images.*' => 'image|mimes:jpeg,jpg,png,webp|max:5120',
        ];
    }
}
