-- 注册模组
local FB = RegisterMod("nostalgicGame", 1)

-- 从XML中获取道具数据
local ItemID = {
    -- 风油精
    IP_EssentialBalm = Isaac.GetItemIdByName("Essential Balm")
}

function FB:onEssentialBalmAdd(player, cacheFlag)
    -- 如果玩家拥有当前道具的数量
    local itemCount = player:GetCollectibleNum(ItemID.IP_EssentialBalm);

    -- 如果玩家拥有当前道具
    if player:HasCollectible(ItemID.IP_EssentialBalm) then
        -- 判断以撒中角色数值的道具堆栈标签
        if cacheFlag == CacheFlag.CACHE_DAMAGE then -- 攻击力
            player.Damage = player.Damage + 1 * itemCount;
        elseif cacheFlag == CacheFlag.CACHE_SHOTSPEED then -- 弹速
            player.ShotSpeed = player.ShotSpeed - 0.2 * itemCount;
        elseif cacheFlag == CacheFlag.CACHE_TEARCOLOR then -- 子弹颜色
            player.TearColor = Color(0.2, 1.0, 0.2, 1.0);
        end
    end
end

local ItemEID = {};
local function EIDAddItem(id, content) -- EID添加内容
    if id then
        ItemEID[id] = content;
    end
end

EIDAddItem(ItemID.IP_EssentialBalm, {
    Name = "风油精",
    Descriptions = "↑{{Damage}} +1攻击力"..
    "#↑{{Tears}} -0.2弹速"
});

-- 特殊符号形式添加EID关键字
-- 换行：#
-- 颜色：{{ColorWhite}}{{ColorRed}}{{ColorGray}}{{ColorYellow}}等
-- 属性：{{Damage}}{{Tears}}{{Range}}{{Luck}}{{Shotspeed}}{{Speed}}
-- 转换：{{DevilChance}}{{AngelChance}}
-- 角色：{{Player0}}～{{Player40}}
-- 道具：{{Collectible1}}～{{Collectible732}}
-- 饰品：{{Trinket1}}～{{Trinket189}}
-- 卡牌：{{Card1}}～{{Card97}}
-- 药丸：{{Pill1}}～{{Pill49}}
-- 特殊：!!! ↑ ↓
if EID then -- 判断玩家是否订阅了EID
    local language = 'zh_cn';
    local description = EID.descriptions[language];
    for id, item in pairs(ItemEID) do
        EID:addCollectible(id, item.Descriptions, item.Name, language);
        -- 美德书适配
        if (item.BookOfVirtues and descriptions.bookOfVirtuesWisps) then
            descriptions.bookOfVirtuesWisps[id] = item.BookOfVirtues;
        end
        -- 大胃王适配
        if (item.BingeEater and descriptions.bingeEaterBuffs) then
            descriptions.bingeEaterBuffs[id] = item.BingeEater;
        end
    end
end

-- 事件wiki https://wofsauge.github.io/IsaacDocs/rep/enums/ModCallbacks.html
-- MC_EVALUATE_CACHE 拾取道具、使用影响属性的药丸等执行
-- MC_POST_UPDATE：每帧刷新后执行
-- MC_USE_ITEM：使用主动
-- MC_USE_CARD：使用卡牌
-- MC_USE_PILL：使用药丸
-- MC_ENTITY_TAKE_DMG：游戏实体受到攻击
-- MC_INPUT_ACTION：玩家输入后
-- MC_POST_NEW_ROOM：进入新房间
-- MC_POST_NEW_LEVEL：进入新楼层
FB:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, FB.onEssentialBalmAdd);
