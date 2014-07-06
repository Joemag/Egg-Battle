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

local LostState = {}
local this = {}
LostState.this = this

function LostState.load()
	this.buttons = ButtonManager.new()
end
function LostState.enter()
	this.buttons:removeAllButtons()
	this.buttons:addCenterButton("tryagain", "Try again", -120*pixelscale)
	if game.customlevel then
		if SelCusLevelState.this.canPlayLevel( "next" ) then
			this.buttons:addCenterButton("skip", "Skip level", 0)
		end
	else
		if canPlayLevel(clvl.level+1, true) then
			this.buttons:addCenterButton("skip", "Skip level", 0)
		end
	end
	this.buttons:addCenterButton("menu", "Return to menu", 80*pixelscale)
	
	this.anim = {prog = love.window.getHeight(), back=0}
	this.animt = Tween.new(0.7, this.anim, {prog=0, back=100}, "outCubic")
end
function LostState.update(dt)
	this.animt:update(dt)
	if this.anim.per == 1 then
		this.afterBack()
	end
end
function LostState.draw()
	love.graphics.setColor(50,0,0,this.anim.back)
	love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
	love.graphics.setColor(0,0,0,255)
	love.graphics.print("No moves left", (love.graphics.getWidth()-font:getWidth("No moves left"))/2+1, love.graphics.getHeight()/2-150*pixelscale+1+this.anim.prog)
	love.graphics.setColor(255,255,255,255)
	love.graphics.print("No moves left", (love.graphics.getWidth()-font:getWidth("No moves left"))/2, love.graphics.getHeight()/2-150*pixelscale+this.anim.prog)
	
	this.buttons:draw(this.anim.prog)
end

function LostState.mousepressed(x, y, button)
	local clickedbutton = this.buttons:getClickedButton(x, y)
	if clickedbutton == "tryagain" then
		if game.customlevel then
			this.animBack("game", "again")
		else
			this.animBack(function() loadLevel(clvl.level) end)
		end
	end
	if clickedbutton == "skip" and canPlayLevel(clvl.level+1, true) then
		if game.customlevel then
			this.animBack("selectcustomlevel", "next")
		else
			this.animBack(function() loadLevel(clvl.level+1) end)
		end
	end
	if clickedbutton == "menu" then
		if game.customlevel then
			this.animBack("selectcustomlevel", "rettomenu")
		else
			this.animBack("selectlevel")
		end
	end
end
function this.animBack(func, x1, x2)
	this.anim = {prog = 0, back=100, per=0}
	this.animt = Tween.new(0.7, this.anim, {prog=love.window.getHeight(), back=0, per=1}, "inCubic")
	local funct
	if type(func) == "string" then
		funct = function() print(func) StateManager.setState(func, x1, x2) end
	end
	this.afterBack = funct or func
end
StateManager.registerState("lost", LostState)