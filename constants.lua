-- GENERAL CONSTANTS --
DEVELOPER_MODE = false
TEXTURE_BASE_SIZE = 32
BACKGROUND_VARIANTS = 1
NUM_OVERLAY_TEXTURES = 15
NUM_CONNECTED_TEXTURE_TILES = 2
STATE_CONFIGURATIONS = {[1]=1,[5]=2,[21]=3,[85]=4,[17]=5,[29]=6,[113]=7,[93]=8,[125]=9,[7]=10,[31]=11,[127]=12,[255]=13,[119]=14,[0]=15}
TEXT_MARGIN = 4
FONT_DEFAULT = love.graphics.newImageFont("Textures/Fonts/mypixelfont.png"," abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-=!@#$%^&*()_+|\\[]{}:;\"'<>,./?~`",1)
FONT_BASE = love.graphics.getFont()
DEFAULT_SCREEN_WIDTH = 720
DEFAULT_SCREEN_HEIGHT = 480

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

-- ENUM CONSTANTS --
NUM_TYPES = 7
TYPE_WALL, TYPE_GLASS, TYPE_SOURCE, TYPE_RECEIVER, TYPE_MIRROR, TYPE_PWHEEL, TYPE_PRISM = enum(NUM_TYPES)

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