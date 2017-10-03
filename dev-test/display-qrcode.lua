local QRCode = require('qrcode')
local qrcode = QRCode.initBytes(3,0,'HELLO WORLD')
disp:clearBuffer()
disp:setDrawColor(1)
disp:drawBox(0,0,128,64)
disp:setDrawColor(2)
for y=0, qrcode.size-1 do
  for x=0, qrcode.size-1 do
    if QRCode.getModule(qrcode,x,y) then
      disp:drawBox(5+x*2,5+y*2,2,2)
    end
  end
end
disp:setDrawColor(1)
disp:sendBuffer()
