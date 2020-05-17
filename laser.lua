local objects = require("objects")
local grid = require("grid")
local bit = require("bit")
local bnot, band, bor, bxor, rshift, lshift = bit.bnot, bit.band, bit.bor, bit.bxor, bit.rshift, bit.lshift

local laser = {}

local LaserGridH = {}
local LaserGridV = {}
local grid_width = 0
local grid_height= 0

local mask1 = false
local mask1_r = 0
local mask2 = false
local mask2_r = 0
local laser_r = 0
local frame = 1
local TEXTURE_OFFSET = TEXTURE_BASE_SIZE/2
local function stencilFunction()
   love.graphics.setShader(MASK_EFFECT2)
   if mask1 then love.graphics.draw(mask1, TEXTURE_OFFSET, TEXTURE_OFFSET, mask1_r, nil, nil, TEXTURE_OFFSET, TEXTURE_OFFSET) end
   if mask2 then love.graphics.draw(mask2, TEXTURE_OFFSET, TEXTURE_OFFSET, mask2_r, nil, nil, TEXTURE_OFFSET, TEXTURE_OFFSET) end
   love.graphics.draw(MASK_LASER[frame], TEXTURE_OFFSET, TEXTURE_OFFSET, laser_r, nil, nil, TEXTURE_OFFSET, TEXTURE_OFFSET)
   love.graphics.setShader()
end
local MASK_STRAIGHT_HALF = love.graphics.newImage("Textures/mask_straight_half.png")
local MASK_DIAGONAL_HALF = love.graphics.newImage("Textures/mask_diagonal_half.png")

UpdateLaserFG = false
LaserFrame = {}
local LaserFrameUpdate = {}

function laser.update()
  grid_width, grid_height = grid.getDimensions()
  if UpdateLaserFG then
    for i=1,#TEXTURE_LASER do
      LaserFrameUpdate[i] = true
    end
    UpdateLaserFG = false
    LaserGridH = {}
    LaserGridV = {}
    for i=1,grid_width+1 do
      LaserGridH[i] = {}
      for j=1,grid_height do
        LaserGridH[i][j] = {0}
        LaserGridH[i][j][0] = 0
      end
    end
    for i=1,grid_width do
      LaserGridV[i] = {}
      for j=1,grid_height+1 do
        LaserGridV[i][j] = {0}
        LaserGridV[i][j][0] = 0
      end
    end
    
    for i=1,objects.getId(TYPE_SOURCE) do
      local source = ObjectReferences[TYPE_SOURCE][i]
      if source then
        if source.state == 2 then
          local r = source.rotation
          laser.create(source.xpos + (r==1 and 1 or 0), source.ypos + (r==2 and 1 or 0), r%2==0, (r==1 or r==2), source.color)
        end
      end
    end
    
    for i=1,objects.getId(TYPE_RECEIVER) do
      local receiver = ObjectReferences[TYPE_RECEIVER][i]
      if receiver then
        local new_state = 1
        local l_c = 0
        if receiver.rotation%2==0 then  -- Vertical laser test
          local l_x, l_y = receiver.xpos, receiver.ypos + (band(receiver.rotation,2)==2 and 1 or 0)
          l_c = bor(LaserGridV[l_x][l_y][0],LaserGridV[l_x][l_y][1])
        else                            -- Horizontal laser test
          local l_x, l_y = receiver.xpos + (band(receiver.rotation,3)==3 and 0 or 1), receiver.ypos
          l_c = bor(LaserGridH[l_x][l_y][0],LaserGridH[l_x][l_y][1])
        end

        if band(receiver.color,8)~=0 then
          if l_c~=0 then new_state = 2 end
        elseif band(bnot(l_c),receiver.color) == 0 then
          new_state = 2
        end
        if receiver.state ~= new_state then
          receiver.state = new_state
          UpdateObjectType[TYPE_RECEIVER] = true
        end
      end
    end
  end
  
  frame = math.floor(game_time*LASER_FREQUENCY)%#TEXTURE_LASER+1
  if LaserFrameUpdate[frame] then laser.drawFrame(frame) end
  canvas_LL = LaserFrame[frame]

