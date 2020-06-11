local grid = require("grid")
local audio = require("audio")
local objects = require("objects")
local bit = require("bit")
local bnot, band, bor, bxor, rshift, lshift = bit.bnot, bit.band, bit.bor, bit.bxor, bit.rshift, bit.lshift

local ui_elements = {}

----------- VARIABLES -----------
local MenuId = 0
local uniqueId = 0
local UI_automatic_scaling = true
local MenuCallStack = {}
local sel_x, sel_y = false, false
local UI_scale = 1.5

----------- CONSTANTS -----------
local UI_TYPES = {"menu","dialog","tile"}
local UI_AUTOSCALE_X = 1/384 --UI_scale 3*128*UI_scale = ww
local UI_AUTOSCALE_Y = 1/512 --16*32*UI_scale = wh
local MIN_UI_SCALE = 0.5 --Only applies for manual mode
local MAX_UI_SCALE = 5 --Only applies for manual mode
local DEFAULT_BUTTON_SPACING = 6
local DEFAULT_H_DEADZONE = 32
local DEFAULT_V_DEADZONE = 32
local DEFAULT_DIALOG_H_DEADZONE = 8
local DEFAULT_DIALOG_V_DEADZONE = 8
local DEFAULT_DIALOG_V_SPAN = 256
local DEFAULT_ANIM_FREQ = 2
local DEFAULT_TEXT_RATE = 30


if UI_automatic_scaling then
  local ww, wh = love.graphics.getDimensions()
  UI_scale = math.min(ww*UI_AUTOSCALE_X, wh*UI_AUTOSCALE_Y)
end

----------- RESSOURCES -----------
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
local TEXTURE_MINISQ_BUTTON_NORMAL = love.graphics.newImage("Textures/minisq_button_1.png")
local TEXTURE_MINISQ_BUTTON_PRESSED = love.graphics.newImage("Textures/minisq_button_2.png")
local TEXTURE_MINISQ_BUTTON_GREYED = love.graphics.newImage("Textures/minisq_button_4.png")
local TEXTURE_MINISQ_PRESS_NORMAL = love.graphics.newImage("Textures/minisq_press_1.png")
local TEXTURE_MINISQ_PRESS_PRESSED = love.graphics.newImage("Textures/minisq_press_2.png")
local TEXTURE_MINISQ_PRESS_GREYED = love.graphics.newImage("Textures/minisq_press_4.png")
local TEXTURE_ARROWR_NORMAL = love.graphics.newImage("Textures/arrowR_1.png")
local TEXTURE_ARROWR_PRESSED = love.graphics.newImage("Textures/arrowR_2.png")
local TEXTURE_ARROWR_GREYED = love.graphics.newImage("Textures/arrowR_4.png")
local TEXTURE_ARROWL_NORMAL = love.graphics.newImage("Textures/arrowL_1.png")
local TEXTURE_ARROWL_PRESSED = love.graphics.newImage("Textures/arrowL_2.png")
local TEXTURE_ARROWL_GREYED = love.graphics.newImage("Textures/arrowL_4.png")
local TEXTURE_SLIDER_NORMAL = love.graphics.newImage("Textures/slider_1.png")
local TEXTURE_SLIDER_PRESSED = love.graphics.newImage("Textures/slider_2.png")
local TEXTURE_SLIDER_GREYED = love.graphics.newImage("Textures/slider_4.png")

local TEXTURE_THUMB_MOVE = love.graphics.newImage("Textures/thumbnail_move.png")
local TEXTURE_THUMB_SELECT = love.graphics.newImage("Textures/thumbnail_select.png")
local TEXTURE_THUMB_DELETE = love.graphics.newImage("Textures/thumbnail_delete.png")
local TEXTURE_THUMB_PLACE = love.graphics.newImage("Textures/thumbnail_place.png")
local TEXTURE_THUMB_CHECK = love.graphics.newImage("Textures/thumbnail_check.png")
local TEXTURE_THUMB_LOCK = love.graphics.newImage("Textures/thumbnail_lock.png")
local TEXTURE_THUMB_NOLOCK = love.graphics.newImage("Textures/thumbnail_locknot.png")
local TEXTURE_THUMB_SOUND = love.graphics.newImage("Textures/thumbnail_sound.png")
local TEXTURE_THUMB_NOSOUND = love.graphics.newImage("Textures/thumbnail_soundnot.png")
local TEXTURE_THUMB_GLASS = love.graphics.newImage("Textures/thumbnail_glass.png")
local TEXTURE_THUMB_NOGLASS = love.graphics.newImage("Textures/thumbnail_glassnot.png")
local TEXTURE_THUMB_TRASH = love.graphics.newImage("Textures/thumbnail_trash.png")
local TEXTURE_THUMB_WALL = love.graphics.newImage("Textures/thumbnail_wall.png")
local TEXTURE_THUMB_SOURCE = love.graphics.newImage("Textures/thumbnail_source.png")
local TEXTURE_THUMB_RECEIVER = love.graphics.newImage("Textures/thumbnail_receiver.png")
local TEXTURE_THUMB_MIRROR = love.graphics.newImage("Textures/thumbnail_mirror.png")
local TEXTURE_THUMB_PWHEEL = love.graphics.newImage("Textures/thumbnail_pwheel.png")
local TEXTURE_THUMB_LOGIC = love.graphics.newImage("Textures/thumbnail_logic.png")
local TEXTURE_THUMB_DELAY = love.graphics.newImage("Textures/thumbnail_delay.png")
local TEXTURE_THUMB = {
  TEXTURE_THUMB_WALL,
  TEXTURE_THUMB_GLASS,
  TEXTURE_THUMB_SOURCE,
  TEXTURE_THUMB_RECEIVER,
  TEXTURE_THUMB_MIRROR,
  TEXTURE_THUMB_PWHEEL,
  TEXTURE_THUMB_LOGIC,
  TEXTURE_THUMB_DELAY
}

local TEXTURE_DIALOG_SIDE = love.graphics.newImage("Textures/dialog_side.png")
local TEXTURE_DIALOG_NAMEBAR = love.graphics.newImage("Textures/dialog_namebar.png")
local TEXTURE_DIALOG_NAMEBAR_EDGE = love.graphics.newImage("Textures/dialog_namebar_edge.png")
local TEXTURE_SLIDERBAR = love.graphics.newImage("Textures/sliderbar.png")
local TEXTURE_SELECTION_BOX = love.graphics.newImage("Textures/selection.png")


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
--  Only if the menu is handled like any other, i.e. buttons have a normal and pressed state dependent on mouse position [optionally hover state]
    ui_elements.checkButtonUpdate(m) 
  end,

}

local DEFAULT_DIALOG = {
--TYPE
  t = UI_DIALOG,
  
--NO TOUCHING THESE
  xpos = 0,
  ypos = 0,
  width_factor = 0,
  height_factor = 0,
  text_width = 0,
  text_height = 0,
  game_time_start = 0,
  current_frame = false,
  canvas = false,
  textcanvas = false,
  imagedata = false,
  page = 1,
  scroll = 0,
  
--CAN BE CHANGED THROUGH ASSIGNMENTS
  charname = {},
  text = {}, --table of different "pages", each page can be love2d coloredtext format
  text_rate = {},
  animation = {}, -- contains table of images, animation[x][0] is {freq,repetitions,fade} if defined
  sfx = {}, -- sfx[x][0] is mode
  window_position_mode = MENU_BL,
  isBlocking = true,
  noSkip = false,
  
  update = function(m)
    ui_elements.updateDialog(m)
  end
}

