-- easylua.StartWeapon("weapon_archerbow")

AddCSLuaFile()

SWEP.Base				= "weapon_base"

SWEP.PrintName			= "Archer Crossbow" -- What's the deal with the name? I'd call it Grappling Hook or something. -- Tenrys
SWEP.Author				= "Slade Xanthas"
SWEP.Category			= "Slade Xanthas"
SWEP.Slot				= 2
SWEP.SlotPos			= 3
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= true
SWEP.ViewModelFOV		= 65
SWEP.ViewModelFlip		= false
SWEP.HoldType			= "crossbow"
SWEP.Spawnable			= true
SWEP.AdminOnly			= false
SWEP.ViewModel			= "models/weapons/v_crossbow.mdl"
SWEP.WorldModel			= "models/weapons/w_crossbow.mdl"
SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.Charge = 0
SWEP.LastThink = CurTime()
SWEP.NextShot = CurTime()

function SWEP:Initialize()
	self:SetHoldType( self.HoldType )
end

function SWEP:Deploy()
	self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
	if IsValid(self.Owner:GetViewModel()) then
		self.NextShot = (CurTime() + self.Owner:GetViewModel():SequenceDuration())
	end
	self.Charge = 0
	return true
end

function SWEP:Holster()
	self.Charge = 0
	return true
end

function SWEP:Think()

	if self.LastThink < CurTime() then

		if self.NextShot < CurTime() then

			if self.Owner:KeyDown(IN_ATTACK) then

				if self.Charge < 100 then
					self.Charge = self.Charge + 5
				else
					self.Charge = 100
				end

			elseif self.Charge > 0 then

				if self.Charge <= 40 then
					self:CreateArrow("normal", self.Owner, self.Weapon)
					self.NextShot = CurTime()+0.5
				elseif self.Charge <= 80 then
					self:CreateArrow("fire", self.Owner, self.Weapon)
					self.NextShot = CurTime()+0.7
				elseif self.Charge <= 100 then
					self:CreateArrow("explosive", self.Owner, self.Weapon)
					self.NextShot = CurTime()+1.5
				end

				self.Charge = 0

				if !(game.SinglePlayer() and CLIENT) then
					self:EmitSound("weapons/crossbow/bolt_fly4.wav", 100, 100)
					self:EmitSound("weapons/crossbow/fire1.wav", 100, 100)
				end

				self.Owner:ViewPunch( Angle( math.Rand(-0.2,-0.1) * 10, math.Rand(-0.1,0.1) * 10, 0 ) )

			end

			if self.Owner:KeyDown(IN_ATTACK2) then

				self:CreateArrow("grapple", self.Owner, self.Weapon, self)
				self.NextShot = CurTime()+2
				self.Charge = 0

				if !(game.SinglePlayer() and CLIENT) then
					self:EmitSound("weapons/crossbow/bolt_fly4.wav", 100, 100)
					self:EmitSound("weapons/crossbow/fire1.wav", 100, 100)
				end

				self.Owner:ViewPunch( Angle( math.Rand(-0.2,-0.1) * 10, math.Rand(-0.1,0.1) * 10, 0 ) )

			end

		end

		self.LastThink = CurTime()+0.05

	end

end

function SWEP:CreateArrow(aType)

	if IsValid(self.Owner) and IsValid(self.Weapon) then

		if (SERVER) then

			local ent = ents.Create("rj_arrow")
			if !ent then return end
			ent.Owner = self.Owner
			ent.Arrowtype = aType
			ent.Inflictor = self.Weapon
			ent:SetOwner(self.Owner)
			local eyeang = self.Owner:GetAimVector():Angle()
			local right = eyeang:Right()
			local up = eyeang:Up()
			ent:SetPos(self.Owner:GetShootPos()+right*3-up*3)
			ent:SetAngles(self.Owner:GetAngles())
			ent:SetPhysicsAttacker(self.Owner)
			ent:Spawn()

			local phys = ent:GetPhysicsObject()
			if phys:IsValid() then
				if aType == "grapple" then
					phys:SetVelocity(self.Owner:GetAimVector() * 2500)
				else
					phys:SetVelocity(self.Owner:GetAimVector() * 1750)
				end
			end

			return ent

		end

	end

