-- fixme - almost converted from https://github.com/ricmoo/QRCode/blob/master/src/qrcode.c

local NUM_ERROR_CORRECTION_CODEWORDS = {
    -- 1,  2,  3,  4,  5,   6,   7,   8,   9,  10,  11,  12,  13,  14,  15,  16,  17,  18,  19,  20,  21,  22,  23,  24,   25,   26,   27,   28,   29,   30,   31,   32,   33,   34,   35,   36,   37,   38,   39,   40    Error correction level
    { 10, 16, 26, 36, 48,  64,  72,  88, 110, 130, 150, 176, 198, 216, 240, 280, 308, 338, 364, 416, 442, 476, 504, 560,  588,  644,  700,  728,  784,  812,  868,  924,  980, 1036, 1064, 1120, 1204, 1260, 1316, 1372},  -- Medium
    {  7, 10, 15, 20, 26,  36,  40,  48,  60,  72,  80,  96, 104, 120, 132, 144, 168, 180, 196, 224, 224, 252, 270, 300,  312,  336,  360,  390,  420,  450,  480,  510,  540,  570,  570,  600,  630,  660,  720,  750},  -- Low
    { 17, 28, 44, 64, 88, 112, 130, 156, 192, 224, 264, 308, 352, 384, 432, 480, 532, 588, 650, 700, 750, 816, 900, 960, 1050, 1110, 1200, 1260, 1350, 1440, 1530, 1620, 1710, 1800, 1890, 1980, 2100, 2220, 2310, 2430},  -- High
    { 13, 22, 36, 52, 72,  96, 108, 132, 160, 192, 224, 260, 288, 320, 360, 408, 448, 504, 546, 600, 644, 690, 750, 810,  870,  952, 1020, 1050, 1140, 1200, 1290, 1350, 1440, 1530, 1590, 1680, 1770, 1860, 1950, 2040},  -- Quartile
}

local NUM_ERROR_CORRECTION_BLOCKS = {
    -- Version: (note that index 0 is for padding, and is set to an illegal value)
    -- 1, 2, 3, 4, 5, 6, 7, 8, 9,10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40    Error correction level
    {  1, 1, 1, 2, 2, 4, 4, 4, 5, 5,  5,  8,  9,  9, 10, 10, 11, 13, 14, 16, 17, 17, 18, 20, 21, 23, 25, 26, 28, 29, 31, 33, 35, 37, 38, 40, 43, 45, 47, 49},  -- Medium
    {  1, 1, 1, 1, 1, 2, 2, 2, 2, 4,  4,  4,  4,  4,  6,  6,  6,  6,  7,  8,  8,  9,  9, 10, 12, 12, 12, 13, 14, 15, 16, 17, 18, 19, 19, 20, 21, 22, 24, 25},  -- Low
    {  1, 1, 2, 4, 4, 4, 5, 6, 8, 8, 11, 11, 16, 16, 18, 16, 19, 21, 25, 25, 25, 34, 30, 32, 35, 37, 40, 42, 45, 48, 51, 54, 57, 60, 63, 66, 70, 74, 77, 81},  -- High
    {  1, 1, 2, 2, 4, 4, 6, 6, 8, 8,  8, 10, 12, 16, 12, 17, 16, 18, 21, 20, 23, 23, 25, 27, 29, 34, 34, 35, 38, 40, 43, 45, 48, 51, 53, 56, 59, 62, 65, 68},  -- Quartile
}

local NUM_RAW_DATA_MODULES = {
    --  1,   2,   3,   4,    5,    6,    7,    8,    9,   10,   11,   12,   13,   14,   15,   16,   17,
      208, 359, 567, 807, 1079, 1383, 1568, 1936, 2336, 2768, 3232, 3728, 4256, 4651, 5243, 5867, 6523,
    --   18,   19,   20,   21,    22,    23,    24,    25,   26,    27,     28,    29,    30,    31,
       7211, 7931, 8683, 9252, 10068, 10916, 11796, 12708, 13652, 14628, 15371, 16411, 17483, 18587,
    --    32,    33,    34,    35,    36,    37,    38,    39,    40
       19723, 20891, 22091, 23008, 24272, 25568, 26896, 28256, 29648
}

