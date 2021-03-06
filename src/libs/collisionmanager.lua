local collisionmanager = {}


function collisionmanager:init()

   self.tiles = {}
   dbug.show('collision manager loaded')

end


function collisionmanager:clearAll()

   constants.clearTable(self.tiles)

end


function collisionmanager:addTile(params)

   -- expects:
   -- xtile
   -- ytile
   -- id: 'solid', 'exit'

   -- optional:
   -- dest: table with keys xtile, ytile, map (string)
   -- name: name of npc, used for looking up dialogue
   -- w/h: width/height in px of the collision tile


   local params = params or {}
   local tbl = {}

   local toAdd = {xtile = tonumber(params.xtile), ytile = tonumber(params.ytile), id = params.id}

   -- you can specify the width and height of the collision tile
   toAdd.wtile = params.wtile or 1
   toAdd.htile = params.htile or 1

   if params.dest then
      dbug.show('exit added: ' .. params.dest.map)
      toAdd.dest = {xtile = tonumber(params.dest.xtile), ytile = tonumber(params.dest.ytile), map = params.dest.map}
   end

   if params.name then
      toAdd.name = params.name
   end

   table.insert(self.tiles, toAdd)

end


function collisionmanager:NPCfirst(name)

   table.sort(self.tiles, function(a,b) return a.name and (a.name == name) or false end)

end


function collisionmanager:removeNPC(name)

   self:NPCfirst(name)
   table.remove(self.tiles, 1)

end


function collisionmanager:detect(x, y, w, h, npc)

   local w = w or constants.tilesize
   local h = h or constants.tilesize

   -- detect a square
   local xtile = constants:pxtotile(x)
   local ytile = constants:pxtotile(y)
   local xtile2 = constants:pxtotile(x+w-1)
   local ytile2 = constants:pxtotile(y+h-1)

   for i,v in ipairs(self.tiles) do
      for i = 1, v.wtile, 1 do
         for j = 1, v.htile, 1 do

            if (((xtile == v.xtile) or (xtile2 == v.xtile+i)) and
                ((ytile == v.ytile) or (ytile2 == v.ytile+j))) then
               dbug.show('collision registered at ' .. xtile .. ', ' .. ytile .. ', ' .. v.id)
               -- if it is an exit tile, v.dest will be set
               -- if it is an npc, v.name will be set
               return v.id, v.dest or v.name or nil

            elseif (((xtile <= 0) or (xtile2 >= constants.wtile)) or
                    ((ytile <= 0) or (ytile2 >= constants.htile))) then
               dbug.show('offscreen collision registered at ' .. xtile .. ', ' .. ytile)
               return true
            end

         end
      end
   end

   return false

end


function collisionmanager:render()

   --[[
   if dbugglobal then
      for i,v in ipairs(self.tiles) do
         love.graphics.rectangle("line", constants:tiletopx(v.xtile), constants:tiletopx(v.ytile), constants:tiletopx(v.wtile), constants:tiletopx(v.htile))
         love.graphics.rectangle("line", constants:tiletopx(v.xtile+v.wtile), constants:tiletopx(v.ytile+v.htile), constants:tiletopx(v.wtile), constants:tiletopx(v.htile))
      end
   end
   --]]

end


function collisionmanager.draw()

   collisionmanager:render()

end



return collisionmanager
