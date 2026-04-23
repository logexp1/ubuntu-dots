#!/usr/bin/env python3

import json
import urllib.request

# Set your city name, or leave empty for IP-based auto-detection
LOCATION = ""

weather_icons = {
    "sunnyDay":        "󰖙",
    "clearNight":      "󰖔",
    "cloudyFoggyDay":  "󰖐",
    "cloudyFoggyNight":"󰖑",
    "rainyDay":        "󰼳",
    "rainyNight":      "󰖗",
    "snowyIcyDay":     "󰼴",
    "snowyIcyNight":   "󰖘",
    "severe":          "󰖓",
    "default":         "󰖚",
}

def code_to_status(code, is_night=False):
    code = int(code)
    if code == 113:
        return "clearNight" if is_night else "sunnyDay"
    elif code in (116, 119, 122, 143, 248, 260):
        return "cloudyFoggyNight" if is_night else "cloudyFoggyDay"
    elif code in range(176, 282):
        return "rainyNight" if is_night else "rainyDay"
    elif code in range(282, 395):
        if code >= 386:
            return "severe"
        if code in (323, 326, 329, 332, 335, 338, 350, 368, 371, 374, 377):
            return "snowyIcyNight" if is_night else "snowyIcyDay"
        return "rainyNight" if is_night else "rainyDay"
    elif code == 200:
        return "severe"
    return "default"

url = f"https://wttr.in/{LOCATION}?format=j1"
try:
    with urllib.request.urlopen(url, timeout=10) as r:
        data = json.loads(r.read())
except Exception as e:
    print(json.dumps({"text": "N/A", "alt": "unavailable", "tooltip": str(e), "class": "default"}))
    raise SystemExit

current = data["current_condition"][0]
today   = data["weather"][0]

temp        = current["temp_C"]
feels_like  = current["FeelsLikeC"]
humidity    = current["humidity"]
wind        = current["windspeedKmph"]
visibility  = current["visibility"]
status      = current["weatherDesc"][0]["value"]
status      = f"{status[:16]}.." if len(status) > 17 else status
temp_min    = today["mintempC"]
temp_max    = today["maxtempC"]

code       = current["weatherCode"]
status_key = code_to_status(code)
icon       = weather_icons.get(status_key, weather_icons["default"])

tooltip = (
    f"\t\t<span size='xx-large'>{temp}°C</span>\t\t\n"
    f"<big> {icon}</big>\n"
    f"<b>{status}</b>\n"
    f"<small>Feels like {feels_like}°C</small>\n\n"
    f"<b>  {temp_min}°C\t\t  {temp_max}°C</b>\n"
    f"  {wind} km/h\t  {humidity}%\n"
    f"  {visibility} km"
)

print(json.dumps({
    "text":    f"{icon} {temp}°C",
    "alt":     status,
    "tooltip": tooltip,
    "class":   status_key,
}))
