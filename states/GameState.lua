--[[   Copyright 2014 Sergej Nisin

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
]]

local GameState = {}
local this = {}
GameState.this = this
function GameState.load()
	this.resetbutton = RessourceManager.images.buttons.reset
	this.eggs = RessourceManager.images.eggs
	this.clvl = {}
	this.origlevel = {}
	this.worldId = 1
	this.levelId = 1
	this.customlevel = "no"
end
function GameState.enter(args) -- {cmd="", worldId=0, levelId=0, world={}, custom=""}       world, level, worldid, custom )
	this.clvl = {
		world={
			{0,0,0,0,0},
			{0,0,0,0,0},
			{0,0,0,0,0},
			{0,0,0,0,0},
			{0,0,0,0,0},
			{0,0,0,0,0}
		},
		taps=0,
		projectiles = {}
	}
	if args.cmd == "loadTable" then -- Load level from table. Used for custom levels and editor
		table.merge(this.clvl, args.world)
		this.worldId = args.worldId
		this.levelId = args.levelId
		this.customlevel = args.custom
	elseif args.cmd == "again" then  -- reset level, called from loststate and wonstate
		this.clvl = table.copy(this.origlevel, true)
	elseif args.cmd == "loadLevel" then -- load official level
		if LevelManager.worlds[args.worldId].levels[args.levelId] then
			this.clvl.world = table.copy(LevelManager.worlds[args.worldId].levels[args.levelId].world, true)
			this.clvl.taps = LevelManager.worlds[args.worldId].levels[args.levelId].taps
			this.worldId = args.worldId
			this.levelId = args.levelId
			this.customlevel = "no"
		else
			StateManager.setState("menu")
		end
	else -- Unknown 
		StateManager.setState("menu")
	end
	this.origlevel = table.copy(this.clvl, true)
	SoundManager.playMusic("game")
end
function GameState.update(dt)
	for i,v in ipairs(this.clvl.projectiles) do
		if v.dir == "left" then
			v.x = v.x-200*dt*game.scaleX
		elseif v.dir == "right" then
			v.x = v.x+200*dt*game.scaleX
		elseif v.dir == "up" then
			v.y = v.y-200*dt*game.scaleY
		elseif v.dir == "down" then
			v.y = v.y+200*dt*game.scaleY
		end
		if v.x < 0 or v.y < 0 or v.x > #this.clvl.world[1]*game.tilew or v.y > #this.clvl.world*game.tileh or this.hitegg(v.x, v.y) then

			table.remove(this.clvl.projectiles, i)
		end
	end
	if this.checkwin() then
		SoundManager.playSound("win", true)
		if this.customlevel == "edit" then
			StateManager.setState("editor", "return", "You won")

		else
			local world = this.worldId
			local level = this.levelId
			SaveManager.save.crnt = 1
			LevelManager.setLevelSuccessed(world, level, this.customlevel)
			SaveManager.saveGame()
			
			this.clvl.projectiles = {}
			StateManager.addState("won")
		end
	end
	if #this.clvl.projectiles == 0 and not this.checkwin() and this.clvl.taps <= 0 then
		SoundManager.playSound("lost", true)
		if this.customlevel == "edit" then
			StateManager.setState("editor", "return", "You lost")
		else
			StateManager.addState("lost", this.worldId, this.levelId)
		end
	end
end

function GameState.draw()
	love.graphics.setColor(255,255,255,255)
	for y,v in ipairs(this.clvl.world) do
		for x,v2 in ipairs(v) do
			if this.eggs[v2] then
				love.graphics.draw(this.eggs[v2], (x-1)*game.tilew+game.eggofX, (y-1)*game.tileh+game.eggofY +game.offY, 0, game.scale, game.scale)
			end
		end
	end
	
	for i,v in ipairs(this.clvl.projectiles) do
		love.graphics.setColor(255,255,0,255)
		love.graphics.circle("fill", v.x, v.y+game.offY, 5*game.scale)
		
		love.graphics.setColor(0,0,0,255)
		love.graphics.circle("line", v.x, v.y+game.offY, 5*game.scale)
	end
	love.graphics.setColor(255,255,255,255)
	local barimg = RessourceManager.images.bar
	love.graphics.draw(barimg, 0, 0, 0, love.graphics.getWidth()/barimg:getWidth(), (50*pixelscale)/barimg:getHeight())
	
	love.graphics.setColor(0,0,0,255)
	love.graphics.printf("Moves left: "..this.clvl.taps, 1, (game.offY-font:getHeight())/2+1, love.graphics.getWidth(), "center")
	love.graphics.setColor(255,255,255,255)
	love.graphics.printf("Moves left: "..this.clvl.taps, 0, (game.offY-font:getHeight())/2, love.graphics.getWidth(), "center")

	local resetwidth, resetheight = 32*pixelscale, 32*pixelscale
	local offset = (game.offY-resetheight)/2
	love.graphics.draw(this.resetbutton, love.graphics.getWidth()-resetwidth-offset, offset, 0, resetwidth/this.resetbutton:getWidth(), resetheight/this.resetbutton:getHeight())
end

function GameState.mousepressed(x, y, button)
	local resetwidth, resetheight = 32*pixelscale, 32*pixelscale
	local offset = (game.offY-resetheight)/2
	if ButtonManager.check(love.graphics.getWidth()-resetwidth-offset, offset, resetwidth, resetheight) then
		this.clvl = table.copy(this.origlevel, true)
	end

	if this.clvl.taps>0 and this.hitegg(x, y-game.offY) then
		this.clvl.taps = this.clvl.taps - 1
	end
end

function GameState.keypressed(k)
	if k == "escape" then
		if this.customlevel == "edit" then
			StateManager.setState("editor", "return")
		else
			StateManager.setState("selectlevel", "rettomenu")
		end
	end
end

function this.checkwin()
	for y,v in ipairs(this.clvl.world) do
		for x,v2 in ipairs(v) do
			if this.eggs[v2] then
				return false
			end
		end
	end
	return true
end

function this.hitegg(mx, my)
	local x = math.floor(mx/game.tilew)+1
	local y = math.floor(my/game.tileh)+1
	if this.clvl.world[y] and this.clvl.world[y][x] and this.clvl.world[y][x]>0 then
		this.clvl.world[y][x] = this.clvl.world[y][x]-1
		if this.clvl.world[y][x] == 0 then
			table.insert(this.clvl.projectiles, {x=(x-1)*game.tilew+game.tilew/2, y=(y-1)*game.tileh+game.tileh/2, dir="left"})
			table.insert(this.clvl.projectiles, {x=(x-1)*game.tilew+game.tilew/2, y=(y-1)*game.tileh+game.tileh/2, dir="right"})
			table.insert(this.clvl.projectiles, {x=(x-1)*game.tilew+game.tilew/2, y=(y-1)*game.tileh+game.tileh/2, dir="up"})
			table.insert(this.clvl.projectiles, {x=(x-1)*game.tilew+game.tilew/2, y=(y-1)*game.tileh+game.tileh/2, dir="down"})
		end
		SoundManager.playSound("hit")
		return true
	end
	return false
end

StateManager.registerState("game", GameState)