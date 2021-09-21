
--@class CDOTA_Item

local public = CDOTA_Item

-- 设置属性
function public:SetCustomAttribute(name, value)
	if self.__CustomAttributes == nil then
		self.__CustomAttributes = {}
	end
	self.__CustomAttributes[name] = value

	DelayDispatch(0.06, self:GetEntityIndex(), self.UpdateCustomAttribute, self)
end

function public:HasCustomAttributes()
	return self.__CustomAttributes ~= nil
end

-- 设置属性
function public:SetCustomAttributeFromTable(t)
	if not t then return end
	for k,v in pairs(t) do
		self:SetCustomAttribute(k, v)
	end
end

-- 获取属性
function public:GetCustomAttribute(name,defaultValue)
	if self.__CustomAttributes == nil then
		self.__CustomAttributes = {}
	end
	
	local value = self.__CustomAttributes[name] or (defaultValue or 0)

	return value 
end

-- 修改属性
function public:ModifyCustomAttribute(name, value)
	local oldValue = self:GetCustomAttribute(name)

	oldValue = oldValue + value

	self:SetCustomAttribute(name, oldValue)
end

-- 获取所有属性
function public:GetAllCustomAttribute()
	return self.__CustomAttributes
end

-- 更新
function public:UpdateCustomAttribute()
	if self ~= nil and self:IsNull() == false then
		CustomNetTables:SetTableValue("CustomAttributes", tostring(self:GetEntityIndex()),self:GetAllCustomAttribute())
	end
end

