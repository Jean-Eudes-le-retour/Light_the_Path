local objects = require("objects")
local grid = require("grid")
local bit = require("bit")
local bnot, band, bor, rshift, lshift = bit.bnot, bit.band, bit.bor, bit.rshift, bit.lshift

--[[
The point of this module is to define a function which updates the canvases IF REQUIRED by UpdateObjectType
canvas_WL, canvas_GL, canvas_BG, canvas_OL sizes are updated when resolution changes in createDrawbox. Assume they are always at the right size.
The canvases must be made at BASE RESOLUTION, the magnifying is done later on when they will be drawn in another module.
]]

tiles = {}

function tiles.loadTextures()
  print("Loading textures...")
  TEXTURES = {}
  for i=1,#TYPES do
    local Path = {}
    for j=1,NUM_STATES[i] do
      Path[j] = "/Textures/"..TYPES[i].."_"..tostring(j)..".png"
      if not file_exists(Path[j]) then
        print(Path[j].." could not be opened! Using placeholder!")
        Path[j] = "/Textures/PLACEHOLDER.png"
      end
    end
    TEXTURES[i] = love.graphics.newArrayImage(Path)
  end
  
  print("Loading background textures...")
  local Path = {}
  for i=1,BACKGROUND_VARIANTS do
    Path[i] = "/Textures/BG_"..tostring(i)..".png"
    if not file_exists(Path[i]) then
      print(Path[i].." could not be opened! Using placeholder!")
      Path[i] = "/Textures/PLACEHOLDER.png"
    end
  end
  TEXTURES[0] = love.graphics.newArrayImage(Path)
  
  print("Loading overlays...")
  OVERLAY_TEXTURES = {}
  for i=1,NUM_CONNECTED_TEXTURE_TILES do
    local Path = {}
    for j=1,NUM_OVERLAY_TEXTURES do
      Path[j] = "/Textures/Overlay/"..TYPES[i].."_overlay_"..tostring(j)..".png"
      if not file_exists(Path[j]) then
        print(Path[j].." could not be opened! Using placeholder!")
        Path[j] = "/Textures/PLACEHOLDER.png"
      end
    end
    OVERLAY_TEXTURES[i] = love.graphics.newArrayImage(Path)
  end
end
tiles.reloadTextures = tiles.loadTextures

function tiles.update()
  if not BG_is_drawn then print("Drawing background layer...") tiles.updateBG() BG_is_drawn = true end
  if UpdateObjectType[TYPE_WALL] then print("Updating wall states...") tiles.updateWall() UpdateObjectType[TYPE_WALL] = false end
  if UpdateObjectType[TYPE_GLASS] then print("Updating glass states...") tiles.updateGlass() UpdateObjectType[TYPE_GLASS] = false end
  for i=NUM_CONNECTED_TEXTURE_TILES+1,#TYPES do
    if UpdateObjectType[i] then
      print("Updating all object graphics...")
      tiles.updateObjects()
      for j=i,#TYPES do UpdateObjectType[j] = false end
    end
  end
end

function tiles.updateBG()
  print("Background drawing script not written yet.")
end

function tiles.updateWall()
  tiles.updateConnectedTextureTypeState(TYPE_WALL)
  -- draw walls to canvas...
end

function tiles.updateGlass()
  tiles.updateConnectedTextureTypeState(TYPE_GLASS)
  -- draw glass to canvas...
end

function tiles.updateObjects()

end

-- Used exclusively in updateConnectedTextureTypeState(), do not use.
function tiles.checkTypeAt(t,xpos,ypos,state,index,update_self)
  if Grid[xpos] and Grid[xpos][ypos] and (Grid[xpos][ypos].t == t or (t == TYPE_GLASS and Grid[xpos][ypos].glassState)) then
    state = state + lshift(1,index)
    if update_self then updateConnectedTextureTypeState(t,xpos,ypos,false) end
  end
  index = index+1
  return state, index
end
-- Update wall data of wall at x,y and neighbors if updateNeighbors. Foolproof. If nothing specified updates all walls in the game (includes non-placed walls)
function tiles.updateConnectedTextureTypeState(t,xpos,ypos,updateNeighbors)
  local index = 0
  local state = 0
  t = t or TYPE_WALL
  local typeIsPresent = false
  if updateNeighbors == nil then updateNeighbors = true end
  if xpos and ypos then
    typeIsPresent = grid.checkGrid(xpos,ypos,t) or ((t == TYPE_GLASS) and Grid[xpos][ypos].glassState)
    for i=xpos-1,xpos+1 do
      state, index = tiles.checkTypeAt(t,i,ypos-1,state,index,updateNeighbors)
    end
    state, index = tiles.checkTypeAt(t,xpos+1,ypos,state,index,updateNeighbors)
    for i=xpos+1,xpos-1,-1 do
      state, index = tiles.checkTypeAt(t,i,ypos+1,state,index,updateNeighbors)
    end
    state, index = tiles.checkTypeAt(t,xpos-1,ypos,state,index,updateNeighbors)
    if not typeIsPresent then return end

    -- code allowing comparison of 15 possible wall states
    -- invert state to represent empty space with bits instead of walls
    state = band(bnot(state),255)
    -- an empty space in cardinal directions renders the information on corner blocks useless - reduce possible configurations
    if band(state,2)~=0 then state = bor(state,7) end
    if band(state,8)~=0 then state = bor(state,28) end
    if band(state,32)~=0 then state = bor(state,112) end
    if band(state,128)~=0 then state = bor(state,193) end
    -- rotate the configuration clockwise and compare with table
    local old_bit1 = 0
    local old_bit2 = 0
    for i=0,3 do
      if STATE_CONFIGURATIONS[state] then
      if t == TYPE_GLASS then
        Grid[xpos][ypos].glassState = STATE_CONFIGURATIONS[state]
        Grid[xpos][ypos].glassRotation = (-i)%4
      else
        Grid[xpos][ypos].state = STATE_CONFIGURATIONS[state] end
        Grid[xpos][ypos].rotation = (-i)%4
        return true
      end
      old_bit1 = band(state,1) ~= 0 and 64 or 0
      old_bit2 = band(state,2) ~= 0 and 128 or 0
      state = bor(rshift(state,2),(old_bit1+old_bit2))
    end
    return false
  elseif t == TYPE_GLASS then
    for j=1,#TYPES do
      if j == TYPE_GLASS then j = j+1 end
      for i=1,objects.getId(j) do
        local o = ObjectReferences[j][i]
        if o then tiles.updateConnectedTextureTypeState(t,o.xpos,o.ypos,false) end -- extra precaution in case objects were externally deleted
      end
    end
  else
    for i=1,objects.getId(t) do
      local o = ObjectReferences[t][i]
      if o then tiles.updateConnectedTextureTypeState(t,o.xpos,o.ypos,false) end -- extra precaution in case objects were externally deleted
    end
    return true
  end
end

return tiles