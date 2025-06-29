local state = {}
state._index = state

function state:init()
    self.refueling = false
    self.holding = "null"
end

function state:set(key, value)
    self[key] = value
end

return state