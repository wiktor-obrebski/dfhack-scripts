-- Adjust all preferences of one or all dwarves in play
-- by vjek

utils = require 'utils'
pss_counter = pss_counter or 31415926

-- ---------------------------------------------------------------------------
function insert_preference(unit, preftype, val1)
    if preftype == df.unitpref_type.LikeMaterial then
        utils.insert_or_update(unit.status.current_soul.preferences, {
            new = true,
            type = preftype,
            poetic_form_id = -1, -- only set this field, because it's one of the largest in the union
            mattype = dfhack.matinfo.find(val1).type,
            mat_state = df.matter_state.Solid,
            matindex = dfhack.matinfo.find(val1).index,
            active = true,
            prefstring_seed = pss_counter,
        }, 'prefstring_seed')
        -- mattype for some is non zero, those non-inorganic like creature:gazelle:hoof is 42,344
    elseif preftype == df.unitpref_type.LikeFood then
        consumable_type = val1[1]
        consumable_name = val1[2]
        utils.insert_or_update(unit.status.current_soul.preferences, {
            new = true,
            type = preftype,
            item_type = consumable_type,
            item_subtype = dfhack.matinfo.find(consumable_name).subtype,
            mattype = dfhack.matinfo.find(consumable_name).type,
            mat_state = df.matter_state.Solid,
            matindex = dfhack.matinfo.find(consumable_name).index,
            active = true,
            prefstring_seed = pss_counter,
        }, 'prefstring_seed')
    elseif df.unitpref_type[preftype] ~= nil then
        utils.insert_or_update(unit.status.current_soul.preferences, {
            new = true,
            type = preftype,
            -- only set poetic_form_id because it's the largest field in the union.
            -- setting a smaller field would truncate larger values
            poetic_form_id = val1,
            item_subtype = -1,
            mattype = -1,
            mat_state = df.matter_state.Solid,
            matindex = -1,
            active = true,
            prefstring_seed = pss_counter,
        }, 'prefstring_seed')
    else
        error('Unrecognized preference type: ' .. tostring(preftype))
    end

    pss_counter = pss_counter + 1
