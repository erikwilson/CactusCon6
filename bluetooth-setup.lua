local name = 'CactusCon6.badge'
local data = {string.char(string.len(name)+1),string.char(8),name}
local adv = table.concat(data)
bthci.adv.setparams({type=bthci.adv.NONCONN_UNDIR})
bthci.adv.setdata(adv)
