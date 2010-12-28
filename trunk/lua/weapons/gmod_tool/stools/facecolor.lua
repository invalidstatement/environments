------------------------------------------
//     SpaceRP     //
//   CmdrMatthew   //
------------------------------------------

TOOL.Category       = "Render"
TOOL.Name           = "Surface Color"
TOOL.Command        = nil
TOOL.ConfigName     = nil
 
TOOL.ClientConVar[ "r" ] = 255
TOOL.ClientConVar[ "g" ] = 0
TOOL.ClientConVar[ "b" ] = 255
TOOL.ClientConVar[ "a" ] = 255
TOOL.ClientConVar[ "material" ] = ""
 
local DefMat = nil
if(CLIENT) then
    language.Add("Tool_surfacecolor_name", "Surface Color")
    language.Add("Tool_surfacecolor_desc", "Changes a surface's color or render mode")
    language.Add("Tool_surfacecolor_0", "Left click to apply color, Right click to remove")
    DefMat = Material("")
end
 
function table.index(tab, val)
    for k,v in pairs(tab) do
        if(v == val) then
            return k
        end
    end
end
 
local Clips, Unclipped = {}, {}
 
local function SetColor( Entity, Data )
    if ( Data.Color and Data.Norm and Data.Pos and Data.Material and CLIENT) then
        local tab = {}
        tab.Ent = Entity
        tab.Norm = Entity:WorldToLocal(Entity:GetPos() + Data.Norm)
        tab.Pos = Entity:WorldToLocal(Data.Pos - (Data.Norm*0.1))
        tab.OldColor = {r = Data.OldColor.r/255, g = Data.OldColor.g/255, b = Data.OldColor.b/255, a = Data.OldColor.a/255}
        tab.Color = {r = Data.Color.r/255, g = Data.Color.g/255, b = Data.Color.b/255, a = Data.Color.a/255}
        tab.OldMaterial = Material(Data.OldMaterial)
        tab.OldMatStr = Data.OldMaterial
        tab.Material = Material(Data.Material)
        tab.MatStr = Data.Material
        table.insert(Clips, tab)
        if(table.HasValue(Unclipped, Entity)) then
            table.remove(Unclipped, table.index(Unclipped, Entity))
        end
    end
    if ( SERVER ) then
        duplicator.StoreEntityModifier( Entity, "colour", Data )
    end
end
 
duplicator.RegisterEntityModifier( "colour", SetColour )
 
function TOOL:LeftClick( trace )
    if(trace.Entity:IsValid() and not trace.Entity:IsPlayer() and not trace.Entity:IsWorld()) then
        local r = self:GetClientNumber( "r", 0 )
        local g = self:GetClientNumber( "g", 0 )
        local b = self:GetClientNumber( "b", 0 )
        local a = self:GetClientNumber( "a", 0 )
        local mat   = self:GetClientInfo( "material", 0 )
        local OldR, OldG, OldB, OldA = trace.Entity:GetColor()
        trace.Entity:CallOnRemove("RemoveFromClips", function()
            table.remove(Clips, table.index(Clips, self))
        end)
        SetColor( trace.Entity, { OldColor = Color(OldR, OldG, OldB, OldA), Color = Color( r, g, b, a ), OldMaterial = trace.Entity:GetMaterial(), Material = mat, Norm = trace.HitNormal, Pos = trace.HitPos } )
        if (SERVER) then
            trace.Entity:SetColor(255, 255, 255, 0)
            undo.Create("Surface Color")
                undo.AddFunction(function(Undo, Ent)
                    table.remove(Clips, table.index(Clips, Ent))
                    render.Clear(0, 0, 0, 255)
                end, trace.Entity)
                undo.SetPlayer(self:GetOwner())
            undo.Finish()
        end
        return true
    end
end
 
function TOOL:RightClick( trace )
    if(trace.Entity:IsValid() and not trace.Entity:IsPlayer() and not trace.Entity:IsWorld()) then
        if(CLIENT) then
            table.remove(Clips, table.index(Clips, trace.Entity))
            render.Clear(0, 0, 0, 255)
            table.insert(Unclipped, trace.Entity)
        end
        trace.Entity:RemoveCallOnRemove("RemoveFromClips")
        trace.Entity:CallOnRemove("RemoveFromUnclipped", function()
            table.remove(Unclipped, table.index(Unclipped, self))
        end)
        return true
    end
end
 
function ClipPlanes()
    render.EnableClipping(true)
    for k,v in pairs(Clips) do
        local N = v.Ent:LocalToWorld(v.Norm) - v.Ent:GetPos()
        local P = v.Ent:LocalToWorld(v.Pos)
        local D = N:Dot(P)
        render.PushCustomClipPlane(N*-1, -D)
            render.SetColorModulation(v.OldColor.r, v.OldColor.g, v.OldColor.b)
            render.SetBlend(v.OldColor.a)
            if(string.len(v.OldMatStr) > 0) then
                render.SetMaterial(v.OldMaterial)
            end
            v.Ent:DrawModel()
        render.PopCustomClipPlane()
        render.PushCustomClipPlane(N, D)
            render.SetColorModulation(v.Color.r, v.Color.g, v.Color.b)
            render.SetBlend(v.Color.a)
            //if(string.len(v.MatStr) > 0) then
            //  render.SetMaterial(v.Material)
            //end
            v.Ent:DrawModel()
            render.SetColorModulation(1, 1, 1)
            render.SetBlend(1)
            //if(string.len(v.MatStr) > 0) then
            //  render.SetMaterial(DefMat)
            //end
        render.PopCustomClipPlane()
    end
    render.EnableClipping(false)
    for k,v in pairs(Unclipped) do
        v:DrawModel()
    end
end
hook.Add("PreDrawOpaqueRenderables", "ClipPlanes", ClipPlanes)
 
function TOOL.BuildCPanel(Panel)
    Panel:AddControl("Header", {Text = "#Tool_surfacecolor_name", Description = "#Tool_surfacecolor_desc"})
    Panel:AddControl("ComboBox", {Label = "Presets", MenuButton = 1, Folder = "colour", Options = {Default = {surfacecolor_r = 255, surfacecolor_g = 0, surfacecolor_b = 255, surfacecolor_a = 255}}, CVars = {"surfacecolor_r", "surfacecolor_g", "surfacecolor_b", "surfacecolor_a"}})
    Panel:AddControl("Color", {Label = "#Tool_colour_colour", Red = "surfacecolor_r", Green = "surfacecolor_g", Blue = "surfacecolor_b", Alpha = "surfacecolor_a", ShowAlpha = 1, ShowHSV = 1, ShowRGB = 1, Multiplier = 255})
    Panel:MatSelect("surfacecolor_material", list.Get( "OverrideMaterials" ), false, 0.33, 0.33)
    Panel:TextEntry("Material", "surfacecolor_material")
end