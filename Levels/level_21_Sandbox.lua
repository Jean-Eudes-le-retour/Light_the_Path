local grid = require("grid")        -- Used to modify or observe the grid and its content.

local level = {}

-- IMPORTANT VARIABLES --
level.complete = false
level.x = 32
level.y = 18
level.name = "Sandbox"
level.canModify = true

-- IMPORTANT FUNCTIONS --
function level.load()
-- CREATE GRID -- grid is made to the specified dimensions, and drawbox is defined (by default, x fits to screen and y is centered)
  grid.setDimensions(level.x,level.y,level.drawbox_mode,level.x_val,level.y_val)
end

function level.update(dt) -- dt is time since last update in seconds

end

return level