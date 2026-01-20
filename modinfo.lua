local lang = locale
local function translate(String)  -- use this fn can be automatically translated according to the language in the table
	String.zhr = String.zh
	String.zht = String.zht or String.zh
	return String[lang] or String.en
end

--The name of the mod displayed in the 'mods' screen.
name = translate({en = "the better biomes", zh = "更好的地形(地图)"})

--A description of the mod.
description = translate({
	en = '"Triple MacTusk" and "Killer Bee" will always spawn. \n "Secondary Deciduous Forest" and "Secondary Meteor Area" biomes are permanently disabled. \n Ruins are guaranteed to spawn "Military Pitst" and "Muddy Sacred" and "More Altars" and "Sacred Danger". \n You can disable this mod after world generation completes if you want.',
	zh = "--> 必定出现 三海象平原 和 杀人蜂地块 \n --> 不再出现 第二桦树林 和 第二陨石区地形 \n --> 远古必定刷 军事矿坑、泥泞圣地、额外祭坛区、高危圣地 \n --> 你可以在地图生成之后取消这个mod"})


--Who wrote this awesome mod?
author = "TUTU"

--A version number so you can ask people if they are running an old version of your mod.
version = "1.0.4"

--This lets other players know if your mod is out of date. This typically needs to be updated every time there's a new game update.
api_version = 10

dst_compatible = true

--This lets clients know if they need to get the mod from the Steam Workshop to join the game
all_clients_require_mod = true

--This determines whether it causes a server to be marked as modded (and shows in the mod list)
client_only_mod = false

--This lets people search for servers with this mod by these tags
server_filter_tags = {"map", "biome"}


priority =-20  --模组优先级0-10 mod 加载的顺序   0最后载入  覆盖大值

configuration_options={ --模组变量配置

	{name = "Title",label = translate({en = "FOREST", zh = "森林"}),options = {{description = "", data = ""},}, default = "",},

	{
		name = "MacTusk",--modmain脚本里调用变量
		hover = translate({en = "Control whether this biome spawns during map generation", zh = "选择是否产生这个群落"}),
		label = translate({en = "Triple MacTusk", zh = "3海象平原"}),--游戏里显示的名字
		options ={	
					{description = translate({en = "Always", zh = "总是"}), data = 1},
					{description = translate({en = "Never",  zh = "从不"}), data = 0},
					{description = translate({en = "Random", zh = "随机"}), data = 2},
				},
		default = 1
	},

	{
		name = "KillerBee",--modmain脚本里调用变量
		hover = translate({en = "Control whether this biome spawns during map generation", zh = "选择是否产生这个群落"}),
		label = translate({en = "Killer Bee", zh = "杀人蜂平原"}),--游戏里显示的名字
		options ={	
					{description = translate({en = "Always", zh = "总是"}), data = 1},
					{description = translate({en = "Never",  zh = "从不"}), data = 0},
					{description = translate({en = "Random", zh = "随机"}), data = 2},
				},
		default = 1
	},

	{
		name = "SecondaryDeciduous",--modmain脚本里调用变量
		hover = translate({en = "Control whether this biome spawns during map generation", zh = "选择是否产生这个群落"}),
		label = translate({en = "Secondary Deciduous", zh = "第二桦树林"}),--游戏里显示的名字
		options ={	
					{description = translate({en = "Always", zh = "总是"}), data = 1},
					{description = translate({en = "Never",  zh = "从不"}), data = 0},
					{description = translate({en = "Random", zh = "随机"}), data = 2},
				},
		default = 0
	},

	{
		name = "SecondaryMeteor",--modmain脚本里调用变量
		hover = translate({en = "Control whether this biome spawns during map generation", zh = "选择是否产生这个群落"}),
		label = translate({en = "Secondary Meteor Area", zh = "第二陨石区"}),--游戏里显示的名字
		options ={	
					{description = translate({en = "Always", zh = "总是"}), data = 1},
					{description = translate({en = "Never",  zh = "从不"}), data = 0},
					{description = translate({en = "Random", zh = "随机"}), data = 2},
				},
		default = 0
	},

	{name = "Title",label = translate({en = "RUINS", zh = "遗迹"}),options = {{description = "", data = ""},}, default = "",},

	{
		name = "TheLargestSacred",--modmain脚本里调用变量
		hover = translate({en = "This makes Sacred always generate the largest number of rooms", zh = "使得圣地总是生成最多的房间数量"}),
		label = translate({en = "The Largest Sacred", zh = "最大的圣地"}),--游戏里显示的名字
		options ={	
					{description = translate({en = "Enable", zh = "开启"}), data = true},
					{description = translate({en = "Disable",  zh = "关闭"}), data = false},
				},
		default = true
	},

	{
		name = "MoreAltars",--modmain脚本里调用变量
		hover = translate({en = "Control whether this biome spawns during map generation", zh = "选择是否产生这个群落"}),
		label = translate({en = "More Altars", zh = "额外祭坛区"}),--游戏里显示的名字
		options ={	
					{description = translate({en = "Always", zh = "总是"}), data = 1},
					{description = translate({en = "Never",  zh = "从不"}), data = 0},
					{description = translate({en = "Random", zh = "随机"}), data = 2},
				},
		default = 2
	},

	{
		name = "SacredDanger",--modmain脚本里调用变量
		hover = translate({en = "Control whether this biome spawns during map generation", zh = "选择是否产生这个群落"}),
		label = translate({en = "Sacred Danger", zh = "高危圣地"}),--游戏里显示的名字
		options ={	
					{description = translate({en = "Always", zh = "总是"}), data = 1},
					{description = translate({en = "Never",  zh = "从不"}), data = 0},
					{description = translate({en = "Random", zh = "随机"}), data = 2},
				},
		default = 2
	},

	{
		name = "MilitaryPits",--modmain脚本里调用变量
		hover = translate({en = "Control whether this biome spawns during map generation", zh = "选择是否产生这个群落"}),
		label = translate({en = "Military Pits", zh = "军事矿坑"}),--游戏里显示的名字
		options ={	
					{description = translate({en = "Always", zh = "总是"}), data = 1},
					{description = translate({en = "Never",  zh = "从不"}), data = 0},
					{description = translate({en = "Random", zh = "随机"}), data = 2},
				},
		default = 2
	},
	
	{
		name = "MuddySacred",--modmain脚本里调用变量
		hover = translate({en = "Control whether this biome spawns during map generation", zh = "选择是否产生这个群落"}),
		label = translate({en = "Muddy Sacred", zh = "泥泞圣地"}),--游戏里显示的名字
		options ={	
					{description = translate({en = "Always", zh = "总是"}), data = 1},
					{description = translate({en = "Never",  zh = "从不"}), data = 0},
					{description = translate({en = "Random", zh = "随机"}), data = 2},
				},
		default = 2
	},
}

mod_dependencies = {
}

icon_atlas = "preview.xml"
icon = "preview.tex"