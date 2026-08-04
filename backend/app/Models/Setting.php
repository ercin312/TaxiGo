<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Cache;

class Setting extends Model
{
    protected $fillable = [
        'key',
        'value',
        'type',
        'group',
    ];

    public static function getValue(string $key, mixed $default = null): mixed
    {
        return Cache::remember("setting.{$key}", 3600, function () use ($key, $default) {
            $setting = static::query()->where('key', $key)->first();

            if (! $setting) {
                return $default;
            }

            return static::castValue($setting->value, $setting->type);
        });
    }

    public static function setValue(string $key, mixed $value, string $type = 'string', string $group = 'general'): self
    {
        $setting = static::query()->updateOrCreate(
            ['key' => $key],
            [
                'value' => is_array($value) ? json_encode($value) : (string) $value,
                'type' => $type,
                'group' => $group,
            ],
        );

        Cache::forget("setting.{$key}");

        return $setting;
    }

    protected static function castValue(?string $value, string $type): mixed
    {
        return match ($type) {
            'integer', 'int' => (int) $value,
            'float', 'decimal' => (float) $value,
            'boolean', 'bool' => filter_var($value, FILTER_VALIDATE_BOOLEAN),
            'json', 'array' => json_decode($value ?? '[]', true),
            default => $value,
        };
    }
}
