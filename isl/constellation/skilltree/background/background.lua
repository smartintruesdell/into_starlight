--[[
   UISkillTreeBackground manages drawing the skill tree background layer.
]]
require("/scripts/util.lua")
require("/scripts/questgen/util.lua")
require("/isl/lib/uicomponent.lua")

local PATH = "/isl/constellation/skilltree/background"
local Assets = {}
Assets.grid_tile = PATH.."/assets/grid_tile.png"

-- Class ----------------------------------------------------------------------

UISkillTreeBackground = defineSubclass(UIComponent, "UISkillTreeBackground")()

-- Constructor ----------------------------------------------------------------

function UISkillTreeBackground:init(canvas)
   self.canvas = canvas
   assert(
      self.canvas ~= nil,
      "Unable to bind a valid canvas for the background"
   )
   self.bounds = Bounds.new(
      {0, 0},
      self.canvas:size()
   )
   self.grid_tile_size = Point.new(root.imageSize(Assets.grid_tile))
end

-- Methods --------------------------------------------------------------------

function UISkillTreeBackground:draw(skilltree_state)
   -- This part of the background scrolls with the user's drag
   -- and gives them the sense of moving a space around.
   self.canvas:drawTiledImage(
      Assets.grid_tile,
      skilltree_state.drag_offset:mod(self.grid_tile_size),
      {
         0,
         0,
         self.bounds.max[1] + self.grid_tile_size[1],
         self.bounds.max[2] + self.grid_tile_size[2]
      }
   )
end
