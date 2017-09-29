local id  = i2c.HW0
local sda = 21
local scl = 22
local sla = 0x3C
i2c.setup(id, sda, scl, i2c.FAST)
_G.disp = u8g2.ssd1306_i2c_128x64_noname(id, sla)
disp:setFont(u8g2.font_6x10_tf)
