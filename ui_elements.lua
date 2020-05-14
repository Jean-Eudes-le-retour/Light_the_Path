local grid = require("grid")

local ui_elements = {}

local MenuId = 1 --DEFAULT HAS MAIN_MENU ACTIVE
local uniqueId = 0
local UI_TYPES = {"menu","dialogue","tile"}
local NUM_PRESETS = 1
local UI_automatic_scaling = true
local UI_autoscale_factor_x = 1/384 --UI_scale 3*128*UI_scale = ww
local UI_autoscale_factor_y = 1/512 --16*32*UI_scale = wh
local MIN_UI_SCALE = 0.5 --Only applies for manual mode
local MAX_UI_SCALE = 5 --Only applies for manual mode

local UI_scale = 1.5
if UI_automatic_scaling then
  local ww, wh = love.graphics.getDimensions()
  UI_scale = math.min(ww*UI_autoscale_factor_x, wh*UI_autoscale_factor_y)
end


local DEFAULT_BUTTON_SPACING = 6
local DEFAULT_H_DEADZONE = 32
local DEFAULT_V_DEADZONE = 32
----------------------------------------------------------
local TEXTURE_MENU_CORNER = love.graphics.newImage("Textures/menu_corner.png")
local TEXTURE_MENU_SIDE   = love.graphics.newImage("Textures/menu_side.png")
local TEXTURE_REG_BUTTON_NORMAL  = love.graphics.newImage("Textures/default_button_1.png")
local TEXTURE_REG_BUTTON_PRESSED = love.graphics.newImage("Textures/default_button_2.png")
local TEXTURE_REG_BUTTON_HOVERED = love.graphics.newImage("Textures/default_button_3.png")
local TEXTURE_REG_BUTTON_GREYED  = love.graphics.newImage("Textures/default_button_4.png")
local TEXTURE_REG_BUTTON_INVIS   = love.graphics.newImage("Textures/default_button_5.png")
local TEXTURE_COMPL2SQ_BUTTON_NORMAL  = love.graphics.newImage("Textures/compl2sq_button_1.png")
local TEXTURE_COMPL2SQ_BUTTON_PRESSED = love.graphics.newImage("Textures/compl2sq_button_2.png")
local TEXTURE_COMPL2SQ_BUTTON_HOVERED = love.graphics.newImage("Textures/compl2sq_button_3.png")
local TEXTURE_COMPL2SQ_BUTTON_GREYED  = love.graphics.newImage("Textures/compl2sq_button_4.png")
local TEXTURE_COMPL2SQ_BUTTON_INVIS   = love.graphics.newImage("Textures/compl2sq_button_5.png")
local TEXTURE_SQ_BUTTON_NORMAL   = love.graphics.newImage("Textures/sq_button_1.png")
local TEXTURE_SQ_BUTTON_PRESSED  = love.graphics.newImage("Textures/sq_button_2.png")
local TEXTURE_SQ_BUTTON_HOVERED  = love.graphics.newImage("Textures/sq_button_3.png")
local TEXTURE_SQ_BUTTON_GREYED   = love.graphics.newImage("Textures/sq_button_4.png")
local TEXTURE_SQ_BUTTON_INVIS    = love.graphics.newImage("Textures/sq_button_5.png")


local Menu = {} -- Object from which all others are derived (here to define methods)
local DEFAULT_MENU = {
--TYPE
  t = UI_MENU,
  
--VALUES EVALUATED AUTOMATICALLY DO NOT ASSIGN
  xpos = 0,
  ypos = 0,
  width = 0,
  height = 0,
  canvas = false,

--CAN BE CHANGED WITH ASSIGNMENTS AFTER CREATION
  width_factor = 64, --if texture[0] is defined, automatically set to x size
  height_factor = 64, --if texture[0] is defined, automatically set to y size
  width_mode = false, -- width relative mode, if false, actual width will be width*UI_scale IGNORED IF TEXTURE IS PRESENT
  height_mode = false, -- height relative mode, if false, actual height will be height*UI_scale IGNORED IF TEXTURE IS PRESENT

  isBlocking = true,
  window_position_mode = MENU_CENTER,
  imagedata = false, -- if defined, test transparency
  
  update = function(m)
    ui_elements.checkButtonUpdate(m) -- Only if the menu is handled like any other, i.e. buttons have a normal and pressed state dependent on mouse position [optionally hover state]
  end,

}

