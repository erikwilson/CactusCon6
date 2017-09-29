local name = 'CactusCon6.badge'
local data = {string.char(string.len(name)+1),string.char(8),name}
local adv = table.concat(data)
bthci.scan.setparams({mode=0,interval=400,window=400})
bthci.adv.setparams({type=bthci.adv.NONCONN_UNDIR})
bthci.adv.setdata(adv)