end
-- ---------------------------------------------------------------------------
function brainwash_unit(unit, profile)
    if unit==nil then
        print ("No unit available!  Aborting with extreme prejudice.")
        return
    end

    if profile == "IDEAL" then
        -- Material Likes: IRON(0),STEEL(8),ADAMANTINE(25)
        insert_preference(unit, df.unitpref_type.LikeMaterial, "IRON")
        insert_preference(unit, df.unitpref_type.LikeMaterial, "STEEL")
    --  insert_preference(unit, df.unitpref_type.LikeMaterial, "ADAMANTINE")

        -- Item likes: (WEAPON, ARMOR, SHIELD)
        insert_preference(unit, df.unitpref_type.LikeItem, df.item_type.WEAPON)
        insert_preference(unit, df.unitpref_type.LikeItem, df.item_type.ARMOR)
        insert_preference(unit, df.unitpref_type.LikeItem, df.item_type.SHIELD)

        -- Plant Likes: "Likes plump helmets for their rounded tops"
        insert_preference(unit, df.unitpref_type.LikePlant, dfhack.matinfo.find("MUSHROOM_HELMET_PLUMP:STRUCTURAL").index)
    --  insert_preference(unit, df.unitpref_type.LikePlant, dfhack.matinfo.find("PEACH").index)

        -- Prefers to consume drink: (From plump helmets we get dwarven wine)
        insert_preference(unit, df.unitpref_type.LikeFood, {df.item_type.DRINK, "MUSHROOM_HELMET_PLUMP:DRINK"})
        -- Prefers to consume food: (plump helmets, mushrooms)
        insert_preference(unit, df.unitpref_type.LikeFood, {df.item_type.PLANT, "MUSHROOM_HELMET_PLUMP:MUSHROOM"})
        -- Prefers to consume prepared meals: (quarry bush)
        insert_preference(unit, df.unitpref_type.LikeFood, {df.item_type.FOOD, "BUSH_QUARRY"})

        -- Creature detests (TROLL, BIRD_BUZZARD, BIRD_VULTURE, CRUNDLE)
        insert_preference(unit, df.unitpref_type.HateCreature, list_of_creatures.TROLL)
        insert_preference(unit, df.unitpref_type.HateCreature, list_of_creatures.BIRD_BUZZARD)
        insert_preference(unit, df.unitpref_type.HateCreature, list_of_creatures.BIRD_VULTURE)
        insert_preference(unit, df.unitpref_type.HateCreature, list_of_creatures.CRUNDLE)
        if #df.global.world.poetic_forms.all > 0 then
            insert_preference(unit, df.unitpref_type.LikePoeticForm, 0) -- this just inserts the first song out of typically many.
        end
        if #df.global.world.musical_forms.all > 0 then
            insert_preference(unit, df.unitpref_type.LikeMusicalForm, 0) -- same goes for music
        end
        if #df.global.world.dance_forms.all > 0 then
            insert_preference(unit, df.unitpref_type.LikeDanceForm, 0) -- and dancing
        end
        -- end IDEAL profile

    elseif profile == "GOTH" then
        insert_preference(unit, df.unitpref_type.LikeMaterial, "CREATURE:DWARF:SKIN")
        insert_preference(unit, df.unitpref_type.LikeItem, df.item_type.CORPSE)
        insert_preference(unit, df.unitpref_type.LikeItem, df.item_type.CORPSEPIECE)
        insert_preference(unit, df.unitpref_type.LikeItem, df.item_type.REMAINS)
        insert_preference(unit, df.unitpref_type.LikeItem, df.item_type.COFFIN)
        insert_preference(unit, df.unitpref_type.LikeColor, list_of_colors.BLACK)
        insert_preference(unit, df.unitpref_type.LikeShape, list_of_shapes.CROSS)
        insert_preference(unit, df.unitpref_type.LikePlant, dfhack.matinfo.find("GLUMPRONG").index)
        insert_preference(unit, df.unitpref_type.LikeFood, {df.item_type.DRINK, "WEED_RAT:DRINK"})
        insert_preference(unit, df.unitpref_type.LikeFood, {df.item_type.DRINK, "SLIVER_BARB:DRINK"})
        insert_preference(unit, df.unitpref_type.LikeFood, {df.item_type.PLANT, "TUBER_BLOATED:STRUCTURAL"})
        insert_preference(unit, df.unitpref_type.HateCreature, list_of_creatures.ELF)
        insert_preference(unit, df.unitpref_type.HateCreature, list_of_creatures.HUMAN)
        insert_preference(unit, df.unitpref_type.HateCreature, list_of_creatures.DWARF)
        if list_of_creatures.DEMON_1 and df.global.world.raws.creatures.all[list_of_creatures.DEMON_1].prefstring[0] ~= '' then
            insert_preference(unit, df.unitpref_type.LikeCreature, list_of_creatures.DEMON_1)
        end
        if #df.global.world.poetic_forms.all > 0 then
            insert_preference(unit, df.unitpref_type.LikePoeticForm, #df.global.world.poetic_forms.all - 1) -- this just inserts the last song out of typically many.
        end
        if #df.global.world.musical_forms.all > 0 then
            insert_preference(unit, df.unitpref_type.LikeMusicalForm, #df.global.world.musical_forms.all - 1) -- same goes for music
        end
        if #df.global.world.dance_forms.all > 0 then
            insert_preference(unit, df.unitpref_type.LikeDanceForm, #df.global.world.dance_forms.all - 1) -- and dancing
        end
        -- end GOTH profile
    else
        error("Unrecognized profile: " .. profile)
    end

    prefcount = #(unit.status.current_soul.preferences)
    print ("After adjusting, unit "..unit_name_to_console(unit).." has "..prefcount.." preferences")
end -- end of function brainwash_unit
-- ---------------------------------------------------------------------------
function clear_preferences(unit)
    local prefs=unit.status.current_soul.preferences
    for index,pref in ipairs(prefs) do
        pref:delete()
    end
    prefs:resize(0)
end
-- ---------------------------------------------------------------------------
function clearpref_all_dwarves()
    for _,unit in ipairs(dfhack.units.getCitizens()) do
        print("Clearing Preferences for "..unit_name_to_console(unit))
        clear_preferences(unit)
    end
end
-- ---------------------------------------------------------------------------
function adjust_all_dwarves(profile)
    for _,unit in ipairs(dfhack.units.getCitizens()) do
        print("Adjusting "..unit_name_to_console(unit))
        brainwash_unit(unit,profile)
    end
end
-- ---------------------------------------------------------------------------
function build_all_lists(printflag)
    list_of_inorganics={} -- Type 0 "Likes iron.."
    list_of_inorganics_string=""
    vec=df.global.world.raws.inorganics.all -- also df.global.world.raws.inorganics.cheap[0].id available
    for k=0,#vec-1 do
        name=vec[k].id
        list_of_inorganics[name]=k
        list_of_inorganics_string=list_of_inorganics_string..name..","
    end
    if printflag then
        print("\nTYPE 0 INORGANICS:"..list_of_inorganics_string) --    printall(list_of_inorganics)
    end
-- ------------------------------------
    list_of_creatures={} --dict[name]=number, Type 1/3 "Likes them for.." / "Detests .."
    vec=df.global.world.raws.creatures.all
    list_of_creatures_string=""
    for k=0,#vec-1 do
        name=vec[k].creature_id
        list_of_creatures[name]=k
        list_of_creatures_string=list_of_creatures_string..name..","
    end
    if printflag then
        print("\nTYPE 1,3 CREATURES:"..list_of_creatures_string) --    printall(list_of_creatures)
    end
-- ------------------------------------
    list_of_plants={} -- Type 2 "Prefers to consume.." and Type 5 "Likes Plump Helmets for their rounded tops"
    -- (TODO could have edible only, and/or a different list for each-all edible meat/plants/drinks)
    list_of_plants_string=""
    vec=df.global.world.raws.plants.all
    for k=0,#vec-1 do
        name=vec[k].id
        list_of_plants[name]=k
        list_of_plants_string=list_of_plants_string..name..","
    end
    if printflag then
        print("\nTYPE 2,5 PLANTS:"..list_of_plants_string) --    printall(list_of_plants)
    end
-- ------------------------------------
    list_of_items={} -- Type 4 "Likes armor.." (TODO need recursive material decode lists?)
    list_of_items_string=""
    -- [lua]# @dfhack.matinfo.decode(31,1)
    -- <material 31:1 CREATURE:TOAD_MAN:GUT>
    -- [lua]# @dfhack.matinfo.decode(0,1)
    -- <material 0:1 INORGANIC:GOLD>
    for k,v in ipairs(df.item_type) do
        list_of_items[v]=k
        list_of_items_string=list_of_items_string..v..","
    end
    if printflag then
        print("\nTYPE 4 ITEMS:"..list_of_items_string) --    printall(list_of_items)
    end
-- ------------------------------------
    list_of_colors={} -- Type 7 "Likes the color.."
    list_of_colors_string = ""
    vec=df.global.world.raws.descriptors.colors
    for k=0,#vec-1 do
        name=vec[k].id
        list_of_colors[name]=k
        list_of_colors_string=list_of_colors_string..name..","
    end
    if printflag then
        print("\nTYPE 7 COLORS:"..list_of_colors_string) --    printall(list_of_colors)
    end
-- ------------------------------------
    list_of_shapes={} -- Type 8 "Likes circles"
    list_of_shapes_string = ""
    vec=df.global.world.raws.descriptors.shapes
    for k=0,#vec-1 do
        name=vec[k].id
        list_of_shapes[name]=k
        list_of_shapes_string=list_of_shapes_string..name..","
    end
    if printflag then
        print("\nTYPE 8 SHAPES:"..list_of_shapes_string) --    printall(list_of_shapes)
    end
-- ------------------------------------
    list_of_poems={} -- Type 9 "likes the words of.."
    list_of_poems_string = ""
    vec=df.global.world.poetic_forms.all
    for k=0,#vec-1 do
        name=dfhack.translation.translateName(vec[k].name,true)
        list_of_poems[name]=k
        list_of_poems_string=list_of_poems_string..k..":"..name..","
    end
    if printflag then
        print("\nTYPE 9 POEMS:"..dfhack.df2console(list_of_poems_string)) -- printall(list_of_poems)
    end
-- ------------------------------------
    list_of_music={} -- Type 10 "Likes the sound of.."
    list_of_music_string = ""
    vec=df.global.world.musical_forms.all
    for k=0,#vec-1 do
        name=dfhack.translation.translateName(vec[k].name,true)
        list_of_music[name]=k
        list_of_music_string=list_of_music_string..k..":"..name..","
    end
    if printflag then
        print("\nTYPE 10 MUSIC:"..dfhack.df2console(list_of_music_string)) --    printall(list_of_music)
    end
-- ------------------------------------
    list_of_dances={} -- Type 11
    list_of_dances_string = ""
    vec=df.global.world.dance_forms.all
    for k=0,#vec-1 do
        name=dfhack.translation.translateName(vec[k].name,true)
        list_of_dances[name]=k
        list_of_dances_string=list_of_dances_string..k..":"..name..","
    end
    if printflag then
        print("\nTYPE 11 DANCES:"..dfhack.df2console(list_of_dances_string)) --    printall(list_of_dances)
    end
end -- end func build_all_lists
-- ---------------------------------------------------------------------------
function get_preferences(unit)
    if not unit then
        print("No unit selected!")
        return
    end

    local preferences = unit.status.current_soul.preferences
    if #preferences == 0 then
        print("Unit " .. unit_name_to_console(unit) .. " has no preferences.")
        return
    end

    print("Preferences for " .. unit_name_to_console(unit) .. ":")
    for _, pref in ipairs(preferences) do
        local pref_type = df.unitpref_type[pref.type]
        local description = ""

        if pref_type == "LikeMaterial" then
            description = "Likes material: " .. dfhack.matinfo.getToken(pref.mattype, pref.matindex)
        elseif pref_type == "LikeFood" then
            description = "Likes food: " .. dfhack.matinfo.getToken(pref.mattype, pref.matindex)
        elseif pref_type == "LikeItem" then
            description = "Likes item type: " .. tostring(pref.item_type)
        elseif pref_type == "LikePlant" then
            description = "Likes plant: " .. dfhack.matinfo.getToken(pref.mattype, pref.matindex)
        elseif pref_type == "HateCreature" then
            description = "Hates creature: " .. df.global.world.raws.creatures.all[pref.creature_id].creature_id
        elseif pref_type == "LikeColor" then
            description = "Likes color: " .. df.global.world.raws.descriptors.colors[pref.color_id].id
        elseif pref_type == "LikeShape" then
            description = "Likes shape: " .. df.global.world.raws.descriptors.shapes[pref.shape_id].id
        elseif pref_type == "LikePoeticForm" then
            description = "Likes poetic form: " .. dfhack.translation.translateName(df.global.world.poetic_forms.all[pref.poetic_form_id].name, true)
        elseif pref_type == "LikeMusicalForm" then
            description = "Likes musical form: " .. dfhack.translation.translateName(df.global.world.musical_forms.all[pref.musical_form_id].name, true)
        elseif pref_type == "LikeDanceForm" then
            description = "Likes dance form: " .. dfhack.translation.translateName(df.global.world.dance_forms.all[pref.dance_form_id].name, true)
        else
            description = "Unknown preference type: " .. tostring(pref.type)
        end

        print(description)
    end
end -- end function: get_preferences
-- ---------------------------------------------------------------------------
function unit_name_to_console(unit)
    return dfhack.df2console(dfhack.units.getReadableName(unit))
end


-- ---------------------------------------------------------------------------
-- main script operation starts here
-- ---------------------------------------------------------------------------
build_all_lists(false)

local opt = ({...})[1]

function handle_one(profile)
    local unit = dfhack.gui.getSelectedUnit(true)
    if unit == nil then
        print ("No unit available!  Aborting with extreme prejudice.")
        return
    end
    clear_preferences(unit)
    brainwash_unit(unit, profile)
end

function handle_all(profile)
    clearpref_all_dwarves()
    adjust_all_dwarves(profile)
end

if opt == "list" then
    build_all_lists(true)
elseif opt == "clear" then
    local unit = dfhack.gui.getSelectedUnit(true)
    if unit==nil then
        print ("No unit available!  Aborting with extreme prejudice.")
        return
    end
    clear_preferences(unit)
    prefcount = #unit.status.current_soul.preferences
    print ("After clearing, unit "..unit_name_to_console(unit).." has "..prefcount.." preferences")
elseif opt == "clear_all" then
    clearpref_all_dwarves()
elseif opt == "goth" then
    handle_one("GOTH")
elseif opt == "one" then
    handle_one("IDEAL")
elseif opt == "all" then
    handle_all("IDEAL")
elseif opt == "goth_all" then
    handle_all("GOTH")
elseif opt == "show" then
    local unit = dfhack.gui.getSelectedUnit(true)
    get_preferences(unit)
else
    print(dfhack.script_help())
    if opt and opt ~= "help" then
        qerror("Unrecognized option: " .. opt)
    end
end