local DEFAULT_UI = {DEFAULT_MENU,DEFAULT_DIALOGUE,DEFAULT_TILE}
--Menus = {MAIN_MENU} -- Global Menus table
Menus = {}


------------------------------------------------------------------------------------------------------------------------------------------------
-- On screen resize : menu:resize(), menu:draw() for all (use ui_elements.redraw()?)

function Menu:new(t)
  local m = {}
  setmetatable(m, self)
  self.__index = self
  
  m.t = DEFAULT_UI[t] and t or UI_MENU
  m.isBlocking = DEFAULT_UI[t].isBlocking
  m.window_position_mode = DEFAULT_UI[t].window_position_mode
  m.width_mode = DEFAULT_UI[t].width_mode
  m.height_mode = DEFAULT_UI[t].height_mode
  m.width_factor = DEFAULT_UI[t].width_factor
  m.height_factor = DEFAULT_UI[t].height_factor
  m.texture = {}
  m.canvas = DEFAULT_UI[t].canvas
  m.update = DEFAULT_UI[t].update
  
  while MenuId > 0 and not Menus[MenuId] do MenuId = MenuId-1 end
  MenuId = MenuId+1
  m.id = MenuId
  m.uniqueId = uniqueId
  uniqueId = uniqueId+1
  Menus[MenuId] = m
  return m
end

-- For some UI_MENU ui elements, contain imagedata -> some pixels are transparent and must be taken into account in isInMenu
function Menu:isInMenu()
  local cursor_x, cursor_y = love.mouse.getPosition()
--IF THE POSITION AND SIZE SYSTEM IS GRID-BASED
  if self.t == UI_TILE then
    cursor_x, cursor_y = grid.getCursorPosition()
    if cursor_x >= self.xpos and cursor_x < self.xpos + self.width and
       cursor_y >= self.ypos and cursor_y < self.ypos + self.height then
      return true
    else
      return false
    end
  end
--IF SOLELY THE POSITION SYSTEM IS GRID BASED
  if self.t == UI_MENU and self.window_position_mode == MENU_GRID then
    cursor_x, cursor_y = grid.getCursorPosition(true)
    local texture_scale = grid.getTextureScale()
    if cursor_x >= self.xpos and cursor_x < self.xpos + self.width*UI_scale/texture_scale and
       cursor_y >= self.ypos and cursor_y < self.ypos + self.height*UI_scale/texture_scale then
      return true
    else
      return false
    end
  end
--ELSE FOR WINDOW POSITIONING SYSTEM
  if cursor_x > self.xpos and cursor_x <= self.xpos + self.width and
     cursor_y > self.ypos and cursor_y <= self.ypos + self.height then
    return true --ADD IMAGEDATA TESTING!!!!
  else
    return false
  end
end

function Menu:isInButton(i)
  if not self.buttons[i] then return false end
  local cursor_x, cursor_y = love.mouse.getPosition()
--IF GRID-BASED
  if self.t == UI_TILE then
    cursor_x, cursor_y = grid.getCursorPosition()
    cursor_x, cursor_y = cursor_x - self.xpos + 1, cursor_y - self.ypos + 1
    if cursor_x >= self.buttons[i].xpos and cursor_x < self.buttons[i].xpos + (self.buttons[i].width or 1) and
       cursor_y >= self.buttons[i].ypos and cursor_y < self.buttons[i].ypos + (self.buttons[i].height or 1) then
      self.buttons[i].cursorPresent = true
      return true
    else
      self.buttons[i].cursorPresent = false
      return false
    end
  end
