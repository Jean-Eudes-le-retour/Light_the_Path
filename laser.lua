local objects = require("objects")
local grid = require("grid")
local bit = require("bit")
local bnot, band, bor, bxor, rshift, lshift = bit.bnot, bit.band, bit.bor, bit.bxor, bit.rshift, bit.lshift

local laser = {}

local LaserGridH = {}
local LaserGridV = {}
local grid_width = 0
local grid_height= 0

function laser.update()
  grid_width, grid_height = grid.getDimensions()
  LaserGridH = {}
  LaserGridV = {}
  for i=1,grid_width+1 do
    LaserGridH[i] = {}
    for j=1,grid_height do
      LaserGridH[i][j] = {0}
      LaserGridH[i][j][0] = 0
    end
  end
  for i=1,grid_height+1 do
    LaserGridV[i] = {}
    for j=1,grid_width do
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
      LaserGridV[x][y][dir] = color

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
            local inv_dir = (m_r%2==0)
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
              local inv_dir = (w_r%2==0)
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
      LaserGridH[x][y][dir] = color

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
            local inv_dir = (m_r%2==0)
            laser.create(x+(dir==1 and 1 or -1),y,vertical,(dir==1),band(color,bnot(m_color)))
            if inv_dir then
              laser.create(grid_x,grid_y+1-dir,not vertical,not (dir==1),band(color,m_color))
            else
              laser.create(grid_x,grid_y+dir,not vertical,(dir==1),band(color,m_color))
            end

          else
--        MIRROR IS STRAIGHT
            if o.rotation%2==0 then
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
              local inv_dir = (w_r%2==0)
              if inv_dir then
                laser.create(grid_x,grid_y+1-dir,not vertical,not (dir==1),w_color)
              else
                laser.create(grid_x,grid_y+dir,not vertical,(dir==1),w_color)
              end

            else
--          PWHEEL IS STRAIGHT
              if o.rotation%2==0 then laser.create(x,y,vertical,not (dir == 1),w_color) end
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

return laser