end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

function SWEP:Reload()
end

function SWEP:DrawHUD()

	local charge = self.Charge/100

	surface.SetDrawColor(0, 0, 0, 200)
	surface.DrawRect(ScrW()/2 - 105, (ScrH()/1.5) - 7.5, 210, 30)

	if self.Charge <= 40 then
		surface.SetDrawColor(255, 255, 255, 255)
	elseif self.Charge <= 80 then
		surface.SetDrawColor(255, 255, 0, 255)
	elseif self.Charge <= 100 then
		surface.SetDrawColor(255, 0, 0, 255)
	end

	surface.DrawRect(ScrW()/2 - 100, ScrH()/1.5, 200 * charge, 15)

end

////
//Arrow Entity
////

local ENT = {}
ENT.Type = "anim"

function ENT:SetupDataTables()
	self:DTVar( "Entity", 1, "Ent" )
	self:DTVar( "Bool", 1, "Grappled" )
	self:DTVar( "Bool", 2, "Collided" )
end

if CLIENT then

	ENT.Mat = Material("sprites/light_glow02_add")

	local function Arrow_Init(um)
		local aType = um:ReadString()
		local arrow = um:ReadEntity()

		if IsValid(arrow) then
			arrow.aType = aType
		end
	end
	usermessage.Hook("xbowarrowinit", Arrow_Init)


	function ENT:Draw()

		self:DrawModel()
		self:SetRenderBoundsWS( self:GetPos()+self:OBBMins()*100, self:GetPos()+self:OBBMaxs()*100 )

		if self.aType and self.aType == "fire" and !self.dt.Collided then
			render.SetMaterial(self.Mat)
			render.DrawSprite(self:GetPos(), 32, 32, Color(255,0,0,255)) //Totally not stolen from Zero.
		end

		if IsValid(self.dt.Ent) and self.dt.Ent:IsPlayer() and self.dt.Ent:Alive() and self.dt.Grappled then
			render.SetMaterial( Material( "cable/rope" ) )
			render.DrawBeam( self:GetPos(), self.dt.Ent:GetPos()+Vector(0,0,45), 2, 1, 32, Color( 255, 255, 255, 255 ) )
		end

	end

end

