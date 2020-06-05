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
local halt = false
local step = false
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
  for i=1,#UpdateObjectType do
    if UpdateObjectType[i] then UpdateLaserFG = true end
  end
  if laser.checkDelayUpdate() then UpdateLaserFG = true end

  if halt and not step then goto skip_update end
  step = false
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
        if Grid[source.xpos] and Grid[source.xpos][source.ypos] and source.state == 2 then
          local r = source.rotation
          laser.create(source.xpos + (r==1 and 1 or 0), source.ypos + (r==2 and 1 or 0), r%2==0, (r==1 or r==2), source.color)
        end
      end
    end
    
--  EMIT FROM DELAYS
    for i=1,objects.getId(TYPE_DELAY) do
      local delay = ObjectReferences[TYPE_DELAY][i]
      if delay and Grid[delay.xpos] and Grid[delay.xpos][delay.ypos] then
        for j=0,3 do
          local l_c = delay.memory[(delay.index-delay.delay-1)%61+1][j]
          if l_c ~= 0 then
            if delay.state == DELAY_TRAVERSE then
              laser.create(delay.xpos + (j==3 and 1 or 0), delay.ypos + (j==0 and 1 or 0), j%2==0, (j==0 or j==3), delay.color == COLOR_BLACK and l_c or delay.color)
            elseif delay.state == DELAY_FEEDBACK then
              laser.create(delay.xpos + (j==1 and 1 or 0), delay.ypos + (j==2 and 1 or 0), j%2==0, (j==1 or j==2), delay.color == COLOR_BLACK and l_c or delay.color)
            elseif delay.state == DELAY_QUARTER then
              laser.create(delay.xpos + (j==0 and 1 or 0), delay.ypos + (j==3 and 1 or 0), j%2==1, (j==0 or j==3), delay.color == COLOR_BLACK and l_c or delay.color)
            elseif delay.state == DELAY_IQUARTER then
              laser.create(delay.xpos + (j==2 and 1 or 0), delay.ypos + (j==1 and 1 or 0), j%2==1, (j==1 or j==2), delay.color == COLOR_BLACK and l_c or delay.color)
            elseif delay.state == DELAY_SWIRL then
              laser.create(delay.xpos + (j==0 and 1 or 0), delay.ypos + (j==1 and 1 or 0), j%2==1, (j==0 or j==1), delay.color == COLOR_BLACK and l_c or delay.color)
            elseif delay.state == DELAY_ISWIRL then
              laser.create(delay.xpos + (j==2 and 1 or 0), delay.ypos + (j==3 and 1 or 0), j%2==1, (j==2 or j==3), delay.color == COLOR_BLACK and l_c or delay.color)
            end
          end
        end
      end
    end

--  EMIT FROM LOGIC GATE OUTPUTS
    for i=1,objects.getId(TYPE_LOGIC) do
      local logic = ObjectReferences[TYPE_LOGIC][i]
      if logic and Grid[logic.xpos] and Grid[logic.xpos][logic.ypos] then
        if logic.color ~= COLOR_BLACK then
          for j=0,3 do
            if logic.side and logic.side[j] == "out" then
              laser.create(logic.xpos + (j==1 and 1 or 0), logic.ypos + (j==2 and 1 or 0), j%2==0, (j==1 or j==2), band(logic.color,bnot(COLOR_BLACK)))
            end
          end
        end
        logic.old_color = logic.color
      end
    end

--  UPDATE LOGIC GATE COLORS (1 TICK DELAY TO EMISSION)
    for i=1,objects.getId(TYPE_LOGIC) do
      local logic = ObjectReferences[TYPE_LOGIC][i]
      if logic then
        local c
        if logic.state == LOGIC_OR then
          c = 0
          for j=0,3 do
            if logic.side and logic.side[j] == "in" then c = bor(c,laser.colorAt(logic.xpos,logic.ypos,j,(j==0 or j==3))) end
          end
        elseif logic.state == LOGIC_AND then
          c = COLOR_WHITE
          for j=0,3 do
            if logic.side and logic.side[j] == "in" then c = band(c,laser.colorAt(logic.xpos,logic.ypos,j,(j==0 or j==3))) end
          end
        elseif logic.state == LOGIC_NOT then
          c = COLOR_WHITE
          for j=0,3 do
            if logic.side and logic.side[j] == "in" then c = band(c,bnot(laser.colorAt(logic.xpos,logic.ypos,j,(j==0 or j==3)))) end
          end
        end
        logic.color = bor(c,COLOR_BLACK)
        
        if logic.color ~= logic.old_color then
          UpdateObjectType[TYPE_LOGIC] = true
          UpdateLaserFG = true
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
  
  for i=1,objects.getId(TYPE_DELAY) do
    local delay = ObjectReferences[TYPE_DELAY][i]
    if delay then
      if Grid[delay.xpos] and Grid[delay.xpos][delay.ypos] then
        for j=0,3 do
          if j%2 == 0 then
            delay.memory[delay.index][j] = LaserGridV[delay.xpos][delay.ypos + (j==0 and 0 or 1)][(j==0 and 1 or 0)]
          else
            delay.memory[delay.index][j] = LaserGridH[delay.xpos + (j==3 and 0 or 1)][delay.ypos][(j==3 and 1 or 0)]
          end
        end
      else
        for i=1,61 do
          for j=0,3 do
            delay.memory[i][j] = 0
          end
        end
      end
      delay.index = delay.index%61+1
    end
  end
  
  ::skip_update::
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

      local obj_tp = grid.check(grid_x,grid_y)
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
        elseif obj_tp == TYPE_LOGIC then
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

      local obj_tp = grid.check(grid_x,grid_y)
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
        elseif obj_tp == TYPE_LOGIC then
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

        local obj = grid.check(i,j)
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

function laser.colorAt(x,y,r,d)
  if r%2==0 then
    return LaserGridV[x][y + (r==2 and 1 or 0)][d and 1 or 0]
  else
    return LaserGridH[x + (r==1 and 1 or 0)][y][d and 1 or 0]
  end
end

function laser.checkDelayUpdate()
  for i=1,objects.getId(TYPE_DELAY) do
    local delay = ObjectReferences[TYPE_DELAY][i]
    if delay then
      for j=0,3 do
        if delay.memory[(delay.index-delay.delay-1)%61+1][j] ~= delay.memory[(delay.index-delay.delay-2)%61+1][j] then return true end
      end
    end
  end
  return false
end

function laser.halt(bool)
  if type(bool) == "boolean" then
    halt = bool
  else
    halt = not halt
  end
end

function laser.isHalted()
  return halt
end

function laser.step()
  halt = true
  step = true
end

return laser