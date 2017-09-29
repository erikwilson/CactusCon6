local prefix = {
    "http://www.",
    "https://www.",
    "http://",
    "https://",
    "urn:uuid:",
}

local suffix = {
    ".com/",
    ".org/",
    ".edu/",
    ".net/",
    ".info/",
    ".biz/",
    ".gov/",
    ".com",
    ".org",
    ".edu",
    ".net",
    ".info",
    ".biz",
    ".gov",
}

function startsWith(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end

function endsWith(String,End)
   return End=='' or string.sub(String,-string.len(End))==End
end

local url = "https://octoblu.com/"
print("url len:",url:len())
local data = {
    string.char(0x02),
    string.char(0x01),
    string.char(0x06),
    string.char(0x03),
    string.char(0x03),
    string.char(0xAA),
    string.char(0xFE),
    string.char(0x19),
    string.char(0x16),
    string.char(0xAA),
    string.char(0xFE),
    string.char(0x10),
    string.char(0x20),
}

--for i=1,url:len()+13 do data[i] = 0 end
print('data len:',table.getn(data))
print(encoder.toHex(table.concat(data)))
local prefix_index = 0
local url_start = 1
for i=1, table.getn(prefix) do
    if startsWith(url,prefix[i]) then
        prefix_index = i
        url_start = prefix[i]:len()+1
    end
end

local suffix_index = 0
local url_end = url:len()
for i=1, table.getn(suffix) do
    if endsWith(url,suffix[i]) then
        suffix_index=i
        url_end = url:len() - suffix[i]:len()
    end
end

local newUrl = string.sub(url, url_start, url_end)
local indx = 14

if prefix_index ~= 0 then
    data[indx] = string.char(prefix_index-1)
    indx = indx + 1
end

for i=1, newUrl:len() do
    data[indx] = string.sub(newUrl,i,i+1)
    indx = indx + 1
end

if suffix_index ~= 0 then
    data[indx] = string.char(suffix_index-1)
    indx = indx + 1
end

data[8] = string.char(indx-8)

print(table.getn(data), encoder.toHex(string.char(table.getn(data))))
print(encoder.toHex(table.concat(data)))

print('index:', prefix_index, suffix_index, url_start, url_end)
print()

local name = 'https://octoblu.com/'
local info = name
data = {string.char(string.len(info)+1),string.char(8),info}
--local adv = encoder.fromHex("f60032be32c20201040303d8fe1216d8fe00f2027265656c7961637469766507")
local adv = table.concat(data)
--local adv = encoder.fromHex("ffffffffffffffff")
--local adv = encoder.fromHex("0c096162636465666768697071")

print('enc:',string.len(adv),encoder.toHex(adv))

bthci.reset(function(err)
    bthci.adv.setparams({type=bthci.adv.NONCONN_UNDIR}, function(err) 
        print(err or "bt params set!") 
        bthci.adv.setdata(adv, function(err) 
            print(err or "bt data set!") 
            bthci.adv.enable(1, function(err) print(err or "advertising!") end)
        end)
    end)
end)