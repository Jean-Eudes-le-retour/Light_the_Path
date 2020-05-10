local grid = require("grid")

local ui_elements = {}

local MenuId = 1 --DEFAULT HAS MAIN_MENU ACTIVE
local UI_TYPES = {"menu","dialogue","tile"}
local NUM_PRESETS = 1
local UI_scale = 1

--[[
________________________________________________
TO PREPARE A MENU:
________________________________________________
local m = ui_elements.create(UI_MENU)
m.texture[0] = ui_elements.getNewMenuBackground(width,height) -- (or a custom texture)
local buttons = { {xpos = 5, ypos = 5, texture_id = 1, onClick = <a function of m and b>}, ... }
m.buttons = buttons
m.texture[1] = love.graphics.newImage("path_to_regular_button")

--OPTIONAL ARGUMENTS
m.window_position_mode = MENU_CENTER
m.isBlocking = true
m.texture[2] = love.graphics.newImage("path_to_pressed_button") -- for both if unspecified, will show texture[1]
m.texture[3] = love.graphics.newImafe("path_to_hovered_button")
m.update = <a function of m>
--Note that the button onClick function should only be called via love.mouse release callbacks.
--This function can serve to give special behaviour to buttons or update the menu itself
--For example, there are no "mouse is no longer on button" callbacks so if required to know, this must be checked here
--It's also worth noting that no other functions but Menu:resize() updates the menu graphics by default, so it is recommended that this function be defined
--Recommend using ui_elements.checkButtonUpdate by default for those purposes

-- IMPORTANT FINALIZATION --
m.updateButtonDimensions(m) --So that the menu is initialized to correct values for default update function (depends on your update function)
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
  buttons = {}, -- contains button {xpos,ypos,texture_id(determines width/height, NORMAL,PRESSED,HOVERED),previous_texture_id,text,text_size,align,font,onClick(m,b)}
  texture = {}, -- contains all textures including button textures; 0 is the menu itself
  imagedata = false, -- if defined, test transparency
  
  update = function(m)
    ui_elements.checkButtonUpdate(m) -- Only if the menu is handled like any other, i.e. buttons have a normal and pressed state dependent on mouse position [optionally hover state]
  end,

}

local DEFAULT_UI = {DEFAULT_MENU,DEFAULT_DIALOGUE,DEFAULT_TILE}
Menus = {MAIN_MENU} -- Global Menus table



------------------------------------------------------------------------------------------------------------------------------------------------
-- On screen resize : menu:resize(), menu:draw() for all (use ui_elements.redraw()?)

function Menu:new(t) --do not forget to index to Menus (and check if the Id needs changing)
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
    if cursor_x >= self.buttons[i].xpos and cursor_x < self.buttons[i].xpos + (self.buttons[i].width or 0) and
       cursor_y >= self.buttons[i].ypos and cursor_y < self.buttons[i].ypos + (self.buttons[i].height or 0) then
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
    if cursor_x > self.buttons[i].xpos and cursor_x <= self.buttons[i].xpos + (self.buttons[i].width or 0) and
       cursor_y > self.buttons[i].ypos and cursor_y <= self.buttons[i].ypos + (self.buttons[i].height or 0) then
      return true
    else
      return false
    end
  end
--REGULAR SCREEN POSITION BASED
  cursor_x, cursor_y = cursor_x - self.xpos, cursor_y - self.ypos
  if cursor_x > self.buttons[i].xpos and cursor_x <= self.buttons[i].xpos + (self.buttons[i].width or 0) and
     cursor_y > self.buttons[i].ypos and cursor_y <= self.buttons[i].ypos + (self.buttons[i].height or 0) then
    return true
  else 
    return false
  end
end

-- Menu draws its own internal canvas
function Menu:draw()
  love.graphics.setCanvas(self.canvas)
  love.graphics.clear()
  if texture and texture[0] then love.graphics.draw(texture[0]) end
  for i=1,(self.buttons and #self.buttons or 0) do
    local b_x, b_y, b_w, b_h, b_tid = self.buttons[i].xpos, self.buttons[i].ypos, self.buttons[i].width, self.buttons[i].height, self.buttons[i].texture_id
    if self.t == UI_TILE then b_x, b_y = (b_x-1)*TEXTURE_BASE_SIZE, (b_y-1)*TEXTURE_BASE_SIZE end
    if not self.texture[t_id] then t_id = 1 end
    love.graphics.draw(self.texture[t_id],b_x,b_y)
    
    if self.buttons[i].text then
      local b_str, b_ft, b_ts, b_al = self.buttons[i].text, self.buttons[i].font, self.text_size, self.buttons[i].align
      if not b_ft then b_ft = "Retro Gaming.ttf" end
      if not b_ts then b_ts = 12 end
      if not b_al then b_al = "center" end
      b_ft = "Textures/Fonts/"..b_ft
      love.graphics.setNewFont(b_ft,b_ts)
      love.graphics.printf(b_str, b_x + TEXT_MARGIN, math.ceil(b_y + (b_h - b_ts)/2), b_w - 2*TEXT_MARGIN, b_al)
    end
    love.graphics.setNewFont()
  end
  love.graphics.setCanvas()
end

function Menu:close()
  if self.id == MenuId then MenuId = MenuId-1 end
  Menus[self.id] = nil
end

function Menu:resize()
  if self.t == UI_MENU then

    local window_x, window_y = love.getDimensions()
    local pmode = self.window_position_mode
    if self.texture and self.texture[0] then
      self.width_factor, self.height_factor = self.texture:getDimensions()
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
function ui_elements.getNewMenuBackground(width,height)

end

function ui_elements.create(t)
  return Menu:new(t)
end

-- Called in love.resize()
function ui_elements.redraw()
  for i=MenuId,1,-1 do
   if Menus[i] then Menus[i]:resize() end
  end
end

function ui_elements.updateButtonDimensions(m)
  for j=1,#m.buttons do
    m.buttons[j].previous_texture_id = m.buttons[j].texture_id
    if m.t == UI_TILE then
      if m.texture[m.buttons[j].texture_id] then
        m.buttons[j].width, m.buttons[j].height = m.texture[m.buttons[j].texture_id]:getPixelDimensions()
        m.buttons[j].width, m.buttons[j].height = m.buttons[j].width/TEXTURE_BASE_SIZE, m.buttons[j].height/TEXTURE_BASE_SIZE
      else
        m.buttons[j].width, m.buttons[j].height = m.texture[1]:getPixelDimensions()
        m.buttons[j].width, m.buttons[j].height = m.buttons[j].width/TEXTURE_BASE_SIZE, m.buttons[j].height/TEXTURE_BASE_SIZE
      end
    else
      if m.texture[m.buttons[j].texture_id] then
        m.buttons[j].width, m.buttons[j].height = m.texture[m.buttons[j].texture_id]:getPixelDimensions()
      else
        m.buttons[j].width, m.buttons[j].height = m.texture[1]:getPixelDimensions()
      end
    end
  end
end

function ui_elements.checkButtonUpdate(m)
  for i=1,#m.buttons do
    if texture[3] and m:isInButton(i) and m.buttons[i].texture_id ~= 2 then m.buttons[i].texture_id = 3
    else m.buttons[i].texture_id = 1 end
  end
  for i=1,#m.buttons do
    if m:buttons[i].previous_texture_id ~= m.buttons[i].texture_id then
      ui_elements.updateButtonDimensions(m)
      m:draw()
      return true
    end
  end
  return false
end

function ui_elements.getMenuId()
  return MenuId
end

function ui_elements.getUIscale()
  return UI_scale
end

return ui_elements