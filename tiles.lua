local objects = require("objects")
local grid = require("grid")
local bit = require("bit")
local bnot, band, bor, bxor, rshift, lshift = bit.bnot, bit.band, bit.bor, bit.bxor, bit.rshift, bit.lshift

--[[
The point of this module is to define a function which updates the canvases IF REQUIRED by UpdateObjectType
canvas_WL, canvas_GL, canvas_BG, canvas_OL, canvas_GD sizes are updated when resolution changes in createDrawbox. Assume they are always at the right size.
The canvases must be made at BASE RESOLUTION, the magnifying is done later on when they will be drawn in another module.
]]

tiles = {}

-- A single texture-sized canvas to easily make unrotated draw operations on before final draw to canvas.
canvas_Texture = love.graphics.newCanvas(TEXTURE_BASE_SIZE,TEXTURE_BASE_SIZE)
local selected_background = 1
local mask = false
local function stencilFunction()
   love.graphics.setShader(MASK_EFFECT)
   love.graphics.draw(mask, 0, 0)
   love.graphics.setShader()
end
 
-- Must be called at initialisation, if called again, will reload the textures.
function tiles.loadTextures()
  print("Loading textures...")
  TEXTURES = {}
  for i=1,#TYPES do
    local Path = {}
    for j=1,NUM_STATES[i] do
      Path[j] = "Textures/"..TYPES[i].."_"..tostring(j)..".png"
      if not file_exists(Path[j]) then
        print(Path[j].." could not be opened! Using placeholder!")
        Path[j] = "Textures/PLACEHOLDER.png"
      end
    end
    TEXTURES[i] = love.graphics.newArrayImage(Path)
  end
  
  print("Loading background textures...")
  local Path = {}
  for i=1,BACKGROUND_VARIANTS do
    Path[i] = "Textures/BG_"..tostring(i)..".png"
    if not file_exists(Path[i]) then
      print(Path[i].." could not be opened! Using placeholder!")
      Path[i] = "Textures/PLACEHOLDER.png"
    end
  end
  TEXTURES[0] = love.graphics.newArrayImage(Path)
  
  print("Loading overlays...")
  OVERLAY_TEXTURES = {}
  for i=1,NUM_CONNECTED_TEXTURE_TILES do
    local Path = {}
    for j=1,NUM_OVERLAY_TEXTURES do
      Path[j] = "Textures/Overlay/"..TYPES[i].."_overlay_"..tostring(j)..".png"
      if not file_exists(Path[j]) then
        print(Path[j].." could not be opened! Using placeholder!")
        Path[j] = "Textures/PLACEHOLDER.png"
      end
    end
    OVERLAY_TEXTURES[i] = love.graphics.newArrayImage(Path)
  end
  
  print("Loading masks...")
  MASK = {}
  for i=1,#TYPES do
  local path = ""
    if DEFAULT_OBJECT[i].hasMask then 
      path = "Textures/"..TYPES[i].."_mask.png"
      if file_exists(path) then
        MASK[i] = love.graphics.newImage(path)
      else
        print(path.." could not be opened! Not using mask...")
      end
      if DEFAULT_OBJECT[i].rotateByEights then
        path = "Textures/"..TYPES[i].."_mask_2.png"
        if file_exists(path) then
          MASK[-i] = love.graphics.newImage(path)
        else
          print(path.." could not be opened! Not using mask...")
        end
      end
    end
  end
end
tiles.reloadTextures = tiles.loadTextures

-- Set active color to specified color (bit 1 is Red, bit 2 is Green, bit 3 is Blue). If color's 4th bit is on, AND all other bits are off, the texture will be printed ALL BLACK. Otherwise color = 0 means WHITE.
function tiles.setColor(color)
  local Red, Green, Blue = band(color,1), band(color,2), band(color,4)
  love.graphics.setColor(Red,Green,Blue)
end

