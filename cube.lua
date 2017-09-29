
local timeDelta = 100
local stretch = 10
local sZ = 1000
local scale = 14
local centerX = 64
local centerY = 40

local framecount = 0
local time = 0

local C1 = nil
local C2 = nil
local C3 = nil
local C4 = nil
local C5 = nil
local C6 = nil
local C7 = nil
local C8 = nil

local function vectRotXYZ(angle, axe)
  local m1 -- coords polarity
  local i1 -- coords index
  local i2

  if axe == 1 then
    i1 = 2 -- y
    i2 = 3 -- z
    m1 = -1
  end
  if axe == 2 then
    i1 = 1 -- x
    i2 = 3 -- z
    m1 = 1
  end
  if axe == 3 then
    i1 = 1 -- x
    i2 = 2 -- y
    m1 = 1
  end

  local t1 = C1[i1]
  local t2 = C1[i2]
  C1[i1] = t1*math.cos(angle)+(m1*t2)*math.sin(angle)
  C1[i2] = (-m1*t1)*math.sin(angle)+t2*math.cos(angle)

  t1 = C2[i1]
  t2 = C2[i2]
  C2[i1] = t1*math.cos(angle)+(m1*t2)*math.sin(angle)
  C2[i2] = (-m1*t1)*math.sin(angle)+t2*math.cos(angle)

  t1 = C3[i1]
  t2 = C3[i2]
  C3[i1] = t1*math.cos(angle)+(m1*t2)*math.sin(angle)
  C3[i2] = (-m1*t1)*math.sin(angle)+t2*math.cos(angle)

  t1 = C4[i1]
  t2 = C4[i2]
  C4[i1] = t1*math.cos(angle)+(m1*t2)*math.sin(angle)
  C4[i2] = (-m1*t1)*math.sin(angle)+t2*math.cos(angle)

  t1 = C5[i1]
  t2 = C5[i2]
  C5[i1] = t1*math.cos(angle)+(m1*t2)*math.sin(angle)
  C5[i2] = (-m1*t1)*math.sin(angle)+t2*math.cos(angle)

  t1 = C6[i1]
  t2 = C6[i2]
  C6[i1] = t1*math.cos(angle)+(m1*t2)*math.sin(angle)
  C6[i2] = (-m1*t1)*math.sin(angle)+t2*math.cos(angle)

  t1 = C7[i1]
  t2 = C7[i2]
  C7[i1] = t1*math.cos(angle)+(m1*t2)*math.sin(angle)
  C7[i2] = (-m1*t1)*math.sin(angle)+t2*math.cos(angle)

  t1 = C8[i1]
  t2 = C8[i2]
  C8[i1] = t1*math.cos(angle)+(m1*t2)*math.sin(angle)
  C8[i2] = (-m1*t1)*math.sin(angle)+t2*math.cos(angle)
end

local function millis()
  time = time+timeDelta
  return time
end

local function cubeloop()
  framecount = framecount + 1

  local gx = stretch*math.sin(0.02*framecount+0.5)
  local gy = stretch*math.sin(0.001*framecount)
  local gz = stretch*math.sin(0.01*framecount+0.25)

  -- Initialize cube point arrays
  C1 = {  1,  1,  1 }
  C2 = {  1,  1, -1 }
  C3 = {  1, -1,  1 }
  C4 = {  1, -1, -1 }
  C5 = { -1,  1,  1 }
  C6 = { -1,  1, -1 }
  C7 = { -1, -1,  1 }
  C8 = { -1, -1, -1 }

  -- scale angles down, rotate
  vectRotXYZ(-gy, 1) -- X
  vectRotXYZ(-gx, 2) -- Y
  vectRotXYZ(-gz, 3) -- Z

  -- Initialize cube points coords
  local P1 = { 0, 0 }
  local P2 = { 0, 0 }
  local P3 = { 0, 0 }
  local P4 = { 0, 0 }
  local P5 = { 0, 0 }
  local P6 = { 0, 0 }
  local P7 = { 0, 0 }
  local P8 = { 0, 0 }

  -- calculate each point coords
  P1[1] = centerX + scale/(1+C1[3]/sZ)*C1[1]
  P2[1] = centerX + scale/(1+C2[3]/sZ)*C2[1]
  P3[1] = centerX + scale/(1+C3[3]/sZ)*C3[1]
  P4[1] = centerX + scale/(1+C4[3]/sZ)*C4[1]
  P5[1] = centerX + scale/(1+C5[3]/sZ)*C5[1]
  P6[1] = centerX + scale/(1+C6[3]/sZ)*C6[1]
  P7[1] = centerX + scale/(1+C7[3]/sZ)*C7[1]
  P8[1] = centerX + scale/(1+C8[3]/sZ)*C8[1]

  P1[2] = centerY + scale/(1+C1[3]/sZ)*C1[2]
  P2[2] = centerY + scale/(1+C2[3]/sZ)*C2[2]
  P3[2] = centerY + scale/(1+C3[3]/sZ)*C3[2]
  P4[2] = centerY + scale/(1+C4[3]/sZ)*C4[2]
  P5[2] = centerY + scale/(1+C5[3]/sZ)*C5[2]
  P6[2] = centerY + scale/(1+C6[3]/sZ)*C6[2]
  P7[2] = centerY + scale/(1+C7[3]/sZ)*C7[2]
  P8[2] = centerY + scale/(1+C8[3]/sZ)*C8[2]

  -- draw each cube edge
  disp:clearBuffer()
  disp:setDrawColor(1)

  disp:drawLine(P1[1], P1[2], P2[1], P2[2]) --1-2
  disp:drawLine(P1[1], P1[2], P3[1], P3[2]) --1-3
  disp:drawLine(P1[1], P1[2], P5[1], P5[2]) --1-5
  disp:drawLine(P2[1], P2[2], P4[1], P4[2]) --2-4
  disp:drawLine(P2[1], P2[2], P6[1], P6[2]) --2-6
  disp:drawLine(P3[1], P3[2], P4[1], P4[2]) --3-4
  disp:drawLine(P3[1], P3[2], P7[1], P7[2]) --3-7
  disp:drawLine(P4[1], P4[2], P8[1], P8[2]) --4-8
  disp:drawLine(P5[1], P5[2], P6[1], P6[2]) --5-6
  disp:drawLine(P5[1], P5[2], P7[1], P7[2]) --5-7
  disp:drawLine(P6[1], P6[2], P8[1], P8[2]) --6-8
  disp:drawLine(P7[1], P7[2], P8[1], P8[2]) --7-8

  disp:drawLine(23,0,105,0)
  disp:drawRBox(21,2,87,11,1)
  disp:drawLine(23,14,105,14)
  disp:setDrawColor(2)
  disp:setFontDirection(0)
  disp:drawStr(23,11, 'CactusCon 2017')
  disp:setFontRefHeightText(20)
  disp:setDrawColor(1)
  disp:drawStr(61,44, '6')

  disp:sendBuffer()
end

local timer = _G._screenSaver
if timer == nil then
  timer = tmr.create()
  _G._screenSaver = timer
end
timer:register(timeDelta, tmr.ALARM_AUTO, cubeloop)

return timer