end

function laser.create(x,y,vertical,dir,color) --dir is true for positive direction
  dir = dir and 1 or 0
  if vertical then
--  LASER TRAVELING VERTICALLY --
    if not (LaserGridV[x] and LaserGridV[x][y]) then return nil end

    local laser_present = LaserGridV[x][y][dir] or 0
    if band(bnot(laser_present),color)==0 then
      return nil
    else
--    COLORING CURRENT POSITION
      LaserGridV[x][y][dir] = bor(LaserGridV[x][y][dir],color)

--    CHECKING HOW LASER BEHAVES AFTER CROSSING THE TILE
      local grid_x, grid_y = x, y - 1 + dir
      if grid_x > grid_width or grid_x < 1 or grid_y > grid_height or grid_y < 1 then return nil end

      local obj_tp = grid.checkGrid(grid_x,grid_y)
      if obj_tp then

        if obj_tp == TYPE_MIRROR then
          local o = Grid[grid_x][grid_y]
          local m_color = o.color
          local m_r = o.rotation
          if band(o.state,2)~=0 then
--        MIRROR IS DIAGONAL
            local inv_dir = (m_r%2==1)
            laser.create(x,y+(dir==1 and 1 or -1),vertical,(dir==1),band(color,bnot(m_color)))
            if inv_dir then
              laser.create(grid_x+1-dir,grid_y,not vertical,not (dir==1),band(color,m_color))
            else
              laser.create(grid_x+dir,grid_y,not vertical,(dir==1),band(color,m_color))
            end

          else
--        MIRROR IS STRAIGHT
            if o.rotation%2==0 then
              laser.create(x,y,vertical,not (dir == 1),band(color,m_color))
              laser.create(x,y+(dir==1 and 1 or -1),vertical,(dir==1),band(color,bnot(m_color)))
            end
          end
          return nil

        elseif obj_tp == TYPE_PWHEEL then
          local o = Grid[grid_x][grid_y]
          local o = Grid[grid_x][grid_y]
          local w_color = o.color
          local w_r = o.rotation
          if band(color,COLOR_BLUE)~=0 then
            if band(o.state,2)~=0 then
--          PWHEEL IS DIAGONAL
              local inv_dir = (w_r%2==1)
              if inv_dir then
                laser.create(grid_x+1-dir,grid_y,not vertical,not (dir==1),w_color)
              else
                laser.create(grid_x+dir,grid_y,not vertical,(dir==1),w_color)
              end

            else
--          PWHEEL IS STRAIGHT
              if o.rotation%2==0 then laser.create(x,y,vertical,not (dir == 1),w_color) end
            end
          end
          return nil

        elseif obj_tp == TYPE_GLASS then
          laser.create(x,y+(dir==1 and 1 or -1),vertical,(dir == 1),color)
          return nil
        elseif obj_tp == TYPE_PRISM then
--      UNDEFINED -> laser stops
          return nil
        end

      else
--      NOTHING AT GIVEN TILE
        laser.create(x,y+(dir==1 and 1 or -1),vertical,(dir == 1),color)
        return nil
      end
    end
  else
--  LASER TRAVELING HORIZONTALLY --
    if not (LaserGridH[x] and LaserGridH[x][y]) then return nil end

    local laser_present = LaserGridH[x][y][dir] or 0
    if band(bnot(laser_present),color)==0 then
      return nil
    else
--    COLORING CURRENT POSITION
      LaserGridH[x][y][dir] = bor(LaserGridH[x][y][dir],color)

--    CHECKING HOW LASER BEHAVES AFTER CROSSING THE TILE
      local grid_x, grid_y = x - 1 + dir, y
      if grid_x > grid_width or grid_x < 1 or grid_y > grid_height or grid_y < 1 then return nil end

      local obj_tp = grid.checkGrid(grid_x,grid_y)
      if obj_tp then

        if obj_tp == TYPE_MIRROR then
          local o = Grid[grid_x][grid_y]
          local m_color = o.color
          local m_r = o.rotation
          if band(o.state,2)~=0 then
