$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Drawing

$outPath = Join-Path $PSScriptRoot '..\docs\er_diagram.png'

$width = 1900
$height = 1150

$bmp = New-Object System.Drawing.Bitmap($width, $height)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.Clear([System.Drawing.Color]::White)

$titleFont = New-Object System.Drawing.Font('Segoe UI', 13, [System.Drawing.FontStyle]::Bold)
$font = New-Object System.Drawing.Font('Segoe UI', 9)
$headerFont = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]::Bold)

$borderPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(55, 55, 55), 2)
$linePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(130, 130, 130), 1)
$boxBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(248, 248, 248))
$headerBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(230, 240, 255))
$textBrush = [System.Drawing.Brushes]::Black

function New-Box {
  param(
    [Parameter(Mandatory)] [string] $Id,
    [Parameter(Mandatory)] [int] $X,
    [Parameter(Mandatory)] [int] $Y,
    [Parameter(Mandatory)] [int] $W,
    [Parameter(Mandatory)] [int] $H,
    [Parameter(Mandatory)] [string] $Title,
    [Parameter(Mandatory)] [string[]] $Lines
  )

  $rect = New-Object System.Drawing.Rectangle($X, $Y, $W, $H)
  $g.FillRectangle($boxBrush, $rect)
  $g.DrawRectangle($borderPen, $rect)

  $hdr = New-Object System.Drawing.Rectangle($X, $Y, $W, 26)
  $g.FillRectangle($headerBrush, $hdr)
  $g.DrawRectangle($linePen, $hdr)

  $g.DrawString($Title, $headerFont, $textBrush, $X + 8, $Y + 4)

  $yy = $Y + 34
  foreach ($ln in $Lines) {
    $g.DrawString($ln, $font, $textBrush, $X + 10, $yy)
    $yy += 15
  }

  return [pscustomobject]@{
    id = $Id
    x = $X; y = $Y; w = $W; h = $H
    cx = [int]($X + ($W / 2))
    cy = [int]($Y + ($H / 2))
  }
}

function Connect {
  param(
    [Parameter(Mandatory)] $A,
    [Parameter(Mandatory)] $B
  )
  $g.DrawLine($linePen, $A.cx, $A.cy, $B.cx, $B.cy)
}

$users = New-Box -Id 'users' -X 30 -Y 30 -W 320 -H 205 -Title 'users' -Lines @(
  'id (uuid PK)'
  'phone (unique)'
  'email (unique nullable)'
  'role'
  'status'
)

$customerProfiles = New-Box -Id 'customer_profiles' -X 380 -Y 30 -W 360 -H 165 -Title 'customer_profiles' -Lines @(
  'user_id (unique FK users)'
  'full_name'
  'default_address_id (FK addresses)'
)

$driverProfiles = New-Box -Id 'driver_profiles' -X 380 -Y 220 -W 360 -H 175 -Title 'driver_profiles' -Lines @(
  'user_id (unique FK users)'
  'approval_status'
  'vehicle_type'
  'is_online'
)

$driverDocs = New-Box -Id 'driver_documents' -X 770 -Y 235 -W 360 -H 150 -Title 'driver_documents' -Lines @(
  'driver_profile_id (FK)'
  'doc_type'
  'file_url'
  'status'
)

$addresses = New-Box -Id 'addresses' -X 770 -Y 30 -W 360 -H 165 -Title 'addresses' -Lines @(
  'user_id (FK users)'
  'address_text'
  'latitude'
  'longitude'
)

$restaurants = New-Box -Id 'restaurants' -X 30 -Y 290 -W 320 -H 155 -Title 'restaurants' -Lines @(
  'name'
  'latitude'
  'longitude'
  'status'
)

$openingHours = New-Box -Id 'opening_hours' -X 380 -Y 420 -W 360 -H 155 -Title 'opening_hours' -Lines @(
  'restaurant_id (FK)'
  'day_of_week'
  'open_time / close_time'
  'is_closed'
)

$menuCategories = New-Box -Id 'menu_categories' -X 380 -Y 605 -W 360 -H 140 -Title 'menu_categories' -Lines @(
  'restaurant_id (FK)'
  'name'
  'is_active'
)

$menuItems = New-Box -Id 'menu_items' -X 770 -Y 605 -W 360 -H 155 -Title 'menu_items' -Lines @(
  'category_id (FK)'
  'name'
  'price'
  'is_available'
)

$orders = New-Box -Id 'orders' -X 30 -Y 480 -W 320 -H 255 -Title 'orders' -Lines @(
  'order_number (unique)'
  'customer_user_id (FK users)'
  'restaurant_id (FK)'
  'assigned_driver_user_id (FK users)'
  'status'
  'delivery_fee / driver_payout / platform_fee'
)

$orderItems = New-Box -Id 'order_items' -X 30 -Y 765 -W 320 -H 195 -Title 'order_items' -Lines @(
  'order_id (FK)'
  'menu_item_id (nullable FK)'
  'item_name (snapshot)'
  'unit_price (snapshot)'
  'quantity'
)

$payments = New-Box -Id 'payments' -X 380 -Y 790 -W 360 -H 170 -Title 'payments' -Lines @(
  'order_id (FK)'
  'provider_reference (unique)'
  'amount'
  'status'
)

$events = New-Box -Id 'delivery_events' -X 770 -Y 790 -W 360 -H 185 -Title 'delivery_events' -Lines @(
  'order_id (FK)'
  'event_type'
  'actor_user_id (FK users)'
  'created_at'
)

$notifications = New-Box -Id 'notifications' -X 1160 -Y 30 -W 380 -H 165 -Title 'notifications' -Lines @(
  'user_id (FK users)'
  'channel'
  'title / body'
  'is_read'
)

$deviceTokens = New-Box -Id 'device_tokens' -X 1160 -Y 220 -W 380 -H 145 -Title 'device_tokens' -Lines @(
  'user_id (FK users)'
  'token (unique)'
  'platform'
  'is_active'
)

$pricingConfigs = New-Box -Id 'pricing_configs' -X 1160 -Y 420 -W 380 -H 160 -Title 'pricing_configs' -Lines @(
  'channel'
  'base_fee'
  'per_km_rate'
  'min_fee'
  'service_charge'
)

$operationalConfigs = New-Box -Id 'operational_configs' -X 1160 -Y 605 -W 380 -H 145 -Title 'operational_configs' -Lines @(
  'key (unique)'
  'value'
  'value_type'
  'updated_at'
)

Connect $users $customerProfiles
Connect $users $driverProfiles
Connect $driverProfiles $driverDocs
Connect $users $addresses

Connect $restaurants $openingHours
Connect $restaurants $menuCategories
Connect $menuCategories $menuItems

Connect $orders $orderItems
Connect $orders $payments
Connect $orders $events

Connect $users $notifications
Connect $users $deviceTokens

Connect $customerProfiles $addresses
Connect $orders $users
Connect $orders $restaurants
Connect $orderItems $menuItems
Connect $events $users
$g.DrawString('ER Diagram (MVP) — Kech Delivery App', $titleFont, $textBrush, 30, 1085)

$bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$bmp.Dispose()

$titleFont.Dispose()
$font.Dispose()
$headerFont.Dispose()
$borderPen.Dispose()
$linePen.Dispose()
$boxBrush.Dispose()
$headerBrush.Dispose()

Write-Output "Wrote $outPath"

