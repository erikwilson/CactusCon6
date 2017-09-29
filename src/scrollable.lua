local disp = disp
local registerButtons = registerButtons
local setmetatable = setmetatable
local ipairs = ipairs
local tmr = tmr
local print = print

local Package = {
  offsetX=0,
  offsetY=0,
  maxX=128,
  maxY=64,
  lineHeight=10,
  deltaX=20,
  deltaY=20,
  bottomPad=2,
  registered=false,
}
setfenv(1,Package)

Package.new = function(self, o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Package:display()
  self:registerButtons()
  disp:clearBuffer()
  if self.lines == nil then return end
  for i, text in ipairs(self.lines) do
    local offset = self.offsetY + (self.lineHeight*i)
    if offset >= 0 and offset+self.lineHeight < self.maxX then
      disp:drawStr(self.offsetX,offset,text)
    end
  end
  disp:sendBuffer()
end

function Package:registerButtons()
  if self.registered then return end
  self.registered = true
  registerButtons(function(name)
    if name == 'center' then
      return self.callback()
    end
    if name == 'up' then
      self.offsetY = self.offsetY + self.deltaY
    end
    if name == 'down' then
      self.offsetY = self.offsetY - self.deltaY
    end
    if name == 'left' then
      self.offsetX = self.offsetX + self.deltaX
    end
    if name == 'right' then
      self.offsetX = self.offsetX - self.deltaX
    end
    if self.offsetX > 0 then
      self.offsetX = 0
    end
    if self.offsetX < -self.maxX then
      self.offsetX = -self.maxX
    end
    if self.offsetY > 0 then
      self.offsetY = 0
    end

    if self.lines == nil then return end

    local minY = (self.maxY-self.bottomPad)-(#self.lines*self.lineHeight)
    if minY > 0 then minY = 0 end
    if self.offsetY < minY then
      self.offsetY = minY
    end
    self:display()
  end)
end

return Package
