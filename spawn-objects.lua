-- name: Spawn Objects (beta)
-- description: Spawn objects
--
-- - Because of sm64coopdxn limits, max 1200 objects can be spawned, included
-- the one already spawned with the map
-- - Submarine center is at the right of visible object position, so a special
-- function is needed for it or the model needs fixing in blender

-- Parameters
local COOLDOWN_FRAMES = 50
local SPEED_MULTIPLIER = 5.0 -- Adjusts object spawn position based on Mario speed

-- local TARGET_LEVEL = LEVEL_BOB
-- local TARGET_LEVEL = LEVEL_RR
local TARGET_LEVEL = LEVEL_CASTLE_GROUNDS
local TARGET_AREA = 1
local TARGET_WARP = 0
local recentObjs = {}
local MAX_RECENT = 30

-- Menu: spawn objects always upright?
local spawnObjectsUpright = mod_storage_load_bool("spawn_objects_upright") or true
local function onUprightToggle(index, value)
    spawnObjectsUpright = value
    mod_storage_save_bool("spawn_objects_upright", value)
end
hook_mod_menu_checkbox("Spawn Objects Upright", spawnObjectsUpright, onUprightToggle)

-- Menu categories and subcategories
local categories = {
    {
      name = "Recents",
      items = recentObjs,
    },
    {
        name = "Powerups",
        items = {
            {
                behavior = id_bhvKoopaShell,
                model = E_MODEL_KOOPA_SHELL,
                name = "Shell",
                spawnOffset = 0,
                spawnYaw = 0,
                spawnPitch = 0,
                spawnRoll = 0,
            },
            { behavior = id_bhvRecoveryHeart, model = E_MODEL_HEART, name = "Recovery Heart", spawnYOffset = 100 },
            { name = "Ten coins spawn", model = E_MODEL_YELLOW_COIN, behavior = id_bhvTenCoinsSpawn },
            { name = "1UP", behavior = id_bhv1Up, model = E_MODEL_1UP },
            { behavior = id_bhvWingCap, model = E_MODEL_TOADS_WING_CAP, name = "Wing Cap", spawnOffset = 200 },
            { behavior = id_bhvMetalCap, model = E_MODEL_TOADS_METAL_CAP, name = "Metal Cap", spawnOffset = 200 },
            { behavior = id_bhvVanishCap, model = E_MODEL_TOADS_CAP, name = "Vanish Cap", spawnOffset = 200 },
            -- { name = "Jumping 1UP", behavior = id_bhv1upJumpOnApproach, model = E_MODEL_1UP },
            -- {name = "Hidden 1up", model = E_MODEL_1UP, behavior = id_bhvHidden1up},
            { name = "Hidden 1up pole", model = E_MODEL_1UP, behavior = id_bhvHidden1upInPole },
            { name = "Coin formation (front)", behavior = id_bhvCoinFormation, model = E_MODEL_YELLOW_COIN, spawnOffset = 480},
            { name = "Coin formation (above)", behavior = id_bhvCoinFormation, model = E_MODEL_YELLOW_COIN, spawnOffset = 0, spawnYOffset = 200, param2nd = 1 },
            { name = "Coin formation (circle)", behavior = id_bhvCoinFormation, model = E_MODEL_YELLOW_COIN, spawnOffset = 0, param2nd = 2},
            { name = "Red coin", model = E_MODEL_RED_COIN, behavior = id_bhvRedCoin, spawnOffset = 100 },
            { name = "Blue coin jumping", behavior = id_bhvBlueCoinJumping, model = E_MODEL_BLUE_COIN },
            { name = "Blue coin sliding", behavior = id_bhvBlueCoinSliding, model = E_MODEL_BLUE_COIN },
            { name = "Marios cap", model = E_MODEL_MARIOS_CAP, behavior = id_bhvNormalCap },
        },
    },
    {
        name = "Platforms",
        items = {
            {
                name = "Wood piece",
                model = E_MODEL_LLL_WOOD_BRIDGE,
                behavior = id_bhvLllWoodPiece,
                spawnYOffset = -100,
            },
            {
                behavior = id_bhvTree,
                model = E_MODEL_BUBBLY_TREE,
                name = "Tree",
                spawnOffset = 250,
                spawnYOffset = -100,
            },
            { name = "Spiky tree", model = E_MODEL_COURTYARD_SPIKY_TREE, behavior = id_bhvTree, spawnYOffset = -100 },
            { name = "Palm tree", model = E_MODEL_PALM_TREE, behavior = id_bhvTree, spawnYOffset = -100 },
            { name = "Snow tree", model = E_MODEL_SNOW_TREE, behavior = id_bhvTree, spawnYOffset = -100 },
            {
                behavior = id_bhvTweester,
                model = E_MODEL_TWEESTER,
                name = "Tweester",
                spawnOffset = 0,
                spawnYOffset = 0,
                spawnYaw = 0,
                spawnPitch = 0,
                spawnRoll = 0,
            },
            {
                name = "Sinking rock block",
                model = E_MODEL_LLL_SINKING_ROCK_BLOCK,
                behavior = id_bhvLllSinkingRockBlock,
                spawnOffset = 200,
                spawnYOffset = -200,
            },
            {
                name = "WDW (NON)rotating platform",
                model = E_MODEL_WDW_ROTATING_PLATFORM,
                behavior = id_bhvRotatingPlatform,
                spawnYOffset = -400,
                param2nd = 1
            },
            {
                name = "Floor trap",
                model = E_MODEL_CASTLE_BOWSER_TRAP,
                behavior = id_bhvFloorTrapInCastle,
                spawnLateralOffset = 180,
            },
            {
                behavior = id_bhvSquarishPathMoving,
                model = E_MODEL_BITDW_SQUARE_PLATFORM,
                name = "Moving Pyramid",
                spawnOffset = 0,
                spawnYOffset = -80,
            },
            {
                behavior = id_bhvSeesawPlatform,
                model = E_MODEL_BITDW_SEESAW_PLATFORM,
                name = "Seesaw BitDW",
                spawnOffset = 200,
                spawnYOffset = -60,
                param2nd = 0,
            },
            {
                behavior = id_bhvSeesawPlatform,
                model = E_MODEL_BITFS_SEESAW_PLATFORM,
                name = "Seesaw BitFS",
                spawnOffset = 200,
                spawnYOffset = -200,
                spawnYaw = 16384,
                param2nd = 4,
            },
            {
                name = "Seesaw RR",
                model = E_MODEL_RR_SEESAW_PLATFORM,
                behavior = id_bhvSeesawPlatform,
                spawnYOffset = -60,
                param2nd = 5,
            },
            {
                name = "Seesaw BOB",
                model = E_MODEL_BOB_SEESAW_PLATFORM,
                behavior = id_bhvSeesawPlatform,
                spawnYOffset = -100,
                param2nd = 3,
            },
            {
                name = "Seesaw Bits",
                model = E_MODEL_BITS_SEESAW_PLATFORM,
                behavior = id_bhvSeesawPlatform,
                spawnYOffset = -100,
                param2nd = 1,
            },
            {
                name = "Bitfs Tilting inverted pyramid",
                behavior = id_bhvBitfsTiltingInvertedPyramid,
                model = E_MODEL_BITFS_TILTING_SQUARE_PLATFORM,
                spawnYOffset = -300,
            },
            {
                name = "LLL Tilting inverted pyramid",
                model = E_MODEL_LLL_TILTING_SQUARE_PLATFORM,
                behavior = id_bhvLllTiltingInvertedPyramid,
                spawnYOffset = -300,
            },
            {
                behavior = id_bhvLllDrawbridge,
                model = E_MODEL_LLL_DRAWBRIDGE_PART,
                name = "Drawbridge",
                spawnOffset = -100,
                spawnYOffset = -150,
                spawnYaw = 16384,
                spawnPitch = 0,
            },
            {
                behavior = id_bhvKickableBoard,
                model = E_MODEL_WF_KICKABLE_BOARD,
                name = "Kickable Board",
                spawnYOffset = -30,
                spawnYaw = 32768,
            },
            { name = "TTC treadmill", model = E_MODEL_TTC_LARGE_TREADMILL, behavior = id_bhvTTCTreadmill },
            { behavior = id_bhvTTCSpinner, model = E_MODEL_TTC_SPINNER, name = "Spinner", spawnOffset = 0 },
            {
                behavior = id_bhvTTC2DRotator,
                model = E_MODEL_TTC_CLOCK_HAND,
                name = "Clock Hand",
                spawnOffset = 0,
                spawnYOffset = -40,
            },
            {
                behavior = id_bhvDonutPlatform,
                model = E_MODEL_RR_DONUT_PLATFORM,
                name = "Donut Platform",
                spawnOffset = 200,
                spawnYOffset = -200,
            },
            {
                name = "Moving octagon",
                model = E_MODEL_LLL_MOVING_OCTAGONAL_MESH_PLATFORM,
                behavior = id_bhvLllMovingOctagonalMeshPlatform,
                spawnOffset = 200,
                spawnYOffset = -200,
            },
            {
                name = "Koopa flag",
                model = E_MODEL_KOOPA_FLAG,
                behavior = id_bhvKoopaFlag,
                spawnOffset = 200,
                spawnYOffset = 20,
            },
            {
                name = "Rotating hexagon (TTC)",
                model = E_MODEL_TTC_ROTATING_HEXAGON,
                behavior = id_bhvTTCCog,
                spawnOffset = 100,
                spawnYOffset = -50,
            },
            -- Koopa flag always goes on the ground, so i make it spawn higher
            -- {name = "Koopa race endpoint", model = E_MODEL_KOOPA_FLAG, behavior = id_bhvKoopaRaceEndpoint},
            {
                name = "Sliding platform (Bits)",
                model = E_MODEL_BITS_SLIDING_PLATFORM,
                behavior = id_bhvSlidingPlatform2,
                spawnYOffset = -300,
            },
            {
                name = "Sliding platform (RR)",
                model = E_MODEL_RR_SLIDING_PLATFORM,
                behavior = id_bhvSlidingPlatform2,
                spawnYOffset = -300,
            },
            {
                name = "Tilting floor platform",
                behavior = id_bhvBbhTiltingTrapPlatform,
                model = E_MODEL_BBH_TILTING_FLOOR_PLATFORM,
                spawnYOffset = -200,
            },
            { name = "Pyramid top", model = E_MODEL_SSL_PYRAMID_TOP, behavior = id_bhvPyramidTop },
            {
                name = "Floating platform (JRB)",
                model = E_MODEL_JRB_FLOATING_PLATFORM,
                behavior = id_bhvJrbFloatingPlatform,
            },
            {
                name = "Floating platform (WDW)",
                model = E_MODEL_WDW_RECTANGULAR_FLOATING_PLATFORM,
                behavior = id_bhvWdwRectangularFloatingPlatform,
            },
            {
                name = "Floating platform square (WDW)",
                model = E_MODEL_WDW_SQUARE_FLOATING_PLATFORM,
                behavior = id_bhvWdwSquareFloatingPlatform,
            },
            {
                name = "WDW express el platform",
                model = E_MODEL_WDW_EXPRESS_ELEVATOR,
                behavior = id_bhvWdwExpressElevatorPlatform,
                spawnOffset = 0,
                spawnYOffset = -200,
            },
            {
                name = "Controllable platform",
                behavior = id_bhvControllablePlatform,
                model = E_MODEL_HMC_METAL_PLATFORM,
                spawnYOffset = -100,
            },
            {
                name = "Checkered platform",
                model = E_MODEL_CHECKERBOARD_PLATFORM,
                behavior = id_bhvStaticCheckeredPlatform,
                spawnOffset = 100,
                spawnYOffset = -100,
            },
            {
                name = "Checkerboard elevator (swings)",
                behavior = id_bhvCheckerboardPlatformSub,
                model = E_MODEL_CHECKERBOARD_PLATFORM,
                spawnOffset = 300,
                spawnYOffset = -200,
            },
            {
                name = "Sliding platform (WF)",
                model = E_MODEL_WF_TOWER_SQUARE_PLATORM,
                behavior = id_bhvWfSlidingPlatform,
            },
            { name = "Pillar base", model = E_MODEL_JRB_FALLING_PILLAR_BASE, behavior = id_bhvPillarBase },
            {
                name = "THI island top",
                model = E_MODEL_THI_HUGE_ISLAND_TOP,
                behavior = id_bhvThiHugeIslandTop,
                spawnYOffset = -100,
                spawnOffset = 50,
            },
        },
    },
    {
        name = "Big Platforms",
        items = {
            -- Logs get pitch ~= 0 when saved
            { behavior = id_bhvTtmRollingLog, model = E_MODEL_TTM_ROLLING_LOG, name = "Log TTM", spawnYOffset = -250 },
            { name = "Log LLL", model = E_MODEL_LLL_ROLLING_LOG, behavior = id_bhvLllRollingLog, spawnYOffset = -250 },
            {
                behavior = id_bhvBitfsSinkingPlatforms,
                model = E_MODEL_BITFS_SINKING_PLATFORMS,
                name = "Sinking Platform",
                spawnOffset = 0,
                spawnYOffset = -100,
            },
            {
                name = "Sinking rectangular platform",
                model = E_MODEL_LLL_SINKING_RECTANGULAR_PLATFORM,
                behavior = id_bhvLllSinkingRectangularPlatform,
            },
            {
                name = "Sinking square platforms",
                model = E_MODEL_LLL_SINKING_SQUARE_PLATFORMS,
                behavior = id_bhvLllSinkingSquarePlatforms,
            },
            {
                name = "Bits octagonal platform",
                model = E_MODEL_BITS_OCTAGONAL_PLATFORM,
                behavior = id_bhvOctagonalPlatformRotating,
                spawnYOffset = -300,
            },
            {
                name = "Seesaw S-shaped",
                model = E_MODEL_BITS_TILTING_W_PLATFORM,
                behavior = id_bhvSeesawPlatform,
                spawnOffset = 1000,
                spawnYOffset = -300,
                spawnLateralOffset = 250,
                spawnYaw = 16384,
                -- spawnYaw = -16384,
                param2nd = 2,
            },
            {
                name = "RR octagonal platform",
                model = E_MODEL_RR_OCTAGONAL_PLATFORM,
                behavior = id_bhvOctagonalPlatformRotating,
                spawnYOffset = -300,
            },
            {
                name = "RR rotating bridge platform",
                model = E_MODEL_RR_ROTATING_BRIDGE_PLATFORM,
                behavior = id_bhvRrRotatingBridgePlatform,
                spawnYOffset = -700,
            },
            {
                behavior = id_bhvSwingPlatform,
                model = E_MODEL_RR_SWINGING_PLATFORM,
                name = "Swing",
                spawnOffset = 700,
                spawnYOffset = 400,
                spawnLateralOffset = 200,
                spawnYaw = 16384,
            },
            {
                name = "Merry go round",
                model = E_MODEL_BBH_MERRY_GO_ROUND,
                behavior = id_bhvMerryGoRound,
                spawnOffset = 300,
            },
            {
                behavior = id_bhvSquishablePlatform,
                model = E_MODEL_BITFS_STRETCHING_PLATFORMS,
                name = "Stretching Platforms",
                spawnOffset = 0,
                spawnYOffset = -120,
                spawnYaw = 16384,
            },
            -- {name = "Koopa race endpoint", model = E_MODEL_KOOPA_FLAG, behavior = id_bhvKoopaRaceEndpoint},
            {
                behavior = id_bhvLllRotatingHexagonalRing,
                model = E_MODEL_LLL_ROTATING_HEXAGONAL_RING,
                name = "Rotating Hexagon (LLL)",
            },
            {
                behavior = id_bhvDorrie,
                model = E_MODEL_DORRIE,
                name = "Sea Dragon",
                spawnOffset = -1000,
                spawnYOffset = -400,
            },
            -- Need to fix it's center in blender
            {
                behavior = id_bhvBowsersSub,
                model = E_MODEL_DDD_BOWSER_SUB,
                name = "Submarine",
                spawnOffset = 1800,
                spawnYOffset = -1000,
                spawnLateralOffset = 4000,
            },
        },
    },
    {
        name = "Elevators",
        items = {
            -- Owls disabled because when they go way up, Mario can get stuck in interaction
            -- { behavior = id_bhvHoot, model = E_MODEL_HOOT,name = "Owl", spawnOffset = 0, action = 1},
            { name = "Ferris wheel", model = E_MODEL_BITS_FERRIS_WHEEL_AXLE, behavior = id_bhvFerrisWheelAxle },
            {
                name = "HMC elevator platform",
                model = E_MODEL_HMC_ELEVATOR_PLATFORM,
                behavior = id_bhvHmcElevatorPlatform,
                spawnOffset = 0,
                spawnYOffset = -80,
            },
            {
                name = "RR elevator platform",
                model = E_MODEL_RR_ELEVATOR_PLATFORM,
                behavior = id_bhvRrElevatorPlatform,
            },
            {
                name = "Mesh elevator",
                model = E_MODEL_BBH_MESH_ELEVATOR,
                behavior = id_bhvMeshElevator,
                spawnOffset = 200,
                spawnYOffset = -50,
            },
            {
                behavior = id_bhvCheckerboardElevatorGroup,
                model = E_MODEL_CHECKERBOARD_PLATFORM,
                name = "Checkerboard Elevator Group",
                spawnYOffset = -80,
            },
            {
                name = "WDW express elevator",
                model = E_MODEL_WDW_EXPRESS_ELEVATOR,
                behavior = id_bhvWdwExpressElevator,
                spawnOffset = 0,
                spawnYOffset = -200,
            },
            {
                name = "Sinking cage platform",
                behavior = id_bhvBitfsSinkingCagePlatform,
                model = E_MODEL_BITFS_SINKING_CAGE_PLATFORM,
                spawnOffset = 200,
                spawnYOffset = -150,
                param2nd = 1
            },
            {
                name = "TTC elevator",
                model = E_MODEL_TTC_ELEVATOR_PLATFORM,
                behavior = id_bhvTTCElevator,
                spawnOffset = 0,
                spawnYOffset = -100,
            },
            -- Disable because no one will use these
            -- {
            --     name = "TTC push block",
            --     model = E_MODEL_TTC_PUSH_BLOCK,
            --     behavior = id_bhvTTCMovingBar,
            --     spawnOffset = 300,
            --     spawnYOffset = -200,
            -- },
            -- {
            --     name = "TTC pit block",
            --     model = E_MODEL_TTC_PIT_BLOCK,
            --     behavior = id_bhvTTCPitBlock,
            --     spawnYOffset = -300,
            -- },
            -- Disabled because sometimes Mario gets teleported way out of bounds
            -- {name = "Pyramid elevator", model = E_MODEL_SSL_PYRAMID_ELEVATOR, behavior = id_bhvPyramidElevator},
        },
    },
    {
        name = "Squares",
        items = {
            { behavior = id_bhvBreakableBox, model = E_MODEL_BREAKABLE_BOX, name = "Breakable Box"},
            { behavior = id_bhvBreakableBox, model = E_MODEL_BREAKABLE_BOX, name = "Breakable Box (Big)", param2nd = 3 },
            {
                behavior = id_bhvTTCRotatingSolid,
                model = E_MODEL_TTC_ROTATING_CUBE,
                name = "Rotating Cube",
                spawnYOffset = 0,
            },
            {
                behavior = id_bhvPushableMetalBox,
                model = E_MODEL_METAL_BOX,
                name = "Metal Box",
                spawnOffset = 200,
                spawnYOffset = 0,
            },
            { behavior = id_bhvBreakableBox, model = E_MODEL_ERROR_MODEL, name = "ERROR" },
            { name = "Breakable box small", behavior = id_bhvBreakableBoxSmall, model = E_MODEL_BREAKABLE_BOX_SMALL },
            { name = "JRB floating box", model = E_MODEL_JRB_SLIDING_BOX, behavior = id_bhvJrbFloatingBox, spawnYOffset = 100 },
            {
                name = "Staircase step",
                model = E_MODEL_BBH_STAIRCASE_STEP,
                behavior = id_bhvHiddenStaircaseStep,
                spawnYOffset = -350,
            },
            {
                name = "Water level pillar",
                model = E_MODEL_CASTLE_WATER_LEVEL_PILLAR,
                behavior = id_bhvWaterLevelPillar,
                spawnOffset = 100,
            },
        },
    },
    {
        name = "Hazards",
        items = {
            -- { behavior = id_bhvMontyMoleRock, model = E_MODEL_PEBBLE, name = "Mole rock", spawnOffset = 150 },
            -- { behavior = id_bhvFlameBowser, model = E_MODEL_PEBBLE, name = "Mole rock", spawnOffset = 150 },
            { name = "Snow mound", model = E_MODEL_SL_SNOW_TRIANGLE, behavior = id_bhvSlidingSnowMound, spawnYaw = 16384},
            { name = "Snow mound pushing you", model = E_MODEL_SL_SNOW_TRIANGLE, behavior = id_bhvSlidingSnowMound, spawnYaw = 16384, spawnOffset = -300},
            { behavior = id_bhvBowserShockWave, model = E_MODEL_BOWSER_WAVE, name = "Shockwave", spawnOffset = 0 },
            { behavior = id_bhvFlame, model = E_MODEL_RED_FLAME, name = "Red Flame", spawnOffset = 200 },
            { name = "Explosion", behavior = id_bhvExplosion, model = E_MODEL_EXPLOSION, spawnOffset = 400 },
            { name = "Blue flame", model = E_MODEL_BLUE_FLAME, behavior = id_bhvFlame },
            { name = "Bowser bomb", behavior = id_bhvBowserBomb, model = E_MODEL_BOWSER_BOMB, spawnYOffset = 200 },
            { name = "Bowser flame", model = E_MODEL_RED_FLAME, behavior = id_bhvFlameBowser },
            { name = "Bouncing fireball spawn", behavior = id_bhvBouncingFireball, model = E_MODEL_ERROR_MODEL },
            -- {name = "Bouncing fireball flame", behavior = id_bhvBouncingFireballFlame, model = E_MODEL_RED_FLAME},
            -- {name = "Moving flames", behavior = id_bhvBetaMovingFlames, model = E_MODEL_RED_FLAME},
            -- {name = "Flame bouncing", model = E_MODEL_RED_FLAME, behavior = id_bhvFlameBouncing},
            {
                name = "Flame moving forward growing",
                model = E_MODEL_RED_FLAME,
                behavior = id_bhvFlameMovingForwardGrowing,
            },
            { name = "Blue flames group", behavior = id_bhvBlueFlamesGroup, model = E_MODEL_BLUE_FLAME },
            { behavior = id_bhvToxBox, model = E_MODEL_SSL_TOX_BOX, name = "Tox-Box" },
            { behavior = id_bhvFlamethrower, model = E_MODEL_STAR, name = "Flamethrower", spawnOffset = 200 },
            { behavior = id_bhvFlamethrower, model = E_MODEL_STAR, name = "Flamethrower (upwards)", spawnOffset = 200, param2nd = 4 },
            { behavior = id_bhvFireSpitter, model = E_MODEL_BOWLING_BALL, name = "Fire Spitter", spawnOffset = 200 },
            { behavior = id_bhvCirclingAmp, model = E_MODEL_AMP, name = "Circling Amp", spawnOffset = 0 },
            { behavior = id_bhvHomingAmp, model = E_MODEL_AMP, name = "Homing Amp", spawnOffset = 300 },
            { behavior = id_bhvBowlingBall, model = E_MODEL_BOWLING_BALL, name = "Bowling Ball", spawnOffset = 300 },
            { name = "Bowling ball pit", model = E_MODEL_BOWLING_BALL, behavior = id_bhvPitBowlingBall },
            {
                name = "Bowling ball spawner",
                model = E_MODEL_BOWLING_BALL,
                behavior = id_bhvThiBowlingBallSpawner,
                spawnYOffset = 150,
            },
            { name = "Grindel", model = E_MODEL_SSL_GRINDEL, behavior = id_bhvGrindel },
            {
                behavior = id_bhvHorizontalGrindel,
                model = E_MODEL_SSL_GRINDEL,
                name = "Moving grindel",
                spawnOffset = 400,
            },
            { behavior = id_bhvBigBoulder, model = E_MODEL_HMC_ROLLING_ROCK, name = "Boulder", spawnOffset = 450 },
            { behavior = id_bhvBulletBill, model = E_MODEL_BULLET_BILL, name = "Bullet Bill spawn", spawnOffset = 400 },
            { behavior = id_bhvLllVolcanoFallingTrap, model = E_MODEL_LLL_VOLCANO_FALLING_TRAP, name = "Wall Trap" },
            { model = E_MODEL_HAUNTED_CHAIR, behavior = id_bhvHauntedChair, name = "Haunted chair", spawnOffset = 300 },
            { name = "Cloud", behavior = id_bhvCloud, model = E_MODEL_FWOOSH },
            {
                name = "Falling pillar",
                model = E_MODEL_JRB_FALLING_PILLAR,
                behavior = id_bhvFallingPillar,
                spawnOffset = 400,
            },
            { name = "Still bowling ball", model = E_MODEL_BOWLING_BALL, behavior = id_bhvFreeBowlingBall },
            {
                name = "Rotating block with fire",
                model = E_MODEL_LLL_ROTATING_BLOCK_FIRE_BARS,
                behavior = id_bhvLllRotatingBlockWithFireBars,
                spawnOffset = 300,
            },
            { name = "JRB sliding box", model = E_MODEL_JRB_SLIDING_BOX, behavior = id_bhvJrbSlidingBox },
        },
    },
    {
        name = "Enemies",
        items = {
            { behavior = id_bhvGoomba, model = E_MODEL_GOOMBA, name = "Goomba", spawnOffset = 200 },
            { behavior = id_bhvGoomba, model = E_MODEL_GOOMBA, name = "Goomba (small)", spawnOffset = 200, param2nd = 2},
            { name = "Goomba triplet spawner", model = E_MODEL_ERROR_MODEL, behavior = id_bhvGoombaTripletSpawner },
            -- { name = "Koopa", model = E_MODEL_KOOPA_WITH_SHELL, behavior = id_bhvKoopa, spawnOffset = 200 },
            { name = "Koopa", model = E_MODEL_KOOPA_WITH_SHELL, behavior = id_bhvKoopa, spawnOffset = 200, param2nd = 1 },
            { name = "Bobomb", behavior = id_bhvBobomb, model = E_MODEL_BLACK_BOBOMB, spawnOffset = 100 },
            { behavior = id_bhvBobomb, model = E_MODEL_BOBOMB_BUDDY, name = "Bobomb Not-Buddy", spawnOffset = 200 },
            { behavior = id_bhvSmallBully, model = E_MODEL_BULLY, name = "Bully", spawnOffset = 100 },
            { name = "Piranha plant", model = E_MODEL_PIRANHA_PLANT, behavior = id_bhvPiranhaPlant },
            { behavior = id_bhvSmallWhomp, model = E_MODEL_WHOMP, name = "Whomp", spawnOffset = 200 },
            { behavior = id_bhvThwomp, model = E_MODEL_THWOMP, name = "Thwomp", spawnOffset = 300 },
            { behavior = id_bhvMadPiano, model = E_MODEL_MAD_PIANO, name = "Piano", spawnOffset = 300 },
            { name = "Thwomp 2", model = E_MODEL_THWOMP, behavior = id_bhvThwomp2 },
            { behavior = id_bhvChuckya, model = E_MODEL_CHUCKYA, name = "Chuckya", spawnOffset = 200 },
            { behavior = id_bhvScuttlebug, model = E_MODEL_SCUTTLEBUG, name = "Scuttlebug", spawnOffset = 200 },
            { behavior = id_bhvFlyGuy, model = E_MODEL_FLYGUY, name = "Fly Guy", spawnOffset = 300 },
            { behavior = id_bhvEnemyLakitu, model = E_MODEL_LAKITU, name = "Lakitu", spawnOffset = 200 },
            { behavior = id_bhvBoo, model = E_MODEL_BOO, name = "Boo", spawnOffset = 300 },
            { behavior = id_bhvSwoop, model = E_MODEL_SWOOP, name = "Bat", spawnOffset = 200 },
            { behavior = id_bhvSnufit, model = E_MODEL_SNUFIT, name = "Snufit", spawnOffset = 200 },
            { behavior = id_bhvKlepto, model = E_MODEL_KLEPTO, name = "Vulture", spawnOffset = 300 },
            { behavior = id_bhvUnagi, model = E_MODEL_UNAGI, name = "Eel" },
            { behavior = id_bhvBubba, model = E_MODEL_BUBBA, name = "Bubba", spawnOffset = 200 },
            { behavior = id_bhvClamShell, model = E_MODEL_CLAM_SHELL, name = "Clam Shell", spawnOffset = 400 },
            { behavior = id_bhvHeaveHo, model = E_MODEL_HEAVE_HO, name = "Heave-Ho", spawnOffset = 200 },
            { name = "Skeeter", model = E_MODEL_SKEETER, behavior = id_bhvSkeeter, spawnOffset = 400 },
            { name = "Spindrift", model = E_MODEL_SPINDRIFT, behavior = id_bhvSpindrift },
            { name = "Book", model = E_MODEL_BOOKEND, behavior = id_bhvFlyingBookend },
            { name = "Moneybag hidden", model = E_MODEL_MONEYBAG, behavior = id_bhvMoneybagHidden },
            -- TODO: To make it work first spawn hole than mole. Can this be fixed?
            { name = "Mole hole (spawn first)", model = E_MODEL_DL_MONTY_MOLE_HOLE, behavior = id_bhvMontyMoleHole },
            { name = "Mole (spawn second)", model = E_MODEL_MONTY_MOLE, behavior = id_bhvMontyMole },
            { name = "Snowman", model = E_MODEL_MR_BLIZZARD, behavior = id_bhvMrBlizzard },
        },
    },
    {
        name = "Big enemies",
        items = {
            { behavior = id_bhvGoomba, model = E_MODEL_GOOMBA, name = "Goomba (big)", spawnOffset = 300, param2nd = 1},
            { name = "Goomba triplet spawner (big)", model = E_MODEL_ERROR_MODEL, behavior = id_bhvGoombaTripletSpawner, param2nd = 1 },
            { behavior = id_bhvChainChomp, model = E_MODEL_CHAIN_CHOMP, name = "Chain Chomp", spawnOffset = 400 },
            {
                behavior = id_bhvBigBully,
                model = E_MODEL_BULLY_BOSS,
                name = "Big Bully",
                spawnOffset = 400,
                spawnYaw = 32768,
                spawnPitch = 0,
                spawnRoll = 0,
            },
            -- {name = "Whomp king", model = E_MODEL_WHOMP, behavior = id_bhvWhompKingBoss, spawnOffset = 500},
            -- { name = "king Bobomb", model = E_MODEL_KING_BOBOMB, behavior = id_bhvKingBobomb },
            { behavior = id_bhvBowser, model = E_MODEL_BOWSER, name = "Bowser" },
            { name = "Bowser2", behavior = id_bhvBowser, model = E_MODEL_BOWSER2 },
            -- {name = "Big bully with minions", behavior = id_bhvBigBullyWithMinions, model = E_MODEL_BULLY_BOSS},
            { behavior = id_bhvBalconyBigBoo, model = E_MODEL_BOO, name = "Balcony big boo", spawnOffset = 300 },
            -- Appears small
            -- { name = "Piranha plant (big)", model = E_MODEL_PIRANHA_PLANT, behavior = id_bhvPiranhaPlant, param2nd = 1 },
        },
    },
    {
        name = "Misc",
        items = {
            {
                behavior = id_bhvCannon,
                model = E_MODEL_CANNON_BASE,
                name = "Cannon",
                spawnYOffset = 0,
                spawnYaw = -16384,
            },
            { behavior = id_bhvJumpingBox, model = E_MODEL_BREAKABLE_BOX_SMALL, name = "Jumping Box" },
            { behavior = id_bhvWhirlpool, model = E_MODEL_DL_WHIRLPOOL, name = "Whirlpool" },
            { behavior = id_bhvSLWalkingPenguin, model = E_MODEL_PENGUIN, name = "Walking Penguin" },
            { name = "Baby penguin", model = E_MODEL_PENGUIN, behavior = id_bhvPenguinBaby },
            { behavior = id_bhvUkiki, model = E_MODEL_UKIKI, name = "Monkey" },
            { name = "Monkey Macro", model = E_MODEL_UKIKI, behavior = id_bhvMacroUkiki },
            -- Commented because this is already part of "Sinking cage platform"
            -- { behavior = id_bhvDDDPole, model = E_MODEL_DDD_POLE, name = "DDD pole" },
            -- { name = "DDD moving pole", behavior = id_bhvDddMovingPole, model = E_MODEL_DDD_POLE },
            { name = "Blue coin switch", behavior = id_bhvBlueCoinSwitch, model = E_MODEL_BLUE_COIN_SWITCH },
            -- {name = "Bowser key", behavior = id_bhvBowserKey, model = E_MODEL_BOWSER_KEY},
            { name = "Chain chomp gate", behavior = id_bhvChainChompGate, model = E_MODEL_BOB_CHAIN_CHOMP_GATE, spawnOffset = 300, spawnYaw = 32768},
            -- Questo sotto può essere interessante
            { name = "Holdable object (test)", behavior = id_bhvBetaHoldableObject, model = E_MODEL_BULLY },
            {
                name = "Arrow lift",
                behavior = id_bhvArrowLift,
                model = E_MODEL_WDW_ARROW_LIFT,
                spawnOffset = 0,
                spawnYOffset = -200,
            },
            {
                name = "Switch animates object",
                model = E_MODEL_PURPLE_SWITCH,
                behavior = id_bhvFloorSwitchAnimatesObject,
            },
            { name = "Switch grills", model = E_MODEL_PURPLE_SWITCH, behavior = id_bhvFloorSwitchGrills },
            { name = "Switch hardcoded", model = E_MODEL_PURPLE_SWITCH, behavior = id_bhvFloorSwitchHardcodedModel },
            {
                name = "Switch hidden objects",
                model = E_MODEL_PURPLE_SWITCH,
                behavior = id_bhvFloorSwitchHiddenObjects,
            },
            { name = "Switch hidden boxes", model = E_MODEL_PURPLE_SWITCH, behavior = id_bhvPurpleSwitchHiddenBoxes },
            { name = "Cap switch base", behavior = id_bhvCapSwitchBase, model = E_MODEL_CAP_SWITCH_BASE },
            -- XXX: Exclamation boxes spawns, for a reason or another, are very heavy
            -- computationally, and it gets worse the more there are. Commented
            -- for this reason
            -- {name = "Exclamation box", behavior = id_bhvExclamationBox, model = E_MODEL_EXCLAMATION_BOX},
        },
    },
    {
        name = "Tilted objects",
        items = {
            {
                name = "T. Wood piece",
                model = E_MODEL_LLL_WOOD_BRIDGE,
                behavior = id_bhvLllWoodPiece,
                spawnYOffset = 100,
                spawnPitch = 16384,
                spawnRoll = 32768,
            },
            {
                name = "T. Sinking rock block",
                model = E_MODEL_LLL_SINKING_ROCK_BLOCK,
                behavior = id_bhvLllSinkingRockBlock,
                spawnOffset = 200,
                spawnYOffset = -200,
                spawnPitch = 16384,
                spawnRoll = 32768,
            },
            {
                behavior = id_bhvTtmRollingLog,
                model = E_MODEL_TTM_ROLLING_LOG,
                name = "T. Log TTM",
                spawnOffset = -100,
                spawnYOffset = -1100,
                spawnRoll = 16384,
            },
            {
                name = "T. Log LLL",
                model = E_MODEL_LLL_ROLLING_LOG,
                behavior = id_bhvLllRollingLog,
                spawnOffset = -100,
                spawnYOffset = -1100,
                spawnRoll = 16384,
            },
            {
                behavior = id_bhvBitfsSinkingPlatforms,
                model = E_MODEL_BITFS_SINKING_PLATFORMS,
                name = "T. Sinking Platform",
                spawnOffset = 200,
                spawnYOffset = 200,
                spawnPitch = 49152,
            },
            {
                name = "T. Sinking rectangular platform",
                model = E_MODEL_LLL_SINKING_RECTANGULAR_PLATFORM,
                behavior = id_bhvLllSinkingRectangularPlatform,
                spawnOffset = 200,
                spawnYOffset = 200,
                spawnPitch = -16384,
            },
            {
                name = "T. Sinking square platforms",
                model = E_MODEL_LLL_SINKING_SQUARE_PLATFORMS,
                behavior = id_bhvLllSinkingSquarePlatforms,
                spawnOffset = 200,
                spawnYOffset = 100,
                spawnPitch = -16384,
            },
        },
    },
    {
        name = "Decorative",
        items = {
            { name = "Haunted bookshelf", model = E_MODEL_BBH_MOVING_BOOKSHELF, behavior = id_bhvHauntedBookshelf },
            { name = "Wooden post", model = E_MODEL_WOODEN_POST, behavior = id_bhvWoodenPost },
            { name = "Bobomb buddy", behavior = id_bhvBobombBuddy, model = E_MODEL_BOBOMB_BUDDY },
            { name = "Bobomb opens cannon", behavior = id_bhvBobombBuddyOpensCannon, model = E_MODEL_BOBOMB_BUDDY },
            { name = "Blue fish", behavior = id_bhvBlueFish, model = E_MODEL_FISH },
            -- Commented because it just flies outside of the map
            -- { name = "Bird", behavior = id_bhvBird, model = E_MODEL_BIRDS },
            { name = "Castle flag", behavior = id_bhvCastleFlagWaving, model = E_MODEL_CASTLE_GROUNDS_FLAG },
            -- {name = "Blue fish many", model = E_MODEL_FISH, behavior = id_bhvManyBlueFishSpawner},
            -- {name = "Fish group", model = E_MODEL_FISH, behavior = id_bhvFishGroup},
            { behavior = id_bhvButterfly, model = E_MODEL_BUTTERFLY, name = "Butterfly" },
            { name = "Hexagon", model = E_MODEL_LLL_ROTATING_HEXAGONAL_RING, behavior = id_bhvLllHexagonalMesh },
            { name = "Koopa shell", model = E_MODEL_KOOPA_SHELL, behavior = id_bhvKoopaShellUnderwater },
            {
                name = "Pendulum",
                behavior = id_bhvDecorativePendulum,
                model = E_MODEL_CASTLE_CLOCK_PENDULUM,
                spawnYOffset = 300,
            },
            {
                name = "TTC pendulum (still)",
                model = E_MODEL_TTC_PENDULUM,
                behavior = id_bhvTTCPendulum,
                spawnYOffset = 500,
            },
            {
                name = "Clock hour hand",
                behavior = id_bhvClockHourHand,
                model = E_MODEL_CASTLE_CLOCK_HOUR_HAND,
                spawnYOffset = 200,
                spawnYaw = 32768,
            },
            {
                name = "Clock minute hand",
                behavior = id_bhvClockMinuteHand,
                model = E_MODEL_CASTLE_CLOCK_MINUTE_HAND,
                spawnYOffset = 200,
                spawnYaw = 32768,
            },
            { name = "Seaweed", model = E_MODEL_SEAWEED, behavior = id_bhvSeaweed },
            { name = "Boo cage", behavior = id_bhvStaticObject, model = E_MODEL_HAUNTED_CAGE },
            { name = "RR cruiser wing", model = E_MODEL_RR_CRUISER_WING, behavior = id_bhvRrCruiserWing },
            { name = "Cannon barrel", behavior = id_bhvCannonBarrel, model = E_MODEL_CANNON_BARREL },
            { name = "Blue smiley", model = E_MODEL_TTM_BLUE_SMILEY, behavior = id_bhvStaticObject },
            { name = "Yellow smiley", model = E_MODEL_TTM_YELLOW_SMILEY, behavior = id_bhvStaticObject },
            { name = "Star smiley", model = E_MODEL_TTM_STAR_SMILEY, behavior = id_bhvStaticObject },
            { name = "Moon smiley", model = E_MODEL_TTM_MOON_SMILEY, behavior = id_bhvStaticObject },
            { name = "Yellow smiley", model = E_MODEL_TTM_YELLOW_SMILEY, behavior = id_bhvStaticObject },
            { name = "Water bomb cannon", model = E_MODEL_CANNON_BASE, behavior = id_bhvWaterBombCannon },
            { name = "HMC red grills", model = E_MODEL_HMC_RED_GRILLS, behavior = id_bhvStaticObject },
            {
                name = "Water level diamond",
                model = E_MODEL_WDW_WATER_LEVEL_DIAMOND,
                behavior = id_bhvWaterLevelDiamond,
            },
            { name = "Yellow ball", model = E_MODEL_YELLOW_SPHERE, behavior = id_bhvYellowBall, spawnYOffset = 100 },
            { name = "Yoshi egg", model = E_MODEL_YOSHI_EGG, behavior = id_bhvAnimatedTexture },
            { name = "Ukiki cage", model = E_MODEL_TTM_STAR_CAGE, behavior = id_bhvUkikiCage, spawnYOffset = 100 },
            { name = "Chest bottom", behavior = id_bhvBetaChestBottom, model = E_MODEL_TREASURE_CHEST_BASE },
            { name = "Chest lid", behavior = id_bhvBetaChestLid, model = E_MODEL_TREASURE_CHEST_LID },
            { name = "Boo key", behavior = id_bhvAlphaBooKey, model = E_MODEL_BETA_BOO_KEY },
            { behavior = id_bhvUnusedFakeStar, model = E_MODEL_STAR, name = "Fake Star", spawnYOffset = 100 },
            { name = "Message panel", model = E_MODEL_WOODEN_SIGNPOST, behavior = id_bhvMessagePanel, spawnYaw = 32768},
            {
                name = "Wind Snowman Head",
                model = E_MODEL_CCM_SNOWMAN_HEAD,
                behavior = id_bhvSLSnowmanWind,
                spawnOffset = 300,
                spawnYOffset = 200,
            },
            {
                name = "Cannonless wall left",
                model = E_MODEL_WF_BREAKABLE_WALL_LEFT,
                behavior = id_bhvWfBreakableWallLeft,
                spawnOffset = 400,
            },
            {
                name = "Cannonless wall right",
                model = E_MODEL_WF_BREAKABLE_WALL_RIGHT,
                behavior = id_bhvWfBreakableWallRight,
                spawnOffset = 400,
            },
            {
                name = "JRB ship left half part",
                model = E_MODEL_JRB_SHIP_LEFT_HALF_PART,
                behavior = id_bhvSunkenShipPart2,
            },
            {
                name = "JRB ship right half part",
                model = E_MODEL_JRB_SHIP_RIGHT_HALF_PART,
                behavior = id_bhvSunkenShipPart2,
            },
            {
                name = "WF solid tower platform",
                model = E_MODEL_WF_TOWER_SQUARE_PLATORM,
                behavior = id_bhvWfSolidTowerPlatform,
                spawnOffset = 100,
                spawnYOffset = -200,
            },
            -- { behavior = id_bhvToadMessage, model = E_MODEL_TOAD, name = "Toad"},
        },
    },
    -- {
    --     name = "New",
    --     items = {
    --     }
    -- },
    {
        name = "Bugged",
        items = {
            -- Wrong hitbox
            -- {
            --     name = "Bitfs elevator (still)",
            --     behavior = id_bhvActivatedBackAndForthPlatform,
            --     model = E_MODEL_BITFS_ELEVATOR,
            --     spawnOffset = 100,
            --     spawnYOffset = -150,
            -- },
            -- Fix direction, also always goes same direction
            { name = "SPINDEL", model = E_MODEL_SSL_SPINDEL, behavior = id_bhvSpindel, spawnYOffset = 200 },
            {
                name = "WF_ROTATING_WOODEN_PLATFORM",
                model = E_MODEL_ERROR_MODEL,
                behavior = id_bhvWfRotatingWoodenPlatform,
            },
            { name = "WF_TUMBLING_BRIDGE", model = E_MODEL_ERROR_MODEL, behavior = id_bhvWfTumblingBridge },
            {
                name = "BITFS_TUMBLING_BRIDGE",
                model = E_MODEL_BITFS_TUMBLING_PLATFORM,
                behavior = id_bhvWfTumblingBridge,
            },
            { name = "POKEY", model = E_MODEL_POKEY_HEAD, behavior = id_bhvPokey },
        },
    },
}

