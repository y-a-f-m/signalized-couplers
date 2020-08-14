local interface = {}

function interface.set(setting, value)
	if global[setting] then
		global[setting]=value
	end
end

remote.add_interface("AutomaticCoupler", interface)