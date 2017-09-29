local name = 'CactusCon6.badge'
local data = {string.char(string.len(name)+1),string.char(8),name}
local adv = table.concat(data)
print('enc:',string.len(adv),encoder.toHex(adv))

bthci.adv.setparams({type=bthci.adv.NONCONN_UNDIR})
bthci.adv.setdata(adv)
bthci.adv.enable(1, function(err) print(err or "advertising!") end)