local DEFAULT_TILE = {
--TYPE
  t = UI_TILE,
  
--NO TOUCHING THESE
  xpos = 0,
  ypos = 0,
  canvas = false,
  
--CAN BE CHANGED THROUGH ASSIGNMENTS
  isBlocking = false,
  
  update = function(m)
    ui_elements.checkButtonUpdate(m)
  end
}

local DEFAULT_UI = {DEFAULT_MENU,DEFAULT_DIALOG,DEFAULT_TILE}
--Menus = {MAIN_MENU} -- Global Menus table
Menus = {}


--------------------------------------------------------------------------------------------------------------------------
-- On screen resize : menu:resize(), menu:draw() for all (use ui_elements.redraw()?)

function Menu:new(t,id)
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
  if m.t == UI_DIALOG then
    m.game_time_start = game_time
    m.page = DEFAULT_UI[t].page
    m.scroll = DEFAULT_UI[t].scroll
    m.animation = {}
    m.text_rate = {}
    m.noSkip = DEFAULT_UI[t].noSkip
  end
  
  if id then
    m.id = id
    Menus[id] = m
  else
    while MenuId > 0 and not Menus[MenuId] do MenuId = MenuId-1 end
    MenuId = MenuId+1
    m.id = MenuId
    Menus[MenuId] = m
  end
  m.uniqueId = uniqueId
  uniqueId = uniqueId+1

  return m
end

-- For some UI_MENU ui elements, contain imagedata -> some pixels are transparent and must be taken into account in isInMenu
function Menu:isInMenu()
  local cursor_x, cursor_y = 0,0
--IF THE POSITION AND SIZE SYSTEM IS GRID-BASED
  if self.t == UI_TILE then
    cursor_x, cursor_y = grid.getCursorPosition(true)
    cursor_x, cursor_y = cursor_x-self.xpos+1, cursor_y-self.ypos+1
    if cursor_x > 0 and cursor_x < self.width and
       cursor_y > 0 and cursor_y < self.height then
      return true
    end
    return false
  end
--IF SOLELY THE POSITION SYSTEM IS GRID BASED
  if self.t == UI_MENU and self.window_position_mode == MENU_GRID then
    cursor_x, cursor_y = grid.getCursorPosition(true)
    cursor_x, cursor_y = cursor_x-self.xpos, cursor_y-self.ypos
    local texture_scale = grid.getTextureScale()
    if cursor_x >= 0 and cursor_x < self.width*UI_scale/texture_scale and
       cursor_y >= 0 and cursor_y < self.height*UI_scale/texture_scale then
      return true
    end
    return false
  end
--ELSE FOR WINDOW POSITIONING SYSTEM
  cursor_x, cursor_y = love.mouse.getPosition()
  cursor_x, cursor_y = cursor_x-self.xpos, cursor_y-self.ypos
  if cursor_x > 0 and cursor_x <= self.width and
     cursor_y > 0 and cursor_y <= self.height then
    if self.imagedata then
      local _,_,_,alpha = self.imagedata:getPixel(math.floor(cursor_x/UI_scale),math.floor(cursor_y/UI_scale))
      if alpha ~= 0 then return true end
    else
      return true
    end
  end
  return false
end

function Menu:isInButton(i)
  if not self.buttons[i] then return false end
  local cursor_x, cursor_y = love.mouse.getPosition()