-- QR Code Format Encoding
local MODE_NUMERIC = 0
local MODE_ALPHANUMERIC = 1
local MODE_BYTE = 2

-- Error Correction Code Levels
local ECC_LOW = 0
local ECC_MEDIUM = 1
local ECC_QUARTILE = 2
local ECC_HIGH = 3

local function max(a, b)
  if a > b then return a end
  return b
end

-- /*
-- local function abs(value)
--     if value < 0)  return -value }
--     return value
-- }
-- */


-- - Mode testing and conversion

local function getAlphanumeric(c)
  local a0 = 'A0'
  if c >= '0' and c <= '9' then return (c:byte(1) - a0:byte(2)) end
  if c >= 'A' and c <= 'Z' then return (c:byte(1) - a0:byte(1) + 10) end

  if c == ' ' then return 36 end
  if c == '$' then return 37 end
  if c == '%' then return 38 end
  if c == '*' then return 39 end
  if c == '+' then return 40 end
  if c == '-' then return 41 end
  if c == '.' then return 42 end
  if c == '/' then return 43 end
  if c == ':' then return 44 end

  return -1
end

local function isAlphanumeric(text)
  for i=1, text:len(), 1 do
    if getAlphanumeric(text:sub(i,i)) == -1 then return false end
  end
  return true
end

local function isNumeric(text)
  for i=1, text:len(), 1 do
    local c = text:sub(i,i)
    if c < '0' or c > '9' then return false end
  end
  return true
end


-- - Counting

-- We store the following tightly packed (less 8) in modeInfo
--               <=9  <=26  <= 40
-- NUMERIC      ( 10,   12,    14)
-- ALPHANUMERIC (  9,   11,    13)
-- BYTE         (  8,   16,    16)
local function getModeBits(version, mode)
    -- Note: We use 15 instead of 16 since 15 doesn't exist and we cannot store 16 (8 + 8) in 3 bits
    -- hex(int("".join(reversed([('00' + bin(x - 8)[2:])[-3:] for x in [10, 9, 8, 12, 11, 15, 14, 13, 15]])), 2))
    local modeInfo = 129742858

    if version > 9 then modeInfo = bit.rshift(modeInfo,9) end
    if version > 26 then modeInfo = bit.rshift(modeInfo,9) end

    local result = 8 + bit.band(bit.rshift(modeInfo, 3*mode), 7)
    if result == 15 then result = 16 end
    return result
end

local function bb_getGridSizeBytes(size)
    return (((size * size) + 7) / 8)
end

local function bb_getBufferSizeBytes(bits)
    return ((bits + 7) / 8)
end

local function bb_initBuffer(bitBuffer, data, capacityBytes)
  for i=0, capacityBytes-1 do data[i] = 0 end
  bitBuffer.bitOffsetOrWidth = 0
  bitBuffer.capacityBytes = capacityBytes
  bitBuffer.data = data
end

local function bb_initGrid(bitGrid, data, size)
  local capacityBytes = bb_getGridSizeBytes(size)
  for i=0, capacityBytes-1 do data[i] = 0 end
  bitGrid.bitOffsetOrWidth = size
  bitGrid.capacityBytes = capacityBytes
  bitGrid.data = data
end

local function bb_appendBits(bitBuffer, val, length)
  local offset = bitBuffer.bitOffsetOrWidth
  for i=length-1, 0, -1 do
    offset = offset + 1
    local pos = bit.rshift(offset, 3)
    local c = bitBuffer.data[pos]
    c = bit.bor(c, bit.lshift(bit.band(bit.rshift(val, i), 1), 7 - bit.band(offset,7)))
    bitBuffer.data[pos] = c
    -- bitBuffer.data[offset >> 3] |= ((val >> i) & 1bit.lshift(), ()7 - (offset & 7))
  end
  bitBuffer.bitOffsetOrWidth = offset