--IF SOLELY THE POSITION SYSTEM IS GRID BASED
  if self.t == UI_MENU and self.window_position_mode == MENU_GRID then
    local texture_scale = grid.getTextureScale()
    cursor_x, cursor_y = grid.getCursorPosition(true)
    cursor_x, cursor_y = (cursor_x - self.xpos)*texture_scale/UI_scale, (cursor_y - self.ypos)*texture_scale/UI_scale
    if cursor_x > self.buttons[i].xpos and cursor_x <= self.buttons[i].xpos + (self.buttons[i].width or 1) and
       cursor_y > self.buttons[i].ypos and cursor_y <= self.buttons[i].ypos + (self.buttons[i].height or 1) then
      self.buttons[i].cursorPresent = true
      return true
    else
      self.buttons[i].cursorPresent = false
      return false
    end
  end
--REGULAR SCREEN POSITION BASED
  cursor_x, cursor_y = cursor_x - self.xpos, cursor_y - self.ypos
  if cursor_x > self.buttons[i].xpos*UI_scale and cursor_x <= (self.buttons[i].xpos + (self.buttons[i].width or 1))*UI_scale and
     cursor_y > self.buttons[i].ypos*UI_scale and cursor_y <= (self.buttons[i].ypos + (self.buttons[i].height or 1))*UI_scale then
    self.buttons[i].cursorPresent = true
    return true
  else
    self.buttons[i].cursorPresent = false
    return false
  end
end

