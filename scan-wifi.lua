local Scrollable = require('scrollable')

local function scanWifi()
  local lines = {
    'RSSI C E SSID                 BSSID',
    '---+--+-+--------------------+------------+------------------------------------------',
  }
  local mapping = {}
  local finished = false
  local display = false
  local doScan = nil
  local scrollable = Scrollable:new({lines=lines, callback=function()
    finished = true
    require('main-menu')()
  end})

  local function showScan(err, scaninfo)
    if err ~= nil then return doScan() end

    if finished then
      wifi.stop()
      wifi.mode(wifi.NULLMODE)
      return
    end

    for i, ap in ipairs(scaninfo) do
      local ssid = string.format("%-20.20s", ap.ssid)

      local auth = '?'
      if ap.auth == wifi.AUTH_OPEN then
        auth = 'O'
      end
      if ap.auth == wifi.AUTH_WEP then
        auth = 'W'
      end
      if ap.auth == wifi.AUTH_WPA_PSK then
        auth = '1'
      end
      if ap.auth == wifi.AUTH_WPA2_PSK then
        auth = '2'
      end
      if ap.auth == wifi.AUTH_WPA_WPA2_PSK then
        auth = 'M'
      end

      local channel = string.format("%2d", ap.channel)
      local rssi = string.format("%-3d", ap.rssi)
      local bssid = string.gsub(ap.bssid, ':', '')
      local id = channel .. bssid
      if mapping[id] == nil then
        mapping[id] = #lines + 1
      end
      lines[mapping[id]] = rssi .. ' ' .. channel .. ' ' .. auth .. ' ' .. ssid .. ' ' .. bssid
    end

    if display then scrollable:display() end
    doScan()
  end

  doScan = function()
    wifi.sta.scan({ hidden = 1 }, showScan)
  end

  registerButtons()
  wifi.mode(wifi.STATION)
  wifi.start()
  disp:clearBuffer()
  disp:drawStr(0, 10, 'O=Open, W=WEP, 1=WPA,')
  disp:drawStr(0, 20, '2=WPA2, M=WPA/WPA2')
  disp:drawStr(30, 62, 'WiFi scanning...')
  disp:sendBuffer()
  if not pcall(doScan) then
    tmr.create():alarm(1000, tmr.ALARM_SINGLE, scanWifi)
  end
  tmr.create():alarm(3000, tmr.ALARM_SINGLE, function()
    display = true
  end)
end

return scanWifi