--IF GRID-BASED
  if self.t == UI_TILE then
    cursor_x, cursor_y = grid.getCursorPosition(true)
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
  if self.t == UI_MENU then
    if self.texture[0] then love.graphics.draw(self.texture[0]) end
    for i=1,(self.buttons and #self.buttons or 0) do
      local b_x, b_y, b_w, b_h, b_tid = self.buttons[i].xpos, self.buttons[i].ypos, self.buttons[i].width, self.buttons[i].height, self.buttons[i].texture_id
      if self.t == UI_TILE then b_x, b_y = (b_x-1)*TEXTURE_BASE_SIZE, (b_y-1)*TEXTURE_BASE_SIZE end
      if self.texture[b_tid] then
        love.graphics.draw(self.texture[b_tid],b_x,b_y)
      end
      
      if self.buttons[i].text then
        local b_str, b_ft, b_al, b_c = self.buttons[i].text, self.buttons[i].font, self.buttons[i].align, self.buttons[i].textcolor
        if not b_ft then b_ft = FONT_DEFAULT end
        if not b_al then b_al = "center" end
        if b_c then
          if type(b_c) == "table" then
            love.graphics.setColor(unpack(b_c))
          else
            love.graphics.setColor(band(b_c,1), band(b_c,2)==1 and 1 or 0, band(b_c,4)==1 and 1 or 0)
          end
        end
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
        love.graphics.setColor(1,1,1)
      end
      love.graphics.setFont(FONT_BASE)
    end
  elseif self.t == UI_DIALOG then
    love.graphics.setFont(FONT_DEFAULT)
    if self.current_frame then
      local framewidth, frameheight = self.current_frame:getDimensions()
      love.graphics.draw(self.current_frame, self.width_factor, math.ceil(self.height_factor/2), nil, nil, nil, framewidth, frameheight)
    end
    if self.texture[0] then love.graphics.draw(self.texture[0]) end
    if self.charname and self.charname[self.page] then
      local nl, nbl, nb_y = FONT_DEFAULT:getWidth(self.charname[self.page]), self.namebar:getWidth(), math.ceil(self.height_factor/2)-self.namebar:getHeight()
      love.graphics.draw(self.namebar_edge,nl+2*DEFAULT_DIALOG_H_DEADZONE,nb_y)
      for i=nl+2*DEFAULT_DIALOG_H_DEADZONE-nbl,-nbl,-nbl do
        love.graphics.draw(self.namebar, i, nb_y)
      end
      love.graphics.print(self.charname[self.page], DEFAULT_DIALOG_H_DEADZONE, math.ceil(self.height_factor/2)-12)
    end
    if self.textcanvas then love.graphics.draw(self.textcanvas, DEFAULT_DIALOG_H_DEADZONE, math.ceil(self.height_factor/2)+DEFAULT_DIALOG_V_DEADZONE) end
    love.graphics.setFont(FONT_BASE)
  elseif self.t == UI_TILE then
    if self.texture[0] then love.graphics.draw(self.texture[0]) end
  end
  love.graphics.setCanvas()
end

function Menu:close(noInvoke)
  if self.id == MenuId then
    MenuId = MenuId-1
    while not Menus[MenuId] and MenuId > 0 do MenuId = MenuId-1 end
    if MenuId < 0 then MenuId = 0 end
  end

  Menus[self.id] = nil
  if not noInvoke and #MenuCallStack ~= 0 then
    MenuCallStack[#MenuCallStack](true)
    MenuCallStack[#MenuCallStack] = nil
  end
end

function Menu:resize()
  if self.t == UI_MENU then
    local window_x, window_y = love.graphics.getDimensions()
    local pmode = self.window_position_mode
    if self.texture[0] then
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
        self.xpos = window_x-self.width+1
      end
      if pmode == MENU_TL or pmode == MENU_T or pmode == MENU_TR then
        self.ypos = 0
      elseif pmode == MENU_L or pmode == MENU_R then
        self.ypos = math.ceil((window_y-self.height)/2)
      elseif pmode == MENU_BL or pmode == MENU_B or pmode == MENU_BR then
        self.ypos = window_y-self.height+1
      end
    elseif pmode == MENU_CENTER then
      self.xpos = math.ceil((window_x-self.width)/2)
      self.ypos = math.ceil((window_y-self.height)/2)
    elseif pmode == MENU_GRID then
      self.xpos, self.ypos = grid.getTilePosition(self.grid_x,self.grid_y)
    end

  elseif self.t == UI_DIALOG then
    local window_x, window_y = love.graphics.getDimensions()
    self.width_factor = math.ceil(window_x/UI_scale)
    self.height_factor = DEFAULT_DIALOG_V_SPAN
    self.width = window_x
    self.height = math.ceil(self.height_factor*UI_scale)
    
    self.canvas = love.graphics.newCanvas(self.width_factor,self.height_factor)
    self.textcanvas = love.graphics.newCanvas(self.width_factor-2*DEFAULT_DIALOG_H_DEADZONE,math.floor(self.width/2)-2*DEFAULT_DIALOG_V_DEADZONE)
    
    self.text_width = self.width_factor-2*DEFAULT_DIALOG_H_DEADZONE
    self.text_height = math.floor(self.height_factor/2)-2*DEFAULT_DIALOG_V_DEADZONE
    self.texture[0] = ui_elements.getDialogBox(self.width_factor,self.height_factor)
    if not self.namebar or not self.namebar_edge then
      self.namebar = TEXTURE_DIALOG_NAMEBAR
      self.namebar_edge = TEXTURE_DIALOG_NAMEBAR_EDGE
    end
    self.imagedata = self.texture[0]:newImageData()
    self.xpos = 0
    self.ypos = window_y-self.height
  elseif self.t == UI_TILE then
    if self.texture[0] then
      self.width = self.texture[0]:getWidth()/TEXTURE_BASE_SIZE
      self.height = self.texture[0]:getHeight()/TEXTURE_BASE_SIZE
    elseif not self.width or not self.height then
      print("UI_TILE needs either a texture or width and height")
    end
    self.canvas = love.graphics.newCanvas(self.width*TEXTURE_BASE_SIZE, self.height*TEXTURE_BASE_SIZE)
    self.xpos, self.ypos = grid.getTilePosition(self.x, self.y)
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

function ui_elements.getDialogBox(width,height,ts_path,bg_color)
  local t_side = nil
  local halfway_pos = math.ceil(height/2)
  bg_color = bg_color or {0.8,0.8,0.8,1}
  if not ts_path then t_side = TEXTURE_DIALOG_SIDE
  else t_side = love.graphics.newImage(ts_path) end
  local side_w, side_h = t_side:getPixelWidth(), t_side:getPixelHeight()

  local h_rep = math.floor(width/side_w+0.5)
  if h_rep == 0 then h_rep = 1 end
  local h_scale = width/(h_rep*side_w)
  
  local canvas = love.graphics.newCanvas(width,height)
  love.graphics.setCanvas(canvas)
  for i=0,h_rep-1 do
    love.graphics.draw(t_side,i*h_scale*side_w,halfway_pos,0,h_scale,1)
  end
  for i=1,h_rep do
   love.graphics.draw(t_side,i*h_scale*side_w,height,math.rad(180),h_scale,1)
  end
  
  love.graphics.setColor(unpack(bg_color))
  love.graphics.rectangle("fill",0,math.ceil(height/2)+side_h,width,math.floor(height/2)-2*side_h)
  love.graphics.setColor(1,1,1,1)
  love.graphics.setCanvas()
  
  return canvas
end

function ui_elements.create(t,id)
--[[UI test for non-base types]]
  return Menu:new(t,id)
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
      end
    else
      if m.texture[m.buttons[j].texture_id] then
        m.buttons[j].width, m.buttons[j].height = m.texture[m.buttons[j].texture_id]:getPixelDimensions()
      end
    end
  end
end

function ui_elements.checkButtonUpdate(m)
  if not m.buttons then return end
  for i=1,#m.buttons do
    if m:isInButton(i) then m.buttons[i].cursorPresent = true
    else m.buttons[i].cursorPresent = false end
  end
  
  for i=1,#m.buttons do
    if not m.buttons[i].noUpdate then
      if m.buttons[i].cursorPresent then
        if not m.buttons[i].pressed then m.buttons[i].texture_id = BUTTON_TEXTURE_HOVERED
        else m.buttons[i].texture_id = BUTTON_TEXTURE_PRESSED end
      else 
        m.buttons[i].pressed = false
        m.buttons[i].texture_id = BUTTON_TEXTURE_NORMAL
      end
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

-- Fit the buttons into a custom made menu
function ui_elements.fitButtons(m,options) --align,spacing,h_deadzone,v_deadzone,tc_path,ts_path,bg_color
  if not options then options = {} end
  options.spacing = options.spacing or DEFAULT_BUTTON_SPACING
  options.h_deadzone = options.h_deadzone or DEFAULT_H_DEADZONE
  options.v_deadzone = options.v_deadzone or DEFAULT_V_DEADZONE
  options.align = options.align

  local height = options.v_deadzone
  local width = 0
  for i=1,#m.buttons do
    if not m.buttons[i].texture_id then m.buttons[i].texture_id = BUTTON_TEXTURE_NORMAL end
    local b_w, b_h = m.texture[m.buttons[i].texture_id]:getDimensions()
    width = math.max(width,b_w)
    m.buttons[i].ypos = height
    m.buttons[i].width = b_w
    m.buttons[i].height = b_h
    height = height + options.spacing + b_h
  end
  height = height + options.v_deadzone - options.spacing
  width = width + 2*options.h_deadzone
  for i=1,#m.buttons do
    local b_w = m.texture[m.buttons[i].texture_id]:getDimensions()
    if options.align == "left" then
      m.buttons[i].xpos = options.h_deadzone
    elseif options.align == "right" then
      m.buttons[i].xpos = width - b_w - options.h_deadzone
    else
      m.buttons[i].xpos = math.ceil((width - b_w)/2)
    end
  end

  m.texture[0] = ui_elements.getNewMenuBackground(width,height,options.tc_path,options.ts_path,options.bg_color)
end

function ui_elements.updateDialog(m)
  local progress = game_time - m.game_time_start
  local page = m.page
  
  local text_to_print = {}
  if not m.finished then
    local characters_to_print = (m.text_rate and m.text_rate[page] or DEFAULT_TEXT_RATE)*progress
    local text_stop_id = 0
    for i=1,#m.text[page] do
      text_stop_id = i
      if type(m.text[page][i]) == "string" then
        characters_to_print = characters_to_print-string.len(m.text[page][i])
        if characters_to_print <= 0 then break end
      end
    end
    if characters_to_print >= 0 then m.finished = true end
    characters_to_print = string.len(m.text[page][text_stop_id])+characters_to_print
    audio.makeSpeech()

    for i=1,text_stop_id-1 do
      text_to_print[i] = m.text[page][i]
    end
    text_to_print[text_stop_id] = string.sub(m.text[page][text_stop_id],1,characters_to_print)
  else
    text_to_print = m.text[page]
  end
  
  local tmp_text = ""
  for i=1,#text_to_print do
    if type(text_to_print[i]) == "string" then
      tmp_text = tmp_text..text_to_print[i]
    end
  end
  
  love.graphics.setFont(FONT_DEFAULT)
  local tw, textlines = FONT_DEFAULT:getWrap(tmp_text,m.text_width)
  local th = #textlines*FONT_DEFAULT:getHeight()
  if th > m.text_height then m.scroll = th-m.text_height
  else m.scroll = 0 end
  
  if #text_to_print == 1 then
    text_to_print[2] = text_to_print[1]
    text_to_print[1] = {1,1,1,1}
  end
  
  m.current_frame = false
  if m.animation and m.animation[page] then
    local freq, repetitions, fade = unpack(m.animation[page][0])
    if not freq then freq = DEFAULT_ANIM_FREQ end
    if not repetitions then repetitions = -1 end
    if fade then
      --NOT IMPLEMENTED
    else
      if (repetitions == -1 and not m.finished) or repetitions == 0 or (progress*freq)/(#m.animation[page]-1) < repetitions then
        local anim_id = math.floor(progress*freq)%(#m.animation[page]-1)+1
        m.current_frame = m.animation[page][anim_id]
      else
        m.current_frame = m.animation[page][#m.animation[page]]
      end
    end
  end
  
  love.graphics.setCanvas(m.textcanvas)
  love.graphics.clear()
  love.graphics.printf(text_to_print,0,-m.scroll,m.text_width)
  love.graphics.setFont(FONT_BASE)
  m:draw()
end

function ui_elements.clickDialog(m)
  if m.finished and not m.noSkip then
    audio.playSound(SFX_TICK)
    m.finished = false
    m.game_time_start = game_time
    m.page = m.page + 1
    if m.page > #m.text then m:close() end
  else
    if not m.finished then audio.playSound(SFX_TICK) end
    m.finished = true
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
    ui_elements.changeUIScale(math.min(window_w*UI_AUTOSCALE_X, window_h*UI_AUTOSCALE_Y))
  end
end

function ui_elements.getUIScaleMode()
  return UI_automatic_scaling, UI_AUTOSCALE_X, UI_AUTOSCALE_Y
end

function ui_elements.resetCallStack()
  MenuCallStack = {}
end

function ui_elements.close(t)
  t = t or 0
  if t<0 or t>#UI_TYPES then t = 0 end
  for i=1,MenuId do
    if Menus[i] and (t==0 or Menus[i].t == t) then
      Menus[i]:close()
    end
  end
end

function ui_elements.select(x,y)
  local grid_x, grid_y = grid.getDimensions()
  for i=0,MenuId do
    if Menus[i] and Menus[i].isSelection then Menus[i]:close() end
  end
  
  if x < 1 or x > grid_x or y < 1 or y > grid_y or (sel_x == x and sel_y == y) then
    sel_x, sel_y = false, false
    return
  end

  ui_elements.makeSelection(x,y)
end

--IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII--
--II                                                                          SPECIFIC PREDEFINED MENUS                                                                        II--
--IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII--

function ui_elements.escapeMenu()
  audio.muffle(true)
  local m = ui_elements.create(UI_MENU)
  m.buttons = {
    {onClick = function(m,b) m:close() ui_elements.mainMenu() end, text = "Main Menu"},
    {onClick = function(m,b) m:close(true) ui_elements.levelSelect() table.insert(MenuCallStack,ui_elements.escapeMenu) end, text = "Level Select"},
    {onClick = function(m,b) m:close(true) ui_elements.videoOptions() table.insert(MenuCallStack,ui_elements.escapeMenu) end, text = "Video Options"},
    {onClick = function(m,b) m:close(true) ui_elements.audioOptions() table.insert(MenuCallStack,ui_elements.escapeMenu) end, text = "Audio Options"},
    {onClick = function(m,b) m:close() end, text = "Return to Game"}
  }
  m.texture[1] = TEXTURE_REG_BUTTON_NORMAL
  m.texture[2] = TEXTURE_REG_BUTTON_PRESSED
  m.texture[3] = TEXTURE_REG_BUTTON_NORMAL
  ui_elements.fitButtons(m)

  m.window_position_mode = MENU_CENTER
  m.isBlocking = true

  -- m.imagedata = m.texture[0]:newImageData() -- ImageData test
  m:resize()
  return m
end

function ui_elements.levelSelect()
  local m = ui_elements.create(UI_MENU)
  m.texture[0] = love.graphics.newImage("Textures/levelselect.png")
  m.texture[1] = TEXTURE_REG_BUTTON_NORMAL
  m.texture[2] = TEXTURE_REG_BUTTON_PRESSED
  m.texture[3] = TEXTURE_REG_BUTTON_NORMAL
  m.texture[5] = TEXTURE_REG_BUTTON_INVIS --INVISIBLE BUTTON 'text area'
  m.buttons = {
    {xpos = 100, ypos = 24, texture_id = 5,text = "LEVEL SELECT", textcolor = COLOR_BLACK, noUpdate = true},
    {xpos = 100, ypos = 378, texture_id = 1, text = "Back", onClick = function(m,b) m:close() end}
  }

  function m:close(noInvoke)
    m.submenu:close(true)
    if self.id == MenuId then
      MenuId = MenuId-1
      while not Menus[MenuId] and MenuId > 0 do MenuId = MenuId-1 end
    end
    Menus[self.id] = nil
    if not noInvoke and #MenuCallStack ~= 0 then
      MenuCallStack[#MenuCallStack](true)
      MenuCallStack[#MenuCallStack] = nil
    end
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
  m.submenu.texture[3] = m.texture[1]
  m.submenu.buttons = {}
  
  local b_x, b_y = 4,4
  for i=1,#Levels do
    m.submenu.buttons[i] = {
      xpos = b_x,
      ypos = b_y,
      lvlid = Levels[i].id,
      texture_id = 1,
      text = Levels[i].name or "Level "..tostring(Levels[i].id),
      onClick = function(m,b) ui_elements.resetCallStack() load_level(b.lvlid) m.parentmenu:close() end
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
  return m
end

function ui_elements.videoOptions()
  local m = ui_elements.create(UI_MENU)
  local BUTTON_OPTIONS_TEXT, BUTTON_OPTIONS_WINDOWTEXT, BUTTON_OPTIONS_SCREENMODE,
        BUTTON_OPTIONS_SCALETEXT, BUTTON_OPTIONS_SCALEMODE, BUTTON_OPTIONS_SCALE,
        BUTTONS_OPTIONS_RETURN, BUTTON_OPTIONS_SCALE_MINUS, BUTTON_OPTIONS_SCALE_PLUS = enum(9)
  m.buttons = {
    {text = "VIDEO OPTIONS", textcolor = COLOR_BLACK, texture_id = 5, noUpdate = true},
    {text = "Window Mode", textcolor = {0.3,0.3,0.3}, align = "left", texture_id = 5, noUpdate = true},
    {text = "Windowed"},
    {text = "UI Scale Options", textcolor = {0.3,0.3,0.3}, align = "left", texture_id = 5, noUpdate = true},
    {text = "Auto", compl2SQButton = true, onClick = function(m,b) ui_elements.changeUIScaleMode() end},
    {text = "Scale:", textcolor = {0.3,0.3,0.3}, texture_id = 5, noUpdate = true},
    {text = "Back", onClick = function(m,b) m:close() end}
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
        if not m:isInButton(i) then
          m.buttons[i].texture_id = BUTTON_TEXTURE_NORMAL + button_texture_offset
          m.buttons[i].pressed = false
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
  return m
end

function ui_elements.audioOptions()
  local m = ui_elements.create(UI_MENU)
  m.texture[1] = TEXTURE_REG_BUTTON_NORMAL
  m.texture[2] = TEXTURE_REG_BUTTON_PRESSED
  m.texture[3] = TEXTURE_MINISQ_BUTTON_NORMAL
  m.texture[4] = TEXTURE_MINISQ_BUTTON_PRESSED
  m.texture[5] = TEXTURE_ARROWR_NORMAL
  m.texture[6] = TEXTURE_ARROWR_PRESSED
  m.texture[7] = TEXTURE_ARROWL_NORMAL
  m.texture[8] = TEXTURE_ARROWL_PRESSED
  m.texture[9] = TEXTURE_SLIDER_NORMAL
  m.texture[10] = TEXTURE_SLIDER_PRESSED
  m.texture[11] = TEXTURE_REG_BUTTON_INVIS

  m.buttons = {
    {texture_id = 11, xpos = 88, ypos = 32, text = "AUDIO OPTIONS", textcolor = COLOR_BLACK, noUpdate = true},
    {texture_id = 11, xpos = 32, ypos = 70, text = "Master Volume", textcolor = {0.3,0.3,0.3}, align = "left", noUpdate = true},
    {texture_id = 3, xpos = 32, ypos = 108, onClick = function(m,b) audio.muteMaster() end, ctrl_id = 1},
    {texture_id = 11, xpos = 32, ypos = 138, text = "Music Volume", textcolor = {0.3,0.3,0.3}, align = "left", noUpdate = true},
    {texture_id = 3, xpos = 32, ypos = 176, onClick = function(m,b) audio.muteMusic() end, ctrl_id = 2},
    {texture_id = 11, xpos = 32, ypos = 206, text = "SFX Volume", textcolor = {0.3,0.3,0.3}, align = "left", noUpdate = true},
    {texture_id = 3, xpos = 32, ypos = 244, onClick = function(m,b) audio.muteSFX() end, ctrl_id = 3},
    {texture_id = 1, xpos = 88, ypos = 274, text = "Back", onClick = function(m,b) m:close() end}
  }
  m.texture[0] = ui_elements.getNewMenuBackground(306,338)
  love.graphics.setCanvas(m.texture[0])
  love.graphics.draw(TEXTURE_SLIDERBAR, 52, 115)
  love.graphics.draw(TEXTURE_SLIDERBAR, 52, 183)
  love.graphics.draw(TEXTURE_SLIDERBAR, 52, 251)
  love.graphics.setCanvas()
  m.volume = {audio.getMasterVolume, audio.getMusicVolume, audio.getSFXVolume}
  m.setVolume = {audio.setMasterVolume, audio.setMusicVolume, audio.setSFXVolume}
  m.mute = {audio.getMasterMute, audio.getMusicMute, audio.getSFXMute}
  for i=1,3 do
    m.buttons[i*2].ypos = m.buttons[i*2].ypos + 8
    local y = m.buttons[1+i*2].ypos + 2
    m.buttons[1+i*2].xpos = 238
    m.buttons[1+i*2].ypos = y - 30
    table.insert(m.buttons, {texture_id = 9, ctrl_id = i, xpos = 52 + math.floor(m.volume[i]()*2 + 0.5), ypos = y, isHeld = true})
    table.insert(m.buttons, {texture_id = 7, ctrl_id = i, xpos = DEFAULT_H_DEADZONE, ypos = y, onClick = function(m,b) m.setVolume[b.ctrl_id](m.volume[b.ctrl_id]() - 0.1) end})
    table.insert(m.buttons, {texture_id = 5, ctrl_id = i, xpos = 262, ypos = y, onClick = function(m,b) m.setVolume[b.ctrl_id](m.volume[b.ctrl_id]() + 0.1) end})
  end
  
  m.update = function(m)
    for i=1,#m.buttons do
      if m.buttons[i].isHeld then
        if m.buttons[i].pressed and love.mouse.isDown(1) then
          local r_mouse_x = love.mouse.getPosition()
          local id = m.buttons[i].ctrl_id
          r_mouse_x = math.floor((r_mouse_x - m.xpos)/UI_scale - 54.5)
          if r_mouse_x < 0 then r_mouse_x = 0 end
          if r_mouse_x > 200 then r_mouse_x = 200 end
          m.buttons[i].xpos = 50 + r_mouse_x
          m.setVolume[id](r_mouse_x/200)
          m.buttons[i].texture_id = 10
        else
          m.buttons[i].pressed = false
          m.buttons[i].xpos = 50 + math.floor(m.volume[m.buttons[i].ctrl_id]()*200)
          m.buttons[i].texture_id = 9
        end

      elseif not m.buttons[i].noUpdate then
        local offset = 2*math.floor((m.buttons[i].texture_id-1)/2)
        if m:isInButton(i) then m.buttons[i].cursorPresent = true
        else m.buttons[i].cursorPresent = false end

        if m.buttons[i].cursorPresent then
          if not m.buttons[i].pressed then m.buttons[i].texture_id = offset + 1
          else m.buttons[i].texture_id = offset + 2 end
        else 
          m.buttons[i].pressed = false
          m.buttons[i].texture_id = offset + 1
        end
      end
    end
    m:draw()
    love.graphics.setCanvas(m.canvas)
    for i=1,3 do
      local b = m.buttons[1+2*i]
      local mute = m.mute[b.ctrl_id]()
      love.graphics.draw(mute and TEXTURE_THUMB_NOSOUND or TEXTURE_THUMB_SOUND, b.xpos, b.ypos)
    end
    love.graphics.setCanvas()
  end
  
  ui_elements.updateButtonDimensions(m)
  m:resize()
 return m
end

function ui_elements.credits()
  local m = ui_elements.create(UI_MENU)
  m.texture[0] = love.graphics.newImage("Textures/levelselect.png")
  m.texture[1] = TEXTURE_REG_BUTTON_NORMAL
  m.texture[2] = TEXTURE_REG_BUTTON_PRESSED
  m.texture[3] = TEXTURE_REG_BUTTON_NORMAL
  m.texture[5] = TEXTURE_REG_BUTTON_INVIS
  m.buttons = {
    {xpos = 100, ypos = 24, texture_id = 5,text = "CREDITS", textcolor = COLOR_BLACK, noUpdate = true},
    {xpos = 100, ypos = 378, texture_id = 1, text = "Back", onClick = function(m,b) m:close() end}
  }

  function m:close(noInvoke)
    m.submenu:close(true)
    if self.id == MenuId then
      MenuId = MenuId-1
      while not Menus[MenuId] and MenuId > 0 do MenuId = MenuId-1 end
    end
    Menus[self.id] = nil
    if not noInvoke and #MenuCallStack ~= 0 then
      MenuCallStack[#MenuCallStack](true)
      MenuCallStack[#MenuCallStack] = nil
    end
  end

  m.submenu = ui_elements.create(UI_MENU)
  m.submenu.parentmenu = m
  m.submenu.width_factor, m.submenu.height_factor = 268, 292
  m.submenu.isBlocking = false
  m.submenu.scrollOffset = 0
  m.submenu.texture[1] = m.texture[5]
  m.submenu.buttons = {
    {text = "Music tracks from AIRGLOW's album:\nMemory Bank", align = "left"},
    {text = "Check him out at\nhttps://soundcloud.com/airglowsounds", align = "left"},
    {text = "SFX", align = "left"},
    {text = "Programming", align = "left"},
    {text = "Art", align = "left"},
    {text = "", align = "left"}
  }
  
  local b_y = 4
  for i=1,#m.submenu.buttons do
    m.submenu.buttons[i].xpos = 4
    m.submenu.buttons[i].ypos = b_y
    b_y = b_y + 36
  end
  m.submenu.onScroll = function(m,x,y)
    y = y*4
    if (y > 0 and m.scrollOffset-y < 0) then y = m.scrollOffset end
    if (y < 0 and m.scrollOffset-y > 36*#m.buttons-288) then y = m.scrollOffset+288-36*#m.buttons end
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
  return m
end

function ui_elements.mainMenu(fromSubmenu)
--THERE CAN BE ONLY ONE
  for i=1, MenuId do if Menus[i] then Menus[i]:close() end end
  local m = ui_elements.create(UI_MENU)
  audio.muffle(false)
  m.noEscape = true
  m.texture[1] = TEXTURE_REG_BUTTON_NORMAL
  m.texture[2] = TEXTURE_REG_BUTTON_PRESSED
  m.texture[3] = TEXTURE_REG_BUTTON_NORMAL
  m.texture[6] = love.graphics.newImage("Textures/title.png")

  m.buttons = {
    {texture_id = 6, noUpdate = true},
    {text = "Play", onClick = function(m,b) m:close() load_level("intro") end},
    {
      text = "Level Select",
      onClick = function(m,b) m:close() table.insert(MenuCallStack,ui_elements.mainMenu) ui_elements.levelSelect() end
    },
    {
      text = "Video Options",
      onClick = function(m,b) m:close() table.insert(MenuCallStack,ui_elements.mainMenu) ui_elements.videoOptions() end
    },
    {
      text = "Audio Options",
      onClick = function(m,b) m:close() table.insert(MenuCallStack,ui_elements.mainMenu) ui_elements.audioOptions() end
    },
    {
      text = "Credits",
      onClick = function(m,b) m:close() table.insert(MenuCallStack,ui_elements.mainMenu) ui_elements.credits() end
    },
    {text = "Exit", onClick = function(m,b) love.event.quit() end}
  }
  ui_elements.fitButtons(m)
  
  m:resize()
  if not fromSubmenu then load_level("main") end
  return m
end

function ui_elements.victory()
  ui_elements.resetCallStack()
  for i=1,MenuId do
    if Menus[i] then Menus[i]:close() end
  end
  local m = ui_elements.create(UI_MENU)
  m.noEscape = true
  
  m.texture[1] = TEXTURE_REG_BUTTON_NORMAL
  m.texture[2] = TEXTURE_REG_BUTTON_PRESSED
  m.texture[3] = TEXTURE_REG_BUTTON_NORMAL
  m.texture[5] = TEXTURE_REG_BUTTON_INVIS

  level_id = (level and level.level_id) or "nil"
  level_name = (level and level.name) or "Unnamed"
  
  m.buttons = {
    {text = "LEVEL "..tostring(level_id)..":", texture_id = 5, noUpdate = true},
    {text = tostring(level_name), texture_id = 5, noUpdate = true},
    {text = "COMPLETE!", texture_id = 5, noUpdate = true},
    {text = "Next Level", onClick = function(m,b) m:close() load_level(level_id+1) end},
    {text = "Level Select", onClick = function(m,b) m:close() table.insert(MenuCallStack,ui_elements.victory) ui_elements.levelSelect() end},
    {text = "Main Menu", onClick = function(m,b) m:close() ui_elements.mainMenu() end}
  }
  ui_elements.fitButtons(m)
  m:resize()
end

function ui_elements.dialogTest()
  local m = ui_elements.create(UI_DIALOG)
  m.text = {
    {{0.5,0.5,0.5},
     "Bonjour et bienvenue au projet gamification du groupe 9, \z
     ne vous preoccupez pas trop de ce qui se passe sur cette grille. Nous l'utilisons \z
     pour rapidement conduire des tests sur les fonctionalites du jeu. Histoire de nous \z
     simplifier la tache, l'ecran s'ouvre en 480p. Nous vous recommandons d'appuyer sur \z
     echap et rentrer dans les options pour afficher en plein ecran. Pour vous faire une \z
     meilleure idee du jeu, veuillez ouvrir le menu 'Level Select' et choisir 'Basics 2' \z
     (le seul niveau entierement interactif). Notez qu'il n'y a pas d'ecran de fin de \z
     niveau de programme. Notez egalement que le bouton 'Main Menu' ne permet actuellement \z
     que de relancer le jeu a son etat initial."}
  }
  m.charname = {"Groupe 9"}
  m.animation[1] = {}
  m.animation[1][0] = {4,-1}
  m.animation[1][1] = love.graphics.newImage("Textures/test1.png")
  m.animation[1][2] = love.graphics.newImage("Textures/test2.png")
  m.animation[1][3] = m.animation[1][1]
  m:resize()
  return m
end

function ui_elements.makeSelection(x,y)
  sel_x, sel_y = x, y
  print("Selected "..tostring(x).." "..tostring(y))
  local sbox = ui_elements.create(UI_TILE,0)
  sbox.isSelection = true
  sbox.x = x
  sbox.y = y
  sbox.texture[0] = TEXTURE_SELECTION_BOX
  sbox:resize()
  local o = Grid[sel_x][sel_y]
  if o then
    local sinfo = ui_elements.create(UI_MENU)
    sinfo.isSelection = true
    sinfo.isBlocking = false
    sinfo.window_position_mode = MENU_TR
    sinfo.o = o
    sinfo.sel_x = sel_x
    sinfo.sel_y = sel_y
    sinfo.texture[0] = love.graphics.newImage("Textures/selectionmenu.png")
    sinfo.texture[1] = TEXTURE_MINISQ_BUTTON_NORMAL
    sinfo.texture[2] = TEXTURE_MINISQ_BUTTON_PRESSED
    sinfo.texture[3] = TEXTURE_MINISQ_BUTTON_GREYED
    sinfo.texture[4] = TEXTURE_MINISQ_PRESS_NORMAL
    sinfo.texture[5] = TEXTURE_MINISQ_PRESS_PRESSED
    sinfo.texture[6] = TEXTURE_MINISQ_PRESS_GREYED
    if DEVELOPER_MODE then
      sinfo.buttons = {
        {xpos = 156, ypos = 74, texture_id = 1, onClick = function(m,b) sinfo.o.canMove = not sinfo.o.canMove UpdateBackgroundFG = true end},
        {xpos = 156, ypos = 138, texture_id = 1, onClick = function(m,b) sinfo.o.canChangeState = not sinfo.o.canChangeState end},
        {xpos = 156, ypos = 172, texture_id = 1, onClick = function(m,b) sinfo.o.canChangeColor = not sinfo.o.canChangeColor end},
        {xpos = 156, ypos = 206, texture_id = 1, onClick = function(m,b) sinfo.o.canRotate = not sinfo.o.canRotate UpdateBackgroundFG = true end},
        {
          xpos = 156, ypos = 240, texture_id = 1,
          onClick = function(m,b)
            sinfo.o:delete()
            sinfo.o = nil
            sel_x, sel_y = false, false
            ui_elements.select(sinfo.sel_x, sinfo.sel_y)
          end
        },
        {xpos = 14, ypos = 240, texture_id = 1, onClick = function(m,b) sinfo.o.glass = not sinfo.o.glass UpdateObjectType[TYPE_GLASS] = true end},
        {xpos = 104, ypos = 172, texture_id = 4, onClick = function(m,b) sinfo.o:changeColor(COLOR_RED) end},
        {xpos = 116, ypos = 172, texture_id = 4, onClick = function(m,b) sinfo.o:changeColor(COLOR_GREEN) end},
        {xpos = 128, ypos = 172, texture_id = 4, onClick = function(m,b) sinfo.o:changeColor(COLOR_BLUE) end},
        {xpos = 140, ypos = 172, texture_id = 4, onClick = function(m,b) sinfo.o:changeColor(COLOR_WHITE) end},
        {xpos = 104, ypos = 184, texture_id = 4, onClick = function(m,b) sinfo.o:changeColor(COLOR_CYAN) end},
        {xpos = 116, ypos = 184, texture_id = 4, onClick = function(m,b) sinfo.o:changeColor(COLOR_MAGENTA) end},
        {xpos = 128, ypos = 184, texture_id = 4, onClick = function(m,b) sinfo.o:changeColor(COLOR_YELLOW) end},
        {xpos = 140, ypos = 184, texture_id = 4, onClick = function(m,b) sinfo.o:changeColor(COLOR_BLACK) end},
        {xpos = 100, ypos = 140, texture_id = -1, width = 12, height = 20, onClick = function(m,b) sinfo.o:changeState(true) end},
        {xpos = 140, ypos = 140, texture_id = -1, width = 12, height = 20, onClick = function(m,b) sinfo.o:changeState() end}
      }
    else
      local mc = sinfo.o.canChangeColor and not sinfo.o.glass
      local ms = sinfo.o.canChangeState and not sinfo.o.glass
      sinfo.buttons = {
        {xpos = 156, ypos = 74, texture_id = 3, noUpdate = true},
        {xpos = 156, ypos = 138, texture_id = 3, noUpdate = true},
        {xpos = 156, ypos = 172, texture_id = 3, noUpdate = true},
        {xpos = 156, ypos = 206, texture_id = 3, noUpdate = true},
        {
          xpos = 156, ypos = 240, texture_id = (sinfo.o.playerMade and 1 or 3),
          noUpdate = (not sinfo.o.playerMade),
          onClick = (sinfo.o.playerMade and function(m,b)
            sinfo.o:delete()
            sinfo.o = nil
            sel_x, sel_y = false, false
            ui_elements.select(sinfo.sel_x, sinfo.sel_y)
          end)
        },
        {xpos = 14, ypos = 240, texture_id = 3, noUpdate = true},
        {xpos = 104, ypos = 172, texture_id = (mc and 4 or 6), noUpdate = (not mc), onClick = (mc and function(m,b) sinfo.o:changeColor(COLOR_RED) end)},
        {xpos = 116, ypos = 172, texture_id = (mc and 4 or 6), noUpdate = (not mc), onClick = (mc and function(m,b) sinfo.o:changeColor(COLOR_GREEN) end)},
        {xpos = 128, ypos = 172, texture_id = (mc and 4 or 6), noUpdate = (not mc), onClick = (mc and function(m,b) sinfo.o:changeColor(COLOR_BLUE) end)},
        {xpos = 140, ypos = 172, texture_id = (mc and 4 or 6), noUpdate = (not mc), onClick = (mc and function(m,b) sinfo.o:changeColor(COLOR_WHITE) end)},
        {xpos = 104, ypos = 184, texture_id = (mc and 4 or 6), noUpdate = (not mc), onClick = (mc and function(m,b) sinfo.o:changeColor(COLOR_CYAN) end)},
        {xpos = 116, ypos = 184, texture_id = (mc and 4 or 6), noUpdate = (not mc), onClick = (mc and function(m,b) sinfo.o:changeColor(COLOR_MAGENTA) end)},
        {xpos = 128, ypos = 184, texture_id = (mc and 4 or 6), noUpdate = (not mc), onClick = (mc and function(m,b) sinfo.o:changeColor(COLOR_YELLOW) end)},
        {xpos = 140, ypos = 184, texture_id = (mc and 4 or 6), noUpdate = (not mc), onClick = (mc and function(m,b) sinfo.o:changeColor(COLOR_BLACK) end)},
        {xpos = 100, ypos = 140, texture_id = -1, width = 12, height = 20, onClick = (ms and function(m,b) sinfo.o:changeState(true) end)},
        {xpos = 140, ypos = 140, texture_id = -1, width = 12, height = 20, onClick = (ms and function(m,b) sinfo.o:changeState() end)}
      }
    end
    ui_elements.updateButtonDimensions(sinfo)
    
    sinfo.onScroll = function(m, x, y)
      if DEVELOPER_MODE or (m.o.canRotate and not m.o.glass) then m.o:rotate(y>0) end
    end

    sinfo.update = function(m)
      if not m.o or not Grid[sel_x] or Grid[sel_x][sel_y] ~= m.o then
        sel_x, sel_y = false, false
        for i=0, MenuId do
          if Menus[i] and Menus[i].isSelection then
            Menus[i]:close()
          end
        end
        return
      end
      
--    BUTTON UPDATES
      for i=1,#m.buttons do
        if m:isInButton(i) then m.buttons[i].cursorPresent = true
        else m.buttons[i].cursorPresent = false end
      end
      
--    SMALL SQUARE BUTTONS
      for i=1,14 do
        if (i>6) or not m.buttons[i].noUpdate then
          if m.buttons[i].cursorPresent then
            if not m.buttons[i].pressed then m.buttons[i].texture_id = (i>6) and (m.buttons[i].noUpdate and 6 or 4) or 1
            else m.buttons[i].texture_id = (i>6) and (m.buttons[i].noUpdate and 6 or 5) or 2 end
          else 
            m.buttons[i].pressed = false
            m.buttons[i].texture_id = (i>6) and (m.buttons[i].noUpdate and 6 or 4) or 1
          end
        end
      end
      if not m.buttons[15].cursorPresent then m.buttons[15].pressed = false end
      if not m.buttons[16].cursorPresent then m.buttons[16].pressed = false end
      local c = band(m.o.color,7)
      if c == COLOR_RED then
        m.buttons[7].texture_id = 5
      elseif c == COLOR_GREEN then
        m.buttons[8].texture_id = 5
      elseif c == COLOR_BLUE then
        m.buttons[9].texture_id = 5
      elseif c == COLOR_WHITE then
        m.buttons[10].texture_id = 5
      elseif c == COLOR_CYAN then
        m.buttons[11].texture_id = 5
      elseif c == COLOR_MAGENTA then
        m.buttons[12].texture_id = 5
      elseif c == COLOR_YELLOW then
        m.buttons[13].texture_id = 5
      else
        m.buttons[14].texture_id = 5
      end
      
      m:draw()
      love.graphics.setCanvas(m.canvas)
      local Locks = {m.o.canMove, m.o.canChangeState, m.o.canChangeColor, m.o.canRotate}
      love.graphics.draw(Locks[1] and TEXTURE_THUMB_NOLOCK or TEXTURE_THUMB_LOCK,156,74)
      for i=2,#Locks do
        love.graphics.draw(Locks[i] and TEXTURE_THUMB_NOLOCK or TEXTURE_THUMB_LOCK,156,70+34*i)
      end
      love.graphics.draw(m.o.glass and TEXTURE_THUMB_GLASS or TEXTURE_THUMB_NOGLASS,14,240)
      love.graphics.draw(TEXTURE_THUMB_TRASH,156,240)
      tiles.drawTexture(m.o.t,m.o.state,m.o.color,m.o.side)
      love.graphics.setCanvas(m.canvas)
      love.graphics.setBlendMode("alpha","premultiplied")
      love.graphics.draw(canvas_Texture, 22 + TEXTURE_BASE_SIZE, 54 + TEXTURE_BASE_SIZE, math.rad(90*m.o.rotation), 2,nil, TEXTURE_OFFSET, TEXTURE_OFFSET)
      love.graphics.setBlendMode("alpha")
      
      love.graphics.setFont(FONT_DEFAULT)
      love.graphics.print(TYPES[m.o.t]:gsub("^%l", string.upper),12,4,nil,2)
      love.graphics.print(tostring(m.o.xpos),122,65)
      love.graphics.print(tostring(m.o.ypos),122,99)
      local state = tostring(m.o.state)
      local tw = FONT_DEFAULT:getWidth(state)
      love.graphics.print(tostring(m.o.state),126-math.floor(tw/2),146)
      
      love.graphics.setFont(FONT_BASE)
      
      love.graphics.setCanvas()
    end

    sinfo:resize()
  else
    local splace = ui_elements.create(UI_MENU)
    splace.isSelection = true
    splace.isBlocking = false
    splace.window_position_mode = MENU_TR
    splace.sel_x = sel_x
    splace.sel_y = sel_y
    splace.ot = TYPE_WALL
    splace.texture[0] = love.graphics.newImage("Textures/selectionempty.png")
    splace.texture[1] = TEXTURE_MINISQ_BUTTON_NORMAL
    splace.texture[2] = TEXTURE_MINISQ_BUTTON_PRESSED
    splace.texture[3] = TEXTURE_MINISQ_BUTTON_GREYED
    splace.buttons = {
      {xpos = 114, ypos = 60, texture_id = 1, noUpdate = true},
      {xpos = 156, ypos = 60, texture_id = 1},
      {xpos = 100, ypos = 62, texture_id = -1, width = 12, height = 20, onClick = function(m,b) m.ot = (m.ot - 2) % #TYPES + 1 end},
      {xpos = 140, ypos = 62, texture_id = -1, width = 12, height = 20, onClick = function(m,b) m.ot = m.ot % #TYPES + 1 end}
    }
    splace.buttons[2].onClick = function(m,b)
      local o = grid.fit(m.ot, m.sel_x, m.sel_y, {canMove = true, canRotate = true, canChangeState = true, canChangeColor = true})
      o.playerMade = true
      audio.playSound(2 + objects.getSFXOffset(o.t))
      sel_x, sel_y = false, false
      ui_elements.select(m.sel_x, m.sel_y)
      return
    end
    ui_elements.updateButtonDimensions(splace)
    
    splace.onScroll = function(m, x, y)
      m.ot = (m.ot - 1 - y) % #TYPES + 1
    end

    splace.update = function(m)
      if Grid[m.sel_x] and Grid[m.sel_x][m.sel_y] then
        sel_x, sel_y = false, false
        ui_elements.select(m.sel_x, m.sel_y)
        return
      end
      
--    BUTTON UPDATES
      for i=1,#m.buttons do
        if m:isInButton(i) then m.buttons[i].cursorPresent = true
        else m.buttons[i].cursorPresent = false end
      end
      if m.buttons[2].cursorPresent then
        if not m.buttons[2].pressed then m.buttons[2].texture_id = 1
        else m.buttons[2].texture_id = 2 end
      else 
        m.buttons[2].pressed = false
        m.buttons[2].texture_id = 1
      end
      if not m.buttons[3].cursorPresent then m.buttons[3].pressed = false end
      if not m.buttons[4].cursorPresent then m.buttons[4].pressed = false end
      m:draw()
      love.graphics.setCanvas(m.canvas)
      love.graphics.draw(TEXTURE_THUMB[m.ot],114,60)
      love.graphics.draw(TEXTURE_THUMB_CHECK,156,60)
      love.graphics.setCanvas()
    end
    splace:resize()
  end
end

function ui_elements.makeLevelMenu()
  for i=1,MenuId do
    if Menus[i] and Menus[i].isLevelMenu then Menus[i]:close() end
  end
  if level and level.noUI then return end

  local m = ui_elements.create(UI_MENU)
  m.window_position_mode = MENU_TL
  m.isBlocking = false
  m.isLevelMenu = true
  m.sel_t = TYPE_WALL
  local lvl_id = level and tostring(level.level_id) or "NaN"
  local lvl_name = level and level.name or "Unnamed"
  local lvl_info = "Level "..tostring(lvl_id).." - "..lvl_name
  local tw = FONT_DEFAULT:getWidth(lvl_info)
  m.bpos = tw + 4
  m.texture[0] = love.graphics.newCanvas(tw + 166, 32)
  love.graphics.setCanvas(m.texture[0])
  love.graphics.setColor(0.8,0.8,0.8,1)
  love.graphics.rectangle("fill", 0, 0, tw + 162, 28)
  love.graphics.setColor(0.4,0.4,0.4,1)
  love.graphics.rectangle("fill", 0, 28, tw + 162, 30)
  love.graphics.rectangle("fill", tw + 162, 0, tw + 164, 28)
  love.graphics.points(tw + 161, 27, tw + 161, 28, tw + 162, 27,  tw + 162, 28)
  love.graphics.setColor(0.2,0.2,0.2,1)
  love.graphics.rectangle("fill", 0, 30, tw + 164, 32)
  love.graphics.rectangle("fill", tw + 164, 0, tw + 166, 30)
  love.graphics.points(tw + 163, 29, tw + 163, 30, tw + 164, 29, tw + 164, 30)
  love.graphics.setColor(1,1,1,1)
  love.graphics.draw(TEXTURE_MINISQ_BUTTON_NORMAL, tw + 122, 2)
  love.graphics.setFont(FONT_DEFAULT)
  love.graphics.print(lvl_info, 2, 8)
  love.graphics.setFont(FONT_BASE)
  love.graphics.setCanvas()
  
  m.texture[1] = TEXTURE_MINISQ_BUTTON_NORMAL
  m.texture[2] = TEXTURE_MINISQ_BUTTON_PRESSED
  m.texture[3] = TEXTURE_ARROWL_NORMAL
  m.texture[4] = TEXTURE_ARROWL_PRESSED
  m.texture[5] = TEXTURE_ARROWR_NORMAL
  m.texture[6] = TEXTURE_ARROWR_PRESSED
  m.texture[7] = TEXTURE_MINISQ_BUTTON_GREYED
  
  local mod = (DEVELOPER_MODE or level and level.canModify)
  m.buttons = {
    {xpos = tw + 4, ypos = 2, texture_id = 1, onClick = function(m,b) cursor_mode = CURSOR_MOVE end},
    {xpos = tw + 30, ypos = 2, texture_id = 1, onClick = function(m,b) cursor_mode = CURSOR_SELECT end},
    {xpos = tw + 56, ypos = 2, texture_id = mod and 1 or 7, noUpdate = not mod, onClick = mod and function(m,b) cursor_mode = CURSOR_DELETE end},
    {xpos = tw + 82, ypos = 2, texture_id = mod and 1 or 7, noUpdate = not mod, onClick = mod and function(m,b) cursor_mode = CURSOR_PLACE end},
    {xpos = tw + 108, ypos = 4, texture_id = 4, onClick = function(m,b) m.sel_t = (m.sel_t - 2)%#TYPES + 1 end},
    {xpos = tw + 148, ypos = 4, texture_id = 6, onClick = function(m,b) m.sel_t = (m.sel_t)%#TYPES + 1 end}
  }
  m.update = function(m)
    for i=1,#m.buttons do
      if not m.buttons[i].noUpdate then
        local offset = 2*math.floor((m.buttons[i].texture_id-1)/2)
        if m:isInButton(i) and m.buttons[i].pressed then
          m.buttons[i].texture_id = offset + 2
        else
          m.buttons[i].pressed = false
          m.buttons[i].texture_id = offset + 1
        end
      end
    end
    m.buttons[cursor_mode].texture_id = 2
    m:draw()
    love.graphics.setCanvas(m.canvas)
    love.graphics.draw(TEXTURE_THUMB_MOVE, m.bpos, 2)
    love.graphics.draw(TEXTURE_THUMB_SELECT, m.bpos+26, 2)
    love.graphics.draw(TEXTURE_THUMB_DELETE, m.bpos+52, 2)
    love.graphics.draw(TEXTURE_THUMB_PLACE, m.bpos+78, 2)
    love.graphics.draw(TEXTURE_THUMB[m.sel_t], m.bpos+118, 2)
    love.graphics.setCanvas()
  end
  
  m.onScroll = function(m, x, y)
    m.sel_t = (m.sel_t - 1 - y) % #TYPES + 1
  end
  ui_elements.updateButtonDimensions(m)
  m:resize()
  return m
end

return ui_elements