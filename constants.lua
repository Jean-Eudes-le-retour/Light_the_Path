-- GENERAL CONSTANTS --
TEXTURE_BASE_SIZE = 32
BACKGROUND_VARIANTS = 1
NUM_OVERLAY_TEXTURES = 15
NUM_CONNECTED_TEXTURE_TILES = 2
STATE_CONFIGURATIONS = {[1]=1,[5]=2,[21]=3,[85]=4,[17]=5,[29]=6,[113]=7,[93]=8,[125]=9,[7]=10,[31]=11,[127]=12,[255]=13,[119]=14,[0]=15}

function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true
   else return false end
end

local function enum(n,i)
  i = i or 1
  if n > i then
    return i, enum(n,i+1)
  end
  return n
end

-- ENUM CONSTANTS --
NUM_TYPES = 7
TYPE_WALL, TYPE_GLASS, TYPE_SOURCE, TYPE_RECEIVER, TYPE_MIRROR, TYPE_DMIRROR, TYPE_PWHEEL = enum(NUM_TYPES)

NUM_CURSOR_MODE = 3
CURSOR_MOVE, CURSOR_ROTATE, CURSOR_SELECT = enum(NUM_CURSOR_MODE)