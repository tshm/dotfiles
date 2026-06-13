--- @sync entry
return {
	entry = function(self, args)
		if #cx.tabs > 1 then
			ya.emit("tab_switch", { 1, relative = true })
		else
			ya.emit("tab_create", { current = true })
		end
	end,
}
