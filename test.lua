local Stats = game:GetService('Stats')

local Players = game:GetService('Players')

local RunService = game:GetService('RunService')

local ReplicatedStorage = game:GetService('ReplicatedStorage')

local TweenService = game:GetService('TweenService')

local Nurysium_Util = loadstring(game:HttpGet('https://raw.githubusercontent.com/flezzpe/Nurysium/main/nurysium_helper.lua'))()

local local_player = Players.LocalPlayer

local camera = workspace.CurrentCamera

local nurysium_Data = nil

local hit_Sound = nil

local closest_Entity = nil

local parry_remote = nil

getgenv().aura_Enabled = false

getgenv().hit_sound_Enabled = false

getgenv().hit_effect_Enabled = false

getgenv().night_mode_Enabled = false

getgenv().trail_Enabled = false

getgenv().self_effect_Enabled = false

getgenv().kill_effect_Enabled = false

getgenv().shaders_effect_Enabled = false

getgenv().ai_Enabled = false

getgenv().spectate_Enabled = false

local Services = {

	game:GetService('AdService'),

	game:GetService('SocialService')

}

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Pan Hub" .. Fluent.Version,
    SubTitle = "by Borg and Triple Script",
    TabWidth = 160,
    Size = UDim2.fromOffset(450, 300),
    Acrylic = true, -- The blur may be detectable, setting this to false disables blur entirely
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl -- Used when theres no MinimizeKeybind
})
--Fluent provides Lucide Icons https://lucide.dev/icons/ for the tabs, icons are optional
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "" }),
    Credit = Window:AddTab({ Title = "Credit", Icon = "settings" })
}

function initializate(dataFolder_name: string)

	local nurysium_Data = Instance.new('Folder', game:GetService('CoreGui'))

	nurysium_Data.Name = dataFolder_name

	hit_Sound = Instance.new('Sound', nurysium_Data)

	hit_Sound.SoundId = 'rbxassetid://6607204501'

	hit_Sound.Volume = 6

end

local function get_closest_entity(Object: Part)

	task.spawn(function()

		local closest

		local max_distance = math.huge

		for index, entity in workspace.Alive:GetChildren() do

			if entity.Name ~= Players.LocalPlayer.Name then

				local distance = (Object.Position - entity.HumanoidRootPart.Position).Magnitude

				if distance < max_distance then

					closest_Entity = entity

					max_distance = distance

				end

			end

		end

		return closest_Entity

	end)

end

local function get_center()

	for _, object in workspace.Map:GetDescendants() do

		if object.Name == 'BALLSPAWN' then

			return object

		end

	end

end

function resolve_parry_Remote()

	for _, value in Services do

		local temp_remote = value:FindFirstChildOfClass('RemoteEvent')

		if not temp_remote then

			continue

		end

		if not temp_remote.Name:find('\n') then

			continue

		end

		parry_remote = temp_remote

	end

end

    local Toggle = Tabs.Main:AddToggle("Auto Parry", {Title = "Auto Parry", Default = false })

    Toggle:OnChanged(function(toggled)
    
    resolve_parry_Remote()

	getgenv().aura_Enabled = toggled

        print("Toggle changed:", Options.Auto Parry.Value)
    end)

    Options.Auto Parry:SetValue(false)
    
    local Toggle = Tabs.Main:AddToggle("Hit sound", {Title = "Hit sound", Default = false })

    Toggle:OnChanged(function(toggled)
    
    getgenv().hit_sound_Enabled = toggled
    
        print("Toggle changed:", Options.Hit sound.Value)
    end)

    Options.Hit sound:SetValue(false)
    
    local Toggle = Tabs.Main:AddToggle("Hit effect", {Title = "Hit effect", Default = false })

    Toggle:OnChanged(function(toggled)
    
    getgenv().hit_effect_Enabled = toggled
    
        print("Toggle changed:", Options.Hiteffect.Value)
    end)

    Options.HitEffect:SetValue(false)
    
    local Toggle = Tabs.Main:AddToggle("nightmode", {Title = "nightmode", Default = false })

    Toggle:OnChanged(function(toggled)
    
    getgenv().night_mode_Enabled = toggled
    
        print("Toggle changed:", Options.nightmode.Value)
    end)

    Options.nightmode:SetValue(false)
    
    task.defer(function()

    while task.wait(1) do

        if getgenv().night_mode_Enabled then

            game:GetService("TweenService"):Create(game:GetService("Lighting"), TweenInfo.new(3), {ClockTime = 3.9}):Play()

        else

            game:GetService("TweenService"):Create(game:GetService("Lighting"), TweenInfo.new(3), {ClockTime = 13.5}):Play()

        end

    end

end)

