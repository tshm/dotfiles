return {
	entry = function(self, args)
		if #cx.tabs > 1 then
			ya.manager_emit("tab_switch", { 1, relative = true })
		else
			ya.manager_emit("tab_create", { current = true })
		end
	end,
}
