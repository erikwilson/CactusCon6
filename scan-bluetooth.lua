local Scrollable = require('scrollable')

local function scanBluetooth()
  local lines = {
    'DATA',
    '-------------------------------------------------------------------------------------',
  }
  local mapping = {}
  local finished = false
  local display = false
  local doScan = nil
  local scrollable = Scrollable:new({lines=lines, callback=function()
    finished = true
    require('main-menu')()
  end})


  -- 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7
  -- 0300fe0425a4ae30121108436163747573436f6e362e6261646765d7

  local function showScan(data)
    if data == nil then return end

    if finished then
      bthci.scan.enable(0)
      return
    end

    print("ADV: "..encoder.toHex(data))

    local length = data:byte(10)
    local dataType = data:byte(11)
    local shortName = ''
    print(length,dataType)
    if length == data:len()-10 and type == 8 then
      shortName = data:sub(12)
    end

    local id = data:sub(3,8):reverse()
    if mapping[id] == nil then
      mapping[id] = #lines + 1
    end

    lines[mapping[id]] = encoder.toHex(id) .. ' ' .. shortName

    if display then scrollable:display() end
  end

  doScan = function()
    bthci.scan.on("adv_report", showScan)
  end

  registerButtons()
  bthci.scan.setparams({mode=1,interval=40,window=20})
  bthci.scan.enable(1)
  disp:clearBuffer()
  disp:drawStr(0, 62, 'BlueTooth scanning...')
  disp:sendBuffer()
  if not pcall(doScan) then
    tmr.create():alarm(1000, tmr.ALARM_SINGLE, scanBluetooth)
  end
  tmr.create():alarm(3000, tmr.ALARM_SINGLE, function()
    display = true
  end)
end

return scanBluetooth