end

local function bb_setBit(bitGrid, x, y, on)
  local offset = y * bitGrid.bitOffsetOrWidth + x
  local mask = bit.lshift(1, 7 - bit.band(offset, 7))
  local pos = bit.rshift(offset, 3)
  if bitGrid.data[pos] == nil then bitGrid.data[pos] = 0 end
  if on==true or on==1 then
    bitGrid.data[pos] = bit.bor(bitGrid.data[pos], mask)
  else
    bitGrid.data[pos] = bit.band(bitGrid.data[pos], bit.bnot(mask))
  end
end

local function bb_invertBit(bitGrid, x, y, invert)
  local offset = y * bitGrid.bitOffsetOrWidth + x
  local mask = bit.lshift(1, 7 - bit.band(offset, 7))
  local pos = bit.rshift(offset, 3)
  local c = bitGrid.data[pos]
  local on = bit.band(c, mask) ~= 0
  if on==true or on==1 then on=1 else on=0 end
  if invert==true or invert==1 then invert=1 else invert=0 end

  if bit.bxor(on, invert)==1 then
    bitGrid.data[pos] = bit.bor(bitGrid.data[pos], mask)
  else
    bitGrid.data[pos] = bit.band(bitGrid.data[pos], bit.bnot(mask))
  end
end

local function bb_getBit(bitGrid, x, y)
  local offset = y * bitGrid.bitOffsetOrWidth + x
  local mask = bit.lshift(1, 7 - bit.band(offset, 7))
  local pos = bit.rshift(offset, 3)
  return bit.band(bitGrid.data[pos], mask) ~= 0
end

-- - Drawing Patterns

-- XORs the data modules in this QR Code with the given mask pattern. Due to XOR's mathematical
-- properties, calling applyMask(m) twice with the same value is equivalent to no change at all.
-- This means it is possible to apply a mask, undo it, and try another mask. Note that a final
-- well-formed QR Code symbol needs exactly one mask applied (not zero, not two, etc.).
local function applyMask(modules, isFunction, mask)
  local size = modules.bitOffsetOrWidth
  for y=0, size-1 do
    for x=0, size-1 do
      if not bb_getBit(isFunction, x, y) then
        local invert = 0
        if mask == 0 then invert = (x + y) % 2 == 0                   end
        if mask == 1 then invert = y % 2 == 0                         end
        if mask == 2 then invert = x % 3 == 0                         end
        if mask == 3 then invert = (x + y) % 3 == 0                   end
        if mask == 4 then invert = (x / 3 + y / 2) % 2 == 0           end
        if mask == 5 then invert = x * y % 2 + x * y % 3 == 0         end
        if mask == 6 then invert = (x * y % 2 + x * y % 3) % 2 == 0   end
        if mask == 7 then invert = ((x + y) % 2 + x * y % 3) % 2 == 0 end
        bb_invertBit(modules, x, y, invert)
      end
    end
  end
end

local function setFunctionModule(modules, isFunction, x, y, on)
    bb_setBit(modules, x, y, on)
    bb_setBit(isFunction, x, y, true)
end

-- Draws a 9*9 finder pattern including the border separator, with the center module at (x, y).
local function drawFinderPattern(modules, isFunction, x, y)
  local size = modules.bitOffsetOrWidth

  for i=-4, 4 do
    for j=-4, 4 do
      local dist = max(math.abs(i), math.abs(j))  -- Chebyshev/infinity norm
      local xx = x + j
      local yy = y + i
      if 0 <= xx and xx < size and 0 <= yy and yy < size then
        setFunctionModule(modules, isFunction, xx, yy, dist ~= 2 and dist ~= 4)
      end
    end
  end
end

-- Draws a 5*5 alignment pattern, with the center module at (x, y).
local function drawAlignmentPattern(modules, isFunction, x, y)
  for i=-2, 2 do
    for j=-2, 2 do
      setFunctionModule(modules, isFunction, x + j, y + i, max(math.abs(i), math.abs(j)) ~= 1)
    end
  end
