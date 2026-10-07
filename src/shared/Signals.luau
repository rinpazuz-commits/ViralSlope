local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signals = ReplicatedStorage:FindFirstChild("Signals")
if not Signals then
	Signals = Instance.new("Folder")
	Signals.Name = "Signals"
	Signals.Parent = ReplicatedStorage
end

return Signals