-- Menu draws its own internal canvas
function Menu:draw()
  love.graphics.setCanvas(self.canvas)
  love.graphics.clear()
  if self.texture and self.texture[0] then love.graphics.draw(self.texture[0]) end
  for i=1,(self.buttons and #self.buttons or 0) do
    local b_x, b_y, b_w, b_h, b_tid = self.buttons[i].xpos, self.buttons[i].ypos, self.buttons[i].width, self.buttons[i].height, self.buttons[i].texture_id
    if self.t == UI_TILE then b_x, b_y = (b_x-1)*TEXTURE_BASE_SIZE, (b_y-1)*TEXTURE_BASE_SIZE end
    if not self.texture[b_tid] then b_tid = BUTTON_TEXTURE_NORMAL end
    love.graphics.draw(self.texture[b_tid],b_x,b_y)
    
    if self.buttons[i].text then
      local b_str, b_ft, b_al = self.buttons[i].text, self.buttons[i].font, self.buttons[i].align
      if not b_ft then b_ft = FONT_DEFAULT end
      if not b_al then b_al = "center" end
      local t_w = b_ft:getWidth(b_str)
      local t_h = b_ft:getHeight()
      
      love.graphics.setFont(b_ft)
      if b_al == "center" then
        love.graphics.print(b_str, math.floor(b_x + (b_w-t_w)/2), math.ceil(b_y + (b_h - t_h)/2))
      elseif b_al == "right" then
        love.graphics.print(b_str, b_x+b_w-TEXT_MARGIN-t_w, math.ceil(b_y + (b_h - t_h)/2))
      else
        love.graphics.print(b_str, b_x+TEXT_MARGIN, math.ceil(b_y + (b_h - t_h)/2))
      end
    end
    love.graphics.setFont(FONT_BASE)
  end
  love.graphics.setCanvas()
end

function Menu:close()
  if self.id == MenuId then
    MenuId = MenuId-1
    while not Menus[MenuId] and MenuId > 0 do MenuId = MenuId-1 end
  end
  Menus[self.id] = nil
end

function Menu:resize()
  if self.t == UI_MENU then

    local window_x, window_y = love.graphics.getDimensions()
    local pmode = self.window_position_mode
    if self.texture and self.texture[0] then
      self.width_factor, self.height_factor = self.texture[0]:getDimensions()
      self.width = math.ceil(self.width_factor*UI_scale)
      self.height = math.ceil(self.height_factor*UI_scale)
    else
      if self.width_mode then self.width = math.ceil(self.width_factor*window_x)
      else self.width = math.ceil(self.width_factor*UI_scale) end
      if self.height_mode then self.height = math.ceil(self.height_factor*window_y)
      else self.height = math.ceil(self.height_factor*UI_scale) end
    end

    self.canvas = love.graphics.newCanvas(self.width_factor,self.height_factor)

    if pmode < 9 then -- Number of screen side positioned UI elements
      if pmode == MENU_TL or pmode == MENU_L or pmode == MENU_BL then
        self.xpos = 0
      elseif pmode == MENU_T or pmode == MENU_B then
        self.xpos = math.ceil((window_x-self.width)/2)
      elseif pmode == MENU_TR or pmode == MENU_R or pmode == MENU_BR then
        self.xpos = window_x-self.width
      end
      if pmode == MENU_TL or pmode == MENU_T or pmode == MENU_TR then
        self.ypos = 0
      elseif pmode == MENU_L or pmode == MENU_R then
        self.ypos = math.ceil((window_y-self.height)/2)
      elseif pmode == MENU_BL or pmode == MENU_B or pmode == MENU_BR then
        self.ypos = window_y-self.height
      end
    elseif pmode == MENU_CENTER then
      self.xpos = math.ceil((window_x-self.width)/2)
      self.ypos = math.ceil((window_y-self.height)/2)
    elseif pmode == MENU_GRID then
      self.xpos, self.ypos = grid.getTilePosition(self.grid_x,self.grid_y)
    end

  elseif self.t == UI_DIALOGUE then
  
  elseif self.t == UI_TILE then
  
  else
    --What could there be...?
  end
  self:draw()
end

-- GENERAL FUNCTIONS --

--draws and returns a standard background canvas for the specified dimensions.
function ui_elements.getNewMenuBackground(width,height,tc_path,ts_path,bg_color)
  local t_corner, t_side = nil, nil
  bg_color = bg_color or {0.8,0.8,0.8,1}
  if not tc_path or not ts_path then t_corner, t_side = TEXTURE_MENU_CORNER, TEXTURE_MENU_SIDE
  else t_corner, t_side = love.graphics.newImage(tc_path), love.graphics.newImage(ts_path) end
  local corner_dim, side_dim = t_corner:getPixelWidth(), t_side:getPixelWidth()
  
  if 2*corner_dim > width or 2*corner_dim > height then return nil end

  local h_rep = math.floor((width-2*corner_dim)/side_dim+0.5)
  if h_rep == 0 then h_rep = 1 end
  local h_scale = (width-2*corner_dim)/(h_rep*side_dim)
  local v_rep = math.floor((height-2*corner_dim)/side_dim+0.5)
  if v_rep == 0 then v_rep = 1 end
  local v_scale = (height-2*corner_dim)/(v_rep*side_dim)
  
  local canvas = love.graphics.newCanvas(width,height)
  love.graphics.setCanvas(canvas)
  for i=0,h_rep-1 do
    love.graphics.draw(t_side,corner_dim+i*h_scale*side_dim,0,0,h_scale,1)
  end
  love.graphics.draw(t_corner,0,0,0)
  for i=0,v_rep-1 do
    love.graphics.draw(t_side,width,corner_dim+i*v_scale*side_dim,math.rad(90),v_scale,1)
  end
  love.graphics.draw(t_corner,width,0,math.rad(90))
  for i=1,h_rep do
   love.graphics.draw(t_side,corner_dim+i*h_scale*side_dim,height,math.rad(180),h_scale,1)
  end
  love.graphics.draw(t_corner,width,height,math.rad(180))
  for i=1,v_rep do
    love.graphics.draw(t_side,0,corner_dim+i*v_scale*side_dim,math.rad(270),v_scale,1)
  end
  love.graphics.draw(t_corner,0,height,math.rad(270))
  
  love.graphics.setColor(unpack(bg_color))
  love.graphics.rectangle("fill",corner_dim,corner_dim,width-2*corner_dim,height-2*corner_dim)
  love.graphics.setColor(1,1,1,1)
  love.graphics.setCanvas()
  
  return canvas
end

function ui_elements.create(t)
--[[UI test for non-base types]]
  return Menu:new(t)
end

-- Called in love.resize()
function ui_elements.redraw()
  --[[if UI_scale is automatic then UI_scale = operation on screen size]]
  for i=MenuId,1,-1 do
   if Menus[i] then Menus[i]:resize() end
  end
end

function ui_elements.updateButtonDimensions(m)
  for j=1,#m.buttons do
    if not m.buttons[j].texture_id then m.buttons[j].texture_id = 1 end
    m.buttons[j].previous_texture_id = m.buttons[j].texture_id
    if m.t == UI_TILE then
      if m.texture[m.buttons[j].texture_id] then
        m.buttons[j].width, m.buttons[j].height = m.texture[m.buttons[j].texture_id]:getPixelDimensions()
        m.buttons[j].width, m.buttons[j].height = m.buttons[j].width/TEXTURE_BASE_SIZE, m.buttons[j].height/TEXTURE_BASE_SIZE
      else
        m.buttons[j].width, m.buttons[j].height = m.texture[BUTTON_TEXTURE_NORMAL]:getPixelDimensions()
        m.buttons[j].width, m.buttons[j].height = m.buttons[j].width/TEXTURE_BASE_SIZE, m.buttons[j].height/TEXTURE_BASE_SIZE
      end
    else
      if m.texture[m.buttons[j].texture_id] then
        m.buttons[j].width, m.buttons[j].height = m.texture[m.buttons[j].texture_id]:getPixelDimensions()
      else
        m.buttons[j].width, m.buttons[j].height = m.texture[BUTTON_TEXTURE_NORMAL]:getPixelDimensions()
      end
    end
  end
end

function ui_elements.checkButtonUpdate(m)

  for i=1,#m.buttons do
    if m:isInButton(i) then m.buttons[i].cursorPresent = true
    else m.buttons[i].cursorPresent = false end
  end
  
  for i=1,#m.buttons do
    if m.buttons[i].cursorPresent then
      if not m.buttons[i].pressed then m.buttons[i].texture_id = BUTTON_TEXTURE_HOVERED
      else m.buttons[i].texture_id = BUTTON_TEXTURE_PRESSED end
    else 
      m.buttons[i].pressed = false
      m.buttons[i].texture_id = BUTTON_TEXTURE_NORMAL
    end
  end
  
  for i=1,#m.buttons do
    if m.buttons[i].previous_texture_id ~= m.buttons[i].texture_id then
      ui_elements.updateButtonDimensions(m)
      m:draw()
      return true
    end
  end
  
  return false
end

--Assumes all buttons have the same dimensions as default texture[1] (safe enough...)
function ui_elements.fitButtons(m,spacing,h_deadzone,v_deadzone)
  spacing = spacing or DEFAULT_BUTTON_SPACING
  h_deadzone = h_deadzone or DEFAULT_H_DEADZONE
  v_deadzone = v_deadzone or DEFAULT_V_DEADZONE
  if not m.texture[BUTTON_TEXTURE_NORMAL] then m.texture[BUTTON_TEXTURE_NORMAL] = TEXTURE_REG_BUTTON_NORMAL end
  local b_w,b_h = m.texture[BUTTON_TEXTURE_NORMAL]:getDimensions()
  local width = 2*h_deadzone+b_w
  local height = 2*v_deadzone+#m.buttons*(b_h+spacing)-spacing
  m.texture[0] = ui_elements.getNewMenuBackground(width,height)
  for i=1,#m.buttons do
    m.buttons[i].xpos = v_deadzone
    m.buttons[i].ypos = h_deadzone+(i-1)*(spacing+b_h)
    m.buttons[i].width = b_w
    m.buttons[i].height = b_h
    if not m.buttons[i].texture_id then m.buttons[i].texture_id = BUTTON_TEXTURE_NORMAL end
  end
end

function ui_elements.getMenuId()
  return MenuId
end

function ui_elements.getUIScale()
  return UI_scale
end

function ui_elements.changeUIScale(value, invert)
  if value then
    UI_scale = value
    ui_elements.redraw()
  elseif invert then
    if UI_scale ~= MIN_UI_SCALE then
      UI_scale = math.floor(UI_scale*4)/4 - 0.25
      if UI_scale < MIN_UI_SCALE then UI_scale = MIN_UI_SCALE end
      ui_elements.redraw()
    end
  else
    if UI_scale ~= MAX_UI_SCALE then
      UI_scale = math.floor(UI_scale*4)/4 + 0.25
      if UI_scale > MAX_UI_SCALE then UI_scale = MAX_UI_SCALE end
      ui_elements.redraw()
    end
  end
end

function ui_elements.changeUIScaleMode()
  UI_automatic_scaling = not UI_automatic_scaling
  if UI_automatic_scaling then
    local window_w, window_h = love.graphics.getDimensions()
    ui_elements.changeUIScale(math.min(window_w*UI_autoscale_factor_x, window_h*UI_autoscale_factor_y))
  end
end

function ui_elements.getUIScaleMode()
  return UI_automatic_scaling, UI_autoscale_factor_x, UI_autoscale_factor_y
end


--------------------------------------------------------------------------------------------------------------------------------
function ui_elements.escapeMenu()
  local m = ui_elements.create(UI_MENU)
  m.buttons = {{onClick = function(m,b) love.event.quit("restart") end, text = "Main Menu"},{onClick = function(m,b) m:close() ui_elements.levelSelect() end, text = "Level Select"},{onClick = function(m,b) m:close() ui_elements.optionsMenu() end, text = "Options"},{onClick = function(m,b) m:close() end, text = "Return to Game"}}
  m.texture[1] = TEXTURE_REG_BUTTON_NORMAL
  ui_elements.fitButtons(m)

  m.window_position_mode = MENU_CENTER
  m.isBlocking = true
  m.texture[2] = TEXTURE_REG_BUTTON_PRESSED

  m:resize()
end

function ui_elements.levelSelect()
  local m = ui_elements.create(UI_MENU)
  m.texture[0] = love.graphics.newImage("Textures/levelselect.png")
  m.texture[1] = TEXTURE_REG_BUTTON_NORMAL
  m.texture[2] = TEXTURE_REG_BUTTON_PRESSED
  m.texture[5] = TEXTURE_REG_BUTTON_INVIS --INVISIBLE BUTTON 'text area'
  m.buttons = {{xpos = 100, ypos = 24, texture_id = 5,text = "Level Select"},{xpos = 100, ypos = 378, texture_id = 1, text = "Back", onClick = function(m,b) m:close() ui_elements.escapeMenu() end}}
  m.update = function(m)
    m.buttons[1].texture_id = 5
    if not m:isInButton(2) then m.buttons[2].texture_id = BUTTON_TEXTURE_NORMAL
    elseif m.buttons[2].texture_id ~= BUTTON_TEXTURE_PRESSED then m.buttons[2].texture_id = BUTTON_TEXTURE_HOVERED end
    
    if m.buttons[2].previous_texture_id ~= m.buttons[2].texture_id then
      ui_elements.updateButtonDimensions(m)
      m:draw()
      return true
    end
  end
  function m:close()
    m.submenu:close()
    if self.id == MenuId then
      MenuId = MenuId-1
      while not Menus[MenuId] and MenuId > 0 do MenuId = MenuId-1 end
    end
    Menus[self.id] = nil
  end
  
  local Files = love.filesystem.getDirectoryItems("Levels/")
  local Levels = {}
  for i=1,#Files do
    if string.find(Files[i],"level_") == 1 then
      local ext_pos, ext_end = string.find(Files[i],".lua")
      local name_pos = string.find(Files[i],"_",7)
      local lvl = {}
      
      if name_pos then
        name_pos = name_pos+1
        lvl.name = string.sub(Files[i],name_pos,ext_pos-1)
      end

      if ext_end == string.len(Files[i]) then
        local level_id = string.sub(Files[i],7,name_pos and (name_pos-2) or (ext_pos-1))
        level_id = tonumber(level_id)
        if level_id then
          lvl.id = level_id
          table.insert(Levels,lvl)
        end
      end
    end
  end
  table.sort(Levels, function(lvl_1,lvl_2) return lvl_1.id < lvl_2.id end )

  m.submenu = ui_elements.create(UI_MENU)
  m.submenu.parentmenu = m
  m.submenu.width_factor, m.submenu.height_factor = 268, 292
  m.submenu.isBlocking = false
  m.submenu.scrollOffset = 0
  m.submenu.texture[1] = m.texture[1]
  m.submenu.texture[2] = m.texture[2]
  m.submenu.buttons = {}
  
  local b_x, b_y = 4,4
  for i=1,#Levels do
    m.submenu.buttons[i] = {
                              xpos = b_x,
                              ypos = b_y,
                              lvlid = Levels[i].id,
                              texture_id = 1,
                              text = Levels[i].name or "Level "..tostring(Levels[i].id),
                              onClick = function(m,b) load_level(b.lvlid) m:close() m.parentmenu:close() end
                            }
    if b_x == 4 then
      b_x = 136
    else
      b_x = 4
      b_y = b_y + 36
    end
  end
  m.submenu.onScroll = function(m,x,y)
    y = y*4
    if (y > 0 and m.scrollOffset-y < 0) then y = m.scrollOffset end
    if (y < 0 and m.scrollOffset-y > 36*math.ceil(#m.buttons/2)-288) then y = m.scrollOffset+288-36*math.ceil(#m.buttons/2) end
    if y ~= 0 then
      m.scrollOffset = m.scrollOffset - y
      for i=1,#m.buttons do
        m.buttons[i].ypos = m.buttons[i].ypos + y
      end
      m:draw()
    end
  end

  ui_elements.updateButtonDimensions(m)
  ui_elements.updateButtonDimensions(m.submenu)
  m:resize()
  m.submenu:resize()
end

function ui_elements.optionsMenu()
  local m = ui_elements.create(UI_MENU)
  local BUTTON_OPTIONS_TEXT, BUTTON_OPTIONS_WINDOWTEXT, BUTTON_OPTIONS_SCREENMODE, BUTTON_OPTIONS_SCALETEXT, BUTTON_OPTIONS_SCALEMODE, BUTTON_OPTIONS_SCALE , BUTTONS_OPTIONS_RETURN, BUTTON_OPTIONS_SCALE_MINUS, BUTTON_OPTIONS_SCALE_PLUS= enum(9)
  m.buttons = {
    {text = "UI Options", texture_id = 5, noUpdate = true},
    {text = "Window Mode", align = "left", texture_id = 5, noUpdate = true},
    {text = "Windowed"},
    {text = "UI Scale Options", align = "left", texture_id = 5, noUpdate = true},
    {text = "Auto", compl2SQButton = true, onClick = function(m,b) ui_elements.changeUIScaleMode() end},
    {text = "Scale:", texture_id = 5, noUpdate = true},
    {text = "Back", onClick = function(m,b) m:close() ui_elements.escapeMenu() end}
  }
  m.texture[1] = TEXTURE_REG_BUTTON_NORMAL
  m.texture[2] = TEXTURE_REG_BUTTON_PRESSED
  m.texture[5] = TEXTURE_REG_BUTTON_INVIS
  m.texture[6] = TEXTURE_SQ_BUTTON_NORMAL
  m.texture[7] = TEXTURE_SQ_BUTTON_PRESSED
  m.texture[9] = TEXTURE_SQ_BUTTON_GREYED
  m.texture[11] = TEXTURE_COMPL2SQ_BUTTON_NORMAL
  m.texture[12] = TEXTURE_COMPL2SQ_BUTTON_PRESSED
  ui_elements.fitButtons(m)
  table.insert(m.buttons,{
                            xpos = m.buttons[BUTTON_OPTIONS_SCALEMODE].xpos+62,
                            ypos = m.buttons[BUTTON_OPTIONS_SCALEMODE].ypos,
                            SQButton = true,
                            text = "-",
                            texture_id = 9,
                            noUpdate = true,
                            onClick = function(m,b) if not UI_automatic_scaling then ui_elements.changeUIScale(nil,true) end end
                          })
  table.insert(m.buttons,{
                            xpos = m.buttons[BUTTON_OPTIONS_SCALEMODE].xpos+96,
                            ypos = m.buttons[BUTTON_OPTIONS_SCALEMODE].ypos,
                            SQButton = true, text = "+",
                            texture_id = 9,
                            noUpdate = true,
                            onClick = function(m,b) if not UI_automatic_scaling then ui_elements.changeUIScale() end end
                          })
  ui_elements.updateButtonDimensions(m)
  m.window_position_mode = MENU_CENTER
  m.isBlocking = true
  local _,_,flags = love.window.getMode()
  if flags.fullscreen then
    m.buttons[BUTTON_OPTIONS_SCREENMODE].mode = true
    m.buttons[BUTTON_OPTIONS_SCREENMODE].text = "Fullscreen"
  end
  m.buttons[BUTTON_OPTIONS_SCREENMODE].onClick = function(m,b)
    local menu_bg = false
    if m.texture[0]:typeOf("Canvas") then
      menu_bg = m.texture[0]:newImageData()
    end
    if b.mode then
      b.mode = false
      b.text = "Windowed"
      love.window.setMode(DEFAULT_SCREEN_WIDTH,DEFAULT_SCREEN_HEIGHT,{resizable = true})
    else
      b.mode = true
      b.text = "Fullscreen"
      love.window.setMode(0,0,{fullscreen = true})
    end
    if menu_bg then m.texture[0] = love.graphics.newImage(menu_bg) end
    love.resize()
    UpdateBackgroundFG = true
    for i=1,#UpdateObjectType do
      UpdateObjectType[i] = true
    end
  end

  m.update = function(m)
    m.buttons[BUTTON_OPTIONS_SCALEMODE].text = (UI_automatic_scaling and "Auto" or "Manual")
    m.buttons[BUTTON_OPTIONS_SCALE].text = "Scale: "..string.sub(tostring(UI_scale),1,5)
    if UI_automatic_scaling then
      m.buttons[BUTTON_OPTIONS_SCALE_MINUS].texture_id = 9
      m.buttons[BUTTON_OPTIONS_SCALE_PLUS].texture_id = 9
      m.buttons[BUTTON_OPTIONS_SCALE_MINUS].noUpdate = true
      m.buttons[BUTTON_OPTIONS_SCALE_PLUS].noUpdate = true
    else
      m.buttons[BUTTON_OPTIONS_SCALE_MINUS].noUpdate = false
      m.buttons[BUTTON_OPTIONS_SCALE_PLUS].noUpdate = false
    end
    for i=1,#m.buttons do
      if not m.buttons[i].noUpdate then
        local button_texture_offset = m.buttons[i].SQButton and 5 or m.buttons[i].compl2SQButton and 10 or 0
        if not m.buttons[i].cursorPresent then
          m.buttons[i].texture_id = BUTTON_TEXTURE_NORMAL + button_texture_offset
          m.pressed = false
        elseif not m.buttons[i].pressed then
          m.buttons[i].texture_id = BUTTON_TEXTURE_NORMAL + button_texture_offset
        else
          m.buttons[i].texture_id = BUTTON_TEXTURE_PRESSED + button_texture_offset
        end
      end
    end
    for i=1,#m.buttons do
      if m.buttons[i].previous_texture_id ~= m.buttons[i].texture_id or m.previous_UI_scale ~= UI_scale then
        ui_elements.updateButtonDimensions(m)
        m.previous_UI_scale = UI_scale
        m:draw()
        return true
      end
    end
  end
  m:resize()
end

return ui_elements