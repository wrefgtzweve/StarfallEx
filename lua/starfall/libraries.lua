---------------------------------------------------------------------
-- SF Global Library management
---------------------------------------------------------------------

SF.Libraries = {}

SF.Libraries.libraries = {}
SF.Libraries.hooks = {}

--- Creates and registers a global library. The library will be accessible from any Starfall Instance, regardless of context.
-- This will automatically set __index and __metatable.
-- @param name The library name
function SF.Libraries.Register(name)
	local methods, metamethods = {}, {}
	SF.Libraries.libraries[ name ] = {methods, metamethods}
	return methods, metamethods
end

--- Builds an environment table
-- @return The environment
function SF.Libraries.BuildEnvironment()
	local function deepCopy(src, dst, done)
		if done[src] then return end
		done[src] = true
		for k, v in pairs(src) do
			if type(v)=="table" then
				local t = setmetatable({}, debug.getmetatable(v))
				deepCopy(v, t, done)
				dst[k] = t
			else
				dst[k] = v
			end
		end
		done[src] = nil
	end
	
	local env = {}
	deepCopy(SF.DefaultEnvironment, env, {})
	
	for k, v in pairs(SF.Libraries.libraries) do
		local t = setmetatable({},v[2])
		deepCopy(v[1], t, {})
		env[k] = t
	end
	return env
end

--- Registers a library hook. These hooks are only available to SF libraries,
-- and are called by Libraries.CallHook.
-- @param hookname The name of the hook.
-- @param func The function to call
function SF.Libraries.AddHook(hookname, func)
	local hook = SF.Libraries.hooks[hookname]
	if not hook then
		hook = {}
		SF.Libraries.hooks[hookname] = hook
	end
	
	hook[#hook+1] = func
end

--- Calls a library hook.
-- @param hookname The name of the hook.
-- @param ... The arguments to the functions that are called.
function SF.Libraries.CallHook(hookname, ...)
	local hook = SF.Libraries.hooks[hookname]
	if not hook then return end
	
	for i=1,#hook do
		hook[i](...)
	end
end
