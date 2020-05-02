-- GENERAL CONSTANTS --
TEXTURE_BASE_SIZE = 32
WALL_STATE_CONFIGURATIONS = {[0]=0,[1]=1,[5]=2,[21]=3,[85]=4,[17]=5,[29]=6,[113]=7,[93]=8,[125]=9,[7]=10,[31]=11,[127]=12,[255]=13,[119]=14}



local function enum(n,i)
  i = i or 1
  if n > i then
    return i, enum(n,i+1)
  end
  return n
end

-- ENUM CONSTANTS --
TYPE_WALL, TYPE_GLASS, TYPE_MIRROR, TYPE_DMIRROR, TYPE_PWHEEL, TYPE_RECEIVER = enum(7)