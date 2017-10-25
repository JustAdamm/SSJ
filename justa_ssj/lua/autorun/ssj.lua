-- SSJ Colour
SSJ_Col = Color( 255, 157, 0 )

-- Add
if (SERVER) then
	AddCSLuaFile("ssj/cl_functionality.lua")
	include("ssj/sv_functionality.lua")
else
	include("ssj/cl_functionality.lua")
end