local playerData = {}
local selectedCategory = 1
local selectedObjectInCat = {} -- remembers position inside each submenu
local inSubmenu = false

local function get_player_data(playerIndex)
    if not playerData[playerIndex] then
        playerData[playerIndex] = {
            cooldown = 0,
        }
    end
    return playerData[playerIndex]
end

-- Menu navigation
function move_selection(m)
    local buttons = m.controller.buttonPressed
    if buttons & U_JPAD ~= 0 then
        if inSubmenu then
            selectedObjectInCat[selectedCategory] = (selectedObjectInCat[selectedCategory] or 1) - 1
        else
            selectedCategory = selectedCategory - 1
        end
    elseif buttons & D_JPAD ~= 0 then
        if inSubmenu then
            selectedObjectInCat[selectedCategory] = (selectedObjectInCat[selectedCategory] or 1) + 1
        else
            selectedCategory = selectedCategory + 1
        end
    elseif buttons & L_JPAD ~= 0 then
        if inSubmenu then
            inSubmenu = false
            play_sound(SOUND_MENU_CHANGE_SELECT, m.marioObj.header.gfx.cameraToObject)
            return
        else
            selectedCategory = selectedCategory - 1
        end
    elseif buttons & R_JPAD ~= 0 then
        if not inSubmenu then
            inSubmenu = true
            if not selectedObjectInCat[selectedCategory] then
                selectedObjectInCat[selectedCategory] = 1
            end
            play_sound(SOUND_MENU_CHANGE_SELECT, m.marioObj.header.gfx.cameraToObject)
            return
        else
            -- This commmented code is for submenu change on DRAD right press.
            -- I prefer to advance 5 elements instead
            -- -- next category while in submenu
            -- selectedCategory = selectedCategory + 1
            -- if selectedCategory > #categories then
            --     selectedCategory = 1
            -- end
            -- if not selectedObjectInCat[selectedCategory] then
            --     selectedObjectInCat[selectedCategory] = 1
            -- end
            selectedObjectInCat[selectedCategory] = (selectedObjectInCat[selectedCategory] or 1) + 5
        end
    else
        return
    end

    -- clamp values
    -- if inSubmenu then
    --     local items = categories[selectedCategory].items
    --     selectedObjectInCat[selectedCategory] =
    --         math.max(1, math.min(selectedObjectInCat[selectedCategory] or 1, #items))
    -- else
    --     selectedCategory = math.max(1, math.min(selectedCategory, #categories))
    -- end
    if inSubmenu then
        local items = categories[selectedCategory].items
        local numItems = #items
        if numItems > 0 then
            local sel = selectedObjectInCat[selectedCategory] or 1
            selectedObjectInCat[selectedCategory] = ((sel - 1) % numItems) + 1
        end
    else
        local numCats = #categories
        if numCats > 0 then
            selectedCategory = ((selectedCategory - 1) % numCats) + 1
        end
    end

    play_sound(SOUND_MENU_CHANGE_SELECT, m.marioObj.header.gfx.cameraToObject)
end

function spawn_selected(m)
    if m.controller.buttonPressed & X_BUTTON == 0 then
        return
    end
    if not inSubmenu then
        return
    end -- only spawn when inside a submenu

    local data = get_player_data(m.playerIndex)
    if data.cooldown > 0 then
        return
    end

    local cat = categories[selectedCategory]
    local idx = selectedObjectInCat[selectedCategory] or 1
    local obj = cat.items[idx]
    local name = obj.name

    -- spawn relative to Mario's facing direction + speed bonus + height offset
    -- local baseOffset = obj.spawnOffset or 400
    local baseOffset = obj.spawnOffset or 200
    local forwardVel = m.forwardVel or 0
    local speedBonus = math.max(0, forwardVel) * SPEED_MULTIPLIER
    local effectiveOffset = baseOffset + speedBonus

    local lateralOffset = obj.spawnLateralOffset or 0
    local spawnX = m.pos.x + effectiveOffset * sins(m.faceAngle.y) - lateralOffset * coss(m.faceAngle.y) -- lateral component
    local spawnY = m.pos.y + (obj.spawnYOffset or 0)
    local spawnZ = m.pos.z + effectiveOffset * coss(m.faceAngle.y) + lateralOffset * sins(m.faceAngle.y)

    -- local finalYaw = (m.faceAngle.y + (obj.spawnYaw or 0)) % 0x10000
    local finalYaw = m.faceAngle.y + (obj.spawnYaw or 0)
    local finalPitch
    local finalRoll
    if spawnObjectsUpright then
        finalPitch = obj.spawnPitch or 0
        finalRoll = obj.spawnRoll or 0
    else
        finalPitch = m.faceAngle.x + (obj.spawnPitch or 0)
        finalRoll = m.faceAngle.z + (obj.spawnRoll or 0)
    end

    local o = spawn_sync_object(obj.behavior, obj.model, spawnX, spawnY, spawnZ, function(o)
        -- See KNOWN_BUGS (3) at the top of this file
        -- o.oFlags = o.oFlags & ~OBJ_FLAG_SET_FACE_YAW_TO_MOVE_YAW
        o.oFlags = o.oFlags | OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
        o.oTimer = 0
        -- o.oOpacity = 255  -- not working for ttc objects
        o.oFaceAngleYaw = finalYaw
        o.header.gfx.angle.y = finalYaw
        o.oMoveAngleYaw = finalYaw

        -- -- -- Hoot not grabbable if this code used, but conversation gets skipped
        -- if obj.behavior == id_bhvHoot then
        --   print('imahoot')
        --   o.oIntangibleTimer = 0
        --   o.header.gfx.node.flags = o.header.gfx.node.flags | GRAPH_RENDER_ACTIVE
        --   o.oHootAvailability = HOOT_AVAIL_READY_TO_FLY
        -- end

        o.oFaceAnglePitch = finalPitch
        o.header.gfx.angle.x = finalPitch
        -- o.oMoveAnglePitch = finalPitch
        o.oFaceAngleRoll = finalRoll
        o.header.gfx.angle.z = finalRoll
        -- o.oMoveAngleRoll = finalRoll

        -- o.oBehParams = ((obj.param1 or 0) << 24) | ((obj.param2 or 0) << 16) | ((obj.param3 or 0) << 8) | (obj.param4 or 0)

        -- Fixes cannon yaw
        if obj.behavior == id_bhvCannon then
            o.oBehParams2ndByte = (finalYaw >> 8) & 0xFF
        else
            o.oBehParams2ndByte = obj.param2nd or 0
        end

    end)

    if o then
        -- This section adds spawned object to the recent section
        -- This for is for removing duplicates
        for i = #recentObjs, 1, -1 do
          if recentObjs[i] == obj then
              table.remove(recentObjs, i)
              break
          end
        end

        -- Insert just spawned object in Recent section
        table.insert(recentObjs, 1, obj)

        -- When spawning object from Recent catgeory (selectedCategory == 1),
        -- jump to first position, because spawned object also jumps in first position
        if selectedCategory == 1 then
            selectedObjectInCat[selectedCategory] = 1
        end

        -- No more than MAX_RECENT objects in the Recent section
        if #recentObjs > MAX_RECENT then
          table.remove(recentObjs)
        end
    end

    data.cooldown = COOLDOWN_FRAMES
    djui_popup_create("Spawned \\#FFFF00\\" .. name .. "\\#d5d5d5\\.", 1)
end

-- respawn
hook_chat_command("respawn", "Respawn if you get stuck", function(msg)
    -- local m = gMarioStates[0]
    -- local np = gNetworkPlayers[0]

    -- Respawn
    warp_to_level(TARGET_LEVEL, TARGET_AREA, TARGET_WARP)
    return true

    -- m.health = 0
    -- set_mario_action(m, ACT_DEATH, 0)
    -- return true
end)

hook_event(HOOK_ON_HUD_RENDER, function()
    if gMarioStates[0].action == ACT_DEATH or gMarioStates[0].action == ACT_GAME_OVER then
        return
    end

    -- #RENDERMENU --
    -- This moves the entire menu up or down
    local offsetY = 70

    djui_hud_set_resolution(RESOLUTION_DJUI)

    -- background
    djui_hud_set_color(0, 0, 0, 200)
    -- djui_hud_render_rect(8, 68, 370, 495)
    djui_hud_render_rect(8, 68 + offsetY, 370, 495)

    -- title
    djui_hud_set_color(255, 100, 0, 255)
    if inSubmenu then
        -- djui_hud_print_text(categories[selectedCategory].name:upper(), 20, 78, 1.2)
        djui_hud_print_text(categories[selectedCategory].name:upper(), 20, 78 + offsetY, 1.2)
    else
        -- djui_hud_print_text("OBJECT SPAWNER", 20, 78, 1.2)
        djui_hud_print_text("OBJECT SPAWNER", 20, 78 + offsetY, 1.2)
    end

    local VISIBLE_ITEMS = 15
    -- local startY = 120
    local startY = 120 + offsetY

    if inSubmenu then
        -- show objects inside the selected category
        local items = categories[selectedCategory].items
        local sel = selectedObjectInCat[selectedCategory] or 1
        local startIdx = math.max(1, sel - 7)
        local endIdx = math.min(#items, startIdx + VISIBLE_ITEMS - 1)

        for i = startIdx, endIdx do
            local y = startY + (i - startIdx) * 24
            local text = items[i].name

            if i == sel then
                djui_hud_set_color(255, 255, 0, 255)
                djui_hud_render_rect(15, y, 355, 29)
                djui_hud_set_color(0, 0, 0, 255)
            else
                djui_hud_set_color(255, 255, 255, 230)
            end
            djui_hud_print_text(text, 22, y, 1.0)
        end
    else
        -- main menu: show categories
        local startIdx = math.max(1, selectedCategory - 7)
        local endIdx = math.min(#categories, startIdx + VISIBLE_ITEMS - 1)

        for i = startIdx, endIdx do
            local y = startY + (i - startIdx) * 24
            local text = categories[i].name

            if i == selectedCategory then
                djui_hud_set_color(255, 255, 0, 255)
                djui_hud_render_rect(15, y, 355, 29)
                djui_hud_set_color(0, 0, 0, 255)
            else
                djui_hud_set_color(255, 255, 255, 230)
            end
            djui_hud_print_text(text, 22, y, 1.0)
        end
    end

    djui_hud_set_color(180, 180, 180, 200)
    djui_hud_print_text("D-PAD L/R = submenu    X = spawn", 25, 510 + offsetY, 0.85)
    djui_hud_print_text("Y = delete nearest object", 25, 530 + offsetY, 0.85)

    -- #RENDERCOOLDOWNTIMER --
    local m = gMarioStates[0]
    local data = get_player_data(m.playerIndex)
    if data.cooldown <= 0 then return end

    djui_hud_set_resolution(RESOLUTION_N64)

    local seconds = math.floor(data.cooldown * 10 / 30) / 10
    local text = "Spawn cooldown " .. tostring(seconds) .. "s"

    local scale = 0.32
    local screenWidth = djui_hud_get_screen_width()
    local width = djui_hud_measure_text(text) * scale
    local x = (screenWidth - width) / 2.0
    local y = 8

    -- background box
    djui_hud_set_color(0, 0, 0, 200)
    djui_hud_render_rect(x - 4, y, width + 8, 18)

    -- text
    djui_hud_set_color(255, 255, 255, 255)
    djui_hud_print_text(text, x, y, scale)
end)

hook_event(HOOK_MARIO_UPDATE, function(m)
    -- m.health = 0x880   -- or 0x8FF; both are common "full health" values in SM64 Lua mods
    -- m.health = 0xFFF

    -- Invincibility timer (extra safety)
    -- m.invincTimer = 60

    -- Optional: instantly cancel any death action and put Mario back into idle
    -- local deathActions = {
    --     ACT_DEATH_ON_BACK, ACT_DEATH_ON_STOMACH, ACT_DEATH_PLUNGE,
    --     ACT_QUICKSAND_DEATH, ACT_SUFFOCATION, ACT_WATER_DEATH,
    --     ACT_DROWNING, ACT_ELECTROCUTION, ACT_BURNING_JUMP,
    --     ACT_BURNING_FALL
    -- }
    -- for _, act in ipairs(deathActions) do
    --     if m.action == act then
    --         set_mario_action(m, ACT_IDLE, 0)
    --         break
    --     end
    -- end

    -- cooldown for every player
    local data = get_player_data(m.playerIndex)
    if data.cooldown > 0 then
        data.cooldown = data.cooldown - 1
    end

    -- only local player (index 0) controls the spawn menu
    if m.playerIndex ~= 0 then
        return
    end
    move_selection(m)
    spawn_selected(m)
end)

-- Gives ferris wheel the blue platform instead of error model
local function fix_ferris_wheel(obj)
    obj_set_model_extended(obj, E_MODEL_BITS_BLUE_PLATFORM)

    if obj.parentObj ~= nil then
        obj.oMoveAngleYaw = obj.parentObj.oFaceAngleYaw
    end
end
hook_behavior(id_bhvFerrisWheelPlatform, OBJ_LIST_SURFACE, false, fix_ferris_wheel, nil)

-- Replace chain chomp metallic balls
local function fix_chain_chomp_ball(obj)
    obj_set_model_extended(obj, E_MODEL_METALLIC_BALL)
end
hook_behavior(id_bhvChainChompChainPart, OBJ_LIST_GENACTOR, false, fix_chain_chomp_ball, nil)
local function fix_wooden_post(obj)
    obj_set_model_extended(obj, E_MODEL_WOODEN_POST)
end
hook_behavior(id_bhvWoodenPost, OBJ_LIST_SURFACE, false, fix_wooden_post, nil)

-- Fix sinking cage platform's invisible DDD pole
local function fix_ddd_pole(obj)
    obj_set_model_extended(obj, E_MODEL_DDD_POLE)
    -- obj_set_model_extended(obj, E_MODEL_BITS_BLUE_PLATFORM)
end
-- hook_behavior(id_bhvDDDPole, OBJ_LIST_POLELIKE, false, fix_ddd_pole, nil)
hook_behavior(id_bhvDddMovingPole, OBJ_LIST_POLELIKE, false, fix_ddd_pole, nil)  -- just in case both variants exist

-- Fix Cloud
local function fix_cloud(obj)
    obj_set_model_extended(obj, E_MODEL_MIST)
end
-- hook_behavior(id_bhvCloud, OBJ_LIST_DEFAULT, false, fix_cloud, nil)
hook_behavior(id_bhvCloudPart, OBJ_LIST_DEFAULT, false, fix_cloud, nil)

-- Fix Pokey
-- local function fix_pokey_head(obj)
--     obj_set_model_extended(obj, E_MODEL_POKEY_HEAD)
-- end
local function fix_pokey_body_part(obj)
    obj_set_model_extended(obj, E_MODEL_POKEY_BODY_PART)
end
-- hook_behavior(id_bhvPokey, OBJ_LIST_GENACTOR, false, fix_pokey_head, nil)
-- hook_behavior(id_bhvPokey, OBJ_LIST_DEFAULT,  false, fix_pokey_head, nil)
hook_behavior(id_bhvPokeyBodyPart, OBJ_LIST_GENACTOR, false, fix_pokey_body_part, nil)
-- hook_behavior(id_bhvPokeyBodyPart, OBJ_LIST_DEFAULT,  false, fix_pokey_body_part, nil)

-- Not working
-- -- Fix tumbling bridge pieces
-- local function fix_tumbling_bridge(obj)
--     -- obj_set_model_extended(obj, E_MODEL_BITFS_TUMBLING_PLATFORM)
--     obj_set_model_extended(obj, E_MODEL_BITFS_TUMBLING_PLATFORM_PART)
--     obj.oFlags = obj.oFlags | OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
-- end
-- hook_behavior(id_bhvTumblingBridgePlatform, OBJ_LIST_SURFACE, false, fix_tumbling_bridge, nil)

function fix_snow_mound_init(o)
    o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    -- Object intangible is collisionData not declared (don't know why)
    o.collisionData = gGlobalObjectCollisionData.sl_seg7_collision_sliding_snow_mound
    o.oCollisionDistance = 1500
end
-- Replace origina behavior so that snow mound goes in the direction Mario is facing
function fix_snow_mound_loop(o)
    local yaw = o.oMoveAngleYaw - 16384

    o.oFlags = o.oFlags | OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    -- o.oIntangibleTimer = 0

    if o.oAction == 0 then
        local speed = 40.0
        o.oVelX = speed * sins(yaw)
        o.oVelZ = speed * coss(yaw)
        o.oPosX = o.oPosX + o.oVelX
        o.oPosZ = o.oPosZ + o.oVelZ

        if o.oTimer > 117 then
            o.oAction = 1
        end
    elseif o.oAction == 1 then
        local speed = 5.0
        o.oVelX = speed * sins(yaw)
        o.oVelZ = speed * coss(yaw)
        o.oVelY = -10.0

        o.oPosX = o.oPosX + o.oVelX
        o.oPosZ = o.oPosZ + o.oVelZ
        o.oPosY = o.oPosY + o.oVelY

        if o.oTimer > 50 then
            o.activeFlags = ACTIVE_FLAG_DEACTIVATED
        end
    end

    -- cur_obj_move_using_vel()
    load_object_collision_model()
end
-- hook_behavior(id_bhvSlidingSnowMound, OBJ_LIST_SURFACE, true, nil, fix_snow_mound_loop)
hook_behavior(id_bhvSlidingSnowMound, OBJ_LIST_SURFACE, true, fix_snow_mound_init, fix_snow_mound_loop)
