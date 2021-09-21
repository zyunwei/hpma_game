if Queue == nil then
    Queue = class({})
end

local public = Queue

function public:constructor()
    self:clear()
end

function public:push_back(value)
    self.last = self.last + 1
    self.list[self.last] = value
end

function public:push_front(value)
    self.first = self.first - 1
    self.list[self.first] = value
end

function public:empty()
    if self.last < self.first then
        return true
    end
    return false
end

function public:pop_back()
    if self:empty() then
        return nil
    end
    local value = self.list[self.last]
    self.list[self.last] = nil
    self.last = self.last - 1
    return value
end

function public:pop_front()
    if self:empty() then
        return nil
    end
    local value = self.list[self.first]
    self.list[self.first] = nil
    self.first = self.first + 1
    return value
end

function public:clear()
    self.list = {}
    self.first = 0
    self.last = -1
end

function public:to_list()
    local result = {}
    for i = self.first, self.last do
        table.insert(result, self.list[i])
    end
    return result
end