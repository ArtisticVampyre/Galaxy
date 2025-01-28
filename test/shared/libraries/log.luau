local log = {}

function log.print(message: string)
	print(message)
end

function log.info(message: string)
	print(`[INFO] {message}`)
end

function log.warn(message: string)
	print("[WARN] " .. message)
end

function log.error(message: string)
	print("[ERROR] " .. message)
end

function log.debug(message: string)
	print("[DEBUG] " .. message)
end

return log