if SERVER then

	function ENT:Initialize()

		self.Hit = false
		self.LastSound = CurTime()

		self:SetModel("models/items/crossbowrounds.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
		self:SetMaterial("models/gibs/woodgibs/woodgibs03")
		self:DrawShadow(false)

		local phys = self:GetPhysicsObject()
		if (phys:IsValid()) then
			phys:Wake()
			phys:EnableDrag(false)
			phys:AddGameFlag(FVPHYSICS_NO_IMPACT_DMG)
			phys:AddGameFlag(FVPHYSICS_NO_PLAYER_PICKUP)
			phys:SetMass(1)
			phys:SetBuoyancyRatio(0)
			phys:EnableGravity(false)
		end

		if !self.Arrowtype then
			self.Arrowtype = "normal"
		end

		if self.Arrowtype and self.Arrowtype == "explosive" then
			self:SetColor(Color(255,0,0,255))
			self.Flame = ents.Create("env_fire_trail")
			self.Flame:SetPos(self:GetPos())
			self.Flame:Spawn()
			self.Flame:SetParent(self)
		elseif self.Arrowtype == "fire" then
			self:SetColor(Color(255,0,0,255))
			self.Trail = util.SpriteTrail(self, 0, Color(255,0,0), false, 20, 1, 1.5, 0.01, "trails/laser.vmt")
		elseif self.Arrowtype == "grapple" then
			self:SetColor(Color(0,255,0,255))
			self.Trail = util.SpriteTrail(self, 0, Color(0,255,0), false, 5, 1, 0.3, 0.01, "trails/laser.vmt")
		elseif self.Arrowtype == "normal" then
			self.Trail = util.SpriteTrail(self, 0, Color(255,255,255), false, 5, 1, 0.3, 0.01, "trails/laser.vmt")
		end

	end

	function ENT:Think()

		if IsValid(self.Owner) then
			self.dt.Ent = self.Owner
			else
			self.dt.Ent = self
		--else
		--	self:Remove()
		--	return
		end

		if self.PinData then

			local ent = self.PinData.Entity
			local rag = self.PinData.Entity
			local pos = self.PinData.Pos

			if IsValid(ent) and ent.Health and ent:Health()<=0 then

				if ent:GetMoveType() == MOVETYPE_VPHYSICS then
					rag = ents.Create("prop_physics")
				else
					rag = ents.Create("prop_ragdoll")
				end

				rag:SetModel(ent:GetModel())
				rag:SetPos(ent:GetPos())
				rag:SetAngles(ent:GetAngles())
				rag:SetColor(ent:GetColor())
				rag:SetMaterial(ent:GetMaterial())
				//rag:SetBodygroup(ent:GetBodygroup())
				rag:Spawn()
				rag:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
				rag:Fire("Kill",1,10)

				for i=0,rag:GetPhysicsObjectCount()-1 do --setup bone positions
					local bone = rag:TranslatePhysBoneToBone(i)
					local phys = rag:GetPhysicsObjectNum(i)
					if phys then
						local bpos,bang = ent:GetBonePosition(bone)
						if bpos then
							phys:SetPos(bpos)
						end
						if bang then
							phys:SetAngles(bang)
						end
						phys:SetVelocity(ent:GetVelocity())
					end
				end

				if self.PinData then
					if ent:IsNPC() then
						if IsValid(self.Owner) then

							ent:TakeDamage(1000,self.Owner,self.Owner)
						end
						ent:Remove()
					else
						ent:KillSilent()
					end
				end

			end

			if pos then

				local temptrace = {}
				temptrace.start = self:GetPos()
				temptrace.endpos = self:GetPos()+self:GetForward()*350
				temptrace.filter = {self, self.Owner, "rj_arrow"}
				temptrace.mask = MASK_SHOT-CONTENTS_SOLID
				local tr = util.TraceLine(temptrace)

				if IsValid(self) then
					self:SetPos(pos)
				end

				if IsValid(rag) then

					local bone = rag:GetPhysicsObjectNum(tr.PhysicsBone)

					if bone then
						bone:SetPos(pos)
						bone:EnableMotion(false)
						constraint.Weld(game.GetWorld(),rag,0,tr.PhysicsBone,0,false)
					end

					if self.Arrowtype == "fire" then
						rag:Ignite(10,25)
					end

				end

			end

			self.PinData = false

		end

		if !self.umsgSent then
			umsg.Start("xbowarrowinit")
				umsg.String(self.Arrowtype)
				umsg.Entity(self)
			umsg.End()

			self.umsgSent = true
		end

		if self.Arrowtype == "grapple" and self.dt.Grappled and IsValid(self.Owner) then

			if self.Owner:KeyDown(IN_JUMP) then
				local vecSub = self:GetPos()-self.Owner:GetPos()
				local vecNormal = vecSub:GetNormalized()
				local vecFinal = (self.Owner:GetVelocity() + vecNormal - self.Owner:GetVelocity()) * 50 //Note to self: Instantaneous velocity on players can be reached by subtracting the original player velocity after adding the velocity to be set to
				self.Owner:SetVelocity(vecFinal)
			end

			if self.Owner:KeyDown(IN_RELOAD) or ( self.Owner:IsPlayer() and !self.Owner:Alive() and self.Hit ) then
				self.dt.Grappled = false
				self:EmitSound("physics/metal/metal_sheet_impact_bullet"..math.random(1,2)..".wav")
				if self.Owner:Alive() then
					self.Owner:EmitSound("weapons/crossbow/reload1.wav")
				end
			end

		end

		self:NextThink(CurTime())
		return true

	end

	function ENT:PhysicsUpdate(phys)

		if !self.Hit then

			self:SetLocalAngles(phys:GetVelocity():Angle())

			local vel = Vector(0,0,0)

			if self:WaterLevel() <= 0 then
				vel = Vector(0,0,-3)
			else
				vel = Vector(0,0,-1.5)
			end

			phys:AddVelocity(vel)

		end

	end

	function ENT:PhysicsCollide(data, physobj)

		local trace = {}
		trace.start = self:GetPos()
		trace.endpos = data.HitPos
		trace.filter = {self, self.Owner}
		trace.mask = MASK_SHOT
		trace.mins = self:OBBMins()
		trace.maxs = self:OBBMaxs()
		local tr = util.TraceHull(trace)
		local ent = data.HitEntity

		if tr.HitSky or !self:IsInWorld() then self:Remove() end

		if IsValid(self) and self.Arrowtype and !self.Hit then

			if IsValid(self.Trail) then self.Trail:Fire("kill", 1, 2) end
			if IsValid(self.Flame) then self.Flame:Fire("kill") end

			self.dt.Collided = true

			self:SetSolid(SOLID_NONE)
			self:SetMoveType(MOVETYPE_NONE)

			if IsValid(ent) and !data.HitEntity:IsWorld() then

				if IsValid(self.Owner) then ent.FireCreditor = self.Owner end

				if !ent:IsPlayer() and !ent:IsNPC() and ent:GetClass() ~= "rj_arrow" then
					self:SetPos(data.HitPos)
					self:SetParent(ent)
				end

			end

			if self.Arrowtype ~= "explosive" then

				if tr.Hit then

					local ef = EffectData()
					ef:SetStart(self:GetVelocity():GetNormalized()*-1)
					ef:SetOrigin(data.HitPos)

					if (tr.MatType == MAT_BLOODYFLESH) or (tr.MatType == MAT_FLESH) then
						util.Effect("BloodImpact", ef)
						self:EmitSound("physics/flesh/flesh_impact_bullet"..math.random(1,5)..".wav", 80, 100)
						self:EmitSound("weapons/crossbow/hitbod"..math.random(1,2)..".wav", 90, 100)
					elseif (tr.MatType == MAT_CONCRETE) then
						util.Effect("GlassImpact", ef)
						self:EmitSound("physics/concrete/concrete_impact_bullet"..math.random(1,4)..".wav", 80, 100)
					elseif (tr.MatType == MAT_PLASTIC) then
						util.Effect("GlassImpact", ef)
						self:EmitSound("physics/plastic/plastic_box_impact_hard"..math.random(1,4)..".wav", 80, 100)
					elseif (tr.MatType == MAT_GLASS) or (tr.MatType == MAT_TILE) then
						util.Effect("GlassImpact", ef)
						self:EmitSound("physics/concrete/concrete_impact_bullet"..math.random(1,4)..".wav", 80, 100)
					elseif (tr.MatType == MAT_METAL) or (tr.MatType == MAT_GRATE) then
						util.Effect("MetalSpark", ef)
						self:EmitSound("physics/metal/metal_solid_impact_bullet"..math.random(1,4)..".wav", 80, 100)
					elseif (tr.MatType == MAT_WOOD) then
						util.Effect("SmallImpact", ef)
						self:EmitSound("physics/wood/wood_solid_impact_bullet"..math.random(1,5)..".wav", 80, 100)
					elseif (tr.MatType == MAT_DIRT) or (tr.MatType == MAT_SAND) then
						util.Effect("SmallImpact", ef)
						self:EmitSound("physics/surfaces/sand_impact_bullet"..math.random(1,4)..".wav", 80, 100)
					end

				end

				if ent:IsWorld() then
					self:EmitSound("physics/metal/sawblade_stick"..math.random(1,3)..".wav", 90, 100)
					else
					self:EmitSound("weapons/crossbow/hitbod"..math.random(1,2)..".wav", 90, 100)
				end

			end

			local dmg = DamageInfo()

			if IsValid(self.Owner) then
				dmg:SetAttacker(self.Owner)
			else
				dmg:SetAttacker(self)
			end

			if IsValid(self.Inflictor) then
				dmg:SetInflictor(self.Inflictor)
				else
				dmg:SetInflictor(self)
			end

			dmg:SetDamagePosition(data.HitPos)
			dmg:SetDamageForce(vector_origin)

			if self.Arrowtype == "explosive" then

				util.ScreenShake( self:GetPos(), 50, 50, 1, 200 )

				if IsValid(self.Inflictor) then
					util.BlastDamage(self.Inflictor, self.Owner, self:GetPos(), 130, 70)
					else
					util.BlastDamage(self, self.Owner, self:GetPos(), 130, 70)
				end

				efdata = EffectData()
				efdata:SetOrigin(self:GetPos())
				util.Effect("Explosion", efdata)

				self:Remove()

			elseif self.Arrowtype == "normal" then

				dmg:SetDamage(40)

			elseif self.Arrowtype == "grapple" then

				self.dt.Grappled = true
				self:EmitSound("weapons/tripwire/hook.wav", 90, 100)
				self:Fire("kill", 1, 15)

			elseif self.Arrowtype == "fire" then

				dmg:SetDamage(80)
				dmg:SetDamageType(DMG_DIRECT)
				self:Ignite(10,0)

				if IsValid(ent) then
					if ((ent:IsNPC() or ent:IsPlayer()) and !self.PinData) then
						ent:Ignite(2,25)
					elseif (!ent:IsNPC() and !ent:IsPlayer()) then
						ent:Ignite(10,25)
					end
					self:EmitSound("weapons/crossbow/bolt_skewer1.wav", 90, 100)
				end

			end

			if !self:GetParent():IsValid() and data.HitEntity:IsWorld() then
				self:SetPos(data.HitPos)
			end

			if IsValid(ent) then

				if ent:IsNPC() or ent:IsPlayer() then

					local tracew = {}
					tracew.start = self:GetPos()
					tracew.endpos = self:GetPos()+self:GetForward()*350
					tracew.mask = MASK_SOLID_BRUSHONLY
					local trw = util.TraceLine(tracew)

					if ent:Health() <= dmg:GetDamage() and trw.Hit then
						local pos = data.HitPos
						offpos = pos - ( data.HitPos - trw.HitPos )

						self.PinData = {}
						self.PinData.Entity = ent
						self.PinData.Pos = offpos
					end

					if !self.PinData then
						self:Remove()
					end

				end

				if !self.PinData then
					ent:TakeDamageInfo(dmg)
				end

			end

			self.Hit = true
			self:Fire("kill", 1, 60)

		end

	end

	local function FireKillCredit(ent,dmginfo)
		local attacker = dmginfo:GetAttacker()
		local inflictor = dmginfo:GetInflictor()
		if IsValid(attacker) and (attacker == inflictor) then
			if attacker:GetClass() == "entityflame" and IsValid(ent.FireCreditor) then
				dmginfo:SetInflictor(attacker)
				dmginfo:SetAttacker(ent.FireCreditor)
			end
		end
	end
	hook.Add("EntityTakeDamage","FireArrowCredit",FireKillCredit)

	local function DenyArrowMoving(ply, ent)
		if ent:GetClass() == "rj_arrow" then return false end
	end
	hook.Add("PhysgunPickup", "DenyArrowPhysGunning", DenyArrowMoving)

end

scripted_ents.Register( ENT, "rj_arrow", true )

////
//Arrow Impact Effect
////

if CLIENT then

	local EFFECT = {}

	function EFFECT:Init(ed)

		local vOrig = ed:GetOrigin()
		local pe = ParticleEmitter(vOrig)

		for i=1,4 do

			local part = pe:Add("particle/particle_smokegrenade", vOrig)

			if (part) then

				part:SetColor(50, 50, 50)
				part:SetVelocity(VectorRand():GetNormal()*math.random(20, 40))
				part:SetRoll(math.Rand(0, 360))
				part:SetRollDelta(math.Rand(-2, 2))
				part:SetDieTime(1)
				part:SetStartSize(5)
				part:SetStartAlpha(255)
				part:SetEndSize(15)
				part:SetEndAlpha(0)
				part:SetGravity(Vector(0,0,-90))

			end

		end

		pe:Finish()

	end

	function EFFECT:Think()
		return false
	end

	function EFFECT:Render()
	end

	effects.Register(EFFECT, "SmallImpact", true)

end

-- easylua.EndWeapon(false,false)

