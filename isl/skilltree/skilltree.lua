--[[
   Interface logic for the IntoStarlight Skilltree

]]

-- Constants ------------------------------------------------------------------
currencyTable = {}
skillTree = nil
gridTileImage = nil
gridTileSize = nil
canvasSize = nil
canvas = nil
data = nil
strings = nil

-- Variables ------------------------------------------------------------------
dragOffset = { x = 0, y = 0 }

-- Main -----------------------------------------------------------------------

function init()
   currencyTable = root.assetJson("/currencies.config")
   data = root.assetJson("/isl/skilltree/skilltree_data.json")
   strings = root.assetJson("/isl/skilltree/skilltree_strings.json")

   gridTileImage = data.defaultGridTileImage
   gridTileSize = root.imageSize(gridTileImage)
   canvas = widget.bindCanvas("canvas")
   canvasSize = widget.getSize("canvas")

   draw()
end
