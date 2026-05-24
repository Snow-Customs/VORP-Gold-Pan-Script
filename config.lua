Config = {}

Config.defaultlang = "de_lang"

---------------------Wild Water Locations--------------------------
Config.locations = { 
    [1]  = { name = 'Sea of Coronado',     hash = -247856387  },
    [2]  = { name = 'San Luis River',      hash = -1504425495 },
    [3]  = { name = 'Lake Don Julio',      hash = -1369817450 },
    [4]  = { name = 'Flat Iron Lake',      hash = -1356490953 },
    [5]  = { name = 'Upper Montana River', hash = -1781130443 },
    [6]  = { name = 'Owanjila',            hash = -1300497193 },
    [7]  = { name = 'Hawks Eye Creek',     hash = -1276586360 },
    [8]  = { name = 'Little Creek River',  hash = -1410384421 },
    [9]  = { name = 'Dakota River',        hash =  370072007  },
    [10] = { name = 'Beartooth Beck',      hash =  650214731  },
    [11] = { name = 'Lake Isabella',       hash =  592454541  },
    [12] = { name = 'Cattail Pond',        hash = -804804953  },
    [13] = { name = 'Deadboot Creek',      hash =  1245451421 },
    [14] = { name = 'Spider Gorge',        hash = -218679770  },
    [15] = { name = 'O\'Creagh\'s Run',    hash = -1817904483 },
    [16] = { name = 'Moonstone Pond',      hash = -811730579  },
    [17] = { name = 'Kamassa River',       hash = -1229593481 },
    [18] = { name = 'Elysian Pool',        hash = -105598602  },
    [19] = { name = 'Heartlands Overflow', hash =  1755369577 },
    [20] = { name = 'Lagras Bayou',        hash = -557290573  },
    [21] = { name = 'Lannahechee River',   hash = -2040708515 },
    [22] = { name = 'Calmut Ravine',       hash =  231313522  },
    [23] = { name = 'Ringneck Creek',      hash =  2005774838 },
    [24] = { name = 'Stillwater Creek',    hash = -1287619521 },
    [25] = { name = 'Lower Montana River', hash = -1308233316 },
    [27] = { name = 'Aurora Basin',        hash = -196675805  },
    [28] = { name = 'Barrow Lagoon',       hash =  795414694  },
    [29] = { name = 'Arroyo De La Vibora', hash = -49694339   },
    [30] = { name = 'Bahia De La Paz',     hash = -1168459546 },
    [31] = { name = 'Dewberry Creek',      hash =  469159176  },
    [32] = { name = 'Whinyard Strait',     hash = -261541730  },
    [33] = { name = 'Cairn Lake',          hash = -1073312073 },
    [34] = { name = 'Hot Springs',         hash =  1175365009 },
    [35] = { name = 'Mattlock Pond',       hash =  301094150  },
    [36] = { name = 'Southfield Flats',    hash = -823661292  },
}
-----------------------------------------------------------------

------------------------ Goldpanning Settings -----------------

Config.GoldPanItem = 'goldpan'   --- Goldpan item DB name
Config.GoldPanTime = 19000     --- Gesamtdauer Schürfen (ms)
Config.CrouchTime = 4000       --- Bücken am Anfang (ms)
Config.PanningTime = 15000     --- Goldpfanne schütteln/rühren (ms)

Config.Anims = {
    Crouch = { dict = 'script_rc@cldn@ig@rsc2_ig1_questionshopkeeper', name = 'inspectfloor_player' },
    -- Dict: script_re@gold_panner@gold_success — bekannte Clips:
    -- SEARCH02              = kräftig schütteln/suchen
    -- SEARCH04              = andere such/schütteln
    -- panning_idle          = ruhig in der pfanne rühren
    -- panning_idle_no_water = langsam rühren (ohne wasser fokus)
    Panning = { dict = 'script_re@gold_panner@gold_success', name = 'SEARCH04' },
}

-- während schürf animation laufen können
Config.PanningCanMove = true
Config.PanningAnimFlag = 31   -- 31 = Bewegung, 1 = feststehen nur als option wenn PanningCanMove false ist
Config.CrouchAnimFlag = 1     -- Bücken bleibt am Boden
Config.DisableSprintWhilePanning = true  -- kein Sprinten während SEARCH04 (Laufen geht)
Config.DisableJumpWhilePanning = true   -- kein Springen im gesamten Schuerfmodus

Config.Keys = {
    Pan = "SPACE",
    ExitMode = "X",
}
Config.RewardChance = 36  ----- Chance etwas zu finden (1-100, z.B. 36 = 36%)
Config.ToolUsage = 1   -- Haltbarkeit pro Schuerfvorgang abziehen

-- Item zurueckgeben, wenn die Goldpfanne 0 Haltbarkeit erreicht?
Config.ReturnItemOnDepletion = false -- false oder Item-Name z.B. "goldpan_broken"

------------------------ SkillCheck Einstellungen ------------------

-- nutzt syn_minigame, ist meist mit VORP mitgeliefert
Config.DoSkillCheck  = false -- Minispiel vor Belohnung erforderlich?
Config.MaxDifficulty = 3000  -- Niedrigere Zahl = schwerer
Config.MinDifficulty = 6000  -- Niedrigere Zahl = schwerer


----------------------- Reward Settings -----------------------

Config.RewardItems = {
    { Name = "gold_nugget", Label = "Gold Nugget", AmountMin = 1, AmountMax = 4 },
}