bthci.scan.on("adv_report", function(rep) print("ADV: "..encoder.toHex(rep))end)
bthci.scan.setparams({mode=1,interval=40,window=20},function(err) print(err or "Ok!") end)
bthci.scan.enable(1, function(err) print(err or "Ok!") end)
