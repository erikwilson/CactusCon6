local Menu = require('menu')
local scanWifi = require('scan-wifi')
local scanBluetooth = require('scan-bluetooth')

local mainMenu = Menu:new({items={
  {name='WiFi Scan', callback=scanWifi},
  {name='BlueTooth Scan', callback=scanBluetooth},
}})

return function()
  mainMenu:setup()
end
