-- easylua.StartEntity("sent_coin")

ENT.Base = "base_anim"
ENT.Type = "anim"

function ENT:Initialize()
	local scale = 0.05
	local origcoins = 5

	while self:GetCoins() > origcoins do
		scale = scale + 0.001
		origcoins = origcoins + 1
	end

	self:SetModel("models/hunter/tubes/circle2x2.mdl")
	self:SetColor(Color(255, 205, 0))
	self:SetModelScale(scale)
	self:SetMaterial("models/shiny")

	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	if SERVER then
		self:PhysicsInit(SOLID_VPHYSICS)
	end

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
	end
	self:Activate() -- fix collisions
end

function ENT:Touch(ent)
	if ent:IsPlayer() then
		ent:SetCoins(ent:GetCoins() + self:GetCoins())
		ent:EmitSound(Sound("ambient/office/coinslot1.wav"))
		self:Remove()
	end
end

function ENT:Draw()
	self:DrawModel()
end

function ENT:SetCoins(c)
	self.Coins = c
end

function ENT:GetCoins()
	return self.Coins
end

-- easylua.EndEntity("sent_coin")

