local disp = disp
local registerButtons = registerButtons
local setmetatable = setmetatable
local ipairs = ipairs
local tmr = tmr
local bthci = bthci

local Package = {
  selected=1,
  screenSaverTimeout=5000,
  screenSaver=require('cube'),
  advertiseBluetooth=true,
  renderCallback=nil,
  offsetX=0,
  offsetY=0,
  lineHeight=10,
  selectOffset=10,
  selectChar='>',
}
setfenv(1,Package)

Package.new = function(self, o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Package:setup()
  registerButtons()
  tmr.create():alarm(250, tmr.ALARM_SINGLE, function()
    registerButtons(function(name)
      self:buttonPress(name)
    end)
  end)
  self.screenSaverTimer = tmr.create()
  self.screenSaverTimer:register(5000, tmr.ALARM_SEMI, function()
    if self.screenSaver == nil then return end
    self.screenSaver:start()
    self.screenSaverRunning = true
  end)
  if self.advertiseBluetooth then
    bthci.adv.enable(1)
  end
  self.screenSaverTimer:start()
  self:display()
end

function Package:buttonPress(name)

  self.screenSaverTimer:stop()
  if self.screenSaver ~= nil then
    self.screenSaver:stop()
  end

  local selected = self.selected
  local items = self.items

  if name == 'center' and not self.screenSaverRunning then
    local function doCallback()
      return self.items[selected].callback()
    end
    if self.advertiseBluetooth then
      return bthci.adv.enable(0, doCallback)
    end
    return doCallback()
  end
  if name == 'up' then
    selected = selected - 1
  end
  if name == 'down' then
    selected = selected + 1
  end
  if selected > #items then
    selected = 1
  end
  if selected < 1 then
    selected = #items
  end

  self.selected = selected
  self:display()

  self.screenSaverRunning = false
  self.screenSaverTimer:start()
end

function Package:display()
  disp:clearBuffer()
  if self.renderCallback ~= nil then self.renderCallback() end
  for i, item in ipairs(self.items) do
    if self.selected == i then
      disp:drawStr(self.offsetX,self.offsetY+self.lineHeight*i,self.selectChar)
    end
    disp:drawStr(self.offsetX+self.selectOffset,self.offsetY+self.lineHeight*i,item.name)
  end
  disp:sendBuffer()
end

return Package
