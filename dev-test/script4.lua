disp:clearBuffer()

disp:drawPixel(0,0)
disp:drawPixel(0,32)
disp:drawPixel(0,63)
disp:drawPixel(127,0)
disp:drawPixel(127,63)
disp:drawPixel(127,32)
disp:drawPixel(64,0)
disp:drawPixel(64,32)
disp:drawPixel(64,63)

disp:drawBox(32, 16, 64, 32)
disp:drawStr(10,10,'hello world')
disp:sendBuffer()