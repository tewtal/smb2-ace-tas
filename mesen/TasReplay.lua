-- Settings

local fileName = "D:\\SMB2\\replayfiles\\build.r16m"
local fileType = 1   -- 1 = r16m, 2 = r08, 3 = raw

local latchFilter = 0
local latchFilterOff = -1

-- Don't change anything below this
local inputs = nil
local latch = 0
local latchFlag = 0
local lastFrame = 0
local clock1 = 0
local clock2 = 0

function readInputs()
  inputs = {}
  fp = io.open(fileName, "rb")
  local l = 1
  while true do

    -- r16m
    if fileType == 1 then 
      local bytes = fp:read(16)
      if not bytes then break end
      inputs[l] = bytes
    end
    
    -- r08
    if fileType == 2 then 
      local bytes = fp:read(2)
      if not bytes then break end
      if not bytes:len() == 2 then break end      
      local data = string.char(bytes:byte(1)) .. "\000\000\000\000\000\000\000" .. string.char(bytes:byte(2)) .. "\000\000\000\000\000\000\000" 
      inputs[l] = data
    end
    
    -- raw
    if fileType == 3 then
      local bytes = fp:read(4)
      if not bytes then break end
      if not bytes:len() == 4 then break end      
      local data = string.char(bytes:byte(2)) .. string.char(bytes:byte(1)) .. "\000\000\000\000\000\000" .. string.char(bytes:byte(4)) .. string.char(bytes:byte(3)) .. "\000\000\000\000\000\000"
      inputs[l] = data
    end
    
    l = l + 1
  end  
  fp.close()
end

function onReset()
  latch = 0
  latchFlag = 0
  clock1 = 0
  clock2 = 0
  readInputs()
  emu.log("Reset detected...")
end

-- Latch
function onLatchWrite(address, value)
  if value == 1 then
    latchFlag = 1
  end
  
  if value == 0 then
    if latchFlag == 1 then
      state = emu.getState()
      
      if latchFilter == 0 then
        latch = latch + 1
      end
      
      if latchFilter == 1 then
        if state.ppu.frameCount ~= lastFrame then
          latch = latch + 1
          lastFrame = state.ppu.frameCount
        end
        
        if latchFilterOff == state.ppu.frameCount then
          latchFilter = 0
        end
      end
      
      clock1 = 0
      clock2 = 0
    end
    latchFlag = 0
  end
end

-- Clock
function onDataPort1Read(address, value)
  if inputs[latch] then
    data = (string.byte(inputs[latch], 1) << 8) + string.byte(inputs[latch], 2)
    data = data >> (15 - clock1)
    data = data & 0x0001
    clock1 = clock1 + 1
    return data  
  end
end

function onDataPort2Read(address, value)
  if inputs[latch] then
    data = (string.byte(inputs[latch], 9) << 8) + string.byte(inputs[latch], 10)
    data = data >> (15 - clock2)
    data = data & 0x0001
    clock2 = clock2 + 1
    return data
  end
end

readInputs()
emu.addMemoryCallback(onLatchWrite, emu.memCallbackType.cpuWrite, 0x4016)
emu.addMemoryCallback(onDataPort1Read, emu.memCallbackType.cpuRead, 0x4016)
emu.addMemoryCallback(onDataPort2Read, emu.memCallbackType.cpuRead, 0x4017)
emu.addEventCallback(onReset, emu.eventType.reset)