-- Draw a texture to the canvas_Texture canvas, takes mask into account if it exists.
function tiles.drawTexture(t,state,color,side)
  love.graphics.setCanvas{canvas_Texture,stencil = true}
  love.graphics.clear()
  if not state or state < 1 or state > NUM_STATES[t] then state = (state-1)%NUM_STATES[t]+1 end
  tiles.setColor(color)
  if MASK[t] then
    mask = MASK[(DEFAULT_OBJECT[t].rotateByEights and band(state,2) ~= 0) and -t or t]
    love.graphics.stencil(stencilFunction, "replace", 1)
    love.graphics.setStencilTest("less", 1)
    love.graphics.drawLayer(TEXTURES[t],state)
    love.graphics.setColor(1,1,1)
    love.graphics.setStencilTest("greater", 0)
    love.graphics.drawLayer(TEXTURES[t],state)
    love.graphics.setStencilTest()
  else
    love.graphics.drawLayer(TEXTURES[t],state)
    love.graphics.setColor(1,1,1)
  end
  if t <= NUM_CONNECTED_TEXTURE_TILES then
    love.graphics.drawLayer(OVERLAY_TEXTURES[t],13)
  end
  if t == TYPE_LOGIC or t == TYPE_RECEIVER then
    if side then
      for i=0,3 do
        if side[i] == "in" then
          love.graphics.draw(TEXTURE_SIDEINPUT,TEXTURE_OFFSET,TEXTURE_OFFSET,math.rad(90*i),nil,nil,TEXTURE_OFFSET,TEXTURE_OFFSET)
        elseif side[i] == "out" then
          love.graphics.draw(TEXTURE_SIDEOUTPUT,TEXTURE_OFFSET,TEXTURE_OFFSET,math.rad(90*i),nil,nil,TEXTURE_OFFSET,TEXTURE_OFFSET)
        elseif side[i] == "activate" then
          love.graphics.draw(TEXTURE_SIDEACTIVATE,TEXTURE_OFFSET,TEXTURE_OFFSET,math.rad(90*i),nil,nil,TEXTURE_OFFSET,TEXTURE_OFFSET)
        end
      end
    end
  end
end

-- Checks UpdateObjectType table and updates all canvases accordingly by calling specific tile update functions
function tiles.update()
  if UpdateBackgroundFG then tiles.updateBG() end
  if UpdateObjectType[TYPE_WALL] or UpdateObjectType[TYPE_GLASS] or UpdateOverlayFG then
    if UpdateObjectType[TYPE_WALL] then tiles.updateWall() end
    if UpdateObjectType[TYPE_GLASS] then tiles.updateGlass() end
    love.graphics.setCanvas(canvas_OL)
    love.graphics.clear()
    love.graphics.setBlendMode("alpha","premultiplied")
    love.graphics.draw(canvas_WL)
    love.graphics.draw(canvas_GL)
    love.graphics.setBlendMode("alpha")
    love.graphics.setCanvas()
    UpdateOverlayFG = false
  end
  for i=NUM_CONNECTED_TEXTURE_TILES+1,#TYPES do
    if UpdateObjectType[i] then
      tiles.updateObjects()
      for j=i,#TYPES do UpdateObjectType[j] = false end
    end
  end
  love.graphics.setCanvas()
end

-- Update the background canvas
function tiles.updateBG()
  --print("Drawing background layer...")
  love.graphics.setCanvas(canvas_BG)
  love.graphics.clear()
  local grid_size_x, grid_size_y = grid.getDimensions()
  for i=0,grid_size_x-1 do
    for j=0,grid_size_y-1 do
      love.graphics.drawLayer(TEXTURES[0],selected_background,i*TEXTURE_BASE_SIZE,j*TEXTURE_BASE_SIZE)
    end
  end
  UpdateBackgroundFG = false
end

-- Update the wall states and canvas
function tiles.updateWall()
  --print("Updating wall states...")
  tiles.updateConnectedTextureTypeState(TYPE_WALL)

  --print("Updating wall graphics...")
  love.graphics.setCanvas(canvas_WL) 
  love.graphics.clear()
  local o = false
  local xpos, ypos, state, rotation = 0,0,0,0
  for i=1,objects.getId(TYPE_WALL) do
    o = ObjectReferences[TYPE_WALL][i]
    if o and Grid[o.xpos][o.ypos] then
      tiles.setColor(o.color)
      xpos,ypos,state,rotation = o.xpos-1, o.ypos-1, o.state, o.rotation
      love.graphics.drawLayer(TEXTURES[TYPE_WALL],1,xpos*TEXTURE_BASE_SIZE,ypos*TEXTURE_BASE_SIZE)
      love.graphics.setColor(1,1,1)

      xpos = xpos + ((rotation == 1 or rotation == 2) and 1 or 0)
      if rotation > 1 then ypos = ypos+1 end
      rotation = math.rad(90*rotation)
      love.graphics.drawLayer(OVERLAY_TEXTURES[TYPE_WALL],state,xpos*TEXTURE_BASE_SIZE,ypos*TEXTURE_BASE_SIZE,rotation)
    end
  end
  UpdateObjectType[TYPE_WALL] = false
