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
	this.setButtons()
end
function LostState.draw()
	love.graphics.setColor(0,0,0,100)
	love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
	love.graphics.setColor(0,0,0,255)
	love.graphics.print("No moves left", (love.graphics.getWidth()-font:getWidth("No moves left"))/2+1, love.graphics.getHeight()/2-150*pixelscale+1)
	love.graphics.setColor(255,255,255,255)
	love.graphics.print("No moves left", (love.graphics.getWidth()-font:getWidth("No moves left"))/2, love.graphics.getHeight()/2-150*pixelscale)
	
	this.buttons:draw()
end

function LostState.mousepressed(x, y, button)
	local clickedbutton = this.buttons:getClickedButton(x, y)
	if clickedbutton == "tryagain" then
		loadLevel(clvl.level)
	end
	if clickedbutton == "skip" and canPlayLevel(clvl.level+1, true) then
		loadLevel(clvl.level+1)
	end
	if clickedbutton == "menu" then
		StateManager.setState("menu")
	end
end
function LostState.resize()
	this.setButtons()
end
function this.setButtons()
	this.buttons:removeAllButtons()
	this.buttons:addCenterButton("tryagain", "Try again", love.graphics.getHeight()/2-120*pixelscale)
	if canPlayLevel(clvl.level+1, true) then
		this.buttons:addCenterButton("skip", "Skip level", love.graphics.getHeight()/2)
	end
	this.buttons:addCenterButton("menu", "Return to menu", love.graphics.getHeight()/2+60*pixelscale)
end
StateManager.registerState("lost", LostState)