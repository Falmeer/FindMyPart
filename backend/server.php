<?php

$publicPath = getcwd();

$uri = urldecode(
    parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH) ?? ''
);

// CORS is handled by Laravel's HandleCors middleware (config/cors.php).
// Do NOT add headers here — it causes duplicate Access-Control-Allow-Origin
// headers which Chrome rejects with a CORS error.

// Serve image/media files manually so the CORS headers above are actually sent.
// (When returning false the built-in server bypasses our headers for static files.)
if ($uri !== '/' && file_exists($publicPath . $uri)) {
    $ext = strtolower(pathinfo($uri, PATHINFO_EXTENSION));
    $mimes = [
        'jpg'  => 'image/jpeg',
        'jpeg' => 'image/jpeg',
        'png'  => 'image/png',
        'gif'  => 'image/gif',
        'webp' => 'image/webp',
        'svg'  => 'image/svg+xml',
    ];
    if (isset($mimes[$ext])) {
        header('Content-Type: ' . $mimes[$ext]);
        header('Cache-Control: public, max-age=86400');
        readfile($publicPath . $uri);
        exit;
    }
    return false;
}

$formattedDateTime = date('D M j H:i:s Y');
$requestMethod     = $_SERVER['REQUEST_METHOD'];
$remoteAddress     = $_SERVER['REMOTE_ADDR'] . ':' . $_SERVER['REMOTE_PORT'];
file_put_contents('php://stdout', "[$formattedDateTime] $remoteAddress [$requestMethod] URI: $uri\n");

require_once $publicPath . '/index.php';