end

-- Update the glass states and canvas
function tiles.updateGlass()
  --print("Updating glass states...")
  tiles.updateConnectedTextureTypeState(TYPE_GLASS)
  
  --print("Updating glass graphics...")
  love.graphics.setCanvas(canvas_GL)
  love.graphics.clear()
  local o = false
  local xpos, ypos, state, rotation = 0,0,0,0
  for j=1,#TYPES do
    for i=1,objects.getId(j) do
      o = ObjectReferences[j][i]
      if o and o.glass and Grid[o.xpos] and Grid[o.xpos][o.ypos] then
        --tiles.setColor(o.color) (issue with o not necessarily being a glass type, but rather an object with glass)
        xpos,ypos,state,rotation = o.xpos-1, o.ypos-1, o.glass, o.glassRotation
        love.graphics.drawLayer(TEXTURES[TYPE_GLASS],1,xpos*TEXTURE_BASE_SIZE,ypos*TEXTURE_BASE_SIZE)
        love.graphics.setColor(1,1,1)
        
        xpos = xpos + ((rotation == 1 or rotation == 2) and 1 or 0)
        if rotation > 1 then ypos = ypos+1 end
        rotation = math.rad(90*rotation)
        love.graphics.drawLayer(OVERLAY_TEXTURES[TYPE_GLASS],state,xpos*TEXTURE_BASE_SIZE,ypos*TEXTURE_BASE_SIZE,rotation)
      end
    end
  end
  UpdateObjectType[TYPE_GLASS] = false
end

-- Update the objects' canvas
function tiles.updateObjects()
  --print("Updating object graphics...")
  love.graphics.setCanvas(canvas_GD)
  love.graphics.clear()
  local o = false
  local xpos, ypos, state, rotation = 0,0,0,0
  for i=NUM_CONNECTED_TEXTURE_TILES+1,#TYPES do
    for j=1,objects.getId(i) do
      o = ObjectReferences[i][j]
      if o and Grid[o.xpos] and Grid[o.xpos][o.ypos] then
        xpos,ypos,state,rotation = o.xpos-1, o.ypos-1, o.state, o.rotation
        xpos = xpos + ((rotation == 1 or rotation == 2) and 1 or 0)
        if rotation > 1 then ypos = ypos+1 end
        rotation = math.rad(90*rotation)
        tiles.drawTexture(i,state,o.color,o.side)
        if o.t == TYPE_DELAY then
          local str = tostring(o.delay)
          if string.len(str) < 2 then str = "0"..str end
          local str_w = FONT_SMALLNUM:getWidth(str)
          local str_h = FONT_SMALLNUM:getHeight()
          love.graphics.setFont(FONT_SMALLNUM)
          love.graphics.print(str, math.ceil((TEXTURE_BASE_SIZE - str_w)/2+1), math.ceil((TEXTURE_BASE_SIZE - str_h)/2)-1)
          love.graphics.setFont(FONT_BASE)
        end
        love.graphics.setCanvas(canvas_GD)
        love.graphics.setBlendMode("alpha","premultiplied")
        love.graphics.draw(canvas_Texture,xpos*TEXTURE_BASE_SIZE,ypos*TEXTURE_BASE_SIZE,rotation)
        love.graphics.setBlendMode("alpha")
      end
    end
  end
  love.graphics.setCanvas()
end

-- Used exclusively in updateConnectedTextureTypeState(), do not use.
function tiles.checkTypeAt(t,xpos,ypos,state,index,update_self)
  if Grid[xpos] and Grid[xpos][ypos] and (Grid[xpos][ypos].t == t or (t == TYPE_GLASS and Grid[xpos][ypos].glass)) then
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
    typeIsPresent = grid.check(xpos,ypos,t) or ((t == TYPE_GLASS) and Grid[xpos][ypos] and Grid[xpos][ypos].glass)
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
          Grid[xpos][ypos].glass = STATE_CONFIGURATIONS[state]
          Grid[xpos][ypos].glassRotation = i%4
        else
          Grid[xpos][ypos].state = STATE_CONFIGURATIONS[state]
          Grid[xpos][ypos].rotation = i%4
          return true
        end
      end
      old_bit1 = band(state,1) ~= 0 and 64 or 0
      old_bit2 = band(state,2) ~= 0 and 128 or 0
      state = bor(rshift(state,2),(old_bit1+old_bit2))
    end
    return false
  elseif t == TYPE_GLASS then
    for j=1,#TYPES do
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