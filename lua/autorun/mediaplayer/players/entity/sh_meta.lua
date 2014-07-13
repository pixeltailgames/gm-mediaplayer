--[[---------------------------------------------------------
	Media Player Entity Meta
-----------------------------------------------------------]]

local EntityMeta = FindMetaTable("Entity")
if not EntityMeta then return end

function EntityMeta:GetMediaPlayer()
	return self._mp
end

--
-- Installs a media player reference to the entity.
--
-- @param Table|String	mp	Media player table or string type.
function EntityMeta:InstallMediaPlayer( mp )
	if not istable(mp) then
		local mpType = isstring(mp) and mp or "entity"

		if not MediaPlayer.IsValidType(mpType) then
			ErrorNoHalt("ERROR: Attempted to install invalid mediaplayer type onto an entity!\n")
			ErrorNoHalt("ENTITY: " .. tostring(self) .. "\n")
			ErrorNoHalt("TYPE: " .. tostring(mpType) .. "\n")
			mpType = "entity" -- default
		end

		local mpId = "Entity" .. self:EntIndex()
		mp = MediaPlayer.Create( mpId, mpType )
	end

	self._mp = mp
	self._mp:SetEntity(self)

	if isfunction(self.SetupMediaPlayer) then
		self:SetupMediaPlayer(mp)
	end

	return mp
end

local DefaultConfig = {
	offset	= Vector(0,0,0),	-- translation from entity origin
	angle	= Angle(0,0,0),		-- rotation
	-- attachment = "corner"	-- attachment name
	width = 64,					-- screen width
	height = 64 * 9/16			-- screen height
}

function EntityMeta:GetMediaPlayerPosition()
	local cfg = self.PlayerConfig or DefaultConfig

	local w = (cfg.width or DefaultConfig.width)
	local h = (cfg.height or DefaultConfig.height)

	local pos, ang

	if cfg.attachment then
		local idx = self:LookupAttachment(cfg.attachment)
		if not idx then
			local err = string.format("MediaPlayer:Entity.Draw: Invalid attachment '%s'\n", cfg.attachment)
			Error(err)
		end

		-- Get attachment orientation
		local attach = self:GetAttachment(idx)
		pos = attach.pos
		ang = attach.ang
	else
		pos = self:GetPos() -- TODO: use GetRenderOrigin?
	end

	-- Apply offset
	if cfg.offset then
		pos = pos +
			self:GetForward() * cfg.offset.x +
			self:GetRight() * cfg.offset.y +
			self:GetUp() * cfg.offset.z
	end

	-- Set angles
	ang = ang or self:GetAngles() -- TODO: use GetRenderAngles?
	ang:RotateAroundAxis( ang:Right(), cfg.angle.p )
	ang:RotateAroundAxis( ang:Up(), cfg.angle.y )
	ang:RotateAroundAxis( ang:Forward(), cfg.angle.r )

	return w, h, pos, ang
end
