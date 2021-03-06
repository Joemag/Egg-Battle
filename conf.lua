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

function love.conf( t )
	t.title = "Egg Battle"
	t.window.vsync = true
	t.window.icon = "gfx/icon.png"
	t.console = false
	t.window.resizable = true
	t.window.width = 1080/3
	t.window.height = 1794/3
end