end

-- Draws two copies of the format bits (with its own error correction code)
-- based on the given mask and this object's error correction level field.
local function drawFormatBits(modules, isFunction, ecc, mask)

  local size = modules.bitOffsetOrWidth

  -- Calculate error correction code and pack bits
  local data = bit.bor(bit.lshift(ecc, 3), mask)  -- errCorrLvl is uint2, mask is uint3
  local rem = data
  for i=0, 9 do
      rem = bit.bxor(bit.lshift(rem, 1), bit.rshift(rem, 9) * 1335)
  end

  data = bit.bor(bit.lshift(data, 10), rem)
  data = bit.bxor(data, 21522)  -- uint15

  -- Draw first copy
  for i=0, 5 do
      setFunctionModule(modules, isFunction, 8, i, bit.band(bit.rshift(data, i), 1) ~= 0)
  end

  setFunctionModule(modules, isFunction, 8, 7, bit.band(bit.rshift(data, 6), 1) ~= 0)
  setFunctionModule(modules, isFunction, 8, 8, bit.band(bit.rshift(data, 7), 1) ~= 0)
  setFunctionModule(modules, isFunction, 7, 8, bit.band(bit.rshift(data, 8), 1) ~= 0)

  for i=9, 14 do
    setFunctionModule(modules, isFunction, 14 - i, 8, bit.band(bit.rshift(data, i), 1) ~= 0)
  end

  -- Draw second copy
  for i=0, 7 do
    setFunctionModule(modules, isFunction, size - 1 - i, 8, bit.band(bit.rshift(data, i), 1) ~= 0)
  end

  for i=8, 14 do
    setFunctionModule(modules, isFunction, 8, size - 15 + i, bit.band(bit.rshift(data, i), 1) ~= 0)
  end

  setFunctionModule(modules, isFunction, 8, size - 8, true)
end


-- Draws two copies of the version bits (with its own error correction code),
-- based on this object's version field (which only has an effect for 7 <= version <= 40).
local function drawVersion(modules, isFunction, version)
    local size = modules.bitOffsetOrWidth
    if version < 7 then return end

    -- Calculate error correction code and pack bits
    local rem = version  -- version is uint6, in the range [7, 40]
    for i=0, 11 do
        rem = bit.bxor(bit.lshift(rem, 1), bit.rshift(rem, 11) * 7973)
    end

    local data = bit.bor(bit.lshift(version, 12), rem)  -- uint18

    -- Draw two copies
    for i=0, 17 do
        local on = bit.band(bit.rshift(data, i), 1) ~= 0
        local a = size - 11 + i % 3
        local b = i / 3
        setFunctionModule(modules, isFunction, a, b, on)
        setFunctionModule(modules, isFunction, b, a, on)
    end
end

local function drawFunctionPatterns(modules, isFunction, version, ecc)

  local size = modules.bitOffsetOrWidth

  -- Draw the horizontal and vertical timing patterns
  for i=0, size-1 do
      setFunctionModule(modules, isFunction, 6, i, i % 2 == 0)
      setFunctionModule(modules, isFunction, i, 6, i % 2 == 0)
  end

  -- Draw 3 finder patterns (all corners except bottom right overwrites some timing modules)
  drawFinderPattern(modules, isFunction, 3, 3)
  drawFinderPattern(modules, isFunction, size - 4, 3)
  drawFinderPattern(modules, isFunction, 3, size - 4)

  if version > 1 then

    -- Draw the numerous alignment patterns

    local alignCount = version / 7 + 2
    local step
    if version ~= 32 then
        step = (version * 4 + alignCount * 2 + 1) / (2 * alignCount - 2) * 2  -- ceil((size - 13) / (2*numAlign - 2)) * 2
    else -- C-C-C-Combo breaker!
        step = 26
    end

    local alignPositionIndex = alignCount - 1
    local alignPosition = {}
    for i=0, alignCount-1 do alignPosition[i] = 0 end
    alignPosition[0] = 6

    local size = version * 4 + 17
    local pos = size - 7
    for i=0, alignCount-2 do
      pos = pos - step
      alignPosition[alignPositionIndex] = pos
      alignPositionIndex = alignPositionIndex - 1
    end

    for i=0, alignCount-1 do
      for j=0, alignCount-1 do
        if (i == 0 and j == 0) or (i == 0 and j == alignCount - 1) or (i == alignCount - 1 and j == 0) then
        else
          drawAlignmentPattern(modules, isFunction, alignPosition[i], alignPosition[j])
        end
      end
    end
  end

  -- Draw configuration data
  drawFormatBits(modules, isFunction, ecc, 0)  -- Dummy mask value overwritten later in the constructor
  drawVersion(modules, isFunction, version)
