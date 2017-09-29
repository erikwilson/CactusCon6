local Scrollable = require('scrollable')

local function scanBluetooth()
  local lines = {
    'RSSI Address      Name',
    '-------------------------------------------------------------------------------------',
  }
  local mapping = {}
  local finished = false
  local display = false
  local doScan = nil
  local scrollable = Scrollable:new({lines=lines, callback=function()
    finished = true
    bthci.scan.enable(0, require('main-menu'))
  end})

  local function showScan(data)
    if data == nil then return end

    if finished then
      return
    end

    print(encoder.toHex(data))

    local length = data:byte(10)
    local dataType = data:byte(11)
    local name = ''
    local isNameData = dataType == 8 or dataType == 9
    if length == data:len()-11 and isNameData then
      name = data:sub(12,-2)
    end
    local rssi = string.format("%-4d", data:byte(-1)-255)
    local id = data:sub(3,8):reverse()
    if mapping[id] == nil then
      mapping[id] = #lines + 1
    end

    lines[mapping[id]] = rssi .. ' ' .. encoder.toHex(id) .. ' ' .. name
    if display then scrollable:display() end
  end

  doScan = function()
    bthci.scan.on("adv_report", showScan)
  end

  registerButtons()
  bthci.scan.enable(1)
  disp:clearBuffer()
  disp:drawStr(0, 31, 'BlueTooth scanning...')
  disp:sendBuffer()
  if not pcall(doScan) then
    tmr.create():alarm(1000, tmr.ALARM_SINGLE, scanBluetooth)
  end
  tmr.create():alarm(3000, tmr.ALARM_SINGLE, function()
    display = true
  end)
end

return scanBluetooth
