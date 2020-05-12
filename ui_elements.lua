local grid = require("grid")

local ui_elements = {}

local MenuId = 1 --DEFAULT HAS MAIN_MENU ACTIVE
local UI_TYPES = {"menu","dialogue","tile"}
local NUM_PRESETS = 1
--UI_scale_mode boolean for automatic scaling?
local UI_scale = 2
local DEFAULT_MENU_CORNER = love.graphics.newImage("Textures/menu_corner.png")
local DEFAULT_MENU_SIDE = love.graphics.newImage("Textures/menu_side.png")
local DEFAULT_BUTTON_SPACING = 6
local DEFAULT_H_DEADZONE = 32
local DEFAULT_V_DEADZONE = 32

--[[
________________________________________________
TO PREPARE A MENU:
________________________________________________
local m = ui_elements.create(UI_MENU)
m.texture[0] = ui_elements.getNewMenuBackground(width,height) -- (or a custom texture)
local buttons = { {xpos = 5, ypos = 5, texture_id = BUTTON_TEXTURE_NORMAL (1), onClick = <a function of m and b>, text = "Return to Game",(font = FONT_DEFAULT),(align = "center")}, ... }
m.buttons = buttons
m.texture[1] = love.graphics.newImage("path_to_regular_button")

--OPTIONAL ARGUMENTS
ui_elements.fitButtons(m) -- very handy function to automatically dispose buttons (also assigns regular button texture if none exists)
m.window_position_mode = MENU_CENTER
m.isBlocking = true
m.texture[2] = love.graphics.newImage("path_to_pressed_button") -- for both if unspecified, will show texture[1]
m.texture[3] = love.graphics.newImage("path_to_hovered_button")
m.update = <a function of m>
--Note that the button onClick function should only be called via love.mouse release callbacks.
--This function can serve to give special behaviour to buttons or update the menu itself
--Note that the onClick function will only ever be called ON MOUSE RELEASE if TEXTURE_ID of the button is 2 (BUTTON_TEXTURE_PRESSED)!
--For example, there are no "mouse is no longer on button" callbacks so if required to know, this must be checked here
--It's also worth noting that no other functions but Menu:resize() updates the menu graphics by default, so it is recommended that this function be defined
--Recommend using ui_elements.checkButtonUpdate by default for those purposes

-- IMPORTANT FINALIZATION --
ui_elements.updateButtonDimensions(m) --So that the menu is initialized to correct values for default update function (depends on your update function)
m:resize()  --Includes m:draw()
________________________________________________
TO PREPARE A DIALOGUE:
________________________________________________

]]



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
  height_mode = false,

  isBlocking = true,
  window_position_mode = MENU_CENTER,
  buttons = {}, -- contains button {xpos,ypos,texture_id(determines width/height, NORMAL,PRESSED,HOVERED),previous_texture_id,text,align,font,onClick(m,b)}
  texture = {}, -- contains all textures including button textures; 0 is the menu itself
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
  m.texture = DEFAULT_UI[t].texture
  m.canvas = DEFAULT_UI[t].canvas
  m.update = DEFAULT_UI[t].update
  
  while MenuId > 0 and not Menus[MenuId] do MenuId = MenuId-1 end
  MenuId = MenuId+1
  m.id = MenuId
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
      return true
    else
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
      return true
    else
      return false
    end
  end
--REGULAR SCREEN POSITION BASED
  cursor_x, cursor_y = cursor_x - self.xpos, cursor_y - self.ypos
  if cursor_x > self.buttons[i].xpos*UI_scale and cursor_x <= (self.buttons[i].xpos + (self.buttons[i].width or 1))*UI_scale and
     cursor_y > self.buttons[i].ypos*UI_scale and cursor_y <= (self.buttons[i].ypos + (self.buttons[i].height or 1))*UI_scale then
    return true
  else 
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
  if not tc_path or not ts_path then t_corner, t_side = DEFAULT_MENU_CORNER, DEFAULT_MENU_SIDE
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
    if not m:isInButton(i) then m.buttons[i].texture_id = BUTTON_TEXTURE_NORMAL
    elseif m.buttons[i].texture_id ~= BUTTON_TEXTURE_PRESSED then m.buttons[i].texture_id = BUTTON_TEXTURE_HOVERED end
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

function ui_elements.fitButtons(m,spacing,h_deadzone,v_deadzone)
  spacing = spacing or DEFAULT_BUTTON_SPACING
  h_deadzone = h_deadzone or DEFAULT_H_DEADZONE
  v_deadzone = v_deadzone or DEFAULT_V_DEADZONE
  if not m.texture[1] then m.texture[1] = love.graphics.newImage("Textures/default_button_1.png") end
  local b_w,b_h = m.texture[1]:getDimensions()
  local width = 2*h_deadzone+b_w
  local height = 2*v_deadzone+#m.buttons*(b_h+spacing)-spacing
  m.texture[0] = ui_elements.getNewMenuBackground(width,height)
  for i=1,#m.buttons do
    m.buttons[i].xpos = v_deadzone
    m.buttons[i].ypos = h_deadzone+(i-1)*(spacing+b_h)
  end
end

function ui_elements.getMenuId()
  return MenuId
end

function ui_elements.getUIscale()
  return UI_scale
end

return ui_elements