end


-- Draws the given sequence of 8-bit codewords (data and error correction) onto the entire
-- data area of this QR Code symbol. Function modules need to be marked off before this is called.
local function drawCodewords(modules, isFunction, codewords)

  local bitLength = codewords.bitOffsetOrWidth
  local data = codewords.data

  local size = modules.bitOffsetOrWidth

  -- Bit index into the data
  local i = 0

  -- Do the funny zigzag scan
  for right=size-1, 1, -2 do   -- Index of right column in each column pair
    if right == 6 then right = 5 end

    for vert=0, size-1 do   -- Vertical counter^
      for j=0, 1 do
        local x = right - j  -- Actual x coordinate
        local b1 = bit.band(right, 2) == 0
        if b1 then b1=1 else b1=0 end
        local b2 = x < 6
        if b2 then b2=1 else b2=0 end
        local upwards = bit.bxor(b1,b2)
        local y = 0
        if upwards == 1 then
          y = size - 1 - vert
        else
          y = vert  -- Actual y coordinate
        end
        if not bb_getBit(isFunction, x, y) and i < bitLength then
          bb_setBit(modules, x, y, bit.band(bit.rshift(data[bit.rshift(i,3)], (7 - bit.band(i,7))), 1) ~= 0)
          i = i + 1
        end
        -- If there are any remainder bits (0 to 7), they are already
        -- set to 0/false/white when the grid of modules was initialized
      end
    end
  end
end

-- - Penalty Calculation

local PENALTY_N1 = 3
local PENALTY_N2 = 3
local PENALTY_N3 = 40
local PENALTY_N4 = 10

-- Calculates and returns the penalty score based on state of this QR Code's current modules.
-- This is used by the automatic mask choice algorithm to find the mask pattern that yields the lowest score.
-- @TODO: This can be optimized by working with the bytes instead of bits.
local function getPenaltyScore(modules)
  local result = 0
  local size = modules.bitOffsetOrWidth

  -- Adjacent modules in row having same color
  for y=0, size-1 do
    local colorX = bb_getBit(modules, 0, y)
    local runX = 1
    for x=1, size-1 do
      local cx = bb_getBit(modules, x, y)
      if cx ~= colorX then
        colorX = cx
        runX = 1
      else
        runX = runX + 1
        if runX == 5 then
          result = result + PENALTY_N1
        else
          if runX > 5 then
            result = result + 1
          end
        end
      end
    end
  end

  -- Adjacent modules in column having same color
  for x=0, size-1 do
    local colorY = bb_getBit(modules, x, 0)
    local runY = 1
    for y=1, size-1 do
      local cy = bb_getBit(modules, x, y)
      if cy ~= colorY then
          colorY = cy
          runY = 1
      else
        runY = runY + 1
        if runY == 5 then
          result = result + PENALTY_N1
        else
          if runY > 5 then
            result = result + 1
          end
        end
      end
    end
  end

  local black = 0
  for y=0, size-1 do
    local bitsRow = 0
    local bitsCol = 0
    for x=0, size-1 do
      local color = bb_getBit(modules, x, y)

      -- 2*2 blocks of modules having same color
      if x > 0 and y > 0 then
        local colorUL = bb_getBit(modules, x - 1, y - 1)
        local colorUR = bb_getBit(modules, x, y - 1)
        local colorL = bb_getBit(modules, x - 1, y)
        if color == colorUL and color == colorUR and color == colorL then
          result = result + PENALTY_N2
        end
      end
      local bR = 0
      if color then bR = 0 end
      local bC = 0
      if bb_getBit(modules, y, x) then bC = 1 end

      -- Finder-like pattern in rows and columns
      bitsRow = bit.bor(bit.band(bit.lshift(bitsRow, 1), 2047), bR)
      bitsCol = bit.bor(bit.band(bit.lshift(bitsCol, 1), 2047), bC)

      -- Needs 11 bits accumulated
      if x >= 10 then
        if bitsRow == 93 or bitsRow == 1488 then
          result = result + PENALTY_N3
        end
        if bitsCol == 93 or bitsCol == 1488 then
          result = result + PENALTY_N3
        end
      end

      -- Balance of black and white modules
      if color then black = black + 1 end
    end
  end

  -- Find smallest k such that (45-5k)% <= dark/total <= (55+5k)%
  local total = size * size
  local k = 0
  while black * 20 < (9 - k) * total or black * 20 > (11 + k) * total do
    k = k + 1
    result = result + PENALTY_N4
  end

  return result
