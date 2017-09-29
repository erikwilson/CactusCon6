local Menu = require('menu')
local scanWifi = require('scan-wifi')
local scanBluetooth = require('scan-bluetooth')
local life = require('life')

local drawHeader = function()
  disp:drawLine(23,0,105,0)
  disp:drawRBox(21,2,87,11,1)
  disp:drawLine(23,14,105,14)
  disp:setDrawColor(2)
  disp:drawStr(23,11, 'CactusCon 2017')
  disp:setDrawColor(1)
end

local mainMenu = Menu:new({
renderCallback=drawHeader,
offsetX=14,
offsetY=26,
items={
  {name='WiFi Scan', callback=scanWifi},
  {name='BlueTooth Scan', callback=scanBluetooth},
  {name='Game of Life',callback=life}
}})

return function()
  mainMenu:setup()
end
