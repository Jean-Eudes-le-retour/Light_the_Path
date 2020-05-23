-- GENERAL CONSTANTS --
DEVELOPER_MODE = false
TEXTURE_BASE_SIZE = 32
TEXTURE_OFFSET = TEXTURE_BASE_SIZE/2
BACKGROUND_VARIANTS = 1
NUM_OVERLAY_TEXTURES = 15
NUM_CONNECTED_TEXTURE_TILES = 2
STATE_CONFIGURATIONS = {[1]=1,[5]=2,[21]=3,[85]=4,[17]=5,[29]=6,[113]=7,[93]=8,[125]=9,[7]=10,[31]=11,[127]=12,[255]=13,[119]=14,[0]=15}
TEXT_MARGIN = 4
FONT_DEFAULT = love.graphics.newImageFont("Textures/Fonts/mypixelfont.png"," abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-=!@#$%^&*()_+|\\[]{}:;\"'<>,./?~`",1)
FONT_BASE = love.graphics.getFont()
DEFAULT_SCREEN_WIDTH = 720
DEFAULT_SCREEN_HEIGHT = 480
LASER_FREQUENCY = 8
TEXTURE_LASER = {love.graphics.newImage("Textures/laser_1.png"),love.graphics.newImage("Textures/laser_2.png"),love.graphics.newImage("Textures/laser_3.png"),love.graphics.newImage("Textures/laser_4.png"),love.graphics.newImage("Textures/laser_5.png"),love.graphics.newImage("Textures/laser_6.png"),love.graphics.newImage("Textures/laser_7.png"),love.graphics.newImage("Textures/laser_8.png")}
MASK_LASER = {love.graphics.newImage("Textures/laser_mask.png"),love.graphics.newImage("Textures/laser_mask.png"),love.graphics.newImage("Textures/laser_mask.png"),love.graphics.newImage("Textures/laser_mask.png"),love.graphics.newImage("Textures/laser_mask.png"),love.graphics.newImage("Textures/laser_mask.png"),love.graphics.newImage("Textures/laser_mask.png"),love.graphics.newImage("Textures/laser_mask.png")}
TEXTURE_SIDEINPUT = love.graphics.newImage("Textures/logic_input.png")
TEXTURE_SIDEOUTPUT = love.graphics.newImage("Textures/logic_output.png")
TEXTURE_SIDEACTIVATE = love.graphics.newImage("Textures/receiver_activate.png")
MASK_EFFECT = love.graphics.newShader[[
   vec4 effect (vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
      if (Texel(texture, texture_coords).rgb == vec3(0.0)) {
         // a discarded pixel wont be applied as the stencil.
         discard;
      }
      return vec4(1.0);
   }
]]
MASK_EFFECT2 = love.graphics.newShader[[
   vec4 effect (vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
      if (Texel(texture, texture_coords).rgb != vec3(0.0)) {
         // a discarded pixel wont be applied as the stencil.
         discard;
      }
      return vec4(1.0);
   }
]]

function file_exists(name)
   if love.filesystem.getInfo(name) then return true
   else return false end
end

function enum(n,i)
  i = i or 1
  if n > i then
    return i, enum(n,i+1)
  end
  return n
end

function duplicateTable(Tab)
  local NewTab = {}
  for i=1,#Tab do
    if type(Tab[i]) == "table" then
      NewTab[i] = duplicateTable(Tab[i])
    else
      NewTab[i] = Tab[i]
    end
  end
  return NewTab
end

-- ENUM CONSTANTS --
NUM_TYPES = 7
TYPE_WALL, TYPE_GLASS, TYPE_SOURCE, TYPE_RECEIVER, TYPE_MIRROR, TYPE_PWHEEL, TYPE_LOGIC = enum(NUM_TYPES)

NUM_COLORS = 8
COLOR_RED, COLOR_GREEN, COLOR_YELLOW, COLOR_BLUE, COLOR_MAGENTA, COLOR_CYAN, COLOR_WHITE, COLOR_BLACK = enum(NUM_COLORS)

NUM_CURSOR_MODES = 4
CURSOR_MOVE, CURSOR_ROTATE, CURSOR_INTERACT, CURSOR_SELECT = enum(NUM_CURSOR_MODES)

NUM_MENU_MODES = 10
MENU_TL, MENU_T, MENU_TR, MENU_R, MENU_BR, MENU_B, MENU_BL, MENU_L, MENU_CENTER, MENU_GRID = enum(NUM_MENU_MODES)

NUM_UI_BASE_TYPES = 3
NUM_UI_TYPES = 6
UI_MENU, UI_DIALOG, UI_TILE, UI_TITLE, UI_LEVELSELECT, UI_OPTIONS = enum(NUM_UI_TYPES)

NUM_BUTTON_TEXTURES = 3
BUTTON_TEXTURE_NORMAL, BUTTON_TEXTURE_PRESSED, BUTTON_TEXTURE_HOVERED = enum(NUM_BUTTON_TEXTURES)

NUM_LOGIC = 3
LOGIC_OR, LOGIC_AND, LOGIC_NOT = enum(NUM_LOGIC)