task.spawn(function()

    RunService.PreRender:Connect(function()

        if not getgenv().aura_Enabled then

            return

        end

        if closest_Entity then

            if workspace.Alive:FindFirstChild(closest_Entity.Name) and workspace.Alive:FindFirstChild(closest_Entity.Name).Humanoid.Health > 0 then

                if aura_table.is_Spamming then

                    if local_player:DistanceFromCharacter(closest_Entity.HumanoidRootPart.Position) <= aura_table.spam_Range then   

                        parry_remote:FireServer(

                            0.5,

                            CFrame.new(camera.CFrame.Position, Vector3.zero),

                            {[closest_Entity.Name] = closest_Entity.HumanoidRootPart.Position},

                            {closest_Entity.HumanoidRootPart.Position.X, closest_Entity.HumanoidRootPart.Position.Y},

                            false

                        )

                    end

                end

            end

        end

    end)

    RunService.Heartbeat:Connect(function()

        if not getgenv().aura_Enabled then

            return

        end

        local ping = Stats.Network.ServerStatsItem['Data Ping']:GetValue() / 10

        local self = Nurysium_Util.getBall()

        if not self then

            return

        end

        self:GetAttributeChangedSignal('target'):Once(function()

            aura_table.canParry = true

        end)

        if self:GetAttribute('target') ~= local_player.Name or not aura_table.canParry then

            return

        end

        get_closest_entity(local_player.Character.PrimaryPart)

        local player_Position = local_player.Character.PrimaryPart.Position

        local ball_Position = self.Position

        local ball_Velocity = self.AssemblyLinearVelocity

        if self:FindFirstChild('zoomies') then

            ball_Velocity = self.zoomies.VectorVelocity

        end

        local ball_Direction = (local_player.Character.PrimaryPart.Position - ball_Position).Unit

        local ball_Distance = local_player:DistanceFromCharacter(ball_Position)

        local ball_Dot = ball_Direction:Dot(ball_Velocity.Unit)

        local ball_Speed = ball_Velocity.Magnitude

        local ball_speed_Limited = math.min(ball_Speed / 1000, 0.1)

        local ball_predicted_Distance = (ball_Distance - ping / 15.5) - (ball_Speed / 3.5)

        local target_Position = closest_Entity.HumanoidRootPart.Position

        local target_Distance = local_player:DistanceFromCharacter(target_Position)

        local target_distance_Limited = math.min(target_Distance / 10000, 0.1)

        local target_Direction = (local_player.Character.PrimaryPart.Position - closest_Entity.HumanoidRootPart.Position).Unit

        local target_Velocity = closest_Entity.HumanoidRootPart.AssemblyLinearVelocity

        local target_isMoving = target_Velocity.Magnitude > 0

        local target_Dot = target_isMoving and math.max(target_Direction:Dot(target_Velocity.Unit), 0)

        aura_table.spam_Range = math.max(ping / 10, 15) + ball_Speed / 7

        aura_table.parry_Range = math.max(math.max(ping, 4) + ball_Speed / 3.5, 9.5)

        aura_table.is_Spamming = aura_table.hit_Count > 1 or ball_Distance < 13.5

        if ball_Dot < -0.2 then

            aura_table.ball_Warping = tick()

        end

        task.spawn(function()

            if (tick() - aura_table.ball_Warping) >= 0.15 + target_distance_Limited - ball_speed_Limited or ball_Distance <= 10 then

                aura_table.is_ball_Warping = false

                return

            end

            aura_table.is_ball_Warping = true

        end)

        if ball_Distance <= aura_table.parry_Range and not aura_table.is_Spamming and not aura_table.is_ball_Warping then

            parry_remote:FireServer(

                0.5,

                CFrame.new(camera.CFrame.Position, Vector3.new(math.random(0, 100), math.random(0, 1000), math.random(100, 1000))),

                {[closest_Entity.Name] = target_Position},

                {target_Position.X, target_Position.Y},

                false

            )

            aura_table.canParry = false

            aura_table.hit_Time = tick()

            aura_table.hit_Count += 1

            task.delay(0.15, function()

                aura_table.hit_Count -= 1

            end)

        end

        task.spawn(function()

            repeat

                RunService.Heartbeat:Wait()

            until (tick() - aura_table.hit_Time) >= 1

                aura_table.canParry = true

        end)

    end)

end)

initializate('nurysium_temp')