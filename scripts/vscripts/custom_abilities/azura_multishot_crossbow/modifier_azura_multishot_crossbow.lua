modifier_azura_multishot_crossbow = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_azura_multishot_crossbow:IsHidden()
	return false
end

function modifier_azura_multishot_crossbow:IsDebuff()
	return false
end

function modifier_azura_multishot_crossbow:IsPurgable()
	return false
end

function modifier_azura_multishot_crossbow:DestroyOnExpire()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_azura_multishot_crossbow:OnCreated( kv )
	if IsServer() then
		-- references
		self.max_charge = self:GetAbility():GetSpecialValueFor( "max_charge" )
		self.bat_override = self:GetAbility():GetSpecialValueFor( "bat_override" )

		-- set current stack
		self:SetStackCount(self.max_charge)

		-- set base attack time
		self:GetParent():SetBaseAttackTime( self.bat_override )

		-- run stat bonus
		self:GetAbility():OnHeroCalculateStatBonus()
	end
end

function modifier_azura_multishot_crossbow:OnRefresh( kv )
	if IsServer() then
		-- references
		self.max_charge = self:GetAbility():GetSpecialValueFor( "max_charge" )
		self.bat_override = self:GetAbility():GetSpecialValueFor( "bat_override" )

		-- calculate charge
		self:CalculateCharge()
	end
end

function modifier_azura_multishot_crossbow:OnDestroy( kv )

end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_azura_multishot_crossbow:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK,
		-- MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
	}

	return funcs
end

function modifier_azura_multishot_crossbow:OnAttack( params )
	if IsServer() then
		-- filter
		local pass = false
		if params.attacker == self:GetParent() then
			pass = true
		end

		-- logic
		if pass then
			self:RemoveStack( 1 )
		end
	end
end

-- function modifier_azura_multishot_crossbow:GetModifierBaseAttackTimeConstant( params )
-- 	if self:GetStackCount()==0 then
-- 		return 10
-- 	else
-- 		return 0
-- 	end
-- end
--------------------------------------------------------------------------------
-- Status Effects
function modifier_azura_multishot_crossbow:CheckState()
	local state = {
	[MODIFIER_STATE_DISARMED] = (self:GetStackCount()==0),
	}

	return state
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_azura_multishot_crossbow:OnIntervalThink()
	if IsServer() then
		self:StartIntervalThink( -1 )
		self:AddStack( 1 )
	end
end

--------------------------------------------------------------------------------
-- Helper Functions
function modifier_azura_multishot_crossbow:AddStack( value )
	self:SetStack( self:GetStackCount() + value )
end
function modifier_azura_multishot_crossbow:RemoveStack( value )
	self:SetStack( self:GetStackCount() - value )
end

function modifier_azura_multishot_crossbow:SetStack( value )
	if value > self.max_charge then
		self:SetStackCount( self.max_charge )
	elseif value < 0 then
		self:SetStackCount( 0 )
	else
		self:SetStackCount( value )
	end

	self:CalculateCharge()
end

function modifier_azura_multishot_crossbow:CalculateCharge()
	if self:GetStackCount()==self.max_charge then
		-- stop duration
		self:SetDuration( 0, false )

		-- stop charging
		self:StartIntervalThink( -1 )
	else
		-- if not charging
		if self:GetRemainingTime() <= 0.05 then
			-- start charging
			local charge_time = self:GetAbility().recharge_time
			self:StartIntervalThink( charge_time )
			self:SetDuration( charge_time, true )
		end
	end
end

--------------------------------------------------------------------------------
-- Graphics & Animations
-- function modifier_azura_multishot_crossbow:GetEffectName()
-- 	return "particles/string/here.vpcf"
-- end

-- function modifier_azura_multishot_crossbow:GetEffectAttachType()
-- 	return PATTACH_XX
-- end
