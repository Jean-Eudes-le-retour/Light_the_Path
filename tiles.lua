--[[
The point of this module is to define a function which updates the canvases IF REQUIRED by UpdateObjectType
canvas_WL, canvas_GL, canvas_BG, canvas_OL sizes are updated when resolution changes in createDrawbox. Assume they are always at the right size.
The canvases must be made at BASE RESOLUTION, the magnifying is done later on when they will be drawn in another module.
]]

tiles = {}

function tiles.loadTextures()
  TEXTURES = {}
  for i=1,#TYPES do
    local Path = {}
    for j=1,NUM_STATES[i] do
      Path[j] = "/Textures/"..TYPES[i].."_"..tostring(j)..".png"
      if not file_exists(Path[j]) then
        print(Path[j].." not found! Using placeholder!")
        Path[j] = "/Textures/PLACEHOLDER.png"
      end
    end
    TEXTURES[i] = love.graphics.newArrayImage(Path)
  end
  local Path = {}
  for i=1,BACKGROUND_VARIANTS do
    Path[i] = "/Textures/BG_"..tostring(i)..".png"
    if not file_exists(Path[i]) then
      print(Path[i].." not found! Using placeholder!")
      Path[i] = "/Textures/PLACEHOLDER.png"
    end
  end
  TEXTURES[0] = love.graphics.newArrayImage(Path)
  
  OVERLAY_TEXTURES = {}
  for i=1,NUM_CONNECTED_TEXTURE_TILES do
    local Path = {}
    for j=1,NUM_OVERLAY_TEXTURES do
      Path[j] = "/Textures/Overlay/"..TYPES[i].."_Overlay_"..tostring(j)..".png"
      if not file_exists(Path[j]) then
        print(Path[j].." not found! Using placeholder!")
        Path[j] = "/Textures/PLACEHOLDER.png"
      end
    end
    OVERLAY_TEXTURES[i] = love.graphics.newArrayImage(Path)
  end
end
tiles.reloadTextures = tiles.loadTextures

function tiles.update()
  if not BG_is_drawn then tiles.updateBG() BG_is_drawn = true end
  if UpdateObjectType[TYPE_WALL] then tiles.updateWall() UpdateObjectType[TYPE_WALL] = false end
  if UpdateObjectType[TYPE_GLASS] then tiles.updateGlass() UpdateObjectType[TYPE_GLASS] = false end
  for i=NUM_CONNECTED_TEXTURE_TILES+1,#TYPES do
    if UpdateObjectType[i] then
      tiles.updateObjects()
      for j=i,#TYPES do UpdateObjectType[j] = false end
    end
  end
end

function tiles.updateBG()

end

function tiles.updateWall()

end

function tiles.updateGlass()

end

function tiles.updateObjects()

end

return tiles