--        MIRROR IS DIAGONAL
            local inv_dir = (m_r%2==1)
            laser.create(x+(dir==1 and 1 or -1),y,vertical,(dir==1),band(color,bnot(m_color)))
            if inv_dir then
              laser.create(grid_x,grid_y+1-dir,not vertical,not (dir==1),band(color,m_color))
            else
              laser.create(grid_x,grid_y+dir,not vertical,(dir==1),band(color,m_color))
            end

          else
--        MIRROR IS STRAIGHT
            if o.rotation%2==1 then
              laser.create(x,y,vertical,not (dir == 1),band(color,m_color))
              laser.create(x+(dir==1 and 1 or -1),y,vertical,(dir==1),band(color,bnot(m_color)))
            end
          end
          return nil

        elseif obj_tp == TYPE_PWHEEL then
          local o = Grid[grid_x][grid_y]
          local o = Grid[grid_x][grid_y]
          local w_color = o.color
          local w_r = o.rotation
          if band(color,COLOR_BLUE)~=0 then
            if band(o.state,2)~=0 then
--          PWHEEL IS DIAGONAL
              local inv_dir = (w_r%2==1)
              if inv_dir then
                laser.create(grid_x,grid_y+1-dir,not vertical,not (dir==1),w_color)
              else
                laser.create(grid_x,grid_y+dir,not vertical,(dir==1),w_color)
              end

            else
--          PWHEEL IS STRAIGHT
              if o.rotation%2==1 then laser.create(x,y,vertical,not (dir == 1),w_color) end
            end
          end
          return nil

        elseif obj_tp == TYPE_GLASS then
          laser.create(x+(dir==1 and 1 or -1),y,vertical,(dir == 1),color)
          return nil
        elseif obj_tp == TYPE_PRISM then
--      UNDEFINED -> laser stops
          return nil
        end

      else
--      NOTHING AT GIVEN TILE
        laser.create(x+(dir==1 and 1 or -1),y,vertical,(dir == 1),color)
        return nil
      end
    end
  end
end

