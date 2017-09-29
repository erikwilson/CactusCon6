
function registerButton(gpioPin,name,callback)
  local process = true
  local mytimer = tmr.create()
  gpio.trig(gpioPin, gpio.INTR_DOWN, function(pin,level)
    if level ~= 0 then return end
    if process == false then return end
    process = false
    mytimer:alarm(250, tmr.ALARM_SINGLE, function() process = true end)
    if callback == nil then return end
    return callback(name, pin)
  end)
end

local buttons = {
  up=12,
  down=5,
  left=13,
  right=23,
  center=18,
}

for name, pin in pairs(buttons) do
  gpio.config({gpio=pin,dir=gpio.IN,pull=gpio.PULL_UP})
end

_G.registerButtons = function(callback)
  for name, pin in pairs(buttons) do
    registerButton(pin, name, callback)
  end
end
