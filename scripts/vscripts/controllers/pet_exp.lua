if PetExpCtrl == nil then
	PetExpCtrl = RegisterController('pet_exp')
    setmetatable(PetExpCtrl, PetExpCtrl)
end

local public = PetExpCtrl

function public:init()
    self.pet_bonus_exp_tick_time = 60
    self.total_bonus_exp = 0
end

function public:Start()
    local GameMode = GameRules:GetGameModeEntity()
    GameMode:SetContextThink("PetExpCtrl", function() return self:OnThink() end, self.pet_bonus_exp_tick_time)
end

function public:OnThink()
    local gameTime = math.floor(GameManager:GetGameTime())
    self.total_bonus_exp = self.total_bonus_exp + gameTime * 1
    return self.pet_bonus_exp_tick_time
end

function public:GetTickTime()
    return self.pet_bonus_exp_tick_time
end

function public:GetTotalExp()
    return self.total_bonus_exp
end