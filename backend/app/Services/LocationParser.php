<?php

namespace App\Services;

class LocationParser
{
    /**
     * Parse any Google Maps URL (long, short, or directions) and return [lat, lng] or null.
     */
    public static function fromMapsUrl(string $url): ?array
    {
        $url = trim($url);

        $coords = self::extractCoords($url);
        if ($coords) {
            return $coords;
        }

        if (preg_match('#goo\.gl|maps\.app\.goo\.gl|google\.com/maps|maps\.google\.com#i', $url)) {
            return self::resolveAndExtract($url);
        }

        return null;
    }

    private static function extractCoords(string $url): ?array
    {
        // @lat,lng  — standard desktop/share URL
        if (preg_match('/@(-?\d+\.\d+),(-?\d+\.\d+)/', $url, $m)) {
            return [(float) $m[1], (float) $m[2]];
        }

        // !3dLAT!4dLNG — embed links
        if (preg_match('/!3d(-?\d+\.\d+)!4d(-?\d+\.\d+)/', $url, $m)) {
            return [(float) $m[1], (float) $m[2]];
        }

        // ?q=lat,lng or &q=lat,lng
        if (preg_match('/[?&]q=(-?\d+\.\d+),(-?\d+\.\d+)/', $url, $m)) {
            return [(float) $m[1], (float) $m[2]];
        }

        // ll=lat,lng — older format
        if (preg_match('/[?&]ll=(-?\d+\.\d+),(-?\d+\.\d+)/', $url, $m)) {
            return [(float) $m[1], (float) $m[2]];
        }

        // !2dLNG!3dLAT — pb= parameter (raw or URL-encoded as %21 in HTML body)
        if (preg_match('/(?:!|%21)2d(-?\d+\.\d+)(?:!|%21)3d(-?\d+\.\d+)/', $url, $m)) {
            $lng = (float) $m[1];
            $lat = (float) $m[2];
            if ($lat >= -90 && $lat <= 90 && $lng >= -180 && $lng <= 180) {
                return [$lat, $lng];
            }
        }

        return null;
    }

    /**
     * Follow redirects (handles goo.gl short links) then scan the final URL and
     * page HTML body for embedded coordinates.
     */
    private static function resolveAndExtract(string $url): ?array
    {
        if (! function_exists('curl_init')) {
            return null;
        }

        $ch = curl_init($url);
        curl_setopt_array($ch, [
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_FOLLOWLOCATION => true,
            CURLOPT_MAXREDIRS      => 6,
            CURLOPT_TIMEOUT        => 10,
            CURLOPT_USERAGENT      => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            CURLOPT_SSL_VERIFYPEER => false,
            CURLOPT_ENCODING       => '',   // accept gzip/deflate
        ]);

        $body     = curl_exec($ch);
        $finalUrl = curl_getinfo($ch, CURLINFO_EFFECTIVE_URL);
        curl_close($ch);

        // Check the resolved URL after any server-side redirects
        if ($finalUrl && $finalUrl !== $url) {
            $coords = self::extractCoords($finalUrl);
            if ($coords) {
                return $coords;
            }
        }

        if (! $body) {
            return null;
        }

        // 1. JSON-LD schema.org GeoCoordinates — exact place pin (most accurate)
        if (preg_match('/"latitude"\s*:\s*(-?\d+(?:\.\d+)?)[^}]{0,80}"longitude"\s*:\s*(-?\d+(?:\.\d+)?)/', $body, $m)) {
            $lat = (float) $m[1];
            $lng = (float) $m[2];
            if ($lat >= -90 && $lat <= 90 && $lng >= -180 && $lng <= 180) {
                return [$lat, $lng];
            }
        }

        // 2. @lat,lng,Xz embedded in page HTML
        if (preg_match('/@(-?\d+\.\d+),(-?\d+\.\d+),\d+(?:\.\d+)?z/', $body, $m)) {
            return [(float) $m[1], (float) $m[2]];
        }

        // 3. !2dLNG!3dLAT from pb= — may be viewport center, last resort
        if (preg_match('/(?:!|%21)2d(-?\d+\.\d+)(?:!|%21)3d(-?\d+\.\d+)/', $body, $m)) {
            $lng = (float) $m[1];
            $lat = (float) $m[2];
            if ($lat >= -90 && $lat <= 90 && $lng >= -180 && $lng <= 180) {
                return [$lat, $lng];
            }
        }

        return null;
    }
}
