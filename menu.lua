local disp = disp
local registerButtons = registerButtons
local setmetatable = setmetatable
local ipairs = ipairs
local tmr = tmr

local Package = {
  selected=1,
  screenSaverTimeout=5000,
  screenSaver=require('cube'),
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
  self.screenSaverTimer:start()
  self:display()
end

function Package:buttonPress(name)

  if self.screenSaver ~= nil then
    self.screenSaver:stop()
    self.screenSaverTimer:stop()
  end

  local selected = self.selected
  local items = self.items

  if name == 'center' and not self.screenSaverRunning then
    self.screenSaverTimer:unregister()
    return self.items[selected].callback()
  end
  if name == 'up' then
    selected = selected + 1
  end
  if name == 'down' then
    selected = selected - 1
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
  for i, item in ipairs(self.items) do
    if self.selected == i then
      disp:drawStr(10,10*i,'>')
    end
    disp:drawStr(20,10*i,item.name)
  end
  disp:sendBuffer()
end

return Package