end


-- - Reed-Solomon Generator

local function rs_multiply(x, y)
  -- Russian peasant multiplication
  -- See: https:--en.wikipedia.org/wiki/Ancient_Egyptian_multiplication
  local z = 0
  for i=7, 0, -1 do
    z = bit.bxor(bit.lshift(z,1), bit.rshift(z,7) * 285)
    z = bit.bxor(z,bit.band(bit.rshift(y,i),1)) * x
  end
  return z
end

local function rs_init(degree, coeff)
  for i=0, degree-1 do coeff[i]=0 end
  -- memset(coeff, 0, degree)
  coeff[degree - 1] = 1

  -- Compute the product polynomial (x - r^0) * (x - r^1) * (x - r^2) * ... * (x - r^{degree-1}),
  -- drop the highest term, and store the rest of the coefficients in order of descending powers.
  -- Note that r = 2, which is a generator element of this field GF(2^8/285).
  local root = 1
  for i=0, degree-1 do
    -- Multiply the current product by (x - r^i)
    for j=0, degree-1 do
      coeff[j] = rs_multiply(coeff[j], root)
      if j + 1 < degree then
        coeff[j] = bit.bxor(coeff[j], coeff[j+1])
      end
    end
    root = bit.bxor(bit.lshift(root, 1), bit.rshift(root,7) * 285)  -- Multiply by 2 mod GF(2^8/285)
  end
end

local function rs_getRemainder(degree, coeff, data, dataOffset, length, result, offset, stride)
  -- Compute the remainder by performing polynomial division

  --for i=0, i < degree i++)  result[] = 0 }
  --memset(result, 0, degree)

  for i=0, length-1 do
    local factor = bit.bxor(data[i+dataOffset],result[0])
    for j=1, degree-1 do
      result[((j-1)*stride)+offset] = result[(j*stride)+offset]
    end
    result[((degree-1)*stride)+offset] = 0

    for j=0, degree-1 do
      result[(j*stride)+offset] = bit.bxor(result[(j*stride)+offset], rs_multiply(coeff[j], factor))
    end
  end
end

-- - QrCode++

