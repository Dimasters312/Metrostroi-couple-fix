if SERVER then
	timer.Simple(0,function()
		if not Metrostroi then return end
		MsgC(Color(0,255,0),'Metrostroi Couple Fix.\n')
		timer.Simple(1,function()
			local couple = scripted_ents.Get("gmod_train_couple")
			if couple then
				function couple:Couple(ent)
					local strain = self:GetNW2Entity("TrainEntity")
					local etrain = ent:GetNW2Entity("TrainEntity")
					if IsValid(strain) then
						self:SetAngles(strain:LocalToWorldAngles(self.SpawnAng))
					end
					if IsValid(etrain) then
						ent:SetAngles(etrain:LocalToWorldAngles(ent.SpawnAng))
					end
					local MCouplingPointOffset = (ent.CouplingPointOffset+self.CouplingPointOffset)/2
					ent:SetPos(self:LocalToWorld(MCouplingPointOffset*Vector(2,1,1)))
					ent:SetAngles(self:LocalToWorldAngles(Angle(0,180,0)))
					self:SetPos(ent:LocalToWorld(MCouplingPointOffset*Vector(2,-1,-1)))
					self:SetAngles(ent:LocalToWorldAngles(Angle(0,180,0)))
					if IsValid(constraint.Weld(
						self,
						ent,
						0,
						0,
						0
					)) then
						sound.Play(Metrostroi.CustomCouplingSound or "subway_trains/bogey/couple.mp3",(self:GetPos()+ent:GetPos())/2,70,100,1)
						self:OnCouple(ent)
						ent:OnCouple(self)
					end
				end
				function couple:Use(ply)
					local train = self:GetNW2Entity("TrainEntity")
					local isfront = self:GetNW2Bool("IsForwardCoupler")
					net.Start("metrostroi-coupler-menu")
						net.WriteEntity(self)
						net.WriteBool(not self.CPPICanUse or self:CPPICanUse(ply))
						net.WriteBool(self.CoupledEnt ~= nil)
						if IsValid(train) then
							if isfront and train.FrontBrakeLineIsolation and train.FrontTrainLineIsolation then
								net.WriteBool(true)
								net.WriteBool(train.FrontBrakeLineIsolation.Value>0 and train.FrontTrainLineIsolation.Value>0)
								net.WriteBool(train.SubwayTrain.NoFrontEKK)
							elseif not isfront and train.RearBrakeLineIsolation and train.RearTrainLineIsolation then
								net.WriteBool(true)
								net.WriteBool(train.RearBrakeLineIsolation.Value>0 and train.RearTrainLineIsolation.Value>0)
								net.WriteBool(self.CoupleType=="722")
							else
								net.WriteBool(false)
								net.WriteBool(false)
								net.WriteBool(self.CoupleType=="722")
							end
						else
							net.WriteBool(false)
							net.WriteBool(false)
							net.WriteBool(self.CoupleType=="722")
						end
						net.WriteBool(self.EKKDisconnected)
					net.Send(ply)
				end
				scripted_ents.Register(couple,"gmod_train_couple")
			end
		end)
	end)
end