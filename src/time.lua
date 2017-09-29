_G.time = 0
tmr:create():alarm(1000, tmr.ALARM_AUTO, function()
  _G.time = _G.time + 1
end)