local function encodeDataCodewords(dataCodewords, text, length, version)
  local mode = MODE_BYTE

  if isNumeric(text, length) then
    mode = MODE_NUMERIC
    bb_appendBits(dataCodewords, bit.lshift(1, MODE_NUMERIC), 4)
    bb_appendBits(dataCodewords, length, getModeBits(version, MODE_NUMERIC))

    local accumData = 0
    local accumCount = 0
    for i=0, length-1 do
      accumData = accumData * 10 + (text:byte(i) - 48)
      accumCount = accumCount + 1
      if accumCount == 3 then
        bb_appendBits(dataCodewords, accumData, 10)
        accumData = 0
        accumCount = 0
      end
    end

    -- 1 or 2 digits remaining
    if accumCount > 0 then
      bb_appendBits(dataCodewords, accumData, accumCount * 3 + 1)
    end

    return mode
  end

  if isAlphanumeric(text, length) then
    mode = MODE_ALPHANUMERIC
    bb_appendBits(dataCodewords, bit.lshift(1, MODE_ALPHANUMERIC), 4)
    bb_appendBits(dataCodewords, length, getModeBits(version, MODE_ALPHANUMERIC))

    local accumData = 0
    local accumCount = 0
    for i=0, length-1 do
      accumData = accumData * 45 + getAlphanumeric(text:sub(i,i))
      accumCount = accumCount + 1
      if accumCount == 2 then
        bb_appendBits(dataCodewords, accumData, 11)
        accumData = 0
        accumCount = 0
      end
    end

    -- 1 character remaining
    if accumCount > 0 then
      bb_appendBits(dataCodewords, accumData, 6)
    end

    return mode
  end

  bb_appendBits(dataCodewords, bit.lshift(1, MODE_BYTE), 4)
  bb_appendBits(dataCodewords, length, getModeBits(version, MODE_BYTE))
  for i=0, length-1 do
      bb_appendBits(dataCodewords, text:sub(i,i):byte(1), 8)
  end

  --bb_setBits(dataCodewords, length, 4, getModeBits(version, mode))

  return mode
end

local function performErrorCorrection(version, ecc, data)

  -- See: http:--www.thonky.com/qr-code-tutorial/structure-final-message

  local numBlocks = NUM_ERROR_CORRECTION_BLOCKS[ecc+1][version]
  local totalEcc = NUM_ERROR_CORRECTION_CODEWORDS[ecc+1][version]
  local moduleCount = NUM_RAW_DATA_MODULES[version]

  local blockEccLen = totalEcc / numBlocks
  local numShortBlocks = numBlocks - moduleCount / 8 % numBlocks
  local shortBlockLen = moduleCount / 8 / numBlocks

  local shortDataBlockLen = shortBlockLen - blockEccLen

  local result = {}
  for i=0, data.capacityBytes-1 do result[i] = 0 end

  local coeff = {}
  rs_init(blockEccLen, coeff)

  local offset = 0
  local dataBytes = data.data

  -- Interleave all short blocks
  for i=0, shortDataBlockLen-1 do
    local index = i
    local stride = shortDataBlockLen
    for blockNum=0, numBlocks-1 do
      result[offset] = dataBytes[index]
      offset = offset + 1
      if blockNum == numShortBlocks then stride = stride + 1 end
      index = index + stride
    end
  end

  -- Interleave long blocks
  local index = shortDataBlockLen * (numShortBlocks + 1)
  local stride = shortDataBlockLen
  for blockNum=0, numBlocks - numShortBlocks - 1 do
    result[offset] = dataBytes[index]
    offset = offset + 1
    if blockNum == 0 then stride = stride + 1 end
    index = index + stride
  end

  -- Add all ecc blocks, interleaved
  local blockSize = shortDataBlockLen
  local dataOffset = 0
  for blockNum=0, numBlocks-1 do
    if blockNum == numShortBlocks then blockSize = blockSize + 1 end
    rs_getRemainder(blockEccLen, coeff, dataBytes, dataOffset, blockSize, result, offset+blockNum, numBlocks)
    dataOffset = dataOffset + blockSize
  end

  for i=0, data.capacityBytes-1 do data.data[i] = result[i] end
  -- memcpy(data.data, result, data.capacityBytes)
  data.bitOffsetOrWidth = moduleCount
end

-- We store the Format bits tightly packed into a single byte (each of the 4 modes is 2 bits)
-- The format bits can be determined by ECC_FORMAT_BITS >> (2 * ecc)
local ECC_FORMAT_BITS = bit.bor(bit.bor(bit.lshift(2, 6), bit.lshift(3, 4)), 1)

-- - Public QRCode functions

