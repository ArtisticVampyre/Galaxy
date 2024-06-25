return function(condition, errorMessage)
	if not condition then
		error(errorMessage or "Assertion failed!", 2)
	end
	return condition
end