function laser.drawFrame(frame)
  LaserFrameUpdate[frame] = false
  love.graphics.setCanvas(LaserFrame[frame])
  love.graphics.clear()
  love.graphics.setBlendMode("lighten","premultiplied")
  
  for i=1,grid_width do
    for j=1,grid_height do
      local LaserSides = {}
      LaserSides[0] = bor(LaserGridV[i][j][0],LaserGridV[i][j][1])
      LaserSides[1] = bor(LaserGridH[i+1][j][0],LaserGridH[i+1][j][1])
      LaserSides[2] = bor(LaserGridV[i][j+1][0],LaserGridV[i][j+1][1])
      LaserSides[3] = bor(LaserGridH[i][j][0],LaserGridH[i][j][1])
      local tmp = 0
      for k=0,3 do tmp = tmp+LaserSides[k] end
      if tmp ~= 0 then
        love.graphics.setCanvas{canvas_Texture,stencil = true}
        love.graphics.clear()

        local obj = grid.checkGrid(i,j)
        if obj == TYPE_MIRROR or obj == TYPE_PWHEEL then
  --    MIRROR OR PWHEEL, COMPLICATED DRAWING
          if band(Grid[i][j].state,1) == 1 then
  --      IF STRAIGHT
            for k=0,3 do
              local color = LaserSides[k]
              if color ~= 0 and k%2 == Grid[i][j].rotation%2 then
                love.graphics.setColor(band(color,1), band(color,2), band(color,4))
                mask1 = MASK_STRAIGHT_HALF
                mask1_r = math.rad(90*k)
                mask2 = MASK[obj]
                mask2_r = math.rad(90*Grid[i][j].rotation)
                laser_r = math.rad(90*(k%2))
                love.graphics.stencil(stencilFunction, "replace", 1)
                love.graphics.setStencilTest("less", 1)
                love.graphics.draw(TEXTURE_LASER[frame],TEXTURE_OFFSET,TEXTURE_OFFSET,laser_r,nil,nil,TEXTURE_OFFSET,TEXTURE_OFFSET)
                love.graphics.setCanvas(LaserFrame[frame])
                love.graphics.draw(canvas_Texture,TEXTURE_BASE_SIZE*(i-1),TEXTURE_BASE_SIZE*(j-1))
                love.graphics.setCanvas{canvas_Texture,stencil = true}
                love.graphics.clear()
              end
            end
          else
  --      IF DIAGONAL
            for k=0,3 do
              local color = LaserSides[k]
              if color ~=0 then
                love.graphics.setColor(band(color,1), band(color,2), band(color,4))
                mask1 = MASK_DIAGONAL_HALF
                mask1_r = math.rad(90*(Grid[i][j].rotation+ ((k==Grid[i][j].rotation or k==(Grid[i][j].rotation+1)%4) and 0 or 2)))
                mask2 = MASK[-obj]
                mask2_r = math.rad(90*Grid[i][j].rotation)
                laser_r = math.rad(90*(k%2))
                love.graphics.stencil(stencilFunction, "replace", 1)
                love.graphics.setStencilTest("less", 1)
                love.graphics.draw(TEXTURE_LASER[frame],TEXTURE_OFFSET,TEXTURE_OFFSET,laser_r,nil,nil,TEXTURE_OFFSET,TEXTURE_OFFSET)
                love.graphics.setStencilTest()
                love.graphics.setCanvas(LaserFrame[frame])
                love.graphics.draw(canvas_Texture,TEXTURE_BASE_SIZE*(i-1),TEXTURE_BASE_SIZE*(j-1))
                love.graphics.setCanvas{canvas_Texture,stencil = true}
                love.graphics.clear()
              end
            end
          end

        elseif obj and obj ~= TYPE_GLASS then
  --    FULL BLOCK, DRAW HALVES
          for k=0,3 do
            local color = LaserSides[k]
            if color ~= 0 then
              love.graphics.setColor(band(color,1), band(color,2), band(color,4))
              mask1 = MASK_STRAIGHT_HALF
              mask1_r = math.rad(90*k)
              mask2 = false
              laser_r = math.rad(90*(k%2))
              love.graphics.stencil(stencilFunction, "replace", 1)
              love.graphics.setStencilTest("less", 1)
              love.graphics.draw(TEXTURE_LASER[frame],TEXTURE_OFFSET,TEXTURE_OFFSET,laser_r,nil,nil,TEXTURE_OFFSET,TEXTURE_OFFSET)
              love.graphics.setCanvas(LaserFrame[frame])
              love.graphics.draw(canvas_Texture,TEXTURE_BASE_SIZE*(i-1),TEXTURE_BASE_SIZE*(j-1))
              love.graphics.setCanvas{canvas_Texture,stencil = true}
              love.graphics.clear()
            end
          end
        else
  --    EMPTY SPACE, DRAW ALL
          for k=0,1 do
            local color = LaserSides[k]
            if color ~= 0 then
              love.graphics.setColor(band(color,1), band(color,2), band(color,4))
              mask1 = false
              mask2 = false
              laser_r = math.rad(k*90)
              love.graphics.setStencilTest("less", 1)
              love.graphics.stencil(stencilFunction, "replace", 1)
              love.graphics.draw(TEXTURE_LASER[frame],TEXTURE_OFFSET,TEXTURE_OFFSET,laser_r,nil,nil,TEXTURE_OFFSET,TEXTURE_OFFSET)
              love.graphics.setCanvas(LaserFrame[frame])
              love.graphics.draw(canvas_Texture,TEXTURE_BASE_SIZE*(i-1),TEXTURE_BASE_SIZE*(j-1))
              love.graphics.setCanvas{canvas_Texture,stencil = true}
              love.graphics.clear()
            end
          end
        end
      end
    end
  end
  
  love.graphics.setColor(1,1,1,1)
  love.graphics.setCanvas()
  love.graphics.setStencilTest()
  love.graphics.setBlendMode("alpha","alphamultiply")
end

return laser