local function qrcode_getBufferSize(version)
  return bb_getGridSizeBytes(4 * version + 17)
end

-- @TODO: Return error if data is too big.
local function qrcode_initBytes(version, ecc, data)
  local size = version * 4 + 17
  local length = data:len()
  local modules = {}
  local qrcode = {}
  qrcode.version = version
  qrcode.size = size
  qrcode.ecc = ecc
  qrcode.modules = modules

  local eccFormatBits = bit.band(bit.rshift(ECC_FORMAT_BITS, 2*ecc), 3)
  local moduleCount = NUM_RAW_DATA_MODULES[version]
  local dataCapacity = moduleCount / 8 - NUM_ERROR_CORRECTION_CODEWORDS[eccFormatBits+1][version]

  local codewords = {}
  local codewordBytesSize = bb_getBufferSizeBytes(moduleCount)
  local codewordBytes = {}
  bb_initBuffer(codewords, codewordBytes, codewordBytesSize)

  -- Place the data code words into the buffer
  local mode = encodeDataCodewords(codewords, data, length, version)

  if mode < 0 then return -1 end
  qrcode.mode = mode

  -- Add terminator and pad up to a byte if applicable
  local padding = (dataCapacity * 8) - codewords.bitOffsetOrWidth
  if padding > 4 then padding = 4 end
  bb_appendBits(codewords, 0, padding)
  bb_appendBits(codewords, 0, (8 - codewords.bitOffsetOrWidth % 8) % 8)

  -- Pad with alternate bytes until data capacity is reached
  local padByte=236
  while codewords.bitOffsetOrWidth < (dataCapacity * 8) do
    bb_appendBits(codewords, padByte, 8)
    padByte = bit.bxor(padByte, bit.bxor(236, 17))
  end

  local modulesGrid = {}
  bb_initGrid(modulesGrid, modules, size)

  local isFunctionGrid = {}
  local isFunctionGridBytes = {}
  bb_initGrid(isFunctionGrid, isFunctionGridBytes, size)

  -- Draw function patterns, draw all codewords, do masking
  drawFunctionPatterns(modulesGrid, isFunctionGrid, version, eccFormatBits)
  performErrorCorrection(version, eccFormatBits, codewords)
  drawCodewords(modulesGrid, isFunctionGrid, codewords)

  -- Find the best (lowest penalty) mask
  local mask = 0
  local minPenalty = 1/0
  for i=0, 7 do
      drawFormatBits(modulesGrid, isFunctionGrid, eccFormatBits, i)
      applyMask(modulesGrid, isFunctionGrid, i)
      penalty = getPenaltyScore(modulesGrid)
      if penalty < minPenalty then
          mask = i
          minPenalty = penalty
      end
      applyMask(modulesGrid, isFunctionGrid, i)  -- Undoes the mask due to XOR
  end

  qrcode.mask = mask

  -- Overwrite old format bits
  drawFormatBits(modulesGrid, isFunctionGrid, eccFormatBits, mask)

  -- Apply the final choice of mask
  applyMask(modulesGrid, isFunctionGrid, mask)

  return qrcode
end

local function qrcode_getModule(qrcode, x, y)
    if x < 0 or x >= qrcode.size or y < 0 or y >= qrcode.size then
        return false
    end

    local offset = y * qrcode.size + x
    return bit.band(qrcode.modules[bit.rshift(offset,3)], bit.lshift(1, (7-bit.band(offset,7)))) ~= 0
end

return {
  initBytes=qrcode_initBytes,
  getModule=qrcode_getModule,
  getBufferSize=qrcode_getBufferSize,

  MODE_NUMERIC = MODE_NUMERIC,
  MODE_ALPHANUMERIC = MODE_ALPHANUMERIC,
  MODE_BYTE = MODE_BYTE,
  ECC_LOW = ECC_LOW,
  ECC_MEDIUM = ECC_MEDIUM,
  ECC_QUARTILE = ECC_QUARTILE,
  ECC_HIGH = ECC_HIGH,
}
