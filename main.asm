INCLUDE "constants.asm"

; the rst vectors are unused
SECTION "rst00",HOME[0]
	db $FF
SECTION "rst08",HOME[8]
	db $FF
SECTION "rst10",HOME[$10]
	db $FF
SECTION "rst18",HOME[$18]
	db $FF
SECTION "rst20",HOME[$20]
	db $FF
SECTION "rst28",HOME[$28]
	db $FF
SECTION "rst30",HOME[$30]
	db $FF
SECTION "rst38",HOME[$38]
	db $FF

; interrupts
SECTION "vblank",HOME[$40]
	jp VBlankHandler
SECTION "lcdc",HOME[$48]
	db $FF
SECTION "timer",HOME[$50]
	jp $2306
SECTION "serial",HOME[$58]
	jp $2125
SECTION "joypad",HOME[$60]
	reti

SECTION "bank0",HOME[$61]

DisableLCD: ; $0061
	xor a
	ld [$ff0f],a
	ld a,[$ffff]
	ld b,a
	res 0,a
	ld [$ffff],a
.jr0\@
	ld a,[$ff44]
	cp a,$91
	jr nz,.jr0\@
	ld a,[$ff40]
	and a,$7f	; res 7,a
	ld [$ff40],a
	ld a,b
	ld [$ffff],a
	ret

EnableLCD: ; $007b
	ld a,[$ff40]
	set 7,a
	ld [$ff40],a
	ret

CleanLCD_OAM: ; $0082
	xor a
	ld hl,$c300
	ld b,$a0
.jr0\@
	ld [hli],a
	dec b
	jr nz,.jr0\@
	ret

ResetLCD_OAM: ; $008d
	ld a,$a0
	ld hl,$c300
	ld de,$0004
	ld b,$28
.jr0\@
	ld [hl],a
	add hl,de
	dec b
	jr nz,.jr0\@
	ret

FarCopyData: ; 009D
; copy bc bytes of data from a:hl to de
	ld [$CEE9],a ; save future bank # for later
	ld a,[$FFB8] ; get current bank #
	push af
	ld a,[$CEE9] ; get future bank #, switch
	ld [$FFB8],a
	ld [$2000],a
	call CopyData
	pop af       ; okay, done, time to switch back
	ld [$FFB8],a
	ld [$2000],a
	ret
CopyData: ; 00B5
; copy bc bytes of data from hl to de
	ld a,[hli]
	ld [de],a
	inc de
	dec bc
	ld a,c
	or b
	jr nz,CopyData
	ret

SECTION "romheader",HOME[$100]
nop
jp Start

Section "start",HOME[$150]
Start: ; 0x150
	cp $11 ; value that indicates Gameboy Color
	jr z,.gbcDetected\@
	xor a
	jr .storeValue\@
.gbcDetected\@
	ld a,$00
.storeValue\@
	ld [$cf1a],a ; same value ($00) either way
	jp InitGame

; this function directly reads the joypad I/O register
; it reads many times in order to give the joypad a chance to stabilize
; it saves a result in [$fff8] in the following format
; (set bit indicates pressed button)
; bit 0 - A button
; bit 1 - B button
; bit 2 - Select button
; bit 3 - Start button
; bit 4 - Right
; bit 5 - Left
; bit 6 - Up
; bit 7 - Down
ReadJoypadRegister: ; 15F
	ld a,%00100000 ; select direction keys
	ld c,$00
	ld [rJOYP],a
	ld a,[rJOYP]
	ld a,[rJOYP]
	ld a,[rJOYP]
	ld a,[rJOYP]
	ld a,[rJOYP]
	ld a,[rJOYP]
	cpl ; complement the result so that a set bit indicates a pressed key
	and a,%00001111
	swap a ; put direction keys in upper nibble
	ld b,a
	ld a,%00010000 ; select button keys
	ld [rJOYP],a
	ld a,[rJOYP]
	ld a,[rJOYP]
	ld a,[rJOYP]
	ld a,[rJOYP]
	ld a,[rJOYP]
	ld a,[rJOYP]
	ld a,[rJOYP]
	ld a,[rJOYP]
	ld a,[rJOYP]
	ld a,[rJOYP]
	cpl ; complement the result so that a set bit indicates a pressed key
	and a,%00001111
	or b ; put button keys in lower nibble
	ld [$fff8],a ; save joypad state
	ld a,%00110000 ; unselect all keys
	ld [rJOYP],a
	ret

; function to update the joypad state variables
; output:
; [$ffb2] = keys released since last time
; [$ffb3] = keys pressed since last time
; [$ffb4] = currently pressed keys
GetJoypadState: ; 19A
	ld a, [$ffb8]
	push af
	ld a,$3
	ld [$ffb8],a
	ld [$2000],a
	call $4000
	pop af
	ld [$ff00+$b8],a
	ld [$2000],a
	ret

; see also MapHeaderBanks
MapHeaderPointers: ; $01AE
	dw PalletTown_h
	dw ViridianCity_h
	dw PewterCity_h
	dw CeruleanCity_h
	dw LavenderTown_h
	dw VermilionCity_h
	dw CeladonCity_h
	dw FuchsiaCity_h
	dw CinnabarIsland_h
	dw IndigoPlateau_h
	dw SaffronCity_h
	dw SaffronCity_h
	dw Route1_h
	dw Route2_h
	dw Route3_h
	dw Route4_h
	dw Route5_h
	dw Route6_h
	dw Route7_h
	dw Route8_h
	dw Route9_h
	dw Route10_h
	dw Route11_h
	dw Route12_h
	dw Route13_h
	dw Route14_h
	dw Route15_h
	dw Route16_h
	dw Route17_h
	dw Route18_h
	dw Route19_h
	dw Route20_h
	dw Route21_h
	dw Route22_h
	dw Route23_h
	dw Route24_h
	dw Route25_h
	dw RedsHouse1F_h
	dw RedsHouse2F_h
	dw BluesHouse_h
	dw OaksLab_h ;id=40
	dw ViridianPokecenter_h
	dw ViridianMart_h
	dw School_h
	dw ViridianHouse_h
	dw ViridianGym_h
	dw DiglettsCaveRoute2_h
	dw ViridianForestexit_h
	dw Route2House_h
	dw Route2Gate_h
	dw ViridianForestEntrance_h ;id=50
	dw ViridianForest_h
	dw MuseumF1_h
	dw MuseumF2_h
	dw PewterGym_h
	dw PewterHouse1_h
	dw PewterMart_h
	dw PewterHouse2_h
	dw PewterPokecenter_h
	dw MtMoon1_h
	dw MtMoon2_h ;id=60
	dw MtMoon3_h
	dw CeruleanHouseTrashed_h
	dw CeruleanHouse2_h
	dw CeruleanPokecenter_h
	dw CeruleanGym_h
	dw BikeShop_h
	dw CeruleanMart_h
	dw MtMoonPokecenter_h
	dw CeruleanHouseTrashed_h ; copy
	dw Route5Gate_h
	dw UndergroundTunnelEntranceRoute5_h
	dw DayCareM_h
	dw Route6Gate_h
	dw UndergroundTunnelEntranceRoute6_h
	dw UndergroundTunnelEntranceRoute6_h ; unused
	dw Route7Gate_h
	dw UndergroundPathEntranceRoute7_h
	dw $575d
	dw Route8Gate_h
	dw UndergroundPathEntranceRoute8_h ;id=80
	dw RockTunnelPokecenter_h
	dw RockTunnel1_h
	dw PowerPlant_h
	dw Route11Gate_h
	dw DiglettsCaveEntranceRoute11_h
	dw Route11GateUpstairs_h
	dw Route12Gate_h
	dw BillsHouse_h
	dw VermilionPokecenter_h
	dw FanClub_h ;id=90
	dw VermilionMart_h
	dw VermilionGym_h
	dw VermilionHouse1_h
	dw VermilionDock_h
	dw SSAnne1_h
	dw SSAnne2_h
	dw SSAnne3_h
	dw SSAnne4_h
	dw SSAnne5_h
	dw SSAnne6_h ;id=100
	dw SSAnne7_h
	dw SSAnne8_h
	dw SSAnne9_h
	dw SSAnne10_h
	dw Lance_h ; unused
	dw Lance_h ; unused
	dw Lance_h ; unused
	dw VictoryRoad1_h
	dw Lance_h ; unused
	dw Lance_h ; unused ;id=110
	dw Lance_h ; unused
	dw Lance_h ; unused
	dw Lance_h
	dw Lance_h ; unused
	dw Lance_h ; unused
	dw Lance_h ; unused
	dw Lance_h ; unused
	dw HallofFameRoom_h
	dw UndergroundPathNS_h
	dw Gary_h ;id=120
	dw UndergroundPathWE_h
	dw CeladonMart1_h
	dw CeladonMart2_h
	dw CeladonMart3_h
	dw CeladonMart4_h
	dw CeladonMartRoof_h
	dw CeladonMartElevator_h
	dw CeladonMansion1_h
	dw CeladonMansion2_h
	dw CeladonMansion3_h ;id=130
	dw CeladonMansion4_h
	dw CeladonMansion5_h
	dw CeladonPokecenter_h
	dw CeladonGym_h
	dw CeladonGameCorner_h
	dw CeladonMart5_h
	dw CeladonPrizeRoom_h
	dw CeladonDiner_h
	dw CeladonHouse_h
	dw CeladonHotel_h ;id=140
	dw LavenderPokecenter_h
	dw PokemonTower1_h
	dw PokemonTower2_h
	dw PokemonTower3_h
	dw PokemonTower4_h
	dw PokemonTower5_h
	dw PokemonTower6_h
	dw PokemonTower7_h
	dw LavenderHouse1_h
	dw LavenderMart_h ;id=150
	dw LavenderHouse2_h
	dw FuchsiaMart_h
	dw FuchsiaHouse1_h
	dw FuchsiaPokecenter_h
	dw FuchsiaHouse2_h
	dw SafariZoneEntrance_h
	dw FuchsiaGym_h
	dw FuchsiaMeetingRoom_h
	dw SeafoamIslands2_h
	dw SeafoamIslands3_h ;id=160
	dw SeafoamIslands4_h
	dw SeafoamIslands5_h
	dw VermilionHouse2_h
	dw FuchsiaHouse3_h
	dw Mansion1_h
	dw CinnabarGym_h
	dw Lab1_h
	dw Lab2_h
	dw Lab3_h
	dw Lab4_h ;id=170
	dw CinnabarPokecenter_h
	dw CinnabarMart_h
	dw CinnabarMart_h ; unused
	dw IndigoPlateauLobby_h
	dw CopycatsHouseF1_h
	dw CopycatsHouseF2_h
	dw FightingDojo_h
	dw SaffronGym_h
	dw SaffronHouse1_h
	dw SaffronMart_h ;id=180
	dw SilphCo1_h
	dw SaffronPokecenter_h
	dw SaffronHouse2_h
	dw Route15Gate_h
	dw $563e
	dw Route16GateMap_h
	dw Route16GateUpstairs_h
	dw Route16House_h
	dw Route12House_h
	dw Route18Gate_h ;id=190
	dw Route18GateHeader_h
	dw SeafoamIslands1_h
	dw Route22Gate_h
	dw VictoryRoad2_h
	dw Route12GateUpstairs_h
	dw VermilionHouse3_h
	dw DiglettsCave_h
	dw VictoryRoad3_h
	dw RocketHideout1_h
	dw RocketHideout2_h ;200
	dw RocketHideout3_h
	dw RocketHideout4_h
	dw RocketHideoutElevator_h
	dw RocketHideoutElevator_h ; unused
	dw RocketHideoutElevator_h ; unused
	dw RocketHideoutElevator_h ; unused
	dw SilphCo2_h
	dw SilphCo3_h
	dw SilphCo4_h
	dw SilphCo5_h ;210
	dw SilphCo6_h
	dw SilphCo7_h
	dw SilphCo8_h
	dw Mansion2_h
	dw Mansion3_h
	dw Mansion4_h
	dw SafariZoneEast_h
	dw SafariZoneNorth_h
	dw SafariZoneWest_h
	dw SafariZoneCenter_h ;220
	dw SafariZoneRestHouse1_h
	dw SafariZoneSecretHouse_h
	dw SafariZoneRestHouse2_h
	dw SafariZoneRestHouse3_h
	dw SafariZoneRestHouse4_h
	dw UnknownDungeon2_h
	dw UnknownDungeon3_h
	dw UnknownDungeon1_h
	dw NameRater_h
	dw CeruleanHouse3_h
	dw Route16GateMap_h ; unused
	dw RockTunnel2_h
	dw SilphCo9_h
	dw SilphCo10_h
	dw SilphCo11_h
	dw SilphCoElevator_h
	dw SilphCo2_h ; unused
	dw SilphCo2_h ; unused
	dw BattleCenterM_h
	dw TradeCenterM_h
	dw SilphCo2_h ; unused
	dw SilphCo2_h ; unused
	dw SilphCo2_h ; unused
	dw SilphCo2_h ; unused
	dw Lorelei_h
	dw Bruno_h
	dw Agatha_h ;247

; this function calls a function that takes necessary actions
; at the beginning of each overworld loop iteration as the player jumps
; down a ledge
; it also ends the jump when it's completed
HandleMidJump: ; 39E
	ld b,$1c
	ld hl,$487e
	jp Bankswitch

; this is jumped to immediately after loading a save / starting a new game / loading a new map
EnterMap: ; 3A6
	ld a,$ff
	ld [$cd6b],a
	call LoadMapData ; load map data
	ld b,$03
	ld hl,$4335
	call Bankswitch ; initialize some variables
	ld hl,$d72c
	bit 0,[hl]
	jr z,.doNotCountSteps\@
	ld a,$03
	ld [$d13c],a ; some kind of step counter (counts up to 3 steps?)
.doNotCountSteps\@
	ld hl,$d72e
	bit 5,[hl] ; did a battle happen immediately before this?
	res 5,[hl] ; unset the "battle just happened" flag
	call z,$12e7
	call nz,MapEntryAfterBattle
	ld hl,$d732
	ld a,[hl]
	and a,$18
	jr z,.didNotFlyOrTeleportIn\@
	res 3,[hl]
	ld b,$1c
	ld hl,$4510
	call Bankswitch ; display fly/teleport in graphical effect
	call $2429 ; move sprites
.didNotFlyOrTeleportIn\@
	ld b,$03
	ld hl,$438b
	call Bankswitch ; handle currents in SF islands and forced bike riding in cycling road
	ld hl,$d72d
	res 5,[hl]
	call $2429 ; move sprites
	ld hl,$d126
	set 5,[hl]
	set 6,[hl]
	xor a
	ld [$cd6b],a

OverworldLoop: ; 3FF
	call DelayFrame
OverworldLoopLessDelay: ; 402
	call DelayFrame
	call LoadGBPal
	ld a,[$d736]
	bit 6,a ; jumping down a ledge?
	call nz, HandleMidJump
	ld a,[W_WALKCOUNTER]
	and a
	jp nz,.moveAhead\@ ; if the player sprite has not yet completed the walking animation
	call GetJoypadStateOverworld ; get joypad state (which is possibly simulated)
	ld b,$07
	ld hl,$6988
	call Bankswitch
	ld a,[$da46]
	and a
	jp nz,WarpFound2
	ld hl,$d72d
	bit 3,[hl]
	res 3,[hl]
	jp nz,WarpFound2
	ld a,[$d732]
	and a,$18
	jp nz,HandleFlyOrTeleportAway
	ld a,[W_CUROPPONENT]
	and a
	jp nz,.newBattle\@
	ld a,[$d730]
	bit 7,a ; are we simulating button presses?
	jr z,.notSimulating\@
	ld a,[$ffb4]
	jr .checkIfStartIsPressed\@
.notSimulating\@
	ld a,[$ffb3]
.checkIfStartIsPressed\@
	bit 3,a ; start button
	jr z,.startButtonNotPressed\@
; if START is pressed
	xor a
	ld [$ff8c],a ; the $2920 ID for the start menu is 0
	jp .displayDialogue\@
.startButtonNotPressed\@
	bit 0,a ; A button
	jp z,.checkIfDownButtonIsPressed\@
; if A is pressed
	ld a,[$d730]
	bit 2,a
	jp nz,.noDirectionButtonsPressed\@
	call $30fd
	jr nz,.checkForOpponent\@
	call $3eb5 ; check for hidden items, PC's, etc.
	ld a,[$ffeb]
	and a
	jp z,OverworldLoop
	call IsSpriteOrSignInFrontOfPlayer ; check for sign or sprite in front of the player
	ld a,[$ff8c] ; $2920 ID for NPC/sign text, if any
	and a
	jp z,OverworldLoop
.displayDialogue\@
	ld a,$35
	call Predef ; check what is in front of the player
	call $2429 ; move sprites
	ld a,[$cd60]
	bit 2,a
	jr nz,.checkForOpponent\@
	bit 0,a
	jr nz,.checkForOpponent\@
	ld a,[$c45c]
	ld [$cf0e],a
	call $2920 ; display either the start menu or the NPC/sign text
	ld a,[$cc47]
	and a
	jr z,.checkForOpponent\@
	dec a
	ld a,$00
	ld [$cc47],a
	jr z,.changeMap\@
	ld a,$52
	call Predef
	ld a,[W_CURMAP]
	ld [$d71a],a
	call $62ce
	ld a,[W_CURMAP]
	call SwitchToMapRomBank ; switch to the ROM bank of the current map
	ld hl,$d367
	set 7,[hl]
.changeMap\@
	jp EnterMap
.checkForOpponent\@
	ld a,[W_CUROPPONENT]
	and a
	jp nz,.newBattle\@
	jp OverworldLoop
.noDirectionButtonsPressed\@
	ld hl,$cd60
	res 2,[hl]
	call $2429 ; move sprites
	ld a,$01
	ld [$cc4b],a
	ld a,[$d528] ; the direction that was pressed last time
	and a
	jp z,OverworldLoop
; if a direction was pressed last time
	ld [$d529],a ; save the last direction
	xor a
	ld [$d528],a ; zero the direction
	jp OverworldLoop
.checkIfDownButtonIsPressed\@
	ld a,[$ffb4] ; current joypad state
	bit 7,a ; down button
	jr z,.checkIfUpButtonIsPressed\@
	ld a,$01
	ld [$c103],a
	ld a,$04
	jr .handleDirectionButtonPress\@
.checkIfUpButtonIsPressed\@
	bit 6,a ; up button
	jr z,.checkIfLeftButtonIsPressed\@
	ld a,$ff
	ld [$c103],a
	ld a,$08
	jr .handleDirectionButtonPress\@
.checkIfLeftButtonIsPressed\@
	bit 5,a ; left button
	jr z,.checkIfRightButtonIsPressed\@
	ld a,$ff
	ld [$c105],a
	ld a,$02
	jr .handleDirectionButtonPress\@
.checkIfRightButtonIsPressed\@
	bit 4,a ; right button
	jr z,.noDirectionButtonsPressed\@
	ld a,$01
	ld [$c105],a
.handleDirectionButtonPress\@
	ld [$d52a],a ; new direction
	ld a,[$d730]
	bit 7,a ; are we simulating button presses?
	jr nz,.noDirectionChange\@ ; ignore direction changes if we are
	ld a,[$cc4b]
	and a
	jr z,.noDirectionChange\@
	ld a,[$d52a] ; new direction
	ld b,a
	ld a,[$d529] ; old direction
	cp b
	jr z,.noDirectionChange\@
; the code below is strange
; it computes whether or not the player did a 180 degree turn, but then overwrites the result
; also, it does a seemingly pointless loop afterwards
	swap a ; put old direction in upper half
	or b ; put new direction in lower half
	cp a,$48 ; change dir from down to up
	jr nz,.notDownToUp\@
	ld a,$02
	ld [$d528],a
	jr .oddLoop\@
.notDownToUp\@
	cp a,$84 ; change dir from up to down
	jr nz,.notUpToDown\@
	ld a,$01
	ld [$d528],a
	jr .oddLoop\@
.notUpToDown\@
	cp a,$12 ; change dir from right to left
	jr nz,.notRightToLeft\@
	ld a,$04
	ld [$d528],a
	jr .oddLoop\@
.notRightToLeft\@
	cp a,$21 ; change dir from left to right
	jr nz,.oddLoop\@
	ld a,$08
	ld [$d528],a
.oddLoop\@
	ld hl,$cd60
	set 2,[hl]
	ld hl,$cc4b
	dec [hl]
	jr nz,.oddLoop\@
	ld a,[$d52a]
	ld [$d528],a
	call NewBattle
	jp c,.battleOccurred\@
	jp OverworldLoop
.noDirectionChange\@
	ld a,[$d52a] ; current direction
	ld [$d528],a ; save direction
	call $2429 ; move sprites
	ld a,[$d700]
	cp a,$02 ; surfing
	jr z,.surfing\@
; not surfing
	call CollisionCheckOnLand
	jr nc,.noCollision\@
	push hl
	ld hl,$d736
	bit 2,[hl]
	pop hl
	jp z,OverworldLoop
	push hl
	call ExtraWarpCheck ; sets carry if there is a potential to warp
	pop hl
	jp c,CheckWarpsCollision
	jp OverworldLoop
.surfing\@
	call CollisionCheckOnWater
	jp c,OverworldLoop
.noCollision\@
	ld a,$08
	ld [W_WALKCOUNTER],a
	jr .moveAhead2\@
.moveAhead\@
	ld a,[$d736]
	bit 7,a
	jr z,.noSpinning\@
	ld b,$11
	ld hl,$4fd7
	call Bankswitch ; spin while moving
.noSpinning\@
	call $2429 ; move sprites
.moveAhead2\@
	ld hl,$cd60
	res 2,[hl]
	ld a,[$d700]
	dec a ; riding a bike?
	jr nz,.normalPlayerSpriteAdvancement\@
	ld a,[$d736]
	bit 6,a ; jumping a ledge?
	jr nz,.normalPlayerSpriteAdvancement\@
	call BikeSpeedup ; if riding a bike and not jumping a ledge
.normalPlayerSpriteAdvancement\@
	call AdvancePlayerSprite
	ld a,[W_WALKCOUNTER]
	and a
	jp nz,CheckMapConnections ; it seems like this check will never succeed (the other place where CheckMapConnections is run works)
; walking animation finished
	ld a,[$d730]
	bit 7,a
	jr nz,.doneStepCounting\@ ; if button presses are being simulated, don't count steps
; step counting
	ld hl,$d13b ; step counter
	dec [hl]
	ld a,[$d72c]
	bit 0,a
	jr z,.doneStepCounting\@
	ld hl,$d13c
	dec [hl]
	jr nz,.doneStepCounting\@
	ld hl,$d72c
	res 0,[hl]
.doneStepCounting\@
	ld a,[$d790]
	bit 7,a ; in the safari zone?
	jr z,.notSafariZone\@
	ld b,$07
	ld hl,$6997
	call Bankswitch
	ld a,[$da46]
	and a
	jp nz,WarpFound2
.notSafariZone\@
	ld a,[W_ISINBATTLE]
	and a
	jp nz,CheckWarpsNoCollision
	ld a,$13
	call Predef ; decrement HP of poisoned pokemon
	ld a,[$d12d]
	and a
	jp nz,HandleBlackOut ; if all pokemon fainted
.newBattle\@
	call NewBattle
	ld hl,$d736
	res 2,[hl]
	jp nc,CheckWarpsNoCollision ; check for warps if there was no battle
.battleOccurred\@
	ld hl,$d72d
	res 6,[hl]
	ld hl,$d733
	res 3,[hl]
	ld hl,$d126
	set 5,[hl]
	set 6,[hl]
	xor a
	ld [$ffb4],a ; clear joypad state
	ld a,[W_CURMAP]
	cp a,CINNABAR_GYM
	jr nz,.notCinnabarGym\@
	ld hl,$d79b
	set 7,[hl]
.notCinnabarGym\@
	ld hl,$d72e
	set 5,[hl]
	ld a,[W_CURMAP]
	cp a,OAKS_LAB
	jp z,.noFaintCheck\@
	ld hl,$4a83
	ld b,$0f
	call Bankswitch ; check if all the player's pokemon fainted
	ld a,d
	and a
	jr z,.allPokemonFainted\@
.noFaintCheck\@
	ld c,$0a
	call DelayFrames
	jp EnterMap
.allPokemonFainted\@
	ld a,$ff
	ld [$d057],a
	call RunMapScript
	jp HandleBlackOut

; function to determine if there will be a battle and execute it (either a trainer battle or wild battle)
; sets carry if a battle occurred and unsets carry if not
NewBattle: ; 683
	ld a,[$d72d]
	bit 4,a
	jr nz,.noBattle\@
	call $30fd
	jr nz,.noBattle\@
	ld a,[$d72e]
	bit 4,a
	jr nz,.noBattle\@
	ld b,$0f
	ld hl,$6f12
	jp Bankswitch ; determines if a battle will occurr and runs the battle if so
.noBattle\@
	and a
	ret

; function to make bikes twice as fast as walking
BikeSpeedup: ; 6A0
	ld a,[$cc57]
	and a
	ret nz
	ld a,[W_CURMAP]
	cp a,ROUTE_17 ; Cycling Road
	jr nz,.goFaster\@
	ld a,[$ffb4] ; current joypad state
	and a,%01110000 ; bit mask for up, left, right buttons
	ret nz
.goFaster\@
	jp AdvancePlayerSprite

; check if the player has stepped onto a warp after having not collided
CheckWarpsNoCollision: ; 6B4
	ld a,[$d3ae] ; number of warps
	and a
	jp z,CheckMapConnections
	ld a,[$d3ae] ; number of warps
	ld b,$00
	ld c,a
	ld a,[W_YCOORD]
	ld d,a
	ld a,[W_XCOORD]
	ld e,a
	ld hl,$d3af ; start of warp entries
CheckWarpsNoCollisionLoop: ; 6CC
	ld a,[hli] ; check if the warp's Y position matches
	cp d
	jr nz,CheckWarpsNoCollisionRetry1
	ld a,[hli] ; check if the warp's X position matches
	cp e
	jr nz,CheckWarpsNoCollisionRetry2
; if a match was found
	push hl
	push bc
	ld hl,$d736
	set 2,[hl]
	ld b,$03
	ld hl,$449d
	call Bankswitch ; check if the player sprite is standing on a "door" tile
	pop bc
	pop hl
	jr c,WarpFound1 ; if it is, go to 0735
	push hl
	push bc
	call ExtraWarpCheck ; sets carry if the warp is confirmed
	pop bc
	pop hl
	jr nc,CheckWarpsNoCollisionRetry2
; if the extra check passed
	ld a,[$d733]
	bit 2,a
	jr nz,WarpFound1
	push de
	push bc
	call GetJoypadState
	pop bc
	pop de
	ld a,[$ffb4] ; current joypad state
	and a,%11110000 ; bit mask for directional buttons
	jr z,CheckWarpsNoCollisionRetry2 ; if directional buttons aren't being pressed, do not pass through the warp
	jr WarpFound1

; check if the player has stepped onto a warp after having collided
CheckWarpsCollision: ; 706
	ld a,[$d3ae] ; number of warps
	ld c,a
	ld hl,$d3af ; start of warp entries
.loop\@
	ld a,[hli] ; Y coordinate of warp
	ld b,a
	ld a,[W_YCOORD]
	cp b
	jr nz,.retry1\@
	ld a,[hli] ; X coordinate of warp
	ld b,a
	ld a,[W_XCOORD]
	cp b
	jr nz,.retry2\@
	ld a,[hli]
	ld [$d42f],a ; save target warp ID
	ld a,[hl]
	ld [$ff8b],a ; save target map
	jr WarpFound2
.retry1\@
	inc hl
.retry2\@
	inc hl
	inc hl
	dec c
	jr nz,.loop\@
	jp OverworldLoop

CheckWarpsNoCollisionRetry1: ; 72F
	inc hl
CheckWarpsNoCollisionRetry2: ; 730
	inc hl
	inc hl
	jp ContinueCheckWarpsNoCollisionLoop

WarpFound1: ; 735
	ld a,[hli]
	ld [$d42f],a ; save target warp ID
	ld a,[hli]
	ld [$ff8b],a ; save target map

WarpFound2: ; 73C
	ld a,[$d3ae] ; number of warps
	sub c
	ld [$d73b],a ; save ID of used warp
	ld a,[W_CURMAP]
	ld [$d73c],a
	call CheckIfInOutsideMap ; check if the tileset number is 0 or the map is Route 12
	jr nz,.indoorMaps\@
; this is for handling "outside" maps that can't have the 0xFF destination map
	ld a,[W_CURMAP]
	ld [$d365],a ; save current map as previous map
	ld a,[W_CURMAPWIDTH]
	ld [$d366],a
	ld a,[$ff8b] ; destination map number
	ld [W_CURMAP],a ; change current map to destination map
	cp a,ROCK_TUNNEL_1
	jr nz,.notRockTunnel\@
	ld a,$06
	ld [$d35d],a
	call GBFadeIn1
.notRockTunnel\@
	call PlayMapChangeSound
	jr .done\@
; for maps that can have the 0xFF destination map, which means to return to the outside map; not all these maps are necessarily indoors, though
.indoorMaps\@
	ld a,[$ff8b] ; destination map
	cp a,$ff
	jr z,.goBackOutside\@
; if not going back to the previous map
	ld [W_CURMAP],a ; current map number
	ld b,$1c
	ld hl,$4787
	call Bankswitch ; check if the warp was a Silph Co. teleporter
	ld a,[$cd5b]
	dec a
	jr nz,.notTeleporter\@
; if it's a Silph Co. teleporter
	ld hl,$d732
	set 3,[hl]
	call DoFlyOrTeleportAwayGraphics
	jr .skipMapChangeSound\@
.notTeleporter\@
	call PlayMapChangeSound
.skipMapChangeSound\@
	ld hl,$d736
	res 0,[hl]
	res 1,[hl]
	jr .done\@
.goBackOutside\@
	ld a,[$d365] ; previous map
	ld [W_CURMAP],a
	call PlayMapChangeSound
	xor a
	ld [$d35d],a
.done\@
	ld hl,$d736
	set 0,[hl]
	call $12da
	jp EnterMap

ContinueCheckWarpsNoCollisionLoop: ; 7B5
	inc b ; increment warp number
	dec c ; decrement number of warps
	jp nz,CheckWarpsNoCollisionLoop

; if no matching warp was found
CheckMapConnections: ; 7BA
.checkWestMap\@
	ld a,[W_XCOORD]
	cp a,$ff
	jr nz,.checkEastMap\@
	ld a,[$d387]
	ld [W_CURMAP],a
	ld a,[$d38f] ; new X coordinate upon entering west map
	ld [W_XCOORD],a
	ld a,[W_YCOORD]
	ld c,a
	ld a,[$d38e] ; Y adjustment upon entering west map
	add c
	ld c,a
	ld [W_YCOORD],a
	ld a,[$d390] ; pointer to upper left corner of map without adjustment for Y position
	ld l,a
	ld a,[$d391]
	ld h,a
	srl c
	jr z,.savePointer1\@
.pointerAdjustmentLoop1\@
	ld a,[$d38d] ; width of connected map
	add a,$06
	ld e,a
	ld d,$00
	ld b,$00
	add hl,de
	dec c
	jr nz,.pointerAdjustmentLoop1\@
.savePointer1\@
	ld a,l
	ld [$d35f],a ; pointer to upper left corner of current tile block map section
	ld a,h
	ld [$d360],a
	jp .loadNewMap\@
.checkEastMap\@
	ld b,a
	ld a,[$d525] ; map width
	cp b
	jr nz,.checkNorthMap\@
	ld a,[$d392]
	ld [W_CURMAP],a
	ld a,[$d39a] ; new X coordinate upon entering east map
	ld [W_XCOORD],a
	ld a,[W_YCOORD]
	ld c,a
	ld a,[$d399] ; Y adjustment upon entering east map
	add c
	ld c,a
	ld [W_YCOORD],a
	ld a,[$d39b] ; pointer to upper left corner of map without adjustment for Y position
	ld l,a
	ld a,[$d39c]
	ld h,a
	srl c
	jr z,.savePointer2\@
.pointerAdjustmentLoop2\@
	ld a,[$d398]
	add a,$06
	ld e,a
	ld d,$00
	ld b,$00
	add hl,de
	dec c
	jr nz,.pointerAdjustmentLoop2\@
.savePointer2\@
	ld a,l
	ld [$d35f],a ; pointer to upper left corner of current tile block map section
	ld a,h
	ld [$d360],a
	jp .loadNewMap\@
.checkNorthMap\@
	ld a,[W_YCOORD]
	cp a,$ff
	jr nz,.checkSouthMap\@
	ld a,[$d371]
	ld [W_CURMAP],a
	ld a,[$d378] ; new Y coordinate upon entering north map
	ld [W_YCOORD],a
	ld a,[W_XCOORD]
	ld c,a
	ld a,[$d379] ; X adjustment upon entering north map
	add c
	ld c,a
	ld [W_XCOORD],a
	ld a,[$d37a] ; pointer to upper left corner of map without adjustment for X position
	ld l,a
	ld a,[$d37b]
	ld h,a
	ld b,$00
	srl c
	add hl,bc
	ld a,l
	ld [$d35f],a ; pointer to upper left corner of current tile block map section
	ld a,h
	ld [$d360],a
	jp .loadNewMap\@
.checkSouthMap\@
	ld b,a
	ld a,[$d524]
	cp b
	jr nz,.didNotEnterConnectedMap\@
	ld a,[$d37c]
	ld [W_CURMAP],a
	ld a,[$d383] ; new Y coordinate upon entering south map
	ld [W_YCOORD],a
	ld a,[W_XCOORD]
	ld c,a
	ld a,[$d384] ; X adjustment upon entering south map
	add c
	ld c,a
	ld [W_XCOORD],a
	ld a,[$d385] ; pointer to upper left corner of map without adjustment for X position
	ld l,a
	ld a,[$d386]
	ld h,a
	ld b,$00
	srl c
	add hl,bc
	ld a,l
	ld [$d35f],a ; pointer to upper left corner of current tile block map section
	ld a,h
	ld [$d360],a
.loadNewMap\@ ; load the connected map that was entered
	call LoadMapHeader
	call $2312 ; music
	ld b,$09
	call $3def ; SGB palette
	ld b,$05
	ld hl,$785b ; load tile pattern data for sprites
	call Bankswitch
	call LoadTileBlockMap
	jp OverworldLoopLessDelay
.didNotEnterConnectedMap\@
	jp OverworldLoop

; function to play a sound when changing maps
PlayMapChangeSound: ; 8c9
	ld a,[$c448] ; upper left tile of the 4x4 square the player's sprite is standing on
	cp a,$0b ; door tile in tileset 0
	jr nz,.didNotGoThroughDoor\@
	ld a,$ad
	jr .playSound\@
.didNotGoThroughDoor\@
	ld a,$b5
.playSound\@
	call $23b1
	ld a,[$d35d]
	and a
	ret nz
	jp GBFadeIn1

; function to set the Z flag if the tileset number is 0 or the map is Route 12
; strangely, Route 12 has tileset 0, so the check is redundant
CheckIfInOutsideMap: ; 8E1
	ld a,[W_CURMAPTILESET]
	and a
	ret z
	cp a,ROUTE_12
	ret

; this function is an extra check that sometimes has to pass in order to warp, beyond just standing on a warp
; the "sometimes" qualification is necessary because of CheckWarpsNoCollision's behavior
; depending on the map, either "function 1" or "function 2" is used for the check
; "function 1" passes when the player is at the edge of the map and is facing towards the outside of the map
; "function 2" passes when the the tile in front of the player is among a certain set
; sets carry if the check passes, otherwise clears carry
ExtraWarpCheck: ; 8E9
	ld a,[W_CURMAP]
	cp a,SS_ANNE_3
	jr z,.useFunction1\@
	cp a,ROCKET_HIDEOUT_1
	jr z,.useFunction2\@
	cp a,ROCKET_HIDEOUT_2
	jr z,.useFunction2\@
	cp a,ROCKET_HIDEOUT_4
	jr z,.useFunction2\@
	cp a,ROCK_TUNNEL_1
	jr z,.useFunction2\@
	ld a,[W_CURMAPTILESET]
	and a ; outside tileset
	jr z,.useFunction2\@
	cp a,$0d ; S.S. Anne tileset
	jr z,.useFunction2\@
	cp a,$0e ; Vermilion Port tileset
	jr z,.useFunction2\@
	cp a,$17 ; Indigo Plateau tileset
	jr z,.useFunction2\@
.useFunction1\@
	ld hl,$43ff
	jr .doBankswitch\@
.useFunction2\@
	ld hl,$444e
.doBankswitch\@
	ld b,$03
	jp Bankswitch

MapEntryAfterBattle: ; 91F
	ld b,$03
	ld hl,$435f
	call Bankswitch ; function that appears to disable warp testing after collisions if the player is standing on a warp
	ld a,[$d35d]
	and a
	jp z,GBFadeIn2
	jp LoadGBPal

; for when all the player's pokemon faint
; other code prints the "you blacked out" message before this is called
HandleBlackOut: ; 931
	call GBFadeIn1
	ld a,$08
	call StopMusic
	ld hl,$d72e
	res 5,[hl]
	ld a,$01
	ld [$ffb8],a
	ld [$2000],a
	call $40b0
	call $62ce
	call $2312
	jp $5d5f

StopMusic: ; 951
	ld [$cfc7],a
	ld a,$ff
	ld [$c0ee],a
	call $23b1
.waitLoop\@
	ld a,[$cfc7]
	and a
	jr nz,.waitLoop\@
	jp $200e

HandleFlyOrTeleportAway: ; 965
	call $2429 ; move sprites
	call $3dd7
	xor a
	ld [$cf0b],a
	ld [$d700],a
	ld [$d057],a
	ld [$d35d],a
	ld hl,$d732
	set 2,[hl]
	res 5,[hl]
	call DoFlyOrTeleportAwayGraphics
	ld a,$01
	ld [$ffb8],a
	ld [$2000],a
	call $62ce
	jp $5d5f

; function that calls a function to do fly away or teleport away graphics
DoFlyOrTeleportAwayGraphics: ; 98F
	ld b,$1c
	ld hl,$45ba
	jp Bankswitch

; load sprite graphics based on whether the player is standing, biking, or surfing
LoadPlayerSpriteGraphics: ; 997
	ld a,[$d700]
	dec a
	jr z,.ridingBike\@
	ld a,[$ffd7]
	and a
	jr nz,.determineGraphics\@
	jr .startWalking\@
.ridingBike\@
	call IsBikeRidingAllowed
	jr c,.determineGraphics\@ ; don't start walking if bike riding is allowed
.startWalking\@
	xor a
	ld [$d700],a
	ld [$d11a],a
	jp LoadWalkingPlayerSpriteGraphics
.determineGraphics\@
	ld a,[$d700]
	and a
	jp z,LoadWalkingPlayerSpriteGraphics
	dec a
	jp z,LoadBikePlayerSpriteGraphics
	dec a
	jp z,LoadSurfingPlayerSpriteGraphics
	jp LoadWalkingPlayerSpriteGraphics

; function to check if bike riding is allowed on the current map
; sets carry if bike is allowed, clears carry otherwise
IsBikeRidingAllowed: ; 9c5
	ld a,[W_CURMAP]
	cp a,ROUTE_23
	jr z,.allowed\@
	cp a,INDIGO_PLATEAU
	jr z,.allowed\@
	ld a,[W_CURMAPTILESET]
	ld b,a
	ld hl,BikeRidingTilesets
.loop\@
	ld a,[hli]
	cp b
	jr z,.allowed\@
	inc a
	jr nz,.loop\@
	and a
	ret
.allowed\@
	scf
	ret

BikeRidingTilesets: ; 9E2
db $00, $03, $0B, $0E, $11, $FF

; load the tile pattern data of the current tileset into VRAM
LoadTilesetTilePatternData: ; 9E8
	ld a,[$d52e]
	ld l,a
	ld a,[$d52f]
	ld h,a
	ld de,$9000
	ld bc,$0600
	ld a,[$d52b]
	jp $17f7

; this loads the current maps complete tile map (which references blocks, not individual tiles) to C6E8
; it can also load partial tile maps of connected maps into a border of length 3 around the current map
LoadTileBlockMap: ; 9FC
; fill C6E8-CBFB with the background tile
	ld hl,$c6e8
	ld a,[$d3ad] ; background tile number
	ld d,a
	ld bc,$0514
.backgroundTileLoop\@
	ld a,d
	ld [hli],a
	dec bc
	ld a,c
	or b
	jr nz,.backgroundTileLoop\@
; load tile map of current map (made of tile block IDs)
; a 3-byte border at the edges of the map is kept so that there is space for map connections
	ld hl,$c6e8
	ld a,[W_CURMAPWIDTH]
	ld [$ff8c],a
	add a,$06 ; border (east and west)
	ld [$ff8b],a ; map width + border
	ld b,$00
	ld c,a
; make space for north border (next 3 lines)
	add hl,bc
	add hl,bc
	add hl,bc
	ld c,$03
	add hl,bc ; this puts us past the (west) border
	ld a,[$d36a] ; tile map pointer
	ld e,a
	ld a,[$d36b]
	ld d,a ; de = tile map pointer
	ld a,[W_CURMAPHEIGHT]
	ld b,a
.rowLoop\@ ; copy one row each iteration
	push hl
	ld a,[$ff8c] ; map width (without border)
	ld c,a
.rowInnerLoop\@
	ld a,[de]
	inc de
	ld [hli],a
	dec c
	jr nz,.rowInnerLoop\@
; add the map width plus the border to the base address of the current row to get the next row's address
	pop hl
	ld a,[$ff8b] ; map width + border
	add l
	ld l,a
	jr nc,.noCarry\@
	inc h
.noCarry\@
	dec b
	jr nz,.rowLoop\@
.northConnection\@
	ld a,[$d371]
	cp a,$ff
	jr z,.southConnection\@
	call SwitchToMapRomBank
	ld a,[$d372]
	ld l,a
	ld a,[$d373]
	ld h,a
	ld a,[$d374]
	ld e,a
	ld a,[$d375]
	ld d,a
	ld a,[$d376]
	ld [$ff8b],a
	ld a,[$d377]
	ld [$ff8c],a
	call LoadNorthSouthConnectionsTileMap
.southConnection\@
	ld a,[$d37c]
	cp a,$ff
	jr z,.westConnection\@
	call SwitchToMapRomBank
	ld a,[$d37d]
	ld l,a
	ld a,[$d37e]
	ld h,a
	ld a,[$d37f]
	ld e,a
	ld a,[$d380]
	ld d,a
	ld a,[$d381]
	ld [$ff8b],a
	ld a,[$d382]
	ld [$ff8c],a
	call LoadNorthSouthConnectionsTileMap
.westConnection\@
	ld a,[$d387]
	cp a,$ff
	jr z,.eastConnection\@
	call SwitchToMapRomBank
	ld a,[$d388]
	ld l,a
	ld a,[$d389]
	ld h,a
	ld a,[$d38a]
	ld e,a
	ld a,[$d38b]
	ld d,a
	ld a,[$d38c]
	ld b,a
	ld a,[$d38d]
	ld [$ff8b],a
	call LoadEastWestConnectionsTileMap
.eastConnection\@
	ld a,[$d392]
	cp a,$ff
	jr z,.done\@
	call SwitchToMapRomBank
	ld a,[$d393]
	ld l,a
	ld a,[$d394]
	ld h,a
	ld a,[$d395]
	ld e,a
	ld a,[$d396]
	ld d,a
	ld a,[$d397]
	ld b,a
	ld a,[$d398]
	ld [$ff8b],a
	call LoadEastWestConnectionsTileMap
.done\@
	ret

LoadNorthSouthConnectionsTileMap: ; ADE
	ld c,$03
.loop\@
	push de
	push hl
	ld a,[$ff8b] ; width of connection
	ld b,a
.innerLoop\@
	ld a,[hli]
	ld [de],a
	inc de
	dec b
	jr nz,.innerLoop\@
	pop hl
	pop de
	ld a,[$ff8c] ; width of connected map
	add l
	ld l,a
	jr nc,.noCarry1\@
	inc h
.noCarry1\@
	ld a,[W_CURMAPWIDTH]
	add a,$06
	add e
	ld e,a
	jr nc,.noCarry2\@
	inc d
.noCarry2\@
	dec c
	jr nz,.loop\@
	ret

LoadEastWestConnectionsTileMap: ; B02
	push hl
	push de
	ld c,$03
.innerLoop\@
	ld a,[hli]
	ld [de],a
	inc de
	dec c
	jr nz,.innerLoop\@
	pop de
	pop hl
	ld a,[$ff8b] ; width of connected map
	add l
	ld l,a
	jr nc,.noCarry1\@
	inc h
.noCarry1\@
	ld a,[W_CURMAPWIDTH]
	add a,$06
	add e
	ld e,a
	jr nc,.noCarry2\@
	inc d
.noCarry2\@
	dec b
	jr nz,LoadEastWestConnectionsTileMap
	ret

; function to check if there is a sign or sprite in front of the player
; if so, it is stored in [$FF8C]
; if not, [$FF8C] is set to 0
IsSpriteOrSignInFrontOfPlayer: ; B23
	xor a
	ld [$ff8c],a
	ld a,[$d4b0] ; number of signs in the map
	and a
	jr z,.extendRangeOverCounter\@
; if there are signs
	ld a,$35
	call Predef ; get the coordinates in front of the player in de
	ld hl,$d4b1 ; start of sign coordinates
	ld a,[$d4b0] ; number of signs in the map
	ld b,a
	ld c,$00
.signLoop\@
	inc c
	ld a,[hli] ; sign Y
	cp d
	jr z,.yCoordMatched\@
	inc hl
	jr .retry\@
.yCoordMatched\@
	ld a,[hli] ; sign X
	cp e
	jr nz,.retry\@
.xCoordMatched\@
; found sign
	push hl
	push bc
	ld hl,$d4d1 ; start of sign text ID's
	ld b,$00
	dec c
	add hl,bc
	ld a,[hl]
	ld [$ff8c],a ; store sign text ID
	pop bc
	pop hl
	ret
.retry\@
	dec b
	jr nz,.signLoop\@
; check if the player is front of a counter in a pokemon center, pokemart, etc. and if so, extend the range at which he can talk to the NPC
.extendRangeOverCounter\@
	ld a,$35
	call Predef ; get the tile in front of the player in c
	ld hl,$d532 ; list of tiles that extend talking range (counter tiles)
	ld b,$03
	ld d,$20 ; talking range in pixels (long range)
.counterTilesLoop\@
	ld a,[hli]
	cp c
	jr z,IsSpriteInFrontOfPlayer2 ; jumps if the tile in front of the player is a counter tile
	dec b
	jr nz,.counterTilesLoop\@

; part of the above function, but sometimes its called on its own, when signs are irrelevant
; the caller must zero [$FF8C]
IsSpriteInFrontOfPlayer: ; B6B
	ld d,$10 ; talking range in pixels (normal range)
IsSpriteInFrontOfPlayer2: ; B6D
	ld bc,$3c40 ; Y and X position of player sprite
	ld a,[$c109] ; direction the player is facing
.checkIfPlayerFacingUp\@
	cp a,$04
	jr nz,.checkIfPlayerFacingDown\@
; facing up
	ld a,b
	sub d
	ld b,a
	ld a,$08
	jr .doneCheckingDirection\@
.checkIfPlayerFacingDown\@
	cp a,$00
	jr nz,.checkIfPlayerFacingRight\@
; facing down
	ld a,b
	add d
	ld b,a
	ld a,$04
	jr .doneCheckingDirection\@
.checkIfPlayerFacingRight\@
	cp a,$0c
	jr nz,.playerFacingLeft\@
; facing right
	ld a,c
	add d
	ld c,a
	ld a,$01
	jr .doneCheckingDirection\@
.playerFacingLeft\@
; facing left
	ld a,c
	sub d
	ld c,a
	ld a,$02
.doneCheckingDirection\@
	ld [$d52a],a
	ld a,[$d4e1] ; number of sprites
	and a
	ret z
; if there are sprites
	ld hl,$c110
	ld d,a
	ld e,$01
.spriteLoop\@
	push hl
	ld a,[hli] ; image (0 if no sprite)
	and a
	jr z,.nextSprite\@
	inc l
	ld a,[hli] ; sprite visibility
	inc a
	jr z,.nextSprite\@
	inc l
	ld a,[hli] ; Y location
	cp b
	jr nz,.nextSprite\@
	inc l
	ld a,[hl] ; X location
	cp c
	jr z,.foundSpriteInFrontOfPlayer\@
.nextSprite\@
	pop hl
	ld a,l
	add a,$10
	ld l,a
	inc e
	dec d
	jr nz,.spriteLoop\@
	ret
.foundSpriteInFrontOfPlayer\@
	pop hl
	ld a,l
	and a,$f0
	inc a
	ld l,a
	set 7,[hl]
	ld a,e
	ld [$ff8c],a ; store sprite ID
	ret

; function to check if the player will jump down a ledge and check if the tile ahead is passable (when not surfing)
; sets the carry flag if there is a collision, and unsets it if there isn't a collision
CollisionCheckOnLand: ; BD1
	ld a,[$d736]
	bit 6,a ; is the player jumping?
	jr nz,.noCollision\@
; if not jumping a ledge
	ld a,[$cd38]
	and a
	jr nz,.noCollision\@
	ld a,[$d52a] ; the direction that the player is trying to go in
	ld d,a
	ld a,[$c10c] ; the player sprite's collision data (bit field) (set in the sprite movement code)
	and d ; check if a sprite is in the direction the player is trying to go
	jr nz,.collision\@
	xor a
	ld [$ff8c],a
	call IsSpriteInFrontOfPlayer ; check for sprite collisions again? when does the above check fail to detect a sprite collision?
	ld a,[$ff8c]
	and a ; was there a sprite collision?
	jr nz,.collision\@
; if no sprite collision
	ld hl,TilePairCollisionsLand
	call CheckForJumpingAndTilePairCollisions
	jr c,.collision\@
	call CheckTilePassable
	jr nc,.noCollision\@
.collision\@
	ld a,[$c02a]
	cp a,$b4 ; check if collision sound is already playing
	jr z,.setCarry\@
	ld a,$b4
	call $23b1 ; play collision sound (if it's not already playing)
.setCarry\@
	scf
	ret
.noCollision\@
	and a
	ret

; function that checks if the tile in front of the player is passable
; clears carry if it is, sets carry if not
CheckTilePassable: ; C10
	ld a,$35
	call Predef ; get tile in front of player
	ld a,[$cfc6] ; tile in front of player
	ld c,a
	ld hl,$d530 ; pointer to list of passable tiles
	ld a,[hli]
	ld h,[hl]
	ld l,a ; hl now points to passable tiles
.loop\@
	ld a,[hli]
	cp a,$ff
	jr z,.tileNotPassable\@
	cp c
	ret z
	jr .loop\@
.tileNotPassable\@
	scf
	ret

; check if the player is going to jump down a small ledge
; and check for collisions that only occur between certain pairs of tiles
; Input: hl - address of directional collision data
; sets carry if there is a collision and unsets carry if not
CheckForJumpingAndTilePairCollisions: ; C2A
	push hl
	ld a,$35
	call Predef ; get the tile in front of the player
	push de
	push bc
	ld b,$06
	ld hl,$6672
	call Bankswitch ; check if the player is trying to jump a ledge
	pop bc
	pop de
	pop hl
	and a
	ld a,[$d736]
	bit 6,a ; is the player jumping?
	ret nz
; if not jumping
	ld a,[$c45c] ; tile the player is on
	ld [$cf0e],a
	ld a,[$cfc6] ; tile in front of the player
	ld c,a
.tilePairCollisionLoop\@
	ld a,[W_CURMAPTILESET] ; tileset number
	ld b,a
	ld a,[hli]
	cp a,$ff
	jr z,.noMatch\@
	cp b
	jr z,.tilesetMatches\@
	inc hl
.retry\@
	inc hl
	jr .tilePairCollisionLoop\@
.tilesetMatches\@
	ld a,[$cf0e] ; tile the player is on
	ld b,a
	ld a,[hl]
	cp b
	jr z,.currentTileMatchesFirstInPair\@
	inc hl
	ld a,[hl]
	cp b
	jr z,.currentTileMatchesSecondInPair\@
	jr .retry\@
.currentTileMatchesFirstInPair\@
	inc hl
	ld a,[hl]
	cp c
	jr z,.foundMatch\@
	jr .tilePairCollisionLoop\@
.currentTileMatchesSecondInPair\@
	dec hl
	ld a,[hli]
	cp c
	inc hl
	jr nz,.tilePairCollisionLoop\@
.foundMatch\@
	scf
	ret
.noMatch\@
	and a
	ret

; FORMAT: tileset number, tile 1, tile 2
; terminated by 0xFF
; these entries indicate that the player may not cross between tile 1 and tile 2
; it's mainly used to simulate differences in elevation

TilePairCollisionsLand: ; C7E
db $11, $20, $05;
db $11, $41, $05;
db $03, $30, $2E;
db $11, $2A, $05;
db $11, $05, $21;
db $03, $52, $2E;
db $03, $55, $2E;
db $03, $56, $2E;
db $03, $20, $2E;
db $03, $5E, $2E;
db $03, $5F, $2E;
db $FF;

TilePairCollisionsWater: ; CA0
db $03, $14, $2E;
db $03, $48, $2E;
db $11, $14, $05;
db $FF;

; this builds a tile map from the tile block map based on the current X/Y coordinates of the player's character
LoadCurrentMapView: ; CAA
	ld a,[$ffb8]
	push af
	ld a,[$d52b] ; tile data ROM bank
	ld [$ffb8],a
	ld [$2000],a ; switch to ROM bank that contains tile data
	ld a,[$d35f] ; address of upper left corner of current map view
	ld e,a
	ld a,[$d360]
	ld d,a
	ld hl,$c508
	ld b,$05
.rowLoop\@ ; each loop iteration fills in one row of tile blocks
	push hl
	push de
	ld c,$06
.rowInnerLoop\@ ; loop to draw each tile block of the current row
	push bc
	push de
	push hl
	ld a,[de]
	ld c,a ; tile block number
	call DrawTileBlock
	pop hl
	pop de
	pop bc
	inc hl
	inc hl
	inc hl
	inc hl
	inc de
	dec c
	jr nz,.rowInnerLoop\@
; update tile block map pointer to next row's address
	pop de
	ld a,[W_CURMAPWIDTH]
	add a,$06
	add e
	ld e,a
	jr nc,.noCarry\@
	inc d
.noCarry\@
; update tile map pointer to next row's address
	pop hl
	ld a,$60
	add l
	ld l,a
	jr nc,.noCarry2\@
	inc h
.noCarry2\@
	dec b
	jr nz,.rowLoop\@
	ld hl,$c508
	ld bc,$0000
.adjustForYCoordWithinTileBlock\@
	ld a,[W_YBLOCKCOORD]
	and a
	jr z,.adjustForXCoordWithinTileBlock\@
	ld bc,$0030
	add hl,bc
.adjustForXCoordWithinTileBlock\@
	ld a,[W_XBLOCKCOORD]
	and a
	jr z,.copyToVisibleAreaBuffer\@
	ld bc,$0002
	add hl,bc
.copyToVisibleAreaBuffer\@
	ld de,$c3a0 ; base address for the tiles that are directly transfered to VRAM during V-blank
	ld b,$12
.rowLoop2\@
	ld c,$14
.rowInnerLoop2\@
	ld a,[hli]
	ld [de],a
	inc de
	dec c
	jr nz,.rowInnerLoop2\@
	ld a,$04
	add l
	ld l,a
	jr nc,.noCarry3\@
	inc h
.noCarry3\@
	dec b
	jr nz,.rowLoop2\@
	pop af
	ld [$ffb8],a
	ld [$2000],a ; restore previous ROM bank
	ret

AdvancePlayerSprite: ; D27
	ld a,[$c103] ; delta Y
	ld b,a
	ld a,[$c105] ; delta X
	ld c,a
	ld hl,W_WALKCOUNTER ; walking animation counter
	dec [hl]
	jr nz,.afterUpdateMapCoords\@
; if it's the end of the animation, update the player's map coordinates
	ld a,[W_YCOORD]
	add b
	ld [W_YCOORD],a
	ld a,[W_XCOORD]
	add c
	ld [W_XCOORD],a
.afterUpdateMapCoords\@
	ld a,[W_WALKCOUNTER] ; walking animation counter
	cp a,$07
	jp nz,.scrollBackgroundAndSprites\@
; if this is the first iteration of the animation
	ld a,c
	cp a,$01
	jr nz,.checkIfMovingWest\@
; moving east
	ld a,[$d526]
	ld e,a
	and a,$e0
	ld d,a
	ld a,e
	add a,$02
	and a,$1f
	or d
	ld [$d526],a
	jr .adjustXCoordWithinBlock\@
.checkIfMovingWest\@
	cp a,$ff
	jr nz,.checkIfMovingSouth\@
; moving west
	ld a,[$d526]
	ld e,a
	and a,$e0
	ld d,a
	ld a,e
	sub a,$02
	and a,$1f
	or d
	ld [$d526],a
	jr .adjustXCoordWithinBlock\@
.checkIfMovingSouth\@
	ld a,b
	cp a,$01
	jr nz,.checkIfMovingNorth\@
; moving south
	ld a,[$d526]
	add a,$40
	ld [$d526],a
	jr nc,.adjustXCoordWithinBlock\@
	ld a,[$d527]
	inc a
	and a,$03
	or a,$98
	ld [$d527],a
	jr .adjustXCoordWithinBlock\@
.checkIfMovingNorth\@
	cp a,$ff
	jr nz,.adjustXCoordWithinBlock\@
; moving north
	ld a,[$d526]
	sub a,$40
	ld [$d526],a
	jr nc,.adjustXCoordWithinBlock\@
	ld a,[$d527]
	dec a
	and a,$03
	or a,$98
	ld [$d527],a
.adjustXCoordWithinBlock\@
	ld a,c
	and a
	jr z,.pointlessJump\@ ; mistake?
.pointlessJump\@
	ld hl,W_XBLOCKCOORD
	ld a,[hl]
	add c
	ld [hl],a
	cp a,$02
	jr nz,.checkForMoveToWestBlock\@
; moved into the tile block to the east
	xor a
	ld [hl],a
	ld hl,$d4e3
	inc [hl]
	ld de,$d35f
	call MoveTileBlockMapPointerEast
	jr .updateMapView\@
.checkForMoveToWestBlock\@
	cp a,$ff
	jr nz,.adjustYCoordWithinBlock\@
; moved into the tile block to the west
	ld a,$01
	ld [hl],a
	ld hl,$d4e3
	dec [hl]
	ld de,$d35f
	call MoveTileBlockMapPointerWest
	jr .updateMapView\@
.adjustYCoordWithinBlock\@
	ld hl,W_YBLOCKCOORD
	ld a,[hl]
	add b
	ld [hl],a
	cp a,$02
	jr nz,.checkForMoveToNorthBlock\@
; moved into the tile block to the south
	xor a
	ld [hl],a
	ld hl,$d4e2
	inc [hl]
	ld de,$d35f
	ld a,[W_CURMAPWIDTH]
	call MoveTileBlockMapPointerSouth
	jr .updateMapView\@
.checkForMoveToNorthBlock\@
	cp a,$ff
	jr nz,.updateMapView\@
; moved into the tile block to the north
	ld a,$01
	ld [hl],a
	ld hl,$d4e2
	dec [hl]
	ld de,$d35f
	ld a,[W_CURMAPWIDTH]
	call MoveTileBlockMapPointerNorth
.updateMapView\@
	call LoadCurrentMapView
	ld a,[$c103] ; delta Y
	cp a,$01
	jr nz,.checkIfMovingNorth2\@
; if moving south
	call ScheduleSouthRowRedraw
	jr .scrollBackgroundAndSprites\@
.checkIfMovingNorth2\@
	cp a,$ff
	jr nz,.checkIfMovingEast2\@
; if moving north
	call ScheduleNorthRowRedraw
	jr .scrollBackgroundAndSprites\@
.checkIfMovingEast2\@
	ld a,[$c105] ; delta X
	cp a,$01
	jr nz,.checkIfMovingWest2\@
; if moving east
	call ScheduleEastColumnRedraw
	jr .scrollBackgroundAndSprites\@
.checkIfMovingWest2\@
	cp a,$ff
	jr nz,.scrollBackgroundAndSprites\@
; if moving west
	call ScheduleWestColumnRedraw
.scrollBackgroundAndSprites\@
	ld a,[$c103] ; delta Y
	ld b,a
	ld a,[$c105] ; delta X
	ld c,a
	sla b
	sla c
	ld a,[$ffaf]
	add b
	ld [$ffaf],a ; update background scroll Y
	ld a,[$ffae]
	add c
	ld [$ffae],a ; update background scroll X
; shift all the sprites in the direction opposite of the player's motion
; so that the player appears to move relative to them
	ld hl,$c114
	ld a,[$d4e1] ; number of sprites
	and a ; are there any sprites?
	jr z,.done\@
	ld e,a
.spriteShiftLoop\@
	ld a,[hl]
	sub b
	ld [hli],a
	inc l
	ld a,[hl]
	sub c
	ld [hl],a
	ld a,$0e
	add l
	ld l,a
	dec e
	jr nz,.spriteShiftLoop\@
.done\@
	ret

; the following four functions are used to move the pointer to the upper left
; corner of the tile block map in the direction of motion

MoveTileBlockMapPointerEast: ; E65
	ld a,[de]
	add a,$01
	ld [de],a
	ret nc
	inc de
	ld a,[de]
	inc a
	ld [de],a
	ret

MoveTileBlockMapPointerWest: ; E6F
	ld a,[de]
	sub a,$01
	ld [de],a
	ret nc
	inc de
	ld a,[de]
	dec a
	ld [de],a
	ret

MoveTileBlockMapPointerSouth: ; E79
	add a,$06
	ld b,a
	ld a,[de]
	add b
	ld [de],a
	ret nc
	inc de
	ld a,[de]
	inc a
	ld [de],a
	ret

MoveTileBlockMapPointerNorth: ; E85
	add a,$06
	ld b,a
	ld a,[de]
	sub b
	ld [de],a
	ret nc
	inc de
	ld a,[de]
	dec a
	ld [de],a
	ret

; the following 6 functions are used to tell the V-blank handler to redraw
; the portion of the map that was newly exposed due to the player's movement

ScheduleNorthRowRedraw: ; E91
	FuncCoord 0, 0
	ld hl,Coord
	call ScheduleRowRedrawHelper
	ld a,[$d526]
	ld [H_SCREENEDGEREDRAWADDR],a
	ld a,[$d527]
	ld [H_SCREENEDGEREDRAWADDR + 1],a
	ld a,REDRAWROW
	ld [H_SCREENEDGEREDRAW],a
	ret

ScheduleRowRedrawHelper: ; EA6
	ld de,W_SCREENEDGETILES
	ld c,$28
.loop\@
	ld a,[hli]
	ld [de],a
	inc de
	dec c
	jr nz,.loop\@
	ret

ScheduleSouthRowRedraw: ; EB2
	FuncCoord 0,16
	ld hl,Coord
	call ScheduleRowRedrawHelper
	ld a,[$d526]
	ld l,a
	ld a,[$d527]
	ld h,a
	ld bc,$0200
	add hl,bc
	ld a,h
	and a,$03
	or a,$98
	ld [H_SCREENEDGEREDRAWADDR + 1],a
	ld a,l
	ld [H_SCREENEDGEREDRAWADDR],a
	ld a,REDRAWROW
	ld [H_SCREENEDGEREDRAW],a
	ret

ScheduleEastColumnRedraw: ; ED3
	FuncCoord 18,0
	ld hl,Coord
	call ScheduleColumnRedrawHelper
	ld a,[$d526]
	ld c,a
	and a,$e0
	ld b,a
	ld a,c
	add a,18
	and a,$1f
	or b
	ld [H_SCREENEDGEREDRAWADDR],a
	ld a,[$d527]
	ld [H_SCREENEDGEREDRAWADDR + 1],a
	ld a,REDRAWCOL
	ld [H_SCREENEDGEREDRAW],a
	ret

ScheduleColumnRedrawHelper: ; EF2
	ld de,W_SCREENEDGETILES
	ld c,$12
.loop\@
	ld a,[hli]
	ld [de],a
	inc de
	ld a,[hl]
	ld [de],a
	inc de
	ld a,19
	add l
	ld l,a
	jr nc,.noCarry\@
	inc h
.noCarry\@
	dec c
	jr nz,.loop\@
	ret

ScheduleWestColumnRedraw: ; F08
	FuncCoord 0,0
	ld hl,Coord
	call ScheduleColumnRedrawHelper
	ld a,[$d526]
	ld [H_SCREENEDGEREDRAWADDR],a
	ld a,[$d527]
	ld [H_SCREENEDGEREDRAWADDR + 1],a
	ld a,REDRAWCOL
	ld [H_SCREENEDGEREDRAW],a
	ret

; function to write the tiles that make up a tile block to memory
; Input: c = tile block ID, hl = destination address
DrawTileBlock: ; F1D
	push hl
	ld a,[$d52c] ; pointer to tiles
	ld l,a
	ld a,[$d52d]
	ld h,a
	ld a,c
	swap a
	ld b,a
	and a,$f0
	ld c,a
	ld a,b
	and a,$0f
	ld b,a ; bc = tile block ID * 0x10
	add hl,bc
	ld d,h
	ld e,l ; de = address of the tile block's tiles
	pop hl
	ld c,$04 ; 4 loop iterations
.loop\@ ; each loop iteration, write 4 tile numbers
	push bc
	ld a,[de]
	ld [hli],a
	inc de
	ld a,[de]
	ld [hli],a
	inc de
	ld a,[de]
	ld [hli],a
	inc de
	ld a,[de]
	ld [hl],a
	inc de
	ld bc,$0015
	add hl,bc
	pop bc
	dec c
	jr nz,.loop\@
	ret

; function to update joypad state and simulate button presses
GetJoypadStateOverworld: ; F4D
	xor a
	ld [$c103],a
	ld [$c105],a
	call RunMapScript
	call GetJoypadState
	ld a,[$d733]
	bit 3,a ; check if a trainer wants a challenge
	jr nz,.notForcedDownwards\@
	ld a,[W_CURMAP]
	cp a,ROUTE_17 ; Cycling Road
	jr nz,.notForcedDownwards\@
	ld a,[$ffb4] ; current joypad state
	and a,%11110011 ; bit mask for all directions and A/B
	jr nz,.notForcedDownwards\@
	ld a,%10000000 ; down pressed
	ld [$ffb4],a ; on the cycling road, if there isn't a trainer and the player isn't pressing buttons, simulate a down press
.notForcedDownwards\@
	ld a,[$d730]
	bit 7,a
	ret z
; if simulating button presses
	ld a,[$ffb4] ; current joypad state
	ld b,a
	ld a,[$cd3b] ; bit mask for button presses that override simulated ones
	and b
	ret nz ; return if the simulated button presses are overridden
	ld hl,$cd38 ; index of current simulated button press
	dec [hl]
	ld a,[hl]
	cp a,$ff
	jr z,.doneSimulating\@ ; if the end of the simulated button presses has been reached
	ld hl,$ccd3 ; base address of simulated button presses
; add offset to base address
	add l
	ld l,a
	jr nc,.noCarry\@
	inc h
.noCarry\@
	ld a,[hl]
	ld [$ffb4],a ; store simulated button press in joypad state
	and a
	ret nz
	ld [$ffb3],a
	ld [$ffb2],a
	ret
; if done simulating button presses
.doneSimulating\@
	xor a
	ld [$cd3a],a
	ld [$cd38],a
	ld [$ccd3],a
	ld [$cd6b],a
	ld [$ffb4],a
	ld hl,$d736
	ld a,[hl]
	and a,$f8
	ld [hl],a
	ld hl,$d730
	res 7,[hl]
	ret

; function to check the tile ahead to determine if the character should get on land or keep surfing
; sets carry if there is a collision and clears carry otherwise
; It seems that this function has a bug in it, but due to luck, it doesn't
; show up. After detecting a sprite collision, it jumps to the code that
; checks if the next tile is passable instead of just directly jumping to the
; "collision detected" code. However, it doesn't store the next tile in c,
; so the old value of c is used. 2429 is always called before this function,
; and 2429 always sets c to 0xF0. There is no 0xF0 background tile, so it
; is considered impassable and it is detected as a collision.
CollisionCheckOnWater: ; FB7
	ld a,[$d730]
	bit 7,a
	jp nz,.noCollision\@ ; return and clear carry if button presses are being simulated
	ld a,[$d52a] ; the direction that the player is trying to go in
	ld d,a
	ld a,[$c10c] ; the player sprite's collision data (bit field) (set in the sprite movement code)
	and d ; check if a sprite is in the direction the player is trying to go
	jr nz,.checkIfNextTileIsPassable\@ ; bug?
	ld hl,TilePairCollisionsWater
	call CheckForJumpingAndTilePairCollisions
	jr c,.collision\@
	ld a,$35
	call Predef ; get tile in front of player (puts it in c and [$CFC6])
	ld a,[$cfc6] ; tile in front of player
	cp a,$14 ; water tile
	jr z,.noCollision\@ ; keep surfing if it's a water tile
	cp a,$32 ; either the left tile of the S.S. Anne boarding platform or the tile on eastern coastlines (depending on the current tileset)
	jr z,.checkIfVermilionDockTileset\@
	cp a,$48 ; tile on right on coast lines in Safari Zone
	jr z,.noCollision\@ ; keep surfing
; check if the [land] tile in front of the player is passable
.checkIfNextTileIsPassable\@
	ld hl,$d530 ; pointer to list of passable tiles
	ld a,[hli]
	ld h,[hl]
	ld l,a
.loop\@
	ld a,[hli]
	cp a,$ff
	jr z,.collision\@
	cp c
	jr z,.stopSurfing\@ ; stop surfing if the tile is passable
	jr .loop\@
.collision\@
	ld a,[$c02a]
	cp a,$b4 ; check if collision sound is already playing
	jr z,.setCarry\@
	ld a,$b4
	call $23b1 ; play collision sound (if it's not already playing)
.setCarry\@
	scf
	jr .done\@
.noCollision\@
	and a
.done\@
	ret
.stopSurfing\@
	xor a
	ld [$d700],a
	call LoadPlayerSpriteGraphics
	call $2307
	jr .noCollision\@
.checkIfVermilionDockTileset\@
	ld a,[W_CURMAPTILESET] ; tileset
	cp a,$0e ; Vermilion Dock tileset
	jr nz,.noCollision\@ ; keep surfing if it's not the boarding platform tile
	jr .stopSurfing\@ ; if it is the boarding platform tile, stop surfing

; function to run the current map's script
RunMapScript: ; 101B
	push hl
	push de
	push bc
	ld b,$03
	ld hl,$7225
	call Bankswitch ; check if the player is pushing a boulder
	ld a,[$cd60]
	bit 1,a ; is the player pushing a boulder?
	jr z,.afterBoulderEffect\@
	ld b,$03
	ld hl,$72b5
	call Bankswitch ; displays dust effect when pushing a boulder
.afterBoulderEffect\@
	pop bc
	pop de
	pop hl
	call $310e
	ld a,[W_CURMAP] ; current map number
	call SwitchToMapRomBank ; change to the ROM bank the map's data is in
	ld hl,W_MAPSCRIPTPTR
	ld a,[hli]
	ld h,[hl]
	ld l,a
	ld de,.return\@
	push de
	jp [hl] ; jump to script
.return\@
	ret

LoadWalkingPlayerSpriteGraphics: ; 0x104d
	ld de,$4180
	ld hl,$8000
	jr LoadPlayerSpriteGraphicsCommon

LoadSurfingPlayerSpriteGraphics: ; 0x1055
	ld de,$76c0
	ld hl,$8000
	jr LoadPlayerSpriteGraphicsCommon

LoadBikePlayerSpriteGraphics: ; 0x105d
	ld de,$4000
	ld hl,$8000

LoadPlayerSpriteGraphicsCommon: ; 0x1063
	push de
	push hl
	ld bc,$050c
	call $1848
	pop hl
	pop de
	ld a,$c0
	add e
	ld e,a
	jr nc,.noCarry\@
	inc d
.noCarry\@
	set 3,h
	ld bc,$050c
	jp $1848

; function to load data from the map header
LoadMapHeader: ; 107C
	ld b,$03
	ld hl,$7113
	call Bankswitch
	ld a,[W_CURMAPTILESET]
	ld [$d119],a
	ld a,[W_CURMAP]
	call SwitchToMapRomBank
	ld a,[W_CURMAPTILESET]
	ld b,a
	res 7,a
	ld [W_CURMAPTILESET],a
	ld [$ff8b],a
	bit 7,b
	ret nz
	ld hl,MapHeaderPointers
	ld a,[W_CURMAP]
	sla a
	jr nc,.noCarry1\@
	inc h
.noCarry1\@
	add l
	ld l,a
	jr nc,.noCarry2\@
	inc h
.noCarry2\@
	ld a,[hli]
	ld h,[hl]
	ld l,a ; hl = base of map header
; copy the first 10 bytes (the fixed area) of the map data to D367-D370
	ld de,$d367
	ld c,$0a
.copyFixedHeaderLoop\@
	ld a,[hli]
	ld [de],a
	inc de
	dec c
	jr nz,.copyFixedHeaderLoop\@
; initialize all the connected maps to disabled at first, before loading the actual values
	ld a,$ff
	ld [$d371],a
	ld [$d37c],a
	ld [$d387],a
	ld [$d392],a
; copy connection data (if any) to WRAM
	ld a,[W_MAPCONNECTIONS]
	ld b,a
.checkNorth\@
	bit 3,b
	jr z,.checkSouth\@
	ld de,W_MAPCONN1PTR
	call CopyMapConnectionHeader
.checkSouth\@
	bit 2,b
	jr z,.checkWest\@
	ld de,W_MAPCONN2PTR
	call CopyMapConnectionHeader
.checkWest\@
	bit 1,b
	jr z,.checkEast\@
	ld de,W_MAPCONN3PTR
	call CopyMapConnectionHeader
.checkEast\@
	bit 0,b
	jr z,.getObjectDataPointer\@
	ld de,W_MAPCONN4PTR
	call CopyMapConnectionHeader
.getObjectDataPointer\@
	ld a,[hli]
	ld [$d3a9],a
	ld a,[hli]
	ld [$d3aa],a
	push hl
	ld a,[$d3a9]
	ld l,a
	ld a,[$d3aa]
	ld h,a ; hl = base of object data
	ld de,$d3ad ; background tile ID
	ld a,[hli]
	ld [de],a ; save background tile ID
.loadWarpData\@
	ld a,[hli] ; number of warps
	ld [$d3ae],a ; save the number of warps
	and a ; are there any warps?
	jr z,.loadSignData\@ ; if not, skip this
	ld c,a
	ld de,$d3af ; base address of warps
.warpLoop\@ ; one warp per loop iteration
	ld b,$04
.warpInnerLoop\@
	ld a,[hli]
	ld [de],a
	inc de
	dec b
	jr nz,.warpInnerLoop\@
	dec c
	jr nz,.warpLoop\@
.loadSignData\@
	ld a,[hli] ; number of signs
	ld [$d4b0],a ; save the number of signs
	and a ; are there any signs?
	jr z,.loadSpriteData\@ ; if not, skip this
	ld c,a
	ld de,$d4d1 ; base address of sign text IDs
	ld a,d
	ld [$ff95],a
	ld a,e
	ld [$ff96],a
	ld de,$d4b1 ; base address of sign coordinates
.signLoop\@
	ld a,[hli]
	ld [de],a
	inc de
	ld a,[hli]
	ld [de],a
	inc de
	push de
	ld a,[$ff95]
	ld d,a
	ld a,[$ff96]
	ld e,a
	ld a,[hli]
	ld [de],a
	inc de
	ld a,d
	ld [$ff95],a
	ld a,e
	ld [$ff96],a
	pop de
	dec c
	jr nz,.signLoop\@
.loadSpriteData\@
	ld a,[$d72e]
	bit 5,a ; did a battle happen immediately before this?
	jp nz,.finishUp\@ ; if so, skip this because battles don't destroy this data
	ld a,[hli]
	ld [$d4e1],a ; save the number of sprites
	push hl
; zero C110-C1FF and C210-C2FF
	ld hl,$c110
	ld de,$c210
	xor a
	ld b,$f0
.zeroSpriteDataLoop\@
	ld [hli],a
	ld [de],a
	inc e
	dec b
	jr nz,.zeroSpriteDataLoop\@
; initialize all C100-C1FF sprite entries to disabled (other than player's)
	ld hl,$c112
	ld de,$0010
	ld c,$0f
.disableSpriteEntriesLoop\@
	ld [hl],$ff
	add hl,de
	dec c
	jr nz,.disableSpriteEntriesLoop\@
	pop hl
	ld de,$c110
	ld a,[$d4e1] ; number of sprites
	and a ; are there any sprites?
	jp z,.finishUp\@ ; if there are no sprites, skip the rest
	ld b,a
	ld c,$00
.loadSpriteLoop\@
	ld a,[hli]
	ld [de],a ; store picture ID at C1X0
	inc d
	ld a,$04
	add e
	ld e,a
	ld a,[hli]
	ld [de],a ; store Y position at C2X4
	inc e
	ld a,[hli]
	ld [de],a ; store X position at C2X5
	inc e
	ld a,[hli]
	ld [de],a ; store movement byte 1 at C2X6
	ld a,[hli]
	ld [$ff8d],a ; save movement byte 2
	ld a,[hli]
	ld [$ff8e],a ; save text ID and flags byte
	push bc
	push hl
	ld b,$00
	ld hl,$d4e4 ; base address of sprite entries
	add hl,bc
	ld a,[$ff8d]
	ld [hli],a ; store movement byte 2 in byte 0 of sprite entry
	ld a,[$ff8e]
	ld [hl],a ; this appears pointless, since the value is overwritten immediately after
	ld a,[$ff8e]
	ld [$ff8d],a
	and a,$3f
	ld [hl],a ; store text ID in byte 1 of sprite entry
	pop hl
	ld a,[$ff8d]
	bit 6,a
	jr nz,.trainerSprite\@
	bit 7,a
	jr nz,.itemBallSprite\@
	jr .regularSprite\@
.trainerSprite\@
	ld a,[hli]
	ld [$ff8d],a ; save trainer class
	ld a,[hli]
	ld [$ff8e],a ; save trainer number (within class)
	push hl
	ld hl,$d504 ; base address of extra sprite info entries
	add hl,bc
	ld a,[$ff8d]
	ld [hli],a ; store trainer class in byte 0 of the entry
	ld a,[$ff8e]
	ld [hl],a ; store trainer number in byte 1 of the entry
	pop hl
	jr .nextSprite\@
.itemBallSprite\@
	ld a,[hli]
	ld [$ff8d],a ; save item number
	push hl
	ld hl,$d504 ; base address of extra sprite info
	add hl,bc
	ld a,[$ff8d]
	ld [hli],a ; store item number in byte 0 of the entry
	xor a
	ld [hl],a ; zero byte 1, since it is not used
	pop hl
	jr .nextSprite\@
.regularSprite\@
	push hl
	ld hl,$d504 ; base address of extra sprite info
	add hl,bc
; zero both bytes, since regular sprites don't use this extra space
	xor a
	ld [hli],a
	ld [hl],a
	pop hl
.nextSprite\@
	pop bc
	dec d
	ld a,$0a
	add e
	ld e,a
	inc c
	inc c
	dec b
	jp nz,.loadSpriteLoop\@
.finishUp\@
	ld a,$19
	call Predef ; load tileset data
	ld hl,$4eb8
	ld b,$03
	call Bankswitch ; load wild pokemon data
	pop hl ; restore hl from before going to the warp/sign/sprite data (this value was saved for seemingly no purpose)
	ld a,[W_CURMAPHEIGHT] ; map height in 4x4 tile blocks
	add a ; double it
	ld [$d524],a ; store map height in 2x2 tile blocks
	ld a,[W_CURMAPWIDTH] ; map width in 4x4 tile blocks
	add a ; double it
	ld [$d525],a ; map width in 2x2 tile blocks
	ld a,[W_CURMAP]
	ld c,a
	ld b,$00
	ld a,[$ffb8]
	push af
	ld a,$03
	ld [$ffb8],a
	ld [$2000],a
	ld hl,$404d
	add hl,bc
	add hl,bc
	ld a,[hli]
	ld [$d35b],a ; music 1
	ld a,[hl]
	ld [$d35c],a ; music 2
	pop af
	ld [$ffb8],a
	ld [$2000],a
	ret

; function to copy map connection data from ROM to WRAM
; Input: hl = source, de = destination
CopyMapConnectionHeader: ; 1238
	ld c,$0b
.loop\@
	ld a,[hli]
	ld [de],a
	inc de
	dec c
	jr nz,.loop\@
	ret

; function to load map data
LoadMapData: ; 1241
	ld a,[$ffb8]
	push af
	call DisableLCD
	ld a,$98
	ld [$d527],a
	xor a
	ld [$d526],a
	ld [$ffaf],a
	ld [$ffae],a
	ld [W_WALKCOUNTER],a
	ld [$d119],a
	ld [$d11a],a
	ld [$d3a8],a
	call $36a0 ; transfer tile pattern data for text windows into VRAM
	call LoadMapHeader
	ld b,$05
	ld hl,$785b
	call Bankswitch ; load tile pattern data for sprites
	call LoadTileBlockMap
	call LoadTilesetTilePatternData
	call LoadCurrentMapView
; copy current map view to VRAM
	ld hl,$c3a0
	ld de,$9800
	ld b,$12
.vramCopyLoop\@
	ld c,$14
.vramCopyInnerLoop\@
	ld a,[hli]
	ld [de],a
	inc e
	dec c
	jr nz,.vramCopyInnerLoop\@
	ld a,$0c
	add e
	ld e,a
	jr nc,.noCarry\@
	inc d
.noCarry\@
	dec b
	jr nz,.vramCopyLoop\@
	ld a,$01
	ld [$cfcb],a
	call EnableLCD
	ld b,$09
	call $3def ; handle SGB palette
	call LoadPlayerSpriteGraphics
	ld a,[$d732]
	and a,$18 ; did the player fly or teleport in?
	jr nz,.restoreRomBank\@
	ld a,[$d733]
	bit 1,a
	jr nz,.restoreRomBank\@
	call $235f ; music related
	call $2312 ; music related
.restoreRomBank\@
	pop af
	ld [$ffb8],a
	ld [$2000],a
	ret

; function to switch to the ROM bank that a map is stored in
; Input: a = map number
SwitchToMapRomBank: ; 12BC
	push hl
	push bc
	ld c,a
	ld b,$00
	ld a,$03
	call BankswitchHome ; switch to ROM bank 3
	ld hl,MapHeaderBanks
	add hl,bc
	ld a,[hl]
	ld [$ffe8],a ; save map ROM bank
	call BankswitchBack
	ld a,[$ffe8]
	ld [$ffb8],a
	ld [$2000],a ; switch to map ROM bank
	pop bc
	pop hl
	ret

INCBIN "baserom.gbc",$12DA,$1627 - $12DA

;XXX what does this do
;XXX what points to this
Unknown_1627: ; 0x1627
	ld bc,$D0B8
	add hl,bc
	ld a,[hli]
	ld [$D0AB],a
	ld a,[hl]
	ld [$D0AC],a

Unknown_1633: ; 0x1633
; define (by index number) the bank that a pokemon's image is in
; index = Mew, bank 1
; index = Kabutops fossil, bank $B
;	index < $1F, bank 9
; $1F ≤ index < $4A, bank $A
; $4A ≤ index < $74, bank $B
; $74 ≤ index < $99, bank $C
; $99 ≤ index,       bank $D
	ld a,[$CF91] ; XXX name for this ram location
	ld b,a
	cp $15
	ld a,$01
	jr z,.GotBank\@
	ld a,b
	cp $B6
	ld a,$0B
	jr z,.GotBank\@
	ld a,b
	cp $1F
	ld a,$09
	jr c,.GotBank\@
	ld a,b
	cp $4A
	ld a,$0A
	jr c,.GotBank\@
	ld a,b
	cp $74
	ld a,$0B
	jr c,.GotBank\@
	ld a,b
	cp $99
	ld a,$0C
	jr c,.GotBank\@
	ld a,$0D
.GotBank\@
	jp $24FD

INCBIN "baserom.gbc",$1665,$172F - $1665

Tset0B_Coll: ; 0x172F
	INCBIN "gfx/tilesets/0b.tilecoll"
Tset00_Coll: ; 0x1735
	INCBIN "gfx/tilesets/00.tilecoll"
Tset01_Coll: ; 0x1749
	INCBIN "gfx/tilesets/01.tilecoll"
Tset02_Coll: ; 0x1753
	INCBIN "gfx/tilesets/02.tilecoll"
Tset05_Coll: ; 0x1759
	INCBIN "gfx/tilesets/05.tilecoll"
Tset03_Coll: ; 0x1765
	INCBIN "gfx/tilesets/03.tilecoll"
Tset08_Coll: ; 0x1775
	INCBIN "gfx/tilesets/08.tilecoll"
Tset09_Coll: ; 0x177f
	INCBIN "gfx/tilesets/09.tilecoll"
Tset0D_Coll: ; 0x178a
	INCBIN "gfx/tilesets/0d.tilecoll"
Tset0E_Coll: ; 0x1795
	INCBIN "gfx/tilesets/0e.tilecoll"
Tset0F_Coll: ; 0x179a
	INCBIN "gfx/tilesets/0f.tilecoll"
Tset10_Coll: ; 0x17a2
	INCBIN "gfx/tilesets/10.tilecoll"
Tset11_Coll: ; 0x17ac
	INCBIN "gfx/tilesets/11.tilecoll"
Tset12_Coll: ; 0x17b8
	INCBIN "gfx/tilesets/12.tilecoll"
Tset13_Coll: ; 0x17c0
	INCBIN "gfx/tilesets/13.tilecoll"
Tset14_Coll: ; 0x17ca
	INCBIN "gfx/tilesets/14.tilecoll"
Tset15_Coll: ; 0x17d1
	INCBIN "gfx/tilesets/15.tilecoll"
Tset16_Coll: ; 0x17dd
	INCBIN "gfx/tilesets/16.tilecoll"
Tset17_Coll: ; 0x17f0
	INCBIN "gfx/tilesets/17.tilecoll"
;Tile Collision ends 0x17f7

INCBIN "baserom.gbc",$17F7,$190F-$17F7

ClearScreen: ; 190F
; clears all tiles in the tilemap,
; then wait three frames
	ld bc,$0168 ; tilemap size
	inc b
	ld hl,$C3A0 ; TILEMAP_START
	ld a,$7F    ; $7F is blank tile
.loop\@
	ld [hli],a
	dec c
	jr nz,.loop\@
	dec b
	jr nz,.loop\@
	jp Delay3

TextBoxBorder: ; 1922
; draw a text box
; upper-left corner at coordinates hl
; height b
; width c

	; first row
	push hl
	ld a,"┌"
	ld [hli],a
	inc a    ; horizontal border ─
	call NPlaceChar
	inc a    ; upper-right border ┐
	ld [hl],a

	; middle rows
	pop hl
	ld de,20
	add hl,de ; skip the top row

.PlaceRow\@
	push hl
	ld a,"│"
	ld [hli],a
	ld a," "
	call NPlaceChar
	ld [hl],"│"

	pop hl
	ld de,20
	add hl,de ; move to next row
	dec b
	jr nz,.PlaceRow\@

	; bottom row
	ld a,"└"
	ld [hli],a
	ld a,"─"
	call NPlaceChar
	ld [hl],"┘"
	ret
;
NPlaceChar: ; 0x194f
; place a row of width c of identical characters
	ld d,c
.loop\@
	ld [hli],a
	dec d
	jr nz,.loop\@
	ret

PlaceString: ; 1955
	push hl
PlaceNextChar: ; 1956
	ld a,[de]

	cp "@"
	jr nz,.PlaceText\@
	ld b,h
	ld c,l
	pop hl
	ret

.PlaceText\@
	cp $4E
	jr nz,.next\@
	ld bc,$0028
	ld a,[$FFF6]
	bit 2,a
	jr z,.next2\@
	ld bc,$14
.next2\@
	pop hl
	add hl,bc
	push hl
	jp Next19E8

.next\@
	cp $4F
	jr nz,.next3\@
	pop hl
	ld hl,$C4E1
	push hl
	jp Next19E8

.next3\@ ; Check against a dictionary
	and a
	jp z,Char00
	cp $4C
	jp z,$1B0A
	cp $4B
	jp z,Char4B
	cp $51
	jp z,Char51
	cp $49
	jp z,Char49
	cp $52
	jp z,Char52
	cp $53
	jp z,Char53
	cp $54
	jp z,Char54
	cp $5B
	jp z,Char5B
	cp $5E
	jp z,Char5E
	cp $5C
	jp z,Char5C
	cp $5D
	jp z,Char5D
	cp $55
	jp z,$1A7C
	cp $56
	jp z,Char56
	cp $57
	jp z,$1AAD
	cp $58
	jp z,Char58
	cp $4A
	jp z,Char4A
	cp $5F
	jp z,Char5F
	cp $59
	jp z,Char59
	cp $5A
	jp z,Char5A
	ld [hli],a
	call $38D3
Next19E8: ; 0x19e8
	inc de
	jp PlaceNextChar

Char00: ; 0x19ec
	ld b,h
	ld c,l
	pop hl
	ld de,Char00Text
	dec de
	ret

Char00Text: ; 0x19f4 “%d ERROR.”
	TX_FAR _Char00Text
	db "@"

Char52: ; 0x19f9 player’s name
	push de
	ld de,W_PLAYERNAME
	jr FinishDTE

Char53: ; rival’s name
	push de
	ld de,W_RIVALNAME
	jr FinishDTE

Char5D: ; TRAINER
	push de
	ld de,Char5DText
	jr FinishDTE

Char5C: ; TM
	push de
	ld de,Char5CText
	jr FinishDTE

Char5B: ; PC
	push de
	ld de,Char5BText
	jr FinishDTE

Char5E: ; ROCKET
	push de
	ld de,Char5EText
	jr FinishDTE

Char54: ; POKé
	push de
	ld de,Char54Text
	jr FinishDTE

Char56: ; ……
	push de
	ld de,Char56Text
	jr FinishDTE

Char4A: ; PKMN
	push de
	ld de,Char4AText
	jr FinishDTE

Char59:
; depending on whose turn it is, print
; enemy active monster’s name, prefixed with “Enemy ”
; or
; player active monster’s name
; (like Char5A but flipped)
	ld a,[H_WHOSETURN]
	xor 1
	jr MonsterNameCharsCommon

Char5A:
; depending on whose turn it is, print
; player active monster’s name
; or
; enemy active monster’s name, prefixed with “Enemy ”
	ld a,[H_WHOSETURN]
MonsterNameCharsCommon:
	push de
	and a
	jr nz,.Enemy\@
	ld de,$D009 ; player active monster name
	jr FinishDTE

.Enemy\@ ; 1A40
	; print “Enemy ”
	ld de,Char5AText
	call PlaceString

	ld h,b
	ld l,c
	ld de,$CFDA ; enemy active monster name

FinishDTE:
	call PlaceString
	ld h,b
	ld l,c
	pop de
	inc de
	jp PlaceNextChar

Char5CText: ; 0x1a55
	db "TM@"
Char5DText: ; 0x1a58
	db "TRAINER@"
Char5BText: ; 0x1a60
	db "PC@"
Char5EText: ; 0x1a63
	db "ROCKET@"
Char54Text: ; 0x1a6a
	db "POKé@"
Char56Text: ; 0x1a70
	db "……@"
Char5AText: ; 0x1a72
	db "Enemy @"
Char4AText: ; 0x1a79
	db $E1,$E2,"@" ; PKMN

Char55: ; 0x1a7c
	push de
	ld b,h
	ld c,l
	ld hl,Char55Text
	call $1B40
	ld h,b
	ld l,c
	pop de
	inc de
	jp PlaceNextChar

Char55Text: ; 0x1a8c
; equivalent to Char4B
	TX_FAR _Char55Text
	db "@"

Char5F: ; 0x1a91
; ends a Pokédex entry
	ld [hl],"."
	pop hl
	ret

Char58: ; 0x1a95
	ld a,[$D12B]
	cp 4
	jp z,Next1AA2
	ld a,$EE
	ld [$C4F2],a
Next1AA2: ; 0x1aa2
	call ProtectedDelay3
	call $3898
	ld a,$7F
	ld [$C4F2],a
	pop hl
	ld de,Char58Text
	dec de
	ret

Char58Text: ; 0x1ab3
	db "@"

Char51: ; 0x1ab4
	push de
	ld a,$EE
	ld [$C4F2],a
	call ProtectedDelay3
	call $3898
	ld hl,$C4A5
	ld bc,$0412
	call $18C4
	ld c,$14
	call DelayFrames
	pop de
	ld hl,$C4B9
	jp Next19E8

Char49: ; 0x1ad5
	push de
	ld a,$EE
	ld [$C4F2],a
	call ProtectedDelay3
	call $3898
	ld hl,$C469
	ld bc,$0712
	call $18C4
	ld c,$14
	call DelayFrames
	pop de
	pop hl
	ld hl,$C47D
	push hl
	jp Next19E8

Char4B: ; 0x1af8
	ld a,$EE
	ld [$C4F2],a
	call ProtectedDelay3
	push de
	call $3898
	pop de
	ld a,$7F
	ld [$C4F2],a
	push de
	call Next1B18
	call Next1B18
	ld hl,$C4E1
	pop de
	jp Next19E8

Next1B18: ; 0x1b18
	ld hl,$C4B8
	ld de,$C4A4
	ld b,$3C
.next\@
	ld a,[hli]
	ld [de],a
	inc de
	dec b
	jr nz,.next\@
	ld hl,$C4E1
	ld a,$7F
	ld b,$12
.next2\@
	ld [hli],a
	dec b
	jr nz,.next2\@

	; wait five frames
	ld b,5
.WaitFrame\@
	call DelayFrame
	dec b
	jr nz,.WaitFrame\@

	ret

ProtectedDelay3: ; 0x1b3a
	push bc
	call Delay3
	pop bc
	ret

TextCommandProcessor: ; 1B40
	ld a,[$d358]
	push af
	set 1,a
	ld e,a
	ld a,[$fff4]
	xor e
	ld [$d358],a
	ld a,c
	ld [$cc3a],a
	ld a,b
	ld [$cc3b],a

NextTextCommand: ; 1B55
	ld a,[hli]
	cp a,$50 ; terminator
	jr nz,.doTextCommand\@
	pop af
	ld [$d358],a
	ret
.doTextCommand\@
	push hl
	cp a,$17
	jp z,TextCommand17
	cp a,$0e
	jp nc,TextCommand0B ; if a != 0x17 and a >= 0xE, go to command 0xB
; if a < 0xE, use a jump table
	ld hl,TextCommandJumpTable
	push bc
	add a
	ld b,$00
	ld c,a
	add hl,bc
	pop bc
	ld a,[hli]
	ld h,[hl]
	ld l,a
	jp [hl]

; draw box
; 04AAAABBCC
; AAAA = address of upper left corner
; BB = height
; CC = width
TextCommand04: ; 1B78
	pop hl
	ld a,[hli]
	ld e,a
	ld a,[hli]
	ld d,a
	ld a,[hli]
	ld b,a
	ld a,[hli]
	ld c,a
	push hl
	ld h,d
	ld l,e
	call TextBoxBorder
	pop hl
	jr NextTextCommand

; place string inline
; 00{string}
TextCommand00: ; 1B8A
	pop hl
	ld d,h
	ld e,l
	ld h,b
	ld l,c
	call PlaceString
	ld h,d
	ld l,e
	inc hl
	jr NextTextCommand

; place string from RAM
; 01AAAA
; AAAA = address of string
TextCommand01: ; 1B97
	pop hl
	ld a,[hli]
	ld e,a
	ld a,[hli]
	ld d,a
	push hl
	ld h,b
	ld l,c
	call PlaceString
	pop hl
	jr NextTextCommand

; print BCD number
; 02AAAABB
; AAAA = address of BCD number
; BB
; bits 0-4 = length in bytes
; bits 5-7 = unknown flags
TextCommand02: ; 1BA5
	pop hl
	ld a,[hli]
	ld e,a
	ld a,[hli]
	ld d,a
	ld a,[hli]
	push hl
	ld h,b
	ld l,c
	ld c,a
	call $15cd
	ld b,h
	ld c,l
	pop hl
	jr NextTextCommand

; repoint destination address
; 03AAAA
; AAAA = new destination address
TextCommand03: ; 1BB7
	pop hl
	ld a,[hli]
	ld [$cc3a],a
	ld c,a
	ld a,[hli]
	ld [$cc3b],a
	ld b,a
	jp NextTextCommand

; repoint destination to second line of dialogue text box
; 05
; (no arguments)
TextCommand05: ; 1BC5
	pop hl
	ld bc,$c4e1 ; address of second line of dialogue text box
	jp NextTextCommand

; blink arrow and wait for A or B to be pressed
; 06
; (no arguments)
TextCommand06: ; 1BCC
	ld a,[W_ISLINKBATTLE]
	cp a,$04
	jp z,TextCommand0D
	ld a,$ee ; down arrow
	ld [$c4f2],a ; place down arrow in lower right corner of dialogue text box
	push bc
	call $3898 ; blink arrow and wait for A or B to be pressed
	pop bc
	ld a,$7f ; blank space
	ld [$c4f2],a ; overwrite down arrow with blank space
	pop hl
	jp NextTextCommand

; scroll text up one line
; 07
; (no arguments)
TextCommand07: ; 1BE7
	ld a,$7f ; blank space
	ld [$c4f2],a ; place blank space in lower right corner of dialogue text box
	call $1b18 ; scroll up text
	call $1b18
	pop hl
	ld bc,$c4e1 ; address of second line of dialogue text box
	jp NextTextCommand

; execute asm inline
; 08{code}
TextCommand08: ; 1BF9
	pop hl
	ld de,NextTextCommand
	push de ; return address
	jp [hl]

; print decimal number (converted from binary number)
; 09AAAABB
; AAAA = address of number
; BB
; bits 0-3 = how many digits to display
; bits 4-7 = how long the number is in bytes
TextCommand09: ; 1BFF
	pop hl
	ld a,[hli]
	ld e,a
	ld a,[hli]
	ld d,a
	ld a,[hli]
	push hl
	ld h,b
	ld l,c
	ld b,a
	and a,$0f
	ld c,a
	ld a,b
	and a,$f0
	swap a
	set 6,a
	ld b,a
	call $3c5f
	ld b,h
	ld c,l
	pop hl
	jp NextTextCommand

; wait half a second if the user doesn't hold A or B
; 0A
; (no arguments)
TextCommand0A: ; 1C1D
	push bc
	call GetJoypadState
	ld a,[$ffb4]
	and a,%00000011 ; A and B buttons
	jr nz,.skipDelay\@
	ld c,30
	call DelayFrames
.skipDelay\@
	pop bc
	pop hl
	jp NextTextCommand

; plays sounds
; this actually handles various command ID's, not just 0B
; (no arguments)
TextCommand0B: ; 1C31
	pop hl
	push bc
	dec hl
	ld a,[hli]
	ld b,a ; b = command number that got us here
	push hl
	ld hl,TextCommandSounds
.loop\@
	ld a,[hli]
	cp b
	jr z,.matchFound\@
	inc hl
	jr .loop\@
.matchFound\@
	cp a,$14
	jr z,.pokemonCry\@
	cp a,$15
	jr z,.pokemonCry\@
	cp a,$16
	jr z,.pokemonCry\@
	ld a,[hl]
	call $23b1
	call $3748
	pop hl
	pop bc
	jp NextTextCommand
.pokemonCry\@
	push de
	ld a,[hl]
	call $13d0
	pop de
	pop hl
	pop bc
	jp NextTextCommand

; format: text command ID, sound ID or cry ID
TextCommandSounds: ; 1C64
db $0B,$86
db $12,$9A
db $0E,$91
db $0F,$86
db $10,$89
db $11,$94
db $13,$98
db $14,$A8
db $15,$97
db $16,$78

; draw ellipses
; 0CAA
; AA = number of ellipses to draw
TextCommand0C: ; 1C78
	pop hl
	ld a,[hli]
	ld d,a
	push hl
	ld h,b
	ld l,c
.loop\@
	ld a,$75 ; ellipsis
	ld [hli],a
	push de
	call GetJoypadState
	pop de
	ld a,[$ffb4] ; joypad state
	and a,%00000011 ; is A or B button pressed?
	jr nz,.skipDelay\@ ; if so, skip the delay
	ld c,10
	call DelayFrames
.skipDelay\@
	dec d
	jr nz,.loop\@
	ld b,h
	ld c,l
	pop hl
	jp NextTextCommand

; wait for A or B to be pressed
; 0D
; (no arguments)
TextCommand0D: ; 1C9A
	push bc
	call $3898 ; wait for A or B to be pressed
	pop bc
	pop hl
	jp NextTextCommand

; process text commands in another ROM bank
; 17AAAABB
; AAAA = address of text commands
; BB = bank
TextCommand17: ; 1CA3
	pop hl
	ld a,[$ffb8]
	push af
	ld a,[hli]
	ld e,a
	ld a,[hli]
	ld d,a
	ld a,[hli]
	ld [$ffb8],a
	ld [$2000],a
	push hl
	ld l,e
	ld h,d
	call TextCommandProcessor
	pop hl
	pop af
	ld [$ffb8],a
	ld [$2000],a
	jp NextTextCommand

TextCommandJumpTable: ; 1CC1
dw TextCommand00
dw TextCommand01
dw TextCommand02
dw TextCommand03
dw TextCommand04
dw TextCommand05
dw TextCommand06
dw TextCommand07
dw TextCommand08
dw TextCommand09
dw TextCommand0A
dw TextCommand0B
dw TextCommand0C
dw TextCommand0D

; this function seems to be used only once
; it store the address of a row and column of the VRAM background map in hl
; INPUT: h - row, l - column, b - high byte of background tile map address in VRAM
GetRowColAddressBgMap: ; 1CDD
	xor a
	srl h
	rr a
	srl h
	rr a
	srl h
	rr a
	or l
	ld l,a
	ld a,b
	or h
	ld h,a
	ret

; clears a VRAM background map with blank space tiles
; INPUT: h - high byte of background tile map address in VRAM
ClearBgMap: ; 1CF0
	ld a,$7f ; blank space
	jr .next\@
	ld a,l ; XXX does anything call this?
.next\@
	ld de,$400 ; size of VRAM background map
	ld l,e
.loop\@
	ld [hli],a
	dec e
	jr nz,.loop\@
	dec d
	jr nz,.loop\@
	ret

; When the player takes a step, a row or column of 2x2 tile blocks at the edge
; of the screen toward which they moved is exposed and has to be redrawn.
; This function does the redrawing.
RedrawExposedScreenEdge: ; 1D01
	ld a,[H_SCREENEDGEREDRAW]
	and a
	ret z
	ld b,a
	xor a
	ld [H_SCREENEDGEREDRAW],a
	dec b
	jr nz,.redrawRow\@
.redrawColumn\@
	ld hl,W_SCREENEDGETILES
	ld a,[H_SCREENEDGEREDRAWADDR]
	ld e,a
	ld a,[H_SCREENEDGEREDRAWADDR + 1]
	ld d,a
	ld c,18 ; screen height
.loop1\@
	ld a,[hli]
	ld [de],a
	inc de
	ld a,[hli]
	ld [de],a
	ld a,31
	add e
	ld e,a
	jr nc,.noCarry\@
	inc d
.noCarry\@
; the following 4 lines wrap us from bottom to top if necessary
	ld a,d
	and a,$03
	or a,$98
	ld d,a
	dec c
	jr nz,.loop1\@
	xor a
	ld [H_SCREENEDGEREDRAW],a
	ret
.redrawRow\@
	ld hl,W_SCREENEDGETILES
	ld a,[H_SCREENEDGEREDRAWADDR]
	ld e,a
	ld a,[H_SCREENEDGEREDRAWADDR + 1]
	ld d,a
	push de
	call .drawHalf\@ ; draw upper half
	pop de
	ld a,32 ; width of VRAM background map
	add e
	ld e,a
	                 ; draw lower half
.drawHalf\@
	ld c,10
.loop2\@
	ld a,[hli]
	ld [de],a
	inc de
	ld a,[hli]
	ld [de],a
	ld a,e
	inc a
; the following 6 lines wrap us from the right edge to the left edge if necessary
	and a,$1f
	ld b,a
	ld a,e
	and a,$e0
	or b
	ld e,a
	dec c
	jr nz,.loop2\@
	ret

; This function automatically transfers tile number data from the tile map at
; C3A0 to VRAM during V-blank. Note that it only transfers one third of the
; background per V-blank. It cycles through which third it draws.
; This transfer is turned off when walking around the map, but is turned
; on when talking to sprites, battling, using menus, etc. This is because
; the above function, RedrawExposedScreenEdge, is used when walking to
; improve efficiency.
AutoBgMapTransfer: ; 1D57
	ld a,[H_AUTOBGTRANSFERENABLED]
	and a
	ret z
	ld hl,[sp + 0]
	ld a,h
	ld [H_SPTEMP],a
	ld a,l
	ld [H_SPTEMP + 1],a ; save stack pinter
	ld a,[H_AUTOBGTRANSFERPORTION]
	and a
	jr z,.transferTopThird\@
	dec a
	jr z,.transferMiddleThird\@
.transferBottomThird\@
	FuncCoord 0,12
	ld hl,Coord
	ld sp,hl
	ld a,[H_AUTOBGTRANSFERDEST + 1]
	ld h,a
	ld a,[H_AUTOBGTRANSFERDEST]
	ld l,a
	ld de,(12 * 32)
	add hl,de
	xor a ; TRANSFERTOP
	jr .doTransfer\@
.transferTopThird\@
	FuncCoord 0,0
	ld hl,Coord
	ld sp,hl
	ld a,[H_AUTOBGTRANSFERDEST + 1]
	ld h,a
	ld a,[H_AUTOBGTRANSFERDEST]
	ld l,a
	ld a,TRANSFERMIDDLE
	jr .doTransfer\@
.transferMiddleThird\@
	FuncCoord 0,6
	ld hl,Coord
	ld sp,hl
	ld a,[H_AUTOBGTRANSFERDEST + 1]
	ld h,a
	ld a,[H_AUTOBGTRANSFERDEST]
	ld l,a
	ld de,(6 * 32)
	add hl,de
	ld a,TRANSFERBOTTOM
.doTransfer\@
	ld [H_AUTOBGTRANSFERPORTION],a ; store next portion
	ld b,6

; unrolled loop and using pop for speed
TransferBgRows: ; 1D9E
	pop de
	ld [hl],e
	inc l
	ld [hl],d
	inc l
	pop de
	ld [hl],e
	inc l
	ld [hl],d
	inc l
	pop de
	ld [hl],e
	inc l
	ld [hl],d
	inc l
	pop de
	ld [hl],e
	inc l
	ld [hl],d
	inc l
	pop de
	ld [hl],e
	inc l
	ld [hl],d
	inc l
	pop de
	ld [hl],e
	inc l
	ld [hl],d
	inc l
	pop de
	ld [hl],e
	inc l
	ld [hl],d
	inc l
	pop de
	ld [hl],e
	inc l
	ld [hl],d
	inc l
	pop de
	ld [hl],e
	inc l
	ld [hl],d
	inc l
	pop de
	ld [hl],e
	inc l
	ld [hl],d
	ld a,13
	add l
	ld l,a
	jr nc,.noCarry\@
	inc h
.noCarry\@
	dec b
	jr nz,TransferBgRows
	ld a,[H_SPTEMP]
	ld h,a
	ld a,[H_SPTEMP + 1]
	ld l,a
	ld sp,hl ; restore stack pointer
	ret

; Copies [H_VBCOPYBGNUMROWS] rows from H_VBCOPYBGSRC to H_VBCOPYBGDEST.
; If H_VBCOPYBGSRC is XX00, the transfer is disabled.
VBlankCopyBgMap: ; 1DE1
	ld a,[H_VBCOPYBGSRC] ; doubles as enabling byte
	and a
	ret z
	ld hl,[sp + 0]
	ld a,h
	ld [H_SPTEMP],a
	ld a,l
	ld [H_SPTEMP + 1],a ; save stack pointer
	ld a,[H_VBCOPYBGSRC]
	ld l,a
	ld a,[H_VBCOPYBGSRC + 1]
	ld h,a
	ld sp,hl
	ld a,[H_VBCOPYBGDEST]
	ld l,a
	ld a,[H_VBCOPYBGDEST + 1]
	ld h,a
	ld a,[H_VBCOPYBGNUMROWS]
	ld b,a
	xor a
	ld [H_VBCOPYBGSRC],a ; disable transfer so it doesn't continue next V-blank
	jr TransferBgRows

; This function copies ([H_VBCOPYDOUBLESIZE] * 4) source bytes
; from H_VBCOPYDOUBLESRC to H_VBCOPYDOUBLEDEST.
; It copies each source byte to the destination twice (next to each other).
; The function updates the source and destination addresses, so the transfer
; can be continued easily by repeatingly calling this function.
VBlankCopyDouble: ; 1E02
	ld a,[H_VBCOPYDOUBLESIZE]
	and a ; are there any bytes to copy?
	ret z
	ld hl,[sp + 0]
	ld a,h
	ld [H_SPTEMP],a
	ld a,l
	ld [H_SPTEMP + 1],a ; save stack pointer
	ld a,[H_VBCOPYDOUBLESRC]
	ld l,a
	ld a,[H_VBCOPYDOUBLESRC + 1]
	ld h,a
	ld sp,hl
	ld a,[H_VBCOPYDOUBLEDEST]
	ld l,a
	ld a,[H_VBCOPYDOUBLEDEST + 1]
	ld h,a
	ld a,[H_VBCOPYDOUBLESIZE]
	ld b,a
	xor a
	ld [H_VBCOPYDOUBLESIZE],a ; disable transfer so it doesn't continue next V-blank
.loop\@
	pop de
	ld [hl],e
	inc l
	ld [hl],e
	inc l
	ld [hl],d
	inc l
	ld [hl],d
	inc l
	pop de
	ld [hl],e
	inc l
	ld [hl],e
	inc l
	ld [hl],d
	inc l
	ld [hl],d
	inc l
	pop de
	ld [hl],e
	inc l
	ld [hl],e
	inc l
	ld [hl],d
	inc l
	ld [hl],d
	inc l
	pop de
	ld [hl],e
	inc l
	ld [hl],e
	inc l
	ld [hl],d
	inc l
	ld [hl],d
	inc hl
	dec b
	jr nz,.loop\@
	ld a,l
	ld [H_VBCOPYDOUBLEDEST],a
	ld a,h
	ld [H_VBCOPYDOUBLEDEST + 1],a ; update destination address
	ld hl,[sp + 0]
	ld a,l
	ld [H_VBCOPYDOUBLESRC],a
	ld a,h
	ld [H_VBCOPYDOUBLESRC + 1],a ; update source address
	ld a,[H_SPTEMP]
	ld h,a
	ld a,[H_SPTEMP + 1]
	ld l,a
	ld sp,hl ; restore stack pointer
	ret

; Copies ([H_VBCOPYSIZE] * 8) bytes from H_VBCOPYSRC to H_VBCOPYDEST.
; The function updates the source and destination addresses, so the transfer
; can be continued easily by repeatingly calling this function.
VBlankCopy: ; 1E5E
	ld a,[H_VBCOPYSIZE]
	and a ; are there any bytes to copy?
	ret z
	ld hl,[sp + 0]
	ld a,h
	ld [H_SPTEMP],a
	ld a,l
	ld [H_SPTEMP + 1],a ; save stack pointer
	ld a,[H_VBCOPYSRC]
	ld l,a
	ld a,[H_VBCOPYSRC + 1]
	ld h,a
	ld sp,hl
	ld a,[H_VBCOPYDEST]
	ld l,a
	ld a,[H_VBCOPYDEST + 1]
	ld h,a
	ld a,[H_VBCOPYSIZE]
	ld b,a
	xor a
	ld [H_VBCOPYSIZE],a ; disable transfer so it doesn't continue next V-blank
.loop\@
	pop de
	ld [hl],e
	inc l
	ld [hl],d
	inc l
	pop de
	ld [hl],e
	inc l
	ld [hl],d
	inc l
	pop de
	ld [hl],e
	inc l
	ld [hl],d
	inc l
	pop de
	ld [hl],e
	inc l
	ld [hl],d
	inc l
	pop de
	ld [hl],e
	inc l
	ld [hl],d
	inc l
	pop de
	ld [hl],e
	inc l
	ld [hl],d
	inc l
	pop de
	ld [hl],e
	inc l
	ld [hl],d
	inc l
	pop de
	ld [hl],e
	inc l
	ld [hl],d
	inc hl
	dec b
	jr nz,.loop\@
	ld a,l
	ld [H_VBCOPYDEST],a
	ld a,h
	ld [H_VBCOPYDEST + 1],a
	ld hl,[sp + 0]
	ld a,l
	ld [H_VBCOPYSRC],a
	ld a,h
	ld [H_VBCOPYSRC + 1],a
	ld a,[H_SPTEMP]
	ld h,a
	ld a,[H_SPTEMP + 1]
	ld l,a
	ld sp,hl ; restore stack pointer
	ret

; This function updates the moving water and flower background tiles.
UpdateMovingBgTiles: ; 1EBE
	ld a,[$ffd7]
	and a
	ret z
	ld a,[$ffd8]
	inc a
	ld [$ffd8],a
	cp a,20
	ret c
	cp a,21
	jr z,.updateFlowerTile\@
	ld hl,$9140 ; water tile pattern VRAM location
	ld c,16 ; number of bytes in a tile pattern
	ld a,[$d085]
	inc a
	and a,$07
	ld [$d085],a
	and a,$04
	jr nz,.rotateWaterLeftLoop\@
.rotateWaterRightloop\@
	ld a,[hl]
	rrca
	ld [hli],a
	dec c
	jr nz,.rotateWaterRightloop\@
	jr .done\@
.rotateWaterLeftLoop\@
	ld a,[hl]
	rlca
	ld [hli],a
	dec c
	jr nz,.rotateWaterLeftLoop\@
.done\@
	ld a,[$ffd7]
	rrca
	ret nc
	xor a
	ld [$ffd8],a
	ret
.updateFlowerTile\@
	xor a
	ld [$ffd8],a
	ld a,[$d085]
	and a,$03
	cp a,2
	ld hl,FlowerTilePattern1
	jr c,.writeTilePatternToVram\@
	ld hl,FlowerTilePattern2
	jr z,.writeTilePatternToVram\@
	ld hl,FlowerTilePattern3
.writeTilePatternToVram\@
	ld de,$9030 ; flower tile pattern VRAM location
	ld c,16 ; number of bytes in a tile pattern
.flowerTileLoop\@
	ld a,[hli]
	ld [de],a
	inc de
	dec c
	jr nz,.flowerTileLoop\@
	ret

FlowerTilePattern1: ; 1F19
INCBIN "baserom.gbc",$1f19,16

FlowerTilePattern2: ; 1F29
INCBIN "baserom.gbc",$1f29,16

FlowerTilePattern3: ; 1F39
INCBIN "baserom.gbc",$1f39,16

INCBIN "baserom.gbc",$1F49,$1F54 - $1F49

; initialization code
; explanation for %11100011 (value stored in rLCDC)
; * LCD enabled
; * Window tile map at $9C00
; * Window display enabled
; * BG and window tile data at $8800
; * BG tile map at $9800
; * 8x8 OBJ size
; * OBJ display enabled
; * BG display enabled
InitGame: ; 1F54
	di
; zero I/O registers
	xor a
	ld [$ff0f],a
	ld [$ffff],a
	ld [$ff43],a
	ld [$ff42],a
	ld [$ff01],a
	ld [$ff02],a
	ld [$ff4b],a
	ld [$ff4a],a
	ld [$ff06],a
	ld [$ff07],a
	ld [$ff47],a
	ld [$ff48],a
	ld [$ff49],a
	ld a,%10000000 ; enable LCD
	ld [rLCDC],a
	call DisableLCD ; why enable then disable?
	ld sp,$dfff ; initialize stack pointer
	ld hl,$c000 ; start of WRAM
	ld bc,$2000 ; size of WRAM
.zeroWramLoop\@
	ld [hl],0
	inc hl
	dec bc
	ld a,b
	or c
	jr nz,.zeroWramLoop\@
	call ZeroVram
	ld hl,$ff80
	ld bc,$007f
	call $36e0 ; zero HRAM
	call CleanLCD_OAM ; this is unnecessary since it was already cleared above
	ld a,$01
	ld [$ffb8],a
	ld [$2000],a
	call $4bed ; copy DMA code to HRAM
	xor a
	ld [$ffd7],a
	ld [$ff41],a
	ld [$ffae],a
	ld [$ffaf],a
	ld [$ff0f],a
	ld a,%00001101 ; enable V-blank, timer, and serial interrupts
	ld [rIE],a
	ld a,$90 ; put the window off the screen
	ld [$ffb0],a
	ld [rWY],a
	ld a,$07
	ld [rWX],a
	ld a,$ff
	ld [$ffaa],a
	ld h,$98
	call ClearBgMap ; fill $9800-$9BFF (BG tile map) with $7F tiles
	ld h,$9c
	call ClearBgMap ; fill $9C00-$9FFF (Window tile map) with $7F tiles
	ld a,%11100011
	ld [rLCDC],a ; enabled LCD
	ld a,$10
	ld [$ff8a],a
	call $200e
	ei
	ld a,$40
	call Predef ; SGB border
	ld a,$1f
	ld [$c0ef],a
	ld [$c0f0],a
	ld a,$9c
	ld [$ffbd],a
	xor a
	ld [$ffbc],a
	dec a
	ld [$cfcb],a
	ld a,$32
	call Predef ; display the copyrights, GameFreak logo, and battle animation
	call DisableLCD
	call ZeroVram
	call $3ddc
	call CleanLCD_OAM
	ld a,%11100011
	ld [rLCDC],a ; enable LCD
	jp $42b7

; zeroes all VRAM
ZeroVram: ; 2004
	ld hl,$8000
	ld bc,$2000
	xor a
	jp $36e0

INCBIN "baserom.gbc",$200E,$2024 - $200E

VBlankHandler: ; 2024
	push af
	push bc
	push de
	push hl
	ld a,[$ffb8] ; current ROM bank
	ld [$d122],a
	ld a,[$ffae]
	ld [rSCX],a
	ld a,[$ffaf]
	ld [rSCY],a
	ld a,[$d0a0]
	and a
	jr nz,.doVramTransfers\@
	ld a,[$ffb0]
	ld [rWY],a
.doVramTransfers\@
	call AutoBgMapTransfer
	call VBlankCopyBgMap
	call RedrawExposedScreenEdge
	call VBlankCopy
	call VBlankCopyDouble
	call UpdateMovingBgTiles
	call $ff80 ; OAM DMA
	ld a,$01
	ld [$ffb8],a
	ld [$2000],a
	call $4b0f ; update OAM buffer with current sprite data
	call GenRandom
	ld a,[H_VBLANKOCCURRED]
	and a
	jr z,.next\@
	xor a
	ld [H_VBLANKOCCURRED],a
.next\@
	ld a,[H_FRAMECOUNTER]
	and a
	jr z,.handleMusic\@
	dec a
	ld [H_FRAMECOUNTER],a
.handleMusic\@
	call $28cb
	ld a,[$c0ef] ; music ROM bank
	ld [$ffb8],a
	ld [$2000],a
	cp a,$02
	jr nz,.checkIfBank08\@
.bank02\@
	call $5103
	jr .afterMusic\@
.checkIfBank08\@
	cp a,$08
	jr nz,.bank1F\@
.bank08\@
	call $536e
	call $5879
	jr .afterMusic\@
.bank1F\@
	call $5177
.afterMusic\@
	ld b,$06
	ld hl,$4dee
	call Bankswitch ; keep track of time played
	ld a,[$fff9]
	and a
	call z,ReadJoypadRegister
	ld a,[$d122]
	ld [$ffb8],a
	ld [$2000],a
	pop hl
	pop de
	pop bc
	pop af
	reti

DelayFrame: ; 20AF
; delay for one frame
	ld a,1
	ld [H_VBLANKOCCURRED],a

; wait for the next Vblank, halting to conserve battery
.halt\@
	db $76 ; XXX this is a hack--rgbasm adds a nop after this instr even when ints are enabled
	ld a,[H_VBLANKOCCURRED]
	and a
	jr nz,.halt\@

	ret

; These routines manage gradual fading
; (e.g., entering a doorway)
LoadGBPal: ; 20BA
	ld a,[$d35d] ;tells if cur.map is dark (requires HM5_FLASH?)
	ld b,a
	ld hl,GBPalTable_00	;16
	ld a,l
	sub b
	ld l,a
	jr nc,.jr0\@
	dec h
.jr0\@
	ld a,[hli]
	ld [rBGP],a
	ld a,[hli]
	ld [rOBP0],a
	ld a,[hli]
	ld [rOBP1],a
	ret

GBFadeOut1: ; 20D1
	ld hl,IncGradGBPalTable_01	;0d
	ld b,$04
	jr GBFadeOutCommon

GBFadeOut2: ; 20D8
	ld hl,IncGradGBPalTable_02	;1c
	ld b,$03

GBFadeOutCommon: ; 0x20dd
	ld a,[hli]
	ld [rBGP],a
	ld a,[hli]
	ld [rOBP0],a
	ld a,[hli]
	ld [rOBP1],a
	ld c,8
	call DelayFrames
	dec b
	jr nz,GBFadeOutCommon
	ret

GBFadeIn1: ; 20EF
	ld hl,DecGradGBPalTable_01	;18
	ld b,$04
	jr GBFadeInCommon

GBFadeIn2: ; 20F6
	ld hl,DecGradGBPalTable_02	;21
	ld b,$03

GBFadeInCommon: ; 0x20fb
	ld a,[hld]
	ld [rOBP1],a
	ld a,[hld]
	ld [rOBP0],a
	ld a,[hld]
	ld [rBGP],a
	ld c,8
	call DelayFrames
	dec b
	jr nz,GBFadeInCommon
	ret

IncGradGBPalTable_01: ; 210D
	db %11111111 ;BG Pal
	db %11111111 ;OBJ Pal 1
	db %11111111 ;OBJ Pal 2
                     ;and so on...
	db %11111110
	db %11111110
	db %11111000

	db %11111001
	db %11100100
	db %11100100
GBPalTable_00: ; 0x2116 16
	db %11100100
	db %11010000
DecGradGBPalTable_01: ; 0x2118 18
	db %11100000
	;19
	db %11100100
	db %11010000
	db %11100000
IncGradGBPalTable_02: ; 0x211c
	db %10010000
	db %10000000
	db %10010000

	db %01000000
	db %01000000
DecGradGBPalTable_02: ; 0x2121
	db %01000000

	db %00000000
	db %00000000
	db %00000000

INCBIN "baserom.gbc",$2125,$2442 - $2125

; XXX where is the pointer to this data?
MartInventories: ; 2442
	; first byte $FE, next byte # of items, last byte $FF

; Viridian
ViridianMartText4: ; 2442 XXX confirm
	db $FE,4,POKE_BALL,ANTIDOTE,PARLYZ_HEAL,BURN_HEAL,$FF

; Pewter
PewterMartText1: ; 2449
	db $FE,7,POKE_BALL,POTION,ESCAPE_ROPE,ANTIDOTE,BURN_HEAL,AWAKENING
	db PARLYZ_HEAL,$FF

; Cerulean
CeruleanMartText1: ; 2453
	db $FE,7,POKE_BALL,POTION,REPEL,ANTIDOTE,BURN_HEAL,AWAKENING
	db PARLYZ_HEAL,$FF

; Bike shop
	db $FE,1,BICYCLE,$FF

; Vermilion
VermilionMartText1: ; 2461
	db $FE,6,POKE_BALL,SUPER_POTION,ICE_HEAL,AWAKENING,PARLYZ_HEAL
	db REPEL,$FF

; Lavender
LavenderMartText1: ; 246a
	db $FE,9,GREAT_BALL,SUPER_POTION,REVIVE,ESCAPE_ROPE,SUPER_REPEL
	db ANTIDOTE,BURN_HEAL,ICE_HEAL,PARLYZ_HEAL,$FF

; Celadon Dept. Store 2F (1)
CeladonMart2Text1: ; 2476
	db $FE,9,GREAT_BALL,SUPER_POTION,REVIVE,SUPER_REPEL,ANTIDOTE
	db BURN_HEAL,ICE_HEAL,AWAKENING,PARLYZ_HEAL,$FF

; Celadon Dept. Store 2F (2)
CeladonMart2Text2: ; 2482
	db $FE,9,TM_32,TM_33,TM_02,TM_07,TM_37,TM_01,TM_05,TM_09,TM_17,$FF

; Celadon Dept. Store 4F
CeladonMart4Text1: ; 248e
	db $FE,5,POKE_DOLL,FIRE_STONE,THUNDER_STONE,WATER_STONE,LEAF_STONE,$FF

; Celadon Dept. Store 5F (1)
CeladonMart5Text3: ; 2496
	db $FE,7,X_ACCURACY,GUARD_SPEC_,DIRE_HIT,X_ATTACK,X_DEFEND,X_SPEED
	db X_SPECIAL,$FF

; Celadon Dept. Store 5F (2)
CeladonMart5Text4: ; 24a0
	db $FE,5,HP_UP,PROTEIN,IRON,CARBOS,CALCIUM,$FF

; Fuchsia
FuchsiaMartText1: ; 24a8
	db $FE,6,ULTRA_BALL,GREAT_BALL,SUPER_POTION,REVIVE,FULL_HEAL
	db SUPER_REPEL,$FF

; unused? 24b1
	db $FE,5,GREAT_BALL,HYPER_POTION,SUPER_POTION,FULL_HEAL,REVIVE,$FF

; Cinnabar
CinnabarMartText1: ; 24b9
	db $FE,7,ULTRA_BALL,GREAT_BALL,HYPER_POTION,MAX_REPEL,ESCAPE_ROPE
	db FULL_HEAL,REVIVE,$FF

; Saffron
SaffronMartText1: ; 24c3
	db $FE,6,GREAT_BALL,HYPER_POTION,MAX_REPEL,ESCAPE_ROPE,FULL_HEAL
	db REVIVE,$FF

; Indigo
IndigoPlateauLobbyText4: ; 24cc
	db $FE,7,ULTRA_BALL,GREAT_BALL,FULL_RESTORE,MAX_POTION,FULL_HEAL
	db REVIVE,MAX_REPEL,$FF

TextScriptEndingChar: ; 24D6
	db "@"
TextScriptEnd: ; 24D7 24d7
	ld hl,TextScriptEndingChar
	ret

UnnamedText_24db: ; 0x24db
	TX_FAR _UnnamedText_24db
	db $50
; 0x24db + 5 bytes

UnnamedText_24e0: ; 0x24e0
	TX_FAR _UnnamedText_24e0
	db $50
; 0x24e0 + 5 bytes

VictoryRoad3Text10:
VictoryRoad3Text9:
VictoryRoad3Text8:
VictoryRoad3Text7:
VictoryRoad2Text13:
VictoryRoad2Text12:
VictoryRoad2Text11:
SeafoamIslands1Text2:
SeafoamIslands1Text1:
SeafoamIslands5Text2:
SeafoamIslands5Text1:
SeafoamIslands4Text6:
SeafoamIslands4Text5:
SeafoamIslands4Text4:
SeafoamIslands4Text3:
SeafoamIslands4Text2:
SeafoamIslands4Text1:
SeafoamIslands3Text2:
SeafoamIslands3Text1:
SeafoamIslands2Text2:
SeafoamIslands2Text1:
FuchsiaHouse2Text3:
VictoryRoad1Text7:
VictoryRoad1Text6:
VictoryRoad1Text5: ; 0x24e5
	TX_FAR _VictoryRoad1Text5
	db $50

SaffronCityText19:
CinnabarIslandText4:
FuchsiaCityText14:
VermilionCityText9:
LavenderTownText6:
CeruleanCityText14:
PewterCityText8:
ViridianCityText11: ; 0x24ea
	TX_FAR _ViridianCityText11
	db $50

PewterCityText9:
CeruleanCityText15:
LavenderTownText7:
VermilionCityText10:
CeladonCityText12:
FuchsiaCityText15:
CinnabarIslandText5:
SaffronCityText23:
Route4Text4:
Route10Text8:
ViridianCityText12: ; 0x24ef
	TX_FAR _ViridianCityText12
	db $50

Route2Text1:
Route4Text3:
Route9Text10:
Route12Text9:
Route12Text10:
Route15Text11:
Route24Text8:
Route25Text10:
ViridianGymText11:
ViridianForestText5:
ViridianForestText6:
ViridianForestText7:
MtMoon1Text8:
MtMoon1Text9:
MtMoon1Text10:
MtMoon1Text11:
MtMoon1Text12:
MtMoon1Text13:
MtMoon3Text8:
MtMoon3Text9:
PowerPlantText10:
PowerPlantText11:
PowerPlantText12:
PowerPlantText13:
PowerPlantText14:
SSAnne8Text10:
SSAnne9Text6:
SSAnne9Text9:
SSAnne10Text9:
SSAnne10Text10:
SSAnne10Text11:
VictoryRoad1Text3:
VictoryRoad1Text4:
PokemonTower3Text4:
PokemonTower4Text4:
PokemonTower4Text5:
PokemonTower4Text6:
PokemonTower5Text6:
PokemonTower6Text4:
PokemonTower6Text5:
FuchsiaHouse2Text2:
VictoryRoad2Text7:
VictoryRoad2Text8:
VictoryRoad2Text9:
VictoryRoad2Text10:
VictoryRoad3Text5:
VictoryRoad3Text6:
RocketHideout1Text6:
RocketHideout1Text7:
RocketHideout2Text2:
RocketHideout2Text3:
RocketHideout2Text4:
RocketHideout2Text5:
RocketHideout3Text3:
RocketHideout3Text4:
RocketHideout4Text5:
RocketHideout4Text6:
RocketHideout4Text7:
RocketHideout4Text8:
RocketHideout4Text9:
SilphCo3Text4:
SilphCo4Text5:
SilphCo4Text6:
SilphCo4Text7:
SilphCo5Text6:
SilphCo5Text7:
SilphCo5Text8:
SilphCo6Text9:
SilphCo6Text10:
SilphCo7Text10:
SilphCo7Text11:
SilphCo7Text12:
Mansion1Text2:
Mansion1Text3:
Mansion2Text2:
Mansion3Text3:
Mansion3Text4:
Mansion4Text3:
Mansion4Text4:
Mansion4Text5:
Mansion4Text6:
Mansion4Text8:
SafariZoneEastText1:
SafariZoneEastText2:
SafariZoneEastText3:
SafariZoneEastText4:
SafariZoneNorthText1:
SafariZoneNorthText2:
SafariZoneWestText1:
SafariZoneWestText2:
SafariZoneWestText3:
SafariZoneWestText4:
SafariZoneCenterText1:
UnknownDungeon2Text1:
UnknownDungeon2Text2:
UnknownDungeon2Text3:
UnknownDungeon3Text2:
UnknownDungeon3Text3:
UnknownDungeon1Text1:
UnknownDungeon1Text2:
UnknownDungeon1Text3:
SilphCo10Text4:
SilphCo10Text5:
SilphCo10Text6:
Route2Text2: ; 24f4 0x424f4
	db $08 ; asm
	ld a, $5c
	call Predef
	jp TextScriptEnd

INCBIN "baserom.gbc",$24fd,$2920 - $24fd

; this function is used to display sign messages, sprite dialog, etc.
; INPUT: [$ff8c] = sprite ID or text ID
DisplayTextID: ; 2920
	ld a,[$ffb8]
	push af
	ld b,BANK(DisplayTextIDInit)
	ld hl,DisplayTextIDInit ; initialization
	call Bankswitch
	ld hl,$cf11
	bit 0,[hl]
	res 0,[hl]
	jr nz,.skipSwitchToMapBank\@
	ld a,[W_CURMAP]
	call SwitchToMapRomBank
.skipSwitchToMapBank\@
	ld a,30 ; half a second
	ld [H_FRAMECOUNTER],a ; used as joypad poll timer
	ld hl,W_MAPTEXTPTR
	ld a,[hli]
	ld h,[hl]
	ld l,a ; hl = map text pointer
	ld d,$00
	ld a,[$ff8c] ; text ID
	ld [$cf13],a
	and a
	jp z,DisplayStartMenu
	cp a,$d3 ; safari game over
	jp z,DisplaySafariGameOverText
	cp a,$d0 ; fainted
	jp z,DisplayPokemonFaintedText
	cp a,$d1 ; blacked out
	jp z,DisplayPlayerBlackedOutText
	cp a,$d2 ; repel wore off
	jp z,DisplayRepelWoreOffText
	ld a,[$d4e1] ; number of sprites
	ld e,a
	ld a,[$ff8c] ; sprite ID
	cp e
	jr z,.spriteHandling\@
	jr nc,.skipSpriteHandling\@
.spriteHandling\@
; get the text ID of the sprite
	push hl
	push de
	push bc
	ld b,$04
	ld hl,$7074
	call Bankswitch ; update the graphics of the sprite the player is talking to (to face the right direction)
	pop bc
	pop de
	ld hl,$d4e4 ; NPC text entries
	ld a,[$ff8c]
	dec a
	add a
	add l
	ld l,a
	jr nc,.noCarry\@
	inc h
.noCarry\@
	inc hl
	ld a,[hl] ; a = text ID of the sprite
	pop hl
.skipSpriteHandling\@
; look up the address of the text in the map's text entries
	dec a
	ld e,a
	sla e
	add hl,de
	ld a,[hli]
	ld h,[hl]
	ld l,a ; hl = address of the text
	ld a,[hl] ; a = first byte of text
; check first byte of text for special cases
	cp a,$fe   ; Pokemart NPC
	jp z,DisplayPokemartDialogue
	cp a,$ff   ; Pokemon Center NPC
	jp z,DisplayPokemonCenterDialogue
	cp a,$fc   ; Item Storage PC
	jp z,$3460
	cp a,$fd   ; Bill's PC
	jp z,$346a
	cp a,$f9   ; Pokemon Center PC
	jp z,$347f
	cp a,$f5   ; Vending Machine
	jr nz,.notVendingMachine\@
	ld b,$1d
	ld hl,Unknown_74ee0
	call Bankswitch
	jr AfterDisplayingTextID
.notVendingMachine\@
	cp a,$f7   ; slot machine
	jp z,$3474
	cp a,$f6   ; cable connection NPC in Pokemon Center
	jr nz,.notSpecialCase\@
	ld hl,$71c5
	ld b,$01
	call Bankswitch
	jr AfterDisplayingTextID
.notSpecialCase\@
	call $3c59 ; display the text
	ld a,[$cc3c]
	and a
	jr nz,HoldTextDisplayOpen

AfterDisplayingTextID: ; 29D6
	ld a,[$cc47]
	and a
	jr nz,HoldTextDisplayOpen
	call $3865 ; wait for a button press after displaying all the text

; loop to hold the dialogue box open as long as the player keeps holding down the A button
HoldTextDisplayOpen: ; 29DF
	call GetJoypadState
	ld a,[$ffb4]
	bit 0,a ; is the A button being pressed?
	jr nz,HoldTextDisplayOpen

CloseTextDisplay: ; 29E8
	ld a,[W_CURMAP]
	call SwitchToMapRomBank
	ld a,$90
	ld [$ffb0],a ; move the window off the screen
	call DelayFrame
	call LoadGBPal
	xor a
	ld [H_AUTOBGTRANSFERENABLED],a ; disable continuous WRAM to VRAM transfer each V-blank
; loop to make sprites face the directions they originally faced before the dialogue
	ld hl,$c219
	ld c,$0f
	ld de,$0010
.restoreSpriteFacingDirectionLoop\@
	ld a,[hl]
	dec h
	ld [hl],a
	inc h
	add hl,de
	dec c
	jr nz,.restoreSpriteFacingDirectionLoop\@
	ld a,$05
	ld [$ffb8],a
	ld [$2000],a
	call $785b ; reload sprite tile pattern data (since it was partially overwritten by text tile patterns)
	ld hl,$cfc4
	res 0,[hl]
	ld a,[$d732]
	bit 3,a
	call z,LoadPlayerSpriteGraphics
	call LoadCurrentMapView
	pop af
	ld [$ffb8],a
	ld [$2000],a
	jp $2429 ; move sprites

DisplayPokemartDialogue: ; 2A2E
	push hl
	ld hl,PokemartGreetingText
	call PrintText
	pop hl
	inc hl
	call LoadPokemartInventory
	ld a,$02
	ld [$cf94],a ; selects between subtypes of menus
	ld a,[$ffb8]
	push af
	ld a,$01
	ld [$ffb8],a
	ld [$2000],a
	call $6c20
	pop af
	ld [$ffb8],a
	ld [$2000],a
	jp AfterDisplayingTextID

PokemartGreetingText: ; 0x2a55
	TX_FAR _PokemartGreetingText
	db $50

LoadPokemartInventory: ; 2A5A
	ld a,$01
	ld [$cfcb],a
	ld a,h
	ld [$d128],a
	ld a,l
	ld [$d129],a
	ld de,$cf7b
.loop\@
	ld a,[hli]
	ld [de],a
	inc de
	cp a,$ff
	jr nz,.loop\@
	ret

DisplayPokemonCenterDialogue: ; 2A72
	xor a
	ld [$ff8b],a
	ld [$ff8c],a
	ld [$ff8d],a
	inc hl
	ld a,[$ffb8]
	push af
	ld a,$01
	ld [$ffb8],a
	ld [$2000],a
	call $6fe6
	pop af
	ld [$ffb8],a
	ld [$2000],a
	jp AfterDisplayingTextID

DisplaySafariGameOverText: ; 2A90
	ld hl,$69ed
	ld b,$07
	call Bankswitch
	jp AfterDisplayingTextID

DisplayPokemonFaintedText: ; 2A9B
	ld hl,PokemonFaintedText
	call PrintText
	jp AfterDisplayingTextID

PokemonFaintedText: ; 0x2aa4
	TX_FAR _PokemonFaintedText
	db $50

DisplayPlayerBlackedOutText: ; 2AA9
	ld hl,PlayerBlackedOutText
	call PrintText
	ld a,[$d732]
	res 5,a
	ld [$d732],a
	jp HoldTextDisplayOpen

PlayerBlackedOutText: ; 0x2aba
	TX_FAR _PlayerBlackedOutText
	db $50

DisplayRepelWoreOffText: ; 2ABF
	ld hl,RepelWoreOffText
	call PrintText
	jp AfterDisplayingTextID

RepelWoreOffText: ; 0x2ac8
	TX_FAR _RepelWoreOffText
	db $50

DisplayStartMenu: ; 2ACD
	ld a,$04
	ld [$ffb8],a
	ld [$2000],a ; ROM bank 4
	ld a,[$d700] ; walking/biking/surfing
	ld [$d11a],a
	ld a,$8f ; Start menu sound
	call $23b1
	ld b,BANK(DrawStartMenu)
	ld hl,DrawStartMenu
	call Bankswitch
	ld b,$03
	ld hl,$452f
	call Bankswitch ; print Safari Zone info, if in Safari Zone
	call $2429 ; move sprites
.loop\@
	call HandleMenuInput
	ld b,a
.checkIfUpPressed\@
	bit 6,a ; was Up pressed?
	jr z,.checkIfDownPressed\@
	ld a,[W_CURMENUITEMID] ; menu selection
	and a
	jr nz,.loop\@
	ld a,[W_OLDMENUITEMID]
	and a
	jr nz,.loop\@
; if the player pressed tried to go past the top item, wrap around to the bottom
	ld a,[$d74b]
	bit 5,a ; does the player have the pokedex?
	ld a,6 ; there are 7 menu items with the pokedex, so the max index is 6
	jr nz,.wrapMenuItemId\@
	dec a ; there are only 6 menu items without the pokedex
.wrapMenuItemId\@
	ld [W_CURMENUITEMID],a
	call EraseMenuCursor
	jr .loop\@
.checkIfDownPressed\@
	bit 7,a
	jr z,.buttonPressed\@
; if the player pressed tried to go past the bottom item, wrap around to the top
	ld a,[$d74b]
	bit 5,a ; does the player have the pokedex?
	ld a,[W_CURMENUITEMID]
	ld c,7 ; there are 7 menu items with the pokedex
	jr nz,.checkIfPastBottom\@
	dec c ; there are only 6 menu items without the pokedex
.checkIfPastBottom\@
	cp c
	jr nz,.loop\@
; the player went past the bottom, so wrap to the top
	xor a
	ld [W_CURMENUITEMID],a
	call EraseMenuCursor
	jr .loop\@
.buttonPressed\@ ; A, B, or Start button pressed
	call PlaceUnfilledArrowMenuCursor
	ld a,[W_CURMENUITEMID]
	ld [$cc2d],a ; save current menu item ID
	ld a,b
	and a,%00001010 ; was the Start button or B button pressed?
	jp nz,.closeMenu\@
	call $36f4 ; copy background from $C3A0 to $CD81
	ld a,[$d74b]
	bit 5,a ; does the player have the pokedex?
	ld a,[W_CURMENUITEMID]
	jr nz,.displayMenuItem\@
	inc a ; adjust position to account for missing pokedex menu item
.displayMenuItem\@
	cp a,0
	jp z,$7095 ; POKEDEX
	cp a,1
	jp z,$70a9 ; POKEMON
	cp a,2
	jp z,$7302 ; ITEM
	cp a,3
	jp z,$7460 ; Trainer Info
	cp a,4
	jp z,$75e3 ; SAVE / RESET
	cp a,5
	jp z,$75f6 ; OPTION
; EXIT falls through to here
.closeMenu\@
	call GetJoypadState
	ld a,[$ffb3]
	bit 0,a ; was A button newly pressed?
	jr nz,.closeMenu\@
	call $36a0 ; transfer tile pattern data for text windows into VRAM
	jp CloseTextDisplay

INCBIN "baserom.gbc",$2b7f,$2f9e - $2b7f

GetMonName: ; 2F9E
	push hl
	ld a,[$ffb8]
	push af
	ld a,BANK(MonsterNames) ; 07
	ld [$ffb8],a
	ld [$2000],a
	ld a,[$d11e]
	dec a
	ld hl,MonsterNames ; 421E
	ld c,10
	ld b,0
	call AddNTimes
	ld de,$cd6d
	push de
	ld bc,10
	call CopyData
	ld hl,$cd77
	ld [hl],$50
	pop de
	pop af
	ld [$ffb8],a
	ld [$2000],a
	pop hl
	ret

GetItemName: ; 2FCF
; given an item ID at [$D11E], store the name of the item into a string
;     starting at $CD6D
	push hl
	push bc
	ld a,[$D11E]
	cp HM_01 ; is this a TM/HM?
	jr nc,.Machine\@

	ld [$D0B5],a
	ld a,ITEM_NAME
	ld [$D0B6],a
	ld a,BANK(ItemNames)
	ld [$D0B7],a
	call GetName
	jr .Finish\@

.Machine\@
	call GetMachineName
.Finish\@
	ld de,$CD6D ; pointer to where item name is stored in RAM
	pop bc
	pop hl
	ret

GetMachineName: ; 2ff3
; copies the name of the TM/HM in [$D11E] to $CD6D
	push hl
	push de
	push bc
	ld a,[$D11E]
	push af
	cp TM_01 ; is this a TM? [not HM]
	jr nc,.WriteTM\@
; if HM, then write "HM" and add 5 to the item ID, so we can reuse the
; TM printing code
	add 5
	ld [$D11E],a
	ld hl,HiddenPrefix ; points to "HM"
	ld bc,2
	jr .WriteMachinePrefix\@
.WriteTM\@
	ld hl,TechnicalPrefix ; points to "TM"
	ld bc,2
.WriteMachinePrefix\@
	ld de,$CD6D
	call CopyData

; now get the machine number and convert it to text
	ld a,[$D11E]
	sub TM_01 - 1
	ld b,$F6 ; "0"
.FirstDigit\@
	sub 10
	jr c,.SecondDigit\@
	inc b
	jr .FirstDigit\@
.SecondDigit\@
	add 10
	push af
	ld a,b
	ld [de],a
	inc de
	pop af
	ld b,$F6 ; "0"
	add b
	ld [de],a
	inc de
	ld a,"@"
	ld [de],a

	pop af
	ld [$D11E],a
	pop bc
	pop de
	pop hl
	ret

TechnicalPrefix: ; 303c
	db "TM"
HiddenPrefix: ; 303e
	db "HM"

INCBIN "baserom.gbc",$3040,$31cc - $3040

LoadTrainerHeader: ; 0x31cc
	call $3157
	xor a
	call $3193
	ld a, $2
	call $3193
	ld a, [$cc55]
	ld c, a
	ld b, $2
	call $31c7
	ld a, c
	and a
	jr z, .asm_c2964 ; 0x31e3 $8
	ld a, $6
	call $3193
	jp PrintText
.asm_c2964 ; 0x31ed
	ld a, $4
	call $3193
	call PrintText
	ld a, $a
	call $3193
	push de
	ld a, $8
	call $3193
	pop de
	call $3354
	ld hl, $d733
	set 4, [hl]
	ld hl, $cd60
	bit 0, [hl]
	ret nz
	call $336a
	ld hl, $da39
	inc [hl]
	jp $325d
	call $3306
	ld a, [$cf13]
	cp $ff
	jr nz, .asm_76c22 ; 0x3221 $8
	xor a
	ld [$cf13], a
	ld [$cc55], a
	ret
.asm_76c22 ; 0x322b
	ld hl, $d733
	set 3, [hl]
	ld [$cd4f], a
	xor a
	ld [$cd50], a
	ld a, $4c
	call Predef
	ld a, $f0
	ld [$cd6b], a
	xor a
	ldh [$b4], a
	call $32cf
	ld hl, $da39
	inc [hl]
	ret

INCBIN "baserom.gbc",$324c,$3474 - $324c

FuncTX_F7: ; 3474
; XXX find a better name for this function
; special_F7
	ld b,BANK(CeladonPrizeMenu)
	ld hl,CeladonPrizeMenu
	call Bankswitch
	jp $29DF        ; continue to main text-engine function

INCBIN "baserom.gbc",$347F,$3493 - $347F

IsItemInBag: ; 3493
; given an item_id in b
; set zero flag if item isn't in player's bag
; else reset zero flag
; related to Pokémon Tower and ghosts
	ld a,$1C
	call Predef
	ld a,b
	and a
	ret

INCBIN "baserom.gbc",$349B,$3541 - $349B

Function3541: ; 3541
; XXX what do these three functions do
	push hl
	call Function354E
	ld [hl],$FF
	call Function3558
	ld [hl],$FF ; prevent person from walking?
	pop hl
	ret

Function354E: ; 354E
	ld h,$C2
	ld a,[$FF8C] ; the sprite to move
	swap a
	add a,6
	ld l,a
	ret

Function3558: ; 3558
	push de
	ld hl,W_PEOPLEMOVEPERMISSIONS
	ld a,[$FF8C] ; the sprite to move
	dec a
	add a
	ld d,0
	ld e,a
	add hl,de
	pop de
	ret

INCBIN "baserom.gbc",$3566,$35BC - $3566

BankswitchHome: ; 35BC
; switches to bank # in a
; Only use this when in the home bank!
	ld [$CF09],a
	ld a,[$FFB8]
	ld [$CF08],a
	ld a,[$CF09]
	ld [$FFB8],a
	ld [$2000],a
	ret

BankswitchBack: ; 35CD
; returns from BankswitchHome
	ld a,[$CF08]
	ld [$FFB8],a
	ld [$2000],a
	ret

Bankswitch: ; 35D6
; self-contained bankswitch, use this when not in the home bank
; switches to the bank in b
	ld a,[$FFB8]
	push af
	ld a,b
	ld [$FFB8],a
	ld [$2000],a
	ld bc,.Return\@
	push bc
	jp [hl]
.Return\@
	pop bc
	ld a,b
	ld [$FFB8],a
	ld [$2000],a
	ret

INCBIN "baserom.gbc",$35EC,$363A - $35EC

MoveSprite: ; 363A
; move the sprite [$FF8C] with the movement pointed to by de
; actually only copies the movement data to $CC5B for later
	call Function3541
	push hl
	push bc
	call Function354E
	xor a
	ld [hl],a
	ld hl,$CC5B
	ld c,0

.loop\@
	ld a,[de]
	ld [hli],a
	inc de
	inc c
	cp a,$FF ; have we reached the end of the movement data?
	jr nz,.loop\@

	ld a,c
	ld [$CF0F],a ; number of steps taken

	pop bc
	ld hl,$D730
	set 0,[hl]
	pop hl
	xor a
	ld [$CD3B],a
	ld [$CCD3],a
	dec a
	ld [$CD6B],a
	ld [$CD3A],a
	ret

INCBIN "baserom.gbc",$366B,$3739 - $366B

DelayFrames: ; 3739
; wait n frames, where n is the value in c
	call DelayFrame
	dec c
	jr nz,DelayFrames
	ret

INCBIN "baserom.gbc",$3740,$375D - $3740

NamePointers: ; 375D
	dw MonsterNames
	dw MoveNames
	dw UnusedNames
	dw ItemNames
	dw $D273 ; player's OT names list
	dw $D9AC ; enemy's OT names list
	dw TrainerNames

GetName: ; 376B
; arguments:
; [$D0B5] = which name
; [$D0B6] = which list
; [$D0B7] = bank of list
;
; returns pointer to name in de
	ld a,[$d0b5]
	ld [$d11e],a
	cp a,$C4        ;it's TM/HM
	jp nc,GetMachineName
	ld a,[$ffb8]
	push af
	push hl
	push bc
	push de
	ld a,[$d0b6]    ;List3759_entrySelector
	dec a
	jr nz,.otherEntries\@
	;1 = MON_NAMES
	call GetMonName
	ld hl,11
	add hl,de
	ld e,l
	ld d,h
	jr .gotPtr\@
.otherEntries\@ ; $378d
	;2-7 = OTHER ENTRIES
	ld a,[$d0b7]
	ld [$ffb8],a
	ld [$2000],a
	ld a,[$d0b6]    ;VariousNames' entryID
	dec a
	add a
	ld d,0
	ld e,a
	jr nc,.skip\@
	inc d
.skip\@ ; $37a0
	ld hl,NamePointers
	add hl,de
	ld a,[hli]
	ld [$ff96],a
	ld a,[hl]
	ld [$ff95],a
	ld a,[$ff95]
	ld h,a
	ld a,[$ff96]
	ld l,a
	ld a,[$d0b5]
	ld b,a
	ld c,0
.nextName\@
	ld d,h
	ld e,l
.nextChar\@
	ld a,[hli]
	cp a,$50
	jr nz,.nextChar\@
	inc c           ;entry counter
	ld a,b          ;wanted entry
	cp c
	jr nz,.nextName\@
	ld h,d
	ld l,e
	ld de,$cd6d
	ld bc,$0014
	call CopyData
.gotPtr\@ ; $37cd
	ld a,e
	ld [$cf8d],a
	ld a,d
	ld [$cf8e],a
	pop de
	pop bc
	pop hl
	pop af
	ld [$ffb8],a
	ld [$2000],a
	ret

INCBIN "baserom.gbc",$37df,$3831 - $37df

; this function is used when lower button sensitivity is wanted (e.g. menus)
; OUTPUT: [$ffb5] = pressed buttons in usual format
; there are two flags that control its functionality, [$ffb6] and [$ffb7]
; there are esentially three modes of operation
; 1. Get newly pressed buttons only
;    ([$ffb7] == 0, [$ffb6] == any)
;    Just copies [$ffb3] to [$ffb5].
; 2. Get currently pressed buttons at low sample rate with delay
;    ([$ffb7] == 1, [$ffb6] != 0)
;    If the user holds down buttons for more than half a second,
;    report buttons as being pressed up to 12 times per second thereafter.
;    If the user holds down buttons for less than half a second,
;    report only one button press.
; 3. Same as 2, but report no buttons as pressed if A or B is held down.
;    ([$ffb7] == 1, [$ffb6] == 0)
GetJoypadStateLowSensitivity: ; 3831
	call GetJoypadState
	ld a,[$ffb7] ; flag
	and a ; get all currently pressed buttons or only newly pressed buttons?
	ld a,[$ffb3] ; newly pressed buttons
	jr z,.storeButtonState\@
	ld a,[$ffb4] ; all currently pressed buttons
.storeButtonState\@
	ld [$ffb5],a
	ld a,[$ffb3] ; newly pressed buttons
	and a ; have any buttons been newly pressed since last check?
	jr z,.noNewlyPressedButtons\@
.newlyPressedButtons\@
	ld a,30 ; half a second delay
	ld [H_FRAMECOUNTER],a
	ret
.noNewlyPressedButtons\@
	ld a,[H_FRAMECOUNTER]
	and a ; is the delay over?
	jr z,.delayOver\@
.delayNotOver\@
	xor a
	ld [$ffb5],a ; report no buttons as pressed
	ret
.delayOver\@
; if [$ffb6] = 0 and A or B is pressed, report no buttons as pressed
	ld a,[$ffb4]
	and a,%00000011 ; A and B buttons
	jr z,.setShortDelay\@
	ld a,[$ffb6] ; flag
	and a
	jr nz,.setShortDelay\@
	xor a
	ld [$ffb5],a             
.setShortDelay\@
	ld a,5 ; 1/12 of a second delay
	ld [H_FRAMECOUNTER],a
	ret

INCBIN "baserom.gbc",$3865,$38AC - $3865

; function to do multiplication
; all values are big endian
; INPUT
; FF96-FF98 =  multiplicand
; FF99 = multiplier
; OUTPUT
; FF95-FF98 = product
Multiply: ; 38AC
	push hl
	push bc
	ld hl,$7d41
	ld b,$0d
	call Bankswitch
	pop bc
	pop hl
	ret

; function to do division
; all values are big endian
; INPUT
; FF95-FF98 = dividend
; FF99 = divisor
; b = number of signficant bytes in the dividend (starting from FF95)
; all bytes considered "not signifcant" will be treated as 0
; OUTPUT
; FF95-FF98 = quotient
; FF99 = remainder
Divide: ; 38B9
	push hl
	push de
	push bc
	ld a,[$ffb8]
	push af
	ld a,$0d
	ld [$ffb8],a
	ld [$2000],a
	call $7da5
	pop af
	ld [$ffb8],a
	ld [$2000],a
	pop bc
	pop de
	pop hl
	ret

; This function is used to wait a short period after printing a letter to the
; screen unless the player presses the A/B button or the delay is turned off
; through the [$d730] or [$d358] flags.
PrintLetterDelay: ; 38D3
	ld a,[$d730]
	bit 6,a
	ret nz
	ld a,[$d358]
	bit 1,a
	ret z
	push hl
	push de
	push bc
	ld a,[$d358]
	bit 0,a
	jr z,.waitOneFrame\@
	ld a,[$d355]
	and a,$0f
	ld [H_FRAMECOUNTER],a
	jr .checkButtons\@
.waitOneFrame\@
	ld a,1
	ld [H_FRAMECOUNTER],a
.checkButtons\@
	call GetJoypadState
	ld a,[$ffb4]
.checkAButton\@
	bit 0,a ; is the A button pressed?
	jr z,.checkBButton\@
	jr .endWait\@
.checkBButton\@
	bit 1,a ; is the B button pressed?
	jr z,.buttonsNotPressed\@
.endWait\@
	call DelayFrame
	jr .done\@
.buttonsNotPressed\@ ; if neither A nor B is pressed
	ld a,[H_FRAMECOUNTER]
	and a
	jr nz,.checkButtons\@
.done\@
	pop bc
	pop de
	pop hl
	ret

; Copies [hl, bc) to [de, bc - hl).
; In other words, the source data is from hl up to but not including bc,
; and the destination is de.
CopyDataUntil: ; 3913
	ld a,[hli]
	ld [de],a
	inc de
	ld a,h
	cp b
	jr nz,CopyDataUntil
	ld a,l
	cp c
	jr nz,CopyDataUntil
	ret

; Function to remove a pokemon from the party or the current box.
; W_WHICHPOKEMON determines the pokemon.
; [$cf95] == 0 specifies the party.
; [$cf95] != 0 specifies the current box.
RemovePokemon: ; 391F
	ld hl,$7b68
	ld b,$01
	jp Bankswitch

AddPokemonToParty: ; 0x3927
	push hl
	push de
	push bc
	ld b, $3 ; BANK(MyFunction)
	ld hl, $72e5 ; MyFunction
	call Bankswitch
	pop bc
	pop de
	pop hl
	ret

INCBIN "baserom.gbc",$3936,$3A87 - $3936

AddNTimes: ; 3A87
; add bc to hl a times
	and a
	ret z
.loop\@
	add hl,bc
	dec a
	jr nz,.loop\@
	ret

; Compare strings, c bytes in length, at de and hl.
; Often used to compare big endian numbers in battle calculations.
StringCmp: ; 3A8E
	ld a,[de]
	cp [hl]
	ret nz
	inc de
	inc hl
	dec c
	jr nz,StringCmp
	ret

; INPUT:
; a = oam block index (each block is 4 oam entries)
; b = Y coordinate of upper left corner of sprite
; c = X coordinate of upper left corner of sprite
; de = base address of 4 tile number and attribute pairs
WriteOAMBlock: ; 3A97
	ld h,$c3
	swap a ; multiply by 16
	ld l,a
	call .writeOneEntry\@ ; upper left
	push bc
	ld a,8
	add c
	ld c,a
	call .writeOneEntry\@ ; upper right
	pop bc
	ld a,8
	add b
	ld b,a
	call .writeOneEntry\@ ; lower left
	ld a,8
	add c
	ld c,a
	                      ; lower right
.writeOneEntry\@
	ld [hl],b ; Y coordinate
	inc hl
	ld [hl],c ; X coordinate
	inc hl
	ld a,[de] ; tile number
	inc de
	ld [hli],a
	ld a,[de] ; attribute
	inc de
	ld [hli],a
	ret

HandleMenuInput: ; 3ABE
	xor a
	ld [$d09b],a

HandleMenuInputPokemonSelection: ; 3AC2
	ld a,[H_DOWNARROWBLINKCNT1]
	push af
	ld a,[H_DOWNARROWBLINKCNT2]
	push af ; save existing values on stack
	xor a
	ld [H_DOWNARROWBLINKCNT1],a ; blinking down arrow timing value 1
	ld a,$06
	ld [H_DOWNARROWBLINKCNT2],a ; blinking down arrow timing value 2
.loop1\@
	xor a
	ld [$d08b],a ; counter for pokemon shaking animation
	call PlaceMenuCursor
	call Delay3
.loop2\@
	push hl
	ld a,[$d09b]
	and a ; is it a pokemon selection menu?
	jr z,.getJoypadState\@
	ld b,$1c
	ld hl,$56ff ; shake mini sprite of selected pokemon
	call Bankswitch
.getJoypadState\@
	pop hl
	call GetJoypadStateLowSensitivity
	ld a,[$ffb5]
	and a ; was a key pressed?
	jr nz,.keyPressed\@
	push hl
	FuncCoord 18,11 ; coordinates of blinking down arrow in some menus
	ld hl,Coord
	call $3c04 ; blink down arrow (if any)
	pop hl
	ld a,[W_MENUJOYPADPOLLCOUNT]
	dec a
	jr z,.giveUpWaiting\@
	jr .loop2\@
.giveUpWaiting\@
; if a key wasn't pressed within the specified number of checks
	pop af
	ld [H_DOWNARROWBLINKCNT2],a
	pop af
	ld [H_DOWNARROWBLINKCNT1],a ; restore previous values
	xor a
	ld [W_MENUWRAPPINGENABLED],a ; disable menu wrapping
	ret
.keyPressed\@
	xor a
	ld [$cc4b],a
	ld a,[$ffb5]
	ld b,a
	bit 6,a ; pressed Up key?
	jr z,.checkIfDownPressed\@
.upPressed\@
	ld a,[W_CURMENUITEMID] ; selected menu item
	and a ; already at the top of the menu?
	jr z,.alreadyAtTop\@
.notAtTop\@
	dec a
	ld [W_CURMENUITEMID],a ; move selected menu item up one space
	jr .checkOtherKeys\@
.alreadyAtTop\@
	ld a,[W_MENUWRAPPINGENABLED]
	and a ; is wrapping around enabled?
	jr z,.noWrappingAround\@
	ld a,[W_MAXMENUITEMID]
	ld [W_CURMENUITEMID],a ; wrap to the bottom of the menu
	jr .checkOtherKeys\@
.checkIfDownPressed\@
	bit 7,a
	jr z,.checkOtherKeys\@
.downPressed\@
	ld a,[W_CURMENUITEMID]
	inc a
	ld c,a
	ld a,[W_MAXMENUITEMID]
	cp c
	jr nc,.notAtBottom\@
.alreadyAtBottom\@
	ld a,[W_MENUWRAPPINGENABLED]
	and a ; is wrapping around enabled?
	jr z,.noWrappingAround\@
	ld c,$00 ; wrap from bottom to top
.notAtBottom\@
	ld a,c
	ld [W_CURMENUITEMID],a
.checkOtherKeys\@
	ld a,[W_MENUWATCHEDKEYS]
	and b ; does the menu care about any of the pressed keys?
	jp z,.loop1\@
.checkIfAButtonOrBButtonPressed\@
	ld a,[$ffb5]
	and a,%00000011 ; pressed A button or B button?
	jr z,.skipPlayingSound\@
.AButtonOrBButtonPressed\@
	push hl
	ld hl,$cd60
	bit 5,[hl]
	pop hl
	jr nz,.skipPlayingSound\@
	ld a,$90
	call $23b1 ; play sound
.skipPlayingSound\@
	pop af
	ld [H_DOWNARROWBLINKCNT2],a
	pop af
	ld [H_DOWNARROWBLINKCNT1],a ; restore previous values
	xor a
	ld [W_MENUWRAPPINGENABLED],a ; disable menu wrapping
	ld a,[$ffb5]
	ret
.noWrappingAround\@
	ld a,[$cc37]
	and a ; should we return if the user tried to go past the top or bottom?
	jr z,.checkOtherKeys\@
	jr .checkIfAButtonOrBButtonPressed\@

PlaceMenuCursor: ; 3B7C
	ld a,[W_TOPMENUITEMY]
	and a ; is the y coordinate 0?
	jr z,.adjustForXCoord\@
	ld hl,$c3a0
	ld bc,20 ; screen width
.topMenuItemLoop\@
	add hl,bc
	dec a
	jr nz,.topMenuItemLoop\@
.adjustForXCoord\@
	ld a,[W_TOPMENUITEMX]
	ld b,$00
	ld c,a
	add hl,bc
	push hl
	ld a,[W_OLDMENUITEMID]
	and a ; was the previous menu id 0?
	jr z,.checkForArrow1\@
	push af
	ld a,[$fff6]
	bit 1,a ; is the menu double spaced?
	jr z,.doubleSpaced1\@
	ld bc,20
	jr .getOldMenuItemScreenPosition\@
.doubleSpaced1\@
	ld bc,40
.getOldMenuItemScreenPosition\@
	pop af
.oldMenuItemLoop\@
	add hl,bc
	dec a
	jr nz,.oldMenuItemLoop\@
.checkForArrow1\@
	ld a,[hl]
	cp a,$ed ; was an arrow next to the previously selected menu item?
	jr nz,.skipClearingArrow\@
.clearArrow\@
	ld a,[W_TILEBEHINDCURSOR]
	ld [hl],a
.skipClearingArrow\@
	pop hl
	ld a,[W_CURMENUITEMID]
	and a
	jr z,.checkForArrow2\@
	push af
	ld a,[$fff6]
	bit 1,a ; is the menu double spaced?
	jr z,.doubleSpaced2\@
	ld bc,20
	jr .getCurrentMenuItemScreenPosition\@
.doubleSpaced2\@
	ld bc,40
.getCurrentMenuItemScreenPosition\@
	pop af
.currentMenuItemLoop\@
	add hl,bc
	dec a
	jr nz,.currentMenuItemLoop\@
.checkForArrow2\@
	ld a,[hl]
	cp a,$ed ; has the right arrow already been placed?
	jr z,.skipSavingTile\@ ; if so, don't lose the saved tile
	ld [W_TILEBEHINDCURSOR],a ; save tile before overwriting with right arrow
.skipSavingTile\@
	ld a,$ed ; place right arrow
	ld [hl],a
	ld a,l
	ld [W_MENUCURSORLOCATION],a
	ld a,h
	ld [W_MENUCURSORLOCATION + 1],a
	ld a,[W_CURMENUITEMID]
	ld [W_OLDMENUITEMID],a
	ret

; This is used to mark a menu cursor other than the one currently being
; manipulated. In the case of submenus, this is used to show the location of
; the menu cursor in the parent menu. In the case of swapping items in list,
; this is used to mark the item that was first chosen to be swapped.
PlaceUnfilledArrowMenuCursor: ; 3BEC
	ld b,a
	ld a,[W_MENUCURSORLOCATION]
	ld l,a
	ld a,[W_MENUCURSORLOCATION + 1]
	ld h,a
	ld [hl],$ec ; outline of right arrow
	ld a,b
	ret

; Replaces the menu cursor with a blank space.
EraseMenuCursor: ; 3BF9
	ld a,[W_MENUCURSORLOCATION]
	ld l,a
	ld a,[W_MENUCURSORLOCATION + 1]
	ld h,a
	ld [hl],$7f ; blank space
	ret

; This toggles a blinking down arrow at hl on and off after a delay has passed.
; This is often called even when no blinking is occurring.
; The reason is that most functions that call this initialize H_DOWNARROWBLINKCNT1 to 0.
; The effect is that if the tile at hl is initialized with a down arrow,
; this function will toggle that down arrow on and off, but if the tile isn't
; initliazed with a down arrow, this function does nothing.
; That allows this to be called without worrying about if a down arrow should
; be blinking.
HandleDownArrowBlinkTiming: ; 3C04
	ld a,[hl]
	ld b,a
	ld a,$ee ; down arrow
	cp b
	jr nz,.downArrowOff\@
.downArrowOn\@
	ld a,[H_DOWNARROWBLINKCNT1]
	dec a
	ld [H_DOWNARROWBLINKCNT1],a
	ret nz
	ld a,[H_DOWNARROWBLINKCNT2]
	dec a
	ld [H_DOWNARROWBLINKCNT2],a
	ret nz
	ld a,$7f ; blank space
	ld [hl],a
	ld a,$ff
	ld [H_DOWNARROWBLINKCNT1],a
	ld a,$06
	ld [H_DOWNARROWBLINKCNT2],a
	ret
.downArrowOff\@
	ld a,[H_DOWNARROWBLINKCNT1]
	and a
	ret z
	dec a
	ld [H_DOWNARROWBLINKCNT1],a
	ret nz
	dec a
	ld [H_DOWNARROWBLINKCNT1],a
	ld a,[H_DOWNARROWBLINKCNT2]
	dec a
	ld [H_DOWNARROWBLINKCNT2],a
	ret nz
	ld a,$06
	ld [H_DOWNARROWBLINKCNT2],a
	ld a,$ee ; down arrow
	ld [hl],a
	ret

; The following code either enables or disables the automatic drawing of
; text boxes by DisplayTextID. Both functions cause DisplayTextID to wait
; for a button press after displaying text (unless [$cc47] is set).

EnableAutoTextBoxDrawing: ; 3C3C
	xor a
	jr AutoTextBoxDrawingCommon

DisableAutoTextBoxDrawing: ; 3C3F
	ld a,$01

AutoTextBoxDrawingCommon: ; 3C41
	ld [$cf0c],a ; control text box drawing
	xor a
	ld [$cc3c],a ; make DisplayTextID wait for button press
	ret

PrintText: ; 3C49
; given a pointer in hl, print the text there
	push hl
	ld a,1
	ld [$D125],a
	call $30E8
	call $2429
	call Delay3
	pop hl
	FuncCoord 1,14
	ld bc,Coord ;$C4B9
	jp $1B40

Func3C5F: ; 3C5F
	push bc
	xor a
	ld [$FF95],a
	ld [$FF96],a
	ld [$FF97],a
	ld a,b
	and $F
	cp 1
	jr z,.next\@
	cp 2
	jr z,.next2\@
	ld a,[de]
	ld [$FF96],a
	inc de
	ld a,[de]
	ld [$FF97],a
	inc de
	ld a,[de]
	ld [$FF98],a
	jr .next3\@

.next2\@
	ld a,[de]
	ld [$FF97],a
	inc de
	ld a,[de]
	ld [$FF98],a
	jr .next3\@

.next\@
	ld a,[de]
	ld [$FF98],a

.next3\@
	push de
	ld d,b
	ld a,c
	ld b,a
	xor a
	ld c,a
	ld a,b
	cp 2
	jr z,.next4\@
	cp 3
	jr z,.next5\@
	cp 4
	jr z,.next6\@
	cp 5
	jr z,.next7\@
	cp 6
	jr z,.next8\@
	ld a,$F
	ld [$FF99],a
	ld a,$42
	ld [$FF9A],a
	ld a,$40
	ld [$FF9B],a
	call $3D25
	call $3D89
.next8\@
	ld a,1
	ld [$FF99],a
	ld a,$86
	ld [$FF9A],a
	ld a,$A0
	ld [$FF9B],a
	call $3D25
	call $3D89
.next7\@
	xor a
	ld [$FF99],a
	ld a,$27
	ld [$FF9A],a
	ld a,$10
	ld [$FF9B],a
	call $3D25
	call $3D89
.next6\@
	xor a
	ld [$FF99],a
	ld a,3
	ld [$FF9A],a
	ld a,$E8
	ld [$FF9B],a
	call $3D25
	call $3D89
.next5\@
	xor a
	ld [$FF99],a
	xor a
	ld [$FF9A],a
	ld a,$64
	ld [$FF9B],a
	call $3D25
	call $3D89
.next4\@
	ld c,0
	ld a,[$FF98]
.next10\@
	cp $A
	jr c,.next9\@
	sub $A
	inc c
	jr .next10\@
.next9\@
	ld b,a
	ld a,[$FF95]
	or c
	ld [$FF95],a
	jr nz,.next11\@
	call $3D83
	jr .next12\@
.next11\@
	ld a,$F6
	add a,c
	ld [hl],a
.next12\@
	call $3D89
	ld a,$F6
	add a,b
	ld [hli],a
	pop de
	dec de
	pop bc
	ret

INCBIN "baserom.gbc",$3D25,$3DAB - $3D25

IsInArray: ; 3DAB
; searches an array at hl for the value in a.
; skips (de − 1) bytes between reads, so to check every byte, de should be 1.
; if found, returns count in b and sets carry.
	ld b,0
	ld c,a
.loop\@
	ld a,[hl]
	cp a,$FF
	jr z,.NotInArray\@
	cp c
	jr z,.InArray\@
	inc b
	add hl,de
	jr .loop\@
.NotInArray\@
	and a
	ret
.InArray\@
	scf
	ret

INCBIN "baserom.gbc",$3DBE,$3DD7 - $3DBE

Delay3: ; 3DD7
; call Delay with a parameter of 3
	ld c,3
	jp DelayFrames

INCBIN "baserom.gbc",$3DDC,$3DED - $3DDC

GoPAL_SET_CF1C: ; 3ded
	ld b,$ff
GoPAL_SET: 	; 3def
	ld a,[$cf1b]
	and a
	ret z
	ld a,$45
	jp Predef

INCBIN "baserom.gbc",$3df9,$3e2e - $3df9

GiveItem: ; 0x3e2e
	ld a, b
	ld [$d11e], a
	ld [$cf91], a
	ld a, c
	ld [$cf96], a
	ld hl,W_NUMBAGITEMS
	call $2bcf
	ret nc
	call GetItemName ; $2fcf
	call $3826
	scf
	ret

GivePokemon: ; 0x3e48
	ld a, b
	ld [$cf91], a
	ld a, c
	ld [$d127], a
	xor a
	ld [$cc49], a
	ld b, $13
	ld hl, $7da5
	jp Bankswitch

GenRandom: ; 3E5C
; store a random 8-bit value in a
	push hl
	push de
	push bc
	ld b,BANK(GenRandom_)
	ld hl,GenRandom_
	call Bankswitch
	ld a,[H_RAND1]
	pop bc
	pop de
	pop hl
	ret

Predef: ; 3E6D
; runs a predefined ASM command, where the command ID is read from $D0B7
; $3E6D grabs the ath pointer from PredefPointers and executes it

	ld [$CC4E],a ; save the predef routine's ID for later

	ld a,[$FFB8]
	ld [$CF12],a

	; save bank and call 13:7E49
	push af
	ld a,BANK(GetPredefPointer)
	ld [$FFB8],a
	ld [$2000],a
	call GetPredefPointer

	; call the predef function
	; ($D0B7 has the bank of the predef routine)
	ld a,[$D0B7]
	ld [$FFB8],a
	ld [$2000],a
	ld de,.Return\@
	push de
	jp [hl]
	; after the predefined function finishes it returns here
.Return\@
	pop af
	ld [$FFB8],a
	ld [$2000],a
	ret

INCBIN "baserom.gbc",$3E94,$4000 - $3E94

SECTION "bank1",DATA,BANK[$1]

INCBIN "baserom.gbc",$4000,$112

MewPicFront: ; 0x4112
	INCBIN "pic/bmon/mew.pic"
MewPicBack: ; 0x4205
	INCBIN "pic/monback/mewb.pic"
; 0x425b

MewBaseStats: ; 0x425b
	db DEX_MEW ; pokedex id
	db 100 ; base hp
	db 100 ; base attack
	db 100 ; base defense
	db 100 ; base speed
	db 100 ; base special

	db PSYCHIC ; species type 1
	db PSYCHIC ; species type 2

	db 45 ; catch rate
	db 64 ; base exp yield
	db $55 ; sprite dimensions

	dw MewPicFront
	dw MewPicBack
	
	; attacks known at lvl 0
	db POUND
	db 0
	db 0
	db 0

	db 3 ; growth rate
	
	; include learnset directly
	db %11111111
	db %11111111
	db %11111111
	db %11111111
	db %11111111
	db %11111111
	db %11111111
	db %11111111 ; usually spacing

INCBIN "baserom.gbc",$4277,$30

UnnamedText_42a7: ; 0x42a7
	TX_FAR SafariZoneEatingText
	db $50
; 0x42a7 + 5 bytes

UnnamedText_42ac: ; 0x42ac
	TX_FAR SafariZoneAngryText
	db $50
; 0x42ac + 5 bytes

INCBIN "baserom.gbc",$42b1,$84

; 0x4335
IF _RED
	ld de,$9600 ; where to put redgreenversion.2bpp in the VRAM
	ld bc,$50 ; how big that file is
ENDC
IF _BLUE
	ld de,$9610 ; where to put blueversion.2bpp in the VRAM
	ld bc,$40 ; how big that file is
ENDC

INCBIN "baserom.gbc",$433B,$4398-$433B

IF _RED
	ld a,CHARMANDER ; which Pokemon to show first on the title screen
ENDC
IF _BLUE
	ld a,SQUIRTLE ; which Pokemon to show first on the title screen
ENDC

INCBIN "baserom.gbc",$439A,$4588-$439A

TitleMons: ; 4588
; mons on the title screen are randomly chosen from here
IF _RED
	db CHARMANDER
	db SQUIRTLE
	db BULBASAUR
	db WEEDLE
	db NIDORAN_M
	db SCYTHER
	db PIKACHU
	db CLEFAIRY
	db RHYDON
	db ABRA
	db GASTLY
	db DITTO
	db PIDGEOTTO
	db ONIX
	db PONYTA
	db MAGIKARP
ENDC
IF _GREEN
	db BULBASAUR
	db CHARMANDER
	db SQUIRTLE
	db CATERPIE
	db NIDORAN_F
	db PINSIR
	db PIKACHU
	db CLEFAIRY
	db RHYDON
	db ABRA
	db GASTLY
	db DITTO
	db PIDGEOTTO
	db ONIX
	db PONYTA
	db MAGIKARP
ENDC
IF _BLUE
	db SQUIRTLE
	db CHARMANDER
	db BULBASAUR
	db MANKEY
	db HITMONLEE
	db VULPIX
	db CHANSEY
	db AERODACTYL
	db JOLTEON
	db SNORLAX
	db GLOOM
	db POLIWAG
	db DODUO
	db PORYGON
	db GENGAR
	db RAICHU
ENDC

INCBIN "baserom.gbc",$4598,$45A1-$4598

; xxx Version tilemap on the title screen
IF _RED
	db $60,$61,$7F,$65,$66,$67,$68,$69,$50
ENDC
IF _BLUE
	db $61,$62,$63,$64,$65,$66,$67,$68,$50
ENDC

INCBIN "baserom.gbc",$45AA,$472B-$45AA

ItemNames: ; 472B
	db "MASTER BALL@"
	db "ULTRA BALL@"
	db "GREAT BALL@"
	db "POKé BALL@"
	db "TOWN MAP@"
	db "BICYCLE@"
	db "?????@"
	db "SAFARI BALL@"
	db "POKéDEX@"
	db "MOON STONE@"
	db "ANTIDOTE@"
	db "BURN HEAL@"
	db "ICE HEAL@"
	db "AWAKENING@"
	db "PARLYZ HEAL@"
	db "FULL RESTORE@"
	db "MAX POTION@"
	db "HYPER POTION@"
	db "SUPER POTION@"
	db "POTION@"
	db "BOULDERBADGE@"
	db "CASCADEBADGE@"
	db "THUNDERBADGE@"
	db "RAINBOWBADGE@"
	db "SOULBADGE@"
	db "MARSHBADGE@"
	db "VOLCANOBADGE@"
	db "EARTHBADGE@"
	db "ESCAPE ROPE@"
	db "REPEL@"
	db "OLD AMBER@"
	db "FIRE STONE@"
	db "THUNDERSTONE@"
	db "WATER STONE@"
	db "HP UP@"
	db "PROTEIN@"
	db "IRON@"
	db "CARBOS@"
	db "CALCIUM@"
	db "RARE CANDY@"
	db "DOME FOSSIL@"
	db "HELIX FOSSIL@"
	db "SECRET KEY@"
	db "?????@"
	db "BIKE VOUCHER@"
	db "X ACCURACY@"
	db "LEAF STONE@"
	db "CARD KEY@"
	db "NUGGET@"
	db "PP UP@"
	db "POKé DOLL@"
	db "FULL HEAL@"
	db "REVIVE@"
	db "MAX REVIVE@"
	db "GUARD SPEC.@"
	db "SUPER REPEL@"
	db "MAX REPEL@"
	db "DIRE HIT@"
	db "COIN@"
	db "FRESH WATER@"
	db "SODA POP@"
	db "LEMONADE@"
	db "S.S.TICKET@"
	db "GOLD TEETH@"
	db "X ATTACK@"
	db "X DEFEND@"
	db "X SPEED@"
	db "X SPECIAL@"
	db "COIN CASE@"
	db "OAK's PARCEL@"
	db "ITEMFINDER@"
	db "SILPH SCOPE@"
	db "POKé FLUTE@"
	db "LIFT KEY@"
	db "EXP.ALL@"
	db "OLD ROD@"
	db "GOOD ROD@"
	db "SUPER ROD@"
	db "PP UP@"
	db "ETHER@"
	db "MAX ETHER@"
	db "ELIXER@"
	db "MAX ELIXER@"
	db "B2F@"
	db "B1F@"
	db "1F@"
	db "2F@"
	db "3F@"
	db "4F@"
	db "5F@"
	db "6F@"
	db "7F@"
	db "8F@"
	db "9F@"
	db "10F@"
	db "11F@"
	db "B4F@"

UnusedNames: ; 4A92
	db "かみなりバッヂ@"
	db "かいがらバッヂ@"
	db "おじぞうバッヂ@"
	db "はやぶさバッヂ@"
	db "ひんやりバッヂ@"
	db "なかよしバッヂ@"
	db "バラバッヂ@"
	db "ひのたまバッヂ@"
	db "ゴールドバッヂ@"
	db "たまご@"
	db "ひよこ@"
	db "ブロンズ@"
	db "シルバー@"
	db "ゴールド@"
	db "プチキャプテン@"
	db "キャプテン@"
	db "プチマスター@"
	db "マスター@"

INCBIN "baserom.gbc",$4b09,$4e2c - $4b09

UnnamedText_4e2c: ; 0x4e2c
	TX_FAR _UnnamedText_4e2c
	db $50
; 0x4e2c + 5 bytes

INCBIN "baserom.gbc",$4e31,$5a24 - $4e31

SSAnne8AfterBattleText2: ; 0x5a24
	TX_FAR _SSAnne8AfterBattleText2
	db $50
; 0x5a24 + 5 bytes

INCBIN "baserom.gbc",$5a29,$c9

MainMenu: ; 0x5af2
; Check save file
	call Func_5bff
	xor a
	ld [$D08A],a
	inc a
	ld [$D088],a
	call $609E
	jr nc,.next0\@

	; Predef 52 loads the save from SRAM to RAM
	ld a,$52
	call Predef

.next0\@
	ld c,20
	call DelayFrames
	xor a
	ld [$D12B],a
	ld hl,$CC2B
	ld [hli],a
	ld [hli],a
	ld [hli],a
	ld [hl],a
	ld [$D07C],a
	ld hl,$D72E
	res 6,[hl]
	call ClearScreen
	call $3DED
	call $36A0 ; load some graphics in VRAM
	call $3680 ; load fonts in VRAM
	ld hl,$D730
	set 6,[hl]
	ld a,[$D088]
	cp a,1
	jr z,.next1\@
	FuncCoord 0,0
	ld hl,Coord
	ld b,6
	ld c,13
	call TextBoxBorder
	FuncCoord 2,2
	ld hl,Coord
	ld de,$5D7E
	call PlaceString
	jr .next2\@
.next1\@
	FuncCoord 0,0
	ld hl,Coord
	ld b,4
	ld c,13
	call TextBoxBorder
	FuncCoord 2,2
	ld hl,Coord
	ld de,$5D87
	call PlaceString
.next2\@
	ld hl,$D730
	res 6,[hl]
	call $2429 ; OAM?
	xor a
	ld [$CC26],a
	ld [$CC2A],a
	ld [$CC34],a
	inc a
	ld [$CC25],a
	inc a
	ld [$CC24],a
	ld a,$B
	ld [$CC29],a
	ld a,[$D088]
	ld [$CC28],a
	call $3ABE
	bit 1,a
	jp nz,$42DD ; load title screen (gfx and arrangement)
	ld c,20
	call DelayFrames
	ld a,[$CC26]
	ld b,a
	ld a,[$D088]
	cp a,2
	jp z,.next3\@
	inc b ; adjust MenuArrow_Counter
.next3\@
	ld a,b
	and a
	jr z,.next4\@ ; if press_A on Continue
	cp a,1
	jp z,$5D52 ; if press_A on NewGame
	call $5E8A ; if press_a on Options
	ld a,1
	ld [$D08A],a
	jp .next0\@
.next4\@
	call $5DB5
	ld hl,$D126
	set 5,[hl]
.next6\@
	xor a
	ld [$FFB3],a
	ld [$FFB2],a
	ld [$FFB4],a
	call GetJoypadState
	ld a,[$FFB4]
	bit 0,a
	jr nz,.next5\@
	bit 1,a
	jp nz,.next0\@
	jr .next6\@
.next5\@
	call $3DD4
	call ClearScreen
	ld a,4
	ld [$D52A],a
	ld c,10
	call DelayFrames
	ld a,[$D5A2]
	and a
	jp z,$5D5F
	ld a,[W_CURMAP] ; map ID
	cp a,HALL_OF_FAME
	jp nz,$5D5F
	xor a
	ld [$D71A],a
	ld hl,$D732
	set 2,[hl]
	call $62CE
	jp $5D5F
Func_5bff: ; 0x5bff
	ld a,1
	ld [$D358],a
	ld a,3
	ld [$D355],a
	ret
; 0x5c0a

INCBIN "baserom.gbc",$5c0a,$5d43 - $5c0a

UnnamedText_5d43: ; 0x5d43
	TX_FAR _UnnamedText_5d43
	db $50
; 0x5d43 + 5 bytes

UnnamedText_5d48: ; 0x5d48
	TX_FAR _UnnamedText_5d48
	db $50
; 0x5d48 + 5 bytes

UnnamedText_5d4d: ; 0x5d4d
	TX_FAR _UnnamedText_5d4d
	db $50
; 0x5d4d + 5 bytes

INCBIN "baserom.gbc",$5d52,$3c3

OakSpeech: ; 6115
	ld a,$FF
	call $23B1 ; stop music
	ld a,2     ; bank of song
	ld c,a
	ld a,$EF    ; song #
	call $23A1  ; plays music
	call ClearScreen
	call $36A0
	call $60CA
	ld a,$18
	call Predef
	ld hl,$D53A
	ld a,$14
	ld [$CF91],a
	ld a,1
	ld [$CF96],a
	call $2BCF
	ld a,[$D07C]
	ld [$D71A],a
	call Function62CE
	xor a
	ld [$FFD7],a
	ld a,[$D732]
	bit 1,a ; XXX when is bit 1 set?
	jp nz,Function61BC ; easter egg: skip the intro
	ld de,$615F
	ld bc,$1300
	call IntroPredef3B   ; displays Oak pic?
	call FadeInIntroPic
	ld hl,OakSpeechText1
	call PrintText      ; prints text box
	call GBFadeOut2
	call ClearScreen
	ld a,NIDORINO
	ld [$D0B5],a    ; pic displayed is stored at this location
	ld [$CF91],a
	call $1537      ; this is also related to the pic
	ld hl,$C3F6     ; position on tilemap the pic is displayed
	call $1384      ; displays pic?
	call MovePicLeft
	ld hl,OakSpeechText2
	call PrintText      ; Prints text box
	call GBFadeOut2
	call ClearScreen
	ld de,$6EDE
	ld bc,$0400     ; affects the position of the player pic
	call IntroPredef3B      ; displays player pic?
	call MovePicLeft
	ld hl,IntroducePlayerText
	call PrintText
	call $695D ; brings up NewName/Red/etc menu
	call GBFadeOut2
	call ClearScreen
	ld de,$6049
	ld bc,$1300
	call IntroPredef3B ; displays rival pic
	call FadeInIntroPic
	ld hl,IntroduceRivalText
	call PrintText
	call $69A4
Function61BC: ; 0x61bc
	call GBFadeOut2
	call ClearScreen
	ld de,$6EDE
	ld bc,$0400
	call IntroPredef3B
	call GBFadeIn2
	ld a,[$D72D]
	and a
	jr nz,.next\@
	ld hl,OakSpeechText3
	call PrintText
.next\@	ld a,[$FFB8]
	push af
	ld a,$9C
	call $23B1
	pop af
	ld [$FFB8],a
	ld [$2000],a
	ld c,4
	call DelayFrames
	ld de,$4180
	ld hl,$8000
	ld bc,$050C
	call $1848
	ld de,$6FE8
	ld bc,$0400
	call IntroPredef3B
	ld c,4
	call DelayFrames
	ld de,$7042
	ld bc,$0400
	call IntroPredef3B
	call $28A6
	ld a,[$FFB8]
	push af
	ld a,2
	ld [$C0EF],a
	ld [$C0F0],a
	ld a,$A
	ld [$CFC7],a
	ld a,$FF
	ld [$C0EE],a
	call $23B1 ; stop music
	pop af
	ld [$FFB8],a
	ld [$2000],a
	ld c,$14
	call DelayFrames
	ld hl,$C40A
	ld b,7
	ld c,7
	call $18C4
	call $36A0
	ld a,1
	ld [$CFCB],a
	ld c,$32
	call DelayFrames
	call GBFadeOut2
	jp ClearScreen
OakSpeechText1: ; 0x6253
	TX_FAR _OakSpeechText1
	db "@"
OakSpeechText2: ; 0x6258
	TX_FAR _OakSpeechText2A
	db $14
	TX_FAR _OakSpeechText2B
	db "@"
IntroducePlayerText: ; 0x6262
	TX_FAR _IntroducePlayerText
	db "@"
IntroduceRivalText: ; 0x6267
	TX_FAR _IntroduceRivalText
	db "@"
OakSpeechText3: ; 0x626c
	TX_FAR _OakSpeechText3
	db "@"

FadeInIntroPic: ; 0x6271
	ld hl,IntroFadePalettes
	ld b,6
.next\@
	ld a,[hli]
	ld [rBGP],a
	ld c,10
	call DelayFrames
	dec b
	jr nz,.next\@
	ret

IntroFadePalettes: ; 0x6282
	db %01010100
	db %10101000
	db %11111100
	db %11111000
	db %11110100
	db %11100100

MovePicLeft: ; 0x6288
	ld a,119
	ld [$FF4B],a
	call DelayFrame

	ld a,$E4
	ld [rBGP],a
.next\@
	call DelayFrame
	ld a,[$FF4B]
	sub 8
	cp $FF
	ret z
	ld [$FF4B],a
	jr .next\@

Predef3B: ; 62A1
	call $3E94
IntroPredef3B: ; 62A4
	push bc
	ld a,b
	call $36EB
	ld hl,$A188
	ld de,$A000
	ld bc,$0310
	call CopyData
	ld de,$9000
	call $16EA
	pop bc
	ld a,c
	and a
	ld hl,$C3C3
	jr nz,.next\@
	ld hl,$C3F6
.next\@
	xor a
	ld [$FFE1],a
	ld a,1
	jp $3E6D

Function62CE: ; 62CE XXX called by 4B2 948 989 5BF9 5D15
	call $62FF
	ld a,$19
	call $3E6D
	ld hl,$D732
	bit 2,[hl]
	res 2,[hl]
	jr z,.next\@
	ld a,[$D71A]
	jr .next2\@
.next\@
	bit 1,[hl]
	jr z,.next3\@
	call $64EA
.next3\@
	ld a,0
.next2\@
	ld b,a
	ld a,[$D72D]
	and a
	jr nz,.next4\@
	ld a,b
.next4\@
	ld hl,$D732
	bit 4,[hl]
	ret nz
	ld [$D365],a
	ret

INCBIN "baserom.gbc",$62FF,$6420-$62FF

FirstMapSpec: ; 0x6420
	db REDS_HOUSE_2F ; RedsHouse2F
; Original Format:
;   [Event Displacement][Y-block][X-block][Y-sub_block][X-sub_block]
; Macro Format:
;   FLYWARP_DATA [Map Width][Y-pos][X-pos]
	FLYWARP_DATA 4,6,3
	db $04 ;Tileset_id

INCBIN "baserom.gbc",$6428,$6448-$6428

FlyWarpDataPtr: ; 0x6448
	db $00,0
	dw Map00FlyWarp
	db $01,0
	dw Map01FlyWarp
	db $02,0
	dw Map02FlyWarp
	db $03,0
	dw Map03FlyWarp
	db $04,0
	dw Map04FlyWarp
	db $05,0
	dw Map05FlyWarp
	db $06,0
	dw Map06FlyWarp
	db $07,0
	dw Map07FlyWarp
	db $08,0
	dw Map08FlyWarp
	db $09,0
	dw Map09FlyWarp
	db $0A,0
	dw Map0aFlyWarp
	db $0F,0
	dw Map0fFlyWarp
	db $15,0
	dw Map15FlyWarp

; Original Format:
;   [Event Displacement][Y-block][X-block][Y-sub_block][X-sub_block]
; Macro Format:
;   FLYWARP_DATA [Map Width][Y-pos][X-pos]
Map00FlyWarp: ; 0x647c
	FLYWARP_DATA 10,6,5
Map01FlyWarp: ; 0x6482
	FLYWARP_DATA 20,26,23
Map02FlyWarp: ; 0x6488
	FLYWARP_DATA 20,26,13
Map03FlyWarp: ; 0x648e
	FLYWARP_DATA 20,18,19
Map04FlyWarp: ; 0x6494
	FLYWARP_DATA 10,6,3
Map05FlyWarp: ; 0x649a
	FLYWARP_DATA 20,4,11
Map06FlyWarp: ; 0x64a0
	FLYWARP_DATA 25,10,41
Map07FlyWarp: ; 0x64a6
	FLYWARP_DATA 20,28,19
Map08FlyWarp: ; 0x64ac
	FLYWARP_DATA 10,12,11
Map09FlyWarp: ; 0x64b2
	FLYWARP_DATA 10,6,9
Map0aFlyWarp: ; 0x64b8
	FLYWARP_DATA 20,30,9
Map0fFlyWarp: ; 0x64be
	FLYWARP_DATA 45,6,11
Map15FlyWarp: ; 0x64c4
	FLYWARP_DATA 10,20,11

INCBIN "baserom.gbc",$64ca,$6557 - $64ca

UnnamedText_6557: ; 0x6557
	TX_FAR _UnnamedText_6557
	db $50
; 0x6557 + 5 bytes

INCBIN "baserom.gbc",$655c,$699f - $655c

UnnamedText_699f: ; 0x699f
	TX_FAR _UnnamedText_699f
	db $50
; 0x699f + 5 bytes

; 0x69a4
	call Unnamed_6a12 ; 0x69a4 call 0x6a12
	ld de, DefaultNamesRival
; 0x69aa

INCBIN "baserom.gbc",$69AA,$69B3 - $69AA

ld hl, DefaultNamesRivalList

INCBIN "baserom.gbc",$69b6,$69e7 - $69b6

UnnamedText_69e7: ; 0x69e7
	TX_FAR _UnnamedText_69e7
	db $50
; 0x69e7 + 5 bytes

INCBIN "baserom.gbc",$69ec,$6a12 - $69ec

Unnamed_6a12: ; 0x6a12
INCBIN "baserom.gbc",$6a12,$6aa8 - $6a12

IF _RED
DefaultNamesPlayer: ; 0x6aa8 22
	db "NEW NAME",$4E,"RED",$4E,"ASH",$4E,"JACK@"
DefaultNamesRival: ; 0x6abe 24
	db "NEW NAME",$4E,"BLUE",$4E,"GARY",$4E,"JOHN@"
ENDC
IF _BLUE
DefaultNamesPlayer:
	db "NEW NAME",$4E,"BLUE",$4E,"GARY",$4E,"JOHN@"
DefaultNamesRival:
	db "NEW NAME",$4E,"RED",$4E,"ASH",$4E,"JACK@"
ENDC

INCBIN "baserom.gbc",$6AD6,$6AF2 - $6AD6

IF _RED
DefaultNamesPlayerList: ; 0x6AF2 22
	db "NEW NAME@RED@ASH@JACK@"
DefaultNamesRivalList: ; 0x6b08 25
	db "NEW NAME@BLUE@GARY@JOHN@@"
ENDC
IF _BLUE
DefaultNamesPlayerList:
	db "NEW NAME@BLUE@GARY@JOHN@"
DefaultNamesRivalList:
	db "NEW NAME@RED@ASH@JACK@@"
ENDC

INCBIN "baserom.gbc",$6b21,$6e0c - $6b21

UnnamedText_6e0c: ; 0x6e0c
	TX_FAR _UnnamedText_6e0c
	db $50
; 0x6e0c + 5 bytes

UnnamedText_6e11: ; 0x6e11
	TX_FAR _UnnamedText_6e11
	db $50
; 0x6e11 + 5 bytes

UnnamedText_6e16: ; 0x6e16
	TX_FAR _UnnamedText_6e16
	db $50
; 0x6e16 + 5 bytes

UnnamedText_6e1b: ; 0x6e1b
	TX_FAR _UnnamedText_6e1b
	db $50
; 0x6e1b + 5 bytes

UnnamedText_6e20: ; 0x6e20
	TX_FAR _UnnamedText_6e20
	db $50
; 0x6e20 + 5 bytes

UnnamedText_6e25: ; 0x6e25
	TX_FAR _UnnamedText_6e25
	db $50
; 0x6e25 + 5 bytes

UnnamedText_6e2a: ; 0x6e2a
	TX_FAR _UnnamedText_6e2a
	db $50
; 0x6e2a + 5 bytes

UnnamedText_6e2f: ; 0x6e2f
	TX_FAR _UnnamedText_6e2f
	db $50
; 0x6e2f + 5 bytes

UnnamedText_6e34: ; 0x6e34
	TX_FAR _UnnamedText_6e34
	db $50
; 0x6e34 + 5 bytes

UnnamedText_6e39: ; 0x6e39
	TX_FAR _UnnamedText_6e39
	db $50
; 0x6e39 + 5 bytes

UnnamedText_6e3e: ; 0x6e3e
	TX_FAR _UnnamedText_6e3e
	db $50
; 0x6e3e + 5 bytes

INCBIN "baserom.gbc",$6e43,$6fb4 - $6e43

UnnamedText_6fb4: ; 0x6fb4
	TX_FAR _UnnamedText_6fb4
	db $50
; 0x6fb4 + 5 bytes

UnnamedText_6fb9: ; 0x6fb9
	TX_FAR _UnnamedText_6fb9
	db $50
; 0x6fb9 + 5 bytes

UnnamedText_6fbe: ; 0x6fbe
	TX_FAR _UnnamedText_6fbe
	db $50
; 0x6fbe + 5 bytes

UnnamedText_6fc3: ; 0x6fc3
	TX_FAR _UnnamedText_6fc3
	db $50
; 0x6fc3 + 5 bytes

UnnamedText_6fc8: ; 0x6fc8
	TX_FAR _UnnamedText_6fc8 ; 0xa2819
	db $a
	db $8
	ld a, $ae
	call $3740
	ld hl, $6fd7
	ret
; 0x6fd7

UnnamedText_6fd7: ; 0x6fd7
	TX_FAR _UnnamedText_6fd7 ; 0xa2827
	db $a ; 0x6fdb
UnnamedText_6fdc: ; 0x6fdc
	TX_FAR _UnnamedText_6fdc
	db $50
; 0x6fe1

UnnamedText_6fe1: ; 0x6fe1
	TX_FAR _UnnamedText_6fe1
	db $50
; 0x6fe1 + 5 bytes

Unnamed_6fe6: ; 0x6fe6
	call $3719
	ld hl, $705d
	call PrintText
	ld hl, $d72e
	bit 2, [hl]
	set 1, [hl]
	set 2, [hl]
	jr nz, .asm_7000 ; 0x6ff8 $6
	ld hl, $7062
	call PrintText
.asm_7000
	call $360a
	ld a, [$cc26]
	and a
	jr nz, .asm_7051 ; 0x7007 $48
	call $7078
	call $3725
	ld hl, $7068
	call PrintText
	ld a, $18
	ld [$c112], a
	call Delay3
	ld a, $7
	call Predef
	ld b, $1c
	ld hl, $4433
	call Bankswitch
	xor a
	ld [$cfc7], a
	ld a, [$c0f0]
	ld [$c0ef], a
	ld a, [$d35b]
	ld [$cfca], a
	ld [$c0ee], a
	call $23b1
	ld hl, $706d
	call PrintText
	ld a, $14
	ld [$c112], a
	ld c, a
	call DelayFrames
	jr .asm_7054 ; 0x704f $3
.asm_7051
	call $3725
.asm_7054
	ld hl, $7072
	call PrintText
	jp $2429
; 0x705d

UnnamedText_705d: ; 0x705d
	TX_FAR _UnnamedText_705d
	db $50
; 0x705d + 5 bytes

; 0x7062
db $a

UnnamedText_7063: ; 0x7063
	TX_FAR _UnnamedText_7063
	db $50
; 0x7063 + 5 bytes

UnnamedText_7068: ; 0x7068
	TX_FAR _UnnamedText_7068
	db $50
; 0x7068 + 5 bytes

UnnamedText_706d: ; 0x706d
	TX_FAR _UnnamedText_706d
	db $50
; 0x706d + 5 bytes

db $a

UnnamedText_7073: ; 0x7073
	TX_FAR _UnnamedText_7073
	db $50
; 0x7078

Unknown_7078: ; 0x7078
	push hl
	ld hl, $7092
	ld a, [$d35e]
	ld b, a
.asm_7080
	ld a, [hli]
	cp $ff
	jr z, .asm_708a ; 0x7083 $5
	cp b
	jr nz, .asm_7080 ; 0x7086 $f8
	jr .asm_7090 ; 0x7088 $6
.asm_708a
	ld a, [$d365]
	ld [$d719], a
.asm_7090
	pop hl
	ret
; 0x7092

Unknown_7092: ; 0x7092
INCBIN "baserom.gbc",$7092,4

; function that performs initialization for DisplayTextID
DisplayTextIDInit: ; 7096
	xor a
	ld [$cf94],a
	ld a,[$cf0c]
	bit 0,a
	jr nz,.skipDrawingTextBoxBorder\@
	ld a,[$ff8c] ; text ID (or sprite ID)
	and a
	jr nz,.notStartMenu\@
; if text ID is 0 (i.e. the start menu)
; Note that the start menu text border is also drawn in the function directly
; below this, so this seems unnecessary.
	ld a,[$d74b]
	bit 5,a ; does the player have the pokedex?
; start menu with pokedex
	ld hl,$c3aa
	ld b,$0e
	ld c,$08
	jr nz,.drawTextBoxBorder\@
; start menu without pokedex
	ld hl,$c3aa
	ld b,$0c
	ld c,$08
	jr .drawTextBoxBorder\@
; if text ID is not 0 (i.e. not the start menu) then do a standard dialogue text box
.notStartMenu\@
	ld hl,$c490
	ld b,$04
	ld c,$12
.drawTextBoxBorder\@
	call TextBoxBorder
.skipDrawingTextBoxBorder\@
	ld hl,$cfc4
	set 0,[hl]
	ld hl,$cd60
	bit 4,[hl]
	res 4,[hl]
	jr nz,.skipMovingSprites\@
	call $2429 ; move sprites
.skipMovingSprites\@
; loop to copy C1X9 (direction the sprite is facing) to C2X9 for each sprite
; this is done because when you talk to an NPC, they turn to look your way
; the original direction they were facing must be restored after the dialogue is over
	ld hl,$c119
	ld c,$0f
	ld de,$0010
.spriteFacingDirectionCopyLoop\@
	ld a,[hl]
	inc h
	ld [hl],a
	dec h
	add hl,de
	dec c
	jr nz,.spriteFacingDirectionCopyLoop\@
; loop to force all the sprites in the middle of animation to stand still
; (so that they don't like they're frozen mid-step during the dialogue)
	ld hl,$c102
	ld de,$0010
	ld c,e
.spriteStandStillLoop\@
	ld a,[hl]
	cp a,$ff ; is the sprite visible?
	jr z,.nextSprite\@
; if it is visible
	and a,$fc
	ld [hl],a
.nextSprite\@
	add hl,de
	dec c
	jr nz,.spriteStandStillLoop\@
	ld b,$9c ; window background address
	call $18d6 ; transfer background in WRAM to VRAM
	xor a
	ld [$ffb0],a ; put the window on the screen
	call $3680 ; transfer tile pattern data for text into VRAM
	ld a,$01
	ld [H_AUTOBGTRANSFERENABLED],a ; enable continuous WRAM to VRAM transfer each V-blank
	ret

; function that displays the start menu
DrawStartMenu: ; 710B
	ld a,[$d74b]
	bit 5,a ; does the player have the pokedex?
; menu with pokedex
	ld hl,$c3aa
	ld b,$0e
	ld c,$08
	jr nz,.drawTextBoxBorder\@
; shorter menu if the player doesn't have the pokedex
	ld hl,$c3aa
	ld b,$0c
	ld c,$08
.drawTextBoxBorder\@
	call TextBoxBorder
	ld a,%11001011 ; bit mask for down, up, start, B, and A buttons
	ld [$cc29],a
	ld a,$02
	ld [$cc24],a ; Y position of first menu choice
	ld a,$0b
	ld [$cc25],a ; X position of first menu choice
	ld a,[$cc2d] ; remembered menu selection from last time
	ld [$cc26],a
	ld [$cc2a],a
	xor a
	ld [$cc37],a
	ld hl,$d730
	set 6,[hl] ; no pauses between printing each letter
	ld hl,$c3d4
	ld a,[$d74b]
	bit 5,a ; does the player have the pokedex?
; case for not having pokdex
	ld a,$06
	jr z,.storeMenuItemCount\@
; case for having pokedex
	ld de,StartMenuPokedexText
	call PrintStartMenuItem
	ld a,$07
.storeMenuItemCount\@
	ld [$cc28],a ; number of menu items
	ld de,StartMenuPokemonText
	call PrintStartMenuItem
	ld de,StartMenuItemText
	call PrintStartMenuItem
	ld de,$d158 ; player's name
	call PrintStartMenuItem
	ld a,[$d72e]
	bit 6,a ; is the player using the link feature?
; case for not using link feature
	ld de,StartMenuSaveText
	jr z,.printSaveOrResetText\@
; case for using link feature
	ld de,StartMenuResetText
.printSaveOrResetText\@
	call PrintStartMenuItem
	ld de,StartMenuOptionText
	call PrintStartMenuItem
	ld de,StartMenuExitText
	call PlaceString
	ld hl,$d730
	res 6,[hl] ; turn pauses between printing letters back on
	ret

StartMenuPokedexText: ; 718F
db "POKéDEX@"

StartMenuPokemonText: ; 7197
db "POKéMON@"

StartMenuItemText: ; 719F
db "ITEM@"

StartMenuSaveText: ; 71A4
db "SAVE@"

StartMenuResetText: ; 71A9
db "RESET@"

StartMenuExitText: ; 71AF
db "EXIT@"

StartMenuOptionText: ; 71B4
db "OPTION@"

PrintStartMenuItem: ; 71BB
	push hl
	call PlaceString
	pop hl
	ld de,$28
	add hl,de
	ret

Unknown_71c5: ; 0x71c5
	ld hl, $72b8
	call PrintText
	ld a, [$d74b]
	bit 5, a
	jp nz, $71e1
	ld c, $3c
	call DelayFrames
	ld hl, $72d2
	call PrintText
	jp $7298
; 0x71e1

Unknown_71e1: ; 0x71e1
	ld a, $1
	ld [$cc34], a
	ld a, $5a
	ld [$cc47], a
.asm_71eb
	ld a, [$ff00+$aa]
	cp $2
	jr z, .asm_721a ; 0x71ef $29
	cp $1
	jr z, .asm_721a ; 0x71f3 $25
	ld a, $ff
	ld [$ff00+$aa], a
	ld a, $2
	ld [$ff00+$1], a
	xor a
	ld [$ff00+$ad], a
	ld a, $80
	ld [$ff00+$2], a
	ld a, [$cc47]
	dec a
	ld [$cc47], a
	jr z, .asm_7287 ; 0x720b $7a
	ld a, $1
	ld [$ff00+$1], a
	ld a, $81
	ld [$ff00+$2], a
	call DelayFrame
	jr .asm_71eb ; 0x7218 $d1
.asm_721a
	call $22ed
	call DelayFrame
	call $22ed
	ld c, $32
	call DelayFrames
	ld hl, $72bd
	call PrintText
	xor a
	ld [$cc34], a
	call $35ec
	ld a, $1
	ld [$cc34], a
	ld a, [$cc26]
	and a
	jr nz, .asm_728f ; 0x723e $4f
	ld hl, $7848
	ld b, $1c
	call Bankswitch
	call $3748
	ld a, $b6
	call $3740
	ld hl, $72c2
	call PrintText
	ld hl, $cc47
	ld a, $3
	ld [hli], a
	xor a
	ld [hl], a
	ld [$ff00+$a9], a
	ld [$cc42], a
	call $227f
	ld hl, $cc47
	ld a, [hli]
	inc a
	jr nz, .asm_72a8 ; 0x726b $3b
	ld a, [hl]
	inc a
	jr nz, .asm_72a8 ; 0x726f $37
	ld b, $a
.asm_7273
	call DelayFrame
	call $22ed
	dec b
	jr nz, .asm_7273 ; 0x727a $f7
	call $72d7
	ld hl, $72c8
	call PrintText
	jr .asm_7298 ; 0x7285 $11
.asm_7287
	ld hl, $72b3
	call PrintText
	jr .asm_7298 ; 0x728d $9
.asm_728f
	call $72d7
	ld hl, $72cd
	call PrintText
.asm_7298
	xor a
	ld hl, $cc47
	ld [hli], a
	ld [hl], a
	ld hl, $d72e
	res 6, [hl]
	xor a
	ld [$cc34], a
	ret
.asm_72a8
	xor a
	ld [hld], a
	ld [hl], a
	ld hl, $5c0a
	ld b, $1
	jp Bankswitch
; 0x72b3

UnnamedText_72b3: ; 0x72b3
	TX_FAR _UnnamedText_72b3
	db $50
; 0x72b3 + 5 bytes

UnnamedText_72b8: ; 0x72b8
	TX_FAR _UnnamedText_72b8
	db $50
; 0x72b8 + 5 bytes

UnnamedText_72bd: ; 0x72bd
	TX_FAR _UnnamedText_72bd
	db $50
; 0x72bd + 5 bytes

UnnamedText_72c2: ; 0x72c2
	TX_FAR UnnamedText_a29cc
	db $a, $50

UnnamedText_72c8: ; 0x72c8
	TX_FAR _UnnamedText_72c8
	db $50
; 0x72c8 + 5 bytes

UnnamedText_72cd: ; 0x72cd
	TX_FAR _UnnamedText_72cd
	db $50
; 0x72cd + 5 bytes

UnnamedText_72d2: ; 0x72d2
	TX_FAR _UnnamedText_72d2
	db $50
; 0x72d2 + 5 bytes

INCBIN "baserom.gbc",$72d7,$4b6

FieldMoveNames: ; 778D
	db "CUT@"
	db "FLY@"
	db "@"
	db "SURF@"
	db "STRENGTH@"
	db "FLASH@"
	db "DIG@"
	db "TELEPORT@"
	db "SOFTBOILED@"

PokemonMenuEntries: ; 77C2
	db "STATS",$4E
	db "SWITCH",$4E
	db "CANCEL@"

INCBIN "baserom.gbc",$77d6,$78dc - $77d6

UnnamedText_78dc: ; 0x78dc
	TX_FAR _UnnamedText_78dc
	db $50
; 0x78dc + 5 bytes

UnnamedText_78e1: ; 0x78e1
	TX_FAR _UnnamedText_78e1
	db $50
; 0x78e1 + 5 bytes

INCBIN "baserom.gbc",$78e6,$20f

PlayersPCMenuEntries: ; 7AF5
	db "WITHDRAW ITEM",$4E
	db "DEPOSIT ITEM",$4E
	db "TOSS ITEM",$4E
	db "LOG OFF@"

UnnamedText_7b22: ; 0x7b22
	TX_FAR _UnnamedText_7b22
	db $50
; 0x7b22 + 5 bytes

UnnamedText_7b27: ; 0x7b27
	TX_FAR _UnnamedText_7b27
	db $50
; 0x7b27 + 5 bytes

UnnamedText_7b2c: ; 0x7b2c
	TX_FAR _UnnamedText_7b2c
	db $50
; 0x7b2c + 5 bytes

UnnamedText_7b31: ; 0x7b31
	TX_FAR _UnnamedText_7b31
	db $50
; 0x7b31 + 5 bytes

UnnamedText_7b36: ; 0x7b36
	TX_FAR _UnnamedText_7b36
	db $50
; 0x7b36 + 5 bytes

UnnamedText_7b3b: ; 0x7b3b
	TX_FAR _UnnamedText_7b3b
	db $50
; 0x7b3b + 5 bytes

UnnamedText_7b40: ; 0x7b40
	TX_FAR _UnnamedText_7b40
	db $50
; 0x7b40 + 5 bytes

UnnamedText_7b45: ; 0x7b45
	TX_FAR _UnnamedText_7b45
	db $50
; 0x7b45 + 5 bytes

UnnamedText_7b4a: ; 0x7b4a
	TX_FAR _UnnamedText_7b4a
	db $50
; 0x7b4a + 5 bytes

UnnamedText_7b4f: ; 0x7b4f
	TX_FAR _UnnamedText_7b4f
	db $50
; 0x7b4f + 5 bytes

UnnamedText_7b54: ; 0x7b54
	TX_FAR _UnnamedText_7b54
	db $50
; 0x7b54 + 5 bytes

UnnamedText_7b59: ; 0x7b59
	TX_FAR _UnnamedText_7b59
	db $50
; 0x7b59 + 5 bytes

UnnamedText_7b5e: ; 0x7b5e
	TX_FAR _UnnamedText_7b5e
	db $50
; 0x7b5e + 5 bytes

UnnamedText_7b63: ; 0x7b63
	TX_FAR _UnnamedText_7b63
	db $50
; 0x7b63 + 5 bytes

INCBIN "baserom.gbc",$7b68,$e1

SECTION "bank2",DATA,BANK[$2]

INCBIN "baserom.gbc",$8000,$822E - $8000

;Music Headers
;Pallet Town
PalletTown_mh: ; 0x822E - 0x8236
	db $80
	dw PalletTown_md_1 ;Channel 1 ($A7C5 - $A85E)
	db $01
	dw PalletTown_md_2 ;Channel 2 ($A85f - $A8DD)
	db $02
	dw PalletTown_md_3 ;Channel 3 ($A8DE - $AA75)

;Pokemon Center
Pokecenter_mh: ; 0x8237 - 0x823F
	db $80
	dw Pokecenter_md_1 ;Channel 1 ($BE56 - $BEF8)
	db $01
	dw Pokecenter_md_2 ;Channel 2 ($BEF9 - $BF6F)
	db $02
	dw Pokecenter_md_3 ;Channel 3 ($BF70 - $BFFF)

;Gyms
Gym_mh: ; 0x8240 - 0x8248
	db $80
	dw Gym_md_1 ;Channel 1 ($BCBB - $BD6A)
	db $01
	dw Gym_md_2 ;Channel 2 ($BD6B - $BDF9)
	db $02
	dw Gym_md_3 ;Channel 3 ($BDFA - $BE55)

;Viridian City, Pewter City, Saffron City
Cities1_mh: ; 0x8249 - 0x8254
	db $C0
	dw Cities1_md_1 ;Channel 1
	db $01
	dw Cities1_md_2 ;Channel 2
	db $02
	dw Cities1_md_3 ;Channel 3
	db $03
	dw Cities1_md_4 ;Channel 4

;Cerulean City, Fuchsia City
Cities2_mh: ; 0x8255 - 0x825D
	db $80
	dw Cities2_md_1 ;Channel 1
	db $01
	dw Cities2_md_2 ;Channel 2
	db $02
	dw Cities2_md_3 ;Channel 3

;Celadon City
Celadon_mh: ; 0x825E - 0x8266
	db $80
	dw Celadon_md_1 ;Channel 1
	db $01
	dw Celadon_md_2 ;Channel 2
	db $02
	dw Celadon_md_3 ;Channel 3

;Cinnabar Island
Cinnabar_mh: ; 0x8267 - 0x826F
	db $80
	dw Cinnabar_md_1 ;Channel 1
	db $01
	dw Cinnabar_md_2 ;Channel 2
	db $02
	dw Cinnabar_md_3 ;Channel 3

;Vermilion City
Vermilion_mh: ; 0x8270 - 0x827B
	db $C0
	dw Vermilion_md_1 ;Channel 1
	db $01
	dw Vermilion_md_2 ;Channel 2
	db $02
	dw Vermilion_md_3 ;Channel 3
	db $03
	dw Vermilion_md_4 ;Channel 4

;Lavender Town
Lavender_mh: ; 0x827C - 0x8287
	db $C0
	dw Lavender_md_1 ;Channel 1
	db $01
	dw Lavender_md_2 ;Channel 2
	db $02
	dw Lavender_md_3 ;Channel 3
	db $03
	dw Lavender_md_4 ;Channel 4

;SS Anne
SSAnne_mh: ; 0x8288 - 0x8290
	db $80
	dw SSAnne_md_1 ;Channel 1
	db $01
	dw SSAnne_md_2 ;Channel 2
	db $02
	dw SSAnne_md_3 ;Channel 3

;Meet Prof. Oak
MeetProfOak_mh: ; 0x8291 - 0x8299
	db $80
	dw MeetProfOak_md_1 ;Channel 1
	db $01
	dw MeetProfOak_md_2 ;Channel 2
	db $02
	dw MeetProfOak_md_3 ;Channel 3

;Meet Rival
MeetRival_mh: ; 0x829A - 0x82A2
	db $80
	dw MeetRival_md_1 ;Channel 1
	db $01
	dw MeetRival_md_2 ;Channel 2
	db $02
	dw MeetRival_md_3 ;Channel 3

;Guy walks you to museum
MuseumGuy_mh: ; 0x82A3 - 0x82AE
	db $C0
	dw MuseumGuy_md_1 ;Channel 1
	db $01
	dw MuseumGuy_md_2 ;Channel 2
	db $02
	dw MuseumGuy_md_3 ;Channel 3
	db $03
	dw MuseumGuy_md_4 ;Channel 4

;Safari Zone
SafariZone_mh: ; 0x82AF - 0x82B7
	db $80
	dw SafariZone_md_1 ;Channel 1
	db $01
	dw SafariZone_md_2 ;Channel 2
	db $02
	dw SafariZone_md_3 ;Channel 3

;Pokemon Get Healed
PkmnHealed_mh: ; 0x82B8 - 0x82C0
	db $80
	dw PkmnHealed_md_1 ;Channel 1
	db $01
	dw PkmnHealed_md_2 ;Channel 2
	db $02
	dw PkmnHealed_md_3 ;Channel 3

;Routes 1 and 2
Routes1_mh: ; 0x82C1 - 0x82CC
	db $C0
	dw Routes1_md_1 ;Channel 1
	db $01
	dw Routes1_md_2 ;Channel 2
	db $02
	dw Routes1_md_3 ;Channel 3
	db $03
	dw Routes1_md_4 ;Channel 4

;Routes 24 and 25
Routes2_mh: ; 0x82CD - 0x82D8
	db $C0
	dw Routes2_md_1 ;Channel 1
	db $01
	dw Routes2_md_2 ;Channel 2
	db $02
	dw Routes2_md_3 ;Channel 3
	db $03
	dw Routes2_md_4 ;Channel 4

;Routes 3, 4, 5, 6, 7, 8, 9, 10, 16, 17, 18, 19, 20, 21, 22
Routes3_mh: ; 0x82D9 - 0x82E4
	db $C0
	dw Routes3_md_1 ;Channel 1
	db $01
	dw Routes3_md_2 ;Channel 2
	db $02
	dw Routes3_md_3 ;Channel 3
	db $03
	dw Routes3_md_4 ;Channel 4

;Routes 11, 12, 13, 14, 15
Routes4_mh: ; 0x82E5 - 0x82F0
	db $C0
	dw Routes4_md_1 ;Channel 1
	db $01
	dw Routes4_md_2 ;Channel 2
	db $02
	dw Routes4_md_3 ;Channel 3
	db $03
	dw Routes4_md_4 ;Channel 4

;Indigo Plateau
IndigoPlateau_mh: ; 0x82F1 - 0x82FC
	db $C0
	dw IndigoPlateau_md_1 ;Channel 1
	db $01
	dw IndigoPlateau_md_2 ;Channel 2
	db $02
	dw IndigoPlateau_md_3 ;Channel 3
	db $03
	dw IndigoPlateau_md_4 ;Channel 4

INCLUDE "music.asm"
	
SECTION "bank3",DATA,BANK[$3]

INCBIN "baserom.gbc",$C000,$C23D - $C000

; see also MapHeaderPointers
MapHeaderBanks: ; 423D
	db BANK(PalletTown_h) ;PALLET_TOWN
	db BANK(ViridianCity_h) ; VIRIDIAN_CITY
	db BANK(PewterCity_h) ; PEWTER_CITY
	db BANK(CeruleanCity_h) ; CERULEAN_CITY
	db BANK(LavenderTown_h) ; LAVENDER_TOWN
	db BANK(VermilionCity_h) ; VERMILION_CITY
	db BANK(CeladonCity_h) ; CELADON_CITY
	db BANK(FuchsiaCity_h) ; FUCHSIA_CITY
	db BANK(CinnabarIsland_h) ; CINNABAR_ISLAND
	db BANK(IndigoPlateau_h) ; INDIGO_PLATEAU
	db BANK(SaffronCity_h) ; SAFFRON_CITY
	db $1 ; unused
	db BANK(Route1_h) ; ROUTE_1
	db BANK(Route2_h) ; ROUTE_2
	db BANK(Route3_h) ; ROUTE_3
	db BANK(Route4_h) ; ROUTE_4
	db BANK(Route5_h) ; ROUTE_5
	db BANK(Route6_h) ; ROUTE_6
	db BANK(Route7_h) ; ROUTE_7
	db BANK(Route8_h) ; ROUTE_8
	db BANK(Route9_h) ; ROUTE_9
	db BANK(Route10_h) ; ROUTE_10
	db BANK(Route11_h) ; ROUTE_11
	db BANK(Route12_h) ; ROUTE_12
	db BANK(Route13_h) ; ROUTE_13
	db BANK(Route14_h) ; ROUTE_14
	db BANK(Route15_h) ; ROUTE_15
	db BANK(Route16_h) ; ROUTE_16
	db BANK(Route17_h) ; ROUTE_17
	db BANK(Route18_h) ; ROUTE_18
	db BANK(Route19_h) ; ROUTE_19
	db BANK(Route20_h) ; ROUTE_20
	db BANK(Route21_h) ; ROUTE_21
	db BANK(Route22_h) ; ROUTE_22
	db BANK(Route23_h) ; ROUTE_23
	db BANK(Route24_h) ; ROUTE_24
	db BANK(Route25_h) ; ROUTE_25
	db BANK(RedsHouse1F_h)
	db BANK(RedsHouse2F_h)
	db BANK(BluesHouse_h)
	db BANK(OaksLab_h)
	db BANK(ViridianPokecenter_h)
	db BANK(ViridianMart_h)
	db BANK(School_h)
	db BANK(ViridianHouse_h)
	db BANK(ViridianGym_h)
	db BANK(DiglettsCaveRoute2_h)
	db BANK(ViridianForestexit_h)
	db BANK(Route2House_h)
	db BANK(Route2Gate_h)
	db BANK(ViridianForestEntrance_h)
	db BANK(ViridianForest_h)
	db BANK(MuseumF1_h)
	db BANK(MuseumF2_h)
	db BANK(PewterGym_h)
	db BANK(PewterHouse1_h)
	db BANK(PewterMart_h)
	db BANK(PewterHouse2_h)
	db BANK(PewterPokecenter_h)
	db BANK(MtMoon1_h)
	db BANK(MtMoon2_h)
	db BANK(MtMoon3_h)
	db BANK(CeruleanHouseTrashed_h)
	db BANK(CeruleanHouse2_h)
	db BANK(CeruleanPokecenter_h)
	db BANK(CeruleanGym_h)
	db BANK(BikeShop_h)
	db BANK(CeruleanMart_h)
	db BANK(MtMoonPokecenter_h)
	db BANK(CeruleanHouseTrashed_h)
	db BANK(Route5Gate_h)
	db BANK(UndergroundTunnelEntranceRoute5_h)
	db BANK(DayCareM_h)
	db BANK(Route6Gate_h)
	db BANK(UndergroundTunnelEntranceRoute6_h)
	db $17 ;FREEZE
	db BANK(Route7Gate_h)
	db BANK(UndergroundPathEntranceRoute7_h)
	db $17 ;FREEZE
	db BANK(Route8Gate_h)
	db BANK(UndergroundPathEntranceRoute8_h)
	db BANK(RockTunnelPokecenter_h)
	db BANK(RockTunnel1_h)
	db BANK(PowerPlant_h)
	db BANK(Route11Gate_h)
	db BANK(DiglettsCaveEntranceRoute11_h)
	db BANK(Route11GateUpstairs_h)
	db BANK(Route12Gate_h)
	db BANK(BillsHouse_h)
	db BANK(VermilionPokecenter_h)
	db BANK(FanClub_h)
	db BANK(VermilionMart_h)
	db BANK(VermilionGym_h)
	db BANK(VermilionHouse1_h)
	db BANK(VermilionDock_h)
	db BANK(SSAnne1_h)
	db BANK(SSAnne2_h)
	db BANK(SSAnne3_h)
	db BANK(SSAnne4_h)
	db BANK(SSAnne5_h)
	db BANK(SSAnne6_h)
	db BANK(SSAnne7_h)
	db BANK(SSAnne8_h)
	db BANK(SSAnne9_h)
	db BANK(SSAnne10_h)
	db $1D ;unused
	db $1D ;unused
	db $1D ;unused
	db BANK(VictoryRoad1_h)
	db $1D ;unused
	db $1D ;unused
	db $1D ;unused
	db $1D ;unused
	db BANK(Lance_h)
	db $1D ;unused
	db $1D ;unused
	db $1D ;unused
	db $1D ;unused
	db BANK(HallofFameRoom_h)
	db BANK(UndergroundPathNS_h)
	db BANK(Gary_h)
	db BANK(UndergroundPathWE_h)
	db BANK(CeladonMart1_h)
	db BANK(CeladonMart2_h)
	db BANK(CeladonMart3_h)
	db BANK(CeladonMart4_h)
	db BANK(CeladonMartRoof_h)
	db BANK(CeladonMartElevator_h)
	db BANK(CeladonMansion1_h)
	db BANK(CeladonMansion2_h)
	db BANK(CeladonMansion3_h)
	db BANK(CeladonMansion4_h)
	db BANK(CeladonMansion5_h)
	db BANK(CeladonPokecenter_h)
	db BANK(CeladonGym_h)
	db BANK(CeladonGameCorner_h)
	db BANK(CeladonMart5_h)
	db BANK(CeladonPrizeRoom_h)
	db BANK(CeladonDiner_h)
	db BANK(CeladonHouse_h)
	db BANK(CeladonHotel_h)
	db BANK(LavenderPokecenter_h)
	db BANK(PokemonTower1_h)
	db BANK(PokemonTower2_h)
	db BANK(PokemonTower3_h)
	db BANK(PokemonTower4_h)
	db BANK(PokemonTower5_h)
	db BANK(PokemonTower6_h)
	db BANK(PokemonTower7_h)
	db BANK(LavenderHouse1_h)
	db BANK(LavenderMart_h)
	db BANK(LavenderHouse2_h)
	db BANK(FuchsiaMart_h)
	db BANK(FuchsiaHouse1_h)
	db BANK(FuchsiaPokecenter_h)
	db BANK(FuchsiaHouse2_h)
	db BANK(SafariZoneEntrance_h)
	db BANK(FuchsiaGym_h)
	db BANK(FuchsiaMeetingRoom_h)
	db BANK(SeafoamIslands2_h)
	db BANK(SeafoamIslands3_h)
	db BANK(SeafoamIslands4_h)
	db BANK(SeafoamIslands5_h)
	db BANK(VermilionHouse2_h)
	db BANK(FuchsiaHouse3_h)
	db BANK(Mansion1_h)
	db BANK(CinnabarGym_h)
	db BANK(Lab1_h)
	db BANK(Lab2_h)
	db BANK(Lab3_h)
	db BANK(Lab4_h)
	db BANK(CinnabarPokecenter_h)
	db BANK(CinnabarMart_h)
	db $1D
	db BANK(IndigoPlateauLobby_h)
	db BANK(CopycatsHouseF1_h)
	db BANK(CopycatsHouseF2_h)
	db BANK(FightingDojo_h)
	db BANK(SaffronGym_h)
	db BANK(SaffronHouse1_h)
	db BANK(SaffronMart_h)
	db BANK(SilphCo1_h)
	db BANK(SaffronPokecenter_h)
	db BANK(SaffronHouse2_h)
	db BANK(Route15Gate_h)
	db $12
	db BANK(Route16GateMap_h)
	db BANK(Route16GateUpstairs_h)
	db BANK(Route16House_h)
	db BANK(Route12House_h)
	db BANK(Route18Gate_h)
	db BANK(Route18GateHeader_h)
	db BANK(SeafoamIslands1_h)
	db BANK(Route22Gate_h)
	db BANK(VictoryRoad2_h)
	db BANK(Route12GateUpstairs_h)
	db BANK(VermilionHouse3_h)
	db BANK(DiglettsCave_h)
	db BANK(VictoryRoad3_h)
	db BANK(RocketHideout1_h)
	db BANK(RocketHideout2_h)
	db BANK(RocketHideout3_h)
	db BANK(RocketHideout4_h)
	db BANK(RocketHideoutElevator_h)
	db $01
	db $01
	db $01
	db BANK(SilphCo2_h)
	db BANK(SilphCo3_h)
	db BANK(SilphCo4_h)
	db BANK(SilphCo5_h)
	db BANK(SilphCo6_h)
	db BANK(SilphCo7_h)
	db BANK(SilphCo8_h)
	db BANK(Mansion2_h)
	db BANK(Mansion3_h)
	db BANK(Mansion4_h)
	db BANK(SafariZoneEast_h)
	db BANK(SafariZoneNorth_h)
	db BANK(SafariZoneWest_h)
	db BANK(SafariZoneCenter_h)
	db BANK(SafariZoneRestHouse1_h)
	db BANK(SafariZoneSecretHouse_h)
	db BANK(SafariZoneRestHouse2_h)
	db BANK(SafariZoneRestHouse3_h)
	db BANK(SafariZoneRestHouse4_h)
	db BANK(UnknownDungeon2_h)
	db BANK(UnknownDungeon3_h)
	db BANK(UnknownDungeon1_h)
	db BANK(NameRater_h)
	db BANK(CeruleanHouse3_h)
	db $01
	db BANK(RockTunnel2_h)
	db BANK(SilphCo9_h)
	db BANK(SilphCo10_h)
	db BANK(SilphCo11_h)
	db BANK(SilphCoElevator_h)
	db $11
	db $11
	db BANK(BattleCenterM_h)
	db BANK(TradeCenterM_h)
	db $11
	db $11
	db $11
	db $11
	db BANK(Lorelei_h)
	db BANK(Bruno_h)
	db BANK(Agatha_h)

INCBIN "baserom.gbc",$C335,$C766-$C335
	ld hl, TilesetsHeadPtr

INCBIN "baserom.gbc",$C769,$C7BE-$C769

TilesetsHeadPtr: ; 0xC7BE
	TSETHEAD Tset00_Block,Tset00_GFX,Tset00_Coll,$FF,$FF,$FF,$52,2
	TSETHEAD Tset01_Block,Tset01_GFX,Tset01_Coll,$FF,$FF,$FF,$FF,0
	TSETHEAD Tset02_Block,Tset02_GFX,Tset02_Coll,$18,$19,$1E,$FF,0
	TSETHEAD Tset03_Block,Tset03_GFX,Tset03_Coll,$FF,$FF,$FF,$20,1
	TSETHEAD Tset01_Block,Tset01_GFX,Tset01_Coll,$FF,$FF,$FF,$FF,0
	TSETHEAD Tset05_Block,Tset05_GFX,Tset05_Coll,$3A,$FF,$FF,$FF,2
	TSETHEAD Tset02_Block,Tset02_GFX,Tset02_Coll,$18,$19,$1E,$FF,0
	TSETHEAD Tset05_Block,Tset05_GFX,Tset05_Coll,$3A,$FF,$FF,$FF,2
	TSETHEAD Tset08_Block,Tset08_GFX,Tset08_Coll,$FF,$FF,$FF,$FF,0
	TSETHEAD Tset09_Block,Tset09_GFX,Tset09_Coll,$17,$32,$FF,$FF,0
	TSETHEAD Tset09_Block,Tset09_GFX,Tset09_Coll,$17,$32,$FF,$FF,0
	TSETHEAD Tset0B_Block,Tset0B_GFX,Tset0B_Coll,$FF,$FF,$FF,$FF,0
	TSETHEAD Tset09_Block,Tset09_GFX,Tset09_Coll,$17,$32,$FF,$FF,0
	TSETHEAD Tset0D_Block,Tset0D_GFX,Tset0D_Coll,$FF,$FF,$FF,$FF,1
	TSETHEAD Tset0E_Block,Tset0E_GFX,Tset0E_Coll,$FF,$FF,$FF,$FF,1
	TSETHEAD Tset0F_Block,Tset0F_GFX,Tset0F_Coll,$12,$FF,$FF,$FF,0
	TSETHEAD Tset10_Block,Tset10_GFX,Tset10_Coll,$FF,$FF,$FF,$FF,0
	TSETHEAD Tset11_Block,Tset11_GFX,Tset11_Coll,$FF,$FF,$FF,$FF,1
	TSETHEAD Tset12_Block,Tset12_GFX,Tset12_Coll,$15,$36,$FF,$FF,0
	TSETHEAD Tset13_Block,Tset13_GFX,Tset13_Coll,$FF,$FF,$FF,$FF,0
	TSETHEAD Tset14_Block,Tset14_GFX,Tset14_Coll,$FF,$FF,$FF,$FF,0
	TSETHEAD Tset15_Block,Tset15_GFX,Tset15_Coll,$07,$17,$FF,$FF,0
	TSETHEAD Tset16_Block,Tset16_GFX,Tset16_Coll,$12,$FF,$FF,$FF,1
	TSETHEAD Tset17_Block,Tset17_GFX,Tset17_Coll,$FF,$FF,$FF,$45,1
; 0xC8DE

INCBIN "baserom.gbc",$C8DE,$C8F5-$C8DE

; data for default hidden/shown
; objects for each map ($00-$F8)

; Table of 2-Byte pointers, one pointer per map,
; goes up to Map_F7, ends with $FFFF.
MapHSPointers: ; 48F5
	dw MapHS00
	dw MapHS01
	dw MapHS02
	dw MapHS03
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHS0A
	dw MapHSXX
	dw MapHSXX
	dw MapHS0D
	dw MapHSXX
	dw MapHS0F
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHS14
	dw MapHSXX
	dw MapHSXX
	dw MapHS17
	dw MapHSXX
	dw MapHSXX
	dw MapHS1A
	dw MapHS1B
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHS21
	dw MapHSXX
	dw MapHS23
	dw MapHS24
	dw MapHSXX
	dw MapHSXX
	dw MapHS27
	dw MapHS28
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHS2D
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHS33
	dw MapHS34
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHS3B
	dw MapHSXX
	dw MapHS3D
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHS53
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHS58
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHS60
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHS66
	dw MapHS67
	dw MapHS68
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHS6C
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHS78
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHS84
	dw MapHSXX
	dw MapHSXX
	dw MapHS87
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHS8F
	dw MapHS90
	dw MapHS91
	dw MapHS92
	dw MapHS93
	dw MapHS94
	dw MapHS95
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHS9B
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHS9F
	dw MapHSA0
	dw MapHSA1
	dw MapHSA2
	dw MapHSXX
	dw MapHSXX
	dw MapHSA5
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSB1
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSB5
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSC0
	dw MapHSXX
	dw MapHSC2
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSC6
	dw MapHSC7
	dw MapHSC8
	dw MapHSC9
	dw MapHSCA
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSCF
	dw MapHSD0
	dw MapHSD1
	dw MapHSD2
	dw MapHSD3
	dw MapHSD4
	dw MapHSD5
	dw MapHSD6
	dw MapHSD7
	dw MapHSD8
	dw MapHSD9
	dw MapHSDA
	dw MapHSDB
	dw MapHSDC
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSE2
	dw MapHSE3
	dw MapHSE4
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSE9
	dw MapHSEA
	dw MapHSEB
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSF4
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw $FFFF

; Structure:
; 3 bytes per object
; [Map_ID][Object_ID][H/S]
;
; Program stops reading when either:
; a) Map_ID = $FF
; b) Map_ID ≠ currentMapID
;
; This Data is loaded into RAM at $D5CE-$D5F?.

; These constants come from the bytes for Predef functions:
Hide	equ $11
Show	equ $15

MapHSXX:
	db $FF,$FF,$FF
MapHS00:
	db PALLET_TOWN,$01,Hide
MapHS01:
	db VIRIDIAN_CITY,$05,Show
	db VIRIDIAN_CITY,$07,Hide
MapHS02:
	db PEWTER_CITY,$03,Show
	db PEWTER_CITY,$05,Show
MapHS03:
	db CERULEAN_CITY,$01,Hide
	db CERULEAN_CITY,$02,Show
	db CERULEAN_CITY,$06,Hide
	db CERULEAN_CITY,$0A,Show
	db CERULEAN_CITY,$0B,Show
MapHS0A:
	db SAFFRON_CITY,$01,Show
	db SAFFRON_CITY,$02,Show
	db SAFFRON_CITY,$03,Show
	db SAFFRON_CITY,$04,Show
	db SAFFRON_CITY,$05,Show
	db SAFFRON_CITY,$06,Show
	db SAFFRON_CITY,$07,Show
	db SAFFRON_CITY,$08,Hide
	db SAFFRON_CITY,$09,Hide
	db SAFFRON_CITY,$0A,Hide
	db SAFFRON_CITY,$0B,Hide
	db SAFFRON_CITY,$0C,Hide
	db SAFFRON_CITY,$0D,Hide
	db SAFFRON_CITY,$0E,Show
	db SAFFRON_CITY,$0F,Hide
MapHS0D:
	db ROUTE_2,$01,Show
	db ROUTE_2,$02,Show
MapHS0F:
	db ROUTE_4,$03,Show
MapHS14:
	db ROUTE_9,$0A,Show
MapHS17:
	db ROUTE_12,$01,Show
	db ROUTE_12,$09,Show
	db ROUTE_12,$0A,Show
MapHS1A:
	db ROUTE_15,$0B,Show
MapHS1B:
	db ROUTE_16,$07,Show
MapHS21:
	db ROUTE_22,$01,Hide
	db ROUTE_22,$02,Hide
MapHS23:
	db ROUTE_24,$01,Show
	db ROUTE_24,$08,Show
MapHS24:
	db ROUTE_25,$0A,Show
MapHS27:
	db BLUES_HOUSE,$01,Show
	db BLUES_HOUSE,$02,Hide
	db BLUES_HOUSE,$03,Show
MapHS28:
	db OAKS_LAB,$01,Show
	db OAKS_LAB,$02,Show
	db OAKS_LAB,$03,Show
	db OAKS_LAB,$04,Show
	db OAKS_LAB,$05,Hide
	db OAKS_LAB,$06,Show
	db OAKS_LAB,$07,Show
	db OAKS_LAB,$08,Hide
MapHS2D:
	db VIRIDIAN_GYM,$01,Show
	db VIRIDIAN_GYM,$0B,Show
MapHS34:
	db MUSEUM_1F,$05,Show
MapHSE4:
	db UNKNOWN_DUNGEON_1,$01,Show
	db UNKNOWN_DUNGEON_1,$02,Show
	db UNKNOWN_DUNGEON_1,$03,Show
MapHS8F:
	db POKEMONTOWER_2,$01,Show
MapHS90:
	db POKEMONTOWER_3,$04,Show
MapHS91:
	db POKEMONTOWER_4,$04,Show
	db POKEMONTOWER_4,$05,Show
	db POKEMONTOWER_4,$06,Show
MapHS92:
	db POKEMONTOWER_5,$06,Show
MapHS93:
	db POKEMONTOWER_6,$04,Show
	db POKEMONTOWER_6,$05,Show
MapHS94:
	db POKEMONTOWER_7,$01,Show
	db POKEMONTOWER_7,$02,Show
	db POKEMONTOWER_7,$03,Show
	db POKEMONTOWER_7,$04,Show
MapHS95:
	db LAVENDER_HOUSE_1,$05,Hide
MapHS84:
	db CELADON_MANSION_5,$02,Show
MapHS87:
	db GAME_CORNER,$0B,Show
MapHS9B:
	db FUCHSIA_HOUSE_2,$02,Show
MapHSA5:
	db MANSION_1,$02,Show
	db MANSION_1,$03,Show
MapHSB1:
	db FIGHTINGDOJO,$06,Show
	db FIGHTINGDOJO,$07,Show
MapHSB5:
	db SILPH_CO_1F,$01,Hide
MapHS53:
	db POWER_PLANT,$01,Show
	db POWER_PLANT,$02,Show
	db POWER_PLANT,$03,Show
	db POWER_PLANT,$04,Show
	db POWER_PLANT,$05,Show
	db POWER_PLANT,$06,Show
	db POWER_PLANT,$07,Show
	db POWER_PLANT,$08,Show
	db POWER_PLANT,$09,Show
	db POWER_PLANT,$0A,Show
	db POWER_PLANT,$0B,Show
	db POWER_PLANT,$0C,Show
	db POWER_PLANT,$0D,Show
	db POWER_PLANT,$0E,Show
MapHSC2:
	db VICTORY_ROAD_2,$06,Show
	db VICTORY_ROAD_2,$07,Show
	db VICTORY_ROAD_2,$08,Show
	db VICTORY_ROAD_2,$09,Show
	db VICTORY_ROAD_2,$0A,Show
	db VICTORY_ROAD_2,$0D,Show
MapHS58:
	db BILLS_HOUSE,$01,Show
	db BILLS_HOUSE,$02,Hide
	db BILLS_HOUSE,$03,Hide
MapHS33:
	db VIRIDIAN_FOREST,$05,Show
	db VIRIDIAN_FOREST,$06,Show
	db VIRIDIAN_FOREST,$07,Show
MapHS3B:
	db MT_MOON_1,$08,Show
	db MT_MOON_1,$09,Show
	db MT_MOON_1,$0A,Show
	db MT_MOON_1,$0B,Show
	db MT_MOON_1,$0C,Show
	db MT_MOON_1,$0D,Show
MapHS3D:
	db MT_MOON_3,$06,Show
	db MT_MOON_3,$07,Show
	db MT_MOON_3,$08,Show
	db MT_MOON_3,$09,Show
MapHS60:
	db SS_ANNE_2,$02,Hide
MapHS66:
	db SS_ANNE_8,$0A,Show
MapHS67:
	db SS_ANNE_9,$06,Show
	db SS_ANNE_9,$09,Show
MapHS68:
	db SS_ANNE_10,$09,Show
	db SS_ANNE_10,$0A,Show
	db SS_ANNE_10,$0B,Show
MapHSC6:
	db VICTORY_ROAD_3,$05,Show
	db VICTORY_ROAD_3,$06,Show
	db VICTORY_ROAD_3,$0A,Show
MapHSC7:
	db ROCKET_HIDEOUT_1,$06,Show
	db ROCKET_HIDEOUT_1,$07,Show
MapHSC8:
	db ROCKET_HIDEOUT_2,$02,Show
	db ROCKET_HIDEOUT_2,$03,Show
	db ROCKET_HIDEOUT_2,$04,Show
	db ROCKET_HIDEOUT_2,$05,Show
MapHSC9:
	db ROCKET_HIDEOUT_3,$03,Show
	db ROCKET_HIDEOUT_3,$04,Show
MapHSCA:
	db ROCKET_HIDEOUT_4,$01,Show
	db ROCKET_HIDEOUT_4,$05,Show
	db ROCKET_HIDEOUT_4,$06,Show
	db ROCKET_HIDEOUT_4,$07,Show
	db ROCKET_HIDEOUT_4,$08,Hide
	db ROCKET_HIDEOUT_4,$09,Hide
MapHSCF:
	db SILPH_CO_2F,$01,Show
	db SILPH_CO_2F,$02,Show
	db SILPH_CO_2F,$03,Show
	db SILPH_CO_2F,$04,Show
	db SILPH_CO_2F,$05,Show
MapHSD0:
	db SILPH_CO_3F,$02,Show
	db SILPH_CO_3F,$03,Show
	db SILPH_CO_3F,$04,Show
MapHSD1:
	db SILPH_CO_4F,$02,Show
	db SILPH_CO_4F,$03,Show
	db SILPH_CO_4F,$04,Show
	db SILPH_CO_4F,$05,Show
	db SILPH_CO_4F,$06,Show
	db SILPH_CO_4F,$07,Show
MapHSD2:
	db SILPH_CO_5F,$02,Show
	db SILPH_CO_5F,$03,Show
	db SILPH_CO_5F,$04,Show
	db SILPH_CO_5F,$05,Show
	db SILPH_CO_5F,$06,Show
	db SILPH_CO_5F,$07,Show
	db SILPH_CO_5F,$08,Show
MapHSD3:
	db SILPH_CO_6F,$06,Show
	db SILPH_CO_6F,$07,Show
	db SILPH_CO_6F,$08,Show
	db SILPH_CO_6F,$09,Show
	db SILPH_CO_6F,$0A,Show
MapHSD4:
	db SILPH_CO_7F,$05,Show
	db SILPH_CO_7F,$06,Show
	db SILPH_CO_7F,$07,Show
	db SILPH_CO_7F,$08,Show
	db SILPH_CO_7F,$09,Show
	db SILPH_CO_7F,$0A,Show
	db SILPH_CO_7F,$0B,Show
	db SILPH_CO_7F,$0C,Show
MapHSD5:
	db SILPH_CO_8F,$02,Show
	db SILPH_CO_8F,$03,Show
	db SILPH_CO_8F,$04,Show
MapHSE9:
	db SILPH_CO_9F,$02,Show
	db SILPH_CO_9F,$03,Show
	db SILPH_CO_9F,$04,Show
MapHSEA:
	db SILPH_CO_10F,$01,Show
	db SILPH_CO_10F,$02,Show
	db SILPH_CO_10F,$03,Show
	db SILPH_CO_10F,$04,Show
	db SILPH_CO_10F,$05,Show
	db SILPH_CO_10F,$06,Show
MapHSEB:
	db SILPH_CO_11F,$03,Show
	db SILPH_CO_11F,$04,Show
	db SILPH_CO_11F,$05,Show
MapHSF4:
	db $F4,$02,Show
MapHSD6:
	db MANSION_2,$02,Show
MapHSD7:
	db MANSION_3,$03,Show
	db MANSION_3,$04,Show
MapHSD8:
	db MANSION_4,$03,Show
	db MANSION_4,$04,Show
	db MANSION_4,$05,Show
	db MANSION_4,$06,Show
	db MANSION_4,$08,Show
MapHSD9:
	db SAFARI_ZONE_EAST,$01,Show
	db SAFARI_ZONE_EAST,$02,Show
	db SAFARI_ZONE_EAST,$03,Show
	db SAFARI_ZONE_EAST,$04,Show
MapHSDA:
	db SAFARI_ZONE_NORTH,$01,Show
	db SAFARI_ZONE_NORTH,$02,Show
MapHSDB:
	db SAFARI_ZONE_WEST,$01,Show
	db SAFARI_ZONE_WEST,$02,Show
	db SAFARI_ZONE_WEST,$03,Show
	db SAFARI_ZONE_WEST,$04,Show
MapHSDC:
	db SAFARI_ZONE_CENTER,$01,Show
MapHSE2:
	db UNKNOWN_DUNGEON_2,$01,Show
	db UNKNOWN_DUNGEON_2,$02,Show
	db UNKNOWN_DUNGEON_2,$03,Show
MapHSE3:
	db UNKNOWN_DUNGEON_3,$01,Show
	db UNKNOWN_DUNGEON_3,$02,Show
	db UNKNOWN_DUNGEON_3,$03,Show
MapHS6C:
	db VICTORY_ROAD_1,$03,Show
	db VICTORY_ROAD_1,$04,Show
MapHS78:
	db CHAMPIONS_ROOM,$02,Hide
MapHSC0:
	db SEAFOAM_ISLANDS_1,$01,Show
	db SEAFOAM_ISLANDS_1,$02,Show
MapHS9F:
	db SEAFOAM_ISLANDS_2,$01,Hide
	db SEAFOAM_ISLANDS_2,$02,Hide
MapHSA0:
	db SEAFOAM_ISLANDS_3,$01,Hide
	db SEAFOAM_ISLANDS_3,$02,Hide
MapHSA1:
	db SEAFOAM_ISLANDS_4,$02,Show
	db SEAFOAM_ISLANDS_4,$03,Show
	db SEAFOAM_ISLANDS_4,$05,Hide
	db SEAFOAM_ISLANDS_4,$06,Hide
MapHSA2:
	db SEAFOAM_ISLANDS_5,$01,Hide
	db SEAFOAM_ISLANDS_5,$02,Hide
	db SEAFOAM_ISLANDS_5,$03,Show

	db $FF

INCBIN "baserom.gbc",$cd97,$cdbb - $cd97

UnnamedText_cdbb: ; 0xcdbb
	TX_FAR _UnnamedText_cdbb
	db $50
; 0xcdbb + 5 bytes

INCBIN "baserom.gbc",$cdc0,$cdfa - $cdc0

UnnamedText_cdfa: ; 0xcdfa
	TX_FAR _UnnamedText_cdfa
	db $50
; 0xcdfa + 5 bytes

UnnamedText_cdff: ; 0xcdff
	TX_FAR _UnnamedText_cdff
	db $50
; 0xcdff + 5 bytes

INCBIN "baserom.gbc",$ce04,$b4

; wild pokemon data: from 4EB8 to 55C7

LoadWildData: ; 4EB8
	ld hl,WildDataPointers
	ld a,[W_CURMAP]

	; get wild data for current map
	ld c,a
	ld b,0
	add hl,bc
	add hl,bc
	ld a,[hli]
	ld h,[hl]
	ld l,a       ; hl now points to wild data for current map
	ld a,[hli]
	ld [W_GRASSRATE],a
	and a
	jr z,.NoGrassData\@ ; if no grass data, skip to surfing data
	push hl
	ld de,W_GRASSMONS ; otherwise, load grass data
	ld bc,$0014
	call CopyData
	pop hl
	ld bc,$0014
	add hl,bc
.NoGrassData\@
	ld a,[hli]
	ld [W_WATERRATE],a
	and a
	ret z        ; if no water data, we're done
	ld de,W_WATERMONS  ; otherwise, load surfing data
	ld bc,$0014
	jp CopyData

WildDataPointers: ; 4EEB
	dw NoMons      ; PALLET_TOWN
	dw NoMons      ; VIRIDIAN_CITY
	dw NoMons      ; PEWTER_CITY
	dw NoMons      ; CERULEAN_CITY
	dw NoMons      ; LAVENDER_TOWN
	dw NoMons      ; VERMILION_CITY
	dw NoMons      ; CELADON_CITY
	dw NoMons      ; FUCHSIA_CITY
	dw NoMons      ; CINNABAR_ISLAND
	dw NoMons      ; INDIGO_PLATEAU
	dw NoMons      ; SAFFRON_CITY
	dw NoMons      ; unused
	dw Route1Mons  ; ROUTE_1
	dw Route2Mons  ; ROUTE_2
	dw Route3Mons  ; ROUTE_3
	dw Route4Mons  ; ROUTE_4
	dw Route5Mons  ; ROUTE_5
	dw Route6Mons  ; ROUTE_6
	dw Route7Mons  ; ROUTE_7
	dw Route8Mons  ; ROUTE_8
	dw Route9Mons  ; ROUTE_9
	dw Route10Mons ; ROUTE_10
	dw Route11Mons ; ROUTE_11
	dw Route12Mons ; ROUTE_12
	dw Route13Mons ; ROUTE_13
	dw Route14Mons ; ROUTE_14
	dw Route15Mons ; ROUTE_15
	dw Route16Mons ; ROUTE_16
	dw Route17Mons ; ROUTE_17
	dw Route18Mons ; ROUTE_18
	dw WaterMons   ; ROUTE_19
	dw WaterMons   ; ROUTE_20
	dw Route21Mons ; ROUTE_21
	dw Route22Mons ; ROUTE_22
	dw Route23Mons ; ROUTE_23
	dw Route24Mons ; ROUTE_24
	dw Route25Mons ; ROUTE_25
	dw NoMons      ; REDS_HOUSE_1F
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw ForestMons ; ViridianForest
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw MoonMons1
	dw MoonMonsB1
	dw MoonMonsB2
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw TunnelMonsB1
	dw PowerPlantMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw PlateauMons1
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw TowerMons1
	dw TowerMons2
	dw TowerMons3
	dw TowerMons4
	dw TowerMons5
	dw TowerMons6
	dw TowerMons7
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw IslandMonsB1
	dw IslandMonsB2
	dw IslandMonsB3
	dw IslandMonsB4
	dw NoMons
	dw NoMons
	dw MansionMons1
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw IslandMons1
	dw NoMons
	dw PlateauMons2
	dw NoMons
	dw NoMons
	dw CaveMons
	dw PlateauMons3
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw MansionMons2
	dw MansionMons3
	dw MansionMonsB1
	dw ZoneMons1
	dw ZoneMons2
	dw ZoneMons3
	dw ZoneMonsCenter
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw DungeonMons2
	dw DungeonMonsB1
	dw DungeonMons1
	dw NoMons
	dw NoMons
	dw NoMons
	dw TunnelMonsB2
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw NoMons
	dw $FFFF

; wild pokemon data is divided into two parts.
; first part:  pokemon found in grass
; second part: pokemon found while surfing
; each part goes as follows:
	; if first byte == 00, then
		; no wild pokemon on this map
	; if first byte != 00, then
		; first byte is encounter rate
		; followed by 20 bytes:
		; level, species (ten times)

IF _RED
NoMons:
	db $00

	db $00

Route1Mons:
	db $19
	db 3,PIDGEY
	db 3,RATTATA
	db 3,RATTATA
	db 2,RATTATA
	db 2,PIDGEY
	db 3,PIDGEY
	db 3,PIDGEY
	db 4,RATTATA
	db 4,PIDGEY
	db 5,PIDGEY

	db $00

Route2Mons:
	db $19
	db 3,RATTATA
	db 3,PIDGEY
	db 4,PIDGEY
	db 4,RATTATA
	db 5,PIDGEY
	db 3,WEEDLE
	db 2,RATTATA
	db 5,RATTATA
	db 4,WEEDLE
	db 5,WEEDLE

	db $00

Route22Mons:
	db $19
	db 3,RATTATA
	db 3,NIDORAN_M
	db 4,RATTATA
	db 4,NIDORAN_M
	db 2,RATTATA
	db 2,NIDORAN_M
	db 3,SPEAROW
	db 5,SPEAROW
	db 3,NIDORAN_F
	db 4,NIDORAN_F

	db $00

ForestMons:
	db $08
	db 4,WEEDLE
	db 5,KAKUNA
	db 3,WEEDLE
	db 5,WEEDLE
	db 4,KAKUNA
	db 6,KAKUNA
	db 4,METAPOD
	db 3,CATERPIE
	db 3,PIKACHU
	db 5,PIKACHU

	db $00

Route3Mons:
	db $14
	db 6,PIDGEY
	db 5,SPEAROW
	db 7,PIDGEY
	db 6,SPEAROW
	db 7,SPEAROW
	db 8,PIDGEY
	db 8,SPEAROW
	db 3,JIGGLYPUFF
	db 5,JIGGLYPUFF
	db 7,JIGGLYPUFF

	db $00

MoonMons1:
	db $0A
	db 8,ZUBAT
	db 7,ZUBAT
	db 9,ZUBAT
	db 8,GEODUDE
	db 6,ZUBAT
	db 10,ZUBAT
	db 10,GEODUDE
	db 8,PARAS
	db 11,ZUBAT
	db 8,CLEFAIRY

	db $00

MoonMonsB1:
	db $0A
	db 8,ZUBAT
	db 7,ZUBAT
	db 7,GEODUDE
	db 8,GEODUDE
	db 9,ZUBAT
	db 10,PARAS
	db 10,ZUBAT
	db 11,ZUBAT
	db 9,CLEFAIRY
	db 9,GEODUDE

	db $00

MoonMonsB2:
	db $0A
	db 9,ZUBAT
	db 9,GEODUDE
	db 10,ZUBAT
	db 10,GEODUDE
	db 11,ZUBAT
	db 10,PARAS
	db 12,PARAS
	db 10,CLEFAIRY
	db 12,ZUBAT
	db 12,CLEFAIRY

	db $00

Route4Mons:
	db $14
	db 10,RATTATA
	db 10,SPEAROW
	db 8,RATTATA
	db 6,EKANS
	db 8,SPEAROW
	db 10,EKANS
	db 12,RATTATA
	db 12,SPEAROW
	db 8,EKANS
	db 12,EKANS

	db $00

Route24Mons:
	db $19
	db 7,WEEDLE
	db 8,KAKUNA
	db 12,PIDGEY
	db 12,ODDISH
	db 13,ODDISH
	db 10,ABRA
	db 14,ODDISH
	db 13,PIDGEY
	db 8,ABRA
	db 12,ABRA

	db $00

Route25Mons:
	db $0F
	db 8,WEEDLE
	db 9,KAKUNA
	db 13,PIDGEY
	db 12,ODDISH
	db 13,ODDISH
	db 12,ABRA
	db 14,ODDISH
	db 10,ABRA
	db 7,METAPOD
	db 8,CATERPIE

	db $00

Route9Mons:
	db $0F
	db 16,RATTATA
	db 16,SPEAROW
	db 14,RATTATA
	db 11,EKANS
	db 13,SPEAROW
	db 15,EKANS
	db 17,RATTATA
	db 17,SPEAROW
	db 13,EKANS
	db 17,EKANS

	db $00

Route5Mons:
	db $0F
	db 13,ODDISH
	db 13,PIDGEY
	db 15,PIDGEY
	db 10,MANKEY
	db 12,MANKEY
	db 15,ODDISH
	db 16,ODDISH
	db 16,PIDGEY
	db 14,MANKEY
	db 16,MANKEY

	db $00

Route6Mons:
	db $0F
	db 13,ODDISH
	db 13,PIDGEY
	db 15,PIDGEY
	db 10,MANKEY
	db 12,MANKEY
	db 15,ODDISH
	db 16,ODDISH
	db 16,PIDGEY
	db 14,MANKEY
	db 16,MANKEY

	db $00

Route11Mons:
	db $0F
	db 14,EKANS
	db 15,SPEAROW
	db 12,EKANS
	db 9,DROWZEE
	db 13,SPEAROW
	db 13,DROWZEE
	db 15,EKANS
	db 17,SPEAROW
	db 11,DROWZEE
	db 15,DROWZEE

	db $00

TunnelMonsB1:
	db $0F
	db 16,ZUBAT
	db 17,ZUBAT
	db 17,GEODUDE
	db 15,MACHOP
	db 16,GEODUDE
	db 18,ZUBAT
	db 15,ZUBAT
	db 17,MACHOP
	db 13,ONIX
	db 15,ONIX

	db $00

TunnelMonsB2:
	db $0F
	db 16,ZUBAT
	db 17,ZUBAT
	db 17,GEODUDE
	db 15,MACHOP
	db 16,GEODUDE
	db 18,ZUBAT
	db 17,MACHOP
	db 17,ONIX
	db 13,ONIX
	db 18,GEODUDE

	db $00

Route10Mons:
	db $0F
	db 16,VOLTORB
	db 16,SPEAROW
	db 14,VOLTORB
	db 11,EKANS
	db 13,SPEAROW
	db 15,EKANS
	db 17,VOLTORB
	db 17,SPEAROW
	db 13,EKANS
	db 17,EKANS

	db $00

Route12Mons:
	db $0F
	db 24,ODDISH
	db 25,PIDGEY
	db 23,PIDGEY
	db 24,VENONAT
	db 22,ODDISH
	db 26,VENONAT
	db 26,ODDISH
	db 27,PIDGEY
	db 28,GLOOM
	db 30,GLOOM

	db $00

Route8Mons:
	db $0F
	db 18,PIDGEY
	db 18,MANKEY
	db 17,EKANS
	db 16,GROWLITHE
	db 20,PIDGEY
	db 20,MANKEY
	db 19,EKANS
	db 17,GROWLITHE
	db 15,GROWLITHE
	db 18,GROWLITHE

	db $00

Route7Mons:
	db $0F
	db 19,PIDGEY
	db 19,ODDISH
	db 17,MANKEY
	db 22,ODDISH
	db 22,PIDGEY
	db 18,MANKEY
	db 18,GROWLITHE
	db 20,GROWLITHE
	db 19,MANKEY
	db 20,MANKEY

	db $00

TowerMons1:
	db $00

	db $00

TowerMons2:
	db $00

	db $00

TowerMons3:
	db $0A
	db 20,GASTLY
	db 21,GASTLY
	db 22,GASTLY
	db 23,GASTLY
	db 19,GASTLY
	db 18,GASTLY
	db 24,GASTLY
	db 20,CUBONE
	db 22,CUBONE
	db 25,HAUNTER

	db $00

TowerMons4:
	db $0A
	db 20,GASTLY
	db 21,GASTLY
	db 22,GASTLY
	db 23,GASTLY
	db 19,GASTLY
	db 18,GASTLY
	db 25,HAUNTER
	db 20,CUBONE
	db 22,CUBONE
	db 24,GASTLY

	db $00

TowerMons5:
	db $0A
	db 20,GASTLY
	db 21,GASTLY
	db 22,GASTLY
	db 23,GASTLY
	db 19,GASTLY
	db 18,GASTLY
	db 25,HAUNTER
	db 20,CUBONE
	db 22,CUBONE
	db 24,GASTLY

	db $00

TowerMons6:
	db $0F
	db 21,GASTLY
	db 22,GASTLY
	db 23,GASTLY
	db 24,GASTLY
	db 20,GASTLY
	db 19,GASTLY
	db 26,HAUNTER
	db 22,CUBONE
	db 24,CUBONE
	db 28,HAUNTER

	db $00

TowerMons7:
	db $0F
	db 21,GASTLY
	db 22,GASTLY
	db 23,GASTLY
	db 24,GASTLY
	db 20,GASTLY
	db 28,HAUNTER
	db 22,CUBONE
	db 24,CUBONE
	db 28,HAUNTER
	db 30,HAUNTER

	db $00

Route13Mons:
	db $14
	db 24,ODDISH
	db 25,PIDGEY
	db 27,PIDGEY
	db 24,VENONAT
	db 22,ODDISH
	db 26,VENONAT
	db 26,ODDISH
	db 25,DITTO
	db 28,GLOOM
	db 30,GLOOM

	db $00

Route14Mons:
	db $0F
	db 24,ODDISH
	db 26,PIDGEY
	db 23,DITTO
	db 24,VENONAT
	db 22,ODDISH
	db 26,VENONAT
	db 26,ODDISH
	db 30,GLOOM
	db 28,PIDGEOTTO
	db 30,PIDGEOTTO

	db $00

Route15Mons:
	db $0F
	db 24,ODDISH
	db 26,DITTO
	db 23,PIDGEY
	db 26,VENONAT
	db 22,ODDISH
	db 28,VENONAT
	db 26,ODDISH
	db 30,GLOOM
	db 28,PIDGEOTTO
	db 30,PIDGEOTTO

	db $00

Route16Mons:
	db $19
	db 20,SPEAROW
	db 22,SPEAROW
	db 18,RATTATA
	db 20,DODUO
	db 20,RATTATA
	db 18,DODUO
	db 22,DODUO
	db 22,RATTATA
	db 23,RATICATE
	db 25,RATICATE

	db $00

Route17Mons:
	db $19
	db 20,SPEAROW
	db 22,SPEAROW
	db 25,RATICATE
	db 24,DODUO
	db 27,RATICATE
	db 26,DODUO
	db 28,DODUO
	db 29,RATICATE
	db 25,FEAROW
	db 27,FEAROW

	db $00

Route18Mons:
	db $19
	db 20,SPEAROW
	db 22,SPEAROW
	db 25,RATICATE
	db 24,DODUO
	db 25,FEAROW
	db 26,DODUO
	db 28,DODUO
	db 29,RATICATE
	db 27,FEAROW
	db 29,FEAROW

	db $00

ZoneMonsCenter:
	db $1E
	db 22,NIDORAN_M
	db 25,RHYHORN
	db 22,VENONAT
	db 24,EXEGGCUTE
	db 31,NIDORINO
	db 25,EXEGGCUTE
	db 31,NIDORINA
	db 30,PARASECT
	db 23,SCYTHER
	db 23,CHANSEY

	db $00

ZoneMons1:
	db $1E
	db 24,NIDORAN_M
	db 26,DODUO
	db 22,PARAS
	db 25,EXEGGCUTE
	db 33,NIDORINO
	db 23,EXEGGCUTE
	db 24,NIDORAN_F
	db 25,PARASECT
	db 25,KANGASKHAN
	db 28,SCYTHER

	db $00

ZoneMons2:
	db $1E
	db 22,NIDORAN_M
	db 26,RHYHORN
	db 23,PARAS
	db 25,EXEGGCUTE
	db 30,NIDORINO
	db 27,EXEGGCUTE
	db 30,NIDORINA
	db 32,VENOMOTH
	db 26,CHANSEY
	db 28,TAUROS

	db $00

ZoneMons3:
	db $1E
	db 25,NIDORAN_M
	db 26,DODUO
	db 23,VENONAT
	db 24,EXEGGCUTE
	db 33,NIDORINO
	db 26,EXEGGCUTE
	db 25,NIDORAN_F
	db 31,VENOMOTH
	db 26,TAUROS
	db 28,KANGASKHAN

	db $00

WaterMons:
	db $00

	db $05
	db 5,TENTACOOL
	db 10,TENTACOOL
	db 15,TENTACOOL
	db 5,TENTACOOL
	db 10,TENTACOOL
	db 15,TENTACOOL
	db 20,TENTACOOL
	db 30,TENTACOOL
	db 35,TENTACOOL
	db 40,TENTACOOL

IslandMons1:
	db $0F
	db 30,SEEL
	db 30,SLOWPOKE
	db 30,SHELLDER
	db 30,HORSEA
	db 28,HORSEA
	db 21,ZUBAT
	db 29,GOLBAT
	db 28,PSYDUCK
	db 28,SHELLDER
	db 38,GOLDUCK

	db $00

IslandMonsB1:
	db $0A
	db 30,STARYU
	db 30,HORSEA
	db 32,SHELLDER
	db 32,HORSEA
	db 28,SLOWPOKE
	db 30,SEEL
	db 30,SLOWPOKE
	db 28,SEEL
	db 38,DEWGONG
	db 37,SEADRA

	db $00

IslandMonsB2:
	db $0A
	db 30,SEEL
	db 30,SLOWPOKE
	db 32,SEEL
	db 32,SLOWPOKE
	db 28,HORSEA
	db 30,STARYU
	db 30,HORSEA
	db 28,SHELLDER
	db 30,GOLBAT
	db 37,SLOWBRO

	db $00

IslandMonsB3:
	db $0A
	db 31,SLOWPOKE
	db 31,SEEL
	db 33,SLOWPOKE
	db 33,SEEL
	db 29,HORSEA
	db 31,SHELLDER
	db 31,HORSEA
	db 29,SHELLDER
	db 39,SEADRA
	db 37,DEWGONG

	db $00

IslandMonsB4:
	db $0A
	db 31,HORSEA
	db 31,SHELLDER
	db 33,HORSEA
	db 33,SHELLDER
	db 29,SLOWPOKE
	db 31,SEEL
	db 31,SLOWPOKE
	db 29,SEEL
	db 39,SLOWBRO
	db 32,GOLBAT

	db $00

MansionMons1:
	db $0A
	db 32,KOFFING
	db 30,KOFFING
	db 34,PONYTA
	db 30,PONYTA
	db 34,GROWLITHE
	db 32,PONYTA
	db 30,GRIMER
	db 28,PONYTA
	db 37,WEEZING
	db 39,MUK

	db $00

MansionMons2:
	db $0A
	db 32,GROWLITHE
	db 34,KOFFING
	db 34,KOFFING
	db 30,PONYTA
	db 30,KOFFING
	db 32,PONYTA
	db 30,GRIMER
	db 28,PONYTA
	db 39,WEEZING
	db 37,MUK

	db $00

MansionMons3:
	db $0A
	db 31,KOFFING
	db 33,GROWLITHE
	db 35,KOFFING
	db 32,PONYTA
	db 34,PONYTA
	db 40,WEEZING
	db 34,GRIMER
	db 38,WEEZING
	db 36,PONYTA
	db 42,MUK

	db $00

MansionMonsB1:
	db $0A
	db 33,KOFFING
	db 31,KOFFING
	db 35,GROWLITHE
	db 32,PONYTA
	db 31,KOFFING
	db 40,WEEZING
	db 34,PONYTA
	db 35,GRIMER
	db 42,WEEZING
	db 42,MUK

	db $00

Route21Mons:
	db $19
	db 21,RATTATA
	db 23,PIDGEY
	db 30,RATICATE
	db 23,RATTATA
	db 21,PIDGEY
	db 30,PIDGEOTTO
	db 32,PIDGEOTTO
	db 28,TANGELA
	db 30,TANGELA
	db 32,TANGELA

	db $05
	db 5,TENTACOOL
	db 10,TENTACOOL
	db 15,TENTACOOL
	db 5,TENTACOOL
	db 10,TENTACOOL
	db 15,TENTACOOL
	db 20,TENTACOOL
	db 30,TENTACOOL
	db 35,TENTACOOL
	db 40,TENTACOOL

DungeonMons1:
	db $0A
	db 46,GOLBAT
	db 46,HYPNO
	db 46,MAGNETON
	db 49,DODRIO
	db 49,VENOMOTH
	db 52,ARBOK
	db 49,KADABRA
	db 52,PARASECT
	db 53,RAICHU
	db 53,DITTO

	db $00

DungeonMons2:
	db $0F
	db 51,DODRIO
	db 51,VENOMOTH
	db 51,KADABRA
	db 52,RHYDON
	db 52,MAROWAK
	db 52,ELECTRODE
	db 56,CHANSEY
	db 54,WIGGLYTUFF
	db 55,DITTO
	db 60,DITTO

	db $00

DungeonMonsB1:
	db $19
	db 55,RHYDON
	db 55,MAROWAK
	db 55,ELECTRODE
	db 64,CHANSEY
	db 64,PARASECT
	db 64,RAICHU
	db 57,ARBOK
	db 65,DITTO
	db 63,DITTO
	db 67,DITTO

	db $00

PowerPlantMons:
	db $0A
	db 21,VOLTORB
	db 21,MAGNEMITE
	db 20,PIKACHU
	db 24,PIKACHU
	db 23,MAGNEMITE
	db 23,VOLTORB
	db 32,MAGNETON
	db 35,MAGNETON
	db 33,ELECTABUZZ
	db 36,ELECTABUZZ

	db $00

Route23Mons:
	db $0A
	db 26,EKANS
	db 33,DITTO
	db 26,SPEAROW
	db 38,FEAROW
	db 38,DITTO
	db 38,FEAROW
	db 41,ARBOK
	db 43,DITTO
	db 41,FEAROW
	db 43,FEAROW

	db $00

PlateauMons2:
	db $0A
	db 22,MACHOP
	db 24,GEODUDE
	db 26,ZUBAT
	db 36,ONIX
	db 39,ONIX
	db 42,ONIX
	db 41,MACHOKE
	db 40,GOLBAT
	db 40,MAROWAK
	db 43,GRAVELER

	db $00

PlateauMons3:
	db $0F
	db 24,MACHOP
	db 26,GEODUDE
	db 22,ZUBAT
	db 42,ONIX
	db 40,VENOMOTH
	db 45,ONIX
	db 43,GRAVELER
	db 41,GOLBAT
	db 42,MACHOKE
	db 45,MACHOKE

	db $00

PlateauMons1:
	db $0F
	db 24,MACHOP
	db 26,GEODUDE
	db 22,ZUBAT
	db 36,ONIX
	db 39,ONIX
	db 42,ONIX
	db 41,GRAVELER
	db 41,GOLBAT
	db 42,MACHOKE
	db 43,MAROWAK

	db $00

CaveMons:
	db $14
	db 18,DIGLETT
	db 19,DIGLETT
	db 17,DIGLETT
	db 20,DIGLETT
	db 16,DIGLETT
	db 15,DIGLETT
	db 21,DIGLETT
	db 22,DIGLETT
	db 29,DUGTRIO
	db 31,DUGTRIO

	db $00

ENDC
IF _GREEN || !_JAPAN && _BLUE
NoMons:
	db $00

	db $00

Route1Mons:
	db $19
	db 3,PIDGEY
	db 3,RATTATA
	db 3,RATTATA
	db 2,RATTATA
	db 2,PIDGEY
	db 3,PIDGEY
	db 3,PIDGEY
	db 4,RATTATA
	db 4,PIDGEY
	db 5,PIDGEY

	db $00

Route2Mons:
	db $19
	db 3,RATTATA
	db 3,PIDGEY
	db 4,PIDGEY
	db 4,RATTATA
	db 5,PIDGEY
	db 3,CATERPIE
	db 2,RATTATA
	db 5,RATTATA
	db 4,CATERPIE
	db 5,CATERPIE

	db $00

Route22Mons:
	db $19
	db 3,RATTATA
	db 3,NIDORAN_F
	db 4,RATTATA
	db 4,NIDORAN_F
	db 2,RATTATA
	db 2,NIDORAN_F
	db 3,SPEAROW
	db 5,SPEAROW
	db 3,NIDORAN_M
	db 4,NIDORAN_M

	db $00

ForestMons:
	db $08
	db 4,CATERPIE
	db 5,METAPOD
	db 3,CATERPIE
	db 5,CATERPIE
	db 4,METAPOD
	db 6,METAPOD
	db 4,KAKUNA
	db 3,WEEDLE
	db 3,PIKACHU
	db 5,PIKACHU

	db $00

Route3Mons:
	db $14
	db 6,PIDGEY
	db 5,SPEAROW
	db 7,PIDGEY
	db 6,SPEAROW
	db 7,SPEAROW
	db 8,PIDGEY
	db 8,SPEAROW
	db 3,JIGGLYPUFF
	db 5,JIGGLYPUFF
	db 7,JIGGLYPUFF

	db $00

MoonMons1:
	db $0A
	db 8,ZUBAT
	db 7,ZUBAT
	db 9,ZUBAT
	db 8,GEODUDE
	db 6,ZUBAT
	db 10,ZUBAT
	db 10,GEODUDE
	db 8,PARAS
	db 11,ZUBAT
	db 8,CLEFAIRY

	db $00

MoonMonsB1:
	db $0A
	db 8,ZUBAT
	db 7,ZUBAT
	db 7,GEODUDE
	db 8,GEODUDE
	db 9,ZUBAT
	db 10,PARAS
	db 10,ZUBAT
	db 11,ZUBAT
	db 9,CLEFAIRY
	db 9,GEODUDE

	db $00

MoonMonsB2:
	db $0A
	db 9,ZUBAT
	db 9,GEODUDE
	db 10,ZUBAT
	db 10,GEODUDE
	db 11,ZUBAT
	db 10,PARAS
	db 12,PARAS
	db 10,CLEFAIRY
	db 12,ZUBAT
	db 12,CLEFAIRY

	db $00

Route4Mons:
	db $14
	db 10,RATTATA
	db 10,SPEAROW
	db 8,RATTATA
	db 6,SANDSHREW
	db 8,SPEAROW
	db 10,SANDSHREW
	db 12,RATTATA
	db 12,SPEAROW
	db 8,SANDSHREW
	db 12,SANDSHREW

	db $00

Route24Mons:
	db $19
	db 7,CATERPIE
	db 8,METAPOD
	db 12,PIDGEY
	db 12,BELLSPROUT
	db 13,BELLSPROUT
	db 10,ABRA
	db 14,BELLSPROUT
	db 13,PIDGEY
	db 8,ABRA
	db 12,ABRA

	db $00

Route25Mons:
	db $0F
	db 8,CATERPIE
	db 9,METAPOD
	db 13,PIDGEY
	db 12,BELLSPROUT
	db 13,BELLSPROUT
	db 12,ABRA
	db 14,BELLSPROUT
	db 10,ABRA
	db 7,KAKUNA
	db 8,WEEDLE

	db $00

Route9Mons:
	db $0F
	db 16,RATTATA
	db 16,SPEAROW
	db 14,RATTATA
	db 11,SANDSHREW
	db 13,SPEAROW
	db 15,SANDSHREW
	db 17,RATTATA
	db 17,SPEAROW
	db 13,SANDSHREW
	db 17,SANDSHREW

	db $00

Route5Mons:
	db $0F
	db 13,BELLSPROUT
	db 13,PIDGEY
	db 15,PIDGEY
	db 10,MEOWTH
	db 12,MEOWTH
	db 15,BELLSPROUT
	db 16,BELLSPROUT
	db 16,PIDGEY
	db 14,MEOWTH
	db 16,MEOWTH

	db $00

Route6Mons:
	db $0F
	db 13,BELLSPROUT
	db 13,PIDGEY
	db 15,PIDGEY
	db 10,MEOWTH
	db 12,MEOWTH
	db 15,BELLSPROUT
	db 16,BELLSPROUT
	db 16,PIDGEY
	db 14,MEOWTH
	db 16,MEOWTH

	db $00

Route11Mons:
	db $0F
	db 14,SANDSHREW
	db 15,SPEAROW
	db 12,SANDSHREW
	db 9,DROWZEE
	db 13,SPEAROW
	db 13,DROWZEE
	db 15,SANDSHREW
	db 17,SPEAROW
	db 11,DROWZEE
	db 15,DROWZEE

	db $00

TunnelMonsB1:
	db $0F
	db 16,ZUBAT
	db 17,ZUBAT
	db 17,GEODUDE
	db 15,MACHOP
	db 16,GEODUDE
	db 18,ZUBAT
	db 15,ZUBAT
	db 17,MACHOP
	db 13,ONIX
	db 15,ONIX

	db $00

TunnelMonsB2:
	db $0F
	db 16,ZUBAT
	db 17,ZUBAT
	db 17,GEODUDE
	db 15,MACHOP
	db 16,GEODUDE
	db 18,ZUBAT
	db 17,MACHOP
	db 17,ONIX
	db 13,ONIX
	db 18,GEODUDE

	db $00

Route10Mons:
	db $0F
	db 16,VOLTORB
	db 16,SPEAROW
	db 14,VOLTORB
	db 11,SANDSHREW
	db 13,SPEAROW
	db 15,SANDSHREW
	db 17,VOLTORB
	db 17,SPEAROW
	db 13,SANDSHREW
	db 17,SANDSHREW

	db $00

Route12Mons:
	db $0F
	db 24,BELLSPROUT
	db 25,PIDGEY
	db 23,PIDGEY
	db 24,VENONAT
	db 22,BELLSPROUT
	db 26,VENONAT
	db 26,BELLSPROUT
	db 27,PIDGEY
	db 28,WEEPINBELL
	db 30,WEEPINBELL

	db $00

Route8Mons:
	db $0F
	db 18,PIDGEY
	db 18,MEOWTH
	db 17,SANDSHREW
	db 16,VULPIX
	db 20,PIDGEY
	db 20,MEOWTH
	db 19,SANDSHREW
	db 17,VULPIX
	db 15,VULPIX
	db 18,VULPIX

	db $00

Route7Mons:
	db $0F
	db 19,PIDGEY
	db 19,BELLSPROUT
	db 17,MEOWTH
	db 22,BELLSPROUT
	db 22,PIDGEY
	db 18,MEOWTH
	db 18,VULPIX
	db 20,VULPIX
	db 19,MEOWTH
	db 20,MEOWTH

	db $00

TowerMons1:
	db $00

	db $00

TowerMons2:
	db $00

	db $00

TowerMons3:
	db $0A
	db 20,GASTLY
	db 21,GASTLY
	db 22,GASTLY
	db 23,GASTLY
	db 19,GASTLY
	db 18,GASTLY
	db 24,GASTLY
	db 20,CUBONE
	db 22,CUBONE
	db 25,HAUNTER

	db $00

TowerMons4:
	db $0A
	db 20,GASTLY
	db 21,GASTLY
	db 22,GASTLY
	db 23,GASTLY
	db 19,GASTLY
	db 18,GASTLY
	db 25,HAUNTER
	db 20,CUBONE
	db 22,CUBONE
	db 24,GASTLY

	db $00

TowerMons5:
	db $0A
	db 20,GASTLY
	db 21,GASTLY
	db 22,GASTLY
	db 23,GASTLY
	db 19,GASTLY
	db 18,GASTLY
	db 25,HAUNTER
	db 20,CUBONE
	db 22,CUBONE
	db 24,GASTLY

	db $00

TowerMons6:
	db $0F
	db 21,GASTLY
	db 22,GASTLY
	db 23,GASTLY
	db 24,GASTLY
	db 20,GASTLY
	db 19,GASTLY
	db 26,HAUNTER
	db 22,CUBONE
	db 24,CUBONE
	db 28,HAUNTER

	db $00

TowerMons7:
	db $0F
	db 21,GASTLY
	db 22,GASTLY
	db 23,GASTLY
	db 24,GASTLY
	db 20,GASTLY
	db 28,HAUNTER
	db 22,CUBONE
	db 24,CUBONE
	db 28,HAUNTER
	db 30,HAUNTER

	db $00

Route13Mons:
	db $14
	db 24,BELLSPROUT
	db 25,PIDGEY
	db 27,PIDGEY
	db 24,VENONAT
	db 22,BELLSPROUT
	db 26,VENONAT
	db 26,BELLSPROUT
	db 25,DITTO
	db 28,WEEPINBELL
	db 30,WEEPINBELL

	db $00

Route14Mons:
	db $0F
	db 24,BELLSPROUT
	db 26,PIDGEY
	db 23,DITTO
	db 24,VENONAT
	db 22,BELLSPROUT
	db 26,VENONAT
	db 26,BELLSPROUT
	db 30,WEEPINBELL
	db 28,PIDGEOTTO
	db 30,PIDGEOTTO

	db $00

Route15Mons:
	db $0F
	db 24,BELLSPROUT
	db 26,DITTO
	db 23,PIDGEY
	db 26,VENONAT
	db 22,BELLSPROUT
	db 28,VENONAT
	db 26,BELLSPROUT
	db 30,WEEPINBELL
	db 28,PIDGEOTTO
	db 30,PIDGEOTTO

	db $00

Route16Mons:
	db $19
	db 20,SPEAROW
	db 22,SPEAROW
	db 18,RATTATA
	db 20,DODUO
	db 20,RATTATA
	db 18,DODUO
	db 22,DODUO
	db 22,RATTATA
	db 23,RATICATE
	db 25,RATICATE

	db $00

Route17Mons:
	db $19
	db 20,SPEAROW
	db 22,SPEAROW
	db 25,RATICATE
	db 24,DODUO
	db 27,RATICATE
	db 26,DODUO
	db 28,DODUO
	db 29,RATICATE
	db 25,FEAROW
	db 27,FEAROW

	db $00

Route18Mons:
	db $19
	db 20,SPEAROW
	db 22,SPEAROW
	db 25,RATICATE
	db 24,DODUO
	db 25,FEAROW
	db 26,DODUO
	db 28,DODUO
	db 29,RATICATE
	db 27,FEAROW
	db 29,FEAROW

	db $00

ZoneMonsCenter:
	db $1E
	db 22,NIDORAN_F
	db 25,RHYHORN
	db 22,VENONAT
	db 24,EXEGGCUTE
	db 31,NIDORINA
	db 25,EXEGGCUTE
	db 31,NIDORINO
	db 30,PARASECT
	db 23,PINSIR
	db 23,CHANSEY

	db $00

ZoneMons1:
	db $1E
	db 24,NIDORAN_F
	db 26,DODUO
	db 22,PARAS
	db 25,EXEGGCUTE
	db 33,NIDORINA
	db 23,EXEGGCUTE
	db 24,NIDORAN_M
	db 25,PARASECT
	db 25,KANGASKHAN
	db 28,PINSIR

	db $00

ZoneMons2:
	db $1E
	db 22,NIDORAN_F
	db 26,RHYHORN
	db 23,PARAS
	db 25,EXEGGCUTE
	db 30,NIDORINA
	db 27,EXEGGCUTE
	db 30,NIDORINO
	db 32,VENOMOTH
	db 26,CHANSEY
	db 28,TAUROS

	db $00

ZoneMons3:
	db $1E
	db 25,NIDORAN_F
	db 26,DODUO
	db 23,VENONAT
	db 24,EXEGGCUTE
	db 33,NIDORINA
	db 26,EXEGGCUTE
	db 25,NIDORAN_M
	db 31,VENOMOTH
	db 26,TAUROS
	db 28,KANGASKHAN

	db $00

WaterMons:
	db $00

	db $05
	db 5,TENTACOOL
	db 10,TENTACOOL
	db 15,TENTACOOL
	db 5,TENTACOOL
	db 10,TENTACOOL
	db 15,TENTACOOL
	db 20,TENTACOOL
	db 30,TENTACOOL
	db 35,TENTACOOL
	db 40,TENTACOOL

IslandMons1:
	db $0F
	db 30,SEEL
	db 30,PSYDUCK
	db 30,STARYU
	db 30,KRABBY
	db 28,KRABBY
	db 21,ZUBAT
	db 29,GOLBAT
	db 28,SLOWPOKE
	db 28,STARYU
	db 38,SLOWBRO

	db $00

IslandMonsB1:
	db $0A
	db 30,SHELLDER
	db 30,KRABBY
	db 32,STARYU
	db 32,KRABBY
	db 28,PSYDUCK
	db 30,SEEL
	db 30,PSYDUCK
	db 28,SEEL
	db 38,DEWGONG
	db 37,KINGLER

	db $00

IslandMonsB2:
	db $0A
	db 30,SEEL
	db 30,PSYDUCK
	db 32,SEEL
	db 32,PSYDUCK
	db 28,KRABBY
	db 30,SHELLDER
	db 30,KRABBY
	db 28,STARYU
	db 30,GOLBAT
	db 37,GOLDUCK

	db $00

IslandMonsB3:
	db $0A
	db 31,PSYDUCK
	db 31,SEEL
	db 33,PSYDUCK
	db 33,SEEL
	db 29,KRABBY
	db 31,STARYU
	db 31,KRABBY
	db 29,STARYU
	db 39,KINGLER
	db 37,DEWGONG

	db $00

IslandMonsB4:
	db $0A
	db 31,KRABBY
	db 31,STARYU
	db 33,KRABBY
	db 33,STARYU
	db 29,PSYDUCK
	db 31,SEEL
	db 31,PSYDUCK
	db 29,SEEL
	db 39,GOLDUCK
	db 32,GOLBAT

	db $00

MansionMons1:
	db $0A
	db 32,GRIMER
	db 30,GRIMER
	db 34,PONYTA
	db 30,PONYTA
	db 34,VULPIX
	db 32,PONYTA
	db 30,KOFFING
	db 28,PONYTA
	db 37,MUK
	db 39,WEEZING

	db $00

MansionMons2:
	db $0A
	db 32,VULPIX
	db 34,GRIMER
	db 34,GRIMER
	db 30,PONYTA
	db 30,GRIMER
	db 32,PONYTA
	db 30,KOFFING
	db 28,PONYTA
	db 39,MUK
	db 37,WEEZING

	db $00

MansionMons3:
	db $0A
	db 31,GRIMER
	db 33,VULPIX
	db 35,GRIMER
	db 32,PONYTA
	db 34,MAGMAR
	db 40,MUK
	db 34,KOFFING
	db 38,MUK
	db 36,PONYTA
	db 42,WEEZING

	db $00

MansionMonsB1:
	db $0A
	db 33,GRIMER
	db 31,GRIMER
	db 35,VULPIX
	db 32,PONYTA
	db 31,GRIMER
	db 40,MUK
	db 34,PONYTA
	db 35,KOFFING
	db 38,MAGMAR
	db 42,WEEZING

	db $00

Route21Mons:
	db $19
	db 21,RATTATA
	db 23,PIDGEY
	db 30,RATICATE
	db 23,RATTATA
	db 21,PIDGEY
	db 30,PIDGEOTTO
	db 32,PIDGEOTTO
	db 28,TANGELA
	db 30,TANGELA
	db 32,TANGELA

	db $05
	db 5,TENTACOOL
	db 10,TENTACOOL
	db 15,TENTACOOL
	db 5,TENTACOOL
	db 10,TENTACOOL
	db 15,TENTACOOL
	db 20,TENTACOOL
	db 30,TENTACOOL
	db 35,TENTACOOL
	db 40,TENTACOOL

DungeonMons1:
	db $0A
	db 46,GOLBAT
	db 46,HYPNO
	db 46,MAGNETON
	db 49,DODRIO
	db 49,VENOMOTH
	db 52,SANDSLASH
	db 49,KADABRA
	db 52,PARASECT
	db 53,RAICHU
	db 53,DITTO

	db $00

DungeonMons2:
	db $0F
	db 51,DODRIO
	db 51,VENOMOTH
	db 51,KADABRA
	db 52,RHYDON
	db 52,MAROWAK
	db 52,ELECTRODE
	db 56,CHANSEY
	db 54,WIGGLYTUFF
	db 55,DITTO
	db 60,DITTO

	db $00

DungeonMonsB1:
	db $19
	db 55,RHYDON
	db 55,MAROWAK
	db 55,ELECTRODE
	db 64,CHANSEY
	db 64,PARASECT
	db 64,RAICHU
	db 57,SANDSLASH
	db 65,DITTO
	db 63,DITTO
	db 67,DITTO

	db $00

PowerPlantMons:
	db $0A
	db 21,VOLTORB
	db 21,MAGNEMITE
	db 20,PIKACHU
	db 24,PIKACHU
	db 23,MAGNEMITE
	db 23,VOLTORB
	db 32,MAGNETON
	db 35,MAGNETON
	db 33,RAICHU
	db 36,RAICHU

	db $00

Route23Mons:
	db $0A
	db 26,SANDSHREW
	db 33,DITTO
	db 26,SPEAROW
	db 38,FEAROW
	db 38,DITTO
	db 38,FEAROW
	db 41,SANDSLASH
	db 43,DITTO
	db 41,FEAROW
	db 43,FEAROW

	db $00

PlateauMons2:
	db $0A
	db 22,MACHOP
	db 24,GEODUDE
	db 26,ZUBAT
	db 36,ONIX
	db 39,ONIX
	db 42,ONIX
	db 41,MACHOKE
	db 40,GOLBAT
	db 40,MAROWAK
	db 43,GRAVELER

	db $00

PlateauMons3:
	db $0F
	db 24,MACHOP
	db 26,GEODUDE
	db 22,ZUBAT
	db 42,ONIX
	db 40,VENOMOTH
	db 45,ONIX
	db 43,GRAVELER
	db 41,GOLBAT
	db 42,MACHOKE
	db 45,MACHOKE

	db $00

PlateauMons1:
	db $0F
	db 24,MACHOP
	db 26,GEODUDE
	db 22,ZUBAT
	db 36,ONIX
	db 39,ONIX
	db 42,ONIX
	db 41,GRAVELER
	db 41,GOLBAT
	db 42,MACHOKE
	db 43,MAROWAK

	db $00

CaveMons:
	db $14
	db 18,DIGLETT
	db 19,DIGLETT
	db 17,DIGLETT
	db 20,DIGLETT
	db 16,DIGLETT
	db 15,DIGLETT
	db 21,DIGLETT
	db 22,DIGLETT
	db 29,DUGTRIO
	db 31,DUGTRIO

	db $00

ENDC
IF _JAPAN && _BLUE
NoMons:
	db $00

	db $00

Route1Mons:
	db $19
	db 3,PIDGEY
	db 3,RATTATA
	db 3,RATTATA
	db 2,RATTATA
	db 2,PIDGEY
	db 3,PIDGEY
	db 3,PIDGEY
	db 4,RATTATA
	db 4,PIDGEY
	db 5,PIDGEY

	db $00

Route2Mons:
	db $19
	db 3,RATTATA
	db 3,PIDGEY
	db 4,PIDGEY
	db 4,RATTATA
	db 5,PIDGEY
	db 3,CATERPIE
	db 2,RATTATA
	db 5,RATTATA
	db 4,CATERPIE
	db 5,CATERPIE

	db $00

Route22Mons:
	db $19
	db 3,RATTATA
	db 3,NIDORAN_M
	db 4,RATTATA
	db 4,NIDORAN_M
	db 2,RATTATA
	db 2,NIDORAN_M
	db 3,SPEAROW
	db 5,SPEAROW
	db 3,NIDORAN_F
	db 4,NIDORAN_F

	db $00

ForestMons:
	db $08
	db 4,CATERPIE
	db 5,METAPOD
	db 3,CATERPIE
	db 5,CATERPIE
	db 4,METAPOD
	db 6,METAPOD
	db 4,KAKUNA
	db 3,WEEDLE
	db 3,PIKACHU
	db 5,PIKACHU

	db $00

Route3Mons:
	db $14
	db 6,PIDGEY
	db 5,SPEAROW
	db 7,PIDGEY
	db 6,SPEAROW
	db 7,SPEAROW
	db 8,PIDGEY
	db 8,SPEAROW
	db 3,JIGGLYPUFF
	db 5,JIGGLYPUFF
	db 7,JIGGLYPUFF

	db $00

MoonMons1:
	db $0A
	db 8,ZUBAT
	db 7,ZUBAT
	db 9,ZUBAT
	db 8,GEODUDE
	db 6,ZUBAT
	db 10,ZUBAT
	db 10,GEODUDE
	db 8,PARAS
	db 11,ZUBAT
	db 8,CLEFAIRY

	db $00

MoonMonsB1:
	db $0A
	db 8,ZUBAT
	db 7,ZUBAT
	db 7,GEODUDE
	db 8,GEODUDE
	db 9,ZUBAT
	db 10,PARAS
	db 10,ZUBAT
	db 11,ZUBAT
	db 9,CLEFAIRY
	db 9,GEODUDE

	db $00

MoonMonsB2:
	db $0A
	db 9,ZUBAT
	db 9,GEODUDE
	db 10,ZUBAT
	db 10,GEODUDE
	db 11,ZUBAT
	db 10,PARAS
	db 12,PARAS
	db 10,CLEFAIRY
	db 12,ZUBAT
	db 12,CLEFAIRY

	db $00

Route4Mons:
	db $14
	db 10,RATTATA
	db 10,SPEAROW
	db 8,RATTATA
	db 6,SANDSHREW
	db 8,SPEAROW
	db 10,SANDSHREW
	db 12,RATTATA
	db 12,SPEAROW
	db 8,SANDSHREW
	db 12,SANDSHREW

	db $00

Route24Mons:
	db $19
	db 7,CATERPIE
	db 8,METAPOD
	db 12,PIDGEY
	db 12,ODDISH
	db 13,ODDISH
	db 10,ABRA
	db 14,ODDISH
	db 13,PIDGEY
	db 8,ABRA
	db 12,ABRA

	db $00

Route25Mons:
	db $0F
	db 8,CATERPIE
	db 9,METAPOD
	db 13,PIDGEY
	db 12,ODDISH
	db 13,ODDISH
	db 12,ABRA
	db 14,ODDISH
	db 10,ABRA
	db 7,KAKUNA
	db 8,WEEDLE

	db $00

Route9Mons:
	db $0F
	db 16,RATTATA
	db 16,SPEAROW
	db 14,RATTATA
	db 11,SANDSHREW
	db 13,SPEAROW
	db 15,SANDSHREW
	db 17,RATTATA
	db 17,SPEAROW
	db 13,SANDSHREW
	db 17,SANDSHREW

	db $00

Route5Mons:
	db $0F
	db 13,ODDISH
	db 13,PIDGEY
	db 15,PIDGEY
	db 10,MEOWTH
	db 12,MEOWTH
	db 15,ODDISH
	db 16,ODDISH
	db 16,PIDGEY
	db 14,MEOWTH
	db 16,MEOWTH

	db $00

Route6Mons:
	db $0F
	db 13,ODDISH
	db 13,PIDGEY
	db 15,PIDGEY
	db 10,MEOWTH
	db 12,MEOWTH
	db 15,ODDISH
	db 16,ODDISH
	db 16,PIDGEY
	db 14,MEOWTH
	db 16,MEOWTH

	db $00

Route11Mons:
	db $0F
	db 14,SANDSHREW
	db 15,SPEAROW
	db 12,SANDSHREW
	db 9,DROWZEE
	db 13,SPEAROW
	db 13,DROWZEE
	db 15,SANDSHREW
	db 17,SPEAROW
	db 11,DROWZEE
	db 15,DROWZEE

	db $00

TunnelMonsB1:
	db $0F
	db 16,ZUBAT
	db 17,ZUBAT
	db 17,GEODUDE
	db 15,MACHOP
	db 16,GEODUDE
	db 18,DITTO
	db 15,ZUBAT
	db 17,MACHOP
	db 13,ONIX
	db 15,ONIX

	db $00

TunnelMonsB2:
	db $0F
	db 16,ZUBAT
	db 17,ZUBAT
	db 17,GEODUDE
	db 15,MACHOP
	db 16,GEODUDE
	db 18,DITTO
	db 17,MACHOP
	db 17,ONIX
	db 13,ONIX
	db 18,GEODUDE

	db $00

Route10Mons:
	db $0F
	db 16,VOLTORB
	db 16,SPEAROW
	db 14,VOLTORB
	db 11,SANDSHREW
	db 13,SPEAROW
	db 15,SANDSHREW
	db 17,VOLTORB
	db 17,SPEAROW
	db 13,SANDSHREW
	db 17,SANDSHREW

	db $00

Route12Mons:
	db $0F
	db 24,ODDISH
	db 25,PIDGEY
	db 23,PIDGEY
	db 24,VENONAT
	db 22,ODDISH
	db 26,VENONAT
	db 26,ODDISH
	db 27,PIDGEY
	db 28,GLOOM
	db 30,GLOOM

	db $00

Route8Mons:
	db $0F
	db 18,PIDGEY
	db 18,MEOWTH
	db 17,SANDSHREW
	db 16,GROWLITHE
	db 20,PIDGEY
	db 20,MEOWTH
	db 19,SANDSHREW
	db 17,GROWLITHE
	db 15,GROWLITHE
	db 18,GROWLITHE

	db $00

Route7Mons:
	db $0F
	db 19,PIDGEY
	db 19,ODDISH
	db 17,MEOWTH
	db 22,ODDISH
	db 22,PIDGEY
	db 18,MEOWTH
	db 18,GROWLITHE
	db 20,GROWLITHE
	db 19,MEOWTH
	db 20,MEOWTH

	db $00

TowerMons1:
	db $00

	db $00

TowerMons2:
	db $00

	db $00

TowerMons3:
	db $0A
	db 20,GASTLY
	db 21,GASTLY
	db 22,GASTLY
	db 23,GASTLY
	db 19,GASTLY
	db 18,GASTLY
	db 24,GASTLY
	db 20,CUBONE
	db 22,CUBONE
	db 25,HAUNTER

	db $00

TowerMons4:
	db $0A
	db 20,GASTLY
	db 21,GASTLY
	db 22,GASTLY
	db 23,GASTLY
	db 19,GASTLY
	db 18,GASTLY
	db 25,HAUNTER
	db 20,CUBONE
	db 22,CUBONE
	db 24,GASTLY

	db $00

TowerMons5:
	db $0A
	db 20,GASTLY
	db 21,GASTLY
	db 22,GASTLY
	db 23,GASTLY
	db 19,GASTLY
	db 18,GASTLY
	db 25,HAUNTER
	db 20,CUBONE
	db 22,CUBONE
	db 24,GASTLY

	db $00

TowerMons6:
	db $0F
	db 21,GASTLY
	db 22,GASTLY
	db 23,GASTLY
	db 24,GASTLY
	db 20,GASTLY
	db 19,GASTLY
	db 26,HAUNTER
	db 22,CUBONE
	db 24,CUBONE
	db 28,HAUNTER

	db $00

TowerMons7:
	db $0F
	db 21,GASTLY
	db 22,GASTLY
	db 23,GASTLY
	db 24,GASTLY
	db 20,GASTLY
	db 28,HAUNTER
	db 22,CUBONE
	db 24,CUBONE
	db 28,HAUNTER
	db 30,HAUNTER

	db $00

Route13Mons:
	db $14
	db 24,ODDISH
	db 25,PIDGEY
	db 27,PIDGEY
	db 24,VENONAT
	db 22,ODDISH
	db 26,VENONAT
	db 26,ODDISH
	db 25,DITTO
	db 28,GLOOM
	db 30,GLOOM

	db $00

Route14Mons:
	db $0F
	db 24,ODDISH
	db 26,PIDGEY
	db 23,DITTO
	db 24,VENONAT
	db 22,ODDISH
	db 26,VENONAT
	db 26,ODDISH
	db 30,GLOOM
	db 28,PIDGEOTTO
	db 30,PIDGEOTTO

	db $00

Route15Mons:
	db $0F
	db 24,ODDISH
	db 26,DITTO
	db 23,PIDGEY
	db 26,VENONAT
	db 22,ODDISH
	db 28,VENONAT
	db 26,ODDISH
	db 30,GLOOM
	db 28,PIDGEOTTO
	db 30,PIDGEOTTO

	db $00

Route16Mons:
	db $19
	db 20,SPEAROW
	db 22,SPEAROW
	db 18,RATTATA
	db 20,DODUO
	db 20,RATTATA
	db 18,DODUO
	db 22,DODUO
	db 22,RATTATA
	db 23,RATICATE
	db 25,RATICATE

	db $00

Route17Mons:
	db $19
	db 20,SPEAROW
	db 22,SPEAROW
	db 25,RATICATE
	db 24,DODUO
	db 27,RATICATE
	db 26,DODUO
	db 28,DODUO
	db 29,RATICATE
	db 25,FEAROW
	db 27,FEAROW

	db $00

Route18Mons:
	db $19
	db 20,SPEAROW
	db 22,SPEAROW
	db 25,RATICATE
	db 24,DODUO
	db 25,FEAROW
	db 26,DODUO
	db 28,DODUO
	db 29,RATICATE
	db 27,FEAROW
	db 29,FEAROW

	db $00

ZoneMonsCenter:
	db $1E
	db 22,NIDORAN_M
	db 25,RHYHORN
	db 22,VENONAT
	db 24,EXEGGCUTE
	db 31,NIDORINO
	db 25,EXEGGCUTE
	db 31,NIDORINA
	db 30,PARASECT
	db 23,SCYTHER
	db 23,CHANSEY

	db $00

ZoneMons1:
	db $1E
	db 24,NIDORAN_M
	db 26,DODUO
	db 22,PARAS
	db 25,EXEGGCUTE
	db 33,NIDORINO
	db 23,EXEGGCUTE
	db 24,NIDORAN_F
	db 25,PARASECT
	db 25,LICKITUNG
	db 28,SCYTHER

	db $00

ZoneMons2:
	db $1E
	db 22,NIDORAN_M
	db 26,RHYHORN
	db 23,PARAS
	db 25,EXEGGCUTE
	db 30,NIDORINO
	db 27,EXEGGCUTE
	db 30,NIDORINA
	db 32,VENOMOTH
	db 26,CHANSEY
	db 28,PINSIR

	db $00

ZoneMons3:
	db $1E
	db 25,NIDORAN_M
	db 26,DODUO
	db 23,VENONAT
	db 24,EXEGGCUTE
	db 33,NIDORINO
	db 26,EXEGGCUTE
	db 25,NIDORAN_F
	db 31,VENOMOTH
	db 26,PINSIR
	db 28,LICKITUNG

	db $00

WaterMons:
	db $00

	db $05
	db 5,TENTACOOL
	db 10,TENTACOOL
	db 15,TENTACOOL
	db 5,TENTACOOL
	db 10,TENTACOOL
	db 15,TENTACOOL
	db 20,TENTACOOL
	db 30,TENTACOOL
	db 35,TENTACOOL
	db 40,TENTACOOL

WaterMons:
	db $00

	db $05
	db 5,TENTACOOL
	db 10,TENTACOOL
	db 15,TENTACOOL
	db 5,TENTACOOL
	db 10,TENTACOOL
	db 15,TENTACOOL
	db 20,TENTACOOL
	db 30,TENTACOOL
	db 35,TENTACOOL
	db 40,TENTACOOL

IslandMons1:
	db $0F
	db 30,SEEL
	db 30,HORSEA
	db 30,STARYU
	db 30,KRABBY
	db 28,KRABBY
	db 21,ZUBAT
	db 29,GOLBAT
	db 28,SLOWPOKE
	db 28,STARYU
	db 38,SLOWBRO

	db $00

IslandMonsB1:
	db $0A
	db 30,SHELLDER
	db 30,KRABBY
	db 32,STARYU
	db 32,KRABBY
	db 28,HORSEA
	db 30,SEEL
	db 30,HORSEA
	db 28,SEEL
	db 38,DEWGONG
	db 37,KINGLER

	db $00

IslandMonsB2:
	db $0A
	db 30,SEEL
	db 30,HORSEA
	db 32,SEEL
	db 32,HORSEA
	db 28,KRABBY
	db 30,SHELLDER
	db 30,KRABBY
	db 28,STARYU
	db 30,GOLBAT
	db 37,JYNX

	db $00

IslandMonsB3:
	db $0A
	db 31,HORSEA
	db 31,SEEL
	db 33,HORSEA
	db 33,SEEL
	db 29,KRABBY
	db 31,STARYU
	db 31,KRABBY
	db 29,STARYU
	db 39,KINGLER
	db 37,DEWGONG

	db $00

IslandMonsB4:
	db $0A
	db 31,KRABBY
	db 31,STARYU
	db 33,KRABBY
	db 33,STARYU
	db 29,HORSEA
	db 31,SEEL
	db 31,HORSEA
	db 29,SEEL
	db 39,JYNX
	db 32,GOLBAT

	db $00

MansionMons1:
	db $0A
	db 32,GRIMER
	db 30,GRIMER
	db 34,PONYTA
	db 30,PONYTA
	db 34,GROWLITHE
	db 32,PONYTA
	db 30,KOFFING
	db 28,PONYTA
	db 37,MUK
	db 39,WEEZING

	db $00

MansionMons2:
	db $0A
	db 32,GROWLITHE
	db 34,GRIMER
	db 34,GRIMER
	db 30,PONYTA
	db 30,GRIMER
	db 32,PONYTA
	db 30,KOFFING
	db 28,PONYTA
	db 39,MUK
	db 37,WEEZING

	db $00

MansionMons3:
	db $0A
	db 31,GRIMER
	db 33,GROWLITHE
	db 35,GRIMER
	db 32,PONYTA
	db 34,PONYTA
	db 40,MUK
	db 34,KOFFING
	db 38,MUK
	db 36,PONYTA
	db 42,WEEZING

	db $00

MansionMonsB1:
	db $0A
	db 33,GRIMER
	db 31,GRIMER
	db 35,GROWLITHE
	db 32,PONYTA
	db 31,GRIMER
	db 40,MUK
	db 34,PONYTA
	db 35,KOFFING
	db 38,MUK
	db 42,WEEZING

	db $00

Route21Mons:
	db $19
	db 21,RATTATA
	db 23,PIDGEY
	db 30,RATICATE
	db 23,RATTATA
	db 21,PIDGEY
	db 30,PIDGEOTTO
	db 32,PIDGEOTTO
	db 28,TANGELA
	db 30,TANGELA
	db 32,TANGELA

	db $05
	db 5,TENTACOOL
	db 10,TENTACOOL
	db 15,TENTACOOL
	db 5,TENTACOOL
	db 10,TENTACOOL
	db 15,TENTACOOL
	db 20,TENTACOOL
	db 30,TENTACOOL
	db 35,TENTACOOL
	db 40,TENTACOOL

DungeonMons1:
	db $0A
	db 46,GOLBAT
	db 46,HYPNO
	db 46,MAGNETON
	db 49,RAPIDASH
	db 49,VENOMOTH
	db 52,SANDSLASH
	db 49,KADABRA
	db 52,PARASECT
	db 53,RAICHU
	db 53,DITTO

	db $00

DungeonMons2:
	db $0F
	db 51,DODRIO
	db 51,VENOMOTH
	db 51,KADABRA
	db 52,RHYDON
	db 52,RATICATE
	db 52,ELECTRODE
	db 56,CHANSEY
	db 54,WIGGLYTUFF
	db 55,DITTO
	db 60,DITTO

	db $00

DungeonMonsB1:
	db $19
	db 55,RHYDON
	db 55,MAROWAK
	db 55,ELECTRODE
	db 64,CLEFAIRY
	db 64,PARASECT
	db 64,RAICHU
	db 57,SANDSLASH
	db 65,DITTO
	db 63,DITTO
	db 67,DITTO

	db $00

PowerPlantMons:
	db $0A
	db 21,VOLTORB
	db 21,MAGNEMITE
	db 20,PIKACHU
	db 24,PIKACHU
	db 23,MAGNEMITE
	db 23,VOLTORB
	db 32,MAGNETON
	db 35,MAGNETON
	db 33,RAICHU
	db 36,RAICHU

	db $00

Route23Mons:
	db $0A
	db 26,SANDSHREW
	db 33,DITTO
	db 26,SPEAROW
	db 38,FEAROW
	db 38,DITTO
	db 38,FEAROW
	db 41,SANDSLASH
	db 43,DITTO
	db 41,FEAROW
	db 43,FEAROW

	db $00

PlateauMons2:
	db $0A
	db 22,MACHOP
	db 24,GEODUDE
	db 26,ZUBAT
	db 36,ONIX
	db 39,ONIX
	db 42,ONIX
	db 41,MACHOKE
	db 40,GOLBAT
	db 40,MAROWAK
	db 43,GRAVELER

	db $00

PlateauMons3:
	db $0F
	db 24,MACHOP
	db 26,GEODUDE
	db 22,ZUBAT
	db 42,ONIX
	db 40,VENOMOTH
	db 45,ONIX
	db 43,GRAVELER
	db 41,GOLBAT
	db 42,MACHOKE
	db 45,MACHOKE

	db $00

PlateauMons1:
	db $0F
	db 24,MACHOP
	db 26,GEODUDE
	db 22,ZUBAT
	db 36,ONIX
	db 39,ONIX
	db 42,ONIX
	db 41,GRAVELER
	db 41,GOLBAT
	db 42,MACHOKE
	db 43,MAROWAK

	db $00

CaveMons:
	db $14
	db 18,DIGLETT
	db 19,DIGLETT
	db 17,DIGLETT
	db 20,DIGLETT
	db 16,DIGLETT
	db 15,DIGLETT
	db 21,DIGLETT
	db 22,DIGLETT
	db 29,DUGTRIO
	db 31,DUGTRIO

	db $00

ENDC
IF _YELLOW
NoMons:
	db $00

	db $00

Route1Mons:
	db $19
	db 3,PIDGEY
	db 4,PIDGEY
	db 2,RATTATA
	db 3,RATTATA
	db 2,PIDGEY
	db 3,PIDGEY
	db 5,PIDGEY
	db 4,RATTATA
	db 6,PIDGEY
	db 7,PIDGEY

	db $00

Route2Mons:
	db $19
	db 3,RATTATA
	db 3,PIDGEY
	db 4,RATTATA
	db 4,NIDORAN_M
	db 4,NIDORAN_F
	db 5,PIDGEY
	db 6,NIDORAN_M
	db 6,NIDORAN_F
	db 7,PIDGEY
	db 7,PIDGEY

	db $00

Route22Mons:
	db $19
	db 2,NIDORAN_M
	db 2,NIDORAN_F
	db 3,MANKEY
	db 3,RATTATA
	db 4,NIDORAN_M
	db 4,NIDORAN_F
	db 5,MANKEY
	db 2,SPEAROW
	db 4,SPEAROW
	db 6,SPEAROW

	db $00

ForestMons:
	db $19
	db 3,CATERPIE
	db 4,METAPOD
	db 4,CATERPIE
	db 5,CATERPIE
	db 4,PIDGEY
	db 6,PIDGEY
	db 6,CATERPIE
	db 6,METAPOD
	db 8,PIDGEY
	db 9,PIDGEOTTO

	db $00

Route3Mons:
	db $14
	db 8,SPEAROW
	db 9,SPEAROW
	db 9,MANKEY
	db 10,SPEAROW
	db 8,SANDSHREW
	db 10,RATTATA
	db 10,SANDSHREW
	db 12,RATTATA
	db 11,SPEAROW
	db 12,SPEAROW

	db $00

MoonMons1:
	db $0A
	db 8,ZUBAT
	db 9,ZUBAT
	db 10,GEODUDE
	db 6,ZUBAT
	db 7,ZUBAT
	db 10,ZUBAT
	db 10,GEODUDE
	db 11,ZUBAT
	db 12,SANDSHREW
	db 11,CLEFAIRY

	db $00

MoonMonsB1:
	db $0A
	db 8,ZUBAT
	db 9,ZUBAT
	db 10,ZUBAT
	db 10,GEODUDE
	db 11,GEODUDE
	db 11,ZUBAT
	db 9,PARAS
	db 11,PARAS
	db 10,CLEFAIRY
	db 12,CLEFAIRY

	db $00

MoonMonsB2:
	db $0A
	db 10,ZUBAT
	db 11,GEODUDE
	db 13,PARAS
	db 11,ZUBAT
	db 11,ZUBAT
	db 12,ZUBAT
	db 13,ZUBAT
	db 9,CLEFAIRY
	db 11,CLEFAIRY
	db 13,CLEFAIRY

	db $00

Route4Mons:
	db $14
	db 8,SPEAROW
	db 9,SPEAROW
	db 9,MANKEY
	db 10,SPEAROW
	db 8,SANDSHREW
	db 10,RATTATA
	db 10,SANDSHREW
	db 12,RATTATA
	db 11,SPEAROW
	db 12,SPEAROW

	db $00

Route24Mons:
	db $19
	db 12,ODDISH
	db 12,BELLSPROUT
	db 13,PIDGEY
	db 14,ODDISH
	db 14,BELLSPROUT
	db 15,PIDGEY
	db 13,VENONAT
	db 16,VENONAT
	db 17,PIDGEY
	db 17,PIDGEOTTO

	db $00

Route25Mons:
	db $0F
	db 12,ODDISH
	db 12,BELLSPROUT
	db 13,PIDGEY
	db 14,ODDISH
	db 14,BELLSPROUT
	db 15,PIDGEY
	db 13,VENONAT
	db 16,VENONAT
	db 17,PIDGEY
	db 17,PIDGEOTTO

	db $00

Route9Mons:
	db $0F
	db 16,NIDORAN_M
	db 16,NIDORAN_F
	db 18,RATTATA
	db 18,NIDORAN_M
	db 18,NIDORAN_F
	db 17,SPEAROW
	db 18,NIDORINO
	db 18,NIDORINA
	db 20,RATICATE
	db 19,FEAROW

	db $00

Route5Mons:
	db $0F
	db 15,PIDGEY
	db 14,RATTATA
	db 7,ABRA
	db 16,PIDGEY
	db 16,RATTATA
	db 17,PIDGEY
	db 17,PIDGEOTTO
	db 3,JIGGLYPUFF
	db 5,JIGGLYPUFF
	db 7,JIGGLYPUFF

	db $00

Route6Mons:
	db $0F
	db 15,PIDGEY
	db 14,RATTATA
	db 7,ABRA
	db 16,PIDGEY
	db 16,RATTATA
	db 17,PIDGEY
	db 17,PIDGEOTTO
	db 3,JIGGLYPUFF
	db 5,JIGGLYPUFF
	db 7,JIGGLYPUFF

	db $03
	db 15,PSYDUCK
	db 15,PSYDUCK
	db 15,PSYDUCK
	db 15,PSYDUCK
	db 15,PSYDUCK
	db 15,PSYDUCK
	db 15,PSYDUCK
	db 15,PSYDUCK
	db 15,GOLDUCK
	db 20,GOLDUCK

Route11Mons:
	db $0F
	db 16,PIDGEY
	db 15,RATTATA
	db 18,PIDGEY
	db 15,DROWZEE
	db 17,RATTATA
	db 17,DROWZEE
	db 18,PIDGEOTTO
	db 20,PIDGEOTTO
	db 19,DROWZEE
	db 17,RATICATE

	db $00

TunnelMonsB1:
	db $0F
	db 15,ZUBAT
	db 16,GEODUDE
	db 17,ZUBAT
	db 19,ZUBAT
	db 18,GEODUDE
	db 20,GEODUDE
	db 21,ZUBAT
	db 17,MACHOP
	db 19,MACHOP
	db 21,MACHOP

	db $00

TunnelMonsB2:
	db $0F
	db 20,ZUBAT
	db 17,GEODUDE
	db 18,MACHOP
	db 21,ZUBAT
	db 22,ZUBAT
	db 21,GEODUDE
	db 20,MACHOP
	db 14,ONIX
	db 18,ONIX
	db 22,ONIX

	db $00

Route10Mons:
	db $0F
	db 16,MAGNEMITE
	db 18,RATTATA
	db 18,MAGNEMITE
	db 20,MAGNEMITE
	db 17,NIDORAN_M
	db 17,NIDORAN_F
	db 22,MAGNEMITE
	db 20,RATICATE
	db 16,MACHOP
	db 18,MACHOP

	db $00

Route12Mons:
	db $0F
	db 25,ODDISH
	db 25,BELLSPROUT
	db 28,PIDGEY
	db 28,PIDGEOTTO
	db 27,ODDISH
	db 27,BELLSPROUT
	db 29,GLOOM
	db 29,WEEPINBELL
	db 26,FARFETCH_D
	db 31,FARFETCH_D

	db $03
	db 15,SLOWPOKE
	db 15,SLOWPOKE
	db 15,SLOWPOKE
	db 15,SLOWPOKE
	db 15,SLOWPOKE
	db 15,SLOWPOKE
	db 15,SLOWPOKE
	db 15,SLOWPOKE
	db 15,SLOWBRO
	db 20,SLOWBRO

Route8Mons:
	db $0F
	db 20,PIDGEY
	db 22,PIDGEY
	db 20,RATTATA
	db 15,ABRA
	db 19,ABRA
	db 24,PIDGEOTTO
	db 19,JIGGLYPUFF
	db 24,JIGGLYPUFF
	db 20,KADABRA
	db 27,KADABRA

	db $00

Route7Mons:
	db $0F
	db 20,PIDGEY
	db 22,PIDGEY
	db 20,RATTATA
	db 15,ABRA
	db 19,ABRA
	db 24,PIDGEOTTO
	db 26,ABRA
	db 19,JIGGLYPUFF
	db 24,JIGGLYPUFF
	db 24,JIGGLYPUFF

	db $00

TowerMons1:
	db $00

	db $00

TowerMons2:
	db $00

	db $00

TowerMons3:
	db $0A
	db 20,GASTLY
	db 21,GASTLY
	db 22,GASTLY
	db 23,GASTLY
	db 24,GASTLY
	db 19,GASTLY
	db 18,GASTLY
	db 25,GASTLY
	db 20,HAUNTER
	db 25,HAUNTER

	db $00

TowerMons4:
	db $0A
	db 20,GASTLY
	db 21,GASTLY
	db 22,GASTLY
	db 23,GASTLY
	db 24,GASTLY
	db 19,GASTLY
	db 18,GASTLY
	db 25,GASTLY
	db 20,HAUNTER
	db 25,HAUNTER

	db $00

TowerMons5:
	db $0F
	db 22,GASTLY
	db 23,GASTLY
	db 24,GASTLY
	db 25,GASTLY
	db 26,GASTLY
	db 21,GASTLY
	db 20,CUBONE
	db 27,GASTLY
	db 22,HAUNTER
	db 27,HAUNTER

	db $00

TowerMons6:
	db $0F
	db 22,GASTLY
	db 23,GASTLY
	db 24,GASTLY
	db 25,GASTLY
	db 26,GASTLY
	db 21,GASTLY
	db 22,CUBONE
	db 27,GASTLY
	db 22,HAUNTER
	db 27,HAUNTER

	db $00

TowerMons7:
	db $14
	db 24,GASTLY
	db 25,GASTLY
	db 26,GASTLY
	db 27,GASTLY
	db 28,GASTLY
	db 23,GASTLY
	db 24,CUBONE
	db 29,GASTLY
	db 24,HAUNTER
	db 29,HAUNTER

	db $00

Route13Mons:
	db $0F
	db 25,ODDISH
	db 25,BELLSPROUT
	db 28,PIDGEOTTO
	db 28,PIDGEY
	db 27,ODDISH
	db 27,BELLSPROUT
	db 29,GLOOM
	db 29,WEEPINBELL
	db 26,FARFETCH_D
	db 31,FARFETCH_D

	db $03
	db 15,SLOWPOKE
	db 15,SLOWPOKE
	db 15,SLOWPOKE
	db 15,SLOWPOKE
	db 15,SLOWPOKE
	db 15,SLOWPOKE
	db 15,SLOWPOKE
	db 15,SLOWPOKE
	db 15,SLOWBRO
	db 20,SLOWBRO

Route14Mons:
	db $0F
	db 26,ODDISH
	db 26,BELLSPROUT
	db 24,VENONAT
	db 30,PIDGEOTTO
	db 28,ODDISH
	db 28,BELLSPROUT
	db 30,GLOOM
	db 30,WEEPINBELL
	db 27,VENONAT
	db 30,VENOMOTH

	db $00

Route15Mons:
	db $0F
	db 26,ODDISH
	db 26,BELLSPROUT
	db 24,VENONAT
	db 32,PIDGEOTTO
	db 28,ODDISH
	db 28,BELLSPROUT
	db 30,GLOOM
	db 30,WEEPINBELL
	db 27,VENONAT
	db 30,VENOMOTH

	db $00

Route16Mons:
	db $19
	db 22,SPEAROW
	db 22,DODUO
	db 23,RATTATA
	db 24,DODUO
	db 24,RATTATA
	db 26,DODUO
	db 23,SPEAROW
	db 24,FEAROW
	db 25,RATICATE
	db 26,RATICATE

	db $00

Route17Mons:
	db $19
	db 26,DODUO
	db 27,FEAROW
	db 27,DODUO
	db 28,DODUO
	db 28,PONYTA
	db 30,PONYTA
	db 29,FEAROW
	db 28,DODUO
	db 32,PONYTA
	db 29,DODRIO

	db $00

Route18Mons:
	db $19
	db 22,SPEAROW
	db 22,DODUO
	db 23,RATTATA
	db 24,DODUO
	db 24,RATTATA
	db 26,DODUO
	db 23,SPEAROW
	db 24,FEAROW
	db 25,RATICATE
	db 26,RATICATE

	db $00

ZoneMonsCenter:
	db $1E
	db 14,NIDORAN_M
	db 36,NIDORAN_F
	db 24,EXEGGCUTE
	db 20,RHYHORN
	db 23,NIDORINO
	db 27,PARASECT
	db 27,PARAS
	db 32,PARASECT
	db 22,TANGELA
	db 7,CHANSEY

	db $00

ZoneMons1:
	db $1E
	db 21,NIDORAN_M
	db 29,NIDORAN_F
	db 22,EXEGGCUTE
	db 21,TAUROS
	db 32,NIDORINA
	db 19,CUBONE
	db 26,EXEGGCUTE
	db 24,MAROWAK
	db 21,CHANSEY
	db 15,SCYTHER

	db $00

ZoneMons2:
	db $1E
	db 36,NIDORAN_M
	db 14,NIDORAN_F
	db 20,EXEGGCUTE
	db 25,RHYHORN
	db 23,NIDORINA
	db 28,KANGASKHAN
	db 16,CUBONE
	db 33,KANGASKHAN
	db 25,SCYTHER
	db 15,PINSIR

	db $00

ZoneMons3:
	db $1E
	db 29,NIDORAN_M
	db 21,NIDORAN_F
	db 22,EXEGGCUTE
	db 21,TAUROS
	db 32,NIDORINO
	db 19,CUBONE
	db 26,EXEGGCUTE
	db 24,MAROWAK
	db 25,PINSIR
	db 27,TANGELA

	db $00

WaterMons:
	db $00

	db $05
	db 5,TENTACOOL
	db 10,TENTACOOL
	db 15,TENTACOOL
	db 5,TENTACOOL
	db 10,TENTACOOL
	db 15,TENTACOOL
	db 20,TENTACOOL
	db 30,TENTACOOL
	db 35,TENTACOOL
	db 40,TENTACOOL

WaterMons:
	db $00

	db $05
	db 5,TENTACOOL
	db 10,TENTACOOL
	db 15,TENTACOOL
	db 5,TENTACOOL
	db 10,TENTACOOL
	db 15,TENTACOOL
	db 20,TENTACOOL
	db 30,TENTACOOL
	db 35,TENTACOOL
	db 40,TENTACOOL

IslandMons1:
	db $0F
	db 18,ZUBAT
	db 25,KRABBY
	db 27,KRABBY
	db 27,ZUBAT
	db 36,ZUBAT
	db 28,SLOWPOKE
	db 30,SLOWPOKE
	db 9,ZUBAT
	db 27,GOLBAT
	db 36,GOLBAT

	db $00

IslandMonsB1:
	db $0A
	db 27,ZUBAT
	db 26,KRABBY
	db 36,ZUBAT
	db 28,KRABBY
	db 27,GOLBAT
	db 29,SLOWPOKE
	db 18,ZUBAT
	db 28,KINGLER
	db 22,SEEL
	db 26,SEEL

	db $00

IslandMonsB2:
	db $0A
	db 27,ZUBAT
	db 27,KRABBY
	db 36,ZUBAT
	db 27,GOLBAT
	db 28,KINGLER
	db 24,SEEL
	db 29,KRABBY
	db 36,GOLBAT
	db 31,SLOWPOKE
	db 31,SLOWBRO

	db $00

IslandMonsB3:
	db $0A
	db 27,GOLBAT
	db 36,ZUBAT
	db 29,KRABBY
	db 27,ZUBAT
	db 30,KINGLER
	db 26,SEEL
	db 31,KRABBY
	db 30,SEEL
	db 28,DEWGONG
	db 32,DEWGONG

	db $05
	db 25,TENTACOOL
	db 30,TENTACOOL
	db 20,TENTACOOL
	db 30,STARYU
	db 35,TENTACOOL
	db 30,STARYU
	db 40,TENTACOOL
	db 30,STARYU
	db 30,STARYU
	db 30,STARYU

IslandMonsB4:
	db $0A
	db 36,GOLBAT
	db 36,ZUBAT
	db 30,KRABBY
	db 32,KINGLER
	db 28,SEEL
	db 32,SEEL
	db 27,GOLBAT
	db 45,ZUBAT
	db 30,DEWGONG
	db 34,DEWGONG

	db $05
	db 25,TENTACOOL
	db 30,TENTACOOL
	db 20,TENTACOOL
	db 30,STARYU
	db 35,TENTACOOL
	db 30,STARYU
	db 40,TENTACOOL
	db 30,STARYU
	db 30,STARYU
	db 30,STARYU

MansionMons1:
	db $0A
	db 34,RATTATA
	db 34,RATICATE
	db 23,GRIMER
	db 26,GROWLITHE
	db 37,RATTATA
	db 37,RATICATE
	db 30,GROWLITHE
	db 26,GRIMER
	db 34,GROWLITHE
	db 38,GROWLITHE

	db $00

MansionMons2:
	db $0A
	db 37,RATTATA
	db 37,RATICATE
	db 26,GRIMER
	db 29,GRIMER
	db 40,RATTATA
	db 40,RATICATE
	db 32,GRIMER
	db 35,GRIMER
	db 35,MUK
	db 38,MUK

	db $00

MansionMons3:
	db $0A
	db 40,RATTATA
	db 40,RATICATE
	db 32,GRIMER
	db 35,GRIMER
	db 43,RATTATA
	db 43,RATICATE
	db 38,GRIMER
	db 38,GRIMER
	db 38,MUK
	db 41,MUK

	db $00

MansionMonsB1:
	db $0A
	db 35,GRIMER
	db 38,GRIMER
	db 37,RATICATE
	db 40,RATICATE
	db 41,MUK
	db 43,RATICATE
	db 24,DITTO
	db 46,RATICATE
	db 18,DITTO
	db 12,DITTO

	db $00

Route21Mons:
	db $19
	db 15,PIDGEY
	db 13,RATTATA
	db 13,PIDGEY
	db 11,PIDGEY
	db 17,PIDGEY
	db 15,RATTATA
	db 15,RATICATE
	db 17,PIDGEOTTO
	db 19,PIDGEOTTO
	db 15,PIDGEOTTO

	db $05
	db 5,TENTACOOL
	db 10,TENTACOOL
	db 15,TENTACOOL
	db 5,TENTACOOL
	db 10,TENTACOOL
	db 15,TENTACOOL
	db 20,TENTACOOL
	db 30,TENTACOOL
	db 35,TENTACOOL
	db 40,TENTACOOL

DungeonMons1:
	db $0A
	db 50,GOLBAT
	db 55,GOLBAT
	db 45,GRAVELER
	db 55,GLOOM
	db 55,WEEPINBELL
	db 52,SANDSLASH
	db 54,VENOMOTH
	db 54,PARASECT
	db 55,DITTO
	db 60,DITTO

	db $00

DungeonMons2:
	db $0F
	db 52,GOLBAT
	db 57,GOLBAT
	db 50,GRAVELER
	db 56,SANDSLASH
	db 50,RHYHORN
	db 60,DITTO
	db 58,GLOOM
	db 58,WEEPINBELL
	db 60,RHYDON
	db 58,RHYDON

	db $00

DungeonMonsB1:
	db $19
	db 54,GOLBAT
	db 59,GOLBAT
	db 55,GRAVELER
	db 52,RHYHORN
	db 62,RHYDON
	db 60,DITTO
	db 56,CHANSEY
	db 65,DITTO
	db 55,LICKITUNG
	db 50,LICKITUNG

	db $00

PowerPlantMons:
	db $0A
	db 30,MAGNEMITE
	db 35,MAGNEMITE
	db 33,MAGNETON
	db 33,VOLTORB
	db 37,VOLTORB
	db 33,GRIMER
	db 37,GRIMER
	db 38,MAGNETON
	db 33,MUK
	db 37,MUK

	db $00

Route23Mons:
	db $0A
	db 41,NIDORINO
	db 41,NIDORINA
	db 36,MANKEY
	db 44,NIDORINO
	db 44,NIDORINA
	db 40,FEAROW
	db 41,MANKEY
	db 45,FEAROW
	db 41,PRIMEAPE
	db 46,PRIMEAPE

	db $00

PlateauMons2:
	db $0A
	db 31,GEODUDE
	db 36,GEODUDE
	db 41,GEODUDE
	db 44,ZUBAT
	db 39,GOLBAT
	db 44,GRAVELER
	db 45,ONIX
	db 47,ONIX
	db 39,MACHOKE
	db 42,MACHOKE

	db $00

PlateauMons3:
	db $0F
	db 36,GEODUDE
	db 44,GOLBAT
	db 41,GEODUDE
	db 49,ONIX
	db 46,GEODUDE
	db 41,GRAVELER
	db 42,MACHOKE
	db 45,MACHOKE
	db 47,GRAVELER
	db 47,GRAVELER

	db $00

PlateauMons1:
	db $0F
	db 26,GEODUDE
	db 31,GEODUDE
	db 36,GEODUDE
	db 39,ZUBAT
	db 44,ZUBAT
	db 41,GEODUDE
	db 43,ONIX
	db 45,ONIX
	db 41,GRAVELER
	db 47,GRAVELER

	db $00

CaveMons:
	db $14
	db 18,DIGLETT
	db 19,DIGLETT
	db 17,DIGLETT
	db 20,DIGLETT
	db 16,DIGLETT
	db 15,DIGLETT
	db 21,DIGLETT
	db 22,DIGLETT
	db 29,DUGTRIO
	db 31,DUGTRIO

	db $00

ENDC

GetItemUse: ; $D5C7
	ld a,1
	ld [$cd6a],a
	ld a,[$cf91]	;contains item_ID
	cp a,HM_01
	jp nc,ItemUseTMHM
	ld hl,ItemUsePtrTable
	dec a
	add a
	ld c,a
	ld b,0
	add hl,bc
	ld a,[hli]
	ld h,[hl]
	ld l,a
	jp [hl]

ItemUsePtrTable: ; $D5E1
	dw ItemUseBall      ;$5687 masterball
	dw ItemUseBall      ;$5687 ultraball
	dw ItemUseBall      ;$5687 greatball
	dw ItemUseBall      ;$5687 pokeball
	dw ItemUseTownMap   ;$5968 TownMap
	dw $5977            ;ItemUseBicycle
	dw $59B4            ;ItemUseSurfBoard (UNUSED, glitchy!)
	dw ItemUseBall      ;$5687 Safariball
	dw ItemUsePokedex   ;$DA56 pokedex
	dw $5A5B            ; MOON_STONE
	dw $5ABB            ; ANTIDOTE
	dw $5ABB            ; BURN_HEAL
	dw $5ABB            ; ICE_HEAL
	dw $5ABB            ; AWAKENING
	dw $5ABB            ; PARLYZ_HEAL
	dw $5ABB            ; FULL_RESTORE
	dw $5ABB            ; MAX_POTION
	dw $5ABB            ; HYPER_POTION
	dw $5ABB            ; SUPER_POTION
	dw $5ABB            ; POTION
	dw $5F52            ; BOULDERBADGE
	dw $5F67            ; CASCADEBADGE
	dw $6476            ; THUNDERBADGE
	dw $6476            ; RAINBOWBADGE
	dw $6476            ; SOULBADGE
	dw $6476            ; MARSHBADGE
	dw $6476            ; VOLCANOBADGE
	dw $6476            ; EARTHBADGE
	dw $5FAF            ; ESCAPE_ROPE
	dw $6003            ; REPEL
	dw $6476            ; OLD_AMBER
	dw $5A5B            ; FIRE_STONE
	dw $5A5B            ; THUNDER_STONE
	dw $5A5B            ; WATER_STONE
	dw $5AB4            ; HP_UP
	dw $5AB4            ; PROTEIN
	dw $5AB4            ; IRON
	dw $5AB4            ; CARBOS
	dw $5AB4            ; CALCIUM
	dw $5AB4            ; RARE_CANDY
	dw $6476            ; DOME_FOSSIL
	dw $6476            ; HELIX_FOSSIL
	dw $6476            ; SECRET_KEY
	dw $6476
	dw $6476            ; BIKE_VOUCHER
	dw $6013            ; X_ACCURACY
	dw $5A5B            ; LEAF_STONE
	dw $6022            ; CARD_KEY
	dw $6476            ; NUGGET
	dw $6476            ; ??? PP_UP
	dw $60CD            ; POKE_DOLL
	dw $5ABB            ; FULL_HEAL
	dw $5ABB            ; REVIVE
	dw $5ABB            ; MAX_REVIVE
	dw $60DC            ; GUARD_SPEC_
	dw $60EB            ; SUPER_REPL
	dw $60F0            ; MAX_REPEL
	dw $60F5            ; DIRE_HIT
	dw $6476            ; COIN
	dw $5ABB            ; FRESH_WATER
	dw $5ABB            ; SODA_POP
	dw $5ABB            ; LEMONADE
	dw $6476            ; S_S__TICKET
	dw $6476            ; GOLD_TEETH
	dw $6104            ; X_ATTACK
	dw $6104            ; X_DEFEND
	dw $6104            ; X_SPEED
	dw $6104            ; X_SPECIAL
	dw $623A            ; COIN_CASE
	dw $62DE            ; OAKS_PARCEL
	dw $62E1            ; ITEMFINDER
	dw $6476            ; SILPH_SCOPE
	dw $6140            ; POKE_FLUTE
	dw $6476            ; LIFT_KEY
	dw $6476            ; EXP__ALL
	dw OldRodCode       ; OLD_ROD
	dw GoodRodCode 		; GOOD_ROD $6259
	dw SuperRodCode     ; SUPER_ROD $6283
	dw $6317            ; PP_UP (see other?)
	dw $631E            ; ETHER
	dw $631E            ; MAX_ETHER
	dw $631E            ; ELIXER
	dw $631E            ; MAX_ELIXER

ItemUseBall: ; 03:5687
	ld a,[W_ISINBATTLE]
	and a
	jp z,ItemUseNotTime ; not in battle
	dec a
	jp nz,$658b ; in trainer battle
	ld a,[W_BATTLETYPE]
	dec a
	jr z,.UseBall\@
	ld a,[W_NUMINPARTY]	;is Party full?
	cp a,6
	jr nz,.UseBall\@
	ld a,[W_NUMINBOX]	;is Box full?
	cp a,20
	jp z,$65b1
.UseBall\@	;$56a7
;ok, you can use a ball
	xor a
	ld [$d11c],a
	ld a,[W_BATTLETYPE]
	cp a,2		;SafariBattle
	jr nz,.skipSafariZoneCode\@
.safariZone\@
	; remove a Safari Ball from inventory
	ld hl,W_NUMSAFARIBALLS
	dec [hl]
.skipSafariZoneCode\@	;$56b6
	call GoPAL_SET_CF1C
	ld a,$43
	ld [$d11e],a
	call $3725	;restore screenBuffer from Backup
	ld hl,ItemUseText00
	call PrintText
	ld hl,$583a
	ld b,$0f
	call Bankswitch
	ld b,$10
	jp z,$5801
	ld a,[W_BATTLETYPE]
	dec a
	jr nz,.notOldManBattle\@
.oldManBattle\@
	ld hl,W_GRASSRATE
	ld de,W_PLAYERNAME
	ld bc,11
	call CopyData ; save the player's name in the Wild Monster data (part of the Cinnabar Island Missingno glitch)
	jp .BallSuccess\@	;$578b
.notOldManBattle\@	;$56e9
	ld a,[W_CURMAP]
	cp a,POKEMONTOWER_6
	jr nz,.loop\@
	ld a,[$cfd8]
	cp a,MAROWAK
	ld b,$10
	jp z,$5801
; if not fighting ghost Marowak, loop until a random number in the current
; pokeball's allowed range is found
.loop\@	;$56fa
	call GenRandom
	ld b,a
	ld hl,$cf91
	ld a,[hl]
	cp a,MASTER_BALL
	jp z,.BallSuccess\@	;$578b
	cp a,POKE_BALL
	jr z,.checkForAilments
	ld a,200
	cp b
	jr c,.loop\@	;get only numbers <= 200 for Great Ball
	ld a,[hl]
	cp a,GREAT_BALL
	jr z,.checkForAilments
	ld a,150	;get only numbers <= 150 for Ultra Ball
	cp b
	jr c,.loop\@
.checkForAilments\@	;$571a
; pokemon can be caught more easily with any (primary) status ailment
; Frozen/Asleep pokemon are relatively even easier to catch
; for Frozen/Asleep pokemon, any random number from 0-24 ensures a catch.
; for the others, a random number from 0-11 ensures a catch.
	ld a,[W_ENEMYMONSTATUS]	;status ailments
	and a
	jr z,.noAilments\@
	and a,(FRZ + SLP)	;is frozen and/or asleep?
	ld c,12
	jr z,.notFrozenOrAsleep\@
	ld c,25
.notFrozenOrAsleep\@	;$5728
	ld a,b
	sub c
	jp c,.BallSuccess\@	;$578b
	ld b,a
.noAilments\@	;$572e
	push bc		;save RANDOM number
	xor a
	ld [H_MULTIPLICAND],a
	ld hl,W_ENEMYMONMAXHP
	ld a,[hli]
	ld [H_MULTIPLICAND + 1],a
	ld a,[hl]
	ld [H_MULTIPLICAND + 2],a
	ld a,255
	ld [H_MULTIPLIER],a
	call Multiply	; MaxHP * 255
	ld a,[$cf91]
	cp a,GREAT_BALL
	ld a,12		;any other BallFactor
	jr nz,.next7\@
	ld a,8
.next7\@	;$574d
	ld [H_DIVISOR],a
	ld b,4		;number of significant bytes
	call Divide
	ld hl,W_ENEMYMONCURHP
	ld a,[hli]
	ld b,a
	ld a,[hl]

; explanation: we have a 16-bit value equal to [b << 8 | a].
; This number is divided by 4. The result is 8 bit (reg. a).
; Always bigger than zero.
	srl b
	rr a
	srl b
	rr a ; a = current HP / 4
	and a
	jr nz,.next8\@
	inc a
.next8\@	;$5766
	ld [H_DIVISOR],a
	ld b,4
	call Divide	; ((MaxHP * 255) / BallFactor) / (CurHP / 4)
	ld a,[H_QUOTIENT + 2]
	and a
	jr z,.next9\@
	ld a,255
	ld [H_QUOTIENT + 3],a
.next9\@	;$5776
	pop bc
	ld a,[$d007]	;enemy: Catch Rate
	cp b
	jr c,.next10\@
	ld a,[H_QUOTIENT + 2]
	and a
	jr nz,.BallSuccess\@ ; if ((MaxHP * 255) / BallFactor) / (CurHP / 4) > 0x255, automatic success
	call GenRandom
	ld b,a
	ld a,[H_QUOTIENT + 3]
	cp b
	jr c,.next10\@
.BallSuccess\@	;$578b
	jr .BallSuccess2\@
.next10\@	;$578d
	ld a,[H_QUOTIENT + 3]
	ld [$d11e],a
	xor a
	ld [H_MULTIPLICAND],a
	ld [H_MULTIPLICAND + 1],a
	ld a,[$d007]	;enemy: Catch Rate
	ld [H_MULTIPLICAND + 2],a
	ld a,100
	ld [H_MULTIPLIER],a
	call Multiply	; CatchRate * 100
	ld a,[$cf91]
	ld b,255
	cp a,POKE_BALL
	jr z,.next11\@
	ld b,200
	cp a,GREAT_BALL
	jr z,.next11\@
	ld b,150
	cp a,ULTRA_BALL
	jr z,.next11\@
.next11\@	;$57b8
	ld a,b
	ld [H_DIVISOR],a
	ld b,4
	call Divide
	ld a,[H_QUOTIENT + 2]
	and a
	ld b,$63
	jr nz,.next12\@
	ld a,[$d11e]
	ld [H_MULTIPLIER],a
	call Multiply
	ld a,255
	ld [H_DIVISOR],a
	ld b,4
	call Divide
	ld a,[W_ENEMYMONSTATUS]	;status ailments
	and a
	jr z,.next13\@
	and a,(FRZ + SLP)
	ld b,5
	jr z,.next14\@
	ld b,10
.next14\@	;$57e6
	ld a,[H_QUOTIENT + 3]
	add b
	ld [H_QUOTIENT + 3],a
.next13\@	;$57eb
	ld a,[H_QUOTIENT + 3]
	cp a,10
	ld b,$20
	jr c,.next12\@
	cp a,30
	ld b,$61
	jr c,.next12\@
	cp a,70
	ld b,$62
	jr c,.next12\@
	ld b,$63
.next12\@	;$5801
	ld a,b
	ld [$d11e],a
.BallSuccess2\@	;$5805
	ld c,20
	call DelayFrames
	ld a,$c1
	ld [$d07c],a
	xor a
	ld [$fff3],a
	ld [$cc5b],a
	ld [$d05b],a
	ld a,[$cf92]
	push af
	ld a,[$cf91]
	push af
	ld a,$08	;probably animations
	call Predef
	pop af
	ld [$cf91],a
	pop af
	ld [$cf92],a
	ld a,[$d11e]
	cp a,$10
	ld hl,ItemUseBallText00
	jp z,.printText0\@
	cp a,$20
	ld hl,ItemUseBallText01
	jp z,.printText0\@
	cp a,$61
	ld hl,ItemUseBallText02
	jp z,.printText0\@
	cp a,$62
	ld hl,ItemUseBallText03
	jp z,.printText0\@
	cp a,$63
	ld hl,ItemUseBallText04
	jp z,.printText0\@
	ld hl,$cfe6	;current HP
	ld a,[hli]
	push af
	ld a,[hli]
	push af		;backup currentHP...
	inc hl
	ld a,[hl]
	push af		;...and status ailments
	push hl
	ld hl,$d069
	bit 3,[hl]
	jr z,.next15\@
	ld a,$4c
	ld [$cfd8],a
	jr .next16\@
.next15\@	;$5871
	set 3,[hl]
	ld hl,$cceb
	ld a,[$cff1]
	ld [hli],a
	ld a,[$cff2]
	ld [hl],a
.next16\@	;$587e
	ld a,[$cf91]
	push af
	ld a,[$cfd8]
	ld [$cf91],a
	ld a,[$cff3]
	ld [$d127],a
	ld hl,$6b01
	ld b,$0f
	call Bankswitch
	pop af
	ld [$cf91],a
	pop hl
	pop af
	ld [hld],a
	dec hl
	pop af
	ld [hld],a
	pop af
	ld [hl],a
	ld a,[$cfe5]	;enemy
	ld [$d11c],a
	ld [$cf91],a
	ld [$d11e],a
	ld a,[W_BATTLETYPE]
	dec a
	jr z,.printText1\@
	ld hl,ItemUseBallText05
	call PrintText
	ld a,$3a	;convert order: Internal->Dex
	call Predef
	ld a,[$d11e]
	dec a
	ld c,a
	ld b,2
	ld hl,$d2f7	;Dex_own_flags (pokemon)
	ld a,$10
	call Predef	;check Dex flag (own already or not)
	ld a,c
	push af
	ld a,[$d11e]
	dec a
	ld c,a
	ld b,1
	ld a,$10	;set Dex_own_flag?
	call Predef
	pop af
	and a
	jr nz,.checkParty\@
	ld hl,ItemUseBallText06
	call PrintText
	call CleanLCD_OAM
	ld a,[$cfe5]	;caught mon_ID
	ld [$d11e],a
	ld a,$3d
	call Predef
.checkParty\@	;$58f4
	ld a,[W_NUMINPARTY]
	cp a,6		;is party full?
	jr z,.sendToBox\@
	xor a
	ld [$cc49],a
	call CleanLCD_OAM
	call AddPokemonToParty	;add mon to Party
	jr .End\@
.sendToBox\@	;$5907
	call CleanLCD_OAM
	call $67a4
	ld hl,ItemUseBallText07
	ld a,[$d7f1]
	bit 0,a		;already met Bill?
	jr nz,.sendToBox2\@
	ld hl,ItemUseBallText08
.sendToBox2\@	;$591a
	call PrintText
	jr .End\@
.printText1\@	;$591f
	ld hl,ItemUseBallText05
.printText0\@	;$5922
	call PrintText
	call CleanLCD_OAM
.End\@	;$5928
	ld a,[W_BATTLETYPE]
	and a
	ret nz
	ld hl,$d31d
	inc a
	ld [$cf96],a
	jp $2bbb	;remove ITEM (XXX)
ItemUseBallText00:
;"It dodged the thrown ball!"
;"This pokemon can't be caught"
	TX_FAR _ItemUseBallText00
	db "@"
ItemUseBallText01:
;"You missed the pokemon!"
	TX_FAR _ItemUseBallText01
	db "@"
ItemUseBallText02:
;"Darn! The pokemon broke free!"
	TX_FAR _ItemUseBallText02
	db "@"
ItemUseBallText03:
;"Aww! It appeared to be caught!"
	TX_FAR _ItemUseBallText03
	db "@"
ItemUseBallText04:
;"Shoot! It was so close too!"
	TX_FAR _ItemUseBallText04
	db "@"
ItemUseBallText05:
;"All right! {MonName} was caught!"
;play sound
	TX_FAR _ItemUseBallText05
	db $12,$06
	db "@"
ItemUseBallText07:
;"X was transferred to Bill's PC"
	TX_FAR _ItemUseBallText07
	db "@"
ItemUseBallText08:
;"X was transferred to someone's PC"
	TX_FAR _ItemUseBallText08
	db "@"

ItemUseBallText06:
;"New DEX data will be added..."
;play sound
	TX_FAR _ItemUseBallText06
	db $13,$06
	db "@"

ItemUseTownMap: ; 03:5968
	ld a,[W_ISINBATTLE]	;in-battle or outside
	and a
	jp nz,ItemUseNotTime	;OAK: "this isn't the time..."

INCBIN "baserom.gbc",$d96f,$da4c - $d96f

UnnamedText_da4c: ; 0xda4c
	TX_FAR _UnnamedText_da4c
	db $50
; 0xda4c + 5 bytes

UnnamedText_da51: ; 0xda51
	TX_FAR _UnnamedText_da51
	db $50
; 0xda51 + 5 bytes

ItemUsePokedex: ; 0xda56 5A56
	ld a, $29
	jp $3e6d
; 0xda5b

INCBIN "baserom.gbc",$da5b,$df24 - $da5b

UnnamedText_df24: ; 0xdf24
	TX_FAR _UnnamedText_df24
	db $50
; 0xdf24 + 5 bytes

UnnamedText_df29: ; 0xdf29
	TX_FAR _UnnamedText_df29
	db $50
; 0xdf29 + 5 bytes

INCBIN "baserom.gbc",$df2e,$dfa5 - $df2e

UnnamedText_dfa5: ; 0xdfa5
	TX_FAR _UnnamedText_dfa5
	db $50
; 0xdfa5 + 5 bytes

UnnamedText_dfaa: ; 0xdfaa
	TX_FAR _UnnamedText_dfaa
	db $50
; 0xdfaa + 5 bytes

INCBIN "baserom.gbc",$dfaf,$e20b - $dfaf

UnnamedText_e20b: ; 0xe20b
	TX_FAR _UnnamedText_e20b
	db $50
; 0xe20b + 5 bytes

UnnamedText_e210: ; 0xe210
	TX_FAR _UnnamedText_e210
	db $50
; 0xe210 + 5 bytes

INCBIN "baserom.gbc",$e215,$e247 - $e215

UnnamedText_e247: ; 0xe247
	TX_FAR _UnnamedText_e247
	db $50
; 0xe247 + 5 bytes

OldRodCode: ; 0xe24c
	call $62b4 ; probably sets carry if not in battle or not by water
	jp c, ItemUseNotTime
	ld bc, (5 << 8) | MAGIKARP
	ld a, $1 ; set bite
	jr RodResponse ; 0xe257 $34

GoodRodCode: ; 6259 0xe259
	call $62B4 ; probably sets carry if not in battle or not by water
	jp c,ItemUseNotTime
.RandomLoop
	call GenRandom
	srl a
	jr c, .SetBite
	and %11
	cp 2
	jr nc, .RandomLoop
	; choose which monster appears
	ld hl,GoodRodMons
	add a,a
	ld c,a
	ld b,0
	add hl,bc
	ld b,[hl]
	inc hl
	ld c,[hl]
	and a
.SetBite
	ld a,0
	rla
	xor 1
	jr RodResponse

GoodRodMons:
	db 10,GOLDEEN
	db 10,POLIWAG

SuperRodCode: ; $6283 0xe283
	call $62B4 ; probably sets carry if in battle or not by water
	jp c, ItemUseNotTime
	call ReadSuperRodData ; 0xe8ea
	ld a, e
RodResponse:
	ld [$CD3D], a

	dec a ; is there a bite?
	jr nz, .next\@
	; if yes, store level and species data
	ld a, 1
	ld [$D05F], a
	ld a, b ; level
	ld [W_CURENEMYLVL], a
	ld a, c ; species
	ld [W_CUROPPONENT], a

.next\@
	ld hl, $D700
	ld a, [hl] ; store the value in a
	push af
	push hl
	ld [hl], 0
	ld b, $1C
	ld hl, $47B6
	call Bankswitch
	pop hl
	pop af
	ld [hl], a
	ret

INCBIN "baserom.gbc",$e2b4,$e30d - $e2b4

UnnamedText_e30d: ; 0xe30d
	TX_FAR _UnnamedText_e30d
	db $50
; 0xe30d + 5 bytes

UnnamedText_e312: ; 0xe312
	TX_FAR _UnnamedText_e312
	db $50
; 0xe312 + 5 bytes

INCBIN "baserom.gbc",$e317,$e45d - $e317

UnnamedText_e45d: ; 0xe45d
	TX_FAR _UnnamedText_e45d
	db $50
; 0xe45d + 5 bytes

UnnamedText_e462: ; 0xe462
	TX_FAR _UnnamedText_e462
	db $50
; 0xe462 + 5 bytes

UnnamedText_e467: ; 0xe467
	TX_FAR _UnnamedText_e467
	db $50
; 0xe467 + 5 bytes

UnnamedText_e46c: ; 0xe46c
	TX_FAR _UnnamedText_e46c
	db $50
; 0xe46c + 5 bytes

UnnamedText_e471: ; 0xe471
	TX_FAR _UnnamedText_e471
	db $50
; 0xe471 + 5 bytes

INCBIN "baserom.gbc",$e476,$3

ItemUseTMHM: ; 03:6479
	INCBIN "baserom.gbc",$E479,$E581 - $E479
ItemUseNotTime: ; 03:6581
	INCBIN "baserom.gbc",$E581,$E5E8 - $E581
ItemUseText00: ; 03:65e8
	TX_FAR _ItemUseText001
	db $05
	TX_FAR _ItemUseText002
	db "@"

INCBIN "baserom.gbc",$e5f2,$e5f7 - $e5f2

UnnamedText_e5f7: ; 0xe5f7
	TX_FAR _UnnamedText_e5f7
	db $50
; 0xe5f7 + 5 bytes

INCBIN "baserom.gbc",$e5fc,$e601 - $e5fc

UnnamedText_e601: ; 0xe601
	TX_FAR _UnnamedText_e601
	db $50
; 0xe601 + 5 bytes

INCBIN "baserom.gbc",$e606,$e755 - $e606

UnnamedText_e755: ; 0xe755
	TX_FAR _UnnamedText_e755
	db $50
; 0xe755 + 5 bytes

UnnamedText_e75a: ; 0xe75a
	TX_FAR _UnnamedText_e75a
	db $50
; 0xe75a + 5 bytes

UnnamedText_e75f: ; 0xe75f
	TX_FAR _UnnamedText_e75f
	db $50
; 0xe75f + 5 bytes

INCBIN "baserom.gbc",$e764,$e8ea - $e764

; 68EA 0xe8ea
ReadSuperRodData:
; return e = 2 if no fish on this map
; return e = 1 if a bite, bc = level,species
; return e = 0 if no bite
	ld a, [W_CURMAP]
	ld de, 3 ; each fishing group is three bytes wide
	ld hl, SuperRodData
	call IsInArray
	jr c, .ReadFishingGroup
	ld e, $2 ; $2 if no fishing groups found
	ret

.ReadFishingGroup ; 0xe8f6
; hl points to the fishing group entry in the index
	inc hl ; skip map id

	; read fishing group address
	ld a, [hli]
	ld h, [hl]
	ld l, a

	ld b, [hl] ; how many mons in group
	inc hl ; point to data
	ld e, $0 ; no bite yet

.RandomLoop ; 0xe90c
	call GenRandom
	srl a
	ret c ; 50% chance of no battle

	and %11 ; 2-bit random number
	cp b
	jr nc, .RandomLoop ; if a is greater than the number of mons, regenerate

	; get the mon
	add a
	ld c, a
	ld b, $0
	add hl, bc
	ld b, [hl] ; level
	inc hl
	ld c, [hl] ; species
	ld e, $1 ; $1 if there's a bite
	ret
; 0xe919

; super rod data
; format: map, pointer to fishing group
SuperRodData: ; 6919
	dbw PALLET_TOWN, FishingGroup1
	dbw VIRIDIAN_CITY, FishingGroup1
	dbw CERULEAN_CITY, FishingGroup3
	dbw VERMILION_CITY, FishingGroup4
	dbw CELADON_CITY, FishingGroup5
	dbw FUCHSIA_CITY, FishingGroup10
	dbw CINNABAR_ISLAND, FishingGroup8
	dbw ROUTE_4, FishingGroup3
	dbw ROUTE_6, FishingGroup4
	dbw ROUTE_10, FishingGroup5
	dbw ROUTE_11, FishingGroup4
	dbw ROUTE_12, FishingGroup7
	dbw ROUTE_13, FishingGroup7
	dbw ROUTE_17, FishingGroup7
	dbw ROUTE_18, FishingGroup7
	dbw ROUTE_19, FishingGroup8
	dbw ROUTE_20, FishingGroup8
	dbw ROUTE_21, FishingGroup8
	dbw ROUTE_22, FishingGroup2
	dbw ROUTE_23, FishingGroup9
	dbw ROUTE_24, FishingGroup3
	dbw ROUTE_25, FishingGroup3
	dbw CERULEAN_GYM, FishingGroup3
	dbw VERMILION_DOCK, FishingGroup4
;XXX syntax errors on the rest?
	dbw $A1, FishingGroup8 ; SEAFOAM_ISLANDS_4
	dbw $A2, FishingGroup8 ; SEAFOAM_ISLANDS_5
	dbw SAFARI_ZONE_EAST, FishingGroup6
	dbw $DA, FishingGroup6 ; SAFARI_ZONE_NORTH
	dbw SAFARI_ZONE_WEST, FishingGroup6 
	dbw $DC, FishingGroup6 ; SAFARI_ZONE_CENTER
	dbw $E2, FishingGroup9 ; UNKNOWN_DUNGEON_2
	dbw $E3, FishingGroup9 ; UNKNOWN_DUNGEON_3
	dbw $E4, FishingGroup9 ; UNKNOWN_DUNGEON_1
	db $FF

; fishing groups
; number of monsters, followed by level/monster pairs
FishingGroup1:
	db 2
	db 15,TENTACOOL
	db 15,POLIWAG

FishingGroup2:
	db 2
	db 15,GOLDEEN
	db 15,POLIWAG

FishingGroup3:
	db 3
	db 15,PSYDUCK
	db 15,GOLDEEN
	db 15,KRABBY

FishingGroup4:
	db 2
	db 15,KRABBY
	db 15,SHELLDER

FishingGroup5:
	db 2
	db 23,POLIWHIRL
	db 15,SLOWPOKE

FishingGroup6:
	db 4
	db 15,DRATINI
	db 15,KRABBY
	db 15,PSYDUCK
	db 15,SLOWPOKE

FishingGroup7:
	db 4
	db 5,TENTACOOL
	db 15,KRABBY
	db 15,GOLDEEN
	db 15,MAGIKARP

FishingGroup8:
	db 4
	db 15,STARYU
	db 15,HORSEA
	db 15,SHELLDER
	db 15,GOLDEEN

FishingGroup9:
	db 4
	db 23,SLOWBRO
	db 23,SEAKING
	db 23,KINGLER
	db 23,SEADRA

FishingGroup10:
	db 4
	db 23,SEAKING
	db 15,KRABBY
	db 15,GOLDEEN
	db 15,MAGIKARP

INCBIN "baserom.gbc",$E9C5,$ef7d - $E9C5

_UnnamedText_ef7d: ; 0xef7d
	db $17, $f8, $42, $2a
	db $50
; 0xef7d + 5 bytes

INCBIN "baserom.gbc",$ef82,$f6a5 - $ef82

HealParty:
	ld hl, W_PARTYMON1
	ld de, W_PARTYMON1_HP
.HealPokemon\@: ; 0xf704
	ld a, [hli]
	cp $ff
	jr z, .DoneHealing\@ ; End if there's no Pokémon
	push hl
	push de
	ld hl, $0003 ; Status offset
	add hl, de
	xor a
	ld [hl], a ; Clean status conditions
	push de
	ld b, $4 ; A Pokémon has 4 moves
.RestorePP\@:
	ld hl, $0007 ; Move offset
	add hl, de
	ld a, [hl]
	and a
	jr z, .HealNext\@ ; Skip if there's no move here
	dec a
	ld hl, $001c ; PP offset
	add hl, de
	push hl
	push de
	push bc
	ld hl, Moves
	ld bc, $0006
	call AddNTimes
	ld de, $cd6d
	ld a, BANK(Moves)
	call FarCopyData ; copy move header to memory
	ld a, [$cd72] ; get default PP
	pop bc
	pop de
	pop hl
	inc de
	push bc
	ld b, a
	ld a, [hl]
	and $c0
	add b
	ld [hl], a
	pop bc
.HealNext\@:
	dec b
	jr nz, .RestorePP\@ ; Continue if there's still moves
	pop de
	ld hl, $0021 ; Max HP offset
	add hl, de
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hl]
	ld [de], a ; Restore full HP
	pop de
	pop hl
	push hl
	ld bc, $002c
	ld h, d
	ld l, e
	add hl, bc
	ld d, h
	ld e, l
	pop hl
	jr .HealPokemon\@ ; Next Pokémon
.DoneHealing\@ ; This calls $6606 for each Pokémon in party -- no idea why
	xor a
	ld [$cf92], a
	ld [$d11e], a
	ld a, [W_NUMINPARTY]
	ld b, a
.asm_f711
	push bc
	call $6606
	pop bc
	ld hl, $cf92
	inc [hl]
	dec b
	jr nz, .asm_f711 ; 0xf71b $f4
	ret

INCBIN "baserom.gbc",$f71e,$fbd9 - $f71e

UnnamedText_fbd9: ; 0xfbd9
	TX_FAR _UnnamedText_fbd9
	db $50
; 0xfbd9 + 5 bytes

UnnamedText_fbde: ; 0xfbde
	TX_FAR _UnnamedText_fbde
	db $50
; 0xfbde + 5 bytes

UnnamedText_fbe3: ; 0xfbe3
	TX_FAR _UnnamedText_fbe3
	db $50
; 0xfbe3 + 5 bytes

INCBIN "baserom.gbc",$fbe8,$fc03 - $fbe8

UnnamedText_fc03: ; 0xfc03
	TX_FAR _UnnamedText_fc03
	db $50
; 0xfc03 + 5 bytes

UnnamedText_fc08: ; 0xfc08
	TX_FAR _UnnamedText_fc08
	db $50
; 0xfc08 + 5 bytes

UnnamedText_fc0d: ; 0xfc0d
	TX_FAR _UnnamedText_fc0d
	db $50
; 0xfc0d + 5 bytes

INCBIN "baserom.gbc",$fc12,$fc45 - $fc12

UnnamedText_fc45: ; 0xfc45
	TX_FAR _UnnamedText_fc45
	db $50
; 0xfc45 + 5 bytes

INCBIN "baserom.gbc",$fc4a,$3b6

SECTION "bank4",DATA,BANK[$4]

INCBIN "baserom.gbc",$10000,$12e7f - $10000

UnnamedText_12e7f: ; 0x12e7f
	TX_FAR _UnnamedText_12e7f
	db $50
; 0x12e7f + 5 bytes

UnnamedText_12e84: ; 0x12e84
	TX_FAR _UnnamedText_12e84
	db $50
; 0x12e84 + 5 bytes

UnnamedText_12e89: ; 0x12e89
	TX_FAR _UnnamedText_12e89
	db $50
; 0x12e89 + 5 bytes

UnnamedText_12e8e: ; 0x12e8e
	TX_FAR _UnnamedText_12e8e
	db $50
; 0x12e8e + 5 bytes

UnnamedText_12e93: ; 0x12e93
	TX_FAR _UnnamedText_12e93
	db $50
; 0x12e93 + 5 bytes

UnnamedText_12e98: ; 0x12e98
	TX_FAR _UnnamedText_12e98
	db $50
; 0x12e98 + 5 bytes

UnnamedText_12e9d: ; 0x12e9d
	TX_FAR _UnnamedText_12e9d
	db $50
; 0x12e9d + 5 bytes

UnnamedText_12ea2: ; 0x12ea2
	TX_FAR _UnnamedText_12ea2
	db $50
; 0x12ea2 + 5 bytes

UnnamedText_12ea7: ; 0x12ea7
	TX_FAR _UnnamedText_12ea7
	db $50
; 0x12ea7 + 5 bytes

UnnamedText_12eac: ; 0x12eac
	TX_FAR _UnnamedText_12eac
	db $50
; 0x12eac + 5 bytes

UnnamedText_12eb1: ; 0x12eb1
	TX_FAR _UnnamedText_12eb1
	db $50
; 0x12eb1 + 5 bytes

UnnamedText_12eb6: ; 0x12eb6
	TX_FAR _UnnamedText_12eb6
	db $50
; 0x12eb6 + 5 bytes

UnnamedText_12ebb: ; 0x12ebb
	TX_FAR _UnnamedText_12ebb
	db $50
; 0x12ebb + 5 bytes

INCBIN "baserom.gbc",$12ec0,$1e

RedPicFront:
	INCBIN "pic/trainer/red.pic"
ShrinkPic1:
	INCBIN "pic/trainer/shrink1.pic"
ShrinkPic2:
	INCBIN "pic/trainer/shrink2.pic"

INCBIN "baserom.gbc",$13074,$13228 - $13074

UnnamedText_13228: ; 0x13228
	TX_FAR _UnnamedText_13228
	db $50
; 0x13228 + 5 bytes

INCBIN "baserom.gbc",$1322d,$1327b - $1322d

UnnamedText_1327b: ; 0x1327b
	TX_FAR _UnnamedText_1327b
	db $50
; 0x1327b + 5 bytes

UnnamedText_13280: ; 0x13280
	TX_FAR _UnnamedText_13280
	db $50
; 0x13280 + 5 bytes

UnnamedText_13285: ; 0x13285
	TX_FAR _UnnamedText_13285
	db $50
; 0x13285 + 5 bytes

INCBIN "baserom.gbc",$1328a,$132d4 - $1328a

UnnamedText_132d4: ; 0x132d4
	TX_FAR _UnnamedText_132d4
	db $50
; 0x132d4 + 5 bytes

INCBIN "baserom.gbc",$132d9,$132e8 - $132d9

UnnamedText_132e8: ; 0x132e8
	TX_FAR _UnnamedText_132e8
	db $50
; 0x132e8 + 5 bytes

INCBIN "baserom.gbc",$132ed,$1342a - $132ed

UnnamedText_1342a: ; 0x1342a
	TX_FAR _UnnamedText_1342a
	db $50
; 0x1342a + 5 bytes

UnnamedText_1342f: ; 0x1342f
	TX_FAR _UnnamedText_1342f
	db $50
; 0x1342f + 5 bytes

INCBIN "baserom.gbc",$13434,$13773 - $13434

TechnicalMachines: ; 0x13773
	db MEGA_PUNCH
	db RAZOR_WIND
	db SWORDS_DANCE
	db WHIRLWIND
	db MEGA_KICK
	db TOXIC
	db HORN_DRILL
	db BODY_SLAM
	db TAKE_DOWN
	db DOUBLE_EDGE
	db BUBBLEBEAM
	db WATER_GUN
	db ICE_BEAM
	db BLIZZARD
	db HYPER_BEAM
	db PAY_DAY
	db SUBMISSION
	db COUNTER
	db SEISMIC_TOSS
	db RAGE
	db MEGA_DRAIN
	db SOLARBEAM
	db DRAGON_RAGE
	db THUNDERBOLT
	db THUNDER
	db EARTHQUAKE
	db FISSURE
	db DIG
	db PSYCHIC_M
	db TELEPORT
	db MIMIC
	db DOUBLE_TEAM
	db REFLECT
	db BIDE
	db METRONOME
	db SELFDESTRUCT
	db EGG_BOMB
	db FIRE_BLAST
	db SWIFT
	db SKULL_BASH
	db SOFTBOILED
	db DREAM_EATER
	db SKY_ATTACK
	db REST
	db THUNDER_WAVE
	db PSYWAVE
	db EXPLOSION
	db ROCK_SLIDE
	db TRI_ATTACK
	db SUBSTITUTE
	db CUT
	db FLY
	db SURF
	db STRENGTH
	db FLASH

INCBIN "baserom.gbc",$137aa,$1386b - $137aa

UnnamedText_1386b: ; 0x1386b
	TX_FAR _UnnamedText_1386b
	db $50
; 0x1386b + 5 bytes

INCBIN "baserom.gbc",$13870,$1399e - $13870

UnnamedText_1399e: ; 0x1399e
	TX_FAR _UnnamedText_1399e
	db $50
; 0x1399e + 5 bytes

INCBIN "baserom.gbc",$139a3,$139cd - $139a3

UnnamedText_139cd: ; 0x139cd
	TX_FAR _UnnamedText_139cd
	db $50
; 0x139cd + 5 bytes

INCBIN "baserom.gbc",$139d2,$13a53 - $139d2

UnnamedText_13a53: ; 0x13a53
	TX_FAR _UnnamedText_13a53
	db $50
; 0x13a53 + 5 bytes

INCBIN "baserom.gbc",$13a58,$37

GenRandom_: ; 7A8F
; generate a random 16-bit integer and store it at $FFD3,$FFD4
	ld a,[rDIV]
	ld b,a
	ld a,[H_RAND1]
	adc b
	ld [H_RAND1],a
	ld a,[rDIV]
	ld b,a
	ld a,[H_RAND2]
	sbc b
	ld [H_RAND2],a
	ret

SECTION "bank5",DATA,BANK[$5]

INCBIN "baserom.gbc",$14000,$17e1d - $14000

UnnamedText_17e1d: ; 0x17e1d
	TX_FAR _UnnamedText_17e1d
	db $50
; 0x17e1d + 5 bytes

UnnamedText_17e22: ; 0x17e22
	TX_FAR _UnnamedText_17e22
	db $50
; 0x17e22 + 5 bytes

UnnamedText_17e27: ; 0x17e27
	TX_FAR _UnnamedText_17e27
	db $50
; 0x17e27 + 5 bytes

INCBIN "baserom.gbc",$17e2c,$17f23 - $17e2c

UnnamedText_17f23: ; 0x17f23
	TX_FAR _UnnamedText_17f23
	db $50
; 0x17f23 + 5 bytes

UnnamedText_17f28: ; 0x17f28
	TX_FAR _UnnamedText_17f28
	db $50
; 0x17f28 + 5 bytes

UnnamedText_17f2d: ; 0x17f2d
	TX_FAR _UnnamedText_17f2d
	db $50
; 0x17f2d + 5 bytes

UnnamedText_17f32: ; 0x17f32
	TX_FAR _UnnamedText_17f32
	db $50
; 0x17f32 + 5 bytes

INCBIN "baserom.gbc",$17f37,$c9

SECTION "bank6",DATA,BANK[$6]

CeladonCity_h: ; 0x18000
	db $00 ; tileset
	db CELADON_CITY_HEIGHT, CELADON_CITY_WIDTH ; dimensions (y, x)
	dw CeladonCityBlocks, CeladonCityTexts, CeladonCityScript ; blocks, texts, scripts
	db WEST | EAST ; connections

	; connections data

	db ROUTE_16
	dw $4B95, $C7C1 ; pointers (connected, current) (strip)
	db $09, $14 ; bigness, width
	db $F8, $27 ; alignments (y, x)
	dw $C716 ; window

	db ROUTE_7
	dw $4051, $C7DD ; pointers (connected, current) (strip)
	db $09, $0A ; bigness, width
	db $F8, $00 ; alignments (y, x)
	dw $C6F9 ; window

	; end connections data

	dw CeladonCityObject ; objects

CeladonCityObject: ; 0x18022 (size=189)
	db $f ; border tile

	db $d ; warps
	db $d, $8, $0, CELADON_MART_1
	db $d, $a, $2, CELADON_MART_1
	db $9, $18, $0, CELADON_MANSION_1
	db $3, $18, $2, CELADON_MANSION_1
	db $3, $19, $2, CELADON_MANSION_1
	db $9, $29, $0, CELADON_POKECENTER
	db $1b, $c, $0, CELADON_GYM
	db $13, $1c, $0, GAME_CORNER
	db $13, $27, $0, CELADON_MART_5
	db $13, $21, $0, CELADONPRIZE_ROOM
	db $1b, $1f, $0, CELADON_DINER
	db $1b, $23, $0, CELADON_HOUSE
	db $1b, $2b, $0, CELADON_HOTEL

	db $9 ; signs
	db $f, $1b, $a ; CeladonCityText10
	db $f, $13, $b ; CeladonCityText11
	db $9, $2a, $c ; CeladonCityText12
	db $1d, $d, $d ; CeladonCityText13
	db $9, $15, $e ; CeladonCityText14
	db $d, $c, $f ; CeladonCityText15
	db $15, $27, $10 ; CeladonCityText16
	db $15, $21, $11 ; CeladonCityText17
	db $15, $1b, $12 ; CeladonCityText18

	db $9 ; people
	db SPRITE_LITTLE_GIRL, $11 + 4, $8 + 4, $fe, $0, $1 ; person
	db SPRITE_OLD_PERSON, $1c + 4, $b + 4, $ff, $d1, $2 ; person
	db SPRITE_GIRL, $13 + 4, $e + 4, $fe, $1, $3 ; person
	db SPRITE_OLD_PERSON, $16 + 4, $19 + 4, $ff, $d0, $4 ; person
	db SPRITE_OLD_PERSON, $10 + 4, $16 + 4, $ff, $d0, $5 ; person
	db SPRITE_FISHER2, $c + 4, $20 + 4, $ff, $d2, $6 ; person
	db SPRITE_SLOWBRO, $c + 4, $1e + 4, $ff, $d3, $7 ; person
	db SPRITE_ROCKET, $1d + 4, $20 + 4, $fe, $2, $8 ; person
	db SPRITE_ROCKET, $e + 4, $2a + 4, $fe, $2, $9 ; person

	; warp-to
	EVENT_DISP $19, $d, $8 ; CELADON_MART_1
	EVENT_DISP $19, $d, $a ; CELADON_MART_1
	EVENT_DISP $19, $9, $18 ; CELADON_MANSION_1
	EVENT_DISP $19, $3, $18 ; CELADON_MANSION_1
	EVENT_DISP $19, $3, $19 ; CELADON_MANSION_1
	EVENT_DISP $19, $9, $29 ; CELADON_POKECENTER
	EVENT_DISP $19, $1b, $c ; CELADON_GYM
	EVENT_DISP $19, $13, $1c ; GAME_CORNER
	EVENT_DISP $19, $13, $27 ; CELADON_MART_5
	EVENT_DISP $19, $13, $21 ; CELADONPRIZE_ROOM
	EVENT_DISP $19, $1b, $1f ; CELADON_DINER
	EVENT_DISP $19, $1b, $23 ; CELADON_HOUSE
	EVENT_DISP $19, $1b, $2b ; CELADON_HOTEL

CeladonCityBlocks: ; 0x180df 450
	INCBIN "maps/celadoncity.blk"

PalletTown_h: ; 0x182a1
	db $00 ; tileset
	db PALLET_TOWN_HEIGHT, PALLET_TOWN_WIDTH ; dimensions
	dw PalletTownBlocks, PalletTownTexts, PalletTownScript
	db NORTH | SOUTH ; connections

	db ROUTE_1
	dw Route1Blocks + ((ROUTE_1_WIDTH * 15) + 0) ;y, x Strip Starting Point
	dw $C6EB + 0 ;Strip X-Offset to current map
	db ROUTE_1_WIDTH ;"Bigness" (Unsure) ;Something to do with MapData
	db ROUTE_1_WIDTH ;"Map Width" (Unsure) ;Something to do with TileSet
	db (ROUTE_1_HEIGHT * 2) - 1 ;Player's new Y-Coordinates
	db (0 * -2) ;Player's new X-Coordinates
	dw $C6E9 + ROUTE_1_HEIGHT * (ROUTE_1_WIDTH + 6) ;New UL Block Pos (Window)

	db ROUTE_21
	dw Route21Blocks,$C7AB ; pointers
	db $0A,$0A ; bigness, width
	db $00,$00 ; alignments
	dw $C6F9 ; window

	dw PalletTownObject

PalletTownObject: ; 0x182c3 (size=58)
	db $b ; border tile

	db $3 ; warps
	db $5, $5, $0, REDS_HOUSE_1F
	db $5, $d, $0, BLUES_HOUSE
	db $b, $c, $1, OAKS_LAB

	db $4 ; signs
	db $d, $d, $4 ; PalletTownText4
	db $9, $7, $5 ; PalletTownText5
	db $5, $3, $6 ; PalletTownText6
	db $5, $b, $7 ; PalletTownText7

	db $3 ; people
	db SPRITE_OAK, $5 + 4, $8 + 4, $ff, $ff, $1 ; person
	db SPRITE_GIRL, $8 + 4, $3 + 4, $fe, $0, $2 ; person
	db SPRITE_FISHER2, $e + 4, $b + 4, $fe, $0, $3 ; person

	; warp-to
	EVENT_DISP $a, $5, $5 ; REDS_HOUSE_1F
	EVENT_DISP $a, $5, $d ; BLUES_HOUSE
	EVENT_DISP $a, $b, $c ; OAKS_LAB

PalletTownBlocks: ; 0x182fd
	INCBIN "maps/pallettown.blk"

ViridianCity_h: ; 0x18357 to 0x18384 (45 bytes) (bank=6) (id=1)
	db $00 ; tileset
	db VIRIDIAN_CITY_HEIGHT, VIRIDIAN_CITY_WIDTH ; dimensions (y, x)
	dw ViridianCityBlocks, ViridianCityTexts, ViridianCityScript ; blocks, texts, scripts
	db NORTH | SOUTH | WEST ; connections

	; connections data

	db ROUTE_2
	dw Route2Blocks + (ROUTE_2_HEIGHT - 3) * ROUTE_2_WIDTH ; connection strip location
	dw $C6EB + 5 ; current map position
	db ROUTE_2_WIDTH, ROUTE_2_WIDTH ; bigness, width
	db (ROUTE_2_HEIGHT * 2) - 1, (5 * -2) ; alignments (y, x)
	dw $C6E9 + ROUTE_2_HEIGHT * (ROUTE_2_WIDTH + 6) ; window

	db ROUTE_1
	dw Route1Blocks ; connection strip location
	dw $C6EB + (VIRIDIAN_CITY_HEIGHT + 3) * (VIRIDIAN_CITY_WIDTH + 6) + 5 ; current map position
	db ROUTE_1_WIDTH, ROUTE_1_WIDTH ; bigness, width
	db 0, (5 * -2) ; alignments (y, x)
	dw $C6EF + ROUTE_1_WIDTH ; window

	db ROUTE_22
	dw Route22Blocks - 3 + (ROUTE_22_WIDTH) ; connection strip location
	dw $C6E8 + (VIRIDIAN_CITY_WIDTH + 6) * (4 + 3) ; current map position
	db ROUTE_22_HEIGHT, ROUTE_22_WIDTH ; bigness, width
	db (4 * -2), (ROUTE_22_WIDTH * 2) - 1 ; alignments (y, x)
	dw $C6EE + 2 * ROUTE_22_WIDTH ; window

	; end connections data

	dw ViridianCityObject ; objects

ViridianCityObject: ; 0x18384 (size=104)
	db $f ; border tile

	db $5 ; warps
	db $19, $17, $0, VIRIDIAN_POKECENTER
	db $13, $1d, $0, VIRIDIAN_MART
	db $f, $15, $0, VIRIDIAN_SCHOOL
	db $9, $15, $0, VIRIDIAN_HOUSE
	db $7, $20, $0, VIRIDIAN_GYM

	db $6 ; signs
	db $11, $11, $8 ; ViridianCityText8
	db $1, $13, $9 ; ViridianCityText9
	db $1d, $15, $a ; ViridianCityText10
	db $13, $1e, $b ; ViridianCityText11
	db $19, $18, $c ; ViridianCityText12
	db $7, $1b, $d ; ViridianCityText13

	db $7 ; people
	db SPRITE_BUG_CATCHER, $14 + 4, $d + 4, $fe, $0, $1 ; person
	db SPRITE_GAMBLER, $8 + 4, $1e + 4, $ff, $ff, $2 ; person
	db SPRITE_BUG_CATCHER, $19 + 4, $1e + 4, $fe, $0, $3 ; person
	db SPRITE_GIRL, $9 + 4, $11 + 4, $ff, $d3, $4 ; person
	db SPRITE_LYING_OLD_MAN, $9 + 4, $12 + 4, $ff, $ff, $5 ; person
	db SPRITE_FISHER2, $17 + 4, $6 + 4, $ff, $d0, $6 ; person
	db SPRITE_GAMBLER, $5 + 4, $11 + 4, $fe, $2, $7 ; person

	; warp-to
	EVENT_DISP $14, $19, $17 ; VIRIDIAN_POKECENTER
	EVENT_DISP $14, $13, $1d ; VIRIDIAN_MART
	EVENT_DISP $14, $f, $15 ; VIRIDIAN_SCHOOL
	EVENT_DISP $14, $9, $15 ; VIRIDIAN_HOUSE
	EVENT_DISP $14, $7, $20 ; VIRIDIAN_GYM

ViridianCityBlocks: ; 0x183ec 360
	INCBIN "maps/viridiancity.blk"

PewterCity_h: ; 0x18554 to 0x18576 (34 bytes) (bank=6) (id=2)
	db $00 ; tileset
	db PEWTER_CITY_HEIGHT, PEWTER_CITY_WIDTH ; dimensions (y, x)
	dw PewterCityBlocks, PewterCityTexts, PewterCityScript ; blocks, texts, scripts
	db SOUTH | EAST ; connections

	; connections data

	db ROUTE_2
	dw Route2Blocks ; connection strip location
	dw $C6EB + (PEWTER_CITY_HEIGHT + 3) * (PEWTER_CITY_WIDTH + 6) + 5 ; current map position
	db ROUTE_2_WIDTH, ROUTE_2_WIDTH ; bigness, width
	db 0, (5 * -2) ; alignments (y, x)
	dw $C6EF + ROUTE_2_WIDTH ; window

	db ROUTE_3
	dw Route3Blocks + (ROUTE_3_WIDTH * 0) ; connection strip location
	dw $C6E5 + (PEWTER_CITY_WIDTH + 6) * (4 + 4) ; current map position
	db ROUTE_3_HEIGHT, ROUTE_3_WIDTH ; bigness, width
	db (4 * -2), 0 ; alignments (y, x)
	dw $C6EF + ROUTE_3_WIDTH ; window

	; end connections data

	dw PewterCityObject ; objects

INCBIN "baserom.gbc",$18576,$18577 - $18576

PewterCityObject: ; 0x18577 (size=111)
	db $a ; border tile

	db $7 ; warps
	db $7, $e, $0, MUSEUM_1F
	db $5, $13, $2, MUSEUM_1F
	db $11, $10, $0, PEWTER_GYM
	db $d, $1d, $0, PEWTER_HOUSE_1
	db $11, $17, $0, PEWTER_MART
	db $1d, $7, $0, PEWTER_HOUSE_2
	db $19, $d, $0, PEWTER_POKECENTER

	db $7 ; signs
	db $1d, $13, $6 ; PewterCityText6
	db $13, $21, $7 ; PewterCityText7
	db $11, $18, $8 ; PewterCityText8
	db $19, $e, $9 ; PewterCityText9
	db $9, $f, $a ; PewterCityText10
	db $11, $b, $b ; PewterCityText11
	db $17, $19, $c ; PewterCityText12

	db $5 ; people
	db SPRITE_LASS, $f + 4, $8 + 4, $ff, $ff, $1 ; person
	db SPRITE_BLACK_HAIR_BOY_1, $19 + 4, $11 + 4, $ff, $ff, $2 ; person
	db SPRITE_BLACK_HAIR_BOY_2, $11 + 4, $1b + 4, $ff, $ff, $3 ; person
	db SPRITE_BLACK_HAIR_BOY_2, $19 + 4, $1a + 4, $fe, $2, $4 ; person
	db SPRITE_BUG_CATCHER, $10 + 4, $23 + 4, $ff, $d0, $5 ; person

	; warp-to
	EVENT_DISP $14, $7, $e ; MUSEUM_1F
	EVENT_DISP $14, $5, $13 ; MUSEUM_1F
	EVENT_DISP $14, $11, $10 ; PEWTER_GYM
	EVENT_DISP $14, $d, $1d ; PEWTER_HOUSE_1
	EVENT_DISP $14, $11, $17 ; PEWTER_MART
	EVENT_DISP $14, $1d, $7 ; PEWTER_HOUSE_2
	EVENT_DISP $14, $19, $d ; PEWTER_POKECENTER

PewterCityBlocks: ; 0x185e6 360
	INCBIN "maps/pewtercity.blk"

CeruleanCity_h: ; 0x1874e to 0x18786 (56 bytes) (bank=6) (id=3)
	db $00 ; tileset
	db CERULEAN_CITY_HEIGHT, CERULEAN_CITY_WIDTH ; dimensions (y, x)
	dw CeruleanCityBlocks, CeruleanCityTexts, CeruleanCityScript ; blocks, texts, scripts
	db NORTH | SOUTH | WEST | EAST ; connections

	; connections data

	db ROUTE_24
	dw Route24Blocks + (ROUTE_24_HEIGHT - 3) * ROUTE_24_WIDTH ; connection strip location
	dw $C6EB + 5 ; current map position
	db ROUTE_24_WIDTH, ROUTE_24_WIDTH ; bigness, width
	db (ROUTE_24_HEIGHT * 2) - 1, (5 * -2) ; alignments (y, x)
	dw $C6E9 + ROUTE_24_HEIGHT * (ROUTE_24_WIDTH + 6) ; window

	db ROUTE_5
	dw Route5Blocks ; connection strip location
	dw $C6EB + (CERULEAN_CITY_HEIGHT + 3) * (CERULEAN_CITY_WIDTH + 6) + 5 ; current map position
	db ROUTE_5_WIDTH, ROUTE_5_WIDTH ; bigness, width
	db 0, (5 * -2) ; alignments (y, x)
	dw $C6EF + ROUTE_5_WIDTH ; window

	db ROUTE_4
	dw Route4Blocks - 3 + (ROUTE_4_WIDTH) ; connection strip location
	dw $C6E8 + (CERULEAN_CITY_WIDTH + 6) * (4 + 3) ; current map position
	db ROUTE_4_HEIGHT, ROUTE_4_WIDTH ; bigness, width
	db (4 * -2), (ROUTE_4_WIDTH * 2) - 1 ; alignments (y, x)
	dw $C6EE + 2 * ROUTE_4_WIDTH ; window

	db ROUTE_9
	dw Route9Blocks + (ROUTE_9_WIDTH * 0) ; connection strip location
	dw $C6E5 + (CERULEAN_CITY_WIDTH + 6) * (4 + 4) ; current map position
	db ROUTE_9_HEIGHT, ROUTE_9_WIDTH ; bigness, width
	db (4 * -2), 0 ; alignments (y, x)
	dw $C6EF + ROUTE_9_WIDTH ; window

	; end connections data

	dw CeruleanCityObject ; objects

CeruleanCityObject: ; 0x18786 (size=170)
	db $f ; border tile

	db $a ; warps
	db $b, $1b, $0, TRASHED_HOUSE
	db $f, $d, $0, CERULEAN_HOUSE
	db $11, $13, $0, CERULEAN_POKECENTER
	db $13, $1e, $0, CERULEAN_GYM
	db $19, $d, $0, BIKE_SHOP
	db $19, $19, $0, CERULEAN_MART
	db $b, $4, $0, UNKNOWN_DUNGEON_1
	db $9, $1b, $2, TRASHED_HOUSE
	db $b, $9, $1, CERULEAN_HOUSE_3
	db $9, $9, $0, CERULEAN_HOUSE_3

	db $6 ; signs
	db $13, $17, $c ; CeruleanCityText12
	db $1d, $11, $d ; CeruleanCityText13
	db $19, $1a, $e ; CeruleanCityText14
	db $11, $14, $f ; CeruleanCityText15
	db $19, $b, $10 ; CeruleanCityText16
	db $15, $1b, $11 ; CeruleanCityText17

	db $b ; people
	db SPRITE_BLUE, $2 + 4, $14 + 4, $ff, $d0, $1 ; person
	db SPRITE_ROCKET, $8 + 4, $1e + 4, $ff, $ff, $42, ROCKET + $C8, $5 ; trainer
	db SPRITE_BLACK_HAIR_BOY_1, $14 + 4, $1f + 4, $ff, $d0, $3 ; person
	db SPRITE_BLACK_HAIR_BOY_2, $12 + 4, $f + 4, $fe, $1, $4 ; person
	db SPRITE_BLACK_HAIR_BOY_2, $15 + 4, $9 + 4, $fe, $2, $5 ; person
	db SPRITE_GUARD, $c + 4, $1c + 4, $ff, $d0, $6 ; person
	db SPRITE_LASS, $1a + 4, $1d + 4, $ff, $d2, $7 ; person
	db SPRITE_SLOWBRO, $1a + 4, $1c + 4, $ff, $d0, $8 ; person
	db SPRITE_LASS, $1b + 4, $9 + 4, $fe, $2, $9 ; person
	db SPRITE_BLACK_HAIR_BOY_2, $c + 4, $4 + 4, $ff, $d0, $a ; person
	db SPRITE_GUARD, $c + 4, $1b + 4, $ff, $d0, $b ; person

	; warp-to
	EVENT_DISP $14, $b, $1b ; TRASHED_HOUSE
	EVENT_DISP $14, $f, $d ; CERULEAN_HOUSE
	EVENT_DISP $14, $11, $13 ; CERULEAN_POKECENTER
	EVENT_DISP $14, $13, $1e ; CERULEAN_GYM
	EVENT_DISP $14, $19, $d ; BIKE_SHOP
	EVENT_DISP $14, $19, $19 ; CERULEAN_MART
	EVENT_DISP $14, $b, $4 ; UNKNOWN_DUNGEON_1
	EVENT_DISP $14, $9, $1b ; TRASHED_HOUSE
	EVENT_DISP $14, $b, $9 ; CERULEAN_HOUSE_3
	EVENT_DISP $14, $9, $9 ; CERULEAN_HOUSE_3

CeruleanCityBlocks: ; 0x18830 360
	INCBIN "maps/ceruleancity.blk"

VermilionCity_h: ; 0x18998 to 0x189ba (34 bytes) (bank=6) (id=5)
	db $00 ; tileset
	db VERMILION_CITY_HEIGHT, VERMILION_CITY_WIDTH ; dimensions (y, x)
	dw VermilionCityBlocks, VermilionCityTexts, VermilionCityScript ; blocks, texts, scripts
	db NORTH | EAST ; connections

	; connections data

	db ROUTE_6
	dw Route6Blocks + (ROUTE_6_HEIGHT - 3) * ROUTE_6_WIDTH ; connection strip location
	dw $C6EB + 5 ; current map position
	db ROUTE_6_WIDTH, ROUTE_6_WIDTH ; bigness, width
	db (ROUTE_6_HEIGHT * 2) - 1, (5 * -2) ; alignments (y, x)
	dw $C6E9 + ROUTE_6_HEIGHT * (ROUTE_6_WIDTH + 6) ; window

	db ROUTE_11
	dw Route11Blocks + (ROUTE_11_WIDTH * 0) ; connection strip location
	dw $C6E5 + (VERMILION_CITY_WIDTH + 6) * (4 + 4) ; current map position
	db ROUTE_11_HEIGHT, ROUTE_11_WIDTH ; bigness, width
	db (4 * -2), 0 ; alignments (y, x)
	dw $C6EF + ROUTE_11_WIDTH ; window

	; end connections data

	dw VermilionCityObject ; objects

VermilionCityObject: ; 0x189ba (size=133)
	db $43 ; border tile

	db $9 ; warps
	db $3, $b, $0, VERMILION_POKECENTER
	db $d, $9, $0, POKEMON_FAN_CLUB
	db $d, $17, $0, VERMILION_MART
	db $13, $c, $0, VERMILION_GYM
	db $13, $17, $0, VERMILION_HOUSE_1
	db $1f, $12, $0, VERMILION_DOCK
	db $1f, $13, $0, VERMILION_DOCK
	db $d, $f, $0, VERMILION_HOUSE_3
	db $3, $7, $0, VERMILION_HOUSE_2

	db $7 ; signs
	db $3, $1b, $7 ; VermilionCityText7
	db $d, $25, $8 ; VermilionCityText8
	db $d, $18, $9 ; VermilionCityText9
	db $3, $c, $a ; VermilionCityText10
	db $d, $7, $b ; VermilionCityText11
	db $13, $7, $c ; VermilionCityText12
	db $f, $1d, $d ; VermilionCityText13

	db $6 ; people
	db SPRITE_FOULARD_WOMAN, $7 + 4, $13 + 4, $fe, $2, $1 ; person
	db SPRITE_GAMBLER, $6 + 4, $e + 4, $ff, $ff, $2 ; person
	db SPRITE_SAILOR, $1e + 4, $13 + 4, $ff, $d1, $3 ; person
	db SPRITE_GAMBLER, $7 + 4, $1e + 4, $ff, $ff, $4 ; person
	db SPRITE_SLOWBRO, $9 + 4, $1d + 4, $fe, $1, $5 ; person
	db SPRITE_SAILOR, $1b + 4, $19 + 4, $fe, $2, $6 ; person

	; warp-to
	EVENT_DISP $14, $3, $b ; VERMILION_POKECENTER
	EVENT_DISP $14, $d, $9 ; POKEMON_FAN_CLUB
	EVENT_DISP $14, $d, $17 ; VERMILION_MART
	EVENT_DISP $14, $13, $c ; VERMILION_GYM
	EVENT_DISP $14, $13, $17 ; VERMILION_HOUSE_1
	EVENT_DISP $14, $1f, $12 ; VERMILION_DOCK
	EVENT_DISP $14, $1f, $13 ; VERMILION_DOCK
	EVENT_DISP $14, $d, $f ; VERMILION_HOUSE_3
	EVENT_DISP $14, $3, $7 ; VERMILION_HOUSE_2

VermilionCityBlocks: ; 0x18a3f 360
	INCBIN "maps/vermilioncity.blk"

FuchsiaCity_h: ; 0x18ba7 to 0x18bd4 (45 bytes) (bank=6) (id=7)
	db $00 ; tileset
	db FUCHSIA_CITY_HEIGHT, FUCHSIA_CITY_WIDTH ; dimensions (y, x)
	dw FuchsiaCityBlocks, FuchsiaCityTexts, FuchsiaCityScript ; blocks, texts, scripts
	db SOUTH | WEST | EAST ; connections

	; connections data

	db ROUTE_19
	dw Route19Blocks ; connection strip location
	dw $C6EB + (FUCHSIA_CITY_HEIGHT + 3) * (FUCHSIA_CITY_WIDTH + 6) + 5 ; current map position
	db ROUTE_19_WIDTH, ROUTE_19_WIDTH ; bigness, width
	db 0, (5 * -2) ; alignments (y, x)
	dw $C6EF + ROUTE_19_WIDTH ; window

	db ROUTE_18
	dw Route18Blocks - 3 + (ROUTE_18_WIDTH) ; connection strip location
	dw $C6E8 + (FUCHSIA_CITY_WIDTH + 6) * (4 + 3) ; current map position
	db ROUTE_18_HEIGHT, ROUTE_18_WIDTH ; bigness, width
	db (4 * -2), (ROUTE_18_WIDTH * 2) - 1 ; alignments (y, x)
	dw $C6EE + 2 * ROUTE_18_WIDTH ; window

	db ROUTE_15
	dw Route15Blocks + (ROUTE_15_WIDTH * 0) ; connection strip location
	dw $C6E5 + (FUCHSIA_CITY_WIDTH + 6) * (4 + 4) ; current map position
	db ROUTE_15_HEIGHT, ROUTE_15_WIDTH ; bigness, width
	db (4 * -2), 0 ; alignments (y, x)
	dw $C6EF + ROUTE_15_WIDTH ; window

	; end connections data

	dw FuchsiaCityObject ; objects

FuchsiaCityObject: ; 0x18bd4 (size=178)
	db $f ; border tile

	db $9 ; warps
	db $d, $5, $0, FUCHSIA_MART
	db $1b, $b, $0, FUCHSIA_HOUSE_1
	db $1b, $13, $0, FUCHSIA_POKECENTER
	db $1b, $1b, $0, FUCHSIA_HOUSE_2
	db $3, $12, $0, SAFARIZONEENTRANCE
	db $1b, $5, $0, FUCHSIA_GYM
	db $d, $16, $0, FUCHSIAMEETINGROOM
	db $1b, $1f, $1, FUCHSIA_HOUSE_3
	db $18, $1f, $0, FUCHSIA_HOUSE_3

	db $e ; signs
	db $17, $f, $b ; FuchsiaCityText11
	db $f, $19, $c ; FuchsiaCityText12
	db $5, $11, $d ; FuchsiaCityText13
	db $d, $6, $e ; FuchsiaCityText14
	db $1b, $14, $f ; FuchsiaCityText15
	db $1d, $1b, $10 ; FuchsiaCityText16
	db $f, $15, $11 ; FuchsiaCityText17
	db $1d, $5, $12 ; FuchsiaCityText18
	db $7, $21, $13 ; FuchsiaCityText19
	db $7, $1b, $14 ; FuchsiaCityText20
	db $7, $d, $15 ; FuchsiaCityText21
	db $d, $1f, $16 ; FuchsiaCityText22
	db $f, $d, $17 ; FuchsiaCityText23
	db $7, $7, $18 ; FuchsiaCityText24

	db $a ; people
	db SPRITE_BUG_CATCHER, $c + 4, $a + 4, $fe, $2, $1 ; person
	db SPRITE_GAMBLER, $11 + 4, $1c + 4, $fe, $2, $2 ; person
	db SPRITE_FISHER2, $e + 4, $1e + 4, $ff, $d0, $3 ; person
	db SPRITE_BUG_CATCHER, $8 + 4, $18 + 4, $ff, $d1, $4 ; person
	db SPRITE_CLEFAIRY, $5 + 4, $1f + 4, $fe, $0, $5 ; person
	db SPRITE_BALL, $6 + 4, $19 + 4, $ff, $ff, $6 ; person
	db SPRITE_SLOWBRO, $6 + 4, $c + 4, $fe, $2, $7 ; person
	db SPRITE_SLOWBRO, $c + 4, $1e + 4, $fe, $2, $8 ; person
	db SPRITE_SEEL, $11 + 4, $8 + 4, $fe, $0, $9 ; person
	db SPRITE_OMANYTE, $5 + 4, $6 + 4, $ff, $ff, $a ; person

	; warp-to
	EVENT_DISP $14, $d, $5 ; FUCHSIA_MART
	EVENT_DISP $14, $1b, $b ; FUCHSIA_HOUSE_1
	EVENT_DISP $14, $1b, $13 ; FUCHSIA_POKECENTER
	EVENT_DISP $14, $1b, $1b ; FUCHSIA_HOUSE_2
	EVENT_DISP $14, $3, $12 ; SAFARIZONEENTRANCE
	EVENT_DISP $14, $1b, $5 ; FUCHSIA_GYM
	EVENT_DISP $14, $d, $16 ; FUCHSIAMEETINGROOM
	EVENT_DISP $14, $1b, $1f ; FUCHSIA_HOUSE_3
	EVENT_DISP $14, $18, $1f ; FUCHSIA_HOUSE_3

FuchsiaCityBlocks: ; 0x18c86 360
	INCBIN "maps/fuchsiacity.blk"

INCBIN "baserom.gbc",$18dee,$6d

PalletTownScript:
	ld a,[$D74B]
	bit 4,a
	jr z,.next\@
	ld hl,$D747
	set 6,[hl]
.next\@
	call $3C3C
	ld hl,PalletTownScriptPointers
	ld a,[$D5F1]
	jp $3D97
; 0x18e73

PalletTownScriptPointers:
	dw PalletTownScript1,PalletTownScript2,PalletTownScript3,PalletTownScript4,PalletTownScript5,PalletTownScript6,PalletTownScript7

PalletTownScript1:
	ld a,[$D747]
	bit 0,a
	ret nz
	ld a,[W_YCOORD]
	cp 1 ; is player near north exit?
	ret nz
	xor a
	ld [$FFB4],a
	ld a,4
	ld [$D528],a
	ld a,$FF
	call $23B1 ; stop music
	ld a,2
	ld c,a ; song bank
	ld a,$DB ; “oak appears” music
	call $23A1 ; plays music
	ld a,$FC
	ld [$CD6B],a
	ld hl,$D74B
	set 7,[hl]

	; trigger the next script
	ld a,1
	ld [$D5F1],a
	ret

PalletTownScript2:
	xor a
	ld [$CF0D],a
	ld a,1
	ld [$FF8C],a
	call $2920
	ld a,$FF
	ld [$CD6B],a
	ld a,0
	ld [$CC4D],a
	ld a,$15
	call Predef

	; trigger the next script
	ld a,2
	ld [$D5F1],a
	ret

PalletTownScript3:
	ld a,1
	ld [$FF8C],a
	ld a,4
	ld [$FF8D],a
	call $34A6
	call Delay3
	ld a,1
	ld [W_YCOORD],a
	ld a,1
	ld [$FF9B],a
	ld a,1
	swap a
	ld [$FF95],a
	ld a,$22
	call Predef
	ld hl,$FF95
	dec [hl]
	ld a,$20
	call Predef ; load Oak’s movement into $CC97
	ld de,$CC97
	ld a,1 ; oak
	ld [$FF8C],a
	call MoveSprite
	ld a,$FF
	ld [$CD6B],a

	; trigger the next script
	ld a,3
	ld [$D5F1],a
	ret

PalletTownScript4:
	ld a,[$D730]
	bit 0,a
	ret nz
	xor a
	ld [$C109],a
	ld a,1
	ld [$CF0D],a
	ld a,$FC
	ld [$CD6B],a
	ld a,1
	ld [$FF8C],a
	call $2920
	ld a,$FF
	ld [$CD6B],a
	ld a,1
	ld [$CF13],a
	xor a
	ld [$CF10],a
	ld a,1
	ld [$CC57],a
	ld a,[$FFB8]
	ld [$CC58],a

	; trigger the next script
	ld a,4
	ld [$D5F1],a
	ret

PalletTownScript5:
	ld a,[$CC57]
	and a
	ret nz

	; trigger the next script
	ld a,5
	ld [$D5F1],a
	ret

PalletTownScript6:
	ld a,[$D74A]
	bit 2,a
	jr nz,.next\@
	and 3
	cp 3
	jr nz,.next\@
	ld hl,$D74A
	set 2,[hl]
	ld a,$27
	ld [$CC4D],a
	ld a,$11
	call Predef
	ld a,$28
	ld [$CC4D],a
	ld a,$15
	jp Predef
.next\@
	ld a,[$D74B]
	bit 4,a
	ret z
	ld hl,$D74B
	set 6,[hl]
PalletTownScript7:
	ret

PalletTownTexts: ; 0x18f88
	dw PalletTownText1,PalletTownText2,PalletTownText3,PalletTownText4,PalletTownText5,PalletTownText6,PalletTownText7

PalletTownText1: ; 4F96 0x18f96
	db 8
	ld a,[$CF0D]
	and a
	jr nz,.next\@
	ld a,1
	ld [$CC3C],a
	ld hl,OakAppearsText
	jr .done\@
.next\@
	ld hl,OakWalksUpText
.done\@
	call PrintText
	jp TextScriptEnd

OakAppearsText:
	TX_FAR _OakAppearsText
	db 8
	ld c,10
	call DelayFrames
	xor a
	ld [$CD4F],a
	ld [$CD50],a
	ld a,$4C
	call Predef ; display ! over head
	ld a,4
	ld [$D528],a
	jp TextScriptEnd

OakWalksUpText:
	TX_FAR _OakWalksUpText
	db "@"

PalletTownText2: ; 0x18fd3 girl
	TX_FAR _PalletTownText2 ; dc 42 29 pointing to 0xa42dc
	db "@"
; 0x18fd8

PalletTownText3: ; 0x18fd8 fat man
	TX_FAR _PalletTownText3
	db "@"
; 0x18fdd

PalletTownText4: ; 0x18fdd sign by lab
	TX_FAR _PalletTownText4
	db "@"
; 0x18fe2

PalletTownText5: ; 0x18fe2 sign by fence
	TX_FAR _PalletTownText5
	db "@"
; 0x18fe7

PalletTownText6: ; 0x18fe7 sign by Red’s house
	TX_FAR _PalletTownText6
	db "@"
; 0x18fec

PalletTownText7: ; 0x18fec sign by Blue’s house
	TX_FAR _PalletTownText7
	db "@"

ViridianCityScript: ; 0x18ff1
	call $3c3c
	ld hl, ViridianCityScripts
	ld a, [$d5f4]
	jp $3d97
; 0x18ffd

ViridianCityScripts: ; 0x18ffd
	dw ViridianCityScript0

INCBIN "baserom.gbc",$18fff,$6

ViridianCityScript0: ; 0x19005
	call $500b
	jp $503d
; 0x1900b

INCBIN "baserom.gbc",$1900b,$d9

ViridianCityTexts: ; 0x190e4
	dw ViridianCityText1, ViridianCityText2, ViridianCityText3, ViridianCityText4, ViridianCityText5, ViridianCityText6, ViridianCityText7, ViridianCityText8, ViridianCityText9, ViridianCityText10, ViridianCityText11, ViridianCityText12, ViridianCityText13, ViridianCityText14, ViridianCityText15

ViridianCityText1: ; 0x19102
	TX_FAR _ViridianCityText1
	db $50

ViridianCityText2: ; 0x19107
	db $08 ; asm
	ld a, [$d356]
	cp $7f
	ld hl, UnnamedText_19127
	jr z, .asm_ae9fe ; 0x19110
	ld a, [$d751]
	bit 1, a
	jr nz, .asm_ae9fe ; 0x19117
	ld hl, UnnamedText_19122
.asm_ae9fe ; 0x1911c
	call PrintText
	jp TextScriptEnd

UnnamedText_19122: ; 0x19122
	TX_FAR _UnnamedText_19122
	db $50
; 0x19122 + 5 bytes

UnnamedText_19127: ; 0x19127
	TX_FAR _UnnamedText_19127
	db $50
; 0x19127 + 5 bytes

ViridianCityText3: ; 0x1912c
	db $08 ; asm
	ld hl, UnnamedText_1914d
	call PrintText
	call $35ec
	ld a, [$cc26]
	and a
	jr nz, .asm_6dfea ; 0x1913a
	ld hl, UnnamedText_19157
	call PrintText
	jr .asm_d611f ; 0x19142
.asm_6dfea ; 0x19144
	ld hl, UnnamedText_19152
	call PrintText
.asm_d611f ; 0x1914a
	jp TextScriptEnd

UnnamedText_1914d: ; 0x1914d
	TX_FAR _UnnamedText_1914d
	db $50
; 0x1914d + 5 bytes

UnnamedText_19152: ; 0x19152
	TX_FAR _UnnamedText_19152
	db $50
; 0x19152 + 5 bytes

UnnamedText_19157: ; 0x19157
	TX_FAR _UnnamedText_19157
	db $50
; 0x19157 + 5 bytes

ViridianCityText4: ; 0x1915c
	db $08 ; asm
	ld a, [$d74b]
	bit 5, a
	jr nz, .asm_83894 ; 0x19162
	ld hl, UnnamedText_19175
	call PrintText
	jr .asm_700a6 ; 0x1916a
.asm_83894 ; 0x1916c
	ld hl, UnnamedText_1917a
	call PrintText
.asm_700a6 ; 0x19172
	jp TextScriptEnd

UnnamedText_19175: ; 0x19175
	TX_FAR _UnnamedText_19175
	db $50
; 0x19175 + 5 bytes

UnnamedText_1917a: ; 0x1917a
	TX_FAR _UnnamedText_1917a
	db $50
; 0x1917a + 5 bytes

ViridianCityText5: ; 0x1917f
	db $08 ; asm
	ld hl, UnnamedText_19191
	call PrintText
	call $50cf
	ld a, $3
	ld [$d5f4], a
	jp TextScriptEnd

UnnamedText_19191: ; 0x19191
	TX_FAR _UnnamedText_19191
	db $50
; 0x19191 + 5 bytes

ViridianCityText6: ; 0x19196
	db $08 ; asm
	ld a, [$d74c]
	bit 1, a
	jr nz, .asm_4e5a0 ; 0x1919c
	ld hl, UnnamedText_191ca
	call PrintText
	ld bc, (TM_42 << 8) | 1
	call GiveItem
	jr nc, .asm_b655e ; 0x191aa
	ld hl, ReceivedTM42Text
	call PrintText
	ld hl, $d74c
	set 1, [hl]
	jr .asm_3c73c ; 0x191b7
.asm_b655e ; 0x191b9
	ld hl, TM42NoRoomText
	call PrintText
	jr .asm_3c73c ; 0x191bf
.asm_4e5a0 ; 0x191c1
	ld hl, TM42Explanation
	call PrintText
.asm_3c73c ; 0x191c7
	jp TextScriptEnd

UnnamedText_191ca: ; 0x191ca
	TX_FAR _UnnamedText_191ca
	db $50
; 0x191ca + 5 bytes

ReceivedTM42Text: ; 0x191cf
	TX_FAR _ReceivedTM42Text ; 0xa469a
	db $10, $50
; 0x191cf + 6 bytes = 0x191d5

TM42Explanation: ; 0x191d5
	TX_FAR _TM42Explanation
	db $50
; 0x191d5 + 5 bytes

TM42NoRoomText: ; 0x191da
	TX_FAR _TM42NoRoomText
	db $50
; 0x191da + 5 bytes

ViridianCityText7: ; 0x191df
	db $08 ; asm
	ld hl, UnnamedText_1920a
	call PrintText
	ld c, $2
	call $3739
	call $35ec
	ld a, [$cc26]
	and a
	jr z, .asm_42f68 ; 0x191f2
	ld hl, UnnamedText_1920f
	call PrintText
	ld a, $1
	ld [$d5f4], a
	jr .asm_2413a ; 0x191ff
.asm_42f68 ; 0x19201
	ld hl, UnnamedText_19214
	call PrintText
.asm_2413a ; 0x19207
	jp TextScriptEnd

UnnamedText_1920a: ; 0x1920a
	TX_FAR _UnnamedText_1920a
	db $50
; 0x1920a + 5 bytes

UnnamedText_1920f: ; 0x1920f
	TX_FAR _UnnamedText_1920f
	db $50
; 0x1920f + 5 bytes

UnnamedText_19214: ; 0x19214
	TX_FAR _UnnamedText_19214
	db $50
; 0x19214 + 5 bytes

ViridianCityText15: ; 0x19219
	TX_FAR _UnnamedText_19219
	db $50
; 0x19219 + 5 bytes

ViridianCityText8: ; 0x1921e
	TX_FAR _ViridianCityText8
	db $50

ViridianCityText9: ; 0x19223
	TX_FAR _ViridianCityText9
	db $50

ViridianCityText10: ; 0x19228
	TX_FAR _ViridianCityText10
	db $50

ViridianCityText13: ; 0x1922d
	TX_FAR _ViridianCityText13
	db $50

ViridianCityText14: ; 0x19232
	TX_FAR _ViridianCityText14
	db $50
; 0x19232 + 5 bytes

PewterCityScript: ; 0x19237
	call $3c3c
	ld hl, PewterCityScripts
	ld a, [$d5f7]
	jp $3d97
; 0x19243

PewterCityScripts: ; 0x19243
	dw PewterCityScript0

INCBIN "baserom.gbc",$19245,$c

PewterCityScript0: ; 0x19251
	xor a
	ld [$d619], a
	ld hl, $d754
	res 0, [hl]
	call $525e
	ret
; 0x1925e

INCBIN "baserom.gbc",$1925e,$12d

PewterCityTexts: ; 0x1938b
	dw PewterCityText1, PewterCityText2, PewterCityText3, PewterCityText4, PewterCityText5, PewterCityText6, PewterCityText7, PewterCityText8, PewterCityText9, PewterCityText10, PewterCityText11, PewterCityText12, PewterCityText13, PewterCityText14

PewterCityText1: ; 0x193a7
	TX_FAR _PewterCityText1
	db $50

PewterCityText2: ; 0x193ac
	TX_FAR _PewterCityText2
	db $50

PewterCityText3: ; 0x193b1
	db $08 ; asm
	ld hl, UnnamedText_193f1
	call PrintText
	call $35ec
	ld a, [$cc26]
	and a
	jr nz, .asm_f46a9 ; 0x193bf
	ld hl, UnnamedText_193f6
	call PrintText
	jr .asm_ac429 ; 0x193c7
.asm_f46a9 ; 0x193c9
	ld hl, UnnamedText_193fb
	call PrintText
	xor a
	ldh [$b3], a
	ldh [$b4], a
	ld [$cf10], a
	ld a, $2
	ld [$cc57], a
	ldh a, [$b8]
	ld [$cc58], a
	ld a, $3
	ld [$cf13], a
	call $32f4
	ld a, $1
	ld [$d5f7], a
.asm_ac429 ; 0x193ee
	jp TextScriptEnd

UnnamedText_193f1: ; 0x193f1
	TX_FAR _UnnamedText_193f1
	db $50
; 0x193f1 + 5 bytes

UnnamedText_193f6: ; 0x193f6
	TX_FAR _UnnamedText_193f6
	db $50
; 0x193f6 + 5 bytes

UnnamedText_193fb: ; 0x193fb
	TX_FAR _UnnamedText_193fb
	db $50
; 0x193fb + 5 bytes

PewterCityText13:

UnnamedText_19400: ; 0x19400
	TX_FAR _UnnamedText_19400
	db $50
; 0x19400 + 5 bytes

PewterCityText4: ; 0x19405
	db $8
	ld hl, UnnamedText_19427
	call PrintText
	call $35ec
	ld a, [$cc26]
	cp $0
	jr nz, .asm_e4603
	ld hl, UnnamedText_1942c
	call PrintText
	jr .asm_e4604 ; 0x1941c $6
.asm_e4603
	ld hl, UnnamedText_19431
	call PrintText
.asm_e4604 ; 0x19424
	jp TextScriptEnd
; 0x19427

UnnamedText_19427: ; 0x19427
	TX_FAR _UnnamedText_19427
	db $50
; 0x19427 + 5 bytes

UnnamedText_1942c: ; 0x1942c
	TX_FAR _UnnamedText_1942c
	db $50
; 0x1942c + 5 bytes

UnnamedText_19431: ; 0x19431
	TX_FAR _UnnamedText_19431
	db $50
; 0x19431 + 5 bytes

PewterCityText5: ; 0x19436
	db $08 ; asm
	ld hl, UnnamedText_1945d
	call PrintText
	xor a
	ldh [$b4], a
	ld [$cf10], a
	ld a, $3
	ld [$cc57], a
	ldh a, [$b8]
	ld [$cc58], a
	ld a, $5
	ld [$cf13], a
	call $32f4
	ld a, $4
	ld [$d5f7], a
	jp TextScriptEnd

UnnamedText_1945d: ; 0x1945d
	TX_FAR _UnnamedText_1945d
	db $50
; 0x1945d + 5 bytes

PewterCityText14: ; 0x19462

UnnamedText_19462: ; 0x19462
	TX_FAR _UnnamedText_19462
	db $50
; 0x19462 + 5 bytes

PewterCityText6: ; 0x19467
	TX_FAR _PewterCityText6
	db $50

PewterCityText7: ; 0x1946c
	TX_FAR _PewterCityText7
	db $50

PewterCityText10: ; 0x19471
	TX_FAR _PewterCityText10
	db $50

PewterCityText11: ; 0x19476
	TX_FAR _PewterCityText11
	db $50

PewterCityText12: ; 0x1947b
	TX_FAR _PewterCityText12
	db $50

CeruleanCityScript: ; 0x19480
	call $3c3c
	ld hl, CeruleanCityScripts
	ld a, [$d60f]
	jp $3d97
; 0x1948c

INCBIN "baserom.gbc",$1948c,$1949d - $1948c

CeruleanCityScripts: ; 0x1949d
	dw CeruleanCityScript0, CeruleanCityScript1, CeruleanCityScript2, CeruleanCityScript3

INCBIN "baserom.gbc",$194a5,$23

CeruleanCityScript0: ; 0x194c8
	ld a, [$d75b]
	bit 7, a
	jr nz, .asm_194f7 ; 0x194cd $28
	ld hl, $554f
	call $34bf
	jr nc, .asm_194f7 ; 0x194d5 $20
	ld a, [$cd3d]
	cp $1
	ld a, $8
	ld b, $0
	jr nz, .asm_194e6 ; 0x194e0 $4
	ld a, $4
	ld b, $4
.asm_194e6
	ld [$d528], a
	ld a, b
	ld [$c129], a
	call Delay3
	ld a, $2
	ld [$ff00+$8c], a
	jp $2920
.asm_194f7
	ld a, [$d75a]
	bit 0, a
	ret nz
	ld hl, $5554
	call $34bf
	ret nc
	ld a, [$d700]
	and a
	jr z, .asm_19512 ; 0x19508 $8
	ld a, $ff
	ld [$c0ee], a
	call $23b1
.asm_19512
	ld c, $2
	ld a, $de
	call $23a1
	xor a
	ld [$ff00+$b4], a
	ld a, $f0
	ld [$cd6b], a
	ld a, [$d362]
	cp $14
	jr z, .asm_19535 ; 0x19526 $d
	ld a, $1
	ld [$ff00+$8c], a
	ld a, $5
	ld [$ff00+$8b], a
	call $3500
	ld [hl], $19
.asm_19535
	ld a, $5
	ld [$cc4d], a
	ld a, $15
	call Predef
	ld de, $5559
	ld a, $1
	ld [$ff00+$8c], a
	call $363a
	ld a, $1
	ld [$d60f], a
	ret
; 0x1954f

INCBIN "baserom.gbc",$1954f,$19567 - $1954f

CeruleanCityScript1: ; 0x19567
	ld a, [$d730]
	bit 0, a
	ret nz
	xor a
	ld [$cd6b], a
	ld a, $1
	ld [$ff00+$8c], a
	call $2920
	ld hl, $d72d
	set 6, [hl]
	set 7, [hl]
	ld hl, UnnamedText_1966d
	ld de, UnnamedText_19672
	call $3354
	ld a, $e1
	ld [$d059], a

	; select which team to use during the encounter
	ld a, [W_RIVALSTARTER]
	cp SQUIRTLE
	jr nz, .NotSquirtle\@ ; 0x19592 $4
	ld a, $7
	jr .done\@
.NotSquirtle\@
	cp BULBASAUR
	jr nz, .Charmander\@ ; 0x1959a $4
	ld a, $8
	jr .done\@
.Charmander\@
	ld a, $9
.done\@
	ld [W_TRAINERNO], a

	xor a
	ld [$ff00+$b4], a
	call $555d
	ld a, $2
	ld [$d60f], a
	ret
; 0x195b1

CeruleanCityScript2: ; 0x195b1
	ld a, [$d057]
	cp $ff
	jp z, $548c
	call $555d
	ld a, $f0
	ld [$cd6b], a
	ld hl, $d75a
	set 0, [hl]
	ld a, $1
	ld [$ff00+$8c], a
	call $2920
	ld a, $ff
	ld [$c0ee], a
	call $23b1
	ld b, $2
	ld hl, $5b47
	call Bankswitch
	ld a, $1
	ld [$ff00+$8c], a
	call $3541
	ld a, [$d362]
	cp $14
	jr nz, .asm_195f0 ; 0x195e9 $5
	ld de, $5608
	jr .asm_195f3 ; 0x195ee $3
.asm_195f0
	ld de, $5600
.asm_195f3
	ld a, $1
	ld [$ff00+$8c], a
	call $363a
	ld a, $3
	ld [$d60f], a
	ret
; 0x19600

INCBIN "baserom.gbc",$19600,$19610 - $19600

CeruleanCityScript3: ; 0x19610
	ld a, [$d730]
	bit 0, a
	ret nz
	ld a, $5
	ld [$cc4d], a
	ld a, $11
	call Predef
	xor a
	ld [$cd6b], a
	call $2307
	ld a, $0
	ld [$d60f], a
	ret
; 0x1962d

CeruleanCityTexts: ; 0x1962d
	dw CeruleanCityText1, CeruleanCityText2, CeruleanCityText3, CeruleanCityText4, CeruleanCityText5, CeruleanCityText6, CeruleanCityText7, CeruleanCityText8, CeruleanCityText9, CeruleanCityText10, CeruleanCityText11, CeruleanCityText12, CeruleanCityText13, CeruleanCityText14, CeruleanCityText15, CeruleanCityText16, CeruleanCityText17

CeruleanCityText1: ; 0x1964f
	db $08 ; asm
	ld a, [$d75a] ; rival battle flag
	bit 0, a
	; do pre-battle text
	jr z, .PreBattleText
	; or talk about bill
	ld hl, UnnamedText_19677
	call PrintText
	jr .end ; 0x1965d
.PreBattleText ; 0x1965f
	ld hl, UnnamedText_19668
	call PrintText
.end ; 0x19665
	jp TextScriptEnd

UnnamedText_19668: ; 0x19668
	TX_FAR _UnnamedText_19668
	db $50
; 0x19668 + 5 bytes

UnnamedText_1966d: ; 0x1966d
	TX_FAR _UnnamedText_1966d
	db $50
; 0x1966d + 5 bytes

UnnamedText_19672: ; 0x19672
	TX_FAR _UnnamedText_19672
	db $50
; 0x19672 + 5 bytes

UnnamedText_19677: ; 0x19677
	TX_FAR _UnnamedText_19677
	db $50
; 0x19677 + 5 bytes

CeruleanCityText2: ; 0x1967c
	db $8
	ld a, [$d75b]
	bit 7, a
	jr nz, .asm_4ca20 ; 0x19682 $29
	ld hl, UnnamedText_196d9
	call PrintText
	ld hl, $d72d
	set 6, [hl]
	set 7, [hl]
	ld hl, UnnamedText_196ee
	ld de, UnnamedText_196ee
	call $3354
	ld a, [$ff00+$8c]
	ld [$cf13], a
	call $336a
	call $32d7
	ld a, $4
	ld [$d60f], a
	jp TextScriptEnd
.asm_4ca20 ; 0x196ad
	ld hl, UnnamedText_196f3
	call PrintText
	ld bc, $e401
	call GiveItem
	jr c, .asm_8bbbd ; 0x196b9 $8
	ld hl, TM28NoRoomText
	call PrintText
	jr .asm_e4e6f ; 0x196c1 $13
.asm_8bbbd ; 0x196c3
	ld a, $1
	ld [$cc3c], a
	ld hl, ReceivedTM28Text
	call PrintText
	ld b, BANK(Unnamed_ASM_74872)
	ld hl, Unnamed_ASM_74872
	call Bankswitch
.asm_e4e6f ; 0x196d6
	jp TextScriptEnd
; 0x196d9

UnnamedText_196d9: ; 0x196d9
	TX_FAR _UnnamedText_196d9
	db $50
; 0x196d9 + 5 bytes

ReceivedTM28Text: ; 0x196de
	TX_FAR _ReceivedTM28Text ; 0xa4f82
	db $0B
	TX_FAR _ReceivedTM28Text2 ; 0xa4f96
	db $0D, $50
; 0x196e9

TM28NoRoomText: ; 0x196e9
	TX_FAR _TM28NoRoomText
	db $50
; 0x196e9 + 5 bytes

UnnamedText_196ee: ; 0x196ee
	TX_FAR _UnnamedText_196ee
	db $50
; 0x196ee + 5 bytes

UnnamedText_196f3: ; 0x196f3
	TX_FAR _UnnamedText_196f3
	db $50
; 0x196f3 + 5 bytes

CeruleanCityText3: ; 0x196f8
	TX_FAR _CeruleanCityText3
	db $50

CeruleanCityText4: ; 0x196fd
	TX_FAR _CeruleanCityText4
	db $50

CeruleanCityText5: ; 0x19702
	TX_FAR _CeruleanCityText5
	db $50

CeruleanCityText11:
CeruleanCityText6: ; 0x19707
	TX_FAR _CeruleanCityText6
	db $50

CeruleanCityText7: ; 0x1970c
	db $08 ; asm
	ldh a, [$d3]
	cp $b4
	jr c, .asm_e9fc9 ; 0x19711
	ld hl, UnnamedText_19730
	call PrintText
	jr .asm_d486e ; 0x19719
.asm_e9fc9 ; 0x1971b
	cp $64
	jr c, .asm_df99b ; 0x1971d
	ld hl, UnnamedText_19735
	call PrintText
	jr .asm_d486e ; 0x19725
.asm_df99b ; 0x19727
	ld hl, UnnamedText_1973a
	call PrintText
.asm_d486e ; 0x1972d
	jp TextScriptEnd

UnnamedText_19730: ; 0x19730
	TX_FAR _UnnamedText_19730
	db $50
; 0x19730 + 5 bytes

UnnamedText_19735: ; 0x19735
	TX_FAR _UnnamedText_19735
	db $50
; 0x19735 + 5 bytes

UnnamedText_1973a: ; 0x1973a
	TX_FAR _UnnamedText_1973a
	db $50
; 0x1973a + 5 bytes

CeruleanCityText8: ; 0x1973f
	db $08 ; asm
	ldh a, [$d3]
	cp $b4
	jr c, .asm_e28da ; 0x19744
	ld hl, UnnamedText_1976f
	call PrintText
	jr .asm_f2f38 ; 0x1974c
.asm_e28da ; 0x1974e
	cp $78
	jr c, .asm_15d08 ; 0x19750
	ld hl, UnnamedText_19774
	call PrintText
	jr .asm_f2f38 ; 0x19758
.asm_15d08 ; 0x1975a
	cp $3c
	jr c, .asm_d7fea ; 0x1975c
	ld hl, UnnamedText_19779
	call PrintText
	jr .asm_f2f38 ; 0x19764
.asm_d7fea ; 0x19766
	ld hl, UnnamedText_1977e
	call PrintText
.asm_f2f38 ; 0x1976c
	jp TextScriptEnd

UnnamedText_1976f: ; 0x1976f
	TX_FAR _UnnamedText_1976f
	db $50
; 0x1976f + 5 bytes

UnnamedText_19774: ; 0x19774
	TX_FAR _UnnamedText_19774
	db $50
; 0x19774 + 5 bytes

UnnamedText_19779: ; 0x19779
	TX_FAR _UnnamedText_19779
	db $50
; 0x19779 + 5 bytes

UnnamedText_1977e: ; 0x1977e
	TX_FAR _UnnamedText_1977e
	db $50
; 0x1977e + 5 bytes

CeruleanCityText9: ; 0x19783
	TX_FAR _CeruleanCityText9
	db $50

CeruleanCityText10: ; 0x19788
	TX_FAR _CeruleanCityText10
	db $50

CeruleanCityText12: ; 0x1978d
	TX_FAR _CeruleanCityText12
	db $50

CeruleanCityText13: ; 0x19792
	TX_FAR _CeruleanCityText13
	db $50

CeruleanCityText16: ; 0x19797
	TX_FAR _CeruleanCityText16
	db $50

CeruleanCityText17: ; 0x1979c
	TX_FAR _CeruleanCityText17
	db $50

VermilionCityScript: ; 0x197a1
	call $3c3c
	ld hl, $d126
	bit 6, [hl]
	res 6, [hl]
	push hl
	call nz, $57cb
	pop hl
	bit 5, [hl]
	res 5, [hl]
	call nz, VermilionCityScript_Unknown197c0
	ld hl, VermilionCityScripts
	ld a, [$d62a]
	jp $3d97
; 0x197c0

VermilionCityScript_Unknown197c0: ; 0x197c0
INCBIN "baserom.gbc",$197c0,$197dc - $197c0

VermilionCityScripts: ; 0x197dc
	dw VermilionCityScript0, VermilionCityScript1

INCBIN "baserom.gbc",$197e0,$6

VermilionCityScript0: ; 0x197e6
	ld a, [$c109]
	and a
	ret nz
	ld hl, $5823
	call $34bf
	ret nc
	xor a
	ld [$ff00+$b4], a
	ld [$cf0d], a
	ld a, $3
	ld [$ff00+$8c], a
	call $2920
	ld a, [$d803]
	bit 2, a
	jr nz, .asm_19810 ; 0x19804 $a
	ld b, $3f
	ld a, $1c
	call Predef
	ld a, b
	and a
	ret nz
.asm_19810
	ld a, $40
	ld [$ccd3], a
	ld a, $1
	ld [$cd38], a
	call $3486
	ld a, $1
	ld [$d62a], a
	ret
; 0x19823

INCBIN "baserom.gbc",$19823,$1985f - $19823

VermilionCityScript1: ; 0x1985f
	ld a, [$cd38]
	and a
	ret nz
	ld c, $a
	call $3739
	ld a, $0
	ld [$d62a], a
	ret
; 0x1986f

VermilionCityTexts: ; 0x1986f
	dw VermilionCityText1, VermilionCityText2, VermilionCityText3, VermilionCityText4, VermilionCityText5, VermilionCityText6, VermilionCityText7, VermilionCityText8, VermilionCityText9, VermilionCityText10, VermilionCityText11, VermilionCityText12, VermilionCityText13

VermilionCityText1: ; 0x19889
	TX_FAR _VermilionCityText1
	db $50

VermilionCityText2: ; 0x1988e
	db $08 ; asm
	ld a, [$d803]
	bit 2, a
	jr nz, .asm_359bd ; 0x19894
	ld hl, UnnamedText_198a7
	call PrintText
	jr .asm_735d9 ; 0x1989c
.asm_359bd ; 0x1989e
	ld hl, UnnamedText_198ac
	call PrintText
.asm_735d9 ; 0x198a4
	jp TextScriptEnd

UnnamedText_198a7: ; 0x198a7
	TX_FAR _UnnamedText_198a7
	db $50
; 0x198a7 + 5 bytes

UnnamedText_198ac: ; 0x198ac
	TX_FAR _UnnamedText_198ac
	db $50
; 0x198ac + 5 bytes

VermilionCityText3: ; 0x198b1
	db $08 ; asm
	ld a, [$d803]
	bit 2, a
	jr nz, .asm_3e0e9 ; 0x198b7
	ld a, [$c109]
	cp $c
	jr z, .asm_07af3 ; 0x198be
	ld hl, $58ff
	call $34bf
	jr nc, .asm_57b73 ; 0x198c6
.asm_07af3 ; 0x198c8
	ld hl, SSAnneWelcomeText4
	call PrintText
	jr .asm_79bd1 ; 0x198ce
.asm_57b73 ; 0x198d0
	ld hl, SSAnneWelcomeText9
	call PrintText
	ld b, $3f
	ld a, $1c
	call Predef
	ld a, b
	and a
	jr nz, .asm_0419b ; 0x198df
	ld hl, SSAnneNoTicketText
	call PrintText
	jr .asm_79bd1 ; 0x198e7
.asm_0419b ; 0x198e9
	ld hl, SSAnneFlashedTicketText
	call PrintText
	ld a, $4
	ld [$d62a], a
	jr .asm_79bd1 ; 0x198f4
.asm_3e0e9 ; 0x198f6
	ld hl, SSAnneNotHereText
	call PrintText
.asm_79bd1 ; 0x198fc
	jp TextScriptEnd

INCBIN "baserom.gbc",$198ff,$19904 - $198ff

SSAnneWelcomeText4: ; 0x19904
	TX_FAR _SSAnneWelcomeText4
	db $50
; 0x19904 + 5 bytes

SSAnneWelcomeText9: ; 0x19909
	TX_FAR _SSAnneWelcomeText9
	db $50
; 0x19909 + 5 bytes

SSAnneFlashedTicketText: ; 0x1990e
	TX_FAR _SSAnneFlashedTicketText
	db $50
; 0x1990e + 5 bytes

SSAnneNoTicketText: ; 0x19913
	TX_FAR _SSAnneNoTicketText
	db $50
; 0x19913 + 5 bytes

SSAnneNotHereText: ; 0x19918
	TX_FAR _SSAnneNotHereText
	db $50
; 0x19918 + 5 bytes

VermilionCityText4: ; 0x1991d
	TX_FAR _VermilionCityText4
	db $50

VermilionCityText5: ; 0x19922
	TX_FAR _VermilionCityText5
	db $08 ; asm
	ld a, $6a
	call $13d0
	call $3748
	ld hl, $5933
	ret

VermilionCityText14: ; 0x19933
	TX_FAR _VermilionCityText14
	db $50

VermilionCityText6: ; 0x19938
	TX_FAR _VermilionCityText6
	db $50

VermilionCityText7: ; 0x1993d
	TX_FAR _VermilionCityText7
	db $50

VermilionCityText8: ; 0x19942
	TX_FAR _VermilionCityText8
	db $50

VermilionCityText11: ; 0x19947
	TX_FAR _VermilionCityText11
	db $50

VermilionCityText12: ; 0x1994c
	TX_FAR _VermilionCityText12
	db $50

VermilionCityText13: ; 0x19951
	TX_FAR _VermilionCityText13
	db $50

CeladonCityScript: ; 0x19956
	call $3c3c
	ld hl, $d77e
	res 0, [hl]
	res 7, [hl]
	ld hl, $d816
	res 7, [hl]
	ret
; 0x19966

CeladonCityTexts: ; 0x19966
	dw CeladonCityText1, CeladonCityText2, CeladonCityText3, CeladonCityText4, CeladonCityText5, CeladonCityText6, CeladonCityText7, CeladonCityText8, CeladonCityText9, CeladonCityText10, CeladonCityText11, CeladonCityText12, CeladonCityText13, CeladonCityText14, CeladonCityText15, CeladonCityText16, CeladonCityText17, CeladonCityText18

CeladonCityText1: ; 0x1998a
	TX_FAR _CeladonCityText1
	db $50

CeladonCityText2: ; 0x1998f
	TX_FAR _CeladonCityText2
	db $50

CeladonCityText3: ; 0x19994
	TX_FAR _CeladonCityText3
	db $50

CeladonCityText4: ; 0x19999
	TX_FAR _CeladonCityText4
	db $50

CeladonCityText5: ; 0x1999e
	db $08 ; asm
	ld a, [$d777]
	bit 0, a
	jr nz, .asm_7053f ; 0x199a4
	ld hl, TM41PreText
	call PrintText
	ld bc, (TM_41 << 8) | 1
	call GiveItem
	jr c, .asm_890ec ; 0x199b2
	ld hl, TM41NoRoomText
	call PrintText
	jr .asm_c765a ; 0x199ba
.asm_890ec ; 0x199bc
	ld hl, ReceivedTM41Text
	call PrintText
	ld hl, $d777
	set 0, [hl]
	jr .asm_c765a ; 0x199c7
.asm_7053f ; 0x199c9
	ld hl, TM41ExplanationText
	call PrintText
.asm_c765a ; 0x199cf
	jp TextScriptEnd

TM41PreText: ; 0x199d2
	TX_FAR _TM41PreText
	db $50
; 0x199d2 + 5 bytes

ReceivedTM41Text: ; 0x199d7
	TX_FAR _ReceivedTM41Text ; 0xa5b5a
	db $0B, $50
; 0x199d7 + 6 bytes = 0x199dd

TM41ExplanationText: ; 0x199dd
	TX_FAR _TM41ExplanationText
	db $50
; 0x199dd + 5 bytes

TM41NoRoomText: ; 0x199e2
	TX_FAR _TM41NoRoomText
	db $50
; 0x199e2 + 5 bytes

CeladonCityText6: ; 0x199e7
	TX_FAR _CeladonCityText6
	db $50

CeladonCityText7: ; 0x199ec
	TX_FAR _CeladonCityText7
	db $08 ; asm
	ld a, $6f
	call $13d0
	jp TextScriptEnd

CeladonCityText8: ; 0x199f9
	TX_FAR _CeladonCityText8
	db $50

CeladonCityText9: ; 0x199fe
	TX_FAR _CeladonCityText9
	db $50

CeladonCityText10: ; 0x19a03
	TX_FAR _CeladonCityText10
	db $50

CeladonCityText11: ; 0x19a08
	TX_FAR _CeladonCityText11
	db $50

CeladonCityText13: ; 0x19a0d
	TX_FAR _CeladonCityText13
	db $50

CeladonCityText14: ; 0x19a12
	TX_FAR _CeladonCityText14
	db $50

CeladonCityText15: ; 0x19a17
	TX_FAR _CeladonCityText15
	db $50

CeladonCityText16: ; 0x19a1c
	TX_FAR _CeladonCityText16
	db $50

CeladonCityText17: ; 0x19a21
	TX_FAR _CeladonCityText17
	db $50

CeladonCityText18: ; 0x19a26
	TX_FAR _CeladonCityText18
	db $50

FuchsiaCityScript: ; 0x19a2b
	jp $3c3c
; 0x19a2e

FuchsiaCityTexts: ; 0x19a2e
	dw FuchsiaCityText1, FuchsiaCityText2, FuchsiaCityText3, FuchsiaCityText4, FuchsiaCityText5, FuchsiaCityText6, FuchsiaCityText7, FuchsiaCityText8, FuchsiaCityText9, FuchsiaCityText10, FuchsiaCityText11, FuchsiaCityText12, FuchsiaCityText13, FuchsiaCityText14, FuchsiaCityText15, FuchsiaCityText16, FuchsiaCityText17, FuchsiaCityText18, FuchsiaCityText19, FuchsiaCityText20, FuchsiaCityText21, FuchsiaCityText22, FuchsiaCityText23, FuchsiaCityText24

FuchsiaCityText1: ; 0x19a5e
	TX_FAR _FuchsiaCityText1
	db $50

FuchsiaCityText2: ; 0x19a63
	TX_FAR _FuchsiaCityText2
	db $50

FuchsiaCityText3: ; 0x19a68
	TX_FAR _FuchsiaCityText3
	db $50

FuchsiaCityText4: ; 0x19a6d
	TX_FAR _FuchsiaCityText4
	db $50

FuchsiaCityText5: ; 0x19a72
FuchsiaCityText6:
FuchsiaCityText7:
FuchsiaCityText8:
FuchsiaCityText9:
FuchsiaCityText10: ; 0x19a72
	TX_FAR _FuchsiaCityText5
	db $50

FuchsiaCityText12:
FuchsiaCityText11: ; 0x19a77
	TX_FAR _FuchsiaCityText11
	db $50

FuchsiaCityText13: ; 0x19a7c
	TX_FAR _FuchsiaCityText13
	db $50

FuchsiaCityText16: ; 0x19a81
	TX_FAR _FuchsiaCityText16
	db $50

FuchsiaCityText17: ; 0x19a86
	TX_FAR _FuchsiaCityText17
	db $50

FuchsiaCityText18: ; 0x19a8b
	TX_FAR _FuchsiaCityText18
	db $50

FuchsiaCityText19: ; 0x19a90
	db $08 ; asm
	ld hl, FuchsiaCityChanseyText
	call PrintText
	ld a, $28
	call $349b
	jp TextScriptEnd

FuchsiaCityChanseyText: ; 0x19a9f
	TX_FAR _FuchsiaCityChanseyText
	db $50
; 0x19a9f + 5 bytes

FuchsiaCityText20: ; 0x19aa4
	db $08 ; asm
	ld hl, FuchsiaCityVoltorbText
	call PrintText
	ld a, $6
	call $349b
	jp TextScriptEnd

FuchsiaCityVoltorbText: ; 0x19ab3
	TX_FAR _FuchsiaCityVoltorbText
	db $50
; 0x19ab3 + 5 bytes

FuchsiaCityText21: ; 0x19ab8
	db $08 ; asm
	ld hl, FuchsiaCityKangaskhanText
	call PrintText
	ld a, $2
	call $349b
	jp TextScriptEnd

FuchsiaCityKangaskhanText: ; 0x19ac7
	TX_FAR _FuchsiaCityKangaskhanText
	db $50
; 0x19ac7 + 5 bytes

FuchsiaCityText22: ; 0x19acc
	db $08 ; asm
	ld hl, FuchsiaCitySlowpokeText
	call PrintText
	ld a, $25
	call $349b
	jp TextScriptEnd

FuchsiaCitySlowpokeText: ; 0x19adb
	TX_FAR _FuchsiaCitySlowpokeText
	db $50
; 0x19adb + 5 bytes

FuchsiaCityText23: ; 0x19ae0
	db $08 ; asm
	ld hl, FuchsiaCityLaprasText
	call PrintText
	ld a, $13
	call $349b
	jp TextScriptEnd

FuchsiaCityLaprasText: ; 0x19aef
	TX_FAR _FuchsiaCityLaprasText
	db $50
; 0x19aef + 5 bytes

FuchsiaCityText24: ; 0x19af4
	db $08 ; asm
	ld a, [$d7f6]
	bit 6, a
	jr nz, .asm_3b4e8 ; 0x19afa
	bit 7, a
	jr nz, .asm_667d5 ; 0x19afe
	ld hl, UnnamedText_19b2a
	call PrintText
	jr .asm_4343f ; 0x19b06
.asm_3b4e8 ; 0x19b08
	ld hl, FuchsiaCityOmanyteText
	call PrintText
	ld a, $62
	jr .asm_81556 ; 0x19b10
.asm_667d5 ; 0x19b12
	ld hl, FuchsiaCityKabutoText
	call PrintText
	ld a, $5a
.asm_81556 ; 0x19b1a
	call $349b
.asm_4343f ; 0x19b1d
	jp TextScriptEnd

FuchsiaCityOmanyteText: ; 0x19b20
	TX_FAR _FuchsiaCityOmanyteText
	db $50
; 0x19b20 + 5 bytes

FuchsiaCityKabutoText: ; 0x19b25
	TX_FAR _FuchsiaCityKabutoText
	db $50
; 0x19b25 + 5 bytes

UnnamedText_19b2a: ; 0x19b2a
	TX_FAR _UnnamedText_19b2a
	db $50
; 0x19b2a + 5 bytes

BluesHouse_h: ; 0x19b2f id=39
	db $08 ; tileset
	db BLUES_HOUSE_HEIGHT, BLUES_HOUSE_WIDTH ; dimensions
	dw BluesHouseBlocks, BluesHouseTexts, BluesHouseScript
	db 0
	dw BluesHouseObject

BluesHouseScript: ; 0x19b3b
	call $3C3C
	ld hl,BluesHouseScriptPointers
	ld a,[$D5F3]
	jp $3D97

BluesHouseScriptPointers: ; 0x19b47
	dw BluesHouseScript1,BluesHouseScript2

BluesHouseScript1: ; 0x19b4a
	ld hl,$D74A
	set 1,[hl]

	; trigger the next script
	ld a,1
	ld [$D5F3],a
	ret

BluesHouseScript2: ; 0x19B56
	ret

BluesHouseTexts: ; 0x19B57
	dw BluesHouseText1,BluesHouseText2,BluesHouseText3

BluesHouseText1: ; 5B5D 0x19B5D
	db 8
	ld a,[$D74A]
	bit 0,a
	jr nz,.GotMap\@
	ld a,[$D74B]
	bit 5,a
	jr nz,.GiveMap\@
	ld hl,DaisyInitialText
	call PrintText
	jr .done\@
.GiveMap\@
	ld hl,DaisyOfferMapText
	call PrintText
	ld bc,(TOWN_MAP << 8) | 1
	call $3E2E
	jr nc,.BagFull\@
	ld a,$29
	ld [$CC4D],a
	ld a,$11
	call Predef ; hide table map object
	ld hl,GotMapText
	call PrintText
	ld hl,$D74A
	set 0,[hl]
	jr .done\@
.GotMap\@
	ld hl,DaisyUseMapText
	call PrintText
	jr .done\@
.BagFull\@
	ld hl,DaisyBagFullText
	call PrintText
.done\@
	jp TextScriptEnd

DaisyInitialText: ; 0x19baa
	TX_FAR _DaisyInitialText
	db "@"

DaisyOfferMapText: ; 0x19baf
	TX_FAR _DaisyOfferMapText
	db "@"

GotMapText: ; 0x19bb4
	TX_FAR _GotMapText
	db $11,"@"

DaisyBagFullText: ; 0x19bba
	TX_FAR _DaisyBagFullText
	db "@"

DaisyUseMapText: ; 0x19bbf
	TX_FAR _DaisyUseMapText
	db "@"

BluesHouseText2: ; 0x19bc4 Daisy, walking around
	TX_FAR _BluesHouseText2
	db "@"

BluesHouseText3: ; 0x19bc9 map on table
	TX_FAR _BluesHouseText3
	db "@"

BluesHouseObject: ; 0x19bce
	db $0A ; border tile

	db 2 ; warps
	db 7,2,1,$FF
	db 7,3,1,$FF

	db 0 ; signs

	db 3 ; people
	db $11,4+3,4+2,$FF,$D3,1 ; Daisy, sitting by map
	db $11,4+4,4+6,$FE,1,ITEM|2,0 ; map on table
	db $41,4+3,4+3,$FF,$FF,ITEM|3,0 ; Daisy, walking around

	; warp-to
	dw $C712
	db 7,2

	dw $C712
	db 7,3

BluesHouseBlocks: ; 0x19bf6
	INCBIN "maps/blueshouse.blk"

VermilionHouse3_h: ; 0x19c06 to 0x19c12 (12 bytes) (bank=6) (id=196)
	db $08 ; tileset
	db VERMILION_HOUSE_3_HEIGHT, VERMILION_HOUSE_3_WIDTH ; dimensions (y, x)
	dw VermilionHouse3Blocks, VermilionHouse3Texts, VermilionHouse3Script ; blocks, texts, scripts
	db $00 ; connections

	dw VermilionHouse3Object ; objects

VermilionHouse3Script: ; 0x19c12
	jp $3c3c
; 0x19c15

VermilionHouse3Texts: ; 0x19c15
	dw VermilionHouse3Text1

VermilionHouse3Text1: ; 0x19c17
	db $08 ; asm
	ld a, $4
	ld [W_WHICHTRADE], a
	ld a, $54
	call Predef
	jp TextScriptEnd

VermilionHouse3Object: ; 0x19c25 (size=26)
	db $a ; border tile

	db $2 ; warps
	db $7, $2, $7, $ff
	db $7, $3, $7, $ff

	db $0 ; signs

	db $1 ; people
	db SPRITE_LITTLE_GIRL, $5 + 4, $3 + 4, $ff, $d1, $1 ; person

	; warp-to
	EVENT_DISP $4, $7, $2
	EVENT_DISP $4, $7, $3

VermilionHouse3Blocks: ; 0x19c3f 16
	INCBIN "maps/vermilionhouse3.blk"

IndigoPlateauLobby_h: ; 0x19c4f to 0x19c5b (12 bytes) (bank=6) (id=174)
	db $02 ; tileset
	db INDIGO_PLATEAU_LOBBY_HEIGHT, INDIGO_PLATEAU_LOBBY_WIDTH ; dimensions (y, x)
	dw IndigoPlateauLobbyBlocks, IndigoPlateauLobbyTexts, IndigoPlateauLobbyScript ; blocks, texts, scripts
	db $00 ; connections

	dw IndigoPlateauLobbyObject ; objects

IndigoPlateauLobbyScript: ; 0x19c5b
	call $22fa
	call $3c3c
	ld hl, $d126
	bit 6, [hl]
	res 6, [hl]
	ret z
	ld hl, $d869
	res 7, [hl]
	ld hl, $d734
	bit 1, [hl]
	res 1, [hl]
	ret z
	ld hl, $d863
	xor a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a
	ret
; 0x19c7f

IndigoPlateauLobbyTexts: ; 0x19c7f
	dw IndigoPlateauLobbyText1, IndigoPlateauLobbyText2, IndigoPlateauLobbyText3, IndigoPlateauLobbyText4, IndigoPlateauLobbyText5

IndigoPlateauLobbyText1: ; 0x19c8a
	db $ff

IndigoPlateauLobbyText2: ; 0x19c8b
	TX_FAR _IndigoPlateauLobbyText1
	db $50

INCBIN "baserom.gbc",$19c8f,$19c8f - $19c8f

IndigoPlateauLobbyText3: ; 0x19c8f
	TX_FAR _IndigoPlateauLobbyText3
	db $50

IndigoPlateauLobbyText5: ; 0x19c94
	db $f6

IndigoPlateauLobbyObject: ; 0x19c95 (size=58)
	db $0 ; border tile

	db $3 ; warps
	db $b, $7, $0, $ff
	db $b, $8, $1, $ff
	db $0, $8, $0, LORELEIS_ROOM

	db $0 ; signs

	db $5 ; people
	db SPRITE_NURSE, $5 + 4, $7 + 4, $ff, $d0, $1 ; person
	db SPRITE_GYM_HELPER, $9 + 4, $4 + 4, $ff, $d3, $2 ; person
	db SPRITE_LASS, $1 + 4, $5 + 4, $ff, $d0, $3 ; person
	db SPRITE_MART_GUY, $5 + 4, $0 + 4, $ff, $d3, $4 ; person
	db SPRITE_CABLE_CLUB_WOMAN, $6 + 4, $d + 4, $ff, $d0, $5 ; person

	; warp-to
	EVENT_DISP $8, $b, $7
	EVENT_DISP $8, $b, $8
	EVENT_DISP $8, $0, $8 ; LORELEIS_ROOM

IndigoPlateauLobbyBlocks: ; 0x19ccf 48
	INCBIN "maps/indigoplateaulobby.blk"

SilphCo4_h: ; 0x19cff to 0x19d0b (12 bytes) (bank=6) (id=209)
	db $16 ; tileset
	db SILPH_CO_4F_HEIGHT, SILPH_CO_4F_WIDTH ; dimensions (y, x)
	dw SilphCo4Blocks, SilphCo4Texts, SilphCo4Script ; blocks, texts, scripts
	db $00 ; connections

	dw SilphCo4Object ; objects

SilphCo4Script: ; 0x19d0b
	call SilphCo4Script_Unknown19d21
	call $3c3c
	ld hl, SilphCo4TrainerHeaders
	ld de, $5d9a
	ld a, [$d645]
	call $3160
	ld [$d645], a
	ret
; 0x19d21

SilphCo4Script_Unknown19d21: ; 0x19d21
INCBIN "baserom.gbc",$19d21,$7f

SilphCo4Texts: ; 0x19da0
	dw SilphCo4Text1, SilphCo4Text2, SilphCo4Text3, SilphCo4Text4, SilphCo4Text5, SilphCo4Text6, SilphCo4Text7

SilphCo4TrainerHeaders:
SilphCo4TrainerHeader0: ; 0x19dae
	db $2 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d829 ; flag's byte
	dw SilphCo4BattleText2 ; 0x5df4 TextBeforeBattle
	dw SilphCo4AfterBattleText2 ; 0x5dfe TextAfterBattle
	dw SilphCo4EndBattleText2 ; 0x5df9 TextEndBattle
	dw SilphCo4EndBattleText2 ; 0x5df9 TextEndBattle
; 0x19dba

SilphCo4TrainerHeader2: ; 0x19dba
	db $3 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d829 ; flag's byte
	dw SilphCo4BattleText3 ; 0x5e0d TextBeforeBattle
	dw SilphCo4AfterBattleText3 ; 0x5e17 TextAfterBattle
	dw SilphCo4EndBattleText3 ; 0x5e12 TextEndBattle
	dw SilphCo4EndBattleText3 ; 0x5e12 TextEndBattle
; 0x19dc4

SilphCo4TrainerHeader3: ; 0x19dc6
	db $4 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d829 ; flag's byte
	dw SilphCo4BattleText4 ; 0x5e26 TextBeforeBattle
	dw SilphCo4AfterBattleText4 ; 0x5e30 TextAfterBattle
	dw SilphCo4EndBattleText4 ; 0x5e2b TextEndBattle
	dw SilphCo4EndBattleText4 ; 0x5e2b TextEndBattle
; 0x19dd2

db $ff

SilphCo4Text1: ; 0x19dd3
	db $08 ; asm
	ld hl, $5de0
	ld de, $5de5
	call $622f
	jp TextScriptEnd

UnnamedText_19de0: ; 0x19de0
	TX_FAR _UnnamedText_19de0
	db $50
; 0x19de0 + 5 bytes

UnnamedText_19de5: ; 0x19de5
	TX_FAR _UnnamedText_19de5
	db $50
; 0x19de5 + 5 bytes

SilphCo4Text2: ; 0x19dea
	db $08 ; asm
	ld hl, SilphCo4TrainerHeader0
	call LoadTrainerHeader
	jp TextScriptEnd

SilphCo4BattleText2: ; 0x19df4
	TX_FAR _SilphCo4BattleText2
	db $50
; 0x19df4 + 5 bytes

SilphCo4EndBattleText2: ; 0x19df9
	TX_FAR _SilphCo4EndBattleText2
	db $50
; 0x19df9 + 5 bytes

SilphCo4AfterBattleText2: ; 0x19dfe
	TX_FAR _SilphCo4AfterBattleText2
	db $50
; 0x19dfe + 5 bytes

SilphCo4Text3: ; 0x19e03
	db $08 ; asm
	ld hl, SilphCo4TrainerHeader2
	call LoadTrainerHeader
	jp TextScriptEnd

SilphCo4BattleText3: ; 0x19e0d
	TX_FAR _SilphCo4BattleText3
	db $50
; 0x19e0d + 5 bytes

SilphCo4EndBattleText3: ; 0x19e12
	TX_FAR _SilphCo4EndBattleText3
	db $50
; 0x19e12 + 5 bytes

SilphCo4AfterBattleText3: ; 0x19e17
	TX_FAR _SilphCo4AfterBattleText3
	db $50
; 0x19e17 + 5 bytes

SilphCo4Text4: ; 0x19e1c
	db $08 ; asm
	ld hl, SilphCo4TrainerHeader3
	call LoadTrainerHeader
	jp TextScriptEnd

SilphCo4BattleText4: ; 0x19e26
	TX_FAR _SilphCo4BattleText4
	db $50
; 0x19e26 + 5 bytes

SilphCo4EndBattleText4: ; 0x19e2b
	TX_FAR _SilphCo4EndBattleText4
	db $50
; 0x19e2b + 5 bytes

SilphCo4AfterBattleText4: ; 0x19e30
	TX_FAR _SilphCo4AfterBattleText4
	db $50
; 0x19e30 + 5 bytes

SilphCo4Object: ; 0x19e35 (size=111)
	db $2e ; border tile

	db $7 ; warps
	db $0, $18, $1, SILPH_CO_3F
	db $0, $1a, $1, SILPH_CO_5F
	db $0, $14, $0, SILPH_CO_ELEVATOR
	db $7, $b, $3, SILPH_CO_10F
	db $3, $11, $3, SILPH_CO_6F
	db $f, $3, $4, SILPH_CO_10F
	db $b, $11, $5, SILPH_CO_10F

	db $0 ; signs

	db $7 ; people
	db SPRITE_LAPRAS_GIVER, $2 + 4, $6 + 4, $ff, $ff, $1 ; person
	db SPRITE_ROCKET, $e + 4, $9 + 4, $ff, $d3, $42, ROCKET + $C8, $1a ; trainer
	db SPRITE_OAK_AIDE, $6 + 4, $e + 4, $ff, $d2, $43, SCIENTIST + $C8, $5 ; trainer
	db SPRITE_ROCKET, $a + 4, $1a + 4, $ff, $d1, $44, ROCKET + $C8, $1b ; trainer
	db SPRITE_BALL, $9 + 4, $3 + 4, $ff, $ff, $85, FULL_HEAL ; item
	db SPRITE_BALL, $7 + 4, $4 + 4, $ff, $ff, $86, MAX_REVIVE ; item
	db SPRITE_BALL, $8 + 4, $5 + 4, $ff, $ff, $87, ESCAPE_ROPE ; item

	; warp-to
	EVENT_DISP $f, $0, $18 ; SILPH_CO_3F
	EVENT_DISP $f, $0, $1a ; SILPH_CO_5F
	EVENT_DISP $f, $0, $14 ; SILPH_CO_ELEVATOR
	EVENT_DISP $f, $7, $b ; SILPH_CO_10F
	EVENT_DISP $f, $3, $11 ; SILPH_CO_6F
	EVENT_DISP $f, $f, $3 ; SILPH_CO_10F
	EVENT_DISP $f, $b, $11 ; SILPH_CO_10F

SilphCo4Blocks: ; 0x19ea4 135
	INCBIN "maps/silphco4.blk"

SilphCo5_h: ; 0x19f2b to 0x19f37 (12 bytes) (bank=6) (id=210)
	db $16 ; tileset
	db SILPH_CO_5F_HEIGHT, SILPH_CO_5F_WIDTH ; dimensions (y, x)
	dw SilphCo5Blocks, SilphCo5Texts, SilphCo5Script ; blocks, texts, scripts
	db $00 ; connections

	dw SilphCo5Object ; objects

SilphCo5Script: ; 0x19f37
	call Unnamed_19f4d
	call $3c3c
	ld hl, SilphCo5TrainerHeaders
	ld de, $5fb6
	ld a, [$d646]
	call $3160
	ld [$d646], a
	ret
; 0x19f4d

Unnamed_19f4d: ; 0x19f4d
INCBIN "baserom.gbc",$19f4d,$6f

SilphCo5Texts: ; 0x19fbc
	dw SilphCo5Text1, SilphCo5Text2, SilphCo5Text3, SilphCo5Text4, SilphCo5Text5, SilphCo5Text6, SilphCo5Text7, SilphCo5Text8, SilphCo5Text9, SilphCo5Text10, SilphCo5Text11

SilphCo5TrainerHeaders:
Silphco5TrainerHeader0: ; 0x19fd2
	db $2 ; flag's bit
	db ($1 << 4) ; trainer's view range
	dw $d82b ; flag's byte
	dw SilphCo5BattleText2 ; 0x6024 TextBeforeBattle
	dw SilphCo5AfterBattleText2 ; 0x602e TextAfterBattle
	dw SilphCo5EndBattleText2 ; 0x6029 TextEndBattle
	dw SilphCo5EndBattleText2 ; 0x6029 TextEndBattle
; 0x19fde

Silphco5TrainerHeader2: ; 0x19fde
	db $3 ; flag's bit
	db ($2 << 4) ; trainer's view range
	dw $d82b ; flag's byte
	dw SilphCo5BattleText3 ; 0x603d TextBeforeBattle
	dw SilphCo5AfterBattleText3 ; 0x6047 TextAfterBattle
	dw SilphCo5EndBattleText3 ; 0x6042 TextEndBattle
	dw SilphCo5EndBattleText3 ; 0x6042 TextEndBattle
; 0x19fea

Silphco5TrainerHeader3: ; 0x19fea
	db $4 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d82b ; flag's byte
	dw SilphCo5BattleText4 ; 0x6056 TextBeforeBattle
	dw SilphCo5AfterBattleText4 ; 0x6060 TextAfterBattle
	dw SilphCo5EndBattleText4 ; 0x605b TextEndBattle
	dw SilphCo5EndBattleText4 ; 0x605b TextEndBattle
; 0x19ff4

Silphco5TrainerHeader4: ; 0x19ff6
	db $5 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d82b ; flag's byte
	dw SilphCo5BattleText5 ; 0x606f TextBeforeBattle
	dw SilphCo5AfterBattleText5 ; 0x6079 TextAfterBattle
	dw SilphCo5EndBattleText5 ; 0x6074 TextEndBattle
	dw SilphCo5EndBattleText5 ; 0x6074 TextEndBattle
; 0x1a002

db $ff

SilphCo5Text1: ; 0x1a003
	db $08 ; asm
	ld hl, $6010
	ld de, $6015
	call $622f
	jp TextScriptEnd

UnnamedText_1a010: ; 0x1a010
	TX_FAR _UnnamedText_1a010
	db $50
; 0x1a010 + 5 bytes

UnnamedText_1a015: ; 0x1a015
	TX_FAR _UnnamedText_1a015
	db $50
; 0x1a015 + 5 bytes

SilphCo5Text2: ; 0x1a01a
	db $08 ; asm
	ld hl, Silphco5TrainerHeader0
	call LoadTrainerHeader
	jp TextScriptEnd

SilphCo5BattleText2: ; 0x1a024
	TX_FAR _SilphCo5BattleText2
	db $50
; 0x1a024 + 5 bytes

SilphCo5EndBattleText2: ; 0x1a029
	TX_FAR _SilphCo5EndBattleText2
	db $50
; 0x1a029 + 5 bytes

SilphCo5AfterBattleText2: ; 0x1a02e
	TX_FAR _SilphCo5AfterBattleText2
	db $50
; 0x1a02e + 5 bytes

SilphCo5Text3: ; 0x1a033
	db $08 ; asm
	ld hl, Silphco5TrainerHeader2
	call LoadTrainerHeader
	jp TextScriptEnd

SilphCo5BattleText3: ; 0x1a03d
	TX_FAR _SilphCo5BattleText3
	db $50
; 0x1a03d + 5 bytes

SilphCo5EndBattleText3: ; 0x1a042
	TX_FAR _SilphCo5EndBattleText3
	db $50
; 0x1a042 + 5 bytes

SilphCo5AfterBattleText3: ; 0x1a047
	TX_FAR _SilphCo5AfterBattleText3
	db $50
; 0x1a047 + 5 bytes

SilphCo5Text4: ; 0x1a04c
	db $08 ; asm
	ld hl, Silphco5TrainerHeader3
	call LoadTrainerHeader
	jp TextScriptEnd

SilphCo5BattleText4: ; 0x1a056
	TX_FAR _SilphCo5BattleText4
	db $50
; 0x1a056 + 5 bytes

SilphCo5EndBattleText4: ; 0x1a05b
	TX_FAR _SilphCo5EndBattleText4
	db $50
; 0x1a05b + 5 bytes

SilphCo5AfterBattleText4: ; 0x1a060
	TX_FAR _SilphCo5AfterBattleText4
	db $50
; 0x1a060 + 5 bytes

SilphCo5Text5: ; 0x1a065
	db $08 ; asm
	ld hl, Silphco5TrainerHeader4
	call LoadTrainerHeader
	jp TextScriptEnd

SilphCo5BattleText5: ; 0x1a06f
	TX_FAR _SilphCo5BattleText5
	db $50
; 0x1a06f + 5 bytes

SilphCo5EndBattleText5: ; 0x1a074
	TX_FAR _SilphCo5EndBattleText5
	db $50
; 0x1a074 + 5 bytes

SilphCo5AfterBattleText5: ; 0x1a079
	TX_FAR _SilphCo5AfterBattleText5
	db $50
; 0x1a079 + 5 bytes

SilphCo5Text9: ; 0x1a07e
	TX_FAR _SilphCo5Text9
	db $50

SilphCo5Text10: ; 0x1a083
	TX_FAR _SilphCo5Text10
	db $50

SilphCo5Text11: ; 0x1a088
	TX_FAR _SilphCo5Text11
	db $50

SilphCo5Object: ; 0x1a08d (size=137)
	db $2e ; border tile

	db $7 ; warps
	db $0, $18, $1, SILPH_CO_6F
	db $0, $1a, $1, SILPH_CO_4F
	db $0, $14, $0, SILPH_CO_ELEVATOR
	db $3, $1b, $5, SILPH_CO_7F
	db $f, $9, $4, SILPH_CO_9F
	db $5, $b, $4, SILPH_CO_3F
	db $f, $3, $5, SILPH_CO_3F

	db $0 ; signs

	db $b ; people
	db SPRITE_LAPRAS_GIVER, $9 + 4, $d + 4, $ff, $ff, $1 ; person
	db SPRITE_ROCKET, $10 + 4, $8 + 4, $ff, $d3, $42, ROCKET + $C8, $1c ; trainer
	db SPRITE_OAK_AIDE, $3 + 4, $8 + 4, $ff, $d3, $43, SCIENTIST + $C8, $6 ; trainer
	db SPRITE_ROCKER, $a + 4, $12 + 4, $ff, $d1, $44, JUGGLER + $C8, $1 ; trainer
	db SPRITE_ROCKET, $4 + 4, $1c + 4, $ff, $d1, $45, ROCKET + $C8, $1d ; trainer
	db SPRITE_BALL, $d + 4, $2 + 4, $ff, $ff, $86, TM_09 ; item
	db SPRITE_BALL, $6 + 4, $4 + 4, $ff, $ff, $87, PROTEIN ; item
	db SPRITE_BALL, $10 + 4, $15 + 4, $ff, $ff, $88, CARD_KEY ; item
	db SPRITE_CLIPBOARD, $c + 4, $16 + 4, $ff, $ff, $9 ; person
	db SPRITE_CLIPBOARD, $a + 4, $19 + 4, $ff, $ff, $a ; person
	db SPRITE_CLIPBOARD, $6 + 4, $18 + 4, $ff, $ff, $b ; person

	; warp-to
	EVENT_DISP $f, $0, $18 ; SILPH_CO_6F
	EVENT_DISP $f, $0, $1a ; SILPH_CO_4F
	EVENT_DISP $f, $0, $14 ; SILPH_CO_ELEVATOR
	EVENT_DISP $f, $3, $1b ; SILPH_CO_7F
	EVENT_DISP $f, $f, $9 ; SILPH_CO_9F
	EVENT_DISP $f, $5, $b ; SILPH_CO_3F
	EVENT_DISP $f, $f, $3 ; SILPH_CO_3F

SilphCo5Blocks: ; 0x1a116 135
	INCBIN "maps/silphco5.blk"

SilphCo6_h: ; 0x1a19d to 0x1a1a9 (12 bytes) (bank=6) (id=211)
	db $16 ; tileset
	db SILPH_CO_6F_HEIGHT, SILPH_CO_6F_WIDTH ; dimensions (y, x)
	dw SilphCo6Blocks, SilphCo6Texts, SilphCo6Script ; blocks, texts, scripts
	db $00 ; connections

	dw SilphCo6Object ; objects

SilphCo6Script: ; 0x1a1a9
	call Unnamed_1a1bf
	call $3c3c
	ld hl, SilphCo6TrainerHeaders
	ld de, $61f0
	ld a, [$d647]
	call $3160
	ld [$d647], a
	ret
; 0x1a1bf

Unnamed_1a1bf: ; 0x1a1bf
INCBIN "baserom.gbc",$1a1bf,$37

SilphCo6Texts: ; 0x1a1f6
	dw SilphCo6Text1, SilphCo6Text2, SilphCo6Text3, SilphCo6Text4, SilphCo6Text5, SilphCo6Text6, SilphCo6Text7, SilphCo6Text8, SilphCo6Text9, SilphCo6Text10

SilphCo6TrainerHeaders:
SilphCo6TrainerHeader0: ; 0x1a20a
	db $6 ; flag's bit
	db ($2 << 4) ; trainer's view range
	dw $d82d ; flag's byte
	dw SilphCo6BattleText2 ; 0x62ba TextBeforeBattle
	dw SilphCo6AfterBattleText2 ; 0x62c4 TextAfterBattle
	dw SilphCo6EndBattleText2 ; 0x62bf TextEndBattle
	dw SilphCo6EndBattleText2 ; 0x62bf TextEndBattle
; 0x1a216

SilphCo6TrainerHeader2: ; 0x1a216
	db $7 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d82d ; flag's byte
	dw SilphCo6BattleText3 ; 0x62d3 TextBeforeBattle
	dw SilphCo6AfterBattleText3 ; 0x62dd TextAfterBattle
	dw SilphCo6EndBattleText3 ; 0x62d8 TextEndBattle
	dw SilphCo6EndBattleText3 ; 0x62d8 TextEndBattle
; 0x1a222

SilphCo6TrainerHeader3: ; 0x1a222
	db $8 ; flag's bit
	db ($2 << 4) ; trainer's view range
	dw $d82d ; flag's byte
	dw SilphCo6BattleText4 ; 0x62ec TextBeforeBattle
	dw SilphCo6AfterBattleText4 ; 0x62f6 TextAfterBattle
	dw SilphCo6EndBattleText4 ; 0x62f1 TextEndBattle
	dw SilphCo6EndBattleText4 ; 0x62f1 TextEndBattle
; 0x1a22e

db $ff

Unnamed_622f: ; 0x1a22f
INCBIN "baserom.gbc",$1a22f,$1a23d - $1a22f

SilphCo6Text1: ; 0x1a23d
	db $08 ; asm
	ld hl, UnnamedText_1a24a
	ld de, UnnamedText_1a24f
	call Unnamed_622f
	jp TextScriptEnd

UnnamedText_1a24a: ; 0x1a24a
	TX_FAR _UnnamedText_1a24a
	db $50
; 0x1a24a + 5 bytes

UnnamedText_1a24f: ; 0x1a24f
	TX_FAR _UnnamedText_1a24f
	db $50
; 0x1a24f + 5 bytes

SilphCo6Text2: ; 0x1a254
	db $08 ; asm
	ld hl, UnnamedText_1a261
	ld de, UnnamedText_1a266
	call Unnamed_622f
	jp TextScriptEnd

UnnamedText_1a261: ; 0x1a261
	TX_FAR _UnnamedText_1a261
	db $50
; 0x1a261 + 5 bytes

UnnamedText_1a266: ; 0x1a266
	TX_FAR _UnnamedText_1a266
	db $50
; 0x1a266 + 5 bytes

SilphCo6Text3: ; 0x1a26b
	db $08 ; asm
	ld hl, UnnamedText_1a278
	ld de, UnnamedText_1a27d
	call Unnamed_622f
	jp TextScriptEnd

UnnamedText_1a278: ; 0x1a278
	TX_FAR _UnnamedText_1a278
	db $50
; 0x1a278 + 5 bytes

UnnamedText_1a27d: ; 0x1a27d
	TX_FAR _UnnamedText_1a27d
	db $50
; 0x1a27d + 5 bytes

SilphCo6Text4: ; 0x1a282
	db $08 ; asm
	ld hl, UnnamedText_1a28f
	ld de, UnnamedText_1a294
	call Unnamed_622f
	jp TextScriptEnd

UnnamedText_1a28f: ; 0x1a28f
	TX_FAR _UnnamedText_1a28f
	db $50
; 0x1a28f + 5 bytes

UnnamedText_1a294: ; 0x1a294
	TX_FAR _UnnamedText_1a294
	db $50
; 0x1a294 + 5 bytes

SilphCo6Text5: ; 0x1a299
	db $08 ; asm
	ld hl, UnnamedText_1a2a6
	ld de, UnnamedText_1a2ab
	call Unnamed_622f
	jp TextScriptEnd

UnnamedText_1a2a6: ; 0x1a2a6
	TX_FAR _UnnamedText_1a2a6
	db $50
; 0x1a2a6 + 5 bytes

UnnamedText_1a2ab: ; 0x1a2ab
	TX_FAR _UnnamedText_1a2ab
	db $50
; 0x1a2ab + 5 bytes

SilphCo6Text6: ; 0x1a2b0
	db $08 ; asm
	ld hl, SilphCo6TrainerHeader0
	call LoadTrainerHeader
	jp TextScriptEnd

SilphCo6BattleText2: ; 0x1a2ba
	TX_FAR _SilphCo6BattleText2
	db $50
; 0x1a2ba + 5 bytes

SilphCo6EndBattleText2: ; 0x1a2bf
	TX_FAR _SilphCo6EndBattleText2
	db $50
; 0x1a2bf + 5 bytes

SilphCo6AfterBattleText2: ; 0x1a2c4
	TX_FAR _SilphCo6AfterBattleText2
	db $50
; 0x1a2c4 + 5 bytes

SilphCo6Text7: ; 0x1a2c9
	db $08 ; asm
	ld hl, SilphCo6TrainerHeader2
	call LoadTrainerHeader
	jp TextScriptEnd

SilphCo6BattleText3: ; 0x1a2d3
	TX_FAR _SilphCo6BattleText3
	db $50
; 0x1a2d3 + 5 bytes

SilphCo6EndBattleText3: ; 0x1a2d8
	TX_FAR _SilphCo6EndBattleText3
	db $50
; 0x1a2d8 + 5 bytes

SilphCo6AfterBattleText3: ; 0x1a2dd
	TX_FAR _SilphCo6AfterBattleText3
	db $50
; 0x1a2dd + 5 bytes

SilphCo6Text8: ; 0x1a2e2
	db $08 ; asm
	ld hl, SilphCo6TrainerHeader3
	call LoadTrainerHeader
	jp TextScriptEnd

SilphCo6BattleText4: ; 0x1a2ec
	TX_FAR _SilphCo6BattleText4
	db $50
; 0x1a2ec + 5 bytes

SilphCo6EndBattleText4: ; 0x1a2f1
	TX_FAR _SilphCo6EndBattleText4
	db $50
; 0x1a2f1 + 5 bytes

SilphCo6AfterBattleText4: ; 0x1a2f6
	TX_FAR _SilphCo6AfterBattleText4
	db $50
; 0x1a2f6 + 5 bytes

SilphCo6Object: ; 0x1a2fb (size=112)
	db $2e ; border tile

	db $5 ; warps
	db $0, $10, $1, SILPH_CO_7F
	db $0, $e, $0, SILPH_CO_5F
	db $0, $12, $0, SILPH_CO_ELEVATOR
	db $3, $3, $4, SILPH_CO_4F
	db $3, $17, $6, SILPH_CO_2F

	db $0 ; signs

	db $a ; people
	db SPRITE_LAPRAS_GIVER, $6 + 4, $a + 4, $ff, $ff, $1 ; person
	db SPRITE_LAPRAS_GIVER, $6 + 4, $14 + 4, $ff, $ff, $2 ; person
	db SPRITE_ERIKA, $6 + 4, $15 + 4, $ff, $d0, $3 ; person
	db SPRITE_ERIKA, $a + 4, $b + 4, $ff, $d3, $4 ; person
	db SPRITE_LAPRAS_GIVER, $d + 4, $12 + 4, $ff, $d1, $5 ; person
	db SPRITE_ROCKET, $3 + 4, $11 + 4, $ff, $d3, $46, ROCKET + $C8, $1e ; trainer
	db SPRITE_OAK_AIDE, $8 + 4, $7 + 4, $ff, $d0, $47, SCIENTIST + $C8, $7 ; trainer
	db SPRITE_ROCKET, $f + 4, $e + 4, $ff, $d2, $48, ROCKET + $C8, $1f ; trainer
	db SPRITE_BALL, $c + 4, $3 + 4, $ff, $ff, $89, HP_UP ; item
	db SPRITE_BALL, $f + 4, $2 + 4, $ff, $ff, $8a, X_ACCURACY ; item

	; warp-to
	EVENT_DISP $d, $0, $10 ; SILPH_CO_7F
	EVENT_DISP $d, $0, $e ; SILPH_CO_5F
	EVENT_DISP $d, $0, $12 ; SILPH_CO_ELEVATOR
	EVENT_DISP $d, $3, $3 ; SILPH_CO_4F
	EVENT_DISP $d, $3, $17 ; SILPH_CO_2F

SilphCo6Blocks: ; 0x1a36b 117
	INCBIN "maps/silphco6.blk"

INCBIN "baserom.gbc",$1a3e0,$1c20

SECTION "bank7",DATA,BANK[$7]

CinnabarIsland_h: ; 0x1c000 to 0x1c022 (34 bytes) (bank=7) (id=8)
	db $00 ; tileset
	db CINNABAR_ISLAND_HEIGHT, CINNABAR_ISLAND_WIDTH ; dimensions (y, x)
	dw CinnabarIslandBlocks, CinnabarIslandTexts, CinnabarIslandScript ; blocks, texts, scripts
	db NORTH | EAST ; connections

	; connections data

	db ROUTE_21
	dw Route21Blocks + (ROUTE_21_HEIGHT - 3) * ROUTE_21_WIDTH ; connection strip location
	dw $C6EB + 0 ; current map position
	db ROUTE_21_WIDTH, ROUTE_21_WIDTH ; bigness, width
	db (ROUTE_21_HEIGHT * 2) - 1, (0 * -2) ; alignments (y, x)
	dw $C6E9 + ROUTE_21_HEIGHT * (ROUTE_21_WIDTH + 6) ; window

	db ROUTE_20
	dw Route20Blocks + (ROUTE_20_WIDTH * 0) ; connection strip location
	dw $C6E5 + (CINNABAR_ISLAND_WIDTH + 6) * (0 + 4) ; current map position
	db ROUTE_20_HEIGHT, ROUTE_20_WIDTH ; bigness, width
	db (0 * -2), 0 ; alignments (y, x)
	dw $C6EF + ROUTE_20_WIDTH ; window

	; end connections data

	dw CinnabarIslandObject ; objects

CinnabarIslandObject: ; 0x1c022 (size=71)
	db $43 ; border tile

	db $5 ; warps
	db $3, $6, $1, MANSION_1
	db $3, $12, $0, CINNABAR_GYM
	db $9, $6, $0, CINNABAR_LAB_1
	db $b, $b, $0, CINNABAR_POKECENTER
	db $b, $f, $0, CINNABAR_MART

	db $5 ; signs
	db $5, $9, $3 ; CinnabarIslandText3
	db $b, $10, $4 ; CinnabarIslandText4
	db $b, $c, $5 ; CinnabarIslandText5
	db $b, $9, $6 ; CinnabarIslandText6
	db $3, $d, $7 ; CinnabarIslandText7

	db $2 ; people
	db SPRITE_GIRL, $5 + 4, $c + 4, $fe, $2, $1 ; person
	db SPRITE_GAMBLER, $6 + 4, $e + 4, $ff, $ff, $2 ; person

	; warp-to
	EVENT_DISP $a, $3, $6 ; MANSION_1
	EVENT_DISP $a, $3, $12 ; CINNABAR_GYM
	EVENT_DISP $a, $9, $6 ; CINNABAR_LAB_1
	EVENT_DISP $a, $b, $b ; CINNABAR_POKECENTER
	EVENT_DISP $a, $b, $f ; CINNABAR_MART

CinnabarIslandBlocks: ; 0x1c069 90
	INCBIN "maps/cinnabarisland.blk"

Route1_h: ; 0x1c0c3 to 0x1c0e5 (34 bytes) (bank=7) (id=12)
	db $00 ; tileset
	db ROUTE_1_HEIGHT, ROUTE_1_WIDTH ; dimensions (y, x)
	dw Route1Blocks, Route1Texts, Route1Script ; blocks, texts, scripts
	db NORTH | SOUTH ; connections

	; connections data

	db VIRIDIAN_CITY
	dw ViridianCityBlocks + (VIRIDIAN_CITY_HEIGHT - 3) * VIRIDIAN_CITY_WIDTH + 2, $c6e8 ; pointers (connected, current) (strip)
	db $10, $14 ; bigness, width
	db $23, $0a ; alignments (y, x)
	dw $c8bd ; window

	db PALLET_TOWN
	dw PalletTownBlocks, $c83b ; pointers (connected, current) (strip)
	db $0a, $0a ; bigness, width
	db $00, $00 ; alignments (y, x)
	dw $c6f9 ; window

	; end connections data

	dw Route1Object ; objects

Route1Object: ; 0x1c0e5 (size=19)
	db $b ; border tile

	db $0 ; warps

	db $1 ; signs
	db $1b, $9, $3 ; Route1Text3

	db $2 ; people
	db SPRITE_BUG_CATCHER, $18 + 4, $5 + 4, $fe, $1, $1 ; person
	db SPRITE_BUG_CATCHER, $d + 4, $f + 4, $fe, $2, $2 ; person

; XXX what is this?
Unknown_1c0f8: ; 0x1c0f8
	db $12, $c7, $7, $2

Route1Blocks: ; 0x1c0fc 180
	INCBIN "maps/route1.blk"

UndergroundPathEntranceRoute8Blocks: ; 0x1c1b0 16
	INCBIN "maps/undergroundpathentranceroute8.blk"

OaksLabBlocks: ; 0x1c1c0 30
	INCBIN "maps/oakslab.blk"

Route16HouseBlocks:
Route2HouseBlocks:
SaffronHouse1Blocks:
SaffronHouse2Blocks:
VermilionHouse1Blocks:
NameRaterBlocks:
LavenderHouse1Blocks:
LavenderHouse2Blocks:
CeruleanHouse2Blocks:
PewterHouse1Blocks:
PewterHouse2Blocks:
ViridianHouseBlocks: ; 0x1c1de 41DE size=16
	INCBIN "maps/viridianhouse.blk"

CeladonMansion5Blocks:
SchoolBlocks: ; 0x1c1ee 41EE size=16
	INCBIN "maps/school.blk"

CeruleanHouseTrashedBlocks: ; 0x1c1fe size=16
	INCBIN "maps/ceruleanhousetrashed.blk"

DiglettsCaveEntranceRoute11Blocks:
DiglettsCaveRoute2Blocks: ; 0x1c20e size=16
	INCBIN "maps/diglettscaveroute2.blk"

MonsterNames: ; 421E
	db "RHYDON@@@@"
	db "KANGASKHAN"
	db "NIDORAN♂@@"
	db "CLEFAIRY@@"
	db "SPEAROW@@@"
	db "VOLTORB@@@"
	db "NIDOKING@@"
	db "SLOWBRO@@@"
	db "IVYSAUR@@@"
	db "EXEGGUTOR@"
	db "LICKITUNG@"
	db "EXEGGCUTE@"
	db "GRIMER@@@@"
	db "GENGAR@@@@"
	db "NIDORAN♀@@"
	db "NIDOQUEEN@"
	db "CUBONE@@@@"
	db "RHYHORN@@@"
	db "LAPRAS@@@@"
	db "ARCANINE@@"
	db "MEW@@@@@@@"
	db "GYARADOS@@"
	db "SHELLDER@@"
	db "TENTACOOL@"
	db "GASTLY@@@@"
	db "SCYTHER@@@"
	db "STARYU@@@@"
	db "BLASTOISE@"
	db "PINSIR@@@@"
	db "TANGELA@@@"
	db "MISSINGNO."
	db "MISSINGNO."
	db "GROWLITHE@"
	db "ONIX@@@@@@"
	db "FEAROW@@@@"
	db "PIDGEY@@@@"
	db "SLOWPOKE@@"
	db "KADABRA@@@"
	db "GRAVELER@@"
	db "CHANSEY@@@"
	db "MACHOKE@@@"
	db "MR.MIME@@@"
	db "HITMONLEE@"
	db "HITMONCHAN"
	db "ARBOK@@@@@"
	db "PARASECT@@"
	db "PSYDUCK@@@"
	db "DROWZEE@@@"
	db "GOLEM@@@@@"
	db "MISSINGNO."
	db "MAGMAR@@@@"
	db "MISSINGNO."
	db "ELECTABUZZ"
	db "MAGNETON@@"
	db "KOFFING@@@"
	db "MISSINGNO."
	db "MANKEY@@@@"
	db "SEEL@@@@@@"
	db "DIGLETT@@@"
	db "TAUROS@@@@"
	db "MISSINGNO."
	db "MISSINGNO."
	db "MISSINGNO."
	db "FARFETCH'D"
	db "VENONAT@@@"
	db "DRAGONITE@"
	db "MISSINGNO."
	db "MISSINGNO."
	db "MISSINGNO."
	db "DODUO@@@@@"
	db "POLIWAG@@@"
	db "JYNX@@@@@@"
	db "MOLTRES@@@"
	db "ARTICUNO@@"
	db "ZAPDOS@@@@"
	db "DITTO@@@@@"
	db "MEOWTH@@@@"
	db "KRABBY@@@@"
	db "MISSINGNO."
	db "MISSINGNO."
	db "MISSINGNO."
	db "VULPIX@@@@"
	db "NINETALES@"
	db "PIKACHU@@@"
	db "RAICHU@@@@"
	db "MISSINGNO."
	db "MISSINGNO."
	db "DRATINI@@@"
	db "DRAGONAIR@"
	db "KABUTO@@@@"
	db "KABUTOPS@@"
	db "HORSEA@@@@"
	db "SEADRA@@@@"
	db "MISSINGNO."
	db "MISSINGNO."
	db "SANDSHREW@"
	db "SANDSLASH@"
	db "OMANYTE@@@"
	db "OMASTAR@@@"
	db "JIGGLYPUFF"
	db "WIGGLYTUFF"
	db "EEVEE@@@@@"
	db "FLAREON@@@"
	db "JOLTEON@@@"
	db "VAPOREON@@"
	db "MACHOP@@@@"
	db "ZUBAT@@@@@"
	db "EKANS@@@@@"
	db "PARAS@@@@@"
	db "POLIWHIRL@"
	db "POLIWRATH@"
	db "WEEDLE@@@@"
	db "KAKUNA@@@@"
	db "BEEDRILL@@"
	db "MISSINGNO."
	db "DODRIO@@@@"
	db "PRIMEAPE@@"
	db "DUGTRIO@@@"
	db "VENOMOTH@@"
	db "DEWGONG@@@"
	db "MISSINGNO."
	db "MISSINGNO."
	db "CATERPIE@@"
	db "METAPOD@@@"
	db "BUTTERFREE"
	db "MACHAMP@@@"
	db "MISSINGNO."
	db "GOLDUCK@@@"
	db "HYPNO@@@@@"
	db "GOLBAT@@@@"
	db "MEWTWO@@@@"
	db "SNORLAX@@@"
	db "MAGIKARP@@"
	db "MISSINGNO."
	db "MISSINGNO."
	db "MUK@@@@@@@"
	db "MISSINGNO."
	db "KINGLER@@@"
	db "CLOYSTER@@"
	db "MISSINGNO."
	db "ELECTRODE@"
	db "CLEFABLE@@"
	db "WEEZING@@@"
	db "PERSIAN@@@"
	db "MAROWAK@@@"
	db "MISSINGNO."
	db "HAUNTER@@@"
	db "ABRA@@@@@@"
	db "ALAKAZAM@@"
	db "PIDGEOTTO@"
	db "PIDGEOT@@@"
	db "STARMIE@@@"
	db "BULBASAUR@"
	db "VENUSAUR@@"
	db "TENTACRUEL"
	db "MISSINGNO."
	db "GOLDEEN@@@"
	db "SEAKING@@@"
	db "MISSINGNO."
	db "MISSINGNO."
	db "MISSINGNO."
	db "MISSINGNO."
	db "PONYTA@@@@"
	db "RAPIDASH@@"
	db "RATTATA@@@"
	db "RATICATE@@"
	db "NIDORINO@@"
	db "NIDORINA@@"
	db "GEODUDE@@@"
	db "PORYGON@@@"
	db "AERODACTYL"
	db "MISSINGNO."
	db "MAGNEMITE@"
	db "MISSINGNO."
	db "MISSINGNO."
	db "CHARMANDER"
	db "SQUIRTLE@@"
	db "CHARMELEON"
	db "WARTORTLE@"
	db "CHARIZARD@"
	db "MISSINGNO."
	db "MISSINGNO."
	db "MISSINGNO."
	db "MISSINGNO."
	db "ODDISH@@@@"
	db "GLOOM@@@@@"
	db "VILEPLUME@"
	db "BELLSPROUT"
	db "WEEPINBELL"
	db "VICTREEBEL"

INCBIN "baserom.gbc",$1c98a,$1c9c1 - $1c98a

UnnamedText_1c9c1: ; 0x1c9c1
	TX_FAR _UnnamedText_1c9c1
	db $50
; 0x1c9c1 + 5 bytes

INCBIN "baserom.gbc",$1c9c6,$1ca14 - $1c9c6

UnnamedText_1ca14: ; 0x1ca14
	TX_FAR _UnnamedText_1ca14
	db $50
; 0x1ca14 + 5 bytes

CinnabarIslandScript: ; 0x1ca19
	call $3c3c
	ld hl, $d126
	set 5, [hl]
	ld hl, $d796
	res 0, [hl]
	ld hl, $d7a3
	res 1, [hl]
	ld hl, CinnabarIslandScripts
	ld a, [$d639]
	jp $3d97
; 0x1ca34

CinnabarIslandScripts: ; 0x1ca34
	dw CinnabarIslandScript0, CinnabarIslandScript1

CinnabarIslandScript0: ; 0x1ca38
	ld b, $2b
	call $3493
	ret nz
	ld a, [$d361]
	cp $4
	ret nz
	ld a, [$d362]
	cp $12
	ret nz
	ld a, $8
	ld [$d528], a
	ld a, $8
	ld [$ff00+$8c], a
	call $2920
	xor a
	ld [$ff00+$b4], a
	ld a, $1
	ld [$cd38], a
	ld a, $80
	ld [$ccd3], a
	call $3486
	xor a
	ld [$c109], a
	ld [$cd6b], a
	ld a, $1
	ld [$d639], a
	ret
; 0x1ca73

CinnabarIslandScript1: ; 0x1ca73
	ld a, [$cd38]
	and a
	ret nz
	call Delay3
	ld a, $0
	ld [$d639], a
	ret
; 0x1ca81

CinnabarIslandTexts: ; 0x1ca81
	dw CinnabarIslandText1, CinnabarIslandText2, CinnabarIslandText3, CinnabarIslandText4, CinnabarIslandText5, CinnabarIslandText6, CinnabarIslandText7, CinnabarIslandText8

CinnabarIslandText8: ; 0x1ca91
	TX_FAR _CinnabarIslandText8
	db $50
; 0x1ca91 + 5 bytes

CinnabarIslandText1: ; 0x1ca96
	TX_FAR _CinnabarIslandText1
	db $50

CinnabarIslandText2: ; 0x1ca9b
	TX_FAR _CinnabarIslandText2
	db $50

CinnabarIslandText3: ; 0x1caa0
	TX_FAR _CinnabarIslandText3
	db $50

CinnabarIslandText6: ; 0x1caa5
	TX_FAR _CinnabarIslandText6
	db $50

CinnabarIslandText7: ; 0x1caaa
	TX_FAR _CinnabarIslandText7
	db $50

Route1Script: ; 0x1caaf
	jp $3c3c
; 0x1cab2

Route1Texts: ; 0x1cab2
	dw Route1Text1, Route1Text2, Route1Text3

Route1Text1: ; 0x1cab8
	db $08 ; asm
	ld hl, $d7bf
	bit 0, [hl]
	set 0, [hl]
	jr nz, .asm_02840 ; 0x1cac0
	ld hl, Route1ViridianMartSampleText
	call PrintText 
	ld bc, (POTION << 8) | 1
	call GiveItem
	jr nc, .asm_a630e ; 0x1cace
	ld hl, $4ae8
	jr .asm_46d43 ; 0x1cad3
.asm_a630e ; 0x1cad5
	ld hl, $4af3
	jr .asm_46d43 ; 0x1cad8
.asm_02840 ; 0x1cada
	ld hl, $4aee
.asm_46d43 ; 0x1cadd
	call PrintText
	jp TextScriptEnd

Route1ViridianMartSampleText: ; 0x1cae3
	TX_FAR _Route1ViridianMartSampleText
	db $50
; 0x1cae3 + 5 bytes

INCBIN "baserom.gbc",$1cae8,$1caee - $1cae8

UnnamedText_1caee: ; 0x1caee
	TX_FAR _UnnamedText_1caee
	db $50
; 0x1caee + 5 bytes

UnnamedText_1caf3: ; 0x1caf3
	TX_FAR _UnnamedText_1caf3
	db $50
; 0x1caf3 + 5 bytes

Route1Text2: ; 0x1caf8
	TX_FAR _Route1Text2
	db $50

Route1Text3: ; 0x1cafd
	TX_FAR _Route1Text3
	db $50

OaksLab_h: ; 0x1cb02 to 0x1cb0e (12 bytes) (bank=7) (id=40)
	db $05 ; tileset
	db OAKS_LAB_HEIGHT, OAKS_LAB_WIDTH ; dimensions (y, x)
	dw OaksLabBlocks, OaksLabTexts, OaksLabScript ; blocks, texts, scripts
	db $00 ; connections

	dw OaksLabObject ; objects

OaksLabScript: ; 0x1cb0e
	ld a, [$d74b]
	bit 6, a
	call nz, $5076
	ld a, $1
	ld [$cf0c], a
	xor a
	ld [$cc3c], a
	ld hl, OaksLabScripts
	ld a, [W_OAKSLABCURSCRIPT]
	jp $3d97
; 0x1cb28

OaksLabScripts: ; 0x1cb28
	dw OaksLabScript0, OaksLabScript1, OaksLabScript2, OaksLabScript3, OaksLabScript4, OaksLabScript5, OaksLabScript6, OaksLabScript7, OaksLabScript8, OaksLabScript9, OaksLabScript10, OaksLabScript11, OaksLabScript12, OaksLabScript13, OaksLabScript14, OaksLabScript15, OaksLabScript16, OaksLabScript17, OaksLabScript18

OaksLabScript0: ; 0x1cb4e
	ld a, [$d74b]
	bit 7, a
	ret z
	ld a, [$cf10]
	and a
	ret nz
	ld a, $31
	ld [$cc4d], a
	ld a, $15
	call Predef
	ld hl, $d72e
	res 4, [hl]

	ld a, $1
	ld [W_OAKSLABCURSCRIPT], a
	ret
; 0x1cb6e

OaksLabScript1: ; 0x1cb6e
	ld a, $8
	ld [$ff00+$8c], a
	ld de, OakEntryMovement
	call MoveSprite

	ld a, $2
	ld [W_OAKSLABCURSCRIPT], a
	ret
; 0x1cb7e

OakEntryMovement: ; 0x1cb7e
	db $40, $40, $40, $ff

OaksLabScript2: ; 0x1cb82
	ld a, [$d730]
	bit 0, a
	ret nz
	ld a, $31
	ld [$cc4d], a
	ld a, $11
	call Predef
	ld a, $2e
	ld [$cc4d], a
	ld a, $15
	call Predef

	ld a, $3
	ld [W_OAKSLABCURSCRIPT], a
	ret
; 0x1cba2

OaksLabScript3: ; 0x1cba2
	call Delay3
	ld hl, $ccd3
	ld de, PlayerEntryMovementRLE
	call $350c
	dec a
	ld [$cd38], a
	call $3486
	ld a, $1
	ld [$ff00+$8c], a
	xor a
	ld [$ff00+$8d], a
	call $34a6 ; face object
	ld a, $5
	ld [$ff00+$8c], a
	xor a
	ld [$ff00+$8d], a
	call $34a6 ; face object

	ld a, $4
	ld [W_OAKSLABCURSCRIPT], a
	ret
; 0x1cbcf

PlayerEntryMovementRLE: ; 0x1cbcf
	db $40, $8, $ff

OaksLabScript4: ; 0x1cbd2
	ld a, [$cd38]
	and a
	ret nz
	ld hl, $d747
	set 0, [hl]
	ld hl, $d74b
	set 0, [hl]
	ld a, $1
	ld [$ff00+$8c], a
	ld a, $4
	ld [$ff00+$8d], a
	call $34a6 ; face object
	call $2429
	ld hl, $d733
	res 1, [hl]
	call $2307

	ld a, $5
	ld [W_OAKSLABCURSCRIPT], a
	ret
; 0x1cbfd

OaksLabScript5: ; 0x1cbfd
	ld a, $fc
	ld [$cd6b], a
	ld a, $11
	ld [$ff00+$8c], a
	call $2920
	call Delay3
	ld a, $12
	ld [$ff00+$8c], a
	call $2920
	call Delay3
	ld a, $13
	ld [$ff00+$8c], a
	call $2920
	call Delay3
	ld a, $14
	ld [$ff00+$8c], a
	call $2920
	ld hl, $d74b
	set 1, [hl]
	xor a
	ld [$cd6b], a

	ld a, $6
	ld [W_OAKSLABCURSCRIPT], a
	ret
; 0x1cc36

OaksLabScript6: ; 0x1cc36
	ld a, [W_YCOORD]
	cp $6
	ret nz
	ld a, $5
	ld [$ff00+$8c], a
	xor a
	ld [$ff00+$8d], a
	call $34a6 ; face object
	ld a, $1
	ld [$ff00+$8c], a
	xor a
	ld [$ff00+$8d], a
	call $34a6 ; face object
	call $2429
	ld a, $c
	ld [$ff00+$8c], a
	call $2920
	ld a, $1
	ld [$cd38], a
	ld a, $40
	ld [$ccd3], a
	call $3486
	ld a, $8
	ld [$d528], a

	ld a, $7
	ld [W_OAKSLABCURSCRIPT], a
	ret
; 0x1cc72

OaksLabScript7: ; 0x1cc72
	ld a, [$cd38]
	and a
	ret nz
	call Delay3

	ld a, $6
	ld [W_OAKSLABCURSCRIPT], a
	ret
; 0x1cc80

OaksLabScript8: ; 0x1cc80
	ld a, [W_PLAYERSTARTER]
	cp CHARMANDER
	jr z, .Charmander\@ ; 0x1cc85 $6
	cp SQUIRTLE
	jr z, .Squirtle\@ ; 0x1cc89 $1d
	jr .Bulbasaur\@ ; 0x1cc8b $38
.Charmander\@
	ld de, .MiddleBallMovement1
	ld a, [W_YCOORD]
	cp $4 ; is the player standing below the table?
	jr z, .asm_1ccf3 ; 0x1cc95 $5c
	ld de, .MiddleBallMovement2
	jr .asm_1ccf3 ; 0x1cc9a $57

.MiddleBallMovement1
	db 0,0,$C0,$C0,$C0,$40,$FF
.MiddleBallMovement2
	db 0,$C0,$C0,$C0,$FF

.Squirtle\@
	ld de, .RightBallMovement1
	ld a, [W_YCOORD]
	cp $4 ; is the player standing below the table?
	jr z, .asm_1ccf3 ; 0x1ccb0 $41
	ld de, .RightBallMovement2
	jr .asm_1ccf3 ; 0x1ccb5 $3c

.RightBallMovement1
	db 0,0,$C0,$C0,$C0,$C0,$40,$FF
.RightBallMovement2
	db 0,$C0,$C0,$C0,$C0,$FF

.Bulbasaur\@
	ld de, .LeftBallMovement1
	ld a, [W_XCOORD]
	cp $9 ; is the player standing to the right of the table?
	jr nz, .asm_1ccf3 ; 0x1cccd $24
	push hl
	ld a, $1
	ld [$ff00+$8c], a
	ld a, $4
	ld [$ff00+$8b], a
	call $34fc
	push hl
	ld [hl], $4c
	inc hl
	inc hl
	ld [hl], $0
	pop hl
	inc h
	ld [hl], $8
	inc hl
	ld [hl], $9
	ld de, .LeftBallMovement2 ; the rival is not currently onscreen, so account for that
	pop hl
	jr .asm_1ccf3 ; 0x1cced $4

.LeftBallMovement1
	db 0,$C0 ; not yet terminated!
.LeftBallMovement2
	db $C0,$FF

.asm_1ccf3
	ld a, $1
	ld [$ff00+$8c], a
	call MoveSprite

	ld a, $9
	ld [W_OAKSLABCURSCRIPT], a
	ret
; 0x1cd00

OaksLabScript9: ; 0x1cd00
	ld a, [$d730]
	bit 0, a
	ret nz
	ld a, $fc
	ld [$cd6b], a
	ld a, $1
	ld [$ff00+$8c], a
	ld a, $4
	ld [$ff00+$8d], a
	call $34a6 ; face object
	ld a, $d
	ld [$ff00+$8c], a
	call $2920
	ld a, [$cd3e]
	cp $2
	jr nz, .asm_1cd28 ; 0x1cd22 $4
	ld a, $2b
	jr .asm_1cd32 ; 0x1cd26 $a
.asm_1cd28
	cp $3
	jr nz, .asm_1cd30 ; 0x1cd2a $4
	ld a, $2c
	jr .asm_1cd32 ; 0x1cd2e $2
.asm_1cd30
	ld a, $2d
.asm_1cd32
	ld [$cc4d], a
	ld a, $11
	call Predef
	call Delay3
	ld a, [$cd3d]
	ld [W_RIVALSTARTER], a
	ld [$cf91], a
	ld [$d11e], a
	call GetMonName
	ld a, $1
	ld [$ff00+$8c], a
	ld a, $4
	ld [$ff00+$8d], a
	call $34a6 ; face object
	ld a, $e
	ld [$ff00+$8c], a
	call $2920
	ld hl, $d74b
	set 2, [hl]
	xor a
	ld [$cd6b], a

	ld a, $a
	ld [W_OAKSLABCURSCRIPT], a
	ret
; 0x1cd6d

OaksLabScript10: ; 0x1cd6d
	ld a, [W_YCOORD]
	cp $6
	ret nz
	ld a, $1
	ld [$ff00+$8c], a
	xor a
	ld [$ff00+$8d], a
	call $34a6 ; face object
	ld a, $8
	ld [$d528], a
	ld c, $2
	ld a, $de
	call $23a1 ; play music
	ld a, $f
	ld [$ff00+$8c], a
	call $2920
	ld a, $1
	ld [$ff00+$9b], a
	ld a, $1
	swap a
	ld [$ff00+$95], a
	ld a, $22
	call Predef
	ld a, [$ff00+$95]
	dec a
	ld [$ff00+$95], a
	ld a, $20
	call Predef
	ld de, $cc97
	ld a, $1
	ld [$ff00+$8c], a
	call MoveSprite

	ld a, $b
	ld [W_OAKSLABCURSCRIPT], a
	ret
; 0x1cdb9

OaksLabScript11: ; 0x1cdb9
	ld a, [$d730]
	bit 0, a
	ret nz

	; define which team rival uses, and fight it
	ld a, SONY1 + 200
	ld [W_CUROPPONENT], a
	ld a, [W_RIVALSTARTER]
	cp SQUIRTLE
	jr nz, .NotSquirtle\@ ; 0x1cdc9 $4
	ld a, $1
	jr .done\@ ; 0x1cdcd $a
.NotSquirtle\@
	cp BULBASAUR
	jr nz, .Charmander\@ ; 0x1cdd1 $4
	ld a, $2
	jr .done\@ ; 0x1cdd5 $2
.Charmander\@
	ld a, $3
.done\@
	ld [W_TRAINERNO], a
	ld a, $1
	ld [$cf13], a
	call $32ef
	ld hl, UnnamedText_1d3be
	ld de, UnnamedText_1d3c3
	call $3354
	ld hl, $d72d
	set 6, [hl]
	set 7, [hl]
	xor a
	ld [$cd6b], a
	ld a, $8
	ld [$d528], a

	ld a, $c
	ld [W_OAKSLABCURSCRIPT], a
	ret
; 0x1ce03

OaksLabScript12: ; 0x1ce03
	ld a, $f0
	ld [$cd6b], a
	ld a, $8
	ld [$d528], a
	call $2429
	ld a, $1
	ld [$cf13], a
	call $32f9
	ld a, $1
	ld [$ff00+$8c], a
	xor a
	ld [$ff00+$8d], a
	call $34a6 ; face object
	ld a, $7
	call Predef
	ld hl, $d74b
	set 3, [hl]

	ld a, $d
	ld [W_OAKSLABCURSCRIPT], a
	ret
; 0x1ce32

OaksLabScript13: ; 0x1ce32
	ld c, $14
	call $3739
	ld a, $10
	ld [$ff00+$8c], a
	call $2920
	ld b, $2
	ld hl, $5b47
	call Bankswitch
	ld a, $1
	ld [$ff00+$8c], a
	ld de, .RivalExitMovement
	call MoveSprite
	ld a, [W_XCOORD]
	cp $4
	; move left or right depending on where the player is standing
	jr nz, .asm_1ce5b ; 0x1ce55 $4
	ld a, $c0
	jr .asm_1ce5d ; 0x1ce59 $2
.asm_1ce5b
	ld a, $80
.asm_1ce5d
	ld [$cc5b], a

	ld a, $e
	ld [W_OAKSLABCURSCRIPT], a
	ret
; 0x1ce66

.RivalExitMovement
	db $E0,0,0,0,0,0,$FF

OaksLabScript14: ; 0x1ce6d
	ld a, [$d730]
	bit 0, a
	jr nz, .asm_1ce8c ; 0x1ce72 $18
	ld a, $2a
	ld [$cc4d], a
	ld a, $11
	call Predef
	xor a
	ld [$cd6b], a
	call $2307 ; reset to map music
	ld a, $12
	ld [W_OAKSLABCURSCRIPT], a
	jr .done\@ ; 0x1ce8a $23
.asm_1ce8c
	ld a, [$cf0f]
	cp $5
	jr nz, .asm_1cea8 ; 0x1ce91 $15
	ld a, [$d362]
	cp $4
	jr nz, .asm_1cea1 ; 0x1ce98 $7
	ld a, $c
	ld [$c109], a
	jr .done\@ ; 0x1ce9f $e
.asm_1cea1
	ld a, $8
	ld [$c109], a
	jr .done\@ ; 0x1cea6 $7
.asm_1cea8
	cp $4
	ret nz
	xor a
	ld [$c109], a
.done\@
	ret
; 0x1ceb0

OaksLabScript15: ; 0x1ceb0
	xor a
	ld [$ff00+$b4], a
	call $3c3c
	ld a, $ff
	ld [$c0ee], a
	call $23b1
	ld b, $2
	ld hl, $5b47
	call Bankswitch
	ld a, $15
	ld [$ff00+$8c], a
	call $2920
	call $502b
	ld a, $2a
	ld [$cc4d], a
	ld a, $15
	call Predef
	ld a, [$cd37]
	ld [$d157], a
	ld b, $0
	ld c, a
	ld hl, $cc97
	ld a, $40
	call $36e0
	ld [hl], $ff
	ld a, $1
	ld [$ff00+$8c], a
	ld de, $cc97
	call MoveSprite

	ld a, $10
	ld [W_OAKSLABCURSCRIPT], a
	ret
; 0x1cefd

Function1CEFD ; 0x1cefd
	ld a, $1
	ld [$ff00+$8c], a
	ld a, $4
	ld [$ff00+$8d], a
	call $34a6 ; face object
	ld a, $8
	ld [$ff00+$8c], a
	xor a
	ld [$ff00+$8d], a
	jp $34a6 ; face object
; 0x1cf12

OaksLabScript16: ; 0x1cf12
	ld a, [$d730]
	bit 0, a
	ret nz
	call $3c3c
	call $2307
	ld a, $fc
	ld [$cd6b], a
	call Function1CEFD
	ld a, $16
	ld [$ff00+$8c], a
	call $2920
	call DelayFrame
	call Function1CEFD
	ld a, $17
	ld [$ff00+$8c], a
	call $2920
	call DelayFrame
	call Function1CEFD
	ld a, $18
	ld [$ff00+$8c], a
	call $2920
	call DelayFrame
	ld a, $19
	ld [$ff00+$8c], a
	call $2920
	call Delay3
	ld a, $2f
	ld [$cc4d], a
	ld a, $11
	call Predef
	ld a, $30
	ld [$cc4d], a
	ld a, $11
	call Predef
	call Function1CEFD
	ld a, $1a
	ld [$ff00+$8c], a
	call $2920
	ld a, $1
	ld [$ff00+$8c], a
	ld a, $c
	ld [$ff00+$8d], a
	call $34a6 ; face object
	call Delay3
	ld a, $1b
	ld [$ff00+$8c], a
	call $2920
	ld hl, $d74b
	set 5, [hl]
	ld hl, $d74e
	set 0, [hl]
	ld a, $1
	ld [$cc4d], a
	ld a, $11
	call Predef
	ld a, $2
	ld [$cc4d], a
	ld a, $15
	call Predef
	ld a, [$d157]
	ld b, $0
	ld c, a
	ld hl, $cc97
	xor a
	call $36e0
	ld [hl], $ff
	ld a, $ff
	ld [$c0ee], a
	call $23b1
	ld b, $2
	ld hl, $5b47
	call Bankswitch
	ld a, $1
	ld [$ff00+$8c], a
	ld de, $cc97
	call MoveSprite

	ld a, $11
	ld [W_OAKSLABCURSCRIPT], a
	ret
; 0x1cfd4

OaksLabScript17: ; 0x1cfd4
	ld a, [$d730]
	bit 0, a
	ret nz
	call $2307
	ld a, $2a
	ld [$cc4d], a
	ld a, $11
	call Predef
	ld hl, $d7eb
	set 0, [hl]
	res 1, [hl]
	set 7, [hl]
	ld a, $22
	ld [$cc4d], a
	ld a, $15
	call Predef
	ld a, $5
	ld [$d5f1], a
	xor a
	ld [$cd6b], a

	ld a, $12
	ld [W_OAKSLABCURSCRIPT], a
	ret
; 0x1d009

OaksLabScript18: ; 0x1d009
	ret
; 0x1d00a

Function1D00A: ; 0x1d00a
	ld hl, W_BAGITEM01
	ld bc, $0000
.asm_1d010
	ld a, [hli]
	cp $ff
	ret z
	cp OAKS_PARCEL
	jr z, .GotParcel ; 0x1d016 $4
	inc hl
	inc c
	jr .asm_1d010 ; 0x1d01a $f4
.GotParcel
	ld hl, $d31d
	ld a, c
	ld [$cf92], a
	ld a, $1
	ld [$cf96], a
	jp $2bbb
; 0x1d02b


INCBIN "baserom.gbc",$1d02b,$1d082-$1d02b

OaksLabTexts: ; 0x1d082
	dw OaksLabText1, OaksLabText2, OaksLabText3, OaksLabText4, OaksLabText5, OaksLabText6, OaksLabText7, OaksLabText8, OaksLabText9, OaksLabText10, OaksLabText11, OaksLabText12, OaksLabText13, OaksLabText14, OaksLabText15, OaksLabText16, OaksLabText17, OaksLabText18, OaksLabText19, OaksLabText20, OaksLabText21, OaksLabText22, OaksLabText23, OaksLabText24, OaksLabText25, OaksLabText26, OaksLabText27, OaksLabText28, OaksLabText29, OaksLabText30, OaksLabText31, OaksLabText32, OaksLabText33, OaksLabText34, OaksLabText35, OaksLabText36, OaksLabText37, OaksLabText38

OaksLabText28:
OaksLabText1: ; 0x1d0ce
	db $08 ; asm
	ld a, [$d74b]
	bit 0, a
	jr nz, .asm_1d0de ; 0x1d0d4
	ld hl, OaksLabGaryText1
	call PrintText
	jr .asm_1d0f0 ; 0x1d0dc
.asm_1d0de ; 0x1d0de
	bit 2, a
	jr nz, .asm_1d0ea ; 0x1d0e0
	ld hl, OaksLabText40
	call PrintText
	jr .asm_1d0f0 ; 0x1d0e8
.asm_1d0ea ; 0x1d0ea
	ld hl, OaksLabText41
	call PrintText
.asm_1d0f0 ; 0x1d0f0
	jp TextScriptEnd

OaksLabGaryText1: ; 0x1d0f3
	TX_FAR _OaksLabGaryText1
	db $50
; 0x1d0f8

OaksLabText40: ; 0x1d0f8
	TX_FAR _OaksLabText40
	db $50
; 0x1d0f8 + 5 bytes

OaksLabText41: ; 0x1d0fd
	TX_FAR _OaksLabText41
	db $50
; 0x1d0fd + 5 bytes

OaksLabText29:
OaksLabText2: ; 0x1d102
	db $8
	ld a, $b1
	ld [$cd3d], a
	ld a, $3
	ld [$cd3e], a
	ld a, $b0
	ld b, $2
	jr asm_1d133 ; 0x1d111 $20

OaksLabText30:
OaksLabText3: ; 0x1d113
	db $8
	ld a, $99
	ld [$cd3d], a
	ld a, $4
	ld [$cd3e], a
	ld a, $b1
	ld b, $3
	jr asm_1d133 ; 0x1d122 $f

OaksLabText31:
OaksLabText4: ; 0x1d124
	db $8
	ld a, $b0
	ld [$cd3d], a
	ld a, $2
	ld [$cd3e], a
	ld a, $99
	ld b, $4

asm_1d133: ; 0x1d133
	ld [$cf91], a
	ld [$d11e], a
	ld a, b
	ld [$cf13], a
	ld a, [$d74b]
	bit 2, a
	jp nz, $522d
	bit 1, a
	jr nz, asm_1d157 ; 0x1d147 $e
	ld hl, OaksLabText39
	call PrintText
	jp TextScriptEnd
; 0x1d152

OaksLabText39: ; 0x1d152
	TX_FAR _OaksLabText39
	db $50

asm_1d157: ; 0x1d157
	ld a, $5
	ld [$ff00+$8c], a
	ld a, $9
	ld [$ff00+$8b], a
	call $34fc
	ld [hl], $0
	; manually fixed some disassembler issues around here
	ld a, $1
	ld [$FF8c], a
	ld a, $9
	ld [$ff00+$8b], a
	call $34fc
	ld [hl], $c
	ld hl, $d730
	set 6, [hl]
	ld a, $46
	call Predef
	ld hl, $d730
	res 6, [hl]
	call $3071
	ld c, $a
	call $3739
	ld a, [$cf13]
	cp $2
	jr z, OaksLabLookAtCharmander
	cp $3
	jr z, OaksLabLookAtSquirtle
	jr OaksLabLookAtBulbasaur

OaksLabLookAtCharmander ; 0x1d195
	ld hl, OaksLabCharmanderText
	jr OaksLabMonChoiceMenu
OaksLabCharmanderText: ; 0x1d19a
	TX_FAR _OaksLabCharmanderText ; 0x94e06
	db $50
; 0x1d19f

OaksLabLookAtSquirtle: ; 0x1d19f
	ld hl, OaksLabSquirtleText
	jr OaksLabMonChoiceMenu
OaksLabSquirtleText: ; 0x1d1a4
	TX_FAR _OaksLabSquirtleText ; 0x94e2f
	db $50
; 0x1d1a9

OaksLabLookAtBulbasaur: ; 0x1d1a9
	ld hl, OaksLabBulbasaurText
	jr OaksLabMonChoiceMenu
OaksLabBulbasaurText: ; 0x1d1ae
	TX_FAR _OaksLabBulbasaurText ; 0x94e57
	db $50
; 0x1d1b3

OaksLabMonChoiceMenu: ; 0x1d1b3
	call PrintText
	ld a, $1
	ld [$cc3c], a
	call $35ec ; yes/no menu
	ld a, [$cc26]
	and a
	jr nz, OaksLabMonChoiceEnd
	ld a, [$cf91]
	ld [$d717], a
	ld [$d11e], a
	call GetMonName
	ld a, [$cf13]
	cp $2
	jr nz, asm_1d1db ; 0x1d1d5 $4
	ld a, $2b
	jr asm_1d1e5 ; 0x1d1d9 $a
asm_1d1db: ; 0x1d1db
	cp $3
	jr nz, asm_1d1e3 ; 0x1d1dd $4
	ld a, $2c
	jr asm_1d1e5 ; 0x1d1e1 $2
asm_1d1e3: ; 0x1d1e3
	ld a, $2d
asm_1d1e5: ; 0x1d1e5
	ld [$cc4d], a
	ld a, $11
	call Predef
	ld a, $1
	ld [$cc3c], a
	ld hl, OaksLabMonEnergeticText
	call PrintText
	ld hl, OaksLabReceivedMonText
	call PrintText
	xor a
	ld [$cc49], a
	ld a, $5
	ld [$d127], a
	ld a, [$cf91]
	ld [$d11e], a
	call AddPokemonToParty
	ld hl, $d72e
	set 3, [hl]
	ld a, $fc
	ld [$cd6b], a
	ld a, $8
	ld [W_OAKSLABCURSCRIPT], a
OaksLabMonChoiceEnd: ; 0x1d21f
	jp TextScriptEnd
; 0x1d222

OaksLabMonEnergeticText: ; 0x1d222
	TX_FAR _OaksLabMonEnergeticText
	db $50
; 0x1d222 + 5 bytes

OaksLabReceivedMonText: ; 0x1d227
	TX_FAR _OaksLabReceivedMonText ; 0x94ea0
	db $11, $50
; 0x1d22d

INCBIN "baserom.gbc",$1d22d,$1d243 - $1d22d

OaksLabLastMonText: ; 0x1d243
	TX_FAR _OaksLabLastMonText
	db $50
; 0x1d248

OaksLabText32:
OaksLabText5: ; 0x1d248
	db $08 ; asm
	ld a, [$d747]
	bit 6, a
	jr nz, .asm_50e81 ; 0x1d24e
	ld hl, $d2f7
	ld b, $13
	call $2b7f
	ld a, [$d11e]
	cp $2
	jr c, .asm_b28b0 ; 0x1d25d
	ld a, [$d74b]
	bit 5, a
	jr z, .asm_b28b0 ; 0x1d264
.asm_50e81 ; 0x1d266
	ld hl, UnnamedText_1d31d
	call PrintText
	ld a, $1
	ld [$cc3c], a
	ld a, $56
	call Predef
	jp $52ed
.asm_b28b0 ; 0x1d279
	ld b,POKE_BALL
	call $3493
	jr nz, .asm_17c30 ; 0x1d27e
	ld a, [$d7eb]
	bit 5, a
	jr nz, .asm_f1adc ; 0x1d285
	ld a, [$d74b]
	bit 5, a
	jr nz, .asm_333a2 ; 0x1d28c
	bit 3, a
	jr nz, .asm_76269 ; 0x1d290
	ld a, [$d72e]
	bit 3, a
	jr nz, .asm_4a5e0 ; 0x1d297
	ld hl, UnnamedText_1d2f0
	call PrintText
	jr .asm_0f042 ; 0x1d29f
.asm_4a5e0 ; 0x1d2a1
	ld hl, UnnamedText_1d2f5
	call PrintText
	jr .asm_0f042 ; 0x1d2a7
.asm_76269 ; 0x1d2a9
	ld b, OAKS_PARCEL
	call $3493
	jr nz, .asm_a8fcf ; 0x1d2ae
	ld hl, UnnamedText_1d2fa
	call PrintText
	jr .asm_0f042 ; 0x1d2b6
.asm_a8fcf ; 0x1d2b8
	ld hl, OaksLabDeliverParcelText
	call PrintText
	call $500a
	ld a, $f
	ld [W_OAKSLABCURSCRIPT], a
	jr .asm_0f042 ; 0x1d2c6
.asm_333a2 ; 0x1d2c8
	ld hl, OaksLabAroundWorldText
	call PrintText
	jr .asm_0f042 ; 0x1d2ce
.asm_f1adc ; 0x1d2d0
	ld hl, $d74b
	bit 4, [hl]
	set 4, [hl]
	jr nz, .asm_17c30 ; 0x1d2d7
	ld bc, (POKE_BALL << 8) | 5
	call GiveItem
	ld hl, OaksLabGivePokeballsText
	call PrintText
	jr .asm_0f042 ; 0x1d2e5
.asm_17c30 ; 0x1d2e7
	ld hl, OaksLabPleaseVisitText
	call PrintText
.asm_0f042 ; 0x1d2ed
	jp TextScriptEnd
; 0x1d2f0

UnnamedText_1d2f0: ; 0x1d2f0
	TX_FAR _UnnamedText_1d2f0
	db $50
; 0x1d2f5

UnnamedText_1d2f5: ; 0x1d2f5
	TX_FAR _UnnamedText_1d2f5
	db $50
; 0x1d2fa

UnnamedText_1d2fa: ; 0x1d2fa
	TX_FAR _UnnamedText_1d2fa
	db $50
; 0x1d2ff

OaksLabDeliverParcelText: ; 0x1d2ff
	TX_FAR _OaksLabDeliverParcelText1 ; 0x94f69
	db $11
	TX_FAR _OaksLabDeliverParcelText2
	db $50
; 0x1d309

OaksLabAroundWorldText: ; 0x1d309
	TX_FAR _OaksLabAroundWorldText
	db $50
; 0x1d30e

OaksLabGivePokeballsText: ; 0x1d30e
	TX_FAR _OaksLabGivePokeballsText1 ; 0x9506d
	db $11
	TX_FAR _OaksLabGivePokeballsText2
	db $50
; 0x1d318

OaksLabPleaseVisitText: ; 0x1d318
	TX_FAR _OaksLabPleaseVisitText
	db $50
; 0x1d318 + 5 bytes

UnnamedText_1d31d: ; 0x1d31d
	TX_FAR _UnnamedText_1d31d
	db $50
; 0x1d31d + 5 bytes

OaksLabText34:
OaksLabText33:
OaksLabText7: ; 0x1d322
OaksLabText6: ; 0x1d322
	db $08 ; asm
	ld hl, UnnamedText_1d32c
	call PrintText
	jp TextScriptEnd

UnnamedText_1d32c: ; 0x1d32c
	TX_FAR _UnnamedText_1d32c
	db $50
; 0x1d32c + 5 bytes

OaksLabText35:
OaksLabText8: ; 0x1d331
	TX_FAR _OaksLabText8
	db $50

OaksLabText36:
OaksLabText9: ; 0x1d336
	db $08 ; asm
	ld hl, UnnamedText_1d340
	call PrintText
	jp TextScriptEnd

UnnamedText_1d340: ; 0x1d340
	TX_FAR _UnnamedText_1d340
	db $50
; 0x1d340 + 5 bytes

OaksLabText17: ; 0x1d345
	db $8
	ld hl, OaksLabRivalWaitingText
	call PrintText
	jp TextScriptEnd
; 0x1d34f

OaksLabRivalWaitingText: ; 0x1d34f
	TX_FAR _OaksLabRivalWaitingText
	db $50
; 0x1d34f + 5 bytes

OaksLabText18: ; 0x1d354
	db $8
	ld hl, OaksLabChooseMonText
	call PrintText
	jp TextScriptEnd
; 0x1d35e

OaksLabChooseMonText: ; 0x1d35e
	TX_FAR _OaksLabChooseMonText
	db $50
; 0x1d35e + 5 bytes

OaksLabText19: ; 0x1d363
	db $8
	ld hl, OaksLabRivalInterjectionText
	call PrintText
	jp TextScriptEnd
; 0x1d36d

OaksLabRivalInterjectionText: ; 0x1d36d
	TX_FAR _OaksLabRivalInterjectionText
	db $50
; 0x1d36d + 5 bytes

OaksLabText20: ; 0x1d372
	db $8
	ld hl, OaksLabBePatientText
	call PrintText
	jp TextScriptEnd
; 0x1d37c

OaksLabBePatientText: ; 0x1d37c
	TX_FAR _OaksLabBePatientText
	db $50
; 0x1d37c + 5 bytes

OaksLabText12: ; 0x1d381
	db $8
	ld hl, OaksLabLeavingText
	call PrintText
	jp TextScriptEnd
; 0x1d38b

OaksLabLeavingText: ; 0x1d38b
	TX_FAR _OaksLabLeavingText
	db $50
; 0x1d38b + 5 bytes

OaksLabText13: ; 0x1d390
	db $8
	ld hl, OaksLabRivalPickingMonText
	call PrintText
	jp TextScriptEnd
; 0x1d39a

OaksLabRivalPickingMonText: ; 0x1d39a
	TX_FAR _OaksLabRivalPickingMonText
	db $50
; 0x1d39f

OaksLabText14: ; 0x1d39f
	db $8
	ld hl, OaksLabRivalReceivedMonText
	call PrintText
	jp TextScriptEnd
; 0x1d3a9

OaksLabRivalReceivedMonText: ; 0x1d3a9
	TX_FAR _OaksLabRivalReceivedMonText ; 0x95461
	db $11, $50
; 0x1d3af

OaksLabText15: ; 0x1d3af
	db $8
	ld hl, OaksLabRivalChallengeText
	call PrintText
	jp TextScriptEnd
; 0x1d3b9

OaksLabRivalChallengeText: ; 0x1d3b9
	TX_FAR _OaksLabRivalChallengeText
	db $50
; 0x1d3be

UnnamedText_1d3be: ; 0x1d3be
	TX_FAR _UnnamedText_1d3be
	db $50
; 0x1d3c3

UnnamedText_1d3c3: ; 0x1d3c3
	TX_FAR _UnnamedText_1d3c3
	db $50
; 0x1d3c8

OaksLabText16: ; 0x1d3c8
	db $8
	ld hl, OaksLabRivalToughenUpText
	call PrintText
	jp TextScriptEnd
; 0x1d3d2

OaksLabRivalToughenUpText: ; 0x1d3d2
	TX_FAR _OaksLabRivalToughenUpText
	db $50
; 0x1d3d7

OaksLabText21: ; 0x1d3d7
	TX_FAR _OaksLabText21
	db $50
; 0x1d3dc

OaksLabText22: ; 0x1d3dc
	TX_FAR _OaksLabText22
	db $50
; 0x1d3e1

OaksLabText23: ; 0x1d3e1
	TX_FAR _OaksLabText23
	db $50
; 0x1d3e6

OaksLabText24: ; 0x1d3e6
	TX_FAR _OaksLabText24
	db $50
; 0x1d3eb

OaksLabText25: ; 0x1d3eb
	TX_FAR _OaksLabText25
	db $11, $50
; 0x1d3f1

OaksLabText26: ; 0x1d3f1
	TX_FAR _OaksLabText26
	db $50
; 0x1d3f6

OaksLabText27: ; 0x1d3f6
	TX_FAR _OaksLabText27
	db $50
; 0x1d3fb

OaksLabText38:
OaksLabText37:
OaksLabText11:
OaksLabText10: ; 0x1d3fb
	db $08 ; asm
	ld hl, UnnamedText_1d405
	call PrintText
	jp TextScriptEnd

UnnamedText_1d405: ; 0x1d405
	TX_FAR _UnnamedText_1d405
	db $50
; 0x1d405 + 5 bytes

OaksLabObject: ; 0x1d40a (size=88)
	db $3 ; border tile

	db $2 ; warps
	db $b, $4, $2, $ff
	db $b, $5, $2, $ff

	db $0 ; signs

	db $b ; people
	db SPRITE_BLUE, $3 + 4, $4 + 4, $ff, $ff, $41, SONY1 + $C8, $1 ; trainer
	db SPRITE_BALL, $3 + 4, $6 + 4, $ff, $ff, $2 ; person
	db SPRITE_BALL, $3 + 4, $7 + 4, $ff, $ff, $3 ; person
	db SPRITE_BALL, $3 + 4, $8 + 4, $ff, $ff, $4 ; person
	db SPRITE_OAK, $2 + 4, $5 + 4, $ff, $d0, $5 ; person
	db SPRITE_BOOK_MAP_DEX, $1 + 4, $2 + 4, $ff, $ff, $6 ; person
	db SPRITE_BOOK_MAP_DEX, $1 + 4, $3 + 4, $ff, $ff, $7 ; person
	db SPRITE_OAK, $a + 4, $5 + 4, $ff, $d1, $8 ; person
	db SPRITE_GIRL, $9 + 4, $1 + 4, $fe, $1, $9 ; person
	db SPRITE_OAK_AIDE, $a + 4, $2 + 4, $ff, $ff, $a ; person
	db SPRITE_OAK_AIDE, $a + 4, $8 + 4, $ff, $ff, $b ; person

	; warp-to
	EVENT_DISP $5, $b, $4
	EVENT_DISP $5, $b, $5

ViridianMart_h: ; 0x1d462 to 0x1d46e (12 bytes) (bank=7) (id=42)
	db $02 ; tileset
	db VIRIDIAN_MART_HEIGHT, VIRIDIAN_MART_WIDTH ; dimensions (y, x)
	dw ViridianMartBlocks, ViridianMartTexts, ViridianMartScript ; blocks, texts, scripts
	db $00 ; connections

	dw ViridianMartObject ; objects

ViridianMartScript: ; 0x1d46e
	call ViridianMartScript_Unknown1d47d
	call $3c3c
	ld hl, $5495
	ld a, [$d60d]
	jp $3d97
; 0x1d47d

ViridianMartScript_Unknown1d47d: ; 0x1d47d
INCBIN "baserom.gbc",$1d47d,$1e

ViridianMartScript0: ; 0x1d49b
	call $2429
	ld a, $4
	ld [$ff00+$8c], a
	call $2920
	ld hl, $ccd3
	ld de, $54bb
	call $350c
	dec a
	ld [$cd38], a
	call $3486
	ld a, $1
	ld [$d60d], a
	ret
; 0x1d4bb

INCBIN "baserom.gbc",$1d4bb,$1d4c0 - $1d4bb

ViridianMartScript1: ; 0x1d4c0
	ld a, [$cd38]
	and a
	ret nz
	call Delay3
	ld a, $5
	ld [$ff00+$8c], a
	call $2920
	ld bc, $4601
	call GiveItem
	ld hl, $d74e
	set 1, [hl]
	ld a, $2
	ld [$d60d], a
	ret
; 0x1d4e0

ViridianMartTexts: ; 0x1d4e0
	dw ViridianMartText1, ViridianMartText2, ViridianMartText3 ;, ViridianMartText4

INCBIN "baserom.gbc",$1d4e6,$a

ViridianMartText1: ; 0x1d4f0
	TX_FAR _ViridianMartText1
	db $50

UnnamedText_1d4f5: ; 0x1d4f5
	TX_FAR _UnnamedText_1d4f5
	db $50
; 0x1d4f5 + 5 bytes

INCBIN "baserom.gbc",$1d4fa,$6

ViridianMartText2: ; 0x1d500
	TX_FAR _ViridianMartText2
	db $50

ViridianMartText3: ; 0x1d505
	TX_FAR _ViridianMartText3
	db $50

ViridianMartObject: ; 0x1d50a (size=38)
	db $0 ; border tile

	db $2 ; warps
	db $7, $3, $1, $ff
	db $7, $4, $1, $ff

	db $0 ; signs

	db $3 ; people
	db SPRITE_MART_GUY, $5 + 4, $0 + 4, $ff, $d3, $1 ; person
	db SPRITE_BUG_CATCHER, $5 + 4, $5 + 4, $fe, $1, $2 ; person
	db SPRITE_BLACK_HAIR_BOY_1, $3 + 4, $3 + 4, $ff, $ff, $3 ; person

	; warp-to
	EVENT_DISP $4, $7, $3
	EVENT_DISP $4, $7, $4

ViridianMartBlocks: ; 0x1d530 16
	INCBIN "maps/viridianmart.blk"

School_h: ; 0x1d540 to 0x1d54c (12 bytes) (bank=7) (id=43)
	db $08 ; tileset
	db VIRIDIAN_SCHOOL_HEIGHT, VIRIDIAN_SCHOOL_WIDTH ; dimensions (y, x)
	dw SchoolBlocks, SchoolTexts, SchoolScript ; blocks, texts, scripts
	db $00 ; connections

	dw SchoolObject ; objects

SchoolScript: ; 0x1d54c
	jp $3c3c
; 0x1d54f

SchoolTexts: ; 0x1d54f
	dw SchoolText1, SchoolText2

SchoolText1: ; 0x1d553
	TX_FAR _SchoolText1
	db $50

SchoolText2: ; 0x1d558
	TX_FAR _SchoolText2
	db $50

SchoolObject: ; 0x1d55d (size=32)
	db $a ; border tile

	db $2 ; warps
	db $7, $2, $2, $ff
	db $7, $3, $2, $ff

	db $0 ; signs

	db $2 ; people
	db SPRITE_BRUNETTE_GIRL, $5 + 4, $3 + 4, $ff, $d1, $1 ; person
	db SPRITE_LASS, $1 + 4, $4 + 4, $ff, $d0, $2 ; person

	; warp-to
	EVENT_DISP $4, $7, $2
	EVENT_DISP $4, $7, $3

ViridianHouse_h: ; 0x1d57d to 0x1d589 (12 bytes) (bank=7) (id=44)
	db $08 ; tileset
	db VIRIDIAN_HOUSE_HEIGHT, VIRIDIAN_HOUSE_WIDTH ; dimensions (y, x)
	dw ViridianHouseBlocks, ViridianHouseTexts, ViridianHouseScript ; blocks, texts, scripts
	db $00 ; connections

	dw ViridianHouseObject ; objects

INCBIN "baserom.gbc",$1d589,$1d58a - $1d589

ViridianHouseScript: ; 0x1d58a
	jp $3c3c
; 0x1d58d

ViridianHouseTexts: ; 0x1d58d
	dw ViridianHouseText1, ViridianHouseText2, ViridianHouseText3, ViridianHouseText4

ViridianHouseText1: ; 0x1d595
	TX_FAR _ViridianHouseText1
	db $50

ViridianHouseText2: ; 0x1d59a
	TX_FAR _ViridianHouseText2
	db $50

ViridianHouseText3: ; 0x1d59f
	db $08 ; asm
	ld hl, UnnamedText_1d5b1
	call PrintText
	ld a, SPEAROW
	call $13d0
	call $3748
	jp TextScriptEnd

UnnamedText_1d5b1: ; 0x1d5b1
	TX_FAR _UnnamedText_1d5b1
	db $50
; 0x1d5b1 + 5 bytes

ViridianHouseText4: ; 0x1d5b6
	TX_FAR _ViridianHouseText4
	db $50

ViridianHouseObject: ; 0x1d5bb (size=44)
	db $a ; border tile

	db $2 ; warps
	db $7, $2, $3, $ff
	db $7, $3, $3, $ff

	db $0 ; signs

	db $4 ; people
	db SPRITE_BALDING_GUY, $3 + 4, $5 + 4, $ff, $ff, $1 ; person
	db SPRITE_LITTLE_GIRL, $4 + 4, $1 + 4, $fe, $1, $2 ; person
	db SPRITE_BIRD, $5 + 4, $5 + 4, $fe, $2, $3 ; person
	db SPRITE_CLIPBOARD, $0 + 4, $4 + 4, $ff, $ff, $4 ; person

	; warp-to
	EVENT_DISP $4, $7, $2
	EVENT_DISP $4, $7, $3

PewterHouse1_h: ; 0x1d5e7 to 0x1d5f3 (12 bytes) (bank=7) (id=55)
	db $08 ; tileset
	db PEWTER_HOUSE_1_HEIGHT, PEWTER_HOUSE_1_WIDTH ; dimensions (y, x)
	dw PewterHouse1Blocks, PewterHouse1Texts, PewterHouse1Script ; blocks, texts, scripts
	db $00 ; connections

	dw PewterHouse1Object ; objects

PewterHouse1Script: ; 0x1d5f3
	jp $3c3c
; 0x1d5f6

PewterHouse1Texts: ; 0x1d5f6
	dw PewterHouse1Text1, PewterHouse1Text2, PewterHouse1Text3

PewterHouse1Text1: ; 0x1d5fc
	TX_FAR _PewterHouse1Text1
	db $08 ; asm
	ld a, $3
	call $13d0
	call $3748
	jp TextScriptEnd

PewterHouse1Text2: ; 0x1d60c
	TX_FAR _PewterHouse1Text2
	db $50

PewterHouse1Text3: ; 0x1d611
	TX_FAR _PewterHouse1Text3
	db $50

PewterHouse1Object: ; 0x1d616 (size=38)
	db $a ; border tile

	db $2 ; warps
	db $7, $2, $3, $ff
	db $7, $3, $3, $ff

	db $0 ; signs

	db $3 ; people
	db SPRITE_SLOWBRO, $5 + 4, $4 + 4, $ff, $d2, $1 ; person
	db SPRITE_YOUNG_BOY, $5 + 4, $3 + 4, $ff, $d3, $2 ; person
	db SPRITE_FAT_BALD_GUY, $2 + 4, $1 + 4, $ff, $ff, $3 ; person

	; warp-to
	EVENT_DISP $4, $7, $2
	EVENT_DISP $4, $7, $3

PewterHouse2_h: ; 0x1d63c to 0x1d648 (12 bytes) (bank=7) (id=57)
	db $08 ; tileset
	db PEWTER_HOUSE_2_HEIGHT, PEWTER_HOUSE_2_WIDTH ; dimensions (y, x)
	dw PewterHouse2Blocks, PewterHouse2Texts, PewterHouse2Script ; blocks, texts, scripts
	db $00 ; connections

	dw PewterHouse2Object ; objects

PewterHouse2Script: ; 0x1d648
	jp $3c3c
; 0x1d64b

PewterHouse2Texts: ; 0x1d64b
	dw PewterHouse2Text1, PewterHouse2Text2

PewterHouse2Text1: ; 0x1d64f
	TX_FAR _PewterHouse2Text1
	db $50

PewterHouse2Text2: ; 0x1d654
	TX_FAR _PewterHouse2Text2
	db $50

PewterHouse2Object: ; 0x1d659 (size=32)
	db $a ; border tile

	db $2 ; warps
	db $7, $2, $5, $ff
	db $7, $3, $5, $ff

	db $0 ; signs

	db $2 ; people
	db SPRITE_GAMBLER, $3 + 4, $2 + 4, $ff, $d3, $1 ; person
	db SPRITE_BUG_CATCHER, $5 + 4, $4 + 4, $ff, $ff, $2 ; person

	; warp-to
	EVENT_DISP $4, $7, $2
	EVENT_DISP $4, $7, $3

CeruleanHouseTrashed_h: ; 0x1d679 to 0x1d685 (12 bytes) (bank=7) (id=62)
	db $08 ; tileset
	db TRASHED_HOUSE_HEIGHT, TRASHED_HOUSE_WIDTH ; dimensions (y, x)
	dw CeruleanHouseTrashedBlocks, CeruleanHouseTrashedTexts, CeruleanHouseTrashedScript ; blocks, texts, scripts
	db $00 ; connections

	dw CeruleanHouseTrashedObject ; objects

CeruleanHouseTrashedScript: ; 0x1d685
	call $3c3c
	ret
; 0x1d689

CeruleanHouseTrashedTexts: ; 0x1d689
	dw CeruleanHouseTrashedText1, CeruleanHouseTrashedText2, CeruleanHouseTrashedText3

CeruleanHouseTrashedText1: ; 0x1d68f
	db $08 ; asm
	ld b, $e4
	ld a, $1c
	call Predef
	and b
	jr z, .asm_f8734 ; 0x1d698
	ld hl, UnnamedText_1d6b0
	call PrintText
	jr .asm_8dfe9 ; 0x1d6a0
.asm_f8734 ; 0x1d6a2
	ld hl, UnnamedText_1d6ab
	call PrintText
.asm_8dfe9 ; 0x1d6a8
	jp TextScriptEnd

UnnamedText_1d6ab: ; 0x1d6ab
	TX_FAR _UnnamedText_1d6ab
	db $50
; 0x1d6ab + 5 bytes

UnnamedText_1d6b0: ; 0x1d6b0
	TX_FAR _UnnamedText_1d6b0
	db $50
; 0x1d6b0 + 5 bytes

CeruleanHouseTrashedText2: ; 0x1d6b5
	TX_FAR _CeruleanHouseTrashedText2
	db $50

CeruleanHouseTrashedText3: ; 0x1d6ba
	TX_FAR _CeruleanHouseTrashedText3
	db $50

CeruleanHouseTrashedObject: ; 0x1d6bf (size=43)
	db $a ; border tile

	db $3 ; warps
	db $7, $2, $0, $ff
	db $7, $3, $0, $ff
	db $0, $3, $7, $ff

	db $1 ; signs
	db $0, $3, $3 ; CeruleanHouseTrashedText3

	db $2 ; people
	db SPRITE_FISHER, $1 + 4, $2 + 4, $ff, $d0, $1 ; person
	db SPRITE_GIRL, $6 + 4, $5 + 4, $fe, $2, $2 ; person

	; warp-to
	EVENT_DISP $4, $7, $2
	EVENT_DISP $4, $7, $3
	EVENT_DISP $4, $0, $3

CeruleanHouse2_h: ; 0x1d6ea to 0x1d6f6 (12 bytes) (bank=7) (id=63)
	db $08 ; tileset
	db CERULEAN_HOUSE_HEIGHT, CERULEAN_HOUSE_WIDTH ; dimensions (y, x)
	dw CeruleanHouse2Blocks, CeruleanHouse2Texts, CeruleanHouse2Script ; blocks, texts, scripts
	db $00 ; connections

	dw CeruleanHouse2Object ; objects

CeruleanHouse2Script: ; 0x1d6f6
	jp $3c3c
; 0x1d6f9

CeruleanHouse2Texts: ; 0x1d6f9
	dw CeruleanHouse2Text1, CeruleanHouse2Text2

CeruleanHouse2Text1: ; 0x1d6fd
	TX_FAR _CeruleanHouse2Text1
	db $50

CeruleanHouse2Text2: ; 0x1d702
	db $08 ; asm
	ld a, $6
	ld [W_WHICHTRADE], a
	ld a, $54
	call Predef
	jp TextScriptEnd

CeruleanHouse2Object: ; 0x1d710 (size=32)
	db $a ; border tile

	db $2 ; warps
	db $7, $2, $1, $ff
	db $7, $3, $1, $ff

	db $0 ; signs

	db $2 ; people
	db SPRITE_OLD_MEDIUM_WOMAN, $4 + 4, $5 + 4, $ff, $d2, $1 ; person
	db SPRITE_GAMBLER, $2 + 4, $1 + 4, $ff, $ff, $2 ; person

	; warp-to
	EVENT_DISP $4, $7, $2
	EVENT_DISP $4, $7, $3

BikeShop_h: ; 0x1d730 to 0x1d73c (12 bytes) (bank=7) (id=66)
	db $15 ; tileset
	db BIKE_SHOP_HEIGHT, BIKE_SHOP_WIDTH ; dimensions (y, x)
	dw BikeShopBlocks, BikeShopTexts, BikeShopScript ; blocks, texts, scripts
	db $00 ; connections

	dw BikeShopObject ; objects

BikeShopScript: ; 0x1d73c
	jp $3c3c
; 0x1d73f

BikeShopTexts: ; 0x1d73f
	dw BikeShopText1, BikeShopText2, BikeShopText3

BikeShopText1: ; 0x1d745
	db $08 ; asm
	ld a, [$d75f]
	bit 0, a
	jr z, .asm_260d4 ; 0x1d74b
	ld hl, UnnamedText_1d82f
	call PrintText
	jp $57f5
.asm_260d4 ; 0x1d756
	ld b, BIKE_VOUCHER
	call $3493
	jr z, .asm_41190 ; 0x1d75b
	ld hl, UnnamedText_1d81f
	call PrintText
	ld bc, (BICYCLE << 8) | 1
	call GiveItem
	jr nc, .asm_d0d90 ; 0x1d769
	ld a, $2d
	ldh [$db], a
	ld b, $5 ; BANK(MyFunction)
	ld hl, $7f37 ; MyFunction
	call Bankswitch
	ld hl, $d75f
	set 0, [hl]
	ld hl, UnnamedText_1d824
	call PrintText
	jr .asm_99ef2 ; 0x1d782
.asm_d0d90 ; 0x1d784
	ld hl, UnnamedText_1d834
	call PrintText
	jr .asm_99ef2 ; 0x1d78a
.asm_41190 ; 0x1d78c
	ld hl, UnnamedText_1d810
	call PrintText
	xor a
	ld [$cc26], a
	ld [$cc2a], a
	ld a, $3
	ld [$cc29], a
	ld a, $1
	ld [$cc28], a
	ld a, $2
	ld [$cc24], a
	ld a, $1
	ld [$cc25], a
	ld hl, $d730
	set 6, [hl]
	ld hl, $c3a0
	ld b, $4
	ld c, $f
	call $1922
	call $2429
	ld hl, $c3ca
	ld de, $57f8
	call $1955
	ld hl, $c3e4
	ld de, $5807
	call $1955
	ld hl, UnnamedText_1d815
	call PrintText
	call $3abe
	bit 1, a
	jr nz, .asm_b7579 ; 0x1d7dc
	ld hl, $d730
	res 6, [hl]
	ld a, [$cc26]
	and a
	jr nz, .asm_b7579 ; 0x1d7e7
	ld hl, UnnamedText_1d81a
	call PrintText
.asm_b7579 ; 0x1d7ef
	ld hl, UnnamedText_1d82a
	call PrintText
.asm_99ef2 ; 0x1d7f5
	jp TextScriptEnd

INCBIN "baserom.gbc",$1d7f8,$1d810 - $1d7f8

UnnamedText_1d810: ; 0x1d810
	TX_FAR _UnnamedText_1d810
	db $50
; 0x1d810 + 5 bytes

UnnamedText_1d815: ; 0x1d815
	TX_FAR _UnnamedText_1d815
	db $50
; 0x1d815 + 5 bytes

UnnamedText_1d81a: ; 0x1d81a
	TX_FAR _UnnamedText_1d81a
	db $50
; 0x1d81a + 5 bytes

UnnamedText_1d81f: ; 0x1d81f
	TX_FAR _UnnamedText_1d81f
	db $50
; 0x1d81f + 5 bytes

UnnamedText_1d824: ; 0x1d824
	TX_FAR _UnnamedText_1d824 ; 0x98eb2
	db $11, $50

UnnamedText_1d82a: ; 0x1d82a
	TX_FAR _UnnamedText_1d82a
	db $50
; 0x1d82a + 5 bytes

UnnamedText_1d82f: ; 0x1d82f
	TX_FAR _UnnamedText_1d82f
	db $50
; 0x1d82f + 5 bytes

UnnamedText_1d834: ; 0x1d834
	TX_FAR _UnnamedText_1d834
	db $50
; 0x1d834 + 5 bytes

BikeShopText2: ; 0x1d839
	db $08 ; asm
	ld hl, UnnamedText_1d843
	call PrintText
	jp TextScriptEnd

UnnamedText_1d843: ; 0x1d843
	TX_FAR _UnnamedText_1d843
	db $50
; 0x1d843 + 5 bytes

BikeShopText3: ; 0x1d848
	db $08 ; asm
	ld a, [$d75f]
	bit 0, a
	ld hl, UnnamedText_1d861
	jr nz, .asm_34d2d ; 0x1d851
	ld hl, UnnamedText_1d85c
.asm_34d2d ; 0x1d856
	call PrintText
	jp TextScriptEnd

UnnamedText_1d85c: ; 0x1d85c
	TX_FAR _UnnamedText_1d85c
	db $50
; 0x1d85c + 5 bytes

UnnamedText_1d861: ; 0x1d861
	TX_FAR _UnnamedText_1d861
	db $50
; 0x1d861 + 5 bytes

BikeShopObject: ; 0x1d866 (size=38)
	db $e ; border tile

	db $2 ; warps
	db $7, $2, $4, $ff
	db $7, $3, $4, $ff

	db $0 ; signs

	db $3 ; people
	db SPRITE_BIKE_SHOP_GUY, $2 + 4, $6 + 4, $ff, $ff, $1 ; person
	db SPRITE_MOM_GEISHA, $6 + 4, $5 + 4, $fe, $1, $2 ; person
	db SPRITE_BUG_CATCHER, $3 + 4, $1 + 4, $ff, $d1, $3 ; person

	; warp-to
	EVENT_DISP $4, $7, $2
	EVENT_DISP $4, $7, $3

BikeShopBlocks: ; 0x1d88c 16
	INCBIN "maps/bikeshop.blk"

LavenderHouse1_h: ; 0x1d89c to 0x1d8a8 (12 bytes) (bank=7) (id=149)
	db $08 ; tileset
	db LAVENDER_HOUSE_1_HEIGHT, LAVENDER_HOUSE_1_WIDTH ; dimensions (y, x)
	dw LavenderHouse1Blocks, LavenderHouse1Texts, LavenderHouse1Script ; blocks, texts, scripts
	db $00 ; connections

	dw LavenderHouse1Object ; objects

LavenderHouse1Script: ; 0x1d8a8
	call $3c3c
	ret
; 0x1d8ac

LavenderHouse1Texts: ; 0x1d8ac
	dw LavenderHouse1Text1, LavenderHouse1Text2, LavenderHouse1Text3, LavenderHouse1Text4, LavenderHouse1Text5, LavenderHouse1Text6

LavenderHouse1Text1: ; 0x1d8b8
	db $08 ; asm
	ld a, [$d7e0]
	bit 7, a
	jr nz, .asm_72e5d ; 0x1d8be
	ld hl, UnnamedText_1d8d1
	call PrintText
	jr .asm_6957f ; 0x1d8c6
.asm_72e5d ; 0x1d8c8
	ld hl, UnnamedText_1d8d6
	call PrintText
.asm_6957f ; 0x1d8ce
	jp TextScriptEnd

UnnamedText_1d8d1: ; 0x1d8d1
	TX_FAR _UnnamedText_1d8d1
	db $50
; 0x1d8d1 + 5 bytes

UnnamedText_1d8d6: ; 0x1d8d6
	TX_FAR _UnnamedText_1d8d6
	db $50
; 0x1d8d6 + 5 bytes

LavenderHouse1Text2: ; 0x1d8db
	db $08 ; asm
	ld a, [$d7e0]
	bit 7, a
	jr nz, .asm_06470 ; 0x1d8e1
	ld hl, UnnamedText_1d8f4
	call PrintText
	jr .asm_3d208 ; 0x1d8e9
.asm_06470 ; 0x1d8eb
	ld hl, UnnamedText_1d8f9
	call PrintText
.asm_3d208 ; 0x1d8f1
	jp TextScriptEnd

UnnamedText_1d8f4: ; 0x1d8f4
	TX_FAR _UnnamedText_1d8f4
	db $50
; 0x1d8f4 + 5 bytes

UnnamedText_1d8f9: ; 0x1d8f9
	TX_FAR _UnnamedText_1d8f9
	db $50
; 0x1d8f9 + 5 bytes

LavenderHouse1Text3: ; 0x1d8fe
	TX_FAR _LavenderHouse1Text3
	db $8
	ld a, $2f
	call $13d0
	jp TextScriptEnd

LavenderHouse1Text4: ; 0x1d90b
	TX_FAR _LavenderHouse1Text4
	db $8
	ld a, $a7
	call $13d0
	jp TextScriptEnd
; 0x1d918

LavenderHouse1Text5: ; 0x1d918
	db $08 ; asm
	ld a, [$d76c]
	bit 0, a
	jr nz, .asm_15ac2 ; 0x1d91e
	ld hl, UnnamedText_1d94c
	call PrintText
	ld bc, (POKE_FLUTE << 8) | 1
	call GiveItem
	jr nc, .asm_5ce36 ; 0x1d92c
	ld hl, ReceivedFluteText
	call PrintText
	ld hl, $d76c
	set 0, [hl]
	jr .asm_da749 ; 0x1d939
.asm_5ce36 ; 0x1d93b
	ld hl, FluteNoRoomText
	call PrintText
	jr .asm_da749 ; 0x1d941
.asm_15ac2 ; 0x1d943
	ld hl, MrFujiAfterFluteText
	call PrintText
.asm_da749 ; 0x1d949
	jp TextScriptEnd

UnnamedText_1d94c: ; 0x1d94c
	TX_FAR _UnnamedText_1d94c
	db $50
; 0x1d94c + 5 bytes

ReceivedFluteText: ; 0x1d951
	TX_FAR _ReceivedFluteText ; 0x99ffb
	db $11
	TX_FAR _FluteExplanationText ; 0x9a011
	db $50
; 0x1d95b

FluteNoRoomText: ; 0x1d95b
	TX_FAR _FluteNoRoomText
	db $50
; 0x1d95b + 5 bytes

MrFujiAfterFluteText: ; 0x1d960
	TX_FAR _MrFujiAfterFluteText
	db $50
; 0x1d960 + 5 bytes

LavenderHouse1Text6: ; 0x1d965
	TX_FAR _LavenderHouse1Text6
	db $50

LavenderHouse1Object: ; 0x1d96a (size=56)
	db $a ; border tile

	db $2 ; warps
	db $7, $2, $2, $ff
	db $7, $3, $2, $ff

	db $0 ; signs

	db $6 ; people
	db SPRITE_BLACK_HAIR_BOY_2, $5 + 4, $3 + 4, $ff, $ff, $1 ; person
	db SPRITE_LITTLE_GIRL, $3 + 4, $6 + 4, $ff, $d0, $2 ; person
	db SPRITE_SLOWBRO, $4 + 4, $6 + 4, $ff, $d1, $3 ; person
	db SPRITE_SLOWBRO, $3 + 4, $1 + 4, $ff, $ff, $4 ; person
	db SPRITE_MR_FUJI, $1 + 4, $3 + 4, $ff, $ff, $5 ; person
	db SPRITE_BOOK_MAP_DEX, $3 + 4, $3 + 4, $ff, $ff, $6 ; person

	; warp-to
	EVENT_DISP $4, $7, $2
	EVENT_DISP $4, $7, $3

LavenderHouse2_h: ; 0x1d9a2 to 0x1d9ae (12 bytes) (bank=7) (id=151)
	db $08 ; tileset
	db LAVENDER_HOUSE_2_HEIGHT, LAVENDER_HOUSE_2_WIDTH ; dimensions (y, x)
	dw LavenderHouse2Blocks, LavenderHouse2Texts, LavenderHouse2Script ; blocks, texts, scripts
	db $00 ; connections

	dw LavenderHouse2Object ; objects

LavenderHouse2Script: ; 0x1d9ae
	call $3c3c
	ret
; 0x1d9b2

LavenderHouse2Texts: ; 0x1d9b2
	dw LavenderHouse2Text1, LavenderHouse2Text2

LavenderHouse2Text1: ; 0x1d9b6
	TX_FAR _LavenderHouse2Text1
	db $8
	ld a, $11
	call $13d0
	jp TextScriptEnd
; 0x1d9c3

LavenderHouse2Text2: ; 0x1d9c3
	db $08 ; asm
	ld a, [$d7e0]
	bit 7, a
	jr nz, .asm_65711 ; 0x1d9c9
	ld hl, UnnamedText_1d9dc
	call PrintText
	jr .asm_64be1 ; 0x1d9d1
.asm_65711 ; 0x1d9d3
	ld hl, UnnamedText_1d9e1
	call PrintText
.asm_64be1 ; 0x1d9d9
	jp TextScriptEnd

UnnamedText_1d9dc: ; 0x1d9dc
	TX_FAR _UnnamedText_1d9dc
	db $50
; 0x1d9dc + 5 bytes

UnnamedText_1d9e1: ; 0x1d9e1
	TX_FAR _UnnamedText_1d9e1
	db $50
; 0x1d9e1 + 5 bytes

LavenderHouse2Object: ; 0x1d9e6 (size=32)
	db $a ; border tile

	db $2 ; warps
	db $7, $2, $4, $ff
	db $7, $3, $4, $ff

	db $0 ; signs

	db $2 ; people
	db SPRITE_SLOWBRO, $5 + 4, $3 + 4, $ff, $d1, $1 ; person
	db SPRITE_BRUNETTE_GIRL, $4 + 4, $2 + 4, $ff, $d3, $2 ; person

	; warp-to
	EVENT_DISP $4, $7, $2
	EVENT_DISP $4, $7, $3

NameRater_h: ; 0x1da06 to 0x1da12 (12 bytes) (bank=7) (id=229)
	db $08 ; tileset
	db NAME_RATERS_HOUSE_HEIGHT, NAME_RATERS_HOUSE_WIDTH ; dimensions (y, x)
	dw NameRaterBlocks, $5a54, NameRaterScript ; blocks, texts, scripts
	db $00 ; connections

	dw NameRaterObject ; objects

NameRaterScript: ; 0x1da12
	jp $3c3c
; 0x1da15

INCBIN "baserom.gbc",$1da15,$41

NameRaterText1: ; 0x1da56
	db $8
	call $36f4
	ld hl, UnnamedText_1dab3
	call $5a15
	jr nz, .asm_1daae ; 0x1da60 $4c
	ld hl, UnnamedText_1dab8
	call PrintText
	xor a
	ld [$d07d], a
	ld [$cfcb], a
	ld [$cc35], a
	call $13fc
	push af
	call $3dd4
	call $3dbe
	call $20ba
	pop af
	jr c, .asm_1daae ; 0x1da80 $2c
	call $15b4
	call $5a20
	ld hl, UnnamedText_1dad1
	jr c, .asm_1daa8 ; 0x1da8b $1b
	ld hl, UnnamedText_1dabd
	call $5a15
	jr nz, .asm_1daae ; 0x1da93 $19
	ld hl, UnnamedText_1dac2
	call PrintText
	ld b, $1
	ld hl, $655c
	call Bankswitch
	jr c, .asm_1daae ; 0x1daa3 $9
	ld hl, UnnamedText_1dac7
.asm_1daa8
	call PrintText
	jp TextScriptEnd
.asm_1daae
	ld hl, UnnamedText_1dacc
	jr .asm_1daa8 ; 0x1dab1 $f5
; 0x1dab3

UnnamedText_1dab3: ; 0x1dab3
	TX_FAR _UnnamedText_1dab3
	db $50
; 0x1dab3 + 5 bytes

UnnamedText_1dab8: ; 0x1dab8
	TX_FAR _UnnamedText_1dab8
	db $50
; 0x1dab8 + 5 bytes

UnnamedText_1dabd: ; 0x1dabd
	TX_FAR _UnnamedText_1dabd
	db $50
; 0x1dabd + 5 bytes

UnnamedText_1dac2: ; 0x1dac2
	TX_FAR _UnnamedText_1dac2
	db $50
; 0x1dac2 + 5 bytes

UnnamedText_1dac7: ; 0x1dac7
	TX_FAR _UnnamedText_1dac7
	db $50
; 0x1dac7 + 5 bytes

UnnamedText_1dacc: ; 0x1dacc
	TX_FAR _UnnamedText_1dacc
	db $50
; 0x1dacc + 5 bytes

UnnamedText_1dad1: ; 0x1dad1
	TX_FAR _UnnamedText_1dad1
	db $50
; 0x1dad1 + 5 bytes

NameRaterObject: ; 0x1dad6 (size=26)
	db $a ; border tile

	db $2 ; warps
	db $7, $2, $5, $ff
	db $7, $3, $5, $ff

	db $0 ; signs

	db $1 ; people
	db SPRITE_MR_MASTERBALL, $3 + 4, $5 + 4, $ff, $d2, $1 ; person

	; warp-to
	EVENT_DISP $4, $7, $2
	EVENT_DISP $4, $7, $3

VermilionHouse1_h: ; 0x1daf0 to 0x1dafc (12 bytes) (bank=7) (id=93)
	db $08 ; tileset
	db VERMILION_HOUSE_1_HEIGHT, VERMILION_HOUSE_1_WIDTH ; dimensions (y, x)
	dw VermilionHouse1Blocks, VermilionHouse1Texts, VermilionHouse1Script ; blocks, texts, scripts
	db $00 ; connections

	dw VermilionHouse1Object ; objects

VermilionHouse1Script: ; 0x1dafc
	call $3c3c
	ret
; 0x1db00

VermilionHouse1Texts: ; 0x1db00
	dw VermilionHouse1Text1, VermilionHouse1Text2, VermilionHouse1Text3

VermilionHouse1Text1: ; 0x1db06
	TX_FAR _VermilionHouse1Text1
	db $50

VermilionHouse1Text2: ; 0x1db0b
	TX_FAR _VermilionHouse1Text2
	db $08 ; asm
	ld a, $24
	call $13d0
	call $3748
	jp TextScriptEnd

VermilionHouse1Text3: ; 0x1db1b
	TX_FAR _VermilionHouse1Text3
	db $50

INCBIN "baserom.gbc", $1db1b + 5, $1db20 - ($1db1b + 5)

VermilionHouse1Object: ; 0x1db20 (size=38)
	db $a ; border tile

	db $2 ; warps
	db $7, $2, $4, $ff
	db $7, $3, $4, $ff

	db $0 ; signs

	db $3 ; people
	db SPRITE_BUG_CATCHER, $3 + 4, $5 + 4, $ff, $d2, $1 ; person
	db SPRITE_BIRD, $5 + 4, $3 + 4, $fe, $2, $2 ; person
	db SPRITE_PAPER_SHEET, $3 + 4, $4 + 4, $ff, $ff, $3 ; person

	; warp-to
	EVENT_DISP $4, $7, $2
	EVENT_DISP $4, $7, $3

VermilionDock_h: ; 0x1db46 to 0x1db52 (12 bytes) (bank=7) (id=94)
	db $0e ; tileset
	db VERMILION_DOCK_HEIGHT, VERMILION_DOCK_WIDTH ; dimensions (y, x)
	dw VermilionDockBlocks, VermilionDockTexts, VermilionDockScript ; blocks, texts, scripts
	db $00 ; connections

	dw VermilionDockObject ; objects

VermilionDockScript: ; 0x1db52
	call $3c3c
	ld hl, $d803
	bit 4, [hl]
	jr nz, .asm_1db8d ; 0x1db5a $31
	bit 0, [hl]
	ret z
	ld a, [$d42f]
	cp $1
	ret nz
	bit 2, [hl]
	jp z, $5b9b
	set 4, [hl]
	call Delay3
	ld hl, $d730
	set 7, [hl]
	ld hl, $ccd3
	ld a, $40
	ld [hli], a
	ld [hli], a
	ld [hl], a
	ld a, $3
	ld [$cd38], a
	xor a
	ld [$c206], a
	ld [$cd3b], a
	dec a
	ld [$cd6b], a
	ret
.asm_1db8d
	bit 5, [hl]
	ret nz
	ld a, [$cd38]
	and a
	ret nz
	ld [$cd6b], a
	set 5, [hl]
	ret
; 0x1db9b

INCBIN "baserom.gbc",$1db9b,$1dcbf - $1db9b

VermilionDockTexts: ; 0x1dcbf
INCBIN "baserom.gbc",$1dcbf,$1dcc1 - $1dcbf

UnnamedText_1dcc1: ; 0x1dcc1
	TX_FAR _UnnamedText_1dcc1
	db $50
; 0x1dcc1 + 5 bytes

VermilionDockObject: ; 0x1dcc6 (size=20)
	db $f ; border tile

	db $2 ; warps
	db $0, $e, $5, $ff
	db $2, $e, $1, SS_ANNE_1

	db $0 ; signs

	db $0 ; people

	; warp-to
	EVENT_DISP $e, $0, $e
	EVENT_DISP $e, $2, $e ; SS_ANNE_1

VermilionDockBlocks: ; 0x1dcda 84
	INCBIN "maps/vermiliondock.blk"

CeladonMansion5_h: ; 0x1dd2e to 0x1dd3a (12 bytes) (bank=7) (id=132)
	db $08 ; tileset
	db CELADON_MANSION_5_HEIGHT, CELADON_MANSION_5_WIDTH ; dimensions (y, x)
	dw CeladonMansion5Blocks, CeladonMansion5Texts, CeladonMansion5Script ; blocks, texts, scripts
	db $00 ; connections

	dw CeladonMansion5Object ; objects

CeladonMansion5Script: ; 0x1dd3a
	jp $3c3c
; 0x1dd3d

CeladonMansion5Texts: ; 0x1dd3d
	dw CeladonMansion5Text1, CeladonMansion5Text2

CeladonMansion5Text1: ; 0x1dd41
	TX_FAR _CeladonMansion5Text1
	db $50

CeladonMansion5Text2: ; 0x1dd46
	db $08 ; asm
	ld bc,(EEVEE << 8) | 25
	call GivePokemon
	jr nc, .asm_24365 ; 0x1dd4d
	ld a, $45
	ld [$cc4d], a
	ld a, $11
	call Predef
.asm_24365 ; 0x1dd59
	jp TextScriptEnd

CeladonMansion5Object: ; 0x1dd5c (size=32)
	db $a ; border tile

	db $2 ; warps
	db $7, $2, $2, CELADON_MANSION_4
	db $7, $3, $2, CELADON_MANSION_4

	db $0 ; signs

	db $2 ; people
	db SPRITE_HIKER, $2 + 4, $2 + 4, $ff, $d0, $1 ; person
	db SPRITE_BALL, $3 + 4, $4 + 4, $ff, $ff, $2 ; person

	; warp-to
	EVENT_DISP $4, $7, $2 ; CELADON_MANSION_4
	EVENT_DISP $4, $7, $3 ; CELADON_MANSION_4

FuchsiaMart_h: ; 0x1dd7c to 0x1dd88 (12 bytes) (bank=7) (id=152)
	db $02 ; tileset
	db FUCHSIA_MART_HEIGHT, FUCHSIA_MART_WIDTH ; dimensions (y, x)
	dw FuchsiaMartBlocks, FuchsiaMartTexts, FuchsiaMartScript ; blocks, texts, scripts
	db $00 ; connections

	dw FuchsiaMartObject ; objects

FuchsiaMartScript: ; 0x1dd88
	jp $3c3c
; 0x1dd8b

FuchsiaMartTexts: ; 0x1dd8b
	dw FuchsiaMartText1, FuchsiaMartText2, FuchsiaMartText3

FuchsiaMartText2: ; 0x1dd91
	TX_FAR _FuchsiaMartText2
	db $50

FuchsiaMartText3: ; 0x1dd96
	TX_FAR _FuchsiaMartText3
	db $50

FuchsiaMartObject: ; 0x1dd9b (size=38)
	db $0 ; border tile

	db $2 ; warps
	db $7, $3, $0, $ff
	db $7, $4, $0, $ff

	db $0 ; signs

	db $3 ; people
	db SPRITE_MART_GUY, $5 + 4, $0 + 4, $ff, $d3, $1 ; person
	db SPRITE_FAT_BALD_GUY, $2 + 4, $4 + 4, $ff, $ff, $2 ; person
	db SPRITE_LASS, $5 + 4, $6 + 4, $fe, $1, $3 ; person

	; warp-to
	EVENT_DISP $4, $7, $3
	EVENT_DISP $4, $7, $4

FuchsiaMartBlocks: ; 0x1ddc1 16
	INCBIN "maps/fuchsiamart.blk"

SaffronHouse1_h: ; 0x1ddd1 to 0x1dddd (12 bytes) (bank=7) (id=179)
	db $08 ; tileset
	db SAFFRON_HOUSE_1_HEIGHT, SAFFRON_HOUSE_1_WIDTH ; dimensions (y, x)
	dw SaffronHouse1Blocks, SaffronHouse1Texts, SaffronHouse1Script ; blocks, texts, scripts
	db $00 ; connections

	dw SaffronHouse1Object ; objects

SaffronHouse1Script: ; 0x1dddd
	jp $3c3c
; 0x1dde0

SaffronHouse1Texts: ; 0x1dde0
	dw SaffronHouse1Text1, SaffronHouse1Text2, SaffronHouse1Text3, SaffronHouse1Text4

SaffronHouse1Text1: ; 0x1dde8
	TX_FAR _SaffronHouse1Text1
	db $50

SaffronHouse1Text2: ; 0x1dded
	TX_FAR _SaffronHouse1Text2
	db $8
	ld a, $24
	call $13d0
	jp TextScriptEnd
; 0x1ddfa

SaffronHouse1Text3: ; 0x1ddfa
	TX_FAR _SaffronHouse1Text3
	db $50

SaffronHouse1Text4: ; 0x1ddff
	TX_FAR _SaffronHouse1Text4
	db $50

SaffronHouse1Object: ; 0x1de04 (size=44)
	db $a ; border tile

	db $2 ; warps
	db $7, $2, $3, $ff
	db $7, $3, $3, $ff

	db $0 ; signs

	db $4 ; people
	db SPRITE_BRUNETTE_GIRL, $3 + 4, $2 + 4, $ff, $d3, $1 ; person
	db SPRITE_BIRD, $4 + 4, $0 + 4, $fe, $1, $2 ; person
	db SPRITE_BUG_CATCHER, $1 + 4, $4 + 4, $ff, $d0, $3 ; person
	db SPRITE_PAPER_SHEET, $3 + 4, $3 + 4, $ff, $ff, $4 ; person

	; warp-to
	EVENT_DISP $4, $7, $2
	EVENT_DISP $4, $7, $3

SaffronHouse2_h: ; 0x1de30 to 0x1de3c (12 bytes) (bank=7) (id=183)
	db $08 ; tileset
	db SAFFRON_HOUSE_2_HEIGHT, SAFFRON_HOUSE_2_WIDTH ; dimensions (y, x)
	dw SaffronHouse2Blocks, SaffronHouse2Texts, SaffronHouse2Script ; blocks, texts, scripts
	db $00 ; connections

	dw SaffronHouse2Object ; objects

SaffronHouse2Script: ; 0x1de3c
	jp $3c3c
; 0x1de3f

SaffronHouse2Texts: ; 0x1de3f
	dw SaffronHouse2Text1

SaffronHouse2Text1: ; 0x1de41
	db $08 ; asm
	ld a, [$d7bd]
	bit 0, a
	jr nz, .asm_9e72b ; 0x1de47
	ld hl, TM29PreReceiveText
	call PrintText
	ld bc,(TM_29 << 8) | 1
	call GiveItem
	jr nc, .asm_4b1da ; 0x1de55
	ld hl, ReceivedTM29Text
	call PrintText
	ld hl, $d7bd
	set 0, [hl]
	jr .asm_fe4e1 ; 0x1de62
.asm_4b1da ; 0x1de64
	ld hl, TM29NoRoomText
	call PrintText
	jr .asm_fe4e1 ; 0x1de6a
.asm_9e72b ; 0x1de6c
	ld hl, TM29ExplanationText
	call PrintText
.asm_fe4e1 ; 0x1de72
	jp TextScriptEnd

TM29PreReceiveText: ; 0x1de75
	TX_FAR _TM29PreReceiveText
	db $50
; 0x1de75 + 5 bytes

ReceivedTM29Text: ; 0x1de7a
	TX_FAR _ReceivedTM29Text ; 0xa252a
	db $0B, $50
; 0x1de80

TM29ExplanationText: ; 0x1de80
	TX_FAR _TM29ExplanationText
	db $50
; 0x1de80 + 5 bytes

TM29NoRoomText: ; 0x1de85
	TX_FAR _TM29NoRoomText
	db $50
; 0x1de85 + 5 bytes

SaffronHouse2Object: ; 0x1de8a (size=26)
	db $a ; border tile

	db $2 ; warps
	db $7, $2, $7, $ff
	db $7, $3, $7, $ff

	db $0 ; signs

	db $1 ; people
	db SPRITE_FISHER, $3 + 4, $5 + 4, $ff, $d2, $1 ; person

	; warp-to
	EVENT_DISP $4, $7, $2
	EVENT_DISP $4, $7, $3

DiglettsCaveRoute2_h: ; 0x1dea4 to 0x1deb0 (12 bytes) (bank=7) (id=46)
	db $11 ; tileset
	db DIGLETTS_CAVE_EXIT_HEIGHT, DIGLETTS_CAVE_EXIT_WIDTH ; dimensions (y, x)
	dw DiglettsCaveRoute2Blocks, DiglettsCaveRoute2Texts, DiglettsCaveRoute2Script ; blocks, texts, scripts
	db $00 ; connections

	dw DiglettsCaveRoute2Object ; objects

DiglettsCaveRoute2Script: ; 0x1deb0
	ld a, $d
	ld [$d365], a
	jp $3c3c
; 0x1deb8

DiglettsCaveRoute2Texts: ; 0x1deb8
	dw DiglettsCaveRoute2Text1

DiglettsCaveRoute2Text1: ; 0x1deba
	TX_FAR _DiglettsCaveRoute2Text1
	db $50

DiglettsCaveRoute2Object: ; 0x1debf (size=34)
	db $7d ; border tile

	db $3 ; warps
	db $7, $2, $0, $ff
	db $7, $3, $0, $ff
	db $4, $4, $0, DIGLETTS_CAVE

	db $0 ; signs

	db $1 ; people
	db SPRITE_FISHER, $3 + 4, $3 + 4, $ff, $ff, $1 ; person

	; warp-to
	EVENT_DISP $4, $7, $2
	EVENT_DISP $4, $7, $3
	EVENT_DISP $4, $4, $4 ; DIGLETTS_CAVE

Route2House_h: ; 0x1dee1 to 0x1deed (12 bytes) (bank=7) (id=48)
	db $08 ; tileset
	db ROUTE_2_HOUSE_HEIGHT, ROUTE_2_HOUSE_WIDTH ; dimensions (y, x)
	dw Route2HouseBlocks, Route2HouseTexts, Route2HouseScript ; blocks, texts, scripts
	db $00 ; connections

	dw Route2HouseObject ; objects

Route2HouseScript: ; 0x1deed
	jp $3c3c
; 0x1def0

Route2HouseTexts: ; 0x1def0
	dw Route2HouseText1, Route2HouseText2

Route2HouseText1: ; 0x1def4
	TX_FAR _Route2HouseText1
	db $50

Route2HouseText2: ; 0x1def9
	db $08 ; asm
	ld a, $1
	ld [W_WHICHTRADE], a
	ld a, $54
	call Predef
	jp TextScriptEnd

Route2HouseObject: ; 0x1df07 (size=32)
	db $a ; border tile

	db $2 ; warps
	db $7, $2, $2, $ff
	db $7, $3, $2, $ff

	db $0 ; signs

	db $2 ; people
	db SPRITE_OAK_AIDE, $4 + 4, $2 + 4, $ff, $d3, $1 ; person
	db SPRITE_GAMEBOY_KID_COPY, $1 + 4, $4 + 4, $ff, $d0, $2 ; person

	; warp-to
	EVENT_DISP $4, $7, $2
	EVENT_DISP $4, $7, $3

Route5Gate_h: ; 0x1df27 to 0x1df33 (12 bytes) (bank=7) (id=70)
	db $0c ; tileset
	db ROUTE_5_GATE_HEIGHT, ROUTE_5_GATE_WIDTH ; dimensions (y, x)
	dw Route5GateBlocks, Route5GateTexts, Route5GateScript ; blocks, texts, scripts
	db $00 ; connections

	dw Route5GateObject ; objects

Route5GateScript: ; 0x1df33
	call $3c3c
	ld a, [$d662]
	ld hl, Route5GateScripts
	jp $3d97
; 0x1df3f

Route5GateScripts: ; 0x1df3f
	dw Route5GateScript0

INCBIN "baserom.gbc",$1df41,$f

Route5GateScript0: ; 0x1df50
	ld a, [$d728]
	bit 6, a
	ret nz
	ld hl, $5f8f
	call $34bf
	ret nc
	ld a, $2
	ld [$d528], a
	xor a
	ld [$ff00+$b4], a
	ld b, $16
	ld hl, $659f
	call Bankswitch
	ld a, [$ff00+$db]
	and a
	jr nz, .asm_1df82 ; 0x1df70 $10
	ld a, $2
	ld [$ff00+$8c], a
	call $2920
	call $5f43
	ld a, $1
	ld [$d662], a
	ret
.asm_1df82
	ld a, $3
	ld [$ff00+$8c], a
	call $2920
	ld hl, $d728
	set 6, [hl]
	ret
; 0x1df8f

INCBIN "baserom.gbc",$1df8f,$15

Route5GateTexts: ; 0x1dfa4
	dw Route5GateText1, Route5GateText2, Route5GateText3

Route8GateText1:
Route7GateText1:
Route6GateText1:
Route5GateText1: ; 0x1dfaa
	db $8
	ld a, [$d728]
	bit 6, a
	jr nz, .asm_88856 ; 0x1dfb0 $2c
	ld b, $16
	ld hl, $659f
	call Bankswitch
	ld a, [$ff00+$db]
	and a
	jr nz, .asm_768a2 ; 0x1dfbd $11
	ld hl, UnnamedText_1dfe7
	call PrintText
	call $5f43
	ld a, $1
	ld [$d662], a
	jp TextScriptEnd
.asm_768a2 ; 0x1dfd0
	ld hl, UnnamedText_1dfec
	call PrintText
	ld hl, $d728
	set 6, [hl]
	jp TextScriptEnd
.asm_88856 ; 0x1dfde
	ld hl, UnnamedText_1dff6
	call PrintText
	jp TextScriptEnd
; 0x1dfe7

Route8GateText2:
Route7GateText2:
Route6GateText2:
Route5GateText2: ; 0x1dfe7
UnnamedText_1dfe7: ; 0x1dfe7
	TX_FAR _UnnamedText_1dfe7
	db $50
; 0x1dfe7 + 5 bytes

Route8GateText3:
Route7GateText3:
Route6GateText3:
Route5GateText3: ; 0x1dfec
UnnamedText_1dfec: ; 0x1dfec
	TX_FAR _UnnamedText_8aaa9 ; 0x8aaa9
	db $11
	TX_FAR _UnnamedText_1dff1 ; 0x8aaef
	db $50
; 0x1dff6

UnnamedText_1dff6: ; 0x1dff6
	TX_FAR _UnnamedText_1dff6
	db $50
; 0x1dff6 + 5 bytes

Route5GateObject: ; 0x1dffb (size=42)
	db $a ; border tile

	db $4 ; warps
	db $5, $3, $2, $ff
	db $5, $4, $2, $ff
	db $0, $3, $1, $ff
	db $0, $4, $0, $ff

	db $0 ; signs

	db $1 ; people
	db SPRITE_GUARD, $3 + 4, $1 + 4, $ff, $d3, $1 ; person

	; warp-to
	EVENT_DISP $4, $5, $3
	EVENT_DISP $4, $5, $4
	EVENT_DISP $4, $0, $3
	EVENT_DISP $4, $0, $4

Route5GateBlocks: ; 0x1e025 12
	INCBIN "maps/route5gate.blk"

Route6Gate_h: ; 0x1e031 to 0x1e03d (12 bytes) (bank=7) (id=73)
	db $0c ; tileset
	db ROUTE_6_GATE_HEIGHT, ROUTE_6_GATE_WIDTH ; dimensions (y, x)
	dw Route6GateBlocks, Route6GateTexts, Route6GateScript ; blocks, texts, scripts
	db $00 ; connections

	dw Route6GateObject ; objects

Route6GateScript: ; 0x1e03d
	call $3c3c
	ld hl, Route6GateScripts
	ld a, [$d636]
	call $3d97
	ret
; 0x1e04a

Route6GateScripts: ; 0x1e04a
	dw Route6GateScript0

INCBIN "baserom.gbc",$1e04c,$2

Route6GateScript0: ; 0x1e04e
	ld a, [$d728]
	bit 6, a
	ret nz
	ld hl, $608c
	call $34bf
	ret nc
	ld a, $1
	ld [$d528], a
	xor a
	ld [$ff00+$b4], a
	ld b, $16
	ld hl, $659f
	call Bankswitch
	ld a, [$ff00+$db]
	and a
	jr nz, .asm_1e080 ; 0x1e06e $10
	ld a, $2
	ld [$ff00+$8c], a
	call $2920
	call $60a1
	ld a, $1
	ld [$d636], a
	ret
.asm_1e080
	ld hl, $d728
	set 6, [hl]
	ld a, $3
	ld [$ff00+$8c], a
	jp $2920
; 0x1e08c

INCBIN "baserom.gbc",$1e08c,$2c

Route6GateTexts: ; 0x1e0b8
	dw Route6GateText1, Route6GateText2, Route6GateText3

Route6GateObject: ; 0x1e0be (size=42)
	db $a ; border tile

	db $4 ; warps
	db $5, $3, $2, $ff
	db $5, $4, $2, $ff
	db $0, $3, $1, $ff
	db $0, $4, $1, $ff

	db $0 ; signs

	db $1 ; people
	db SPRITE_GUARD, $2 + 4, $6 + 4, $ff, $d2, $1 ; person

	; warp-to
	EVENT_DISP $4, $5, $3
	EVENT_DISP $4, $5, $4
	EVENT_DISP $4, $0, $3
	EVENT_DISP $4, $0, $4

Route6GateBlocks: ; 0x1e0e8 12
	INCBIN "maps/route6gate.blk"

Route7Gate_h: ; 0x1e0f4 to 0x1e100 (12 bytes) (bank=7) (id=76)
	db $0c ; tileset
	db ROUTE_7_GATE_HEIGHT, ROUTE_7_GATE_WIDTH ; dimensions (y, x)
	dw Route7GateBlocks, Route7GateTexts, Route7GateScript ; blocks, texts, scripts
	db $00 ; connections

	dw Route7GateObject ; objects

Route7GateScript: ; 0x1e100
	call $3c3c
	ld a, [$d663]
	ld hl, Route7GateScripts
	call $3d97
	ret
; 0x1e10d

Route7GateScripts: ; 0x1e10d
	dw Route7GateScript0

INCBIN "baserom.gbc",$1e10f,$19

Route7GateScript0: ; 0x1e128
	ld a, [$d728]
	bit 6, a
	ret nz
	ld hl, $6167
	call $34bf
	ret nc
	ld a, $8
	ld [$d528], a
	xor a
	ld [$ff00+$b4], a
	ld b, $16
	ld hl, $659f
	call Bankswitch
	ld a, [$ff00+$db]
	and a
	jr nz, .asm_1e15a ; 0x1e148 $10
	ld a, $2
	ld [$ff00+$8c], a
	call $2920
	call $6111
	ld a, $1
	ld [$d663], a
	ret
.asm_1e15a
	ld a, $3
	ld [$ff00+$8c], a
	call $2920
	ld hl, $d728
	set 6, [hl]
	ret
; 0x1e167

INCBIN "baserom.gbc",$1e167,$18

Route7GateTexts: ; 0x1e17f
	dw Route7GateText1, Route7GateText2, Route7GateText3

Route7GateObject: ; 0x1e185 (size=42)
	db $a ; border tile

	db $4 ; warps
	db $3, $0, $3, $ff
	db $4, $0, $3, $ff
	db $3, $5, $0, $ff
	db $4, $5, $1, $ff

	db $0 ; signs

	db $1 ; people
	db SPRITE_GUARD, $1 + 4, $3 + 4, $ff, $d0, $1 ; person

	; warp-to
	EVENT_DISP $3, $3, $0
	EVENT_DISP $3, $4, $0
	EVENT_DISP $3, $3, $5
	EVENT_DISP $3, $4, $5

Route7GateBlocks: ; 0x1e1af 12
	INCBIN "maps/route7gate.blk"

Route8Gate_h: ; 0x1e1bb to 0x1e1c7 (12 bytes) (bank=7) (id=79)
	db $0c ; tileset
	db ROUTE_8_GATE_HEIGHT, ROUTE_8_GATE_WIDTH ; dimensions (y, x)
	dw Route8GateBlocks, Route8GateTexts, Route8GateScript ; blocks, texts, scripts
	db $00 ; connections

	dw Route8GateObject ; objects

Route8GateScript: ; 0x1e1c7
	call $3c3c
	ld hl, Route8GateScripts
	ld a, [$d637]
	jp $3d97
; 0x1e1d3

Route8GateScripts: ; 0x1e1d3
	dw Route8GateScript0

INCBIN "baserom.gbc",$1e1d5,$19

Route8GateScript0: ; 0x1e1ee
	ld a, [$d728]
	bit 6, a
	ret nz
	ld hl, $622c
	call $34bf
	ret nc
	ld a, $2
	ld [$d528], a
	xor a
	ld [$ff00+$b4], a
	ld b, $16
	ld hl, $659f
	call Bankswitch
	ld a, [$ff00+$db]
	and a
	jr nz, .asm_1e220 ; 0x1e20e $10
	ld a, $2
	ld [$ff00+$8c], a
	call $2920
	call $61d7
	ld a, $1
	ld [$d637], a
	ret
.asm_1e220
	ld hl, $d728
	set 6, [hl]
	ld a, $3
	ld [$ff00+$8c], a
	jp $2920
; 0x1e22c

INCBIN "baserom.gbc",$1e22c,$15

Route8GateTexts: ; 0x1e241
	dw Route8GateText1, Route8GateText2, Route8GateText3

Route8GateObject: ; 0x1e247 (size=42)
	db $a ; border tile

	db $4 ; warps
	db $3, $0, $0, $ff
	db $4, $0, $1, $ff
	db $3, $5, $2, $ff
	db $4, $5, $3, $ff

	db $0 ; signs

	db $1 ; people
	db SPRITE_GUARD, $1 + 4, $2 + 4, $ff, $d0, $1 ; person

	; warp-to
	EVENT_DISP $3, $3, $0
	EVENT_DISP $3, $4, $0
	EVENT_DISP $3, $3, $5
	EVENT_DISP $3, $4, $5

Route8GateBlocks: ; 0x1e271 12
	INCBIN "maps/route8gate.blk"

UndergroundPathEntranceRoute8_h: ; 0x1e27d to 0x1e289 (12 bytes) (bank=7) (id=80)
	db $0c ; tileset
	db PATH_ENTRANCE_ROUTE_8_HEIGHT, PATH_ENTRANCE_ROUTE_8_WIDTH ; dimensions (y, x)
	dw UndergroundPathEntranceRoute8Blocks, UndergroundPathEntranceRoute8Texts, UndergroundPathEntranceRoute8Script ; blocks, texts, scripts
	db $00 ; connections

	dw UndergroundPathEntranceRoute8Object ; objects

UndergroundPathEntranceRoute8Script: ; 0x1e289
	ld a, $13
	ld [$d365], a
	jp $3c3c
; 0x1e291

UndergroundPathEntranceRoute8Texts: ; 0x1e291
	dw UndergroundPathEntranceRoute8Text1

;XXX wtf? syntax error
UndergroundPathEntranceRoute8Text1: ; 0x1e293
	db $17, $8d, $42, $23
	;TX_FAR _UndergroundPathEntranceRoute8Text1
	db $50

UndergroundPathEntranceRoute8Object: ; 0x1e298 (size=34)
	db $a ; border tile

	db $3 ; warps
	db $7, $3, $4, $ff
	db $7, $4, $4, $ff
	db $4, $4, $1, UNDERGROUND_PATH_WE

	db $0 ; signs

	db $1 ; people
	db SPRITE_GIRL, $4 + 4, $3 + 4, $ff, $ff, $1 ; person

	; warp-to
	EVENT_DISP $4, $7, $3
	EVENT_DISP $4, $7, $4
	EVENT_DISP $4, $4, $4 ; UNDERGROUND_PATH_WE

PowerPlant_h: ; 0x1e2ba to 0x1e2c6 (12 bytes) (bank=7) (id=83)
	db $16 ; tileset
	db POWER_PLANT_HEIGHT, POWER_PLANT_WIDTH ; dimensions (y, x)
	dw PowerPlantBlocks, PowerPlantTexts, PowerPlantScript ; blocks, texts, scripts
	db $00 ; connections

	dw PowerPlantObject ; objects

PowerPlantScript: ; 0x1e2c6
	call $3c3c
	ld hl, $62fb
	ld de, PowerPlantScript_Unknown1e2d9
	ld a, [$d663]
	call $3160
	ld [$d663], a
	ret
; 0x1e2d9

PowerPlantScript_Unknown1e2d9: ; 0x1e2d9
INCBIN "baserom.gbc",$1e2d9,$6

PowerPlantTexts: ; 0x1e2df
	dw PowerPlantText1, PowerPlantText2, PowerPlantText3, PowerPlantText4, PowerPlantText5, PowerPlantText6, PowerPlantText7, PowerPlantText8, PowerPlantText9, PowerPlantText10, PowerPlantText11, PowerPlantText12, PowerPlantText13, PowerPlantText14

INCBIN "baserom.gbc",$1e2fb,$6d

asm_234cc:
	call $31cc
	ld a, [$da39]
	ld [$d663], a
	jp TextScriptEnd
; 0x1e374

PowerPlantText1: ; 0x1e374
	db $8 ; asm
	ld hl, $62fb
	jr asm_234cc ; 0x1e378 $ee

PowerPlantText2: ; 0x1e37a
	db $8 ; asm
	ld hl, $6307
	jr asm_234cc ; 0x1e37e $e8

PowerPlantText3: ; 0x1e380
	db $8 ; asm
	ld hl, $6313
	jr asm_234cc ; 0x1e384 $e2

PowerPlantText4: ; 0x1e386
	db $8 ; asm
	ld hl, $631f
	jr asm_234cc ; 0x1e38a $dc

PowerPlantText5:
	db $8 ; asm
	ld hl, $632b
	jr asm_234cc ; 0x1e390 $d6

PowerPlantText6: ; 0x1e392
	db $8 ; asm
	ld hl, $6337
	jr asm_234cc ; 0x1e396 $d0

PowerPlantText7: ; 0x1e398
	db $8 ; asm
	ld hl, $6343
	jr asm_234cc ; 0x1e39c $ca

PowerPlantText8: ; 0x1e39e
	db $8 ; asm
	ld hl, $634f
	jr asm_234cc ; 0x1e3a2 $c4

PowerPlantText9: ; 0x1e3a4
	db $8 ; asm
	ld hl, $635b
	jr asm_234cc ; 0x1e3a8 $be
; 0x1e3aa

UnnamedText_1e3aa: ; 0x1e3aa
	TX_FAR _UnnamedText_1e3aa ; 0x8c5e2
	db $50
; 0x1e3af

UnnamedText_1e3af: ; 0x1e3af
	TX_FAR _UnnamedText_1e3af ; 0x8c5ea
	db $8
	ld a, $4b
	call $13d0
	call $3748
	jp TextScriptEnd
; 0x1e3bf

PowerPlantObject: ; 0x1e3bf (size=135)
	db $2e ; border tile

	db $3 ; warps
	db $23, $4, $3, $ff
	db $23, $5, $3, $ff
	db $b, $0, $3, $ff

	db $0 ; signs

	db $e ; people
	db SPRITE_BALL, $14 + 4, $9 + 4, $ff, $ff, $41, VOLTORB, $28 ; trainer
	db SPRITE_BALL, $12 + 4, $20 + 4, $ff, $ff, $42, VOLTORB, $28 ; trainer
	db SPRITE_BALL, $19 + 4, $15 + 4, $ff, $ff, $43, VOLTORB, $28 ; trainer
	db SPRITE_BALL, $12 + 4, $19 + 4, $ff, $ff, $44, ELECTRODE, $2b ; trainer
	db SPRITE_BALL, $22 + 4, $17 + 4, $ff, $ff, $45, VOLTORB, $28 ; trainer
	db SPRITE_BALL, $1c + 4, $1a + 4, $ff, $ff, $46, VOLTORB, $28 ; trainer
	db SPRITE_BALL, $e + 4, $15 + 4, $ff, $ff, $47, ELECTRODE, $2b ; trainer
	db SPRITE_BALL, $20 + 4, $25 + 4, $ff, $ff, $48, VOLTORB, $28 ; trainer
	db SPRITE_BIRD, $9 + 4, $4 + 4, $ff, $d1, $49, ZAPDOS, $32 ; trainer
	db SPRITE_BALL, $19 + 4, $7 + 4, $ff, $ff, $8a, CARBOS ; item
	db SPRITE_BALL, $3 + 4, $1c + 4, $ff, $ff, $8b, HP_UP ; item
	db SPRITE_BALL, $3 + 4, $22 + 4, $ff, $ff, $8c, RARE_CANDY ; item
	db SPRITE_BALL, $20 + 4, $1a + 4, $ff, $ff, $8d, TM_25 ; item
	db SPRITE_BALL, $20 + 4, $14 + 4, $ff, $ff, $8e, TM_33 ; item

	; warp-to
	EVENT_DISP $14, $23, $4
	EVENT_DISP $14, $23, $5
	EVENT_DISP $14, $b, $0

PowerPlantBlocks: ; 0x1e446 360
	INCBIN "maps/powerplant.blk"

DiglettsCaveEntranceRoute11_h: ; 0x1e5ae to 0x1e5ba (12 bytes) (bank=7) (id=85)
	db $11 ; tileset
	db DIGLETTS_CAVE_ENTRANCE_HEIGHT, DIGLETTS_CAVE_ENTRANCE_WIDTH ; dimensions (y, x)
	dw DiglettsCaveEntranceRoute11Blocks, DiglettsCaveEntranceRoute11Texts, DiglettsCaveEntranceRoute11Script ; blocks, texts, scripts
	db $00 ; connections

	dw DiglettsCaveEntranceRoute11Object ; objects

DiglettsCaveEntranceRoute11Script: ; 0x1e5ba
	call $3c3c
	ld a, $16
	ld [$d365], a
	ret
; 0x1e5c3

DiglettsCaveEntranceRoute11Texts: ; 0x1e5c3
	dw DiglettsCaveEntranceRoute11Text1

; XXX wtf? syntax error
DiglettsCaveEntranceRoute11Text1: ; 0x1e5c5
	db $17, $f9, $47, $23
	;TX_FAR _DiglettsCaveEntranceRoute11Text1
	db $50

DiglettsCaveEntranceRoute11Object: ; 0x1e5ca (size=34)
	db $7d ; border tile

	db $3 ; warps
	db $7, $2, $4, $ff
	db $7, $3, $4, $ff
	db $4, $4, $1, DIGLETTS_CAVE

	db $0 ; signs

	db $1 ; people
	db SPRITE_GAMBLER, $3 + 4, $2 + 4, $ff, $ff, $1 ; person

	; warp-to
	EVENT_DISP $4, $7, $2
	EVENT_DISP $4, $7, $3
	EVENT_DISP $4, $4, $4 ; DIGLETTS_CAVE

Route16House_h: ; 0x1e5ec to 0x1e5f8 (12 bytes) (bank=7) (id=188)
	db $08 ; tileset
	db ROUTE_16_HOUSE_HEIGHT, ROUTE_16_HOUSE_WIDTH ; dimensions (y, x)
	dw Route16HouseBlocks, Route16HouseTexts, Route16HouseScript ; blocks, texts, scripts
	db $00 ; connections

	dw Route16HouseObject ; objects

Route16HouseScript: ; 0x1e5f8
	jp $3c3c
; 0x1e5fb

Route16HouseTexts: ; 0x1e5fb
	dw Route16HouseText1, Route16HouseText2

Route16HouseText1: ; 0x1e5ff
	db $08 ; asm
	ld a, [$d7e0]
	bit 6, a
	ld hl, HM02ExplanationText
	jr nz, .asm_13616 ; 0x1e608
	ld hl, Route16HouseText3
	call PrintText
	ld bc, (HM_02 << 8) | 1
	call GiveItem
	jr nc, .asm_d3ee3 ; 0x1e616
	ld hl, $d7e0
	set 6, [hl]
	ld hl, ReceivedHM02Text
	jr .asm_13616 ; 0x1e620
.asm_d3ee3 ; 0x1e622
	ld hl, HM02NoRoomText
.asm_13616 ; 0x1e625
	call PrintText
	jp TextScriptEnd

Route16HouseText3: ; 0x1e62b
	TX_FAR _Route16HouseText3
	db $50
; 0x1e62b + 5 bytes

ReceivedHM02Text: ; 0x1e630
	TX_FAR _ReceivedHM02Text ; 0x8ce66
	db $11, $50

HM02ExplanationText: ; 0x1e636
	TX_FAR _HM02ExplanationText
	db $50
; 0x1e636 + 5 bytes

HM02NoRoomText: ; 0x1e63b
	TX_FAR _HM02NoRoomText
	db $50
; 0x1e63b + 5 bytes

Route16HouseText2: ; 0x1e640
	db $08 ; asm
	ld hl, UnnamedText_1e652
	call PrintText
	ld a, FEAROW
	call $13d0
	call $3748
	jp TextScriptEnd

UnnamedText_1e652: ; 0x1e652
	TX_FAR _UnnamedText_1e652
	db $50
; 0x1e652 + 5 bytes

Route16HouseObject: ; 0x1e657 (size=32)
	db $a ; border tile

	db $2 ; warps
	db $7, $2, $8, $ff
	db $7, $3, $8, $ff

	db $0 ; signs

	db $2 ; people
	db SPRITE_BRUNETTE_GIRL, $3 + 4, $2 + 4, $ff, $d3, $1 ; person
	db SPRITE_BIRD, $4 + 4, $6 + 4, $fe, $0, $2 ; person

	; warp-to
	EVENT_DISP $4, $7, $2
	EVENT_DISP $4, $7, $3

Route22Gate_h: ; 0x1e677 to 0x1e683 (12 bytes) (bank=7) (id=193)
	db $0c ; tileset
	db ROUTE_22_GATE_HEIGHT, ROUTE_22_GATE_WIDTH ; dimensions (y, x)
	dw Route22GateBlocks, Route22GateTexts, Route22GateScript ; blocks, texts, scripts
	db $00 ; connections

	dw Route22GateObject ; objects

Route22GateScript: ; 0x1e683
	call $3c3c
	ld hl, Route22GateScripts
	ld a, [$d60e]
	call $3d97
	ld a, [$d361]
	cp $4
	ld a, $22
	jr c, .asm_1e69a ; 0x1e696 $2
	ld a, $21
.asm_1e69a
	ld [$d365], a
	ret
; 0x1e69e

Route22GateScripts: ; 0x1e69e
	dw Route22GateScript0, Route22GateScript1

INCBIN "baserom.gbc",$1e6a2,$2

Route22GateScript0: ; 0x1e6a4
	ld hl, $66b5
	call $34bf
	ret nc
	xor a
	ld [$ff00+$b4], a
	ld a, $1
	ld [$ff00+$8c], a
	jp $2920
; 0x1e6b5

INCBIN "baserom.gbc",$1e6b5,$1e6cd - $1e6b5

Route22GateScript1: ; 0x1e6cd
	ld a, [$cd38]
	and a
	ret nz
	xor a
	ld [$cd6b], a
	call Delay3
	ld a, $0
	ld [$d60e], a
	ret
; 0x1e6df

Route22GateTexts: ; 0x1e6df
	dw Route22GateText1

Route22GateText1: ; 0x1e6e1
	db $8
	ld a, [$d356]
	bit 0, a
	jr nz, .asm_8a809 ; 0x1e6e7 $d
	ld hl, UnnamedText_1e704
	call PrintText
	call $66ba
	ld a, $1
	jr .asm_20f7e ; 0x1e6f4 $8
.asm_8a809 ; 0x1e6f6
	ld hl, UnnamedText_1e71a
	call PrintText
	ld a, $2
.asm_20f7e ; 0x1e6fe
	ld [$d60e], a
	jp TextScriptEnd
; 0x1e704

UnnamedText_1e704: ; 0x1e704
	TX_FAR _UnnamedText_1e704 ; 0x8cfbb
	db $8
	ld a, $a5
	call $3740
	call $3748
	ld hl, $6715
	ret
; 0x1e715

UnnamedText_1e715: ; 0x1e715
	TX_FAR _UnnamedText_1e715
	db $50
; 0x1e71a

UnnamedText_1e71a: ; 0x1e71a
	TX_FAR _UnnamedText_1e71a ; 0x8d03e
	db $0B, $50
; 0x1e720

Route22GateObject: ; 0x1e720 (size=42)
	db $a ; border tile

	db $4 ; warps
	db $7, $4, $0, $ff
	db $7, $5, $0, $ff
	db $0, $4, $0, $ff
	db $0, $5, $1, $ff

	db $0 ; signs

	db $1 ; people
	db SPRITE_GUARD, $2 + 4, $6 + 4, $ff, $d2, $1 ; person

	; warp-to
	EVENT_DISP $5, $7, $4
	EVENT_DISP $5, $7, $5
	EVENT_DISP $5, $0, $4
	EVENT_DISP $5, $0, $5

Route22GateBlocks: ; 0x1e74a 20
	INCBIN "maps/route22gate.blk"

BillsHouse_h: ; 0x1e75e to 0x1e76a (12 bytes) (bank=7) (id=88)
	db $10 ; tileset
	db BILLS_HOUSE_HEIGHT, BILLS_HOUSE_WIDTH ; dimensions (y, x)
	dw BillsHouseBlocks, BillsHouseTexts, BillsHouseScript ; blocks, texts, scripts
	db $00 ; connections

	dw BillsHouseObject ; objects

BillsHouseScript: ; 0x1e76a
	call $3c3c
	ld a, [$d661]
	ld hl, BillsHouseScripts
	jp $3d97
; 0x1e776

BillsHouseScripts: ; 0x1e776
	dw BillsHouseScript0

INCBIN "baserom.gbc",$1e778,$a

BillsHouseScript0: ; 0x1e782
	ret
; 0x1e783

INCBIN "baserom.gbc",$1e783,$b1

BillsHouseTexts: ; 0x1e834
	dw BillsHouseText1, BillsHouseText2, BillsHouseText3, BillsHouseText4

BillsHouseText4: ; 0x1e83c
	db $fd

BillsHouseText1: ; 0x1e83d
	db $8
	ld hl, UnnamedText_1e865
	call PrintText
	call $35ec
	ld a, [$cc26]
	and a
	jr nz, asm_6b196 ; 0x1e84b $d
asm_4d03c:
	ld hl, UnnamedText_1e86a
	call PrintText
	ld a, $1
	ld [$d661], a
	jr asm_fd4e2 ; 0x1e858 $8
asm_6b196: ; 0x1e85a
	ld hl, UnnamedText_1e86f
	call PrintText
	jr asm_4d03c ; 0x1e860 $eb
asm_fd4e2 ; 0x1e862
	jp TextScriptEnd

UnnamedText_1e865: ; 0x1e865
	TX_FAR _UnnamedText_1e865 ; 0x8d267
	db $50
; 0x1e86a

UnnamedText_1e86a: ; 0x1e86a
	TX_FAR _UnnamedText_1e86a ; 0x8d345
	db $50
; 0x1e86f

UnnamedText_1e86f: ; 0x1e86f
	TX_FAR _UnnamedText_1e86f ; 0x8d391
	db $50
; 0x1e874

BillsHouseText2: ; 0x1e874
	db $08 ; asm
	ld a, [$d7f2]
	bit 4, a
	jr nz, .asm_5491f ; 0x1e87a
	ld hl, BillThankYouText
	call PrintText
	ld bc, (S_S__TICKET << 8) | 1
	call GiveItem
	jr nc, .asm_18a67 ; 0x1e888
	ld hl, SSTicketReceivedText
	call PrintText
	ld hl, $d7f2
	set 4, [hl]
	ld a, $7
	ld [$cc4d], a
	ld a, $15
	call Predef
	ld a, $9
	ld [$cc4d], a
	ld a, $11
	call Predef
.asm_5491f ; 0x1e8a9
	ld hl, UnnamedText_1e8cb
	call PrintText
	jr .asm_bd408 ; 0x1e8af
.asm_18a67 ; 0x1e8b1
	ld hl, SSTicketNoRoomText
	call PrintText
.asm_bd408 ; 0x1e8b7
	jp TextScriptEnd

BillThankYouText: ; 0x1e8ba
	TX_FAR _BillThankYouText
	db $50
; 0x1e8ba + 5 bytes

SSTicketReceivedText: ; 0x1e8bf
	TX_FAR _SSTicketReceivedText ; 0x8d499
	db $11, $6, $50

SSTicketNoRoomText: ; 0x1e8c6
	TX_FAR _SSTicketNoRoomText
	db $50
; 0x1e8c6 + 5 bytes

UnnamedText_1e8cb: ; 0x1e8cb
	TX_FAR _UnnamedText_1e8cb
	db $50
; 0x1e8cb + 5 bytes

BillsHouseText3: ; 0x1e8d0
	db $08 ; asm
	ld hl, UnnamedText_1e8da
	call PrintText
	jp TextScriptEnd
; 0x1e8da

UnnamedText_1e8da: ; 0x1e8da
	TX_FAR _UnnamedText_1e8da
	db $50
; 0x1e8da + 5 bytes

BillsHouseObject: ; 0x1e8df (size=38)
	db $d ; border tile

	db $2 ; warps
	db $7, $2, $0, $ff
	db $7, $3, $0, $ff

	db $0 ; signs

	db $3 ; people
	db SPRITE_SLOWBRO, $5 + 4, $6 + 4, $ff, $ff, $1 ; person
	db SPRITE_BLACK_HAIR_BOY_2, $4 + 4, $4 + 4, $ff, $ff, $2 ; person
	db SPRITE_BLACK_HAIR_BOY_2, $5 + 4, $6 + 4, $ff, $ff, $3 ; person

	; warp-to
	EVENT_DISP $4, $7, $2
	EVENT_DISP $4, $7, $3

BillsHouseBlocks: ; 0x1e905
	INCBIN "maps/billshouse.blk"

INCBIN "baserom.gbc",$1e915,$1e93b - $1e915

UnnamedText_1e93b: ; 0x1e93b
	TX_FAR _UnnamedText_1e93b
	db $50
; 0x1e93b + 5 bytes

INCBIN "baserom.gbc",$1e940,$1e946 - $1e940

UnnamedText_1e946: ; 0x1e946
	TX_FAR _UnnamedText_1e946
	db $50
; 0x1e946 + 5 bytes

INCBIN "baserom.gbc",$1e94b,$1e953 - $1e94b

UnnamedText_1e953: ; 0x1e953
	TX_FAR _UnnamedText_1e953
	db $50
; 0x1e953 + 5 bytes

INCBIN "baserom.gbc",$1e958,$1e960 - $1e958

UnnamedText_1e960: ; 0x1e960
	TX_FAR _UnnamedText_1e960
	db $50
; 0x1e960 + 5 bytes

INCBIN "baserom.gbc",$1e965,$1e97e - $1e965

UnnamedText_1e97e: ; 0x1e97e
	TX_FAR _UnnamedText_1e97e
	db $50
; 0x1e97e + 5 bytes

UnnamedText_1e983: ; 0x1e983
	TX_FAR _UnnamedText_1e983
	db $50
; 0x1e983 + 5 bytes

INCBIN "baserom.gbc",$1e988,$1ea0d - $1e988

UnnamedText_1ea0d: ; 0x1ea0d
	TX_FAR _UnnamedText_1ea0d
	db $50
; 0x1ea0d + 5 bytes

UnnamedText_1ea12: ; 0x1ea12
	TX_FAR _UnnamedText_1ea12
	db $50
; 0x1ea12 + 5 bytes

INCBIN "baserom.gbc",$1ea17,$1ea5b - $1ea17

UnnamedText_1ea5b: ; 0x1ea5b
	TX_FAR _UnnamedText_1ea5b
	db $50
; 0x1ea5b + 5 bytes

INCBIN "baserom.gbc",$1ea60,$1ea6c - $1ea60

UnnamedText_1ea6c: ; 0x1ea6c
	TX_FAR _UnnamedText_1ea6c
	db $50
; 0x1ea6c + 5 bytes

UnnamedText_1ea71: ; 0x1ea71
	TX_FAR _UnnamedText_1ea71
	db $50
; 0x1ea71 + 5 bytes

UnnamedText_1ea76: ; 0x1ea76
	TX_FAR _UnnamedText_1ea76
	db $50
; 0x1ea76 + 5 bytes

UnnamedText_1ea7b: ; 0x1ea7b
	TX_FAR _UnnamedText_1ea7b
	db $50
; 0x1ea7b + 5 bytes

UnnamedText_1ea80: ; 0x1ea80
	TX_FAR _UnnamedText_1ea80
	db $50
; 0x1ea80 + 5 bytes

UnnamedText_1ea85: ; 0x1ea85
	TX_FAR _UnnamedText_1ea85
	db $50
; 0x1ea85 + 5 bytes

INCBIN "baserom.gbc",$1ea8a,$1eb05 - $1ea8a

UnnamedText_1eb05: ; 0x1eb05
	TX_FAR _UnnamedText_1eb05
	db $50
; 0x1eb05 + 5 bytes

INCBIN "baserom.gbc",$1eb0a,$1eb69 - $1eb0a

UnnamedText_1eb69: ; 0x1eb69
	TX_FAR _UnnamedText_1eb69
	db $50
; 0x1eb69 + 5 bytes

INCBIN "baserom.gbc",$1eb6e,$1ebdd - $1eb6e

UnnamedText_1ebdd: ; 0x1ebdd
	TX_FAR _UnnamedText_1ebdd
	db $50
; 0x1ebdd + 5 bytes

INCBIN "baserom.gbc",$1ebe2,$1ec7f - $1ebe2

UnnamedText_1ec7f: ; 0x1ec7f
	TX_FAR _UnnamedText_1ec7f
	db $50
; 0x1ec7f + 5 bytes

INCBIN "baserom.gbc",$1ec84,$1ecaa - $1ec84

UnnamedText_1ecaa: ; 0x1ecaa
	TX_FAR _UnnamedText_1ecaa
	db $50
; 0x1ecaa + 5 bytes

INCBIN "baserom.gbc",$1ecaf,$1ecbd - $1ecaf

UnnamedText_1ecbd: ; 0x1ecbd
	TX_FAR _UnnamedText_1ecbd
	db $50
; 0x1ecbd + 5 bytes

INCBIN "baserom.gbc",$1ecc2,$133e

SECTION "bank8",DATA,BANK[$8]

INCBIN "baserom.gbc",$20000,$217e9 - $20000

UnnamedText_217e9: ; 0x217e9
	TX_FAR _UnnamedText_217e9
	db $50
; 0x217e9 + 5 bytes

UnnamedText_217ee: ; 0x217ee
	TX_FAR _UnnamedText_217ee
	db $50
; 0x217ee + 5 bytes

UnnamedText_217f3: ; 0x217f3
	TX_FAR _UnnamedText_217f3
	db $50
; 0x217f3 + 5 bytes

UnnamedText_217f8: ; 0x217f8
	TX_FAR _UnnamedText_217f8
	db $50
; 0x217f8 + 5 bytes

UnnamedText_217fd: ; 0x217fd
	TX_FAR _UnnamedText_217fd
	db $50
; 0x217fd + 5 bytes

UnnamedText_21802: ; 0x21802
	TX_FAR _UnnamedText_21802
	db $50
; 0x21802 + 5 bytes

UnnamedText_21807: ; 0x21807
	TX_FAR _UnnamedText_21807
	db $50
; 0x21807 + 5 bytes

UnnamedText_2180c: ; 0x2180c
	TX_FAR _UnnamedText_2180c
	db $50
; 0x2180c + 5 bytes

UnnamedText_21811: ; 0x21811
	TX_FAR _UnnamedText_21811
	db $50
; 0x21811 + 5 bytes

UnnamedText_21816: ; 0x21816
	TX_FAR _UnnamedText_21816
	db $50
; 0x21816 + 5 bytes

UnnamedText_2181b: ; 0x2181b
	TX_FAR _UnnamedText_2181b
	db $50
; 0x2181b + 5 bytes

UnnamedText_21820: ; 0x21820
	TX_FAR _UnnamedText_21820
	db $50
; 0x21820 + 5 bytes

INCBIN "baserom.gbc",$21825,$21865 - $21825

UnnamedText_21865: ; 0x21865
	TX_FAR _UnnamedText_21865
	db $50
; 0x21865 + 5 bytes

INCBIN "baserom.gbc",$2186a,$23f52 - $2186a

SECTION "bank9",DATA,BANK[$9]

RhydonPicFront:
	INCBIN "pic/bmon/rhydon.pic"
RhydonPicBack:
	INCBIN "pic/monback/rhydonb.pic"
KangaskhanPicFront:
	INCBIN "pic/bmon/kangaskhan.pic"
KangaskhanPicBack:
	INCBIN "pic/monback/kangaskhanb.pic"
NidoranMPicFront:
	INCBIN "pic/bmon/nidoranm.pic"
NidoranMPicBack:
	INCBIN "pic/monback/nidoranmb.pic"
ClefairyPicFront:
	INCBIN "pic/bmon/clefairy.pic"
ClefairyPicBack:
	INCBIN "pic/monback/clefairyb.pic"
SpearowPicFront:
	INCBIN "pic/bmon/spearow.pic"
SpearowPicBack:
	INCBIN "pic/monback/spearowb.pic"
VoltorbPicFront:
	INCBIN "pic/bmon/voltorb.pic"
VoltorbPicBack:
	INCBIN "pic/monback/voltorbb.pic"
NidokingPicFront:
	INCBIN "pic/bmon/nidoking.pic"
NidokingPicBack:
	INCBIN "pic/monback/nidokingb.pic"
SlowbroPicFront:
	INCBIN "pic/bmon/slowbro.pic"
SlowbroPicBack:
	INCBIN "pic/monback/slowbrob.pic"
IvysaurPicFront:
	INCBIN "pic/bmon/ivysaur.pic"
IvysaurPicBack:
	INCBIN "pic/monback/ivysaurb.pic"
ExeggutorPicFront:
	INCBIN "pic/bmon/exeggutor.pic"
ExeggutorPicBack:
	INCBIN "pic/monback/exeggutorb.pic"
LickitungPicFront:
	INCBIN "pic/bmon/lickitung.pic"
LickitungPicBack:
	INCBIN "pic/monback/lickitungb.pic"
ExeggcutePicFront:
	INCBIN "pic/bmon/exeggcute.pic"
ExeggcutePicBack:
	INCBIN "pic/monback/exeggcuteb.pic"
GrimerPicFront:
	INCBIN "pic/bmon/grimer.pic"
GrimerPicBack:
	INCBIN "pic/monback/grimerb.pic"
GengarPicFront:
	INCBIN "pic/bmon/gengar.pic"
GengarPicBack:
	INCBIN "pic/monback/gengarb.pic"
NidoranFPicFront:
	INCBIN "pic/bmon/nidoranf.pic"
NidoranFPicBack:
	INCBIN "pic/monback/nidoranfb.pic"
NidoqueenPicFront:
	INCBIN "pic/bmon/nidoqueen.pic"
NidoqueenPicBack:
	INCBIN "pic/monback/nidoqueenb.pic"
CubonePicFront:
	INCBIN "pic/bmon/cubone.pic"
CubonePicBack:
	INCBIN "pic/monback/cuboneb.pic"
RhyhornPicFront:
	INCBIN "pic/bmon/rhyhorn.pic"
RhyhornPicBack:
	INCBIN "pic/monback/rhyhornb.pic"
LaprasPicFront:
	INCBIN "pic/bmon/lapras.pic"
LaprasPicBack:
	INCBIN "pic/monback/laprasb.pic"
ArcaninePicFront:
	INCBIN "pic/bmon/arcanine.pic"
ArcaninePicBack:
	INCBIN "pic/monback/arcanineb.pic"
GyaradosPicFront:
	INCBIN "pic/bmon/gyarados.pic"
GyaradosPicBack:
	INCBIN "pic/monback/gyaradosb.pic"
ShellderPicFront:
	INCBIN "pic/bmon/shellder.pic"
ShellderPicBack:
	INCBIN "pic/monback/shellderb.pic"
TentacoolPicFront:
	INCBIN "pic/bmon/tentacool.pic"
TentacoolPicBack:
	INCBIN "pic/monback/tentacoolb.pic"
GastlyPicFront:
	INCBIN "pic/bmon/gastly.pic"
GastlyPicBack:
	INCBIN "pic/monback/gastlyb.pic"
ScytherPicFront:
	INCBIN "pic/bmon/scyther.pic"
ScytherPicBack:
	INCBIN "pic/monback/scytherb.pic"
StaryuPicFront:
	INCBIN "pic/bmon/staryu.pic"
StaryuPicBack:
	INCBIN "pic/monback/staryub.pic"
BlastoisePicFront:
	INCBIN "pic/bmon/blastoise.pic"
BlastoisePicBack:
	INCBIN "pic/monback/blastoiseb.pic"
PinsirPicFront:
	INCBIN "pic/bmon/pinsir.pic"
PinsirPicBack: ; 0x27aaa
	INCBIN "pic/monback/pinsirb.pic"
TangelaPicFront: ; 0x27b39
	INCBIN "pic/bmon/tangela.pic"
TangelaPicBack: ; 0x27ce7
	INCBIN "pic/monback/tangelab.pic"

INCBIN "baserom.gbc",$27d6b,$27DAE - $27d6b

TypeNamePointers: ; 7DAE
	dw Type00Name
	dw Type01Name
	dw Type02Name
	dw Type03Name
	dw Type04Name
	dw Type05Name
	dw Type06Name
	dw Type07Name
	dw Type08Name
	dw Type00Name
	dw Type00Name
	dw Type00Name
	dw Type00Name
	dw Type00Name
	dw Type00Name
	dw Type00Name
	dw Type00Name
	dw Type00Name
	dw Type00Name
	dw Type00Name
	dw Type14Name
	dw Type15Name
	dw Type16Name
	dw Type17Name
	dw Type18Name
	dw Type19Name
	dw Type1AName

Type00Name:
	db "NORMAL@"
Type01Name:
	db "FIGHTING@"
Type02Name:
	db "FLYING@"
Type03Name:
	db "POISON@"
Type14Name:
	db "FIRE@"
Type15Name:
	db "WATER@"
Type16Name:
	db "GRASS@"
Type17Name:
	db "ELECTRIC@"
Type18Name:
	db "PSYCHIC@"
Type19Name:
	db "ICE@"
Type04Name:
	db "GROUND@"
Type05Name:
	db "ROCK@"
Type06Name:
	db "BIRD@"
Type07Name:
	db "BUG@"
Type08Name:
	db "GHOST@"
Type1AName:
	db "DRAGON@"

SaveTrainerName: ; 7E4A
	ld hl,TrainerNamePointers
	ld a,[W_TRAINERCLASS]
	dec a
	ld c,a
	ld b,0
	add hl,bc
	add hl,bc
	ld a,[hli]
	ld h,[hl]
	ld l,a
	ld de,$CD6D
.CopyCharacter\@
	ld a,[hli]
	ld [de],a
	inc de
	cp "@"
	jr nz,.CopyCharacter\@
	ret

TrainerNamePointers: ; 0x27e64
; what is the point of these?
	dw YoungsterName
	dw BugCatcherName
	dw LassName
	dw $D04A
	dw JrTrainerMName
	dw JrTrainerFName
	dw PokemaniacName
	dw SuperNerdName
	dw $D04A
	dw $D04A
	dw BurglarName
	dw EngineerName
	dw JugglerXName
	dw $D04A
	dw SwimmerName
	dw $D04A
	dw $D04A
	dw BeautyName
	dw $D04A
	dw RockerName
	dw JugglerName
	dw $D04A
	dw $D04A
	dw BlackbeltName
	dw $D04A
	dw ProfOakName
	dw ChiefName
	dw ScientistName
	dw $D04A
	dw RocketName
	dw CooltrainerMName
	dw CooltrainerFName
	dw $D04A
	dw $D04A
	dw $D04A
	dw $D04A
	dw $D04A
	dw $D04A
	dw $D04A
	dw $D04A
	dw $D04A
	dw $D04A
	dw $D04A
	dw $D04A
	dw $D04A
	dw $D04A
	dw $D04A

YoungsterName:
	db "YOUNGSTER@"
BugCatcherName:
	db "BUG CATCHER@"
LassName:
	db "LASS@"
JrTrainerMName:
	db "JR.TRAINER♂@"
JrTrainerFName:
	db "JR.TRAINER♀@"
PokemaniacName:
	db "POKéMANIAC@"
SuperNerdName:
	db "SUPER NERD@"
BurglarName:
	db "BURGLAR@"
EngineerName:
	db "ENGINEER@"
JugglerXName:
	db "JUGGLER@"
SwimmerName:
	db "SWIMMER@"
BeautyName:
	db "BEAUTY@"
RockerName:
	db "ROCKER@"
JugglerName:
	db "JUGGLER@"
BlackbeltName:
	db "BLACKBELT@"
ProfOakName:
	db "PROF.OAK@"
ChiefName:
	db "CHIEF@"
ScientistName:
	db "SCIENTIST@"
RocketName:
	db "ROCKET@"
CooltrainerMName:
	db "COOLTRAINER♂@"
CooltrainerFName:
	db "COOLTRAINER♀@"

INCBIN "baserom.gbc",$27f86,$27fb3 - $27f86

UnnamedText_27fb3: ; 0x27fb3
	TX_FAR _UnnamedText_27fb3
	db $50
; 0x27fb3 + 5 bytes

SECTION "bankA",DATA,BANK[$A]
GrowlithePicFront:
	INCBIN "pic/bmon/growlithe.pic"
GrowlithePicBack:
	INCBIN "pic/monback/growlitheb.pic"
OnixPicFront:
	INCBIN "pic/bmon/onix.pic"
OnixPicBack:
	INCBIN "pic/monback/onixb.pic"
FearowPicFront:
	INCBIN "pic/bmon/fearow.pic"
FearowPicBack:
	INCBIN "pic/monback/fearowb.pic"
PidgeyPicFront:
	INCBIN "pic/bmon/pidgey.pic"
PidgeyPicBack:
	INCBIN "pic/monback/pidgeyb.pic"
SlowpokePicFront:
	INCBIN "pic/bmon/slowpoke.pic"
SlowpokePicBack:
	INCBIN "pic/monback/slowpokeb.pic"
KadabraPicFront:
	INCBIN "pic/bmon/kadabra.pic"
KadabraPicBack:
	INCBIN "pic/monback/kadabrab.pic"
GravelerPicFront:
	INCBIN "pic/bmon/graveler.pic"
GravelerPicBack:
	INCBIN "pic/monback/gravelerb.pic"
ChanseyPicFront:
	INCBIN "pic/bmon/chansey.pic"
ChanseyPicBack:
	INCBIN "pic/monback/chanseyb.pic"
MachokePicFront:
	INCBIN "pic/bmon/machoke.pic"
MachokePicBack:
	INCBIN "pic/monback/machokeb.pic"
MrMimePicFront:
	INCBIN "pic/bmon/mr.mime.pic"
MrMimePicBack:
	INCBIN "pic/monback/mr.mimeb.pic"
HitmonleePicFront:
	INCBIN "pic/bmon/hitmonlee.pic"
HitmonleePicBack:
	INCBIN "pic/monback/hitmonleeb.pic"
HitmonchanPicFront:
	INCBIN "pic/bmon/hitmonchan.pic"
HitmonchanPicBack:
	INCBIN "pic/monback/hitmonchanb.pic"
ArbokPicFront:
	INCBIN "pic/bmon/arbok.pic"
ArbokPicBack:
	INCBIN "pic/monback/arbokb.pic"
ParasectPicFront:
	INCBIN "pic/bmon/parasect.pic"
ParasectPicBack:
	INCBIN "pic/monback/parasectb.pic"
PsyduckPicFront:
	INCBIN "pic/bmon/psyduck.pic"
PsyduckPicBack:
	INCBIN "pic/monback/psyduckb.pic"
DrowzeePicFront:
	INCBIN "pic/bmon/drowzee.pic"
DrowzeePicBack:
	INCBIN "pic/monback/drowzeeb.pic"
GolemPicFront:
	INCBIN "pic/bmon/golem.pic"
GolemPicBack:
	INCBIN "pic/monback/golemb.pic"
MagmarPicFront:
	INCBIN "pic/bmon/magmar.pic"
MagmarPicBack:
	INCBIN "pic/monback/magmarb.pic"
ElectabuzzPicFront:
	INCBIN "pic/bmon/electabuzz.pic"
ElectabuzzPicBack:
	INCBIN "pic/monback/electabuzzb.pic"
MagnetonPicFront:
	INCBIN "pic/bmon/magneton.pic"
MagnetonPicBack:
	INCBIN "pic/monback/magnetonb.pic"
KoffingPicFront:
	INCBIN "pic/bmon/koffing.pic"
KoffingPicBack:
	INCBIN "pic/monback/koffingb.pic"
MankeyPicFront:
	INCBIN "pic/bmon/mankey.pic"
MankeyPicBack:
	INCBIN "pic/monback/mankeyb.pic"
SeelPicFront:
	INCBIN "pic/bmon/seel.pic"
SeelPicBack:
	INCBIN "pic/monback/seelb.pic"
DiglettPicFront:
	INCBIN "pic/bmon/diglett.pic"
DiglettPicBack:
	INCBIN "pic/monback/diglettb.pic"
TaurosPicFront:
	INCBIN "pic/bmon/tauros.pic"
TaurosPicBack:
	INCBIN "pic/monback/taurosb.pic"
FarfetchdPicFront:
	INCBIN "pic/bmon/farfetchd.pic"
FarfetchdPicBack:
	INCBIN "pic/monback/farfetchdb.pic"
VenonatPicFront:
	INCBIN "pic/bmon/venonat.pic"
VenonatPicBack:
	INCBIN "pic/monback/venonatb.pic"
DragonitePicFront:
	INCBIN "pic/bmon/dragonite.pic"
DragonitePicBack:
	INCBIN "pic/monback/dragoniteb.pic"
DoduoPicFront:
	INCBIN "pic/bmon/doduo.pic"
DoduoPicBack:
	INCBIN "pic/monback/doduob.pic"
PoliwagPicFront:
	INCBIN "pic/bmon/poliwag.pic"
PoliwagPicBack:
	INCBIN "pic/monback/poliwagb.pic"
JynxPicFront:
	INCBIN "pic/bmon/jynx.pic"
JynxPicBack:
	INCBIN "pic/monback/jynxb.pic"
MoltresPicFront:
	INCBIN "pic/bmon/moltres.pic"
MoltresPicBack:
	INCBIN "pic/monback/moltresb.pic"

INCBIN "baserom.gbc",$2bea9,$2bef2 - $2bea9

UnnamedText_2bef2: ; 0x2bef2
	TX_FAR _UnnamedText_2bef2
	db $50
; 0x2bef2 + 5 bytes

UnnamedText_2bef7: ; 0x2bef7
	TX_FAR _UnnamedText_2bef7
	db $50
; 0x2bef7 + 5 bytes

SECTION "bankB",DATA,BANK[$B]
ArticunoPicFront:
	INCBIN "pic/bmon/articuno.pic"
ArticunoPicBack:
	INCBIN "pic/monback/articunob.pic"
ZapdosPicFront:
	INCBIN "pic/bmon/zapdos.pic"
ZapdosPicBack:
	INCBIN "pic/monback/zapdosb.pic"
DittoPicFront:
	INCBIN "pic/bmon/ditto.pic"
DittoPicBack:
	INCBIN "pic/monback/dittob.pic"
MeowthPicFront:
	INCBIN "pic/bmon/meowth.pic"
MeowthPicBack:
	INCBIN "pic/monback/meowthb.pic"
KrabbyPicFront:
	INCBIN "pic/bmon/krabby.pic"
KrabbyPicBack:
	INCBIN "pic/monback/krabbyb.pic"
VulpixPicFront:
	INCBIN "pic/bmon/vulpix.pic"
VulpixPicBack:
	INCBIN "pic/monback/vulpixb.pic"
NinetalesPicFront:
	INCBIN "pic/bmon/ninetales.pic"
NinetalesPicBack:
	INCBIN "pic/monback/ninetalesb.pic"
PikachuPicFront:
	INCBIN "pic/bmon/pikachu.pic"
PikachuPicBack:
	INCBIN "pic/monback/pikachub.pic"
RaichuPicFront:
	INCBIN "pic/bmon/raichu.pic"
RaichuPicBack:
	INCBIN "pic/monback/raichub.pic"
DratiniPicFront:
	INCBIN "pic/bmon/dratini.pic"
DratiniPicBack:
	INCBIN "pic/monback/dratinib.pic"
DragonairPicFront:
	INCBIN "pic/bmon/dragonair.pic"
DragonairPicBack:
	INCBIN "pic/monback/dragonairb.pic"
KabutoPicFront:
	INCBIN "pic/bmon/kabuto.pic"
KabutoPicBack:
	INCBIN "pic/monback/kabutob.pic"
KabutopsPicFront:
	INCBIN "pic/bmon/kabutops.pic"
KabutopsPicBack:
	INCBIN "pic/monback/kabutopsb.pic"
HorseaPicFront:
	INCBIN "pic/bmon/horsea.pic"
HorseaPicBack:
	INCBIN "pic/monback/horseab.pic"
SeadraPicFront:
	INCBIN "pic/bmon/seadra.pic"
SeadraPicBack:
	INCBIN "pic/monback/seadrab.pic"
SandshrewPicFront:
	INCBIN "pic/bmon/sandshrew.pic"
SandshrewPicBack:
	INCBIN "pic/monback/sandshrewb.pic"
SandslashPicFront:
	INCBIN "pic/bmon/sandslash.pic"
SandslashPicBack:
	INCBIN "pic/monback/sandslashb.pic"
OmanytePicFront:
	INCBIN "pic/bmon/omanyte.pic"
OmanytePicBack:
	INCBIN "pic/monback/omanyteb.pic"
OmastarPicFront:
	INCBIN "pic/bmon/omastar.pic"
OmastarPicBack:
	INCBIN "pic/monback/omastarb.pic"
JigglypuffPicFront:
	INCBIN "pic/bmon/jigglypuff.pic"
JigglypuffPicBack:
	INCBIN "pic/monback/jigglypuffb.pic"
WigglytuffPicFront:
	INCBIN "pic/bmon/wigglytuff.pic"
WigglytuffPicBack:
	INCBIN "pic/monback/wigglytuffb.pic"
EeveePicFront:
	INCBIN "pic/bmon/eevee.pic"
EeveePicBack:
	INCBIN "pic/monback/eeveeb.pic"
FlareonPicFront:
	INCBIN "pic/bmon/flareon.pic"
FlareonPicBack:
	INCBIN "pic/monback/flareonb.pic"
JolteonPicFront:
	INCBIN "pic/bmon/jolteon.pic"
JolteonPicBack:
	INCBIN "pic/monback/jolteonb.pic"
VaporeonPicFront:
	INCBIN "pic/bmon/vaporeon.pic"
VaporeonPicBack:
	INCBIN "pic/monback/vaporeonb.pic"
MachopPicFront:
	INCBIN "pic/bmon/machop.pic"
MachopPicBack:
	INCBIN "pic/monback/machopb.pic"
ZubatPicFront:
	INCBIN "pic/bmon/zubat.pic"
ZubatPicBack:
	INCBIN "pic/monback/zubatb.pic"
EkansPicFront:
	INCBIN "pic/bmon/ekans.pic"
EkansPicBack:
	INCBIN "pic/monback/ekansb.pic"
ParasPicFront:
	INCBIN "pic/bmon/paras.pic"
ParasPicBack:
	INCBIN "pic/monback/parasb.pic"
PoliwhirlPicFront:
	INCBIN "pic/bmon/poliwhirl.pic"
PoliwhirlPicBack:
	INCBIN "pic/monback/poliwhirlb.pic"
PoliwrathPicFront:
	INCBIN "pic/bmon/poliwrath.pic"
PoliwrathPicBack:
	INCBIN "pic/monback/poliwrathb.pic"
WeedlePicFront:
	INCBIN "pic/bmon/weedle.pic"
WeedlePicBack:
	INCBIN "pic/monback/weedleb.pic"
KakunaPicFront:
	INCBIN "pic/bmon/kakuna.pic"
KakunaPicBack:
	INCBIN "pic/monback/kakunab.pic"
BeedrillPicFront:
	INCBIN "pic/bmon/beedrill.pic"
BeedrillPicBack:
	INCBIN "pic/monback/beedrillb.pic"
FossilKabutopsPic:
	INCBIN "pic/bmon/fossilkabutops.pic"

INCBIN "baserom.gbc",$2fb7b,$2fb8e - $2fb7b

UnnamedText_2fb8e: ; 0x2fb8e
	TX_FAR _UnnamedText_2fb8e
	db $50
; 0x2fb8e + 5 bytes

UnnamedText_2fb93: ; 0x2fb93
	TX_FAR _UnnamedText_2fb93
	db $50
; 0x2fb93 + 5 bytes

INCBIN "baserom.gbc",$2fb98,$2fe3b - $2fb98

UnnamedText_2fe3b: ; 0x2fe3b
	TX_FAR _UnnamedText_2fe3b
	db $50
; 0x2fe3b + 5 bytes

INCBIN "baserom.gbc",$2fe40,$2ff04 - $2fe40

UnnamedText_2ff04: ; 0x2ff04
	TX_FAR _UnnamedText_2ff04
	db $50
; 0x2ff04 + 5 bytes

INCBIN "baserom.gbc",$2ff09,$2ff32 - $2ff09

UnnamedText_2ff32: ; 0x2ff32
	TX_FAR _UnnamedText_2ff32
	db $50
; 0x2ff32 + 5 bytes

UnnamedText_2ff37: ; 0x2ff37
	TX_FAR _UnnamedText_2ff37
	db $50
; 0x2ff37 + 5 bytes

SECTION "bankC",DATA,BANK[$C]
DodrioPicFront:
	INCBIN "pic/bmon/dodrio.pic"
DodrioPicBack:
	INCBIN "pic/monback/dodriob.pic"
PrimeapePicFront:
	INCBIN "pic/bmon/primeape.pic"
PrimeapePicBack:
	INCBIN "pic/monback/primeapeb.pic"
DugtrioPicFront:
	INCBIN "pic/bmon/dugtrio.pic"
DugtrioPicBack:
	INCBIN "pic/monback/dugtriob.pic"
VenomothPicFront:
	INCBIN "pic/bmon/venomoth.pic"
VenomothPicBack:
	INCBIN "pic/monback/venomothb.pic"
DewgongPicFront:
	INCBIN "pic/bmon/dewgong.pic"
DewgongPicBack:
	INCBIN "pic/monback/dewgongb.pic"
CaterpiePicFront:
	INCBIN "pic/bmon/caterpie.pic"
CaterpiePicBack:
	INCBIN "pic/monback/caterpieb.pic"
MetapodPicFront:
	INCBIN "pic/bmon/metapod.pic"
MetapodPicBack:
	INCBIN "pic/monback/metapodb.pic"
ButterfreePicFront:
	INCBIN "pic/bmon/butterfree.pic"
ButterfreePicBack:
	INCBIN "pic/monback/butterfreeb.pic"
MachampPicFront:
	INCBIN "pic/bmon/machamp.pic"
MachampPicBack:
	INCBIN "pic/monback/machampb.pic"
GolduckPicFront:
	INCBIN "pic/bmon/golduck.pic"
GolduckPicBack:
	INCBIN "pic/monback/golduckb.pic"
HypnoPicFront:
	INCBIN "pic/bmon/hypno.pic"
HypnoPicBack:
	INCBIN "pic/monback/hypnob.pic"
GolbatPicFront:
	INCBIN "pic/bmon/golbat.pic"
GolbatPicBack:
	INCBIN "pic/monback/golbatb.pic"
MewtwoPicFront:
	INCBIN "pic/bmon/mewtwo.pic"
MewtwoPicBack:
	INCBIN "pic/monback/mewtwob.pic"
SnorlaxPicFront:
	INCBIN "pic/bmon/snorlax.pic"
SnorlaxPicBack:
	INCBIN "pic/monback/snorlaxb.pic"
MagikarpPicFront:
	INCBIN "pic/bmon/magikarp.pic"
MagikarpPicBack:
	INCBIN "pic/monback/magikarpb.pic"
MukPicFront:
	INCBIN "pic/bmon/muk.pic"
MukPicBack:
	INCBIN "pic/monback/mukb.pic"
KinglerPicFront:
	INCBIN "pic/bmon/kingler.pic"
KinglerPicBack:
	INCBIN "pic/monback/kinglerb.pic"
CloysterPicFront:
	INCBIN "pic/bmon/cloyster.pic"
CloysterPicBack:
	INCBIN "pic/monback/cloysterb.pic"
ElectrodePicFront:
	INCBIN "pic/bmon/electrode.pic"
ElectrodePicBack:
	INCBIN "pic/monback/electrodeb.pic"
ClefablePicFront:
	INCBIN "pic/bmon/clefable.pic"
ClefablePicBack:
	INCBIN "pic/monback/clefableb.pic"
WeezingPicFront:
	INCBIN "pic/bmon/weezing.pic"
WeezingPicBack:
	INCBIN "pic/monback/weezingb.pic"
PersianPicFront:
	INCBIN "pic/bmon/persian.pic"
PersianPicBack:
	INCBIN "pic/monback/persianb.pic"
MarowakPicFront:
	INCBIN "pic/bmon/marowak.pic"
MarowakPicBack:
	INCBIN "pic/monback/marowakb.pic"
HaunterPicFront:
	INCBIN "pic/bmon/haunter.pic"
HaunterPicBack:
	INCBIN "pic/monback/haunterb.pic"
AbraPicFront:
	INCBIN "pic/bmon/abra.pic"
AbraPicBack:
	INCBIN "pic/monback/abrab.pic"
AlakazamPicFront:
	INCBIN "pic/bmon/alakazam.pic"
AlakazamPicBack:
	INCBIN "pic/monback/alakazamb.pic"
PidgeottoPicFront:
	INCBIN "pic/bmon/pidgeotto.pic"
PidgeottoPicBack:
	INCBIN "pic/monback/pidgeottob.pic"
PidgeotPicFront:
	INCBIN "pic/bmon/pidgeot.pic"
PidgeotPicBack:
	INCBIN "pic/monback/pidgeotb.pic"
StarmiePicFront:
	INCBIN "pic/bmon/starmie.pic"
StarmiePicBack:
	INCBIN "pic/monback/starmieb.pic"
RedPicBack:
	INCBIN "pic/trainer/redb.pic"
OldManPic:
	INCBIN "pic/trainer/oldman.pic"

INCBIN "baserom.gbc",$33f2b,$33f52 - $33f2b

UnnamedText_33f52: ; 0x33f52
	TX_FAR _UnnamedText_33f52
	db $50
; 0x33f52 + 5 bytes

INCBIN "baserom.gbc",$33f57,$39

SECTION "bankD",DATA,BANK[$D]
BulbasaurPicFront:
	INCBIN "pic/bmon/bulbasaur.pic"
BulbasaurPicBack:
	INCBIN "pic/monback/bulbasaurb.pic"
VenusaurPicFront:
	INCBIN "pic/bmon/venusaur.pic"
VenusaurPicBack:
	INCBIN "pic/monback/venusaurb.pic"
TentacruelPicFront:
	INCBIN "pic/bmon/tentacruel.pic"
TentacruelPicBack:
	INCBIN "pic/monback/tentacruelb.pic"
GoldeenPicFront:
	INCBIN "pic/bmon/goldeen.pic"
GoldeenPicBack:
	INCBIN "pic/monback/goldeenb.pic"
SeakingPicFront:
	INCBIN "pic/bmon/seaking.pic"
SeakingPicBack:
	INCBIN "pic/monback/seakingb.pic"
PonytaPicFront:
	INCBIN "pic/bmon/ponyta.pic"
RapidashPicFront:
	INCBIN "pic/bmon/rapidash.pic"
PonytaPicBack:
	INCBIN "pic/monback/ponytab.pic"
RapidashPicBack:
	INCBIN "pic/monback/rapidashb.pic"
RattataPicFront:
	INCBIN "pic/bmon/rattata.pic"
RattataPicBack:
	INCBIN "pic/monback/rattatab.pic"
RaticatePicFront:
	INCBIN "pic/bmon/raticate.pic"
RaticatePicBack:
	INCBIN "pic/monback/raticateb.pic"
NidorinoPicFront:
	INCBIN "pic/bmon/nidorino.pic"
NidorinoPicBack:
	INCBIN "pic/monback/nidorinob.pic"
NidorinaPicFront:
	INCBIN "pic/bmon/nidorina.pic"
NidorinaPicBack:
	INCBIN "pic/monback/nidorinab.pic"
GeodudePicFront:
	INCBIN "pic/bmon/geodude.pic"
GeodudePicBack:
	INCBIN "pic/monback/geodudeb.pic"
PorygonPicFront:
	INCBIN "pic/bmon/porygon.pic"
PorygonPicBack:
	INCBIN "pic/monback/porygonb.pic"
AerodactylPicFront:
	INCBIN "pic/bmon/aerodactyl.pic"
AerodactylPicBack:
	INCBIN "pic/monback/aerodactylb.pic"
MagnemitePicFront:
	INCBIN "pic/bmon/magnemite.pic"
MagnemitePicBack:
	INCBIN "pic/monback/magnemiteb.pic"
CharmanderPicFront:
	INCBIN "pic/bmon/charmander.pic"
CharmanderPicBack:
	INCBIN "pic/monback/charmanderb.pic"
SquirtlePicFront:
	INCBIN "pic/bmon/squirtle.pic"
SquirtlePicBack:
	INCBIN "pic/monback/squirtleb.pic"
CharmeleonPicFront:
	INCBIN "pic/bmon/charmeleon.pic"
CharmeleonPicBack:
	INCBIN "pic/monback/charmeleonb.pic"
WartortlePicFront:
	INCBIN "pic/bmon/wartortle.pic"
WartortlePicBack:
	INCBIN "pic/monback/wartortleb.pic"
CharizardPicFront:
	INCBIN "pic/bmon/charizard.pic"
CharizardPicBack:
	INCBIN "pic/monback/charizardb.pic"
FossilAerodactylPic:
	INCBIN "pic/bmon/fossilaerodactyl.pic"
GhostPic:
	INCBIN "pic/other/ghost.pic"
OddishPicFront:
	INCBIN "pic/bmon/oddish.pic"
OddishPicBack:
	INCBIN "pic/monback/oddishb.pic"
GloomPicFront:
	INCBIN "pic/bmon/gloom.pic"
GloomPicBack:
	INCBIN "pic/monback/gloomb.pic"
VileplumePicFront:
	INCBIN "pic/bmon/vileplume.pic"
VileplumePicBack:
	INCBIN "pic/monback/vileplumeb.pic"
BellsproutPicFront:
	INCBIN "pic/bmon/bellsprout.pic"
BellsproutPicBack:
	INCBIN "pic/monback/bellsproutb.pic"
WeepinbellPicFront:
	INCBIN "pic/bmon/weepinbell.pic"
WeepinbellPicBack:
	INCBIN "pic/monback/weepinbellb.pic"
VictreebelPicFront:
	INCBIN "pic/bmon/victreebel.pic"
VictreebelPicBack:
	INCBIN "pic/monback/victreebelb.pic"

INCBIN "baserom.gbc",$37244,$37390 - $37244

UnnamedText_37390: ; 0x37390
	TX_FAR _UnnamedText_37390
	db $50
; 0x37390 + 5 bytes

INCBIN "baserom.gbc",$37395,$37467 - $37395

UnnamedText_37467: ; 0x37467
	TX_FAR _UnnamedText_37467
	db $50
; 0x37467 + 5 bytes

UnnamedText_3746c: ; 0x3746c
	TX_FAR _UnnamedText_3746c
	db $50
; 0x3746c + 5 bytes

UnnamedText_37471: ; 0x37471
	TX_FAR _UnnamedText_37471
	db $50
; 0x37471 + 5 bytes

UnnamedText_37476: ; 0x37476
	TX_FAR _UnnamedText_37476
	db $50
; 0x37476 + 5 bytes

UnnamedText_3747b: ; 0x3747b
	TX_FAR _UnnamedText_3747b
	db $50
; 0x3747b + 5 bytes

INCBIN "baserom.gbc",$37480,$37673 - $37480

UnnamedText_37673: ; 0x37673
	TX_FAR _UnnamedText_37673
	db $50
; 0x37673 + 5 bytes

INCBIN "baserom.gbc",$37678,$3769d - $37678

UnnamedText_3769d: ; 0x3769d
	TX_FAR _UnnamedText_3769d
	db $50
; 0x3769d + 5 bytes

INCBIN "baserom.gbc",$376a2,$44f

IF _RED
	INCBIN "gfx/red/slotmachine1.2bpp"
ENDC
IF _BLUE
	INCBIN "gfx/blue/slotmachine1.2bpp"
ENDC

INCBIN "baserom.gbc",$37ca1,$37e79 - $37ca1

UnnamedText_37e79: ; 0x37e79
	TX_FAR _UnnamedText_37e79
	db $50
; 0x37e79 + 5 bytes

UnnamedText_37e7e: ; 0x37e7e
	TX_FAR _UnnamedText_37e7e
	db $50
; 0x37e7e + 5 bytes

UnnamedText_37e83: ; 0x37e83
	TX_FAR _UnnamedText_37e83
	db $50
; 0x37e83 + 5 bytes

SECTION "bankE",DATA,BANK[$E]

Moves: ; 4000
; characteristics of each move
; animation, effect, power, type, accuracy, PP
db POUND       ,$00,$28,NORMAL,$FF,35
db KARATE_CHOP ,$00,$32,NORMAL,$FF,25
db DOUBLESLAP  ,$1D,$0F,NORMAL,$D8,10
db COMET_PUNCH ,$1D,$12,NORMAL,$D8,15
db MEGA_PUNCH  ,$00,$50,NORMAL,$D8,20
db PAY_DAY     ,$10,$28,NORMAL,$FF,20
db FIRE_PUNCH  ,$04,$4B,FIRE,$FF,15
db ICE_PUNCH   ,$05,$4B,ICE,$FF,15
db THUNDERPUNCH,$06,$4B,ELECTRIC,$FF,15
db SCRATCH     ,$00,$28,NORMAL,$FF,35
db VICEGRIP    ,$00,$37,NORMAL,$FF,30
db GUILLOTINE  ,$26,$01,NORMAL,$4C,5
db RAZOR_WIND  ,$27,$50,NORMAL,$BF,10
db SWORDS_DANCE,$32,$00,NORMAL,$FF,30
db CUT         ,$00,$32,NORMAL,$F2,30
db GUST        ,$00,$28,NORMAL,$FF,35
db WING_ATTACK ,$00,$23,FLYING,$FF,35
db WHIRLWIND   ,$1C,$00,NORMAL,$D8,20
db FLY         ,$2B,$46,FLYING,$F2,15
db BIND        ,$2A,$0F,NORMAL,$BF,20
db SLAM        ,$00,$50,NORMAL,$BF,20
db VINE_WHIP   ,$00,$23,GRASS,$FF,10
db STOMP       ,$25,$41,NORMAL,$FF,20
db DOUBLE_KICK ,$2C,$1E,FIGHTING,$FF,30
db MEGA_KICK   ,$00,$78,NORMAL,$BF,5
db JUMP_KICK   ,$2D,$46,FIGHTING,$F2,25
db ROLLING_KICK,$25,$3C,FIGHTING,$D8,15
db SAND_ATTACK ,$16,$00,NORMAL,$FF,15
db HEADBUTT    ,$25,$46,NORMAL,$FF,15
db HORN_ATTACK ,$00,$41,NORMAL,$FF,25
db FURY_ATTACK ,$1D,$0F,NORMAL,$D8,20
db HORN_DRILL  ,$26,$01,NORMAL,$4C,5
db TACKLE      ,$00,$23,NORMAL,$F2,35
db BODY_SLAM   ,$24,$55,NORMAL,$FF,15
db WRAP        ,$2A,$0F,NORMAL,$D8,20
db TAKE_DOWN   ,$30,$5A,NORMAL,$D8,20
db THRASH      ,$1B,$5A,NORMAL,$FF,20
db DOUBLE_EDGE ,$30,$64,NORMAL,$FF,15
db TAIL_WHIP   ,$13,$00,NORMAL,$FF,30
db POISON_STING,$02,$0F,POISON,$FF,35
db TWINEEDLE   ,$4D,$19,BUG,$FF,20
db PIN_MISSILE ,$1D,$0E,BUG,$D8,20
db LEER        ,$13,$00,NORMAL,$FF,30
db BITE        ,$1F,$3C,NORMAL,$FF,25
db GROWL       ,$12,$00,NORMAL,$FF,40
db ROAR        ,$1C,$00,NORMAL,$FF,20
db SING        ,$20,$00,NORMAL,$8C,15
db SUPERSONIC  ,$31,$00,NORMAL,$8C,20
db SONICBOOM   ,$29,$01,NORMAL,$E5,20
db DISABLE     ,$56,$00,NORMAL,$8C,20
db ACID        ,$45,$28,POISON,$FF,30
db EMBER       ,$04,$28,FIRE,$FF,25
db FLAMETHROWER,$04,$5F,FIRE,$FF,15
db MIST        ,$2E,$00,ICE,$FF,30
db WATER_GUN   ,$00,$28,WATER,$FF,25
db HYDRO_PUMP  ,$00,$78,WATER,$CC,5
db SURF        ,$00,$5F,WATER,$FF,15
db ICE_BEAM    ,$05,$5F,ICE,$FF,10
db BLIZZARD    ,$05,$78,ICE,$E5,5
db PSYBEAM     ,$4C,$41,PSYCHIC,$FF,20
db BUBBLEBEAM  ,$46,$41,WATER,$FF,20
db AURORA_BEAM ,$44,$41,ICE,$FF,20
db HYPER_BEAM  ,$50,$96,NORMAL,$E5,5
db PECK        ,$00,$23,FLYING,$FF,35
db DRILL_PECK  ,$00,$50,FLYING,$FF,20
db SUBMISSION  ,$30,$50,FIGHTING,$CC,25
db LOW_KICK    ,$25,$32,FIGHTING,$E5,20
db COUNTER     ,$00,$01,FIGHTING,$FF,20
db SEISMIC_TOSS,$29,$01,FIGHTING,$FF,20
db STRENGTH    ,$00,$50,NORMAL,$FF,15
db ABSORB      ,$03,$14,GRASS,$FF,20
db MEGA_DRAIN  ,$03,$28,GRASS,$FF,10
db LEECH_SEED  ,$54,$00,GRASS,$E5,10
db GROWTH      ,$0D,$00,NORMAL,$FF,40
db RAZOR_LEAF  ,$00,$37,GRASS,$F2,25
db SOLARBEAM   ,$27,$78,GRASS,$FF,10
db POISONPOWDER,$42,$00,POISON,$BF,35
db STUN_SPORE  ,$43,$00,GRASS,$BF,30
db SLEEP_POWDER,$20,$00,GRASS,$BF,15
db PETAL_DANCE ,$1B,$46,GRASS,$FF,20
db STRING_SHOT ,$14,$00,BUG,$F2,40
db DRAGON_RAGE ,$29,$01,DRAGON,$FF,10
db FIRE_SPIN   ,$2A,$0F,FIRE,$B2,15
db THUNDERSHOCK,$06,$28,ELECTRIC,$FF,30
db THUNDERBOLT ,$06,$5F,ELECTRIC,$FF,15
db THUNDER_WAVE,$43,$00,ELECTRIC,$FF,20
db THUNDER     ,$06,$78,ELECTRIC,$B2,10
db ROCK_THROW  ,$00,$32,ROCK,$A5,15
db EARTHQUAKE  ,$00,$64,GROUND,$FF,10
db FISSURE     ,$26,$01,GROUND,$4C,5
db DIG         ,$27,$64,GROUND,$FF,10
db TOXIC       ,$42,$00,POISON,$D8,10
db CONFUSION   ,$4C,$32,PSYCHIC,$FF,25
db PSYCHIC_M   ,$47,$5A,PSYCHIC,$FF,10
db HYPNOSIS    ,$20,$00,PSYCHIC,$99,20
db MEDITATE    ,$0A,$00,PSYCHIC,$FF,40
db AGILITY     ,$34,$00,PSYCHIC,$FF,30
db QUICK_ATTACK,$00,$28,NORMAL,$FF,30
db RAGE        ,$51,$14,NORMAL,$FF,20
db TELEPORT    ,$1C,$00,PSYCHIC,$FF,20
db NIGHT_SHADE ,$29,$00,GHOST,$FF,15
db MIMIC       ,$52,$00,NORMAL,$FF,10
db SCREECH     ,$3B,$00,NORMAL,$D8,40
db DOUBLE_TEAM ,$0F,$00,NORMAL,$FF,15
db RECOVER     ,$38,$00,NORMAL,$FF,20
db HARDEN      ,$0B,$00,NORMAL,$FF,30
db MINIMIZE    ,$0F,$00,NORMAL,$FF,20
db SMOKESCREEN ,$16,$00,NORMAL,$FF,20
db CONFUSE_RAY ,$31,$00,GHOST,$FF,10
db WITHDRAW    ,$0B,$00,WATER,$FF,40
db DEFENSE_CURL,$0B,$00,NORMAL,$FF,40
db BARRIER     ,$33,$00,PSYCHIC,$FF,30
db LIGHT_SCREEN,$40,$00,PSYCHIC,$FF,30
db HAZE        ,$19,$00,ICE,$FF,30
db REFLECT     ,$41,$00,PSYCHIC,$FF,20
db FOCUS_ENERGY,$2F,$00,NORMAL,$FF,30
db BIDE        ,$1A,$00,NORMAL,$FF,10
db METRONOME   ,$53,$00,NORMAL,$FF,10
db MIRROR_MOVE ,$09,$00,FLYING,$FF,20
db SELFDESTRUCT,$07,$82,NORMAL,$FF,5
db EGG_BOMB    ,$00,$64,NORMAL,$BF,10
db LICK        ,$24,$14,GHOST,$FF,30
db SMOG        ,$21,$14,POISON,$B2,20
db SLUDGE      ,$21,$41,POISON,$FF,20
db BONE_CLUB   ,$1F,$41,GROUND,$D8,20
db FIRE_BLAST  ,$22,$78,FIRE,$D8,5
db WATERFALL   ,$00,$50,WATER,$FF,15
db CLAMP       ,$2A,$23,WATER,$BF,10
db SWIFT       ,$11,$3C,NORMAL,$FF,20
db SKULL_BASH  ,$27,$64,NORMAL,$FF,15
db SPIKE_CANNON,$1D,$14,NORMAL,$FF,15
db CONSTRICT   ,$46,$0A,NORMAL,$FF,35
db AMNESIA     ,$35,$00,PSYCHIC,$FF,20
db KINESIS     ,$16,$00,PSYCHIC,$CC,15
db SOFTBOILED  ,$38,$00,NORMAL,$FF,10
db HI_JUMP_KICK,$2D,$55,FIGHTING,$E5,20
db GLARE       ,$43,$00,NORMAL,$BF,30
db DREAM_EATER ,$08,$64,PSYCHIC,$FF,15
db POISON_GAS  ,$42,$00,POISON,$8C,40
db BARRAGE     ,$1D,$0F,NORMAL,$D8,20
db LEECH_LIFE  ,$03,$14,BUG,$FF,15
db LOVELY_KISS ,$20,$00,NORMAL,$BF,10
db SKY_ATTACK  ,$27,$8C,FLYING,$E5,5
db TRANSFORM   ,$39,$00,NORMAL,$FF,10
db BUBBLE      ,$46,$14,WATER,$FF,30
db DIZZY_PUNCH ,$00,$46,NORMAL,$FF,10
db SPORE       ,$20,$00,GRASS,$FF,15
db FLASH       ,$16,$00,NORMAL,$B2,20
db PSYWAVE     ,$29,$01,PSYCHIC,$CC,15
db SPLASH      ,$55,$00,NORMAL,$FF,40
db ACID_ARMOR  ,$33,$00,POISON,$FF,40
db CRABHAMMER  ,$00,$5A,WATER,$D8,10
db EXPLOSION   ,$07,$AA,NORMAL,$FF,5
db FURY_SWIPES ,$1D,$12,NORMAL,$CC,15
db BONEMERANG  ,$2C,$32,GROUND,$E5,10
db REST        ,$38,$00,PSYCHIC,$FF,10
db ROCK_SLIDE  ,$00,$4B,ROCK,$E5,10
db HYPER_FANG  ,$1F,$50,NORMAL,$E5,15
db SHARPEN     ,$0A,$00,NORMAL,$FF,30
db CONVERSION  ,$18,$00,NORMAL,$FF,30
db TRI_ATTACK  ,$00,$50,NORMAL,$FF,10
db SUPER_FANG  ,$28,$01,NORMAL,$E5,10
db SLASH       ,$00,$46,NORMAL,$FF,20
db SUBSTITUTE  ,$4F,$00,NORMAL,$FF,10
db STRUGGLE    ,$30,$32,NORMAL,$FF,10

BulbasaurBaseStats: ; 0x383de
	db DEX_BULBASAUR ; pokedex id
	db 45 ; base hp
	db 49 ; base attack
	db 49 ; base defense
	db 45 ; base speed
	db 65 ; base special

	db GRASS ; species type 1
	db POISON ; species type 2

	db 45 ; catch rate
	db 64 ; base exp yield
	db $55 ; sprite dimensions

	dw BulbasaurPicFront
	dw BulbasaurPicBack
	
	; attacks known at lvl 0
	db TACKLE
	db GROWL
	db 0
	db 0

	db 3 ; growth rate
	
	; learnset
	db %10100100
	db %11
	db %111000
	db %11000000
	db %11
	db %1000
	db %110

	db 0 ; padding

IvysaurBaseStats: ; 0x383fa
	db DEX_IVYSAUR ; pokedex id
	db 60 ; base hp
	db 62 ; base attack
	db 63 ; base defense
	db 60 ; base speed
	db 80 ; base special

	db GRASS ; species type 1
	db POISON ; species type 2

	db 45 ; catch rate
	db 141 ; base exp yield
	db $66 ; sprite dimensions

	dw IvysaurPicFront
	dw IvysaurPicBack
	
	; attacks known at lvl 0
	db TACKLE
	db GROWL
	db LEECH_SEED
	db 0

	db 3 ; growth rate
	
	; learnset
	db %10100100
	db %11
	db %111000
	db %11000000
	db %11
	db %1000
	db %110

	db 0 ; padding

VenusaurBaseStats: ; 0x38416
	db DEX_VENUSAUR ; pokedex id
	db 80 ; base hp
	db 82 ; base attack
	db 83 ; base defense
	db 80 ; base speed
	db 100 ; base special

	db GRASS ; species type 1
	db POISON ; species type 2

	db 45 ; catch rate
	db 208 ; base exp yield
	db $77 ; sprite dimensions

	dw VenusaurPicFront
	dw VenusaurPicBack
	
	; attacks known at lvl 0
	db TACKLE
	db GROWL
	db LEECH_SEED
	db VINE_WHIP

	db 3 ; growth rate
	
	; learnset
	db %10100100
	db %1000011
	db %111000
	db %11000000
	db %11
	db %1000
	db %110

	db 0 ; padding

CharmanderBaseStats: ; 0x38432
	db DEX_CHARMANDER ; pokedex id
	db 39 ; base hp
	db 52 ; base attack
	db 43 ; base defense
	db 65 ; base speed
	db 50 ; base special

	db FIRE ; species type 1
	db FIRE ; species type 2

	db 45 ; catch rate
	db 65 ; base exp yield
	db $55 ; sprite dimensions

	dw CharmanderPicFront
	dw CharmanderPicBack
	
	; attacks known at lvl 0
	db SCRATCH
	db GROWL
	db 0
	db 0

	db 3 ; growth rate
	
	; learnset
	db %10110101
	db %11
	db %1001111
	db %11001000
	db %11100011
	db %1000
	db %100110

	db 0 ; padding

CharmeleonBaseStats: ; 0x3844e
	db DEX_CHARMELEON ; pokedex id
	db 58 ; base hp
	db 64 ; base attack
	db 58 ; base defense
	db 80 ; base speed
	db 65 ; base special

	db FIRE ; species type 1
	db FIRE ; species type 2

	db 45 ; catch rate
	db 142 ; base exp yield
	db $66 ; sprite dimensions

	dw CharmeleonPicFront
	dw CharmeleonPicBack
	
	; attacks known at lvl 0
	db SCRATCH
	db GROWL
	db EMBER
	db 0

	db 3 ; growth rate
	
	; learnset
	db %10110101
	db %11
	db %1001111
	db %11001000
	db %11100011
	db %1000
	db %100110

	db 0 ; padding

CharizardBaseStats: ; 0x3846a
	db DEX_CHARIZARD ; pokedex id
	db 78 ; base hp
	db 84 ; base attack
	db 78 ; base defense
	db 100 ; base speed
	db 85 ; base special

	db FIRE ; species type 1
	db FLYING ; species type 2

	db 45 ; catch rate
	db 209 ; base exp yield
	db $77 ; sprite dimensions

	dw CharizardPicFront
	dw CharizardPicBack
	
	; attacks known at lvl 0
	db SCRATCH
	db GROWL
	db EMBER
	db LEER

	db 3 ; growth rate
	
	; learnset
	db %10110101
	db %1000011
	db %1001111
	db %11001110
	db %11100011
	db %1000
	db %100110

	db 0 ; padding

SquirtleBaseStats: ; 0x38486
	db DEX_SQUIRTLE ; pokedex id
	db 44 ; base hp
	db 48 ; base attack
	db 65 ; base defense
	db 43 ; base speed
	db 50 ; base special

	db WATER ; species type 1
	db WATER ; species type 2

	db 45 ; catch rate
	db 66 ; base exp yield
	db $55 ; sprite dimensions

	dw SquirtlePicFront
	dw SquirtlePicBack
	
	; attacks known at lvl 0
	db TACKLE
	db TAIL_WHIP
	db 0
	db 0

	db 3 ; growth rate
	
	; learnset
	db %10110001
	db %111111
	db %1111
	db %11001000
	db %10000011
	db %1000
	db %110010

	db 0 ; padding

WartortleBaseStats: ; 0x384a2
	db DEX_WARTORTLE ; pokedex id
	db 59 ; base hp
	db 63 ; base attack
	db 80 ; base defense
	db 58 ; base speed
	db 65 ; base special

	db WATER ; species type 1
	db WATER ; species type 2

	db 45 ; catch rate
	db 143 ; base exp yield
	db $66 ; sprite dimensions

	dw WartortlePicFront
	dw WartortlePicBack
	
	; attacks known at lvl 0
	db TACKLE
	db TAIL_WHIP
	db BUBBLE
	db 0

	db 3 ; growth rate
	
	; learnset
	db %10110001
	db %111111
	db %1111
	db %11001000
	db %10000011
	db %1000
	db %110010

	db 0 ; padding

BlastoiseBaseStats: ; 0x384be
	db DEX_BLASTOISE ; pokedex id
	db 79 ; base hp
	db 83 ; base attack
	db 100 ; base defense
	db 78 ; base speed
	db 85 ; base special

	db WATER ; species type 1
	db WATER ; species type 2

	db 45 ; catch rate
	db 210 ; base exp yield
	db $77 ; sprite dimensions

	dw BlastoisePicFront
	dw BlastoisePicBack
	
	; attacks known at lvl 0
	db TACKLE
	db TAIL_WHIP
	db BUBBLE
	db WATER_GUN

	db 3 ; growth rate
	
	; learnset
	db %10110001
	db %1111111
	db %1111
	db %11001110
	db %10000011
	db %1000
	db %110010

	db 0 ; padding

CaterpieBaseStats: ; 0x384da
	db DEX_CATERPIE ; pokedex id
	db 45 ; base hp
	db 30 ; base attack
	db 35 ; base defense
	db 45 ; base speed
	db 20 ; base special

	db BUG ; species type 1
	db BUG ; species type 2

	db 255 ; catch rate
	db 53 ; base exp yield
	db $55 ; sprite dimensions

	dw CaterpiePicFront
	dw CaterpiePicBack
	
	; attacks known at lvl 0
	db TACKLE
	db STRING_SHOT
	db 0
	db 0

	db 0 ; growth rate
	
	; learnset
	db %0
	db %0
	db %0
	db %0
	db %0
	db %0
	db %0

	db 0 ; padding

MetapodBaseStats: ; 0x384f6
	db DEX_METAPOD ; pokedex id
	db 50 ; base hp
	db 20 ; base attack
	db 55 ; base defense
	db 30 ; base speed
	db 25 ; base special

	db BUG ; species type 1
	db BUG ; species type 2

	db 120 ; catch rate
	db 72 ; base exp yield
	db $55 ; sprite dimensions

	dw MetapodPicFront
	dw MetapodPicBack
	
	; attacks known at lvl 0
	db HARDEN
	db 0
	db 0
	db 0

	db 0 ; growth rate
	
	; learnset
	db %0
	db %0
	db %0
	db %0
	db %0
	db %0
	db %0

	db 0 ; padding

ButterfreeBaseStats: ; 0x38512
	db DEX_BUTTERFREE ; pokedex id
	db 60 ; base hp
	db 45 ; base attack
	db 50 ; base defense
	db 70 ; base speed
	db 80 ; base special

	db BUG ; species type 1
	db FLYING ; species type 2

	db 45 ; catch rate
	db 160 ; base exp yield
	db $77 ; sprite dimensions

	dw ButterfreePicFront
	dw ButterfreePicBack
	
	; attacks known at lvl 0
	db CONFUSION
	db 0
	db 0
	db 0

	db 0 ; growth rate
	
	; learnset
	db %101010
	db %1000011
	db %111000
	db %11110000
	db %1000011
	db %101000
	db %10

	db 0 ; padding

WeedleBaseStats: ; 0x3852e
	db DEX_WEEDLE ; pokedex id
	db 40 ; base hp
	db 35 ; base attack
	db 30 ; base defense
	db 50 ; base speed
	db 20 ; base special

	db BUG ; species type 1
	db POISON ; species type 2

	db 255 ; catch rate
	db 52 ; base exp yield
	db $55 ; sprite dimensions

	dw WeedlePicFront
	dw WeedlePicBack
	
	; attacks known at lvl 0
	db POISON_STING
	db STRING_SHOT
	db 0
	db 0

	db 0 ; growth rate
	
	; learnset
	db %0
	db %0
	db %0
	db %0
	db %0
	db %0
	db %0

	db 0 ; padding

KakunaBaseStats: ; 0x3854a
	db DEX_KAKUNA ; pokedex id
	db 45 ; base hp
	db 25 ; base attack
	db 50 ; base defense
	db 35 ; base speed
	db 25 ; base special

	db BUG ; species type 1
	db POISON ; species type 2

	db 120 ; catch rate
	db 71 ; base exp yield
	db $55 ; sprite dimensions

	dw KakunaPicFront
	dw KakunaPicBack
	
	; attacks known at lvl 0
	db HARDEN
	db 0
	db 0
	db 0

	db 0 ; growth rate
	
	; learnset
	db %0
	db %0
	db %0
	db %0
	db %0
	db %0
	db %0

	db 0 ; padding

BeedrillBaseStats: ; 0x38566
	db DEX_BEEDRILL ; pokedex id
	db 65 ; base hp
	db 80 ; base attack
	db 40 ; base defense
	db 75 ; base speed
	db 45 ; base special

	db BUG ; species type 1
	db POISON ; species type 2

	db 45 ; catch rate
	db 159 ; base exp yield
	db $77 ; sprite dimensions

	dw BeedrillPicFront
	dw BeedrillPicBack
	
	; attacks known at lvl 0
	db FURY_ATTACK
	db 0
	db 0
	db 0

	db 0 ; growth rate
	
	; learnset
	db %100100
	db %1000011
	db %11000
	db %11000000
	db %11000011
	db %1000
	db %110

	db 0 ; padding

PidgeyBaseStats: ; 0x38582
	db DEX_PIDGEY ; pokedex id
	db 40 ; base hp
	db 45 ; base attack
	db 40 ; base defense
	db 56 ; base speed
	db 35 ; base special

	db NORMAL ; species type 1
	db FLYING ; species type 2

	db 255 ; catch rate
	db 55 ; base exp yield
	db $55 ; sprite dimensions

	dw PidgeyPicFront
	dw PidgeyPicBack
	
	; attacks known at lvl 0
	db GUST
	db 0
	db 0
	db 0

	db 3 ; growth rate
	
	; learnset
	db %101010
	db %11
	db %1000
	db %11000000
	db %1000011
	db %1100
	db %1010

	db 0 ; padding

PidgeottoBaseStats: ; 0x3859e
	db DEX_PIDGEOTTO ; pokedex id
	db 63 ; base hp
	db 60 ; base attack
	db 55 ; base defense
	db 71 ; base speed
	db 50 ; base special

	db NORMAL ; species type 1
	db FLYING ; species type 2

	db 120 ; catch rate
	db 113 ; base exp yield
	db $66 ; sprite dimensions

	dw PidgeottoPicFront
	dw PidgeottoPicBack
	
	; attacks known at lvl 0
	db GUST
	db SAND_ATTACK
	db 0
	db 0

	db 3 ; growth rate
	
	; learnset
	db %101010
	db %11
	db %1000
	db %11000000
	db %1000011
	db %1100
	db %1010

	db 0 ; padding

PidgeotBaseStats: ; 0x385ba
	db DEX_PIDGEOT ; pokedex id
	db 83 ; base hp
	db 80 ; base attack
	db 75 ; base defense
	db 91 ; base speed
	db 70 ; base special

	db NORMAL ; species type 1
	db FLYING ; species type 2

	db 45 ; catch rate
	db 172 ; base exp yield
	db $77 ; sprite dimensions

	dw PidgeotPicFront
	dw PidgeotPicBack
	
	; attacks known at lvl 0
	db GUST
	db SAND_ATTACK
	db QUICK_ATTACK
	db 0

	db 3 ; growth rate
	
	; learnset
	db %101010
	db %1000011
	db %1000
	db %11000000
	db %1000011
	db %1100
	db %1010

	db 0 ; padding

RattataBaseStats: ; 0x385d6
	db DEX_RATTATA ; pokedex id
	db 30 ; base hp
	db 56 ; base attack
	db 35 ; base defense
	db 72 ; base speed
	db 25 ; base special

	db NORMAL ; species type 1
	db NORMAL ; species type 2

	db 255 ; catch rate
	db 57 ; base exp yield
	db $55 ; sprite dimensions

	dw RattataPicFront
	dw RattataPicBack
	
	; attacks known at lvl 0
	db TACKLE
	db TAIL_WHIP
	db 0
	db 0

	db 0 ; growth rate
	
	; learnset
	db %10100000
	db %101111
	db %10001000
	db %11001001
	db %11000010
	db %1000
	db %10

	db 0 ; padding

RaticateBaseStats: ; 0x385f2
	db DEX_RATICATE ; pokedex id
	db 55 ; base hp
	db 81 ; base attack
	db 60 ; base defense
	db 97 ; base speed
	db 50 ; base special

	db NORMAL ; species type 1
	db NORMAL ; species type 2

	db 90 ; catch rate
	db 116 ; base exp yield
	db $66 ; sprite dimensions

	dw RaticatePicFront
	dw RaticatePicBack
	
	; attacks known at lvl 0
	db TACKLE
	db TAIL_WHIP
	db QUICK_ATTACK
	db 0

	db 0 ; growth rate
	
	; learnset
	db %10100000
	db %1111111
	db %10001000
	db %11001001
	db %11000010
	db %1000
	db %10

	db 0 ; padding

SpearowBaseStats: ; 0x3860e
	db DEX_SPEAROW ; pokedex id
	db 40 ; base hp
	db 60 ; base attack
	db 30 ; base defense
	db 70 ; base speed
	db 31 ; base special

	db NORMAL ; species type 1
	db FLYING ; species type 2

	db 255 ; catch rate
	db 58 ; base exp yield
	db $55 ; sprite dimensions

	dw SpearowPicFront
	dw SpearowPicBack
	
	; attacks known at lvl 0
	db PECK
	db GROWL
	db 0
	db 0

	db 0 ; growth rate
	
	; learnset
	db %101010
	db %11
	db %1000
	db %11000000
	db %1000010
	db %1100
	db %1010

	db 0 ; padding

FearowBaseStats: ; 0x3862a
	db DEX_FEAROW ; pokedex id
	db 65 ; base hp
	db 90 ; base attack
	db 65 ; base defense
	db 100 ; base speed
	db 61 ; base special

	db NORMAL ; species type 1
	db FLYING ; species type 2

	db 90 ; catch rate
	db 162 ; base exp yield
	db $77 ; sprite dimensions

	dw FearowPicFront
	dw FearowPicBack
	
	; attacks known at lvl 0
	db PECK
	db GROWL
	db LEER
	db 0

	db 0 ; growth rate
	
	; learnset
	db %101010
	db %1000011
	db %1000
	db %11000000
	db %1000010
	db %1100
	db %1010

	db 0 ; padding

EkansBaseStats: ; 0x38646
	db DEX_EKANS ; pokedex id
	db 35 ; base hp
	db 60 ; base attack
	db 44 ; base defense
	db 55 ; base speed
	db 40 ; base special

	db POISON ; species type 1
	db POISON ; species type 2

	db 255 ; catch rate
	db 62 ; base exp yield
	db $55 ; sprite dimensions

	dw EkansPicFront
	dw EkansPicBack
	
	; attacks known at lvl 0
	db WRAP
	db LEER
	db 0
	db 0

	db 0 ; growth rate
	
	; learnset
	db %10100000
	db %11
	db %11000
	db %11001110
	db %10000010
	db %10001000
	db %100010

	db 0 ; padding

ArbokBaseStats: ; 0x38662
	db DEX_ARBOK ; pokedex id
	db 60 ; base hp
	db 85 ; base attack
	db 69 ; base defense
	db 80 ; base speed
	db 65 ; base special

	db POISON ; species type 1
	db POISON ; species type 2

	db 90 ; catch rate
	db 147 ; base exp yield
	db $77 ; sprite dimensions

	dw ArbokPicFront
	dw ArbokPicBack
	
	; attacks known at lvl 0
	db WRAP
	db LEER
	db POISON_STING
	db 0

	db 0 ; growth rate
	
	; learnset
	db %10100000
	db %1000011
	db %11000
	db %11001110
	db %10000010
	db %10001000
	db %100010

	db 0 ; padding

PikachuBaseStats: ; 0x3867e
	db DEX_PIKACHU ; pokedex id
	db 35 ; base hp
	db 55 ; base attack
	db 30 ; base defense
	db 90 ; base speed
	db 50 ; base special

	db ELECTRIC ; species type 1
	db ELECTRIC ; species type 2

	db 190 ; catch rate
	db 82 ; base exp yield
	db $55 ; sprite dimensions

	dw PikachuPicFront
	dw PikachuPicBack
	
	; attacks known at lvl 0
	db THUNDERSHOCK
	db GROWL
	db 0
	db 0

	db 0 ; growth rate
	
	; learnset
	db %10110001
	db %10000011
	db %10001101
	db %11000001
	db %11000011
	db %11000
	db %1000010

	db 0 ; padding

RaichuBaseStats: ; 0x3869a
	db DEX_RAICHU ; pokedex id
	db 60 ; base hp
	db 90 ; base attack
	db 55 ; base defense
	db 100 ; base speed
	db 90 ; base special

	db ELECTRIC ; species type 1
	db ELECTRIC ; species type 2

	db 75 ; catch rate
	db 122 ; base exp yield
	db $77 ; sprite dimensions

	dw RaichuPicFront
	dw RaichuPicBack
	
	; attacks known at lvl 0
	db THUNDERSHOCK
	db GROWL
	db THUNDER_WAVE
	db 0

	db 0 ; growth rate
	
	; learnset
	db %10110001
	db %11000011
	db %10001101
	db %11000001
	db %11000011
	db %11000
	db %1000010

	db 0 ; padding

SandshrewBaseStats: ; 0x386b6
	db DEX_SANDSHREW ; pokedex id
	db 50 ; base hp
	db 75 ; base attack
	db 85 ; base defense
	db 40 ; base speed
	db 30 ; base special

	db GROUND ; species type 1
	db GROUND ; species type 2

	db 255 ; catch rate
	db 93 ; base exp yield
	db $55 ; sprite dimensions

	dw SandshrewPicFront
	dw SandshrewPicBack
	
	; attacks known at lvl 0
	db SCRATCH
	db 0
	db 0
	db 0

	db 0 ; growth rate
	
	; learnset
	db %10100100
	db %11
	db %1101
	db %11001110
	db %11000010
	db %10001000
	db %100110

	db 0 ; padding

SandslashBaseStats: ; 0x386d2
	db DEX_SANDSLASH ; pokedex id
	db 75 ; base hp
	db 100 ; base attack
	db 110 ; base defense
	db 65 ; base speed
	db 55 ; base special

	db GROUND ; species type 1
	db GROUND ; species type 2

	db 90 ; catch rate
	db 163 ; base exp yield
	db $66 ; sprite dimensions

	dw SandslashPicFront
	dw SandslashPicBack
	
	; attacks known at lvl 0
	db SCRATCH
	db SAND_ATTACK
	db 0
	db 0

	db 0 ; growth rate
	
	; learnset
	db %10100100
	db %1000011
	db %1101
	db %11001110
	db %11000010
	db %10001000
	db %100110

	db 0 ; padding

NidoranFBaseStats: ; 0x386ee
	db DEX_NIDORAN_F ; pokedex id
	db 55 ; base hp
	db 47 ; base attack
	db 52 ; base defense
	db 41 ; base speed
	db 40 ; base special

	db POISON ; species type 1
	db POISON ; species type 2

	db 235 ; catch rate
	db 59 ; base exp yield
	db $55 ; sprite dimensions

	dw NidoranFPicFront
	dw NidoranFPicBack
	
	; attacks known at lvl 0
	db GROWL
	db TACKLE
	db 0
	db 0

	db 3 ; growth rate
	
	; learnset
	db %10100000
	db %100011
	db %10001000
	db %11000001
	db %10000011
	db %1000
	db %10

	db 0 ; padding

NidorinaBaseStats: ; 0x3870a
	db DEX_NIDORINA ; pokedex id
	db 70 ; base hp
	db 62 ; base attack
	db 67 ; base defense
	db 56 ; base speed
	db 55 ; base special

	db POISON ; species type 1
	db POISON ; species type 2

	db 120 ; catch rate
	db 117 ; base exp yield
	db $66 ; sprite dimensions

	dw NidorinaPicFront
	dw NidorinaPicBack
	
	; attacks known at lvl 0
	db GROWL
	db TACKLE
	db SCRATCH
	db 0

	db 3 ; growth rate
	
	; learnset
	db %11100000
	db %111111
	db %10001000
	db %11000001
	db %10000011
	db %1000
	db %10

	db 0 ; padding

NidoqueenBaseStats: ; 0x38726
	db DEX_NIDOQUEEN ; pokedex id
	db 90 ; base hp
	db 82 ; base attack
	db 87 ; base defense
	db 76 ; base speed
	db 75 ; base special

	db POISON ; species type 1
	db GROUND ; species type 2

	db 45 ; catch rate
	db 194 ; base exp yield
	db $77 ; sprite dimensions

	dw NidoqueenPicFront
	dw NidoqueenPicBack
	
	; attacks known at lvl 0
	db TACKLE
	db SCRATCH
	db TAIL_WHIP
	db BODY_SLAM

	db 3 ; growth rate
	
	; learnset
	db %11110001
	db %11111111
	db %10001111
	db %11000111
	db %10100011
	db %10001000
	db %110010

	db 0 ; padding

NidoranMBaseStats: ; 0x38742
	db DEX_NIDORAN_M ; pokedex id
	db 46 ; base hp
	db 57 ; base attack
	db 40 ; base defense
	db 50 ; base speed
	db 40 ; base special

	db POISON ; species type 1
	db POISON ; species type 2

	db 235 ; catch rate
	db 60 ; base exp yield
	db $55 ; sprite dimensions

	dw NidoranMPicFront
	dw NidoranMPicBack
	
	; attacks known at lvl 0
	db LEER
	db TACKLE
	db 0
	db 0

	db 3 ; growth rate
	
	; learnset
	db %11100000
	db %100011
	db %10001000
	db %11000001
	db %10000011
	db %1000
	db %10

	db 0 ; padding

NidorinoBaseStats: ; 0x3875e
	db DEX_NIDORINO ; pokedex id
	db 61 ; base hp
	db 72 ; base attack
	db 57 ; base defense
	db 65 ; base speed
	db 55 ; base special

	db POISON ; species type 1
	db POISON ; species type 2

	db 120 ; catch rate
	db 118 ; base exp yield
	db $66 ; sprite dimensions

	dw NidorinoPicFront
	dw NidorinoPicBack
	
	; attacks known at lvl 0
	db LEER
	db TACKLE
	db HORN_ATTACK
	db 0

	db 3 ; growth rate
	
	; learnset
	db %11100000
	db %111111
	db %10001000
	db %11000001
	db %10000011
	db %1000
	db %10

	db 0 ; padding

NidokingBaseStats: ; 0x3877a
	db DEX_NIDOKING ; pokedex id
	db 81 ; base hp
	db 92 ; base attack
	db 77 ; base defense
	db 85 ; base speed
	db 75 ; base special

	db POISON ; species type 1
	db GROUND ; species type 2

	db 45 ; catch rate
	db 195 ; base exp yield
	db $77 ; sprite dimensions

	dw NidokingPicFront
	dw NidokingPicBack
	
	; attacks known at lvl 0
	db TACKLE
	db HORN_ATTACK
	db POISON_STING
	db THRASH

	db 3 ; growth rate
	
	; learnset
	db %11110001
	db %11111111
	db %10001111
	db %11000111
	db %10100011
	db %10001000
	db %110010

	db 0 ; padding

ClefairyBaseStats: ; 0x38796
	db DEX_CLEFAIRY ; pokedex id
	db 70 ; base hp
	db 45 ; base attack
	db 48 ; base defense
	db 35 ; base speed
	db 60 ; base special

	db NORMAL ; species type 1
	db NORMAL ; species type 2

	db 150 ; catch rate
	db 68 ; base exp yield
	db $55 ; sprite dimensions

	dw ClefairyPicFront
	dw ClefairyPicBack
	
	; attacks known at lvl 0
	db POUND
	db GROWL
	db 0
	db 0

	db 4 ; growth rate
	
	; learnset
	db %10110001
	db %111111
	db %10101111
	db %11110001
	db %10100111
	db %111000
	db %1100011

	db 0 ; padding

ClefableBaseStats: ; 0x387b2
	db DEX_CLEFABLE ; pokedex id
	db 95 ; base hp
	db 70 ; base attack
	db 73 ; base defense
	db 60 ; base speed
	db 85 ; base special

	db NORMAL ; species type 1
	db NORMAL ; species type 2

	db 25 ; catch rate
	db 129 ; base exp yield
	db $66 ; sprite dimensions

	dw ClefablePicFront
	dw ClefablePicBack
	
	; attacks known at lvl 0
	db SING
	db DOUBLESLAP
	db MINIMIZE
	db METRONOME

	db 4 ; growth rate
	
	; learnset
	db %10110001
	db %1111111
	db %10101111
	db %11110001
	db %10100111
	db %111000
	db %1100011

	db 0 ; padding

VulpixBaseStats: ; 0x387ce
	db DEX_VULPIX ; pokedex id
	db 38 ; base hp
	db 41 ; base attack
	db 40 ; base defense
	db 65 ; base speed
	db 65 ; base special

	db FIRE ; species type 1
	db FIRE ; species type 2

	db 190 ; catch rate
	db 63 ; base exp yield
	db $66 ; sprite dimensions

	dw VulpixPicFront
	dw VulpixPicBack
	
	; attacks known at lvl 0
	db EMBER
	db TAIL_WHIP
	db 0
	db 0

	db 0 ; growth rate
	
	; learnset
	db %10100000
	db %11
	db %1000
	db %11001000
	db %11100011
	db %1000
	db %10

	db 0 ; padding

NinetalesBaseStats: ; 0x387ea
	db DEX_NINETALES ; pokedex id
	db 73 ; base hp
	db 76 ; base attack
	db 75 ; base defense
	db 100 ; base speed
	db 100 ; base special

	db FIRE ; species type 1
	db FIRE ; species type 2

	db 75 ; catch rate
	db 178 ; base exp yield
	db $77 ; sprite dimensions

	dw NinetalesPicFront
	dw NinetalesPicBack
	
	; attacks known at lvl 0
	db EMBER
	db TAIL_WHIP
	db QUICK_ATTACK
	db ROAR

	db 0 ; growth rate
	
	; learnset
	db %10100000
	db %1000011
	db %1000
	db %11001000
	db %11100011
	db %1000
	db %10

	db 0 ; padding

JigglypuffBaseStats: ; 0x38806
	db DEX_JIGGLYPUFF ; pokedex id
	db 115 ; base hp
	db 45 ; base attack
	db 20 ; base defense
	db 20 ; base speed
	db 25 ; base special

	db NORMAL ; species type 1
	db NORMAL ; species type 2

	db 170 ; catch rate
	db 76 ; base exp yield
	db $55 ; sprite dimensions

	dw JigglypuffPicFront
	dw JigglypuffPicBack
	
	; attacks known at lvl 0
	db SING
	db 0
	db 0
	db 0

	db 4 ; growth rate
	
	; learnset
	db %10110001
	db %111111
	db %10101111
	db %11110001
	db %10100011
	db %111000
	db %1100011

	db 0 ; padding

WigglytuffBaseStats: ; 0x38822
	db DEX_WIGGLYTUFF ; pokedex id
	db 140 ; base hp
	db 70 ; base attack
	db 45 ; base defense
	db 45 ; base speed
	db 50 ; base special

	db NORMAL ; species type 1
	db NORMAL ; species type 2

	db 50 ; catch rate
	db 109 ; base exp yield
	db $66 ; sprite dimensions

	dw WigglytuffPicFront
	dw WigglytuffPicBack
	
	; attacks known at lvl 0
	db SING
	db DISABLE
	db DEFENSE_CURL
	db DOUBLESLAP

	db 4 ; growth rate
	
	; learnset
	db %10110001
	db %1111111
	db %10101111
	db %11110001
	db %10100011
	db %111000
	db %1100011

	db 0 ; padding

ZubatBaseStats: ; 0x3883e
	db DEX_ZUBAT ; pokedex id
	db 40 ; base hp
	db 45 ; base attack
	db 35 ; base defense
	db 55 ; base speed
	db 40 ; base special

	db POISON ; species type 1
	db FLYING ; species type 2

	db 255 ; catch rate
	db 54 ; base exp yield
	db $55 ; sprite dimensions

	dw ZubatPicFront
	dw ZubatPicBack
	
	; attacks known at lvl 0
	db LEECH_LIFE
	db 0
	db 0
	db 0

	db 0 ; growth rate
	
	; learnset
	db %101010
	db %11
	db %11000
	db %11000000
	db %1000010
	db %1000
	db %10

	db 0 ; padding

GolbatBaseStats: ; 0x3885a
	db DEX_GOLBAT ; pokedex id
	db 75 ; base hp
	db 80 ; base attack
	db 70 ; base defense
	db 90 ; base speed
	db 75 ; base special

	db POISON ; species type 1
	db FLYING ; species type 2

	db 90 ; catch rate
	db 171 ; base exp yield
	db $77 ; sprite dimensions

	dw GolbatPicFront
	dw GolbatPicBack
	
	; attacks known at lvl 0
	db LEECH_LIFE
	db SCREECH
	db BITE
	db 0

	db 0 ; growth rate
	
	; learnset
	db %101010
	db %1000011
	db %11000
	db %11000000
	db %1000010
	db %1000
	db %10

	db 0 ; padding

OddishBaseStats: ; 0x38876
	db DEX_ODDISH ; pokedex id
	db 45 ; base hp
	db 50 ; base attack
	db 55 ; base defense
	db 30 ; base speed
	db 75 ; base special

	db GRASS ; species type 1
	db POISON ; species type 2

	db 255 ; catch rate
	db 78 ; base exp yield
	db $55 ; sprite dimensions

	dw OddishPicFront
	dw OddishPicBack
	
	; attacks known at lvl 0
	db ABSORB
	db 0
	db 0
	db 0

	db 3 ; growth rate
	
	; learnset
	db %100100
	db %11
	db %111000
	db %11000000
	db %11
	db %1000
	db %110

	db 0 ; padding

GloomBaseStats: ; 0x38892
	db DEX_GLOOM ; pokedex id
	db 60 ; base hp
	db 65 ; base attack
	db 70 ; base defense
	db 40 ; base speed
	db 85 ; base special

	db GRASS ; species type 1
	db POISON ; species type 2

	db 120 ; catch rate
	db 132 ; base exp yield
	db $66 ; sprite dimensions

	dw GloomPicFront
	dw GloomPicBack
	
	; attacks known at lvl 0
	db ABSORB
	db POISONPOWDER
	db STUN_SPORE
	db 0

	db 3 ; growth rate
	
	; learnset
	db %100100
	db %11
	db %111000
	db %11000000
	db %11
	db %1000
	db %110

	db 0 ; padding

VileplumeBaseStats: ; 0x388ae
	db DEX_VILEPLUME ; pokedex id
	db 75 ; base hp
	db 80 ; base attack
	db 85 ; base defense
	db 50 ; base speed
	db 100 ; base special

	db GRASS ; species type 1
	db POISON ; species type 2

	db 45 ; catch rate
	db 184 ; base exp yield
	db $77 ; sprite dimensions

	dw VileplumePicFront
	dw VileplumePicBack
	
	; attacks known at lvl 0
	db STUN_SPORE
	db SLEEP_POWDER
	db ACID
	db PETAL_DANCE

	db 3 ; growth rate
	
	; learnset
	db %10100100
	db %1000011
	db %111000
	db %11000000
	db %11
	db %1000
	db %110

	db 0 ; padding

ParasBaseStats: ; 0x388ca
	db DEX_PARAS ; pokedex id
	db 35 ; base hp
	db 70 ; base attack
	db 55 ; base defense
	db 25 ; base speed
	db 55 ; base special

	db BUG ; species type 1
	db GRASS ; species type 2

	db 190 ; catch rate
	db 70 ; base exp yield
	db $55 ; sprite dimensions

	dw ParasPicFront
	dw ParasPicBack
	
	; attacks known at lvl 0
	db SCRATCH
	db 0
	db 0
	db 0

	db 0 ; growth rate
	
	; learnset
	db %10100100
	db %11
	db %111000
	db %11001000
	db %10000011
	db %1000
	db %110

	db 0 ; padding

ParasectBaseStats: ; 0x388e6
	db DEX_PARASECT ; pokedex id
	db 60 ; base hp
	db 95 ; base attack
	db 80 ; base defense
	db 30 ; base speed
	db 80 ; base special

	db BUG ; species type 1
	db GRASS ; species type 2

	db 75 ; catch rate
	db 128 ; base exp yield
	db $77 ; sprite dimensions

	dw ParasectPicFront
	dw ParasectPicBack
	
	; attacks known at lvl 0
	db SCRATCH
	db STUN_SPORE
	db LEECH_LIFE
	db 0

	db 0 ; growth rate
	
	; learnset
	db %10100100
	db %1000011
	db %111000
	db %11001000
	db %10000011
	db %1000
	db %110

	db 0 ; padding

VenonatBaseStats: ; 0x38902
	db DEX_VENONAT ; pokedex id
	db 60 ; base hp
	db 55 ; base attack
	db 50 ; base defense
	db 45 ; base speed
	db 40 ; base special

	db BUG ; species type 1
	db POISON ; species type 2

	db 190 ; catch rate
	db 75 ; base exp yield
	db $55 ; sprite dimensions

	dw VenonatPicFront
	dw VenonatPicBack
	
	; attacks known at lvl 0
	db TACKLE
	db DISABLE
	db 0
	db 0

	db 0 ; growth rate
	
	; learnset
	db %100000
	db %11
	db %111000
	db %11010000
	db %11
	db %101000
	db %10

	db 0 ; padding

VenomothBaseStats: ; 0x3891e
	db DEX_VENOMOTH ; pokedex id
	db 70 ; base hp
	db 65 ; base attack
	db 60 ; base defense
	db 90 ; base speed
	db 90 ; base special

	db BUG ; species type 1
	db POISON ; species type 2

	db 75 ; catch rate
	db 138 ; base exp yield
	db $77 ; sprite dimensions

	dw VenomothPicFront
	dw VenomothPicBack
	
	; attacks known at lvl 0
	db TACKLE
	db DISABLE
	db POISONPOWDER
	db LEECH_LIFE

	db 0 ; growth rate
	
	; learnset
	db %101010
	db %1000011
	db %111000
	db %11110000
	db %1000011
	db %101000
	db %10

	db 0 ; padding

DiglettBaseStats: ; 0x3893a
	db DEX_DIGLETT ; pokedex id
	db 10 ; base hp
	db 55 ; base attack
	db 25 ; base defense
	db 95 ; base speed
	db 45 ; base special

	db GROUND ; species type 1
	db GROUND ; species type 2

	db 255 ; catch rate
	db 81 ; base exp yield
	db $55 ; sprite dimensions

	dw DiglettPicFront
	dw DiglettPicBack
	
	; attacks known at lvl 0
	db SCRATCH
	db 0
	db 0
	db 0

	db 0 ; growth rate
	
	; learnset
	db %10100000
	db %11
	db %1000
	db %11001110
	db %10
	db %10001000
	db %10

	db 0 ; padding

DugtrioBaseStats: ; 0x38956
	db DEX_DUGTRIO ; pokedex id
	db 35 ; base hp
	db 80 ; base attack
	db 50 ; base defense
	db 120 ; base speed
	db 70 ; base special

	db GROUND ; species type 1
	db GROUND ; species type 2

	db 50 ; catch rate
	db 153 ; base exp yield
	db $66 ; sprite dimensions

	dw DugtrioPicFront
	dw DugtrioPicBack
	
	; attacks known at lvl 0
	db SCRATCH
	db GROWL
	db DIG
	db 0

	db 0 ; growth rate
	
	; learnset
	db %10100000
	db %1000011
	db %1000
	db %11001110
	db %10
	db %10001000
	db %10

	db 0 ; padding

MeowthBaseStats: ; 0x38972
	db DEX_MEOWTH ; pokedex id
	db 40 ; base hp
	db 45 ; base attack
	db 35 ; base defense
	db 90 ; base speed
	db 40 ; base special

	db NORMAL ; species type 1
	db NORMAL ; species type 2

	db 255 ; catch rate
	db 69 ; base exp yield
	db $55 ; sprite dimensions

	dw MeowthPicFront
	dw MeowthPicBack
	
	; attacks known at lvl 0
	db SCRATCH
	db GROWL
	db 0
	db 0

	db 0 ; growth rate
	
	; learnset
	db %10100000
	db %10001111
	db %10001000
	db %11000001
	db %11000010
	db %1000
	db %10

	db 0 ; padding

PersianBaseStats: ; 0x3898e
	db DEX_PERSIAN ; pokedex id
	db 65 ; base hp
	db 70 ; base attack
	db 60 ; base defense
	db 115 ; base speed
	db 65 ; base special

	db NORMAL ; species type 1
	db NORMAL ; species type 2

	db 90 ; catch rate
	db 148 ; base exp yield
	db $77 ; sprite dimensions

	dw PersianPicFront
	dw PersianPicBack
	
	; attacks known at lvl 0
	db SCRATCH
	db GROWL
	db BITE
	db SCREECH

	db 0 ; growth rate
	
	; learnset
	db %10100000
	db %11001111
	db %10001000
	db %11000001
	db %11000010
	db %1000
	db %10

	db 0 ; padding

PsyduckBaseStats: ; 0x389aa
	db DEX_PSYDUCK ; pokedex id
	db 50 ; base hp
	db 52 ; base attack
	db 48 ; base defense
	db 55 ; base speed
	db 50 ; base special

	db WATER ; species type 1
	db WATER ; species type 2

	db 190 ; catch rate
	db 80 ; base exp yield
	db $55 ; sprite dimensions

	dw PsyduckPicFront
	dw PsyduckPicBack
	
	; attacks known at lvl 0
	db SCRATCH
	db 0
	db 0
	db 0

	db 0 ; growth rate
	
	; learnset
	db %10110001
	db %10111111
	db %1111
	db %11001000
	db %11000010
	db %1000
	db %110010

	db 0 ; padding

GolduckBaseStats: ; 0x389c6
	db DEX_GOLDUCK ; pokedex id
	db 80 ; base hp
	db 82 ; base attack
	db 78 ; base defense
	db 85 ; base speed
	db 80 ; base special

	db WATER ; species type 1
	db WATER ; species type 2

	db 75 ; catch rate
	db 174 ; base exp yield
	db $77 ; sprite dimensions

	dw GolduckPicFront
	dw GolduckPicBack
	
	; attacks known at lvl 0
	db SCRATCH
	db TAIL_WHIP
	db DISABLE
	db 0

	db 0 ; growth rate
	
	; learnset
	db %10110001
	db %11111111
	db %1111
	db %11001000
	db %11000010
	db %1000
	db %110010

	db 0 ; padding

MankeyBaseStats: ; 0x389e2
	db DEX_MANKEY ; pokedex id
	db 40 ; base hp
	db 80 ; base attack
	db 35 ; base defense
	db 70 ; base speed
	db 35 ; base special

	db FIGHTING ; species type 1
	db FIGHTING ; species type 2

	db 190 ; catch rate
	db 74 ; base exp yield
	db $55 ; sprite dimensions

	dw MankeyPicFront
	dw MankeyPicBack
	
	; attacks known at lvl 0
	db SCRATCH
	db LEER
	db 0
	db 0

	db 0 ; growth rate
	
	; learnset
	db %10110001
	db %10000011
	db %10001111
	db %11001001
	db %11000110
	db %10001000
	db %100010

	db 0 ; padding

PrimeapeBaseStats: ; 0x389fe
	db DEX_PRIMEAPE ; pokedex id
	db 65 ; base hp
	db 105 ; base attack
	db 60 ; base defense
	db 95 ; base speed
	db 60 ; base special

	db FIGHTING ; species type 1
	db FIGHTING ; species type 2

	db 75 ; catch rate
	db 149 ; base exp yield
	db $77 ; sprite dimensions

	dw PrimeapePicFront
	dw PrimeapePicBack
	
	; attacks known at lvl 0
	db SCRATCH
	db LEER
	db KARATE_CHOP
	db FURY_SWIPES

	db 0 ; growth rate
	
	; learnset
	db %10110001
	db %11000011
	db %10001111
	db %11001001
	db %11000110
	db %10001000
	db %100010

	db 0 ; padding

GrowlitheBaseStats: ; 0x38a1a
	db DEX_GROWLITHE ; pokedex id
	db 55 ; base hp
	db 70 ; base attack
	db 45 ; base defense
	db 60 ; base speed
	db 50 ; base special

	db FIRE ; species type 1
	db FIRE ; species type 2

	db 190 ; catch rate
	db 91 ; base exp yield
	db $55 ; sprite dimensions

	dw GrowlithePicFront
	dw GrowlithePicBack
	
	; attacks known at lvl 0
	db BITE
	db ROAR
	db 0
	db 0

	db 5 ; growth rate
	
	; learnset
	db %10100000
	db %11
	db %1001000
	db %11001000
	db %11100011
	db %1000
	db %10

	db 0 ; padding

ArcanineBaseStats: ; 0x38a36
	db DEX_ARCANINE ; pokedex id
	db 90 ; base hp
	db 110 ; base attack
	db 80 ; base defense
	db 95 ; base speed
	db 80 ; base special

	db FIRE ; species type 1
	db FIRE ; species type 2

	db 75 ; catch rate
	db 213 ; base exp yield
	db $77 ; sprite dimensions

	dw ArcaninePicFront
	dw ArcaninePicBack
	
	; attacks known at lvl 0
	db ROAR
	db EMBER
	db LEER
	db TAKE_DOWN

	db 5 ; growth rate
	
	; learnset
	db %10100000
	db %1000011
	db %1001000
	db %11101000
	db %11100011
	db %1000
	db %10

	db 0 ; padding

PoliwagBaseStats: ; 0x38a52
	db DEX_POLIWAG ; pokedex id
	db 40 ; base hp
	db 50 ; base attack
	db 40 ; base defense
	db 90 ; base speed
	db 40 ; base special

	db WATER ; species type 1
	db WATER ; species type 2

	db 255 ; catch rate
	db 77 ; base exp yield
	db $55 ; sprite dimensions

	dw PoliwagPicFront
	dw PoliwagPicBack
	
	; attacks known at lvl 0
	db BUBBLE
	db 0
	db 0
	db 0

	db 3 ; growth rate
	
	; learnset
	db %10100000
	db %111111
	db %1000
	db %11010000
	db %10000010
	db %101000
	db %10010

	db 0 ; padding

PoliwhirlBaseStats: ; 0x38a6e
	db DEX_POLIWHIRL ; pokedex id
	db 65 ; base hp
	db 65 ; base attack
	db 65 ; base defense
	db 90 ; base speed
	db 50 ; base special

	db WATER ; species type 1
	db WATER ; species type 2

	db 120 ; catch rate
	db 131 ; base exp yield
	db $66 ; sprite dimensions

	dw PoliwhirlPicFront
	dw PoliwhirlPicBack
	
	; attacks known at lvl 0
	db BUBBLE
	db HYPNOSIS
	db WATER_GUN
	db 0

	db 3 ; growth rate
	
	; learnset
	db %10110001
	db %111111
	db %1111
	db %11010110
	db %10000110
	db %101000
	db %110010

	db 0 ; padding

PoliwrathBaseStats: ; 0x38a8a
	db DEX_POLIWRATH ; pokedex id
	db 90 ; base hp
	db 85 ; base attack
	db 95 ; base defense
	db 70 ; base speed
	db 70 ; base special

	db WATER ; species type 1
	db FIGHTING ; species type 2

	db 45 ; catch rate
	db 185 ; base exp yield
	db $77 ; sprite dimensions

	dw PoliwrathPicFront
	dw PoliwrathPicBack
	
	; attacks known at lvl 0
	db HYPNOSIS
	db WATER_GUN
	db DOUBLESLAP
	db BODY_SLAM

	db 3 ; growth rate
	
	; learnset
	db %10110001
	db %1111111
	db %1111
	db %11010110
	db %10000110
	db %101000
	db %110010

	db 0 ; padding

AbraBaseStats: ; 0x38aa6
	db DEX_ABRA ; pokedex id
	db 25 ; base hp
	db 20 ; base attack
	db 15 ; base defense
	db 90 ; base speed
	db 105 ; base special

	db PSYCHIC ; species type 1
	db PSYCHIC ; species type 2

	db 200 ; catch rate
	db 73 ; base exp yield
	db $55 ; sprite dimensions

	dw AbraPicFront
	dw AbraPicBack
	
	; attacks known at lvl 0
	db TELEPORT
	db 0
	db 0
	db 0

	db 3 ; growth rate
	
	; learnset
	db %10110001
	db %11
	db %1111
	db %11110000
	db %10000111
	db %111000
	db %1000011

	db 0 ; padding

KadabraBaseStats: ; 0x38ac2
	db DEX_KADABRA ; pokedex id
	db 40 ; base hp
	db 35 ; base attack
	db 30 ; base defense
	db 105 ; base speed
	db 120 ; base special

	db PSYCHIC ; species type 1
	db PSYCHIC ; species type 2

	db 100 ; catch rate
	db 145 ; base exp yield
	db $66 ; sprite dimensions

	dw KadabraPicFront
	dw KadabraPicBack
	
	; attacks known at lvl 0
	db TELEPORT
	db CONFUSION
	db DISABLE
	db 0

	db 3 ; growth rate
	
	; learnset
	db %10110001
	db %11
	db %1111
	db %11111000
	db %10000111
	db %111000
	db %1000011

	db 0 ; padding

AlakazamBaseStats: ; 0x38ade
	db DEX_ALAKAZAM ; pokedex id
	db 55 ; base hp
	db 50 ; base attack
	db 45 ; base defense
	db 120 ; base speed
	db 135 ; base special

	db PSYCHIC ; species type 1
	db PSYCHIC ; species type 2

	db 50 ; catch rate
	db 186 ; base exp yield
	db $77 ; sprite dimensions

	dw AlakazamPicFront
	dw AlakazamPicBack
	
	; attacks known at lvl 0
	db TELEPORT
	db CONFUSION
	db DISABLE
	db 0

	db 3 ; growth rate
	
	; learnset
	db %10110001
	db %1000011
	db %1111
	db %11111000
	db %10000111
	db %111000
	db %1000011

	db 0 ; padding

MachopBaseStats: ; 0x38afa
	db DEX_MACHOP ; pokedex id
	db 70 ; base hp
	db 80 ; base attack
	db 50 ; base defense
	db 35 ; base speed
	db 35 ; base special

	db FIGHTING ; species type 1
	db FIGHTING ; species type 2

	db 180 ; catch rate
	db 88 ; base exp yield
	db $55 ; sprite dimensions

	dw MachopPicFront
	dw MachopPicBack
	
	; attacks known at lvl 0
	db KARATE_CHOP
	db 0
	db 0
	db 0

	db 3 ; growth rate
	
	; learnset
	db %10110001
	db %11
	db %1111
	db %11001110
	db %10100110
	db %10001000
	db %100010

	db 0 ; padding

MachokeBaseStats: ; 0x38b16
	db DEX_MACHOKE ; pokedex id
	db 80 ; base hp
	db 100 ; base attack
	db 70 ; base defense
	db 45 ; base speed
	db 50 ; base special

	db FIGHTING ; species type 1
	db FIGHTING ; species type 2

	db 90 ; catch rate
	db 146 ; base exp yield
	db $77 ; sprite dimensions

	dw MachokePicFront
	dw MachokePicBack
	
	; attacks known at lvl 0
	db KARATE_CHOP
	db LOW_KICK
	db LEER
	db 0

	db 3 ; growth rate
	
	; learnset
	db %10110001
	db %11
	db %1111
	db %11001110
	db %10100110
	db %10001000
	db %100010

	db 0 ; padding

MachampBaseStats: ; 0x38b32
	db DEX_MACHAMP ; pokedex id
	db 90 ; base hp
	db 130 ; base attack
	db 80 ; base defense
	db 55 ; base speed
	db 65 ; base special

	db FIGHTING ; species type 1
	db FIGHTING ; species type 2

	db 45 ; catch rate
	db 193 ; base exp yield
	db $77 ; sprite dimensions

	dw MachampPicFront
	dw MachampPicBack
	
	; attacks known at lvl 0
	db KARATE_CHOP
	db LOW_KICK
	db LEER
	db 0

	db 3 ; growth rate
	
	; learnset
	db %10110001
	db %1000011
	db %1111
	db %11001110
	db %10100110
	db %10001000
	db %100010

	db 0 ; padding

BellsproutBaseStats: ; 0x38b4e
	db DEX_BELLSPROUT ; pokedex id
	db 50 ; base hp
	db 75 ; base attack
	db 35 ; base defense
	db 40 ; base speed
	db 70 ; base special

	db GRASS ; species type 1
	db POISON ; species type 2

	db 255 ; catch rate
	db 84 ; base exp yield
	db $55 ; sprite dimensions

	dw BellsproutPicFront
	dw BellsproutPicBack
	
	; attacks known at lvl 0
	db VINE_WHIP
	db GROWTH
	db 0
	db 0

	db 3 ; growth rate
	
	; learnset
	db %100100
	db %11
	db %111000
	db %11000000
	db %11
	db %1000
	db %110

	db 0 ; padding

WeepinbellBaseStats: ; 0x38b6a
	db DEX_WEEPINBELL ; pokedex id
	db 65 ; base hp
	db 90 ; base attack
	db 50 ; base defense
	db 55 ; base speed
	db 85 ; base special

	db GRASS ; species type 1
	db POISON ; species type 2

	db 120 ; catch rate
	db 151 ; base exp yield
	db $66 ; sprite dimensions

	dw WeepinbellPicFront
	dw WeepinbellPicBack
	
	; attacks known at lvl 0
	db VINE_WHIP
	db GROWTH
	db WRAP
	db 0

	db 3 ; growth rate
	
	; learnset
	db %100100
	db %11
	db %111000
	db %11000000
	db %11
	db %1000
	db %110

	db 0 ; padding

VictreebelBaseStats: ; 0x38b86
	db DEX_VICTREEBEL ; pokedex id
	db 80 ; base hp
	db 105 ; base attack
	db 65 ; base defense
	db 70 ; base speed
	db 100 ; base special

	db GRASS ; species type 1
	db POISON ; species type 2

	db 45 ; catch rate
	db 191 ; base exp yield
	db $77 ; sprite dimensions

	dw VictreebelPicFront
	dw VictreebelPicBack
	
	; attacks known at lvl 0
	db SLEEP_POWDER
	db STUN_SPORE
	db ACID
	db RAZOR_LEAF

	db 3 ; growth rate
	
	; learnset
	db %10100100
	db %1000011
	db %111000
	db %11000000
	db %11
	db %1000
	db %110

	db 0 ; padding

TentacoolBaseStats: ; 0x38ba2
	db DEX_TENTACOOL ; pokedex id
	db 40 ; base hp
	db 40 ; base attack
	db 35 ; base defense
	db 70 ; base speed
	db 100 ; base special

	db WATER ; species type 1
	db POISON ; species type 2

	db 190 ; catch rate
	db 105 ; base exp yield
	db $55 ; sprite dimensions

	dw TentacoolPicFront
	dw TentacoolPicBack
	
	; attacks known at lvl 0
	db ACID
	db 0
	db 0
	db 0

	db 5 ; growth rate
	
	; learnset
	db %100100
	db %111111
	db %11000
	db %11000000
	db %10000011
	db %1000
	db %10110

	db 0 ; padding

TentacruelBaseStats: ; 0x38bbe
	db DEX_TENTACRUEL ; pokedex id
	db 80 ; base hp
	db 70 ; base attack
	db 65 ; base defense
	db 100 ; base speed
	db 120 ; base special

	db WATER ; species type 1
	db POISON ; species type 2

	db 60 ; catch rate
	db 205 ; base exp yield
	db $66 ; sprite dimensions

	dw TentacruelPicFront
	dw TentacruelPicBack
	
	; attacks known at lvl 0
	db ACID
	db SUPERSONIC
	db WRAP
	db 0

	db 5 ; growth rate
	
	; learnset
	db %100100
	db %1111111
	db %11000
	db %11000000
	db %10000011
	db %1000
	db %10110

	db 0 ; padding

GeodudeBaseStats: ; 0x38bda
	db DEX_GEODUDE ; pokedex id
	db 40 ; base hp
	db 80 ; base attack
	db 100 ; base defense
	db 20 ; base speed
	db 30 ; base special

	db ROCK ; species type 1
	db GROUND ; species type 2

	db 255 ; catch rate
	db 86 ; base exp yield
	db $55 ; sprite dimensions

	dw GeodudePicFront
	dw GeodudePicBack
	
	; attacks known at lvl 0
	db TACKLE
	db 0
	db 0
	db 0

	db 3 ; growth rate
	
	; learnset
	db %10100001
	db %11
	db %1111
	db %11001110
	db %101110
	db %11001000
	db %100010

	db 0 ; padding

GravelerBaseStats: ; 0x38bf6
	db DEX_GRAVELER ; pokedex id
	db 55 ; base hp
	db 95 ; base attack
	db 115 ; base defense
	db 35 ; base speed
	db 45 ; base special

	db ROCK ; species type 1
	db GROUND ; species type 2

	db 120 ; catch rate
	db 134 ; base exp yield
	db $66 ; sprite dimensions

	dw GravelerPicFront
	dw GravelerPicBack
	
	; attacks known at lvl 0
	db TACKLE
	db DEFENSE_CURL
	db 0
	db 0

	db 3 ; growth rate
	
	; learnset
	db %10100001
	db %11
	db %1111
	db %11001110
	db %101110
	db %11001000
	db %100010

	db 0 ; padding

GolemBaseStats: ; 0x38c12
	db DEX_GOLEM ; pokedex id
	db 80 ; base hp
	db 110 ; base attack
	db 130 ; base defense
	db 45 ; base speed
	db 55 ; base special

	db ROCK ; species type 1
	db GROUND ; species type 2

	db 45 ; catch rate
	db 177 ; base exp yield
	db $66 ; sprite dimensions

	dw GolemPicFront
	dw GolemPicBack
	
	; attacks known at lvl 0
	db TACKLE
	db DEFENSE_CURL
	db 0
	db 0

	db 3 ; growth rate
	
	; learnset
	db %10110001
	db %1000011
	db %1111
	db %11001110
	db %101110
	db %11001000
	db %100010

	db 0 ; padding

PonytaBaseStats: ; 0x38c2e
	db DEX_PONYTA ; pokedex id
	db 50 ; base hp
	db 85 ; base attack
	db 55 ; base defense
	db 90 ; base speed
	db 65 ; base special

	db FIRE ; species type 1
	db FIRE ; species type 2

	db 190 ; catch rate
	db 152 ; base exp yield
	db $66 ; sprite dimensions

	dw PonytaPicFront
	dw PonytaPicBack
	
	; attacks known at lvl 0
	db EMBER
	db 0
	db 0
	db 0

	db 0 ; growth rate
	
	; learnset
	db %11100000
	db %11
	db %1000
	db %11000000
	db %11100011
	db %1000
	db %10

	db 0 ; padding

RapidashBaseStats: ; 0x38c4a
	db DEX_RAPIDASH ; pokedex id
	db 65 ; base hp
	db 100 ; base attack
	db 70 ; base defense
	db 105 ; base speed
	db 80 ; base special

	db FIRE ; species type 1
	db FIRE ; species type 2

	db 60 ; catch rate
	db 192 ; base exp yield
	db $77 ; sprite dimensions

	dw RapidashPicFront
	dw RapidashPicBack
	
	; attacks known at lvl 0
	db EMBER
	db TAIL_WHIP
	db STOMP
	db GROWL

	db 0 ; growth rate
	
	; learnset
	db %11100000
	db %1000011
	db %1000
	db %11000000
	db %11100011
	db %1000
	db %10

	db 0 ; padding

SlowpokeBaseStats: ; 0x38c66
	db DEX_SLOWPOKE ; pokedex id
	db 90 ; base hp
	db 65 ; base attack
	db 65 ; base defense
	db 15 ; base speed
	db 40 ; base special

	db WATER ; species type 1
	db PSYCHIC ; species type 2

	db 190 ; catch rate
	db 99 ; base exp yield
	db $55 ; sprite dimensions

	dw SlowpokePicFront
	dw SlowpokePicBack
	
	; attacks known at lvl 0
	db CONFUSION
	db 0
	db 0
	db 0

	db 0 ; growth rate
	
	; learnset
	db %10100000
	db %10111111
	db %1000
	db %11111110
	db %11100011
	db %111000
	db %1110011

	db 0 ; padding

SlowbroBaseStats: ; 0x38c82
	db DEX_SLOWBRO ; pokedex id
	db 95 ; base hp
	db 75 ; base attack
	db 110 ; base defense
	db 30 ; base speed
	db 80 ; base special

	db WATER ; species type 1
	db PSYCHIC ; species type 2

	db 75 ; catch rate
	db 164 ; base exp yield
	db $77 ; sprite dimensions

	dw SlowbroPicFront
	dw SlowbroPicBack
	
	; attacks known at lvl 0
	db CONFUSION
	db DISABLE
	db HEADBUTT
	db 0

	db 0 ; growth rate
	
	; learnset
	db %10110001
	db %11111111
	db %1111
	db %11111110
	db %11100011
	db %111000
	db %1110011

	db 0 ; padding

MagnemiteBaseStats: ; 0x38c9e
	db DEX_MAGNEMITE ; pokedex id
	db 25 ; base hp
	db 35 ; base attack
	db 70 ; base defense
	db 45 ; base speed
	db 95 ; base special

	db ELECTRIC ; species type 1
	db ELECTRIC ; species type 2

	db 190 ; catch rate
	db 89 ; base exp yield
	db $55 ; sprite dimensions

	dw MagnemitePicFront
	dw MagnemitePicBack
	
	; attacks known at lvl 0
	db TACKLE
	db 0
	db 0
	db 0

	db 0 ; growth rate
	
	; learnset
	db %100000
	db %11
	db %10001000
	db %11100001
	db %1000011
	db %11000
	db %1000010

	db 0 ; padding

MagnetonBaseStats: ; 0x38cba
	db DEX_MAGNETON ; pokedex id
	db 50 ; base hp
	db 60 ; base attack
	db 95 ; base defense
	db 70 ; base speed
	db 120 ; base special

	db ELECTRIC ; species type 1
	db ELECTRIC ; species type 2

	db 60 ; catch rate
	db 161 ; base exp yield
	db $66 ; sprite dimensions

	dw MagnetonPicFront
	dw MagnetonPicBack
	
	; attacks known at lvl 0
	db TACKLE
	db SONICBOOM
	db THUNDERSHOCK
	db 0

	db 0 ; growth rate
	
	; learnset
	db %100000
	db %1000011
	db %10001000
	db %11100001
	db %1000011
	db %11000
	db %1000010

	db 0 ; padding

FarfetchdBaseStats: ; 0x38cd6
	db DEX_FARFETCH_D ; pokedex id
	db 52 ; base hp
	db 65 ; base attack
	db 55 ; base defense
	db 60 ; base speed
	db 58 ; base special

	db NORMAL ; species type 1
	db FLYING ; species type 2

	db 45 ; catch rate
	db 94 ; base exp yield
	db $66 ; sprite dimensions

	dw FarfetchdPicFront
	dw FarfetchdPicBack
	
	; attacks known at lvl 0
	db PECK
	db SAND_ATTACK
	db 0
	db 0

	db 0 ; growth rate
	
	; learnset
	db %10101110
	db %11
	db %1000
	db %11000000
	db %11000011
	db %1000
	db %1110

	db 0 ; padding

DoduoBaseStats: ; 0x38cf2
	db DEX_DODUO ; pokedex id
	db 35 ; base hp
	db 85 ; base attack
	db 45 ; base defense
	db 75 ; base speed
	db 35 ; base special

	db NORMAL ; species type 1
	db FLYING ; species type 2

	db 190 ; catch rate
	db 96 ; base exp yield
	db $55 ; sprite dimensions

	dw DoduoPicFront
	dw DoduoPicBack
	
	; attacks known at lvl 0
	db PECK
	db 0
	db 0
	db 0

	db 0 ; growth rate
	
	; learnset
	db %10101000
	db %11
	db %1000
	db %11000000
	db %10000011
	db %1100
	db %1011

	db 0 ; padding

DodrioBaseStats: ; 0x38d0e
	db DEX_DODRIO ; pokedex id
	db 60 ; base hp
	db 110 ; base attack
	db 70 ; base defense
	db 100 ; base speed
	db 60 ; base special

	db NORMAL ; species type 1
	db FLYING ; species type 2

	db 45 ; catch rate
	db 158 ; base exp yield
	db $77 ; sprite dimensions

	dw DodrioPicFront
	dw DodrioPicBack
	
	; attacks known at lvl 0
	db PECK
	db GROWL
	db FURY_ATTACK
	db 0

	db 0 ; growth rate
	
	; learnset
	db %10101000
	db %1000011
	db %1000
	db %11000000
	db %10000011
	db %1100
	db %1011

	db 0 ; padding

SeelBaseStats: ; 0x38d2a
	db DEX_SEEL ; pokedex id
	db 65 ; base hp
	db 45 ; base attack
	db 55 ; base defense
	db 45 ; base speed
	db 70 ; base special

	db WATER ; species type 1
	db WATER ; species type 2

	db 190 ; catch rate
	db 100 ; base exp yield
	db $66 ; sprite dimensions

	dw SeelPicFront
	dw SeelPicBack
	
	; attacks known at lvl 0
	db HEADBUTT
	db 0
	db 0
	db 0

	db 0 ; growth rate
	
	; learnset
	db %11100000
	db %10111111
	db %1000
	db %11000000
	db %10000010
	db %1000
	db %110010

	db 0 ; padding

DewgongBaseStats: ; 0x38d46
	db DEX_DEWGONG ; pokedex id
	db 90 ; base hp
	db 70 ; base attack
	db 80 ; base defense
	db 70 ; base speed
	db 95 ; base special

	db WATER ; species type 1
	db ICE ; species type 2

	db 75 ; catch rate
	db 176 ; base exp yield
	db $66 ; sprite dimensions

	dw DewgongPicFront
	dw DewgongPicBack
	
	; attacks known at lvl 0
	db HEADBUTT
	db GROWL
	db AURORA_BEAM
	db 0

	db 0 ; growth rate
	
	; learnset
	db %11100000
	db %11111111
	db %1000
	db %11000000
	db %10000010
	db %1000
	db %110010

	db 0 ; padding

GrimerBaseStats: ; 0x38d62
	db DEX_GRIMER ; pokedex id
	db 80 ; base hp
	db 80 ; base attack
	db 50 ; base defense
	db 25 ; base speed
	db 40 ; base special

	db POISON ; species type 1
	db POISON ; species type 2

	db 190 ; catch rate
	db 90 ; base exp yield
	db $55 ; sprite dimensions

	dw GrimerPicFront
	dw GrimerPicBack
	
	; attacks known at lvl 0
	db POUND
	db DISABLE
	db 0
	db 0

	db 0 ; growth rate
	
	; learnset
	db %10100000
	db %0
	db %10011000
	db %11000001
	db %101010
	db %1001000
	db %10

	db 0 ; padding

MukBaseStats: ; 0x38d7e
	db DEX_MUK ; pokedex id
	db 105 ; base hp
	db 105 ; base attack
	db 75 ; base defense
	db 50 ; base speed
	db 65 ; base special

	db POISON ; species type 1
	db POISON ; species type 2

	db 75 ; catch rate
	db 157 ; base exp yield
	db $77 ; sprite dimensions

	dw MukPicFront
	dw MukPicBack
	
	; attacks known at lvl 0
	db POUND
	db DISABLE
	db POISON_GAS
	db 0

	db 0 ; growth rate
	
	; learnset
	db %10100000
	db %1000000
	db %10011000
	db %11000001
	db %101010
	db %1001000
	db %10

	db 0 ; padding

ShellderBaseStats: ; 0x38d9a
	db DEX_SHELLDER ; pokedex id
	db 30 ; base hp
	db 65 ; base attack
	db 100 ; base defense
	db 40 ; base speed
	db 45 ; base special

	db WATER ; species type 1
	db WATER ; species type 2

	db 190 ; catch rate
	db 97 ; base exp yield
	db $55 ; sprite dimensions

	dw ShellderPicFront
	dw ShellderPicBack
	
	; attacks known at lvl 0
	db TACKLE
	db WITHDRAW
	db 0
	db 0

	db 5 ; growth rate
	
	; learnset
	db %100000
	db %111111
	db %1000
	db %11100000
	db %1001011
	db %1001000
	db %10011

	db 0 ; padding

CloysterBaseStats: ; 0x38db6
	db DEX_CLOYSTER ; pokedex id
	db 50 ; base hp
	db 95 ; base attack
	db 180 ; base defense
	db 70 ; base speed
	db 85 ; base special

	db WATER ; species type 1
	db ICE ; species type 2

	db 60 ; catch rate
	db 203 ; base exp yield
	db $77 ; sprite dimensions

	dw CloysterPicFront
	dw CloysterPicBack
	
	; attacks known at lvl 0
	db WITHDRAW
	db SUPERSONIC
	db CLAMP
	db AURORA_BEAM

	db 5 ; growth rate
	
	; learnset
	db %100000
	db %1111111
	db %1000
	db %11100000
	db %1001011
	db %1001000
	db %10011

	db 0 ; padding

GastlyBaseStats: ; 0x38dd2
	db DEX_GASTLY ; pokedex id
	db 30 ; base hp
	db 35 ; base attack
	db 30 ; base defense
	db 80 ; base speed
	db 100 ; base special

	db GHOST ; species type 1
	db POISON ; species type 2

	db 190 ; catch rate
	db 95 ; base exp yield
	db $77 ; sprite dimensions

	dw GastlyPicFront
	dw GastlyPicBack
	
	; attacks known at lvl 0
	db LICK
	db CONFUSE_RAY
	db NIGHT_SHADE
	db 0

	db 3 ; growth rate
	
	; learnset
	db %100000
	db %0
	db %10011000
	db %11010001
	db %1010
	db %1101010
	db %10

	db 0 ; padding

HaunterBaseStats: ; 0x38dee
	db DEX_HAUNTER ; pokedex id
	db 45 ; base hp
	db 50 ; base attack
	db 45 ; base defense
	db 95 ; base speed
	db 115 ; base special

	db GHOST ; species type 1
	db POISON ; species type 2

	db 90 ; catch rate
	db 126 ; base exp yield
	db $66 ; sprite dimensions

	dw HaunterPicFront
	dw HaunterPicBack
	
	; attacks known at lvl 0
	db LICK
	db CONFUSE_RAY
	db NIGHT_SHADE
	db 0

	db 3 ; growth rate
	
	; learnset
	db %100000
	db %0
	db %10011000
	db %11010001
	db %1010
	db %1101010
	db %10

	db 0 ; padding

GengarBaseStats: ; 0x38e0a
	db DEX_GENGAR ; pokedex id
	db 60 ; base hp
	db 65 ; base attack
	db 60 ; base defense
	db 110 ; base speed
	db 130 ; base special

	db GHOST ; species type 1
	db POISON ; species type 2

	db 45 ; catch rate
	db 190 ; base exp yield
	db $66 ; sprite dimensions

	dw GengarPicFront
	dw GengarPicBack
	
	; attacks known at lvl 0
	db LICK
	db CONFUSE_RAY
	db NIGHT_SHADE
	db 0

	db 3 ; growth rate
	
	; learnset
	db %10110001
	db %1000011
	db %10011111
	db %11010001
	db %10001110
	db %1101010
	db %100010

	db 0 ; padding

OnixBaseStats: ; 0x38e26
	db DEX_ONIX ; pokedex id
	db 35 ; base hp
	db 45 ; base attack
	db 160 ; base defense
	db 70 ; base speed
	db 30 ; base special

	db ROCK ; species type 1
	db GROUND ; species type 2

	db 45 ; catch rate
	db 108 ; base exp yield
	db $77 ; sprite dimensions

	dw OnixPicFront
	dw OnixPicBack
	
	; attacks known at lvl 0
	db TACKLE
	db SCREECH
	db 0
	db 0

	db 0 ; growth rate
	
	; learnset
	db %10100000
	db %11
	db %1000
	db %11001110
	db %10001010
	db %11001000
	db %100010

	db 0 ; padding

DrowzeeBaseStats: ; 0x38e42
	db DEX_DROWZEE ; pokedex id
	db 60 ; base hp
	db 48 ; base attack
	db 45 ; base defense
	db 42 ; base speed
	db 90 ; base special

	db PSYCHIC ; species type 1
	db PSYCHIC ; species type 2

	db 190 ; catch rate
	db 102 ; base exp yield
	db $66 ; sprite dimensions

	dw DrowzeePicFront
	dw DrowzeePicBack
	
	; attacks known at lvl 0
	db POUND
	db HYPNOSIS
	db 0
	db 0

	db 0 ; growth rate
	
	; learnset
	db %10110001
	db %11
	db %1111
	db %11110000
	db %10000111
	db %111010
	db %1000011

	db 0 ; padding

HypnoBaseStats: ; 0x38e5e
	db DEX_HYPNO ; pokedex id
	db 85 ; base hp
	db 73 ; base attack
	db 70 ; base defense
	db 67 ; base speed
	db 115 ; base special

	db PSYCHIC ; species type 1
	db PSYCHIC ; species type 2

	db 75 ; catch rate
	db 165 ; base exp yield
	db $77 ; sprite dimensions

	dw HypnoPicFront
	dw HypnoPicBack
	
	; attacks known at lvl 0
	db POUND
	db HYPNOSIS
	db DISABLE
	db CONFUSION

	db 0 ; growth rate
	
	; learnset
	db %10110001
	db %1000011
	db %1111
	db %11110000
	db %10000111
	db %111010
	db %1000011

	db 0 ; padding

KrabbyBaseStats: ; 0x38e7a
	db DEX_KRABBY ; pokedex id
	db 30 ; base hp
	db 105 ; base attack
	db 90 ; base defense
	db 50 ; base speed
	db 25 ; base special

	db WATER ; species type 1
	db WATER ; species type 2

	db 225 ; catch rate
	db 115 ; base exp yield
	db $55 ; sprite dimensions

	dw KrabbyPicFront
	dw KrabbyPicBack
	
	; attacks known at lvl 0
	db BUBBLE
	db LEER
	db 0
	db 0

	db 0 ; growth rate
	
	; learnset
	db %10100100
	db %111111
	db %1000
	db %11000000
	db %10
	db %1000
	db %110110

	db 0 ; padding

KinglerBaseStats: ; 0x38e96
	db DEX_KINGLER ; pokedex id
	db 55 ; base hp
	db 130 ; base attack
	db 115 ; base defense
	db 75 ; base speed
	db 50 ; base special

	db WATER ; species type 1
	db WATER ; species type 2

	db 60 ; catch rate
	db 206 ; base exp yield
	db $77 ; sprite dimensions

	dw KinglerPicFront
	dw KinglerPicBack
	
	; attacks known at lvl 0
	db BUBBLE
	db LEER
	db VICEGRIP
	db 0

	db 0 ; growth rate
	
	; learnset
	db %10100100
	db %1111111
	db %1000
	db %11000000
	db %10
	db %1000
	db %110110

	db 0 ; padding

VoltorbBaseStats: ; 0x38eb2
	db DEX_VOLTORB ; pokedex id
	db 40 ; base hp
	db 30 ; base attack
	db 50 ; base defense
	db 100 ; base speed
	db 55 ; base special

	db ELECTRIC ; species type 1
	db ELECTRIC ; species type 2

	db 190 ; catch rate
	db 103 ; base exp yield
	db $55 ; sprite dimensions

	dw VoltorbPicFront
	dw VoltorbPicBack
	
	; attacks known at lvl 0
	db TACKLE
	db SCREECH
	db 0
	db 0

	db 0 ; growth rate
	
	; learnset
	db %100000
	db %1
	db %10001000
	db %11100001
	db %1001011
	db %1011000
	db %1000010

	db 0 ; padding

ElectrodeBaseStats: ; 0x38ece
	db DEX_ELECTRODE ; pokedex id
	db 60 ; base hp
	db 50 ; base attack
	db 70 ; base defense
	db 140 ; base speed
	db 80 ; base special

	db ELECTRIC ; species type 1
	db ELECTRIC ; species type 2

	db 60 ; catch rate
	db 150 ; base exp yield
	db $55 ; sprite dimensions

	dw ElectrodePicFront
	dw ElectrodePicBack
	
	; attacks known at lvl 0
	db TACKLE
	db SCREECH
	db SONICBOOM
	db 0

	db 0 ; growth rate
	
	; learnset
	db %100000
	db %1000001
	db %10001000
	db %11100001
	db %11001011
	db %1011000
	db %1000010

	db 0 ; padding

ExeggcuteBaseStats: ; 0x38eea
	db DEX_EXEGGCUTE ; pokedex id
	db 60 ; base hp
	db 40 ; base attack
	db 80 ; base defense
	db 40 ; base speed
	db 60 ; base special

	db GRASS ; species type 1
	db PSYCHIC ; species type 2

	db 90 ; catch rate
	db 98 ; base exp yield
	db $77 ; sprite dimensions

	dw ExeggcutePicFront
	dw ExeggcutePicBack
	
	; attacks known at lvl 0
	db BARRAGE
	db HYPNOSIS
	db 0
	db 0

	db 5 ; growth rate
	
	; learnset
	db %100000
	db %11
	db %1000
	db %11110000
	db %11011
	db %1101000
	db %10

	db 0 ; padding

ExeggutorBaseStats: ; 0x38f06
	db DEX_EXEGGUTOR ; pokedex id
	db 95 ; base hp
	db 95 ; base attack
	db 85 ; base defense
	db 55 ; base speed
	db 125 ; base special

	db GRASS ; species type 1
	db PSYCHIC ; species type 2

	db 45 ; catch rate
	db 212 ; base exp yield
	db $77 ; sprite dimensions

	dw ExeggutorPicFront
	dw ExeggutorPicBack
	
	; attacks known at lvl 0
	db BARRAGE
	db HYPNOSIS
	db 0
	db 0

	db 5 ; growth rate
	
	; learnset
	db %100000
	db %1000011
	db %111000
	db %11110000
	db %11011
	db %1101000
	db %100010

	db 0 ; padding

CuboneBaseStats: ; 0x38f22
	db DEX_CUBONE ; pokedex id
	db 50 ; base hp
	db 50 ; base attack
	db 95 ; base defense
	db 35 ; base speed
	db 40 ; base special

	db GROUND ; species type 1
	db GROUND ; species type 2

	db 190 ; catch rate
	db 87 ; base exp yield
	db $55 ; sprite dimensions

	dw CubonePicFront
	dw CubonePicBack
	
	; attacks known at lvl 0
	db BONE_CLUB
	db GROWL
	db 0
	db 0

	db 0 ; growth rate
	
	; learnset
	db %10110001
	db %111111
	db %1111
	db %11001110
	db %10100010
	db %1000
	db %100010

	db 0 ; padding

MarowakBaseStats: ; 0x38f3e
	db DEX_MAROWAK ; pokedex id
	db 60 ; base hp
	db 80 ; base attack
	db 110 ; base defense
	db 45 ; base speed
	db 50 ; base special

	db GROUND ; species type 1
	db GROUND ; species type 2

	db 75 ; catch rate
	db 124 ; base exp yield
	db $66 ; sprite dimensions

	dw MarowakPicFront
	dw MarowakPicBack
	
	; attacks known at lvl 0
	db BONE_CLUB
	db GROWL
	db LEER
	db FOCUS_ENERGY

	db 0 ; growth rate
	
	; learnset
	db %10110001
	db %1111111
	db %1111
	db %11001110
	db %10100010
	db %1000
	db %100010

	db 0 ; padding

HitmonleeBaseStats: ; 0x38f5a
	db DEX_HITMONLEE ; pokedex id
	db 50 ; base hp
	db 120 ; base attack
	db 53 ; base defense
	db 87 ; base speed
	db 35 ; base special

	db FIGHTING ; species type 1
	db FIGHTING ; species type 2

	db 45 ; catch rate
	db 139 ; base exp yield
	db $77 ; sprite dimensions

	dw HitmonleePicFront
	dw HitmonleePicBack
	
	; attacks known at lvl 0
	db DOUBLE_KICK
	db MEDITATE
	db 0
	db 0

	db 0 ; growth rate
	
	; learnset
	db %10110001
	db %11
	db %1111
	db %11000000
	db %11000110
	db %1000
	db %100010

	db 0 ; padding

HitmonchanBaseStats: ; 0x38f76
	db DEX_HITMONCHAN ; pokedex id
	db 50 ; base hp
	db 105 ; base attack
	db 79 ; base defense
	db 76 ; base speed
	db 35 ; base special

	db FIGHTING ; species type 1
	db FIGHTING ; species type 2

	db 45 ; catch rate
	db 140 ; base exp yield
	db $66 ; sprite dimensions

	dw HitmonchanPicFront
	dw HitmonchanPicBack
	
	; attacks known at lvl 0
	db COMET_PUNCH
	db AGILITY
	db 0
	db 0

	db 0 ; growth rate
	
	; learnset
	db %10110001
	db %11
	db %1111
	db %11000000
	db %11000110
	db %1000
	db %100010

	db 0 ; padding

LickitungBaseStats: ; 0x38f92
	db DEX_LICKITUNG ; pokedex id
	db 90 ; base hp
	db 55 ; base attack
	db 75 ; base defense
	db 30 ; base speed
	db 60 ; base special

	db NORMAL ; species type 1
	db NORMAL ; species type 2

	db 45 ; catch rate
	db 127 ; base exp yield
	db $77 ; sprite dimensions

	dw LickitungPicFront
	dw LickitungPicBack
	
	; attacks known at lvl 0
	db WRAP
	db SUPERSONIC
	db 0
	db 0

	db 0 ; growth rate
	
	; learnset
	db %10110101
	db %1111111
	db %10001111
	db %11000111
	db %10100010
	db %1000
	db %110110

	db 0 ; padding

KoffingBaseStats: ; 0x38fae
	db DEX_KOFFING ; pokedex id
	db 40 ; base hp
	db 65 ; base attack
	db 95 ; base defense
	db 35 ; base speed
	db 60 ; base special

	db POISON ; species type 1
	db POISON ; species type 2

	db 190 ; catch rate
	db 114 ; base exp yield
	db $66 ; sprite dimensions

	dw KoffingPicFront
	dw KoffingPicBack
	
	; attacks known at lvl 0
	db TACKLE
	db SMOG
	db 0
	db 0

	db 0 ; growth rate
	
	; learnset
	db %100000
	db %0
	db %10001000
	db %11000001
	db %101010
	db %1001000
	db %10

	db 0 ; padding

WeezingBaseStats: ; 0x38fca
	db DEX_WEEZING ; pokedex id
	db 65 ; base hp
	db 90 ; base attack
	db 120 ; base defense
	db 60 ; base speed
	db 85 ; base special

	db POISON ; species type 1
	db POISON ; species type 2

	db 60 ; catch rate
	db 173 ; base exp yield
	db $77 ; sprite dimensions

	dw WeezingPicFront
	dw WeezingPicBack
	
	; attacks known at lvl 0
	db TACKLE
	db SMOG
	db SLUDGE
	db 0

	db 0 ; growth rate
	
	; learnset
	db %100000
	db %1000000
	db %10001000
	db %11000001
	db %101010
	db %1001000
	db %10

	db 0 ; padding

RhyhornBaseStats: ; 0x38fe6
	db DEX_RHYHORN ; pokedex id
	db 80 ; base hp
	db 85 ; base attack
	db 95 ; base defense
	db 25 ; base speed
	db 30 ; base special

	db GROUND ; species type 1
	db ROCK ; species type 2

	db 120 ; catch rate
	db 135 ; base exp yield
	db $77 ; sprite dimensions

	dw RhyhornPicFront
	dw RhyhornPicBack
	
	; attacks known at lvl 0
	db HORN_ATTACK
	db 0
	db 0
	db 0

	db 5 ; growth rate
	
	; learnset
	db %11100000
	db %11
	db %10001000
	db %11001111
	db %10100010
	db %10001000
	db %100010

	db 0 ; padding

RhydonBaseStats: ; 0x39002
	db DEX_RHYDON ; pokedex id
	db 105 ; base hp
	db 130 ; base attack
	db 120 ; base defense
	db 40 ; base speed
	db 45 ; base special

	db GROUND ; species type 1
	db ROCK ; species type 2

	db 60 ; catch rate
	db 204 ; base exp yield
	db $77 ; sprite dimensions

	dw RhydonPicFront
	dw RhydonPicBack
	
	; attacks known at lvl 0
	db HORN_ATTACK
	db STOMP
	db TAIL_WHIP
	db FURY_ATTACK

	db 5 ; growth rate
	
	; learnset
	db %11110001
	db %11111111
	db %10001111
	db %11001111
	db %10100010
	db %10001000
	db %110010

	db 0 ; padding

ChanseyBaseStats: ; 0x3901e
	db DEX_CHANSEY ; pokedex id
	db 250 ; base hp
	db 5 ; base attack
	db 5 ; base defense
	db 50 ; base speed
	db 105 ; base special

	db NORMAL ; species type 1
	db NORMAL ; species type 2

	db 30 ; catch rate
	db 255 ; base exp yield
	db $66 ; sprite dimensions

	dw ChanseyPicFront
	dw ChanseyPicBack
	
	; attacks known at lvl 0
	db POUND
	db DOUBLESLAP
	db 0
	db 0

	db 4 ; growth rate
	
	; learnset
	db %10110001
	db %1111111
	db %10101111
	db %11110001
	db %10110111
	db %111001
	db %1100011

	db 0 ; padding

TangelaBaseStats: ; 0x3903a
	db DEX_TANGELA ; pokedex id
	db 65 ; base hp
	db 55 ; base attack
	db 115 ; base defense
	db 60 ; base speed
	db 100 ; base special

	db GRASS ; species type 1
	db GRASS ; species type 2

	db 45 ; catch rate
	db 166 ; base exp yield
	db $66 ; sprite dimensions

	dw TangelaPicFront
	dw TangelaPicBack
	
	; attacks known at lvl 0
	db CONSTRICT
	db BIND
	db 0
	db 0

	db 0 ; growth rate
	
	; learnset
	db %10100100
	db %1000011
	db %111000
	db %11000000
	db %10000010
	db %1000
	db %110

	db 0 ; padding

KangaskhanBaseStats: ; 0x39056
	db DEX_KANGASKHAN ; pokedex id
	db 105 ; base hp
	db 95 ; base attack
	db 80 ; base defense
	db 90 ; base speed
	db 40 ; base special

	db NORMAL ; species type 1
	db NORMAL ; species type 2

	db 45 ; catch rate
	db 175 ; base exp yield
	db $77 ; sprite dimensions

	dw KangaskhanPicFront
	dw KangaskhanPicBack
	
	; attacks known at lvl 0
	db COMET_PUNCH
	db RAGE
	db 0
	db 0

	db 0 ; growth rate
	
	; learnset
	db %10110001
	db %1111111
	db %10001111
	db %11000111
	db %10100010
	db %10001000
	db %110010

	db 0 ; padding

HorseaBaseStats: ; 0x39072
	db DEX_HORSEA ; pokedex id
	db 30 ; base hp
	db 40 ; base attack
	db 70 ; base defense
	db 60 ; base speed
	db 70 ; base special

	db WATER ; species type 1
	db WATER ; species type 2

	db 225 ; catch rate
	db 83 ; base exp yield
	db $55 ; sprite dimensions

	dw HorseaPicFront
	dw HorseaPicBack
	
	; attacks known at lvl 0
	db BUBBLE
	db 0
	db 0
	db 0

	db 0 ; growth rate
	
	; learnset
	db %100000
	db %111111
	db %1000
	db %11000000
	db %11000010
	db %1000
	db %10010

	db 0 ; padding

SeadraBaseStats: ; 0x3908e
	db DEX_SEADRA ; pokedex id
	db 55 ; base hp
	db 65 ; base attack
	db 95 ; base defense
	db 85 ; base speed
	db 95 ; base special

	db WATER ; species type 1
	db WATER ; species type 2

	db 75 ; catch rate
	db 155 ; base exp yield
	db $66 ; sprite dimensions

	dw SeadraPicFront
	dw SeadraPicBack
	
	; attacks known at lvl 0
	db BUBBLE
	db SMOKESCREEN
	db 0
	db 0

	db 0 ; growth rate
	
	; learnset
	db %100000
	db %1111111
	db %1000
	db %11000000
	db %11000010
	db %1000
	db %10010

	db 0 ; padding

GoldeenBaseStats: ; 0x390aa
	db DEX_GOLDEEN ; pokedex id
	db 45 ; base hp
	db 67 ; base attack
	db 60 ; base defense
	db 63 ; base speed
	db 50 ; base special

	db WATER ; species type 1
	db WATER ; species type 2

	db 225 ; catch rate
	db 111 ; base exp yield
	db $66 ; sprite dimensions

	dw GoldeenPicFront
	dw GoldeenPicBack
	
	; attacks known at lvl 0
	db PECK
	db TAIL_WHIP
	db 0
	db 0

	db 0 ; growth rate
	
	; learnset
	db %1100000
	db %111111
	db %1000
	db %11000000
	db %11000010
	db %1000
	db %10010

	db 0 ; padding

SeakingBaseStats: ; 0x390c6
	db DEX_SEAKING ; pokedex id
	db 80 ; base hp
	db 92 ; base attack
	db 65 ; base defense
	db 68 ; base speed
	db 80 ; base special

	db WATER ; species type 1
	db WATER ; species type 2

	db 60 ; catch rate
	db 170 ; base exp yield
	db $77 ; sprite dimensions

	dw SeakingPicFront
	dw SeakingPicBack
	
	; attacks known at lvl 0
	db PECK
	db TAIL_WHIP
	db SUPERSONIC
	db 0

	db 0 ; growth rate
	
	; learnset
	db %1100000
	db %1111111
	db %1000
	db %11000000
	db %11000010
	db %1000
	db %10010

	db 0 ; padding

StaryuBaseStats: ; 0x390e2
	db DEX_STARYU ; pokedex id
	db 30 ; base hp
	db 45 ; base attack
	db 55 ; base defense
	db 85 ; base speed
	db 70 ; base special

	db WATER ; species type 1
	db WATER ; species type 2

	db 225 ; catch rate
	db 106 ; base exp yield
	db $66 ; sprite dimensions

	dw StaryuPicFront
	dw StaryuPicBack
	
	; attacks known at lvl 0
	db TACKLE
	db 0
	db 0
	db 0

	db 5 ; growth rate
	
	; learnset
	db %100000
	db %111111
	db %10001000
	db %11110001
	db %11000011
	db %111000
	db %1010011

	db 0 ; padding

StarmieBaseStats: ; 0x390fe
	db DEX_STARMIE ; pokedex id
	db 60 ; base hp
	db 75 ; base attack
	db 85 ; base defense
	db 115 ; base speed
	db 100 ; base special

	db WATER ; species type 1
	db PSYCHIC ; species type 2

	db 60 ; catch rate
	db 207 ; base exp yield
	db $66 ; sprite dimensions

	dw StarmiePicFront
	dw StarmiePicBack
	
	; attacks known at lvl 0
	db TACKLE
	db WATER_GUN
	db HARDEN
	db 0

	db 5 ; growth rate
	
	; learnset
	db %100000
	db %1111111
	db %10001000
	db %11110001
	db %11000011
	db %111000
	db %1010011

	db 0 ; padding

MrMimeBaseStats: ; 0x3911a
	db DEX_MR_MIME ; pokedex id
	db 40 ; base hp
	db 45 ; base attack
	db 65 ; base defense
	db 90 ; base speed
	db 100 ; base special

	db PSYCHIC ; species type 1
	db PSYCHIC ; species type 2

	db 45 ; catch rate
	db 136 ; base exp yield
	db $66 ; sprite dimensions

	dw MrMimePicFront
	dw MrMimePicBack
	
	; attacks known at lvl 0
	db CONFUSION
	db BARRIER
	db 0
	db 0

	db 0 ; growth rate
	
	; learnset
	db %10110001
	db %1000011
	db %10101111
	db %11110001
	db %10000111
	db %111000
	db %1000010

	db 0 ; padding

ScytherBaseStats: ; 0x39136
	db DEX_SCYTHER ; pokedex id
	db 70 ; base hp
	db 110 ; base attack
	db 80 ; base defense
	db 105 ; base speed
	db 55 ; base special

	db BUG ; species type 1
	db FLYING ; species type 2

	db 45 ; catch rate
	db 187 ; base exp yield
	db $77 ; sprite dimensions

	dw ScytherPicFront
	dw ScytherPicBack
	
	; attacks known at lvl 0
	db QUICK_ATTACK
	db 0
	db 0
	db 0

	db 0 ; growth rate
	
	; learnset
	db %100100
	db %1000011
	db %1000
	db %11000000
	db %11000010
	db %1000
	db %110

	db 0 ; padding

JynxBaseStats: ; 0x39152
	db DEX_JYNX ; pokedex id
	db 65 ; base hp
	db 50 ; base attack
	db 35 ; base defense
	db 95 ; base speed
	db 95 ; base special

	db ICE ; species type 1
	db PSYCHIC ; species type 2

	db 45 ; catch rate
	db 137 ; base exp yield
	db $66 ; sprite dimensions

	dw JynxPicFront
	dw JynxPicBack
	
	; attacks known at lvl 0
	db POUND
	db LOVELY_KISS
	db 0
	db 0

	db 0 ; growth rate
	
	; learnset
	db %10110001
	db %1111111
	db %1111
	db %11110000
	db %10000111
	db %101000
	db %10

	db 0 ; padding

ElectabuzzBaseStats: ; 0x3916e
	db DEX_ELECTABUZZ ; pokedex id
	db 65 ; base hp
	db 83 ; base attack
	db 57 ; base defense
	db 105 ; base speed
	db 85 ; base special

	db ELECTRIC ; species type 1
	db ELECTRIC ; species type 2

	db 45 ; catch rate
	db 156 ; base exp yield
	db $66 ; sprite dimensions

	dw ElectabuzzPicFront
	dw ElectabuzzPicBack
	
	; attacks known at lvl 0
	db QUICK_ATTACK
	db LEER
	db 0
	db 0

	db 0 ; growth rate
	
	; learnset
	db %10110001
	db %1000011
	db %10001111
	db %11110001
	db %11000111
	db %111000
	db %1100010

	db 0 ; padding

MagmarBaseStats: ; 0x3918a
	db DEX_MAGMAR ; pokedex id
	db 65 ; base hp
	db 95 ; base attack
	db 57 ; base defense
	db 93 ; base speed
	db 85 ; base special

	db FIRE ; species type 1
	db FIRE ; species type 2

	db 45 ; catch rate
	db 167 ; base exp yield
	db $66 ; sprite dimensions

	dw MagmarPicFront
	dw MagmarPicBack
	
	; attacks known at lvl 0
	db EMBER
	db 0
	db 0
	db 0

	db 0 ; growth rate
	
	; learnset
	db %10110001
	db %1000011
	db %1111
	db %11110000
	db %10100110
	db %101000
	db %100010

	db 0 ; padding

PinsirBaseStats: ; 0x391a6
	db DEX_PINSIR ; pokedex id
	db 65 ; base hp
	db 125 ; base attack
	db 100 ; base defense
	db 85 ; base speed
	db 55 ; base special

	db BUG ; species type 1
	db BUG ; species type 2

	db 45 ; catch rate
	db 200 ; base exp yield
	db $77 ; sprite dimensions

	dw PinsirPicFront
	dw PinsirPicBack
	
	; attacks known at lvl 0
	db VICEGRIP
	db 0
	db 0
	db 0

	db 5 ; growth rate
	
	; learnset
	db %10100100
	db %1000011
	db %1101
	db %11000000
	db %10
	db %1000
	db %100110

	db 0 ; padding

TaurosBaseStats: ; 0x391c2
	db DEX_TAUROS ; pokedex id
	db 75 ; base hp
	db 100 ; base attack
	db 95 ; base defense
	db 110 ; base speed
	db 70 ; base special

	db NORMAL ; species type 1
	db NORMAL ; species type 2

	db 45 ; catch rate
	db 211 ; base exp yield
	db $77 ; sprite dimensions

	dw TaurosPicFront
	dw TaurosPicBack
	
	; attacks known at lvl 0
	db TACKLE
	db 0
	db 0
	db 0

	db 5 ; growth rate
	
	; learnset
	db %11100000
	db %1110011
	db %10001000
	db %11000111
	db %10100010
	db %1000
	db %100010

	db 0 ; padding

MagikarpBaseStats: ; 0x391de
	db DEX_MAGIKARP ; pokedex id
	db 20 ; base hp
	db 10 ; base attack
	db 55 ; base defense
	db 80 ; base speed
	db 20 ; base special

	db WATER ; species type 1
	db WATER ; species type 2

	db 255 ; catch rate
	db 20 ; base exp yield
	db $66 ; sprite dimensions

	dw MagikarpPicFront
	dw MagikarpPicBack
	
	; attacks known at lvl 0
	db SPLASH
	db 0
	db 0
	db 0

	db 5 ; growth rate
	
	; learnset
	db %0
	db %0
	db %0
	db %0
	db %0
	db %0
	db %0

	db 0 ; padding

GyaradosBaseStats: ; 0x391fa
	db DEX_GYARADOS ; pokedex id
	db 95 ; base hp
	db 125 ; base attack
	db 79 ; base defense
	db 81 ; base speed
	db 100 ; base special

	db WATER ; species type 1
	db FLYING ; species type 2

	db 45 ; catch rate
	db 214 ; base exp yield
	db $77 ; sprite dimensions

	dw GyaradosPicFront
	dw GyaradosPicBack
	
	; attacks known at lvl 0
	db BITE
	db DRAGON_RAGE
	db LEER
	db HYDRO_PUMP

	db 5 ; growth rate
	
	; learnset
	db %10100000
	db %1111111
	db %11001000
	db %11000001
	db %10100011
	db %1000
	db %110010

	db 0 ; padding

LaprasBaseStats: ; 0x39216
	db DEX_LAPRAS ; pokedex id
	db 130 ; base hp
	db 85 ; base attack
	db 80 ; base defense
	db 60 ; base speed
	db 95 ; base special

	db WATER ; species type 1
	db ICE ; species type 2

	db 45 ; catch rate
	db 219 ; base exp yield
	db $77 ; sprite dimensions

	dw LaprasPicFront
	dw LaprasPicBack
	
	; attacks known at lvl 0
	db WATER_GUN
	db GROWL
	db 0
	db 0

	db 5 ; growth rate
	
	; learnset
	db %11100000
	db %1111111
	db %11101000
	db %11010001
	db %10000011
	db %101000
	db %110010

	db 0 ; padding

DittoBaseStats: ; 0x39232
	db DEX_DITTO ; pokedex id
	db 48 ; base hp
	db 48 ; base attack
	db 48 ; base defense
	db 48 ; base speed
	db 48 ; base special

	db NORMAL ; species type 1
	db NORMAL ; species type 2

	db 35 ; catch rate
	db 61 ; base exp yield
	db $55 ; sprite dimensions

	dw DittoPicFront
	dw DittoPicBack
	
	; attacks known at lvl 0
	db TRANSFORM
	db 0
	db 0
	db 0

	db 0 ; growth rate
	
	; learnset
	db %0
	db %0
	db %0
	db %0
	db %0
	db %0
	db %0

	db 0 ; padding

EeveeBaseStats: ; 0x3924e
	db DEX_EEVEE ; pokedex id
	db 55 ; base hp
	db 55 ; base attack
	db 50 ; base defense
	db 55 ; base speed
	db 65 ; base special

	db NORMAL ; species type 1
	db NORMAL ; species type 2

	db 45 ; catch rate
	db 92 ; base exp yield
	db $55 ; sprite dimensions

	dw EeveePicFront
	dw EeveePicBack
	
	; attacks known at lvl 0
	db TACKLE
	db SAND_ATTACK
	db 0
	db 0

	db 0 ; growth rate
	
	; learnset
	db %10100000
	db %11
	db %1000
	db %11000000
	db %11000011
	db %1000
	db %10

	db 0 ; padding

VaporeonBaseStats: ; 0x3926a
	db DEX_VAPOREON ; pokedex id
	db 130 ; base hp
	db 65 ; base attack
	db 60 ; base defense
	db 65 ; base speed
	db 110 ; base special

	db WATER ; species type 1
	db WATER ; species type 2

	db 45 ; catch rate
	db 196 ; base exp yield
	db $66 ; sprite dimensions

	dw VaporeonPicFront
	dw VaporeonPicBack
	
	; attacks known at lvl 0
	db TACKLE
	db SAND_ATTACK
	db QUICK_ATTACK
	db WATER_GUN

	db 0 ; growth rate
	
	; learnset
	db %10100000
	db %1111111
	db %1000
	db %11000000
	db %11000011
	db %1000
	db %10010

	db 0 ; padding

JolteonBaseStats: ; 0x39286
	db DEX_JOLTEON ; pokedex id
	db 65 ; base hp
	db 65 ; base attack
	db 60 ; base defense
	db 130 ; base speed
	db 110 ; base special

	db ELECTRIC ; species type 1
	db ELECTRIC ; species type 2

	db 45 ; catch rate
	db 197 ; base exp yield
	db $66 ; sprite dimensions

	dw JolteonPicFront
	dw JolteonPicBack
	
	; attacks known at lvl 0
	db TACKLE
	db SAND_ATTACK
	db QUICK_ATTACK
	db THUNDERSHOCK

	db 0 ; growth rate
	
	; learnset
	db %10100000
	db %1000011
	db %10001000
	db %11000001
	db %11000011
	db %11000
	db %1000010

	db 0 ; padding

FlareonBaseStats: ; 0x392a2
	db DEX_FLAREON ; pokedex id
	db 65 ; base hp
	db 130 ; base attack
	db 60 ; base defense
	db 65 ; base speed
	db 110 ; base special

	db FIRE ; species type 1
	db FIRE ; species type 2

	db 45 ; catch rate
	db 198 ; base exp yield
	db $66 ; sprite dimensions

	dw FlareonPicFront
	dw FlareonPicBack
	
	; attacks known at lvl 0
	db TACKLE
	db SAND_ATTACK
	db QUICK_ATTACK
	db EMBER

	db 0 ; growth rate
	
	; learnset
	db %10100000
	db %1000011
	db %1000
	db %11000000
	db %11100011
	db %1000
	db %10

	db 0 ; padding

PorygonBaseStats: ; 0x392be
	db DEX_PORYGON ; pokedex id
	db 65 ; base hp
	db 60 ; base attack
	db 70 ; base defense
	db 40 ; base speed
	db 75 ; base special

	db NORMAL ; species type 1
	db NORMAL ; species type 2

	db 45 ; catch rate
	db 130 ; base exp yield
	db $66 ; sprite dimensions

	dw PorygonPicFront
	dw PorygonPicBack
	
	; attacks known at lvl 0
	db TACKLE
	db SHARPEN
	db CONVERSION
	db 0

	db 0 ; growth rate
	
	; learnset
	db %100000
	db %1110011
	db %10001000
	db %11110001
	db %11000011
	db %111000
	db %1000011

	db 0 ; padding

OmanyteBaseStats: ; 0x392da
	db DEX_OMANYTE ; pokedex id
	db 35 ; base hp
	db 40 ; base attack
	db 100 ; base defense
	db 35 ; base speed
	db 90 ; base special

	db ROCK ; species type 1
	db WATER ; species type 2

	db 45 ; catch rate
	db 120 ; base exp yield
	db $55 ; sprite dimensions

	dw OmanytePicFront
	dw OmanytePicBack
	
	; attacks known at lvl 0
	db WATER_GUN
	db WITHDRAW
	db 0
	db 0

	db 0 ; growth rate
	
	; learnset
	db %10100000
	db %111111
	db %1000
	db %11000000
	db %11
	db %1000
	db %10010

	db 0 ; padding

OmastarBaseStats: ; 0x392f6
	db DEX_OMASTAR ; pokedex id
	db 70 ; base hp
	db 60 ; base attack
	db 125 ; base defense
	db 55 ; base speed
	db 115 ; base special

	db ROCK ; species type 1
	db WATER ; species type 2

	db 45 ; catch rate
	db 199 ; base exp yield
	db $66 ; sprite dimensions

	dw OmastarPicFront
	dw OmastarPicBack
	
	; attacks known at lvl 0
	db WATER_GUN
	db WITHDRAW
	db HORN_ATTACK
	db 0

	db 0 ; growth rate
	
	; learnset
	db %11100000
	db %1111111
	db %1101
	db %11000000
	db %10000011
	db %1000
	db %10010

	db 0 ; padding

KabutoBaseStats: ; 0x39312
	db DEX_KABUTO ; pokedex id
	db 30 ; base hp
	db 80 ; base attack
	db 90 ; base defense
	db 55 ; base speed
	db 45 ; base special

	db ROCK ; species type 1
	db WATER ; species type 2

	db 45 ; catch rate
	db 119 ; base exp yield
	db $55 ; sprite dimensions

	dw KabutoPicFront
	dw KabutoPicBack
	
	; attacks known at lvl 0
	db SCRATCH
	db HARDEN
	db 0
	db 0

	db 0 ; growth rate
	
	; learnset
	db %10100000
	db %111111
	db %1000
	db %11000000
	db %11
	db %1000
	db %10010

	db 0 ; padding

KabutopsBaseStats: ; 0x3932e
	db DEX_KABUTOPS ; pokedex id
	db 60 ; base hp
	db 115 ; base attack
	db 105 ; base defense
	db 80 ; base speed
	db 70 ; base special

	db ROCK ; species type 1
	db WATER ; species type 2

	db 45 ; catch rate
	db 201 ; base exp yield
	db $66 ; sprite dimensions

	dw KabutopsPicFront
	dw KabutopsPicBack
	
	; attacks known at lvl 0
	db SCRATCH
	db HARDEN
	db ABSORB
	db 0

	db 0 ; growth rate
	
	; learnset
	db %10110110
	db %1111111
	db %1101
	db %11000000
	db %10000011
	db %1000
	db %10010

	db 0 ; padding

AerodactylBaseStats: ; 0x3934a
	db DEX_AERODACTYL ; pokedex id
	db 80 ; base hp
	db 105 ; base attack
	db 65 ; base defense
	db 130 ; base speed
	db 60 ; base special

	db ROCK ; species type 1
	db FLYING ; species type 2

	db 45 ; catch rate
	db 202 ; base exp yield
	db $77 ; sprite dimensions

	dw AerodactylPicFront
	dw AerodactylPicBack
	
	; attacks known at lvl 0
	db WING_ATTACK
	db AGILITY
	db 0
	db 0

	db 5 ; growth rate
	
	; learnset
	db %101010
	db %1000011
	db %1001000
	db %11000000
	db %1100011
	db %1100
	db %1010

	db 0 ; padding

SnorlaxBaseStats: ; 0x39366
	db DEX_SNORLAX ; pokedex id
	db 160 ; base hp
	db 110 ; base attack
	db 65 ; base defense
	db 30 ; base speed
	db 65 ; base special

	db NORMAL ; species type 1
	db NORMAL ; species type 2

	db 25 ; catch rate
	db 154 ; base exp yield
	db $77 ; sprite dimensions

	dw SnorlaxPicFront
	dw SnorlaxPicBack
	
	; attacks known at lvl 0
	db HEADBUTT
	db AMNESIA
	db REST
	db 0

	db 5 ; growth rate
	
	; learnset
	db %10110001
	db %11111111
	db %10101111
	db %11010111
	db %10101111
	db %10101000
	db %110010

	db 0 ; padding

ArticunoBaseStats: ; 0x39382
	db DEX_ARTICUNO ; pokedex id
	db 90 ; base hp
	db 85 ; base attack
	db 100 ; base defense
	db 85 ; base speed
	db 125 ; base special

	db ICE ; species type 1
	db FLYING ; species type 2

	db 3 ; catch rate
	db 215 ; base exp yield
	db $77 ; sprite dimensions

	dw ArticunoPicFront
	dw ArticunoPicBack
	
	; attacks known at lvl 0
	db PECK
	db ICE_BEAM
	db 0
	db 0

	db 5 ; growth rate
	
	; learnset
	db %101010
	db %1111111
	db %1000
	db %11000000
	db %1000011
	db %1100
	db %1010

	db 0 ; padding

ZapdosBaseStats: ; 0x3939e
	db DEX_ZAPDOS ; pokedex id
	db 90 ; base hp
	db 90 ; base attack
	db 85 ; base defense
	db 100 ; base speed
	db 125 ; base special

	db ELECTRIC ; species type 1
	db FLYING ; species type 2

	db 3 ; catch rate
	db 216 ; base exp yield
	db $77 ; sprite dimensions

	dw ZapdosPicFront
	dw ZapdosPicBack
	
	; attacks known at lvl 0
	db THUNDERSHOCK
	db DRILL_PECK
	db 0
	db 0

	db 5 ; growth rate
	
	; learnset
	db %101010
	db %1000011
	db %10001000
	db %11000001
	db %1000011
	db %11100
	db %1001010

	db 0 ; padding

MoltresBaseStats: ; 0x393ba
	db DEX_MOLTRES ; pokedex id
	db 90 ; base hp
	db 100 ; base attack
	db 90 ; base defense
	db 90 ; base speed
	db 125 ; base special

	db FIRE ; species type 1
	db FLYING ; species type 2

	db 3 ; catch rate
	db 217 ; base exp yield
	db $77 ; sprite dimensions

	dw MoltresPicFront
	dw MoltresPicBack
	
	; attacks known at lvl 0
	db PECK
	db FIRE_SPIN
	db 0
	db 0

	db 5 ; growth rate
	
	; learnset
	db %101010
	db %1000011
	db %1000
	db %11000000
	db %1100011
	db %1100
	db %1010

	db 0 ; padding

DratiniBaseStats: ; 0x393d6
	db DEX_DRATINI ; pokedex id
	db 41 ; base hp
	db 64 ; base attack
	db 45 ; base defense
	db 50 ; base speed
	db 50 ; base special

	db DRAGON ; species type 1
	db DRAGON ; species type 2

	db 45 ; catch rate
	db 67 ; base exp yield
	db $55 ; sprite dimensions

	dw DratiniPicFront
	dw DratiniPicBack
	
	; attacks known at lvl 0
	db WRAP
	db LEER
	db 0
	db 0

	db 5 ; growth rate
	
	; learnset
	db %10100000
	db %111111
	db %11001000
	db %11000001
	db %11100011
	db %11000
	db %10010

	db 0 ; padding

DragonairBaseStats: ; 0x393f2
	db DEX_DRAGONAIR ; pokedex id
	db 61 ; base hp
	db 84 ; base attack
	db 65 ; base defense
	db 70 ; base speed
	db 70 ; base special

	db DRAGON ; species type 1
	db DRAGON ; species type 2

	db 45 ; catch rate
	db 144 ; base exp yield
	db $66 ; sprite dimensions

	dw DragonairPicFront
	dw DragonairPicBack
	
	; attacks known at lvl 0
	db WRAP
	db LEER
	db THUNDER_WAVE
	db 0

	db 5 ; growth rate
	
	; learnset
	db %11100000
	db %111111
	db %11001000
	db %11000001
	db %11100011
	db %11000
	db %10010

	db 0 ; padding

DragoniteBaseStats: ; 0x3940e
	db DEX_DRAGONITE ; pokedex id
	db 91 ; base hp
	db 134 ; base attack
	db 95 ; base defense
	db 80 ; base speed
	db 100 ; base special

	db DRAGON ; species type 1
	db FLYING ; species type 2

	db 45 ; catch rate
	db 218 ; base exp yield
	db $77 ; sprite dimensions

	dw DragonitePicFront
	dw DragonitePicBack
	
	; attacks known at lvl 0
	db WRAP
	db LEER
	db THUNDER_WAVE
	db AGILITY

	db 5 ; growth rate
	
	; learnset
	db %11100010
	db %1111111
	db %11001000
	db %11000001
	db %11100011
	db %11000
	db %110010

	db 0 ; padding

MewtwoBaseStats: ; 0x3942a
	db DEX_MEWTWO ; pokedex id
	db 106 ; base hp
	db 110 ; base attack
	db 90 ; base defense
	db 130 ; base speed
	db 154 ; base special

	db PSYCHIC ; species type 1
	db PSYCHIC ; species type 2

	db 3 ; catch rate
	db 220 ; base exp yield
	db $77 ; sprite dimensions

	dw MewtwoPicFront
	dw MewtwoPicBack
	
	; attacks known at lvl 0
	db CONFUSION
	db DISABLE
	db SWIFT
	db PSYCHIC_M

	db 5 ; growth rate
	
	; learnset
	db %10110001
	db %11111111
	db %10101111
	db %11110001
	db %10101111
	db %111000
	db %1100011

	db 0 ; padding

INCBIN "baserom.gbc",$39446,$43e

ReadMove: ; 5884
	push hl
	push de
	push bc
	dec a
	ld hl,Moves
	ld bc,6
	call AddNTimes
	ld de,$CFCC
	call CopyData
	pop bc
	pop de
	pop hl
	ret

; trainer data: from 5C53 to 652E

INCBIN "baserom.gbc",$3989B,$39914 - $3989B

; trainer pic pointers and base money.
dw YoungsterPic
db 0,$15,0

dw BugCatcherPic
db 0,$10,0

dw LassPic
db 0,$15,0

dw SailorPic
db 0,$30,0

dw JrTrainerMPic
db 0,$20,0

dw JrTrainerFPic
db 0,$20,0

dw PokemaniacPic
db 0,$50,0

dw SuperNerdPic
db 0,$25,0

dw HikerPic
db 0,$35,0

dw BikerPic
db 0,$20,0

dw BurglarPic
db 0,$90,0

dw EngineerPic
db 0,$50,0

dw JugglerPic
db 0,$35,0

dw FisherPic
db 0,$35,0

dw SwimmerPic
db 0,$05,0

dw CueBallPic
db 0,$25,0

dw GamblerPic
db 0,$70,0

dw BeautyPic
db 0,$70,0

dw PsychicPic
db 0,$10,0

dw RockerPic
db 0,$25,0

dw JugglerPic
db 0,$35,0

dw TamerPic
db 0,$40,0

dw BirdKeeperPic
db 0,$25,0

dw BlackbeltPic
db 0,$25,0

dw Rival1Pic
db 0,$35,0

dw ProfOakPic
db 0,$99,0

dw ChiefPic
db 0,$30,0

dw ScientistPic
db 0,$50,0

dw GiovanniPic
db 0,$99,0

dw RocketPic
db 0,$30,0

dw CooltrainerMPic
db 0,$35,0

dw CooltrainerFPic
db 0,$35,0

dw BrunoPic
db 0,$99,0

dw BrockPic
db 0,$99,0

dw MistyPic
db 0,$99,0

dw LtSurgePic
db 0,$99,0

dw ErikaPic
db 0,$99,0

dw KogaPic
db 0,$99,0

dw BlainePic
db 0,$99,0

dw SabrinaPic
db 0,$99,0

dw GentlemanPic
db 0,$70,0

dw Rival2Pic
db 0,$65,0

dw Rival3Pic
db 0,$99,0

dw LoreleiPic
db 0,$99,0

dw ChannelerPic
db 0,$30,0

dw AgathaPic
db 0,$99,0

dw LancePic
db 0,$99,0

TrainerNames: ; 59FF
	db "YOUNGSTER@"
	db "BUG CATCHER@"
	db "LASS@"
	db "SAILOR@"
	db "JR.TRAINER♂@"
	db "JR.TRAINER♀@"
	db "POKéMANIAC@"
	db "SUPER NERD@"
	db "HIKER@"
	db "BIKER@"
	db "BURGLAR@"
	db "ENGINEER@"
	db "JUGGLER@"
	db "FISHERMAN@"
	db "SWIMMER@"
	db "CUE BALL@"
	db "GAMBLER@"
	db "BEAUTY@"
	db "PSYCHIC@"
	db "ROCKER@"
	db "JUGGLER@"
	db "TAMER@"
	db "BIRD KEEPER@"
	db "BLACKBELT@"
	db "RIVAL1@"
	db "PROF.OAK@"
	db "CHIEF@"
	db "SCIENTIST@"
	db "GIOVANNI@"
	db "ROCKET@"
	db "COOLTRAINER♂@"
	db "COOLTRAINER♀@"
	db "BRUNO@"
	db "BROCK@"
	db "MISTY@"
	db "LT.SURGE@"
	db "ERIKA@"
	db "KOGA@"
	db "BLAINE@"
	db "SABRINA@"
	db "GENTLEMAN@"
	db "RIVAL2@"
	db "RIVAL3@"
	db "LORELEI@"
	db "CHANNELER@"
	db "AGATHA@"
	db "LANCE@"

INCBIN "baserom.gbc",$39B87,$39C53 - $39B87

ReadTrainer: ; 5C53

; don't change any moves in a link battle
	ld a,[W_ISLINKBATTLE]
	and a
	ret nz

; set [W_ENEMYMONCOUNT] to 0, [$D89D] to FF
; XXX first is total enemy pokemon?
; XXX second is species of first pokemon?
	ld hl,W_ENEMYMONCOUNT
	xor a
	ld [hli],a
	dec a
	ld [hl],a

; get the pointer to trainer data for this class
	ld a,[W_CUROPPONENT]
	sub $C9 ; convert value from pokemon to trainer
	add a,a
	ld hl,TrainerDataPointers
	ld c,a
	ld b,0
	add hl,bc ; hl points to trainer class
	ld a,[hli]
	ld h,[hl]
	ld l,a
	ld a,[W_TRAINERNO]
	ld b,a
; At this point b contains the trainer number,
; and hl points to the trainer class.
; Our next task is to iterate through the trainers,
; decrementing b each time, until we get to the right one.
.outer\@
	dec b
	jr z,.IterateTrainer
.inner\@
	ld a,[hli]
	and a
	jr nz,.inner\@
	jr .outer\@

; if the first byte of trainer data is FF,
; - each pokemon has a specific level
;      (as opposed to the whole team being of the same level)
; - if [W_LONEATTACKNO] != 0, one pokemon on the team has a special move
; else the first byte is the level of every pokemon on the team
.IterateTrainer
	ld a,[hli]
	cp $FF ; is the trainer special?
	jr z,.SpecialTrainer\@ ; if so, check for special moves
	ld [W_CURENEMYLVL],a
.LoopTrainerData\@
	ld a,[hli]
	and a ; have we reached the end of the trainer data?
	jr z,.FinishUp\@
	ld [$CF91],a ; write species somewhere (XXX why?)
	ld a,1
	ld [$CC49],a
	push hl
	call AddPokemonToParty
	pop hl
	jr .LoopTrainerData\@
.SpecialTrainer\@
; if this code is being run:
; - each pokemon has a specific level
;      (as opposed to the whole team being of the same level)
; - if [W_LONEATTACKNO] != 0, one pokemon on the team has a special move
	ld a,[hli]
	and a ; have we reached the end of the trainer data?
	jr z,.AddLoneMove\@
	ld [W_CURENEMYLVL],a
	ld a,[hli]
	ld [$CF91],a
	ld a,1
	ld [$CC49],a
	push hl
	call AddPokemonToParty
	pop hl
	jr .SpecialTrainer\@
.AddLoneMove\@
; does the trainer have a single monster with a different move
	ld a,[W_LONEATTACKNO] ; Brock is 01, Misty is 02, Erika is 04, etc
	and a
	jr z,.AddTeamMove\@
	dec a
	add a,a
	ld c,a
	ld b,0
	ld hl,LoneMoves
	add hl,bc
	ld a,[hli]
	ld d,[hl]
	ld hl,W_ENEMYMON1MOVE3
	ld bc,W_ENEMYMON2MOVE3 - W_ENEMYMON1MOVE3
	call AddNTimes
	ld [hl],d
	jr .FinishUp\@
.AddTeamMove\@
; check if our trainer's team has special moves

; get trainer class number
	ld a,[$D059]
	sub $C8
	ld b,a
	ld hl,TeamMoves

; iterate through entries in TeamMoves, checking each for our trainer class
.IterateTeamMoves\@
	ld a,[hli]
	cp b
	jr z,.GiveTeamMoves\@ ; is there a match?
	inc hl ; if not, go to the next entry
	inc a
	jr nz,.IterateTeamMoves\@

	; no matches found. is this trainer champion rival?
	ld a,b
	cp SONY3
	jr z,.ChampionRival\@
	jr .FinishUp\@ ; nope
.GiveTeamMoves\@
	ld a,[hl]
	ld [$D95E],a
	jr .FinishUp\@
.ChampionRival\@ ; give moves to his team

; pidgeot
	ld a,SKY_ATTACK
	ld [W_ENEMYMON1MOVE3],a

; starter
	ld a,[W_RIVALSTARTER]
	cp BULBASAUR
	ld b,MEGA_DRAIN
	jr z,.GiveStarterMove\@
	cp CHARMANDER
	ld b,FIRE_BLAST
	jr z,.GiveStarterMove\@
	ld b,BLIZZARD ; must be squirtle
.GiveStarterMove\@
	ld a,b
	ld [W_ENEMYMON6MOVE3],a
.FinishUp\@ ; XXX this needs documenting
	xor a       ; clear D079-D07B
	ld de,$D079
	ld [de],a
	inc de
	ld [de],a
	inc de
	ld [de],a
	ld a,[W_CURENEMYLVL]
	ld b,a
.LastLoop\@
	ld hl,$D047
	ld c,2
	push bc
	ld a,$B
	call Predef
	pop bc
	inc de
	inc de
	dec b
	jr nz,.LastLoop\@
	ret

LoneMoves: ; 5D22
; these are used for gym leaders.
; this is not automatic! you have to write the number you want to W_LONEATTACKNO
; first. e.g., erika's script writes 4 to W_LONEATTACKNO to get mega drain,
; the fourth entry in the list.

; first byte:  pokemon in the trainer's party that gets the move
; second byte: move
; unterminated
	db 1,BIDE
	db 1,BUBBLEBEAM
	db 2,THUNDERBOLT
	db 2,MEGA_DRAIN
	db 3,TOXIC
	db 3,PSYWAVE
	db 3,FIRE_BLAST
	db 4,FISSURE

TeamMoves: ; 5D32
; these are used for elite four.
; this is automatic, based on trainer class.
; don't be confused by LoneMoves above, the two data structures are
	; _completely_ unrelated.

; first byte: trainer (all trainers in this class have this move)
; second byte: move
; ff-terminated
	db LORELEI,BLIZZARD
	db BRUNO,FISSURE
	db AGATHA,TOXIC
	db LANCE,BARRIER
	db $FF

TrainerDataPointers: ; 5D3B
	dw YoungsterData,BugCatcherData,LassData,SailorData,JrTrainerMData
	dw JrTrainerFData,PokemaniacData,SuperNerdData,HikerData,BikerData
	dw BurglarData,EngineerData,Juggler1Data,FisherData,SwimmerData
	dw CueBallData,GamblerData,BeautyData,PsychicData,RockerData
	dw JugglerData,TamerData,BirdKeeperData,BlackbeltData,Green1Data
	dw ProfOakData,ChiefData,ScientistData,GiovanniData,RocketData
	dw CooltrainerMData,CooltrainerFData,BrunoData,BrockData,MistyData
	dw LtSurgeData,ErikaData,KogaData,BlaineData,SabrinaData
	dw GentlemanData,Green2Data,Green3Data,LoreleiData,ChannelerData
	dw AgathaData,LanceData

; if first byte != FF, then
	; first byte is level (of all pokemon on this team)
	; all the next bytes are pokemon species
	; null-terminated
; if first byte == FF, then
	; first byte is FF (obviously)
	; every next two bytes are a level and species
	; null-terminated

YoungsterData:
	db 11,RATTATA,EKANS,0
	db 14,SPEAROW,0
	db 10,RATTATA,RATTATA,ZUBAT,0
	db 14,RATTATA,EKANS,ZUBAT,0
	db 15,RATTATA,SPEAROW,0
	db 17,SLOWPOKE,0
	db 14,EKANS,SANDSHREW,0
	db 21,NIDORAN_M,0
	db 21,EKANS,0
	db 19,SANDSHREW,ZUBAT,0
	db 17,RATTATA,RATTATA,RATICATE,0
	db 18,NIDORAN_M,NIDORINO,0
	db 17,SPEAROW,RATTATA,RATTATA,SPEAROW,0
BugCatcherData:
	db 6,WEEDLE,CATERPIE,0
	db 7,WEEDLE,KAKUNA,WEEDLE,0
	db 9,WEEDLE,0
	db 10,CATERPIE,WEEDLE,CATERPIE,0
	db 9,WEEDLE,KAKUNA,CATERPIE,METAPOD,0
	db 11,CATERPIE,METAPOD,0
	db 11,WEEDLE,KAKUNA,0
	db 10,CATERPIE,METAPOD,CATERPIE,0
	db 14,CATERPIE,WEEDLE,0
	db 16,WEEDLE,CATERPIE,WEEDLE,0
	db 20,BUTTERFREE,0
	db 18,METAPOD,CATERPIE,VENONAT,0
	db 19,BEEDRILL,BEEDRILL,0
	db 20,CATERPIE,WEEDLE,VENONAT,0
LassData:
	db 9,PIDGEY,PIDGEY,0
	db 10,RATTATA,NIDORAN_M,0
	db 14,JIGGLYPUFF,0
	db 31,PARAS,PARAS,PARASECT,0
	db 11,ODDISH,BELLSPROUT,0
	db 14,CLEFAIRY,0
	db 16,PIDGEY,NIDORAN_F,0
	db 14,PIDGEY,NIDORAN_F,0
	db 15,NIDORAN_M,NIDORAN_F,0
	db 13,ODDISH,PIDGEY,ODDISH,0
	db 18,PIDGEY,NIDORAN_F,0
	db 18,RATTATA,PIKACHU,0
	db 23,NIDORAN_F,NIDORINA,0
	db 24,MEOWTH,MEOWTH,MEOWTH,0
	db 19,PIDGEY,RATTATA,NIDORAN_M,MEOWTH,PIKACHU,0
	db 22,CLEFAIRY,CLEFAIRY,0
	db 23,BELLSPROUT,WEEPINBELL,0
	db 23,ODDISH,GLOOM,0
SailorData:
	db 18,MACHOP,SHELLDER,0
	db 17,MACHOP,TENTACOOL,0
	db 21,SHELLDER,0
	db 17,HORSEA,SHELLDER,TENTACOOL,0
	db 18,TENTACOOL,STARYU,0
	db 17,HORSEA,HORSEA,HORSEA,0
	db 20,MACHOP,0
	db 21,PIKACHU,PIKACHU,0
JrTrainerMData:
	db 11,DIGLETT,SANDSHREW,0
	db 14,RATTATA,EKANS,0
	db 18,MANKEY,0
	db 20,SQUIRTLE,0
	db 16,SPEAROW,RATICATE,0
	db 18,DIGLETT,DIGLETT,SANDSHREW,0
	db 21,GROWLITHE,CHARMANDER,0
	db 19,RATTATA,DIGLETT,EKANS,SANDSHREW,0
	db 29,NIDORAN_M,NIDORINO,0
JrTrainerFData:
	db 19,GOLDEEN,0
	db 16,RATTATA,PIKACHU,0
	db 16,PIDGEY,PIDGEY,PIDGEY,0
	db 22,BULBASAUR,0
	db 18,ODDISH,BELLSPROUT,ODDISH,BELLSPROUT,0
	db 23,MEOWTH,0
	db 20,PIKACHU,CLEFAIRY,0
	db 21,PIDGEY,PIDGEOTTO,0
	db 21,JIGGLYPUFF,PIDGEY,MEOWTH,0
	db 22,ODDISH,BULBASAUR,0
	db 24,BULBASAUR,IVYSAUR,0
	db 24,PIDGEY,MEOWTH,RATTATA,PIKACHU,MEOWTH,0
	db 30,POLIWAG,POLIWAG,0
	db 27,PIDGEY,MEOWTH,PIDGEY,PIDGEOTTO,0
	db 28,GOLDEEN,POLIWAG,HORSEA,0
	db 31,GOLDEEN,SEAKING,0
	db 22,BELLSPROUT,CLEFAIRY,0
	db 20,MEOWTH,ODDISH,PIDGEY,0
	db 19,PIDGEY,RATTATA,RATTATA,BELLSPROUT,0
	db 28,GLOOM,ODDISH,ODDISH,0
	db 29,PIKACHU,RAICHU,0
	db 33,CLEFAIRY,0
	db 29,BELLSPROUT,ODDISH,TANGELA,0
	db 30,TENTACOOL,HORSEA,SEEL,0
PokemaniacData:
	db 30,RHYHORN,LICKITUNG,0
	db 20,CUBONE,SLOWPOKE,0
	db 20,SLOWPOKE,SLOWPOKE,SLOWPOKE,0
	db 22,CHARMANDER,CUBONE,0
	db 25,SLOWPOKE,0
	db 40,CHARMELEON,LAPRAS,LICKITUNG,0
	db 23,CUBONE,SLOWPOKE,0
SuperNerdData:
	db 11,MAGNEMITE,VOLTORB,0
	db 12,GRIMER,VOLTORB,KOFFING,0
	db 20,VOLTORB,KOFFING,VOLTORB,MAGNEMITE,0
	db 22,GRIMER,MUK,GRIMER,0
	db 26,KOFFING,0
	db 22,KOFFING,MAGNEMITE,WEEZING,0
	db 20,MAGNEMITE,MAGNEMITE,KOFFING,MAGNEMITE,0
	db 24,MAGNEMITE,VOLTORB,0
	db 36,VULPIX,VULPIX,NINETALES,0
	db 34,PONYTA,CHARMANDER,VULPIX,GROWLITHE,0
	db 41,RAPIDASH,0
	db 37,GROWLITHE,VULPIX,0
HikerData:
	db 10,GEODUDE,GEODUDE,ONIX,0
	db 15,MACHOP,GEODUDE,0
	db 13,GEODUDE,GEODUDE,MACHOP,GEODUDE,0
	db 17,ONIX,0
	db 21,GEODUDE,ONIX,0
	db 20,GEODUDE,MACHOP,GEODUDE,0
	db 21,GEODUDE,ONIX,0
	db 19,ONIX,GRAVELER,0
	db 21,GEODUDE,GEODUDE,GRAVELER,0
	db 25,GEODUDE,0
	db 20,MACHOP,ONIX,0
	db 19,GEODUDE,MACHOP,GEODUDE,GEODUDE,0
	db 20,ONIX,ONIX,GEODUDE,0
	db 21,GEODUDE,GRAVELER,0
BikerData:
	db 28,KOFFING,KOFFING,KOFFING,0
	db 29,KOFFING,GRIMER,0
	db 25,KOFFING,KOFFING,WEEZING,KOFFING,GRIMER,0
	db 28,KOFFING,GRIMER,WEEZING,0
	db 29,GRIMER,KOFFING,0
	db 33,WEEZING,0
	db 26,GRIMER,GRIMER,GRIMER,GRIMER,0
	db 28,WEEZING,KOFFING,WEEZING,0
	db 33,MUK,0
	db 29,VOLTORB,VOLTORB,0
	db 29,WEEZING,MUK,0
	db 25,KOFFING,WEEZING,KOFFING,KOFFING,WEEZING,0
	db 26,KOFFING,KOFFING,GRIMER,KOFFING,0
	db 28,GRIMER,GRIMER,KOFFING,0
	db 29,KOFFING,MUK,0
BurglarData:
	db 29,GROWLITHE,VULPIX,0
	db 33,GROWLITHE,0
	db 28,VULPIX,CHARMANDER,PONYTA,0
	db 36,GROWLITHE,VULPIX,NINETALES,0
	db 41,PONYTA,0
	db 37,VULPIX,GROWLITHE,0
	db 34,CHARMANDER,CHARMELEON,0
	db 38,NINETALES,0
	db 34,GROWLITHE,PONYTA,0
EngineerData:
	db 21,VOLTORB,MAGNEMITE,0
	db 21,MAGNEMITE,0
	db 18,MAGNEMITE,MAGNEMITE,MAGNETON,0
Juggler1Data:
; none
FisherData:
	db 17,GOLDEEN,TENTACOOL,GOLDEEN,0
	db 17,TENTACOOL,STARYU,SHELLDER,0
	db 22,GOLDEEN,POLIWAG,GOLDEEN,0
	db 24,TENTACOOL,GOLDEEN,0
	db 27,GOLDEEN,0
	db 21,POLIWAG,SHELLDER,GOLDEEN,HORSEA,0
	db 28,SEAKING,GOLDEEN,SEAKING,SEAKING,0
	db 31,SHELLDER,CLOYSTER,0
	db 27,MAGIKARP,MAGIKARP,MAGIKARP,MAGIKARP,MAGIKARP,MAGIKARP,0
	db 33,SEAKING,GOLDEEN,0
	db 24,MAGIKARP,MAGIKARP,0
SwimmerData:
	db 16,HORSEA,SHELLDER,0
	db 30,TENTACOOL,SHELLDER,0
	db 29,GOLDEEN,HORSEA,STARYU,0
	db 30,POLIWAG,POLIWHIRL,0
	db 27,HORSEA,TENTACOOL,TENTACOOL,GOLDEEN,0
	db 29,GOLDEEN,SHELLDER,SEAKING,0
	db 30,HORSEA,HORSEA,0
	db 27,TENTACOOL,TENTACOOL,STARYU,HORSEA,TENTACRUEL,0
	db 31,SHELLDER,CLOYSTER,0
	db 35,STARYU,0
	db 28,HORSEA,HORSEA,SEADRA,HORSEA,0
	db 33,SEADRA,TENTACRUEL,0
	db 37,STARMIE,0
	db 33,STARYU,WARTORTLE,0
	db 32,POLIWHIRL,TENTACOOL,SEADRA,0
CueBallData:
	db 28,MACHOP,MANKEY,MACHOP,0
	db 29,MANKEY,MACHOP,0
	db 33,MACHOP,0
	db 29,MANKEY,PRIMEAPE,0
	db 29,MACHOP,MACHOKE,0
	db 33,MACHOKE,0
	db 26,MANKEY,MANKEY,MACHOKE,MACHOP,0
	db 29,PRIMEAPE,MACHOKE,0
	db 31,TENTACOOL,TENTACOOL,TENTACRUEL,0
GamblerData:
	db 18,POLIWAG,HORSEA,0
	db 18,BELLSPROUT,ODDISH,0
	db 18,VOLTORB,MAGNEMITE,0
	db 18,GROWLITHE,VULPIX,0
	db 22,POLIWAG,POLIWAG,POLIWHIRL,0
	db 22,ONIX,GEODUDE,GRAVELER,0
	db 24,GROWLITHE,VULPIX,0
BeautyData:
	db 21,ODDISH,BELLSPROUT,ODDISH,BELLSPROUT,0
	db 24,BELLSPROUT,BELLSPROUT,0
	db 26,EXEGGCUTE,0
	db 27,RATTATA,PIKACHU,RATTATA,0
	db 29,CLEFAIRY,MEOWTH,0
	db 35,SEAKING,0
	db 30,SHELLDER,SHELLDER,CLOYSTER,0
	db 31,POLIWAG,SEAKING,0
	db 29,PIDGEOTTO,WIGGLYTUFF,0
	db 29,BULBASAUR,IVYSAUR,0
	db 33,WEEPINBELL,BELLSPROUT,WEEPINBELL,0
	db 27,POLIWAG,GOLDEEN,SEAKING,GOLDEEN,POLIWAG,0
	db 30,GOLDEEN,SEAKING,0
	db 29,STARYU,STARYU,STARYU,0
	db 30,SEADRA,HORSEA,SEADRA,0
PsychicData:
	db 31,KADABRA,SLOWPOKE,MR_MIME,KADABRA,0
	db 34,MR_MIME,KADABRA,0
	db 33,SLOWPOKE,SLOWPOKE,SLOWBRO,0
	db 38,SLOWBRO,0
RockerData:
	db 20,VOLTORB,MAGNEMITE,VOLTORB,0
	db 29,VOLTORB,ELECTRODE,0
JugglerData:
	db 29,KADABRA,MR_MIME,0
	db 41,DROWZEE,HYPNO,KADABRA,KADABRA,0
	db 31,DROWZEE,DROWZEE,KADABRA,DROWZEE,0
	db 34,DROWZEE,HYPNO,0
	db 48,MR_MIME,0
	db 33,HYPNO,0
	db 38,HYPNO,0
	db 34,DROWZEE,KADABRA,0
TamerData:
	db 34,SANDSLASH,ARBOK,0
	db 33,ARBOK,SANDSLASH,ARBOK,0
	db 43,RHYHORN,0
	db 39,ARBOK,TAUROS,0
	db 44,PERSIAN,GOLDUCK,0
	db 42,RHYHORN,PRIMEAPE,ARBOK,TAUROS,0
BirdKeeperData:
	db 29,PIDGEY,PIDGEOTTO,0
	db 25,SPEAROW,PIDGEY,PIDGEY,SPEAROW,SPEAROW,0
	db 26,PIDGEY,PIDGEOTTO,SPEAROW,FEAROW,0
	db 33,FARFETCH_D,0
	db 29,SPEAROW,FEAROW,0
	db 26,PIDGEOTTO,FARFETCH_D,DODUO,PIDGEY,0
	db 28,DODRIO,DODUO,DODUO,0
	db 29,SPEAROW,FEAROW,0
	db 34,DODRIO,0
	db 26,SPEAROW,SPEAROW,FEAROW,SPEAROW,0
	db 30,FEAROW,FEAROW,PIDGEOTTO,0
	db 39,PIDGEOTTO,PIDGEOTTO,PIDGEY,PIDGEOTTO,0
	db 42,FARFETCH_D,FEAROW,0
	db 28,PIDGEY,DODUO,PIDGEOTTO,0
	db 26,PIDGEY,SPEAROW,PIDGEY,FEAROW,0
	db 29,PIDGEOTTO,FEAROW,0
	db 28,SPEAROW,DODUO,FEAROW,0
BlackbeltData:
	db 37,HITMONLEE,HITMONCHAN,0
	db 31,MANKEY,MANKEY,PRIMEAPE,0
	db 32,MACHOP,MACHOKE,0
	db 36,PRIMEAPE,0
	db 31,MACHOP,MANKEY,PRIMEAPE,0
	db 40,MACHOP,MACHOKE,0
	db 43,MACHOKE,0
	db 38,MACHOKE,MACHOP,MACHOKE,0
	db 43,MACHOKE,MACHOP,MACHOKE,0
Green1Data:
	db 5,SQUIRTLE,0
	db 5,BULBASAUR,0
	db 5,CHARMANDER,0
	db $FF,9,PIDGEY,8,SQUIRTLE,0
	db $FF,9,PIDGEY,8,BULBASAUR,0
	db $FF,9,PIDGEY,8,CHARMANDER,0
	db $FF,18,PIDGEOTTO,15,ABRA,15,RATTATA,17,SQUIRTLE,0
	db $FF,18,PIDGEOTTO,15,ABRA,15,RATTATA,17,BULBASAUR,0
	db $FF,18,PIDGEOTTO,15,ABRA,15,RATTATA,17,CHARMANDER,0
ProfOakData:
	db $FF,66,TAUROS,67,EXEGGUTOR,68,ARCANINE,69,BLASTOISE,70,GYARADOS,0
	db $FF,66,TAUROS,67,EXEGGUTOR,68,ARCANINE,69,VENUSAUR,70,GYARADOS,0
	db $FF,66,TAUROS,67,EXEGGUTOR,68,ARCANINE,69,CHARIZARD,70,GYARADOS,0
ChiefData:
; none
ScientistData:
	db 34,KOFFING,VOLTORB,0
	db 26,GRIMER,WEEZING,KOFFING,WEEZING,0
	db 28,MAGNEMITE,VOLTORB,MAGNETON,0
	db 29,ELECTRODE,WEEZING,0
	db 33,ELECTRODE,0
	db 26,MAGNETON,KOFFING,WEEZING,MAGNEMITE,0
	db 25,VOLTORB,KOFFING,MAGNETON,MAGNEMITE,KOFFING,0
	db 29,ELECTRODE,MUK,0
	db 29,GRIMER,ELECTRODE,0
	db 28,VOLTORB,KOFFING,MAGNETON,0
	db 29,MAGNEMITE,KOFFING,0
	db 33,MAGNEMITE,MAGNETON,VOLTORB,0
	db 34,MAGNEMITE,ELECTRODE,0
GiovanniData:
	db $FF,25,ONIX,24,RHYHORN,29,KANGASKHAN,0
	db $FF,37,NIDORINO,35,KANGASKHAN,37,RHYHORN,41,NIDOQUEEN,0
	db $FF,45,RHYHORN,42,DUGTRIO,44,NIDOQUEEN,45,NIDOKING,50,RHYDON,0
RocketData:
	db 13,RATTATA,ZUBAT,0
	db 11,SANDSHREW,RATTATA,ZUBAT,0
	db 12,ZUBAT,EKANS,0
	db 16,RATICATE,0
	db 17,MACHOP,DROWZEE,0
	db 15,EKANS,ZUBAT,0
	db 20,RATICATE,ZUBAT,0
	db 21,DROWZEE,MACHOP,0
	db 21,RATICATE,RATICATE,0
	db 20,GRIMER,KOFFING,KOFFING,0
	db 19,RATTATA,RATICATE,RATICATE,RATTATA,0
	db 22,GRIMER,KOFFING,0
	db 17,ZUBAT,KOFFING,GRIMER,ZUBAT,RATICATE,0
	db 20,RATTATA,RATICATE,DROWZEE,0
	db 21,MACHOP,MACHOP,0
	db 23,SANDSHREW,EKANS,SANDSLASH,0
	db 23,EKANS,SANDSHREW,ARBOK,0
	db 21,KOFFING,ZUBAT,0
	db 25,ZUBAT,ZUBAT,GOLBAT,0
	db 26,KOFFING,DROWZEE,0
	db 23,ZUBAT,RATTATA,RATICATE,ZUBAT,0
	db 26,DROWZEE,KOFFING,0
	db 29,CUBONE,ZUBAT,0
	db 25,GOLBAT,ZUBAT,ZUBAT,RATICATE,ZUBAT,0
	db 28,RATICATE,HYPNO,RATICATE,0
	db 29,MACHOP,DROWZEE,0
	db 28,EKANS,ZUBAT,CUBONE,0
	db 33,ARBOK,0
	db 33,HYPNO,0
	db 29,MACHOP,MACHOKE,0
	db 28,ZUBAT,ZUBAT,GOLBAT,0
	db 26,RATICATE,ARBOK,KOFFING,GOLBAT,0
	db 29,CUBONE,CUBONE,0
	db 29,SANDSHREW,SANDSLASH,0
	db 26,RATICATE,ZUBAT,GOLBAT,RATTATA,0
	db 28,WEEZING,GOLBAT,KOFFING,0
	db 28,DROWZEE,GRIMER,MACHOP,0
	db 28,GOLBAT,DROWZEE,HYPNO,0
	db 33,MACHOKE,0
	db 25,RATTATA,RATTATA,ZUBAT,RATTATA,EKANS,0
	db 32,CUBONE,DROWZEE,MAROWAK,0
CooltrainerMData:
	db 39,NIDORINO,NIDOKING,0
	db 43,EXEGGUTOR,CLOYSTER,ARCANINE,0
	db 43,KINGLER,TENTACRUEL,BLASTOISE,0
	db 45,KINGLER,STARMIE,0
	db 42,IVYSAUR,WARTORTLE,CHARMELEON,CHARIZARD,0
	db 44,IVYSAUR,WARTORTLE,CHARMELEON,0
	db 49,NIDOKING,0
	db 44,KINGLER,CLOYSTER,0
	db 39,SANDSLASH,DUGTRIO,0
	db 43,RHYHORN,0
CooltrainerFData:
	db 24,WEEPINBELL,GLOOM,IVYSAUR,0
	db 43,BELLSPROUT,WEEPINBELL,VICTREEBEL,0
	db 43,PARASECT,DEWGONG,CHANSEY,0
	db 46,VILEPLUME,BUTTERFREE,0
	db 44,PERSIAN,NINETALES,0
	db 45,IVYSAUR,VENUSAUR,0
	db 45,NIDORINA,NIDOQUEEN,0
	db 43,PERSIAN,NINETALES,RAICHU,0
BrunoData:
	db $FF,53,ONIX,55,HITMONCHAN,55,HITMONLEE,56,ONIX,58,MACHAMP,0
BrockData:
	db $FF,12,GEODUDE,14,ONIX,0
MistyData:
	db $FF,18,STARYU,21,STARMIE,0
LtSurgeData:
	db $FF,21,VOLTORB,18,PIKACHU,24,RAICHU,0
ErikaData:
	db $FF,29,VICTREEBEL,24,TANGELA,29,VILEPLUME,0
KogaData:
	db $FF,37,KOFFING,39,MUK,37,KOFFING,43,WEEZING,0
BlaineData:
	db $FF,42,GROWLITHE,40,PONYTA,42,RAPIDASH,47,ARCANINE,0
SabrinaData:
	db $FF,38,KADABRA,37,MR_MIME,38,VENOMOTH,43,ALAKAZAM,0
GentlemanData:
	db 18,GROWLITHE,GROWLITHE,0
	db 19,NIDORAN_M,NIDORAN_F,0
	db 23,PIKACHU,0
	db 48,PRIMEAPE,0
	db 17,GROWLITHE,PONYTA,0
Green2Data:
	db $FF,19,PIDGEOTTO,16,RATICATE,18,KADABRA,20,WARTORTLE,0
	db $FF,19,PIDGEOTTO,16,RATICATE,18,KADABRA,20,IVYSAUR,0
	db $FF,19,PIDGEOTTO,16,RATICATE,18,KADABRA,20,CHARMELEON,0
	db $FF,25,PIDGEOTTO,23,GROWLITHE,22,EXEGGCUTE,20,KADABRA,25,WARTORTLE,0
	db $FF,25,PIDGEOTTO,23,GYARADOS,22,GROWLITHE,20,KADABRA,25,IVYSAUR,0
	db $FF,25,PIDGEOTTO,23,EXEGGCUTE,22,GYARADOS,20,KADABRA,25,CHARMELEON,0
	db $FF,37,PIDGEOT,38,GROWLITHE,35,EXEGGCUTE,35,ALAKAZAM,40,BLASTOISE,0
	db $FF,37,PIDGEOT,38,GYARADOS,35,GROWLITHE,35,ALAKAZAM,40,VENUSAUR,0
	db $FF,37,PIDGEOT,38,EXEGGCUTE,35,GYARADOS,35,ALAKAZAM,40,CHARIZARD,0
	db $FF,47,PIDGEOT,45,RHYHORN,45,GROWLITHE,47,EXEGGCUTE,50,ALAKAZAM,53,BLASTOISE,0
	db $FF,47,PIDGEOT,45,RHYHORN,45,GYARADOS,47,GROWLITHE,50,ALAKAZAM,53,VENUSAUR,0
	db $FF,47,PIDGEOT,45,RHYHORN,45,EXEGGCUTE,47,GYARADOS,50,ALAKAZAM,53,CHARIZARD,0
Green3Data:
	db $FF,61,PIDGEOT,59,ALAKAZAM,61,RHYDON,61,ARCANINE,63,EXEGGUTOR,65,BLASTOISE,0
	db $FF,61,PIDGEOT,59,ALAKAZAM,61,RHYDON,61,GYARADOS,63,ARCANINE,65,VENUSAUR,0
	db $FF,61,PIDGEOT,59,ALAKAZAM,61,RHYDON,61,EXEGGUTOR,63,GYARADOS,65,CHARIZARD,0
LoreleiData:
	db $FF,54,DEWGONG,53,CLOYSTER,54,SLOWBRO,56,JYNX,56,LAPRAS,0
ChannelerData:
	db 22,GASTLY,0
	db 24,GASTLY,0
	db 23,GASTLY,GASTLY,0
	db 24,GASTLY,0
	db 23,GASTLY,0
	db 24,GASTLY,0
	db 24,HAUNTER,0
	db 22,GASTLY,0
	db 24,GASTLY,0
	db 23,GASTLY,GASTLY,0
	db 24,GASTLY,0
	db 22,GASTLY,0
	db 24,GASTLY,0
	db 23,HAUNTER,0
	db 24,GASTLY,0
	db 22,GASTLY,0
	db 24,GASTLY,0
	db 22,HAUNTER,0
	db 22,GASTLY,GASTLY,GASTLY,0
	db 24,GASTLY,0
	db 24,GASTLY,0
	db 34,GASTLY,HAUNTER,0
	db 38,HAUNTER,0
	db 33,GASTLY,GASTLY,HAUNTER,0
AgathaData:
	db $FF,56,GENGAR,56,GOLBAT,55,HAUNTER,58,ARBOK,60,GENGAR,0
LanceData:
	db $FF,58,GYARADOS,56,DRAGONAIR,56,DRAGONAIR,60,AERODACTYL,62,DRAGONITE,0

TrainerAI: ; 652E
;XXX called at 34964, 3c342, 3c398
	and a
	ld a,[W_ISINBATTLE]
	dec a
	ret z ; if not a trainer, we're done here
	ld a,[W_ISLINKBATTLE]
	cp 4
	ret z
	ld a,[W_TRAINERCLASS] ; what trainer class is this?
	dec a
	ld c,a
	ld b,0
	ld hl,TrainerAIPointers
	add hl,bc
	add hl,bc
	add hl,bc
	ld a,[W_AICOUNT]
	and a
	ret z ; if no AI uses left, we're done here
	inc hl
	inc a
	jr nz,.getpointer\@
	dec hl
	ld a,[hli]
	ld [W_AICOUNT],a
.getpointer\@
	ld a,[hli]
	ld h,[hl]
	ld l,a
	call GenRandom
	jp [hl]

TrainerAIPointers: ; 655C
; one entry per trainer class
; first byte, number of times (per Pokémon) it can occur
; next two bytes, pointer to AI subroutine for trainer class
	dbw 3,GenericAI
	dbw 3,GenericAI
	dbw 3,GenericAI
	dbw 3,GenericAI
	dbw 3,GenericAI
	dbw 3,GenericAI
	dbw 3,GenericAI
	dbw 3,GenericAI
	dbw 3,GenericAI
	dbw 3,GenericAI
	dbw 3,GenericAI
	dbw 3,GenericAI
	dbw 3,JugglerAI ; juggler_x
	dbw 3,GenericAI
	dbw 3,GenericAI
	dbw 3,GenericAI
	dbw 3,GenericAI
	dbw 3,GenericAI
	dbw 3,GenericAI
	dbw 3,GenericAI
	dbw 3,JugglerAI ; juggler
	dbw 3,GenericAI
	dbw 3,GenericAI
	dbw 2,BlackbeltAI ; blackbelt
	dbw 3,GenericAI
	dbw 3,GenericAI
	dbw 1,GenericAI ; chief
	dbw 3,GenericAI
	dbw 1,GiovanniAI ; giovanni
	dbw 3,GenericAI
	dbw 2,CooltrainerMAI ; cooltrainerm
	dbw 1,CooltrainerFAI ; cooltrainerf
	dbw 2,BrunoAI ; bruno
	dbw 5,BrockAI ; brock
	dbw 1,MistyAI ; misty
	dbw 1,LtSurgeAI ; surge
	dbw 1,ErikaAI ; erika
	dbw 2,KogaAI ; koga
	dbw 2,BlaineAI ; blaine
	dbw 1,SabrinaAI ; sabrina
	dbw 3,GenericAI
	dbw 1,Sony2AI ; sony2
	dbw 1,Sony3AI ; sony3
	dbw 2,LoreleiAI ; lorelei
	dbw 3,GenericAI
	dbw 2,AgathaAI ; agatha
	dbw 1,LanceAI ; lance

JugglerAI:
	cp $40
	ret nc
	jp $672A

BlackbeltAI:
	cp $20
	ret nc
	jp AIUseXAttack

GiovanniAI:
	cp $40
	ret nc
	jp AIUseGuardSpec

CooltrainerMAI:
	cp $40
	ret nc
	jp AIUseXAttack

CooltrainerFAI:
	cp $40
	ld a,$A
	call $67CF
	jp c,AIUseHyperPotion
	ld a,5
	call $67CF
	ret nc
	jp $672A

BrockAI:
; if his active monster has a status condition, use a full heal
	ld a,[W_ENEMYMONSTATUS]
	and a
	ret z
	jp AIUseFullHeal

MistyAI:
	cp $40
	ret nc
	jp AIUseXDefend

LtSurgeAI:
	cp $40
	ret nc
	jp AIUseXSpeed

ErikaAI:
	cp $80
	ret nc
	ld a,$A
	call $67CF
	ret nc
	jp AIUseSuperPotion

KogaAI:
	cp $40
	ret nc
	jp AIUseXAttack

BlaineAI:
	cp $40
	ret nc
	jp AIUseSuperPotion

SabrinaAI:
	cp $40
	ret nc
	ld a,$A
	call $67CF
	ret nc
	jp AIUseHyperPotion

Sony2AI:
	cp $20
	ret nc
	ld a,5
	call $67CF
	ret nc
	jp AIUsePotion

Sony3AI:
	cp $20
	ret nc
	ld a,5
	call $67CF
	ret nc
	jp AIUseFullRestore

LoreleiAI:
	cp $80
	ret nc
	ld a,5
	call $67CF
	ret nc
	jp AIUseSuperPotion

BrunoAI:
	cp $40
	ret nc
	jp AIUseXDefend

AgathaAI:
	cp $14
	jp c,$672A
	cp $80
	ret nc
	ld a,4
	call $67CF
	ret nc
	jp AIUseSuperPotion

LanceAI:
	cp $80
	ret nc
	ld a,5
	call $67CF
	ret nc
	jp AIUseHyperPotion

GenericAI:
	and a ; clear carry
	ret

; end of individual trainer AI routines

DecrementAICount: ; 6695
	ld hl,W_AICOUNT
	dec [hl]
	scf
	ret

Function669B: ; 669B
; XXX what does this do
	ld a,$8E
	jp $3740

AIUseFullRestore: ; 0x3a6a0
	call AICureStatus
	ld a,FULL_RESTORE
	ld [$CF05],a
	ld de,$CEEB
	ld hl,$CFE7
	ld a,[hld]
	ld [de],a
	inc de
	ld a,[hl]
	ld [de],a
	inc de
	ld hl,$CFF5
	ld a,[hld]
	ld [de],a
	inc de
	ld [$CEE9],a
	ld [$CFE7],a
	ld a,[hl]
	ld [de],a
	ld [$CEEA],a
	ld [W_ENEMYMONCURHP],a
	jr Function6718
; 0x3a6ca

AIUsePotion: ; 0x3a6ca
; enemy trainer heals his monster with a potion
	ld a,POTION
	ld b,20
	jr AIRecoverHP

AIUseSuperPotion: ; 0x3a6d0
; enemy trainer heals his monster with a super potion
	ld a,SUPER_POTION
	ld b,50
	jr AIRecoverHP

AIUseHyperPotion: ; 0x3a6d6
; enemy trainer heals his monster with a hyper potion
	ld a,HYPER_POTION
	ld b,200
	; fallthrough

AIRecoverHP: ; 66DA
; heal b HP and print "trainer used $(a) on pokemon!"
	ld [$CF05],a
	ld hl,$CFE7
	ld a,[hl]
	ld [$CEEB],a
	add b
	ld [hld],a
	ld [$CEED],a
	ld a,[hl]
	ld [$CEEC],a
	ld [$CEEE],a
	jr nc,.next\@
	inc a
	ld [hl],a
	ld [$CEEE],a
.next\@
	inc hl
	ld a,[hld]
	ld b,a
	ld de,$CFF5
	ld a,[de]
	dec de
	ld [$CEE9],a
	sub b
	ld a,[hli]
	ld b,a
	ld a,[de]
	ld [$CEEA],a
	sbc b
	jr nc,Function6718
	inc de
	ld a,[de]
	dec de
	ld [hld],a
	ld [$CEED],a
	ld a,[de]
	ld [hl],a
	ld [$CEEE],a
	; fallthrough

Function6718: ; 6718
	call AIPrintItemUse_
	ld hl,$C3CA
	xor a
	ld [$CF94],a
	ld a,$48
	call Predef
	jp DecrementAICount

Function672A: ; 672A
	ld a,[W_ENEMYMONCOUNT]
	ld c,a
	ld hl,W_ENEMYMON1HP

	ld d,0 ; keep count of unfainted monsters

	; count how many monsters haven't fainted yet
.loop\@
	ld a,[hli]
	ld b,a
	ld a,[hld]
	or b
	jr z,.Fainted\@ ; has monster fainted?
	inc d
.Fainted\@
	push bc
	ld bc,$2C
	add hl,bc
	pop bc
	dec c
	jr nz,.loop\@

	ld a,d ; how many available monsters are there?
	cp 2 ; don't bother if only 1 or 2
	jp nc,Function674B ; XXX check, does this jump when a = 2?
	and a
	ret

Function674B: ; 674B

; prepare to withdraw the active monster: copy hp, number, and status to roster

	ld a,[W_ENEMYMONNUMBER]
	ld hl,W_ENEMYMON1HP
	ld bc,$2C
	call AddNTimes
	ld d,h
	ld e,l
	ld hl,W_ENEMYMONCURHP
	ld bc,4
	call CopyData

	ld hl, AIBattleWithdrawText
	call PrintText

	ld a,1
	ld [$D11D],a
	ld hl,EnemySendOut
	ld b,BANK(EnemySendOut)
	call Bankswitch
	xor a
	ld [$D11D],a

	ld a,[W_ISLINKBATTLE]
	cp 4
	ret z
	scf
	ret

AIBattleWithdrawText: ; 0x3a781
	TX_FAR _AIBattleWithdrawText
	db "@"

AIUseFullHeal: ; 0x3a786
	call $669B
	call AICureStatus
	ld a,FULL_HEAL
	jp AIPrintItemUse

AICureStatus: ; 0x3a791
; cures the status of enemy's active pokemon
	ld a,[W_ENEMYMONNUMBER]
	ld hl,$D8A8
	ld bc,$2C
	call AddNTimes
	xor a
	ld [hl],a ; clear status in enemy team roster
	ld [W_ENEMYMONSTATUS],a ; clear status of active enemy
	ld hl,$D069
	res 0,[hl]
	ret

AIUseXAccuracy: ; 0x3a7a8 unused
	call $669B
	ld hl,$D068
	set 0,[hl]
	ld a,X_ACCURACY
	jp AIPrintItemUse

AIUseGuardSpec: ; 0x3a7b5
	call $669B
	ld hl,$D068
	set 1,[hl]
	ld a,GUARD_SPEC_
	jp AIPrintItemUse

AIUseDireHit: ; 0x3a7c2 unused
	call $669B
	ld hl,$D068
	set 2,[hl]
	ld a,DIRE_HIT
	jp AIPrintItemUse

Function67CF: ; 0x3a7cf 67CF
	ld [H_DIVISOR],a
	ld hl,$CFF4
	ld a,[hli]
	ld [H_DIVIDEND],a
	ld a,[hl]
	ld [H_DIVIDEND + 1],a
	ld b,2
	call Divide
	ld a,[H_QUOTIENT + 3]
	ld c,a
	ld a,[H_QUOTIENT + 2]
	ld b,a
	ld hl,$CFE7
	ld a,[hld]
	ld e,a
	ld a,[hl]
	ld d,a
	ld a,d
	sub b
	ret nz
	ld a,e
	sub c
	ret

AIUseXAttack: ; 0x3a7f2
	ld b,$A
	ld a,X_ATTACK
	jr AIIncreaseStat

AIUseXDefend: ; 0x3a7f8
	ld b,$B
	ld a,X_DEFEND
	jr AIIncreaseStat

AIUseXSpeed: ; 0x3a7fe
	ld b,$C
	ld a,X_SPEED
	jr AIIncreaseStat

AIUseXSpecial: ; 0x3a804
	ld b,$D
	ld a,X_SPECIAL
	; fallthrough

AIIncreaseStat: ; 0x3a808
	ld [$CF05],a
	push bc
	call AIPrintItemUse_
	pop bc
	ld hl,$CFCD
	ld a,[hld]
	push af
	ld a,[hl]
	push af
	push hl
	ld a,$AF
	ld [hli],a
	ld [hl],b
	ld hl,$7428
	ld b,$F
	call Bankswitch
	pop hl
	pop af
	ld [hli],a
	pop af
	ld [hl],a
	jp DecrementAICount

AIPrintItemUse: ; 0x3a82c
	ld [$CF05],a
	call AIPrintItemUse_
	jp DecrementAICount

AIPrintItemUse_: ; 0x3a835
; print "x used [$CF05] on z!"
	ld a,[$CF05]
	ld [$D11E],a
	call GetItemName
	ld hl, AIBattleUseItemText
	jp PrintText

AIBattleUseItemText: ; 0x3a844
	TX_FAR _AIBattleUseItemText
	db "@"

INCBIN "baserom.gbc",$3a849,$3af3e - $3a849

UnnamedText_3af3e: ; 0x3af3e
	TX_FAR _UnnamedText_3af3e
	db $50
; 0x3af3e + 5 bytes

UnnamedText_3af43: ; 0x3af43
	TX_FAR _UnnamedText_3af43
	db $50
; 0x3af43 + 5 bytes

UnnamedText_3af48: ; 0x3af48
	TX_FAR _UnnamedText_3af48
	db $50
; 0x3af48 + 5 bytes

UnnamedText_3af4d: ; 0x3af4d
	TX_FAR _UnnamedText_3af4d
	db $50
; 0x3af4d + 5 bytes

INCBIN "baserom.gbc",$3af52,$10a

EvosMovesPointerTable: ; 705C
	dw Mon112_EvosMoves
	dw Mon115_EvosMoves
	dw Mon032_EvosMoves
	dw Mon035_EvosMoves
	dw Mon021_EvosMoves
	dw Mon100_EvosMoves
	dw Mon034_EvosMoves
	dw Mon080_EvosMoves
	dw Mon002_EvosMoves
	dw Mon103_EvosMoves
	dw Mon108_EvosMoves
	dw Mon102_EvosMoves
	dw Mon088_EvosMoves
	dw Mon094_EvosMoves
	dw Mon029_EvosMoves
	dw Mon031_EvosMoves
	dw Mon104_EvosMoves
	dw Mon111_EvosMoves
	dw Mon131_EvosMoves
	dw Mon059_EvosMoves
	dw Mon151_EvosMoves
	dw Mon130_EvosMoves
	dw Mon090_EvosMoves
	dw Mon072_EvosMoves
	dw Mon092_EvosMoves
	dw Mon123_EvosMoves
	dw Mon120_EvosMoves
	dw Mon009_EvosMoves
	dw Mon127_EvosMoves
	dw Mon114_EvosMoves
	dw Mon152_EvosMoves	;MissingNo
	dw Mon153_EvosMoves	;MissingNo
	dw Mon058_EvosMoves
	dw Mon095_EvosMoves
	dw Mon022_EvosMoves
	dw Mon016_EvosMoves
	dw Mon079_EvosMoves
	dw Mon064_EvosMoves
	dw Mon075_EvosMoves
	dw Mon113_EvosMoves
	dw Mon067_EvosMoves
	dw Mon122_EvosMoves
	dw Mon106_EvosMoves
	dw Mon107_EvosMoves
	dw Mon024_EvosMoves
	dw Mon047_EvosMoves
	dw Mon054_EvosMoves
	dw Mon096_EvosMoves
	dw Mon076_EvosMoves
	dw Mon154_EvosMoves	;MissingNo
	dw Mon126_EvosMoves
	dw Mon155_EvosMoves	;MissingNo
	dw Mon125_EvosMoves
	dw Mon082_EvosMoves
	dw Mon109_EvosMoves
	dw Mon156_EvosMoves	;MissingNo
	dw Mon056_EvosMoves
	dw Mon086_EvosMoves
	dw Mon050_EvosMoves
	dw Mon128_EvosMoves
	dw Mon157_EvosMoves	;MissingNo
	dw Mon158_EvosMoves	;MissingNo
	dw Mon159_EvosMoves	;MissingNo
	dw Mon083_EvosMoves
	dw Mon048_EvosMoves
	dw Mon149_EvosMoves
	dw Mon160_EvosMoves	;MissingNo
	dw Mon161_EvosMoves	;MissingNo
	dw Mon162_EvosMoves	;MissingNo
	dw Mon084_EvosMoves
	dw Mon060_EvosMoves
	dw Mon124_EvosMoves
	dw Mon146_EvosMoves
	dw Mon144_EvosMoves
	dw Mon145_EvosMoves
	dw Mon132_EvosMoves
	dw Mon052_EvosMoves
	dw Mon098_EvosMoves
	dw Mon163_EvosMoves	;MissingNo
	dw Mon164_EvosMoves	;MissingNo
	dw Mon165_EvosMoves	;MissingNo
	dw Mon037_EvosMoves
	dw Mon038_EvosMoves
	dw Mon025_EvosMoves
	dw Mon026_EvosMoves
	dw Mon166_EvosMoves	;MissingNo
	dw Mon167_EvosMoves	;MissingNo
	dw Mon147_EvosMoves
	dw Mon148_EvosMoves
	dw Mon140_EvosMoves
	dw Mon141_EvosMoves
	dw Mon116_EvosMoves
	dw Mon117_EvosMoves
	dw Mon168_EvosMoves	;MissingNo
	dw Mon169_EvosMoves	;MissingNo
	dw Mon027_EvosMoves
	dw Mon028_EvosMoves
	dw Mon138_EvosMoves
	dw Mon139_EvosMoves
	dw Mon039_EvosMoves
	dw Mon040_EvosMoves
	dw Mon133_EvosMoves
	dw Mon136_EvosMoves
	dw Mon135_EvosMoves
	dw Mon134_EvosMoves
	dw Mon066_EvosMoves
	dw Mon041_EvosMoves
	dw Mon023_EvosMoves
	dw Mon046_EvosMoves
	dw Mon061_EvosMoves
	dw Mon062_EvosMoves
	dw Mon013_EvosMoves
	dw Mon014_EvosMoves
	dw Mon015_EvosMoves
	dw Mon170_EvosMoves	;MissingNo
	dw Mon085_EvosMoves
	dw Mon057_EvosMoves
	dw Mon051_EvosMoves
	dw Mon049_EvosMoves
	dw Mon087_EvosMoves
	dw Mon171_EvosMoves	;MissingNo
	dw Mon172_EvosMoves	;MissingNo
	dw Mon010_EvosMoves
	dw Mon011_EvosMoves
	dw Mon012_EvosMoves
	dw Mon068_EvosMoves
	dw Mon173_EvosMoves	;MissingNo
	dw Mon055_EvosMoves
	dw Mon097_EvosMoves
	dw Mon042_EvosMoves
	dw Mon150_EvosMoves
	dw Mon143_EvosMoves
	dw Mon129_EvosMoves
	dw Mon174_EvosMoves	;MissingNo
	dw Mon175_EvosMoves	;MissingNo
	dw Mon089_EvosMoves
	dw Mon176_EvosMoves	;MissingNo
	dw Mon099_EvosMoves
	dw Mon091_EvosMoves
	dw Mon177_EvosMoves	;MissingNo
	dw Mon101_EvosMoves
	dw Mon036_EvosMoves
	dw Mon110_EvosMoves
	dw Mon053_EvosMoves
	dw Mon105_EvosMoves
	dw Mon178_EvosMoves	;MissingNo
	dw Mon093_EvosMoves
	dw Mon063_EvosMoves
	dw Mon065_EvosMoves
	dw Mon017_EvosMoves
	dw Mon018_EvosMoves
	dw Mon121_EvosMoves
	dw Mon001_EvosMoves
	dw Mon003_EvosMoves
	dw Mon073_EvosMoves
	dw Mon179_EvosMoves	;MissingNo
	dw Mon118_EvosMoves
	dw Mon119_EvosMoves
	dw Mon180_EvosMoves	;MissingNo
	dw Mon181_EvosMoves	;MissingNo
	dw Mon182_EvosMoves	;MissingNo
	dw Mon183_EvosMoves	;MissingNo
	dw Mon077_EvosMoves
	dw Mon078_EvosMoves
	dw Mon019_EvosMoves
	dw Mon020_EvosMoves
	dw Mon033_EvosMoves
	dw Mon030_EvosMoves
	dw Mon074_EvosMoves
	dw Mon137_EvosMoves
	dw Mon142_EvosMoves
	dw Mon184_EvosMoves	;MissingNo
	dw Mon081_EvosMoves
	dw Mon185_EvosMoves	;MissingNo
	dw Mon186_EvosMoves	;MissingNo
	dw Mon004_EvosMoves
	dw Mon007_EvosMoves
	dw Mon005_EvosMoves
	dw Mon008_EvosMoves
	dw Mon006_EvosMoves
	dw Mon187_EvosMoves	;MissingNo
	dw Mon188_EvosMoves	;MissingNo
	dw Mon189_EvosMoves	;MissingNo
	dw Mon190_EvosMoves	;MissingNo
	dw Mon043_EvosMoves
	dw Mon044_EvosMoves
	dw Mon045_EvosMoves
	dw Mon069_EvosMoves
	dw Mon070_EvosMoves
	dw Mon071_EvosMoves

Mon112_EvosMoves:
;RHYDON
;Evolutions
	db 0
;Learnset
	db 30,STOMP
	db 35,TAIL_WHIP
	db 40,FURY_ATTACK
	db 48,HORN_DRILL
	db 55,LEER
	db 64,TAKE_DOWN
	db 0
Mon115_EvosMoves:
;KANGASKHAN
;Evolutions
	db 0
;Learnset
	db 26,BITE
	db 31,TAIL_WHIP
	db 36,MEGA_PUNCH
	db 41,LEER
	db 46,DIZZY_PUNCH
	db 0
Mon032_EvosMoves:
;NIDORAN_M
;Evolutions
	db EV_LEVEL,16,NIDORINO
	db 0
;Learnset
	db 8,HORN_ATTACK
	db 14,POISON_STING
	db 21,FOCUS_ENERGY
	db 29,FURY_ATTACK
	db 36,HORN_DRILL
	db 43,DOUBLE_KICK
	db 0
Mon035_EvosMoves:
;CLEFAIRY
;Evolutions
	db EV_ITEM,MOON_STONE,1,CLEFABLE
	db 0
;Learnset
	db 13,SING
	db 18,DOUBLESLAP
	db 24,MINIMIZE
	db 31,METRONOME
	db 39,DEFENSE_CURL
	db 48,LIGHT_SCREEN
	db 0
Mon021_EvosMoves:
;SPEAROW
;Evolutions
	db EV_LEVEL,20,FEAROW
	db 0
;Learnset
	db 9,LEER
	db 15,FURY_ATTACK
	db 22,MIRROR_MOVE
	db 29,DRILL_PECK
	db 36,AGILITY
	db 0
Mon100_EvosMoves:
;VOLTORB
;Evolutions
	db EV_LEVEL,30,ELECTRODE
	db 0
;Learnset
	db 17,SONICBOOM
	db 22,SELFDESTRUCT
	db 29,LIGHT_SCREEN
	db 36,SWIFT
	db 43,EXPLOSION
	db 0
Mon034_EvosMoves:
;NIDOKING
;Evolutions
	db 0
;Learnset
	db 8,HORN_ATTACK
	db 14,POISON_STING
	db 23,THRASH
	db 0
Mon080_EvosMoves:
;SLOWBRO
;Evolutions
	db 0
;Learnset
	db 18,DISABLE
	db 22,HEADBUTT
	db 27,GROWL
	db 33,WATER_GUN
	db 37,WITHDRAW
	db 44,AMNESIA
	db 55,PSYCHIC_M
	db 0
Mon002_EvosMoves:
;IVYSAUR
;Evolutions
	db EV_LEVEL,32,VENUSAUR
	db 0
;Learnset
	db 7,LEECH_SEED
	db 13,VINE_WHIP
	db 22,POISONPOWDER
	db 30,RAZOR_LEAF
	db 38,GROWTH
	db 46,SLEEP_POWDER
	db 54,SOLARBEAM
	db 0
Mon103_EvosMoves:
;EXEGGUTOR
;Evolutions
	db 0
;Learnset
	db 28,STOMP
	db 0
Mon108_EvosMoves:
;LICKITUNG
;Evolutions
	db 0
;Learnset
	db 7,STOMP
	db 15,DISABLE
	db 23,DEFENSE_CURL
	db 31,SLAM
	db 39,SCREECH
	db 0
Mon102_EvosMoves:
;EXEGGCUTE
;Evolutions
	db EV_ITEM,LEAF_STONE ,1,EXEGGUTOR
	db 0
;Learnset
	db 25,REFLECT
	db 28,LEECH_SEED
	db 32,STUN_SPORE
	db 37,POISONPOWDER
	db 42,SOLARBEAM
	db 48,SLEEP_POWDER
	db 0
Mon088_EvosMoves:
;GRIMER
;Evolutions
	db EV_LEVEL,38,MUK
	db 0
;Learnset
	db 30,POISON_GAS
	db 33,MINIMIZE
	db 37,SLUDGE
	db 42,HARDEN
	db 48,SCREECH
	db 55,ACID_ARMOR
	db 0
Mon094_EvosMoves:
;GENGAR
;Evolutions
	db 0
;Learnset
	db 29,HYPNOSIS
	db 38,DREAM_EATER
	db 0
Mon029_EvosMoves:
;NIDORAN_F
;Evolutions
	db EV_LEVEL,16,NIDORINA
	db 0
;Learnset
	db 8,SCRATCH
	db 14,POISON_STING
	db 21,TAIL_WHIP
	db 29,BITE
	db 36,FURY_SWIPES
	db 43,DOUBLE_KICK
	db 0
Mon031_EvosMoves:
;NIDOQUEEN
;Evolutions
	db 0
;Learnset
	db 8,SCRATCH
	db 14,POISON_STING
	db 23,BODY_SLAM
	db 0
Mon104_EvosMoves:
;CUBONE
;Evolutions
	db EV_LEVEL,28,MAROWAK
	db 0
;Learnset
	db 25,LEER
	db 31,FOCUS_ENERGY
	db 38,THRASH
	db 43,BONEMERANG
	db 46,RAGE
	db 0
Mon111_EvosMoves:
;RHYHORN
;Evolutions
	db EV_LEVEL,42,RHYDON
	db 0
;Learnset
	db 30,STOMP
	db 35,TAIL_WHIP
	db 40,FURY_ATTACK
	db 45,HORN_DRILL
	db 50,LEER
	db 55,TAKE_DOWN
	db 0
Mon131_EvosMoves:
;LAPRAS
;Evolutions
	db 0
;Learnset
	db 16,SING
	db 20,MIST
	db 25,BODY_SLAM
	db 31,CONFUSE_RAY
	db 38,ICE_BEAM
	db 46,HYDRO_PUMP
	db 0
Mon059_EvosMoves:
;ARCANINE
;Evolutions
	db 0
;Learnset
	db 0
Mon151_EvosMoves:
;MEW
;Evolutions
	db 0
;Learnset
	db 10,TRANSFORM
	db 20,MEGA_PUNCH
	db 30,METRONOME
	db 40,PSYCHIC_M
	db 0
Mon130_EvosMoves:
;GYARADOS
;Evolutions
	db 0
;Learnset
	db 20,BITE
	db 25,DRAGON_RAGE
	db 32,LEER
	db 41,HYDRO_PUMP
	db 52,HYPER_BEAM
	db 0
Mon090_EvosMoves:
;SHELLDER
;Evolutions
	db EV_ITEM,WATER_STONE ,1,CLOYSTER
	db 0
;Learnset
	db 18,SUPERSONIC
	db 23,CLAMP
	db 30,AURORA_BEAM
	db 39,LEER
	db 50,ICE_BEAM
	db 0
Mon072_EvosMoves:
;TENTACOOL
;Evolutions
	db EV_LEVEL,30,TENTACRUEL
	db 0
;Learnset
	db 7,SUPERSONIC
	db 13,WRAP
	db 18,POISON_STING
	db 22,WATER_GUN
	db 27,CONSTRICT
	db 33,BARRIER
	db 40,SCREECH
	db 48,HYDRO_PUMP
	db 0
Mon092_EvosMoves:
;GASTLY
;Evolutions
	db EV_LEVEL,25,HAUNTER
	db 0
;Learnset
	db 27,HYPNOSIS
	db 35,DREAM_EATER
	db 0
Mon123_EvosMoves:
;SCYTHER
;Evolutions
	db 0
;Learnset
	db 17,LEER
	db 20,FOCUS_ENERGY
	db 24,DOUBLE_TEAM
	db 29,SLASH
	db 35,SWORDS_DANCE
	db 42,AGILITY
	db 0
Mon120_EvosMoves:
;STARYU
;Evolutions
	db EV_ITEM,WATER_STONE ,1,STARMIE
	db 0
;Learnset
	db 17,WATER_GUN
	db 22,HARDEN
	db 27,RECOVER
	db 32,SWIFT
	db 37,MINIMIZE
	db 42,LIGHT_SCREEN
	db 47,HYDRO_PUMP
	db 0
Mon009_EvosMoves:
;BLASTOISE
;Evolutions
	db 0
;Learnset
	db 8,BUBBLE
	db 15,WATER_GUN
	db 24,BITE
	db 31,WITHDRAW
	db 42,SKULL_BASH
	db 52,HYDRO_PUMP
	db 0
Mon127_EvosMoves:
;PINSIR
;Evolutions
	db 0
;Learnset
	db 25,SEISMIC_TOSS
	db 30,GUILLOTINE
	db 36,FOCUS_ENERGY
	db 43,HARDEN
	db 49,SLASH
	db 54,SWORDS_DANCE
	db 0
Mon114_EvosMoves:
;TANGELA
;Evolutions
	db 0
;Learnset
	db 29,ABSORB
	db 32,POISONPOWDER
	db 36,STUN_SPORE
	db 39,SLEEP_POWDER
	db 45,SLAM
	db 49,GROWTH
	db 0

Mon152_EvosMoves:
;MISSINGNO
;Evolutions
	db 0
;Learnset
	db 0

Mon153_EvosMoves:
;MISSINGNO
;Evolutions
	db 0
;Learnset
	db 0
Mon058_EvosMoves:
;GROWLITHE
;Evolutions
	db EV_ITEM,FIRE_STONE,1,ARCANINE
	db 0
;Learnset
	db 18,EMBER
	db 23,LEER
	db 30,TAKE_DOWN
	db 39,AGILITY
	db 50,FLAMETHROWER
	db 0
Mon095_EvosMoves:
;ONIX
;Evolutions
	db 0
;Learnset
	db 15,BIND
	db 19,ROCK_THROW
	db 25,RAGE
	db 33,SLAM
	db 43,HARDEN
	db 0
Mon022_EvosMoves:
;FEAROW
;Evolutions
	db 0
;Learnset
	db 9,LEER
	db 15,FURY_ATTACK
	db 25,MIRROR_MOVE
	db 34,DRILL_PECK
	db 43,AGILITY
	db 0
Mon016_EvosMoves:
;PIDGEY
;Evolutions
	db EV_LEVEL,18,PIDGEOTTO
	db 0
;Learnset
	db 5,SAND_ATTACK
	db 12,QUICK_ATTACK
	db 19,WHIRLWIND
	db 28,WING_ATTACK
	db 36,AGILITY
	db 44,MIRROR_MOVE
	db 0
Mon079_EvosMoves:
;SLOWPOKE
;Evolutions
	db EV_LEVEL,37,SLOWBRO
	db 0
;Learnset
	db 18,DISABLE
	db 22,HEADBUTT
	db 27,GROWL
	db 33,WATER_GUN
	db 40,AMNESIA
	db 48,PSYCHIC_M
	db 0
Mon064_EvosMoves:
;KADABRA
;Evolutions
	db EV_TRADE,1,ALAKAZAM
	db 0
;Learnset
	db 16,CONFUSION
	db 20,DISABLE
	db 27,PSYBEAM
	db 31,RECOVER
	db 38,PSYCHIC_M
	db 42,REFLECT
	db 0
Mon075_EvosMoves:
;GRAVELER
;Evolutions
	db EV_TRADE,1,GOLEM
	db 0
;Learnset
	db 11,DEFENSE_CURL
	db 16,ROCK_THROW
	db 21,SELFDESTRUCT
	db 29,HARDEN
	db 36,EARTHQUAKE
	db 43,EXPLOSION
	db 0
Mon113_EvosMoves:
;CHANSEY
;Evolutions
	db 0
;Learnset
	db 24,SING
	db 30,GROWL
	db 38,MINIMIZE
	db 44,DEFENSE_CURL
	db 48,LIGHT_SCREEN
	db 54,DOUBLE_EDGE
	db 0
Mon067_EvosMoves:
;MACHOKE
;Evolutions
	db EV_TRADE,1,MACHAMP
	db 0
;Learnset
	db 20,LOW_KICK
	db 25,LEER
	db 36,FOCUS_ENERGY
	db 44,SEISMIC_TOSS
	db 52,SUBMISSION
	db 0
Mon122_EvosMoves:
;MR_MIME
;Evolutions
	db 0
;Learnset
	db 15,CONFUSION
	db 23,LIGHT_SCREEN
	db 31,DOUBLESLAP
	db 39,MEDITATE
	db 47,SUBSTITUTE
	db 0
Mon106_EvosMoves:
;HITMONLEE
;Evolutions
	db 0
;Learnset
	db 33,ROLLING_KICK
	db 38,JUMP_KICK
	db 43,FOCUS_ENERGY
	db 48,HI_JUMP_KICK
	db 53,MEGA_KICK
	db 0
Mon107_EvosMoves:
;HITMONCHAN
;Evolutions
	db 0
;Learnset
	db 33,FIRE_PUNCH
	db 38,ICE_PUNCH
	db 43,THUNDERPUNCH
	db 48,MEGA_PUNCH
	db 53,COUNTER
	db 0
Mon024_EvosMoves:
;ARBOK
;Evolutions
	db 0
;Learnset
	db 10,POISON_STING
	db 17,BITE
	db 27,GLARE
	db 36,SCREECH
	db 47,ACID
	db 0
Mon047_EvosMoves:
;PARASECT
;Evolutions
	db 0
;Learnset
	db 13,STUN_SPORE
	db 20,LEECH_LIFE
	db 30,SPORE
	db 39,SLASH
	db 48,GROWTH
	db 0
Mon054_EvosMoves:
;PSYDUCK
;Evolutions
	db EV_LEVEL,33,GOLDUCK
	db 0
;Learnset
	db 28,TAIL_WHIP
	db 31,DISABLE
	db 36,CONFUSION
	db 43,FURY_SWIPES
	db 52,HYDRO_PUMP
	db 0
Mon096_EvosMoves:
;DROWZEE
;Evolutions
	db EV_LEVEL,26,HYPNO
	db 0
;Learnset
	db 12,DISABLE
	db 17,CONFUSION
	db 24,HEADBUTT
	db 29,POISON_GAS
	db 32,PSYCHIC_M
	db 37,MEDITATE
	db 0
Mon076_EvosMoves:
;GOLEM
;Evolutions
	db 0
;Learnset
	db 11,DEFENSE_CURL
	db 16,ROCK_THROW
	db 21,SELFDESTRUCT
	db 29,HARDEN
	db 36,EARTHQUAKE
	db 43,EXPLOSION
	db 0

Mon154_EvosMoves:
;MISSINGNO
;Evolutions
	db 0
;Learnset
	db 0
Mon126_EvosMoves:
;MAGMAR
;Evolutions
	db 0
;Learnset
	db 36,LEER
	db 39,CONFUSE_RAY
	db 43,FIRE_PUNCH
	db 48,SMOKESCREEN
	db 52,SMOG
	db 55,FLAMETHROWER
	db 0

Mon155_EvosMoves:
;MISSINGNO
;Evolutions
	db 0
;Learnset
	db 0
Mon125_EvosMoves:
;ELECTABUZZ
;Evolutions
	db 0
;Learnset
	db 34,THUNDERSHOCK
	db 37,SCREECH
	db 42,THUNDERPUNCH
	db 49,LIGHT_SCREEN
	db 54,THUNDER
	db 0
Mon082_EvosMoves:
;MAGNETON
;Evolutions
	db 0
;Learnset
	db 21,SONICBOOM
	db 25,THUNDERSHOCK
	db 29,SUPERSONIC
	db 38,THUNDER_WAVE
	db 46,SWIFT
	db 54,SCREECH
	db 0
Mon109_EvosMoves:
;KOFFING
;Evolutions
	db EV_LEVEL,35,WEEZING
	db 0
;Learnset
	db 32,SLUDGE
	db 37,SMOKESCREEN
	db 40,SELFDESTRUCT
	db 45,HAZE
	db 48,EXPLOSION
	db 0

Mon156_EvosMoves:
;MISSINGNO
;Evolutions
	db 0
;Learnset
	db 0
Mon056_EvosMoves:
;MANKEY
;Evolutions
	db EV_LEVEL,28,PRIMEAPE
	db 0
;Learnset
	db 15,KARATE_CHOP
	db 21,FURY_SWIPES
	db 27,FOCUS_ENERGY
	db 33,SEISMIC_TOSS
	db 39,THRASH
	db 0
Mon086_EvosMoves:
;SEEL
;Evolutions
	db EV_LEVEL,34,DEWGONG
	db 0
;Learnset
	db 30,GROWL
	db 35,AURORA_BEAM
	db 40,REST
	db 45,TAKE_DOWN
	db 50,ICE_BEAM
	db 0
Mon050_EvosMoves:
;DIGLETT
;Evolutions
	db EV_LEVEL,26,DUGTRIO
	db 0
;Learnset
	db 15,GROWL
	db 19,DIG
	db 24,SAND_ATTACK
	db 31,SLASH
	db 40,EARTHQUAKE
	db 0
Mon128_EvosMoves:
;TAUROS
;Evolutions
	db 0
;Learnset
	db 21,STOMP
	db 28,TAIL_WHIP
	db 35,LEER
	db 44,RAGE
	db 51,TAKE_DOWN
	db 0

Mon157_EvosMoves:
;MISSINGNO
;Evolutions
	db 0
;Learnset
	db 0

Mon158_EvosMoves:
;MISSINGNO
;Evolutions
	db 0
;Learnset
	db 0

Mon159_EvosMoves:
;MISSINGNO
;Evolutions
	db 0
;Learnset
	db 0
Mon083_EvosMoves:
;FARFETCH_D
;Evolutions
	db 0
;Learnset
	db 7,LEER
	db 15,FURY_ATTACK
	db 23,SWORDS_DANCE
	db 31,AGILITY
	db 39,SLASH
	db 0
Mon048_EvosMoves:
;VENONAT
;Evolutions
	db EV_LEVEL,31,VENOMOTH
	db 0
;Learnset
	db 24,POISONPOWDER
	db 27,LEECH_LIFE
	db 30,STUN_SPORE
	db 35,PSYBEAM
	db 38,SLEEP_POWDER
	db 43,PSYCHIC_M
	db 0
Mon149_EvosMoves:
;DRAGONITE
;Evolutions
	db 0
;Learnset
	db 10,THUNDER_WAVE
	db 20,AGILITY
	db 35,SLAM
	db 45,DRAGON_RAGE
	db 60,HYPER_BEAM
	db 0

Mon160_EvosMoves:
;MISSINGNO
;Evolutions
	db 0
;Learnset
	db 0

Mon161_EvosMoves:
;MISSINGNO
;Evolutions
	db 0
;Learnset
	db 0

Mon162_EvosMoves:
;MISSINGNO
;Evolutions
	db 0
;Learnset
	db 0
Mon084_EvosMoves:
;DODUO
;Evolutions
	db EV_LEVEL,31,DODRIO
	db 0
;Learnset
	db 20,GROWL
	db 24,FURY_ATTACK
	db 30,DRILL_PECK
	db 36,RAGE
	db 40,TRI_ATTACK
	db 44,AGILITY
	db 0
Mon060_EvosMoves:
;POLIWAG
;Evolutions
	db EV_LEVEL,25,POLIWHIRL
	db 0
;Learnset
	db 16,HYPNOSIS
	db 19,WATER_GUN
	db 25,DOUBLESLAP
	db 31,BODY_SLAM
	db 38,AMNESIA
	db 45,HYDRO_PUMP
	db 0
Mon124_EvosMoves:
;JYNX
;Evolutions
	db 0
;Learnset
	db 18,LICK
	db 23,DOUBLESLAP
	db 31,ICE_PUNCH
	db 39,BODY_SLAM
	db 47,THRASH
	db 58,BLIZZARD
	db 0
Mon146_EvosMoves:
;MOLTRES
;Evolutions
	db 0
;Learnset
	db 51,LEER
	db 55,AGILITY
	db 60,SKY_ATTACK
	db 0
Mon144_EvosMoves:
;ARTICUNO
;Evolutions
	db 0
;Learnset
	db 51,BLIZZARD
	db 55,AGILITY
	db 60,MIST
	db 0
Mon145_EvosMoves:
;ZAPDOS
;Evolutions
	db 0
;Learnset
	db 51,THUNDER
	db 55,AGILITY
	db 60,LIGHT_SCREEN
	db 0
Mon132_EvosMoves:
;DITTO
;Evolutions
	db 0
;Learnset
	db 0
Mon052_EvosMoves:
;MEOWTH
;Evolutions
	db EV_LEVEL,28,PERSIAN
	db 0
;Learnset
	db 12,BITE
	db 17,PAY_DAY
	db 24,SCREECH
	db 33,FURY_SWIPES
	db 44,SLASH
	db 0
Mon098_EvosMoves:
;KRABBY
;Evolutions
	db EV_LEVEL,28,KINGLER
	db 0
;Learnset
	db 20,VICEGRIP
	db 25,GUILLOTINE
	db 30,STOMP
	db 35,CRABHAMMER
	db 40,HARDEN
	db 0

Mon163_EvosMoves:
;MISSINGNO
;Evolutions
	db 0
;Learnset
	db 0

Mon164_EvosMoves:
;MISSINGNO
;Evolutions
	db 0
;Learnset
	db 0

Mon165_EvosMoves:
;MISSINGNO
;Evolutions
	db 0
;Learnset
	db 0
Mon037_EvosMoves:
;VULPIX
;Evolutions
	db EV_ITEM,FIRE_STONE,1,NINETALES
	db 0
;Learnset
	db 16,QUICK_ATTACK
	db 21,ROAR
	db 28,CONFUSE_RAY
	db 35,FLAMETHROWER
	db 42,FIRE_SPIN
	db 0
Mon038_EvosMoves:
;NINETALES
;Evolutions
	db 0
;Learnset
	db 0
Mon025_EvosMoves:
;PIKACHU
;Evolutions
	db EV_ITEM,THUNDER_STONE ,1,RAICHU
	db 0
;Learnset
	db 9,THUNDER_WAVE
	db 16,QUICK_ATTACK
	db 26,SWIFT
	db 33,AGILITY
	db 43,THUNDER
	db 0
Mon026_EvosMoves:
;RAICHU
;Evolutions
	db 0
;Learnset
	db 0

Mon166_EvosMoves:
;MISSINGNO
;Evolutions
	db 0
;Learnset
	db 0

Mon167_EvosMoves:
;MISSINGNO
;Evolutions
	db 0
;Learnset
	db 0
Mon147_EvosMoves:
;DRATINI
;Evolutions
	db EV_LEVEL,30,DRAGONAIR
	db 0
;Learnset
	db 10,THUNDER_WAVE
	db 20,AGILITY
	db 30,SLAM
	db 40,DRAGON_RAGE
	db 50,HYPER_BEAM
	db 0
Mon148_EvosMoves:
;DRAGONAIR
;Evolutions
	db EV_LEVEL,55,DRAGONITE
	db 0
;Learnset
	db 10,THUNDER_WAVE
	db 20,AGILITY
	db 35,SLAM
	db 45,DRAGON_RAGE
	db 55,HYPER_BEAM
	db 0
Mon140_EvosMoves:
;KABUTO
;Evolutions
	db EV_LEVEL,40,KABUTOPS
	db 0
;Learnset
	db 34,ABSORB
	db 39,SLASH
	db 44,LEER
	db 49,HYDRO_PUMP
	db 0
Mon141_EvosMoves:
;KABUTOPS
;Evolutions
	db 0
;Learnset
	db 34,ABSORB
	db 39,SLASH
	db 46,LEER
	db 53,HYDRO_PUMP
	db 0
Mon116_EvosMoves:
;HORSEA
;Evolutions
	db EV_LEVEL,32,SEADRA
	db 0
;Learnset
	db 19,SMOKESCREEN
	db 24,LEER
	db 30,WATER_GUN
	db 37,AGILITY
	db 45,HYDRO_PUMP
	db 0
Mon117_EvosMoves:
;SEADRA
;Evolutions
	db 0
;Learnset
	db 19,SMOKESCREEN
	db 24,LEER
	db 30,WATER_GUN
	db 41,AGILITY
	db 52,HYDRO_PUMP
	db 0

Mon168_EvosMoves:
;MISSINGNO
;Evolutions
	db 0
;Learnset
	db 0

Mon169_EvosMoves:
;MISSINGNO
;Evolutions
	db 0
;Learnset
	db 0
Mon027_EvosMoves:
;SANDSHREW
;Evolutions
	db EV_LEVEL,22,SANDSLASH
	db 0
;Learnset
	db 10,SAND_ATTACK
	db 17,SLASH
	db 24,POISON_STING
	db 31,SWIFT
	db 38,FURY_SWIPES
	db 0
Mon028_EvosMoves:
;SANDSLASH
;Evolutions
	db 0
;Learnset
	db 10,SAND_ATTACK
	db 17,SLASH
	db 27,POISON_STING
	db 36,SWIFT
	db 47,FURY_SWIPES
	db 0
Mon138_EvosMoves:
;OMANYTE
;Evolutions
	db EV_LEVEL,40,OMASTAR
	db 0
;Learnset
	db 34,HORN_ATTACK
	db 39,LEER
	db 46,SPIKE_CANNON
	db 53,HYDRO_PUMP
	db 0
Mon139_EvosMoves:
;OMASTAR
;Evolutions
	db 0
;Learnset
	db 34,HORN_ATTACK
	db 39,LEER
	db 44,SPIKE_CANNON
	db 49,HYDRO_PUMP
	db 0
Mon039_EvosMoves:
;JIGGLYPUFF
;Evolutions
	db EV_ITEM,MOON_STONE,1,WIGGLYTUFF
	db 0
;Learnset
	db 9,POUND
	db 14,DISABLE
	db 19,DEFENSE_CURL
	db 24,DOUBLESLAP
	db 29,REST
	db 34,BODY_SLAM
	db 39,DOUBLE_EDGE
	db 0
Mon040_EvosMoves:
;WIGGLYTUFF
;Evolutions
	db 0
;Learnset
	db 0
Mon133_EvosMoves:
;EEVEE
;Evolutions
	db EV_ITEM,FIRE_STONE,1,FLAREON
	db EV_ITEM,THUNDER_STONE ,1,JOLTEON
	db EV_ITEM,WATER_STONE ,1,VAPOREON
	db 0
;Learnset
	db 27,QUICK_ATTACK
	db 31,TAIL_WHIP
	db 37,BITE
	db 45,TAKE_DOWN
	db 0
Mon136_EvosMoves:
;FLAREON
;Evolutions
	db 0
;Learnset
	db 27,QUICK_ATTACK
	db 31,EMBER
	db 37,TAIL_WHIP
	db 40,BITE
	db 42,LEER
	db 44,FIRE_SPIN
	db 48,RAGE
	db 54,FLAMETHROWER
	db 0
Mon135_EvosMoves:
;JOLTEON
;Evolutions
	db 0
;Learnset
	db 27,QUICK_ATTACK
	db 31,THUNDERSHOCK
	db 37,TAIL_WHIP
	db 40,THUNDER_WAVE
	db 42,DOUBLE_KICK
	db 44,AGILITY
	db 48,PIN_MISSILE
	db 54,THUNDER
	db 0
Mon134_EvosMoves:
;VAPOREON
;Evolutions
	db 0
;Learnset
	db 27,QUICK_ATTACK
	db 31,WATER_GUN
	db 37,TAIL_WHIP
	db 40,BITE
	db 42,ACID_ARMOR
	db 44,HAZE
	db 48,MIST
	db 54,HYDRO_PUMP
	db 0
Mon066_EvosMoves:
;MACHOP
;Evolutions
	db EV_LEVEL,28,MACHOKE
	db 0
;Learnset
	db 20,LOW_KICK
	db 25,LEER
	db 32,FOCUS_ENERGY
	db 39,SEISMIC_TOSS
	db 46,SUBMISSION
	db 0
Mon041_EvosMoves:
;ZUBAT
;Evolutions
	db EV_LEVEL,22,GOLBAT
	db 0
;Learnset
	db 10,SUPERSONIC
	db 15,BITE
	db 21,CONFUSE_RAY
	db 28,WING_ATTACK
	db 36,HAZE
	db 0
Mon023_EvosMoves:
;EKANS
;Evolutions
	db EV_LEVEL,22,ARBOK
	db 0
;Learnset
	db 10,POISON_STING
	db 17,BITE
	db 24,GLARE
	db 31,SCREECH
	db 38,ACID
	db 0
Mon046_EvosMoves:
;PARAS
;Evolutions
	db EV_LEVEL,24,PARASECT
	db 0
;Learnset
	db 13,STUN_SPORE
	db 20,LEECH_LIFE
	db 27,SPORE
	db 34,SLASH
	db 41,GROWTH
	db 0
Mon061_EvosMoves:
;POLIWHIRL
;Evolutions
	db EV_ITEM,WATER_STONE ,1,POLIWRATH
	db 0
;Learnset
	db 16,HYPNOSIS
	db 19,WATER_GUN
	db 26,DOUBLESLAP
	db 33,BODY_SLAM
	db 41,AMNESIA
	db 49,HYDRO_PUMP
	db 0
Mon062_EvosMoves:
;POLIWRATH
;Evolutions
	db 0
;Learnset
	db 16,HYPNOSIS
	db 19,WATER_GUN
	db 0
Mon013_EvosMoves:
;WEEDLE
;Evolutions
	db EV_LEVEL,7,KAKUNA
	db 0
;Learnset
	db 0
Mon014_EvosMoves:
;KAKUNA
;Evolutions
	db EV_LEVEL,10,BEEDRILL
	db 0
;Learnset
	db 0
Mon015_EvosMoves:
;BEEDRILL
;Evolutions
	db 0
;Learnset
	db 12,FURY_ATTACK
	db 16,FOCUS_ENERGY
	db 20,TWINEEDLE
	db 25,RAGE
	db 30,PIN_MISSILE
	db 35,AGILITY
	db 0

Mon170_EvosMoves:
;MISSINGNO
;Evolutions
	db 0
;Learnset
	db 0
Mon085_EvosMoves:
;DODRIO
;Evolutions
	db 0
;Learnset
	db 20,GROWL
	db 24,FURY_ATTACK
	db 30,DRILL_PECK
	db 39,RAGE
	db 45,TRI_ATTACK
	db 51,AGILITY
	db 0
Mon057_EvosMoves:
;PRIMEAPE
;Evolutions
	db 0
;Learnset
	db 15,KARATE_CHOP
	db 21,FURY_SWIPES
	db 27,FOCUS_ENERGY
	db 37,SEISMIC_TOSS
	db 46,THRASH
	db 0
Mon051_EvosMoves:
;DUGTRIO
;Evolutions
	db 0
;Learnset
	db 15,GROWL
	db 19,DIG
	db 24,SAND_ATTACK
	db 35,SLASH
	db 47,EARTHQUAKE
	db 0
Mon049_EvosMoves:
;VENOMOTH
;Evolutions
	db 0
;Learnset
	db 24,POISONPOWDER
	db 27,LEECH_LIFE
	db 30,STUN_SPORE
	db 38,PSYBEAM
	db 43,SLEEP_POWDER
	db 50,PSYCHIC_M
	db 0
Mon087_EvosMoves:
;DEWGONG
;Evolutions
	db 0
;Learnset
	db 30,GROWL
	db 35,AURORA_BEAM
	db 44,REST
	db 50,TAKE_DOWN
	db 56,ICE_BEAM
	db 0

Mon171_EvosMoves:
;MISSINGNO
;Evolutions
	db 0
;Learnset
	db 0

Mon172_EvosMoves:
;MISSINGNO
;Evolutions
	db 0
;Learnset
	db 0
Mon010_EvosMoves:
;CATERPIE
;Evolutions
	db EV_LEVEL,7,METAPOD
	db 0
;Learnset
	db 0
Mon011_EvosMoves:
;METAPOD
;Evolutions
	db EV_LEVEL,10,BUTTERFREE
	db 0
;Learnset
	db 0
Mon012_EvosMoves:
;BUTTERFREE
;Evolutions
	db 0
;Learnset
	db 12,CONFUSION
	db 15,POISONPOWDER
	db 16,STUN_SPORE
	db 17,SLEEP_POWDER
	db 21,SUPERSONIC
	db 26,WHIRLWIND
	db 32,PSYBEAM
	db 0
Mon068_EvosMoves:
;MACHAMP
;Evolutions
	db 0
;Learnset
	db 20,LOW_KICK
	db 25,LEER
	db 36,FOCUS_ENERGY
	db 44,SEISMIC_TOSS
	db 52,SUBMISSION
	db 0

Mon173_EvosMoves:
;MISSINGNO
;Evolutions
	db 0
;Learnset
	db 0
Mon055_EvosMoves:
;GOLDUCK
;Evolutions
	db 0
;Learnset
	db 28,TAIL_WHIP
	db 31,DISABLE
	db 39,CONFUSION
	db 48,FURY_SWIPES
	db 59,HYDRO_PUMP
	db 0
Mon097_EvosMoves:
;HYPNO
;Evolutions
	db 0
;Learnset
	db 12,DISABLE
	db 17,CONFUSION
	db 24,HEADBUTT
	db 33,POISON_GAS
	db 37,PSYCHIC_M
	db 43,MEDITATE
	db 0
Mon042_EvosMoves:
;GOLBAT
;Evolutions
	db 0
;Learnset
	db 10,SUPERSONIC
	db 15,BITE
	db 21,CONFUSE_RAY
	db 32,WING_ATTACK
	db 43,HAZE
	db 0
Mon150_EvosMoves:
;MEWTWO
;Evolutions
	db 0
;Learnset
	db 63,BARRIER
	db 66,PSYCHIC_M
	db 70,RECOVER
	db 75,MIST
	db 81,AMNESIA
	db 0
Mon143_EvosMoves:
;SNORLAX
;Evolutions
	db 0
;Learnset
	db 35,BODY_SLAM
	db 41,HARDEN
	db 48,DOUBLE_EDGE
	db 56,HYPER_BEAM
	db 0
Mon129_EvosMoves:
;MAGIKARP
;Evolutions
	db EV_LEVEL,20,GYARADOS
	db 0
;Learnset
	db 15,TACKLE
	db 0

Mon174_EvosMoves:
;MISSINGNO
;Evolutions
	db 0
;Learnset
	db 0

Mon175_EvosMoves:
;MISSINGNO
;Evolutions
	db 0
;Learnset
	db 0
Mon089_EvosMoves:
;MUK
;Evolutions
	db 0
;Learnset
	db 30,POISON_GAS
	db 33,MINIMIZE
	db 37,SLUDGE
	db 45,HARDEN
	db 53,SCREECH
	db 60,ACID_ARMOR
	db 0

Mon176_EvosMoves:
;MISSINGNO
;Evolutions
	db 0
;Learnset
	db 0
Mon099_EvosMoves:
;KINGLER
;Evolutions
	db 0
;Learnset
	db 20,VICEGRIP
	db 25,GUILLOTINE
	db 34,STOMP
	db 42,CRABHAMMER
	db 49,HARDEN
	db 0
Mon091_EvosMoves:
;CLOYSTER
;Evolutions
	db 0
;Learnset
	db 50,SPIKE_CANNON
	db 0

Mon177_EvosMoves:
;MISSINGNO
;Evolutions
	db 0
;Learnset
	db 0
Mon101_EvosMoves:
;ELECTRODE
;Evolutions
	db 0
;Learnset
	db 17,SONICBOOM
	db 22,SELFDESTRUCT
	db 29,LIGHT_SCREEN
	db 40,SWIFT
	db 50,EXPLOSION
	db 0
Mon036_EvosMoves:
;CLEFABLE
;Evolutions
	db 0
;Learnset
	db 0
Mon110_EvosMoves:
;WEEZING
;Evolutions
	db 0
;Learnset
	db 32,SLUDGE
	db 39,SMOKESCREEN
	db 43,SELFDESTRUCT
	db 49,HAZE
	db 53,EXPLOSION
	db 0
Mon053_EvosMoves:
;PERSIAN
;Evolutions
	db 0
;Learnset
	db 12,BITE
	db 17,PAY_DAY
	db 24,SCREECH
	db 37,FURY_SWIPES
	db 51,SLASH
	db 0
Mon105_EvosMoves:
;MAROWAK
;Evolutions
	db 0
;Learnset
	db 25,LEER
	db 33,FOCUS_ENERGY
	db 41,THRASH
	db 48,BONEMERANG
	db 55,RAGE
	db 0

Mon178_EvosMoves:
;MISSINGNO
;Evolutions
	db 0
;Learnset
	db 0
Mon093_EvosMoves:
;HAUNTER
;Evolutions
	db EV_TRADE,1,GENGAR
	db 0
;Learnset
	db 29,HYPNOSIS
	db 38,DREAM_EATER
	db 0
Mon063_EvosMoves:
;ABRA
;Evolutions
	db EV_LEVEL,16,KADABRA
	db 0
;Learnset
	db 0
Mon065_EvosMoves:
;ALAKAZAM
;Evolutions
	db 0
;Learnset
	db 16,CONFUSION
	db 20,DISABLE
	db 27,PSYBEAM
	db 31,RECOVER
	db 38,PSYCHIC_M
	db 42,REFLECT
	db 0
Mon017_EvosMoves:
;PIDGEOTTO
;Evolutions
	db EV_LEVEL,36,PIDGEOT
	db 0
;Learnset
	db 5,SAND_ATTACK
	db 12,QUICK_ATTACK
	db 21,WHIRLWIND
	db 31,WING_ATTACK
	db 40,AGILITY
	db 49,MIRROR_MOVE
	db 0
Mon018_EvosMoves:
;PIDGEOT
;Evolutions
	db 0
;Learnset
	db 5,SAND_ATTACK
	db 12,QUICK_ATTACK
	db 21,WHIRLWIND
	db 31,WING_ATTACK
	db 44,AGILITY
	db 54,MIRROR_MOVE
	db 0
Mon121_EvosMoves:
;STARMIE
;Evolutions
	db 0
;Learnset
	db 0
Mon001_EvosMoves:
;BULBASAUR
;Evolutions
	db EV_LEVEL,16,IVYSAUR
	db 0
;Learnset
	db 7,LEECH_SEED
	db 13,VINE_WHIP
	db 20,POISONPOWDER
	db 27,RAZOR_LEAF
	db 34,GROWTH
	db 41,SLEEP_POWDER
	db 48,SOLARBEAM
	db 0
Mon003_EvosMoves:
;VENUSAUR
;Evolutions
	db 0
;Learnset
	db 7,LEECH_SEED
	db 13,VINE_WHIP
	db 22,POISONPOWDER
	db 30,RAZOR_LEAF
	db 43,GROWTH
	db 55,SLEEP_POWDER
	db 65,SOLARBEAM
	db 0
Mon073_EvosMoves:
;TENTACRUEL
;Evolutions
	db 0
;Learnset
	db 7,SUPERSONIC
	db 13,WRAP
	db 18,POISON_STING
	db 22,WATER_GUN
	db 27,CONSTRICT
	db 35,BARRIER
	db 43,SCREECH
	db 50,HYDRO_PUMP
	db 0

Mon179_EvosMoves:
;MISSINGNO
;Evolutions
	db 0
;Learnset
	db 0
Mon118_EvosMoves:
;GOLDEEN
;Evolutions
	db EV_LEVEL,33,SEAKING
	db 0
;Learnset
	db 19,SUPERSONIC
	db 24,HORN_ATTACK
	db 30,FURY_ATTACK
	db 37,WATERFALL
	db 45,HORN_DRILL
	db 54,AGILITY
	db 0
Mon119_EvosMoves:
;SEAKING
;Evolutions
	db 0
;Learnset
	db 19,SUPERSONIC
	db 24,HORN_ATTACK
	db 30,FURY_ATTACK
	db 39,WATERFALL
	db 48,HORN_DRILL
	db 54,AGILITY
	db 0

Mon180_EvosMoves:
;MISSINGNO
;Evolutions
	db 0
;Learnset
	db 0

Mon181_EvosMoves:
;MISSINGNO
;Evolutions
	db 0
;Learnset
	db 0

Mon182_EvosMoves:
;MISSINGNO
;Evolutions
	db 0
;Learnset
	db 0

Mon183_EvosMoves:
;MISSINGNO
;Evolutions
	db 0
;Learnset
	db 0
Mon077_EvosMoves:
;PONYTA
;Evolutions
	db EV_LEVEL,40,RAPIDASH
	db 0
;Learnset
	db 30,TAIL_WHIP
	db 32,STOMP
	db 35,GROWL
	db 39,FIRE_SPIN
	db 43,TAKE_DOWN
	db 48,AGILITY
	db 0
Mon078_EvosMoves:
;RAPIDASH
;Evolutions
	db 0
;Learnset
	db 30,TAIL_WHIP
	db 32,STOMP
	db 35,GROWL
	db 39,FIRE_SPIN
	db 47,TAKE_DOWN
	db 55,AGILITY
	db 0
Mon019_EvosMoves:
;RATTATA
;Evolutions
	db EV_LEVEL,20,RATICATE
	db 0
;Learnset
	db 7,QUICK_ATTACK
	db 14,HYPER_FANG
	db 23,FOCUS_ENERGY
	db 34,SUPER_FANG
	db 0
Mon020_EvosMoves:
;RATICATE
;Evolutions
	db 0
;Learnset
	db 7,QUICK_ATTACK
	db 14,HYPER_FANG
	db 27,FOCUS_ENERGY
	db 41,SUPER_FANG
	db 0
Mon033_EvosMoves:
;NIDORINO
;Evolutions
	db EV_ITEM,MOON_STONE,1,NIDOKING
	db 0
;Learnset
	db 8,HORN_ATTACK
	db 14,POISON_STING
	db 23,FOCUS_ENERGY
	db 32,FURY_ATTACK
	db 41,HORN_DRILL
	db 50,DOUBLE_KICK
	db 0
Mon030_EvosMoves:
;NIDORINA
;Evolutions
	db EV_ITEM,MOON_STONE,1,NIDOQUEEN
	db 0
;Learnset
	db 8,SCRATCH
	db 14,POISON_STING
	db 23,TAIL_WHIP
	db 32,BITE
	db 41,FURY_SWIPES
	db 50,DOUBLE_KICK
	db 0
Mon074_EvosMoves:
;GEODUDE
;Evolutions
	db EV_LEVEL,25,GRAVELER
	db 0
;Learnset
	db 11,DEFENSE_CURL
	db 16,ROCK_THROW
	db 21,SELFDESTRUCT
	db 26,HARDEN
	db 31,EARTHQUAKE
	db 36,EXPLOSION
	db 0
Mon137_EvosMoves:
;PORYGON
;Evolutions
	db 0
;Learnset
	db 23,PSYBEAM
	db 28,RECOVER
	db 35,AGILITY
	db 42,TRI_ATTACK
	db 0
Mon142_EvosMoves:
;AERODACTYL
;Evolutions
	db 0
;Learnset
	db 33,SUPERSONIC
	db 38,BITE
	db 45,TAKE_DOWN
	db 54,HYPER_BEAM
	db 0

Mon184_EvosMoves:
;MISSINGNO
;Evolutions
	db 0
;Learnset
	db 0
Mon081_EvosMoves:
;MAGNEMITE
;Evolutions
	db EV_LEVEL,30,MAGNETON
	db 0
;Learnset
	db 21,SONICBOOM
	db 25,THUNDERSHOCK
	db 29,SUPERSONIC
	db 35,THUNDER_WAVE
	db 41,SWIFT
	db 47,SCREECH
	db 0

Mon185_EvosMoves:
;MISSINGNO
;Evolutions
	db 0
;Learnset
	db 0

Mon186_EvosMoves:
;MISSINGNO
;Evolutions
	db 0
;Learnset
	db 0
Mon004_EvosMoves:
;CHARMANDER
;Evolutions
	db EV_LEVEL,16,CHARMELEON
	db 0
;Learnset
	db 9,EMBER
	db 15,LEER
	db 22,RAGE
	db 30,SLASH
	db 38,FLAMETHROWER
	db 46,FIRE_SPIN
	db 0
Mon007_EvosMoves:
;SQUIRTLE
;Evolutions
	db EV_LEVEL,16,WARTORTLE
	db 0
;Learnset
	db 8,BUBBLE
	db 15,WATER_GUN
	db 22,BITE
	db 28,WITHDRAW
	db 35,SKULL_BASH
	db 42,HYDRO_PUMP
	db 0
Mon005_EvosMoves:
;CHARMELEON
;Evolutions
	db EV_LEVEL,36,CHARIZARD
	db 0
;Learnset
	db 9,EMBER
	db 15,LEER
	db 24,RAGE
	db 33,SLASH
	db 42,FLAMETHROWER
	db 56,FIRE_SPIN
	db 0
Mon008_EvosMoves:
;WARTORTLE
;Evolutions
	db EV_LEVEL,36,BLASTOISE
	db 0
;Learnset
	db 8,BUBBLE
	db 15,WATER_GUN
	db 24,BITE
	db 31,WITHDRAW
	db 39,SKULL_BASH
	db 47,HYDRO_PUMP
	db 0
Mon006_EvosMoves:
;CHARIZARD
;Evolutions
	db 0
;Learnset
	db 9,EMBER
	db 15,LEER
	db 24,RAGE
	db 36,SLASH
	db 46,FLAMETHROWER
	db 55,FIRE_SPIN
	db 0

Mon187_EvosMoves:
;MISSINGNO
;Evolutions
	db 0
;Learnset
	db 0

Mon188_EvosMoves:
;MISSINGNO
;Evolutions
	db 0
;Learnset
	db 0

Mon189_EvosMoves:
;MISSINGNO
;Evolutions
	db 0
;Learnset
	db 0

Mon190_EvosMoves:
;MISSINGNO
;Evolutions
	db 0
;Learnset
	db 0
Mon043_EvosMoves:
;ODDISH
;Evolutions
	db EV_LEVEL,21,GLOOM
	db 0
;Learnset
	db 15,POISONPOWDER
	db 17,STUN_SPORE
	db 19,SLEEP_POWDER
	db 24,ACID
	db 33,PETAL_DANCE
	db 46,SOLARBEAM
	db 0
Mon044_EvosMoves:
;GLOOM
;Evolutions
	db EV_ITEM,LEAF_STONE ,1,VILEPLUME
	db 0
;Learnset
	db 15,POISONPOWDER
	db 17,STUN_SPORE
	db 19,SLEEP_POWDER
	db 28,ACID
	db 38,PETAL_DANCE
	db 52,SOLARBEAM
	db 0
Mon045_EvosMoves:
;VILEPLUME
;Evolutions
	db 0
;Learnset
	db 15,POISONPOWDER
	db 17,STUN_SPORE
	db 19,SLEEP_POWDER
	db 0
Mon069_EvosMoves:
;BELLSPROUT
;Evolutions
	db EV_LEVEL,21,WEEPINBELL
	db 0
;Learnset
	db 13,WRAP
	db 15,POISONPOWDER
	db 18,SLEEP_POWDER
	db 21,STUN_SPORE
	db 26,ACID
	db 33,RAZOR_LEAF
	db 42,SLAM
	db 0
Mon070_EvosMoves:
;WEEPINBELL
;Evolutions
	db EV_ITEM,LEAF_STONE ,1,VICTREEBEL
	db 0
;Learnset
	db 13,WRAP
	db 15,POISONPOWDER
	db 18,SLEEP_POWDER
	db 23,STUN_SPORE
	db 29,ACID
	db 38,RAZOR_LEAF
	db 49,SLAM
	db 0
Mon071_EvosMoves:
;VICTREEBEL
;Evolutions
	db 0
;Learnset
	db 13,WRAP
	db 15,POISONPOWDER
	db 18,SLEEP_POWDER
	db 0

INCBIN "baserom.gbc",$3b9ec,$3baa2 - $3b9ec

UnnamedText_3baa2: ; 0x3baa2
	TX_FAR _UnnamedText_3baa2
	db $50
; 0x3baa2 + 5 bytes

UnnamedText_3baa7: ; 0x3baa7
	TX_FAR _UnnamedText_3baa7
	db $50
; 0x3baa7 + 5 bytes

UnnamedText_3baac: ; 0x3baac
	TX_FAR _UnnamedText_3baac
	db $50
; 0x3baac + 5 bytes

INCBIN "baserom.gbc",$3bab1,$3bb92 - $3bab1

UnnamedText_3bb92: ; 0x3bb92
	TX_FAR _UnnamedText_3bb92
	db $50
; 0x3bb92 + 5 bytes

INCBIN "baserom.gbc",$3bb97,$3bbd7 - $3bb97

UnnamedText_3bbd7: ; 0x3bbd7
	TX_FAR _UnnamedText_3bbd7
	db $50
; 0x3bbd7 + 5 bytes

UnnamedText_3bbdc: ; 0x3bbdc
	TX_FAR _UnnamedText_3bbdc
	db $50
; 0x3bbdc + 5 bytes

Unnamed_3bbe1: ; 0x3bbe1
	db $6, $f, $c3, $d6, $35

SECTION "bankF",DATA,BANK[$F]

; These are move effects (second value from the Moves table in bank $E).
EffectsArray1: ; 4000
	db $18,$19,$1C,$2E,$2F,$31,$38,$39,$40,$41,$42,$43,$4F,$52,$54,$55,$FF
EffectsArray2: ; 4011
; moves that do damage but not through normal calculations
; e.g., Super Fang, Psywave
	db $28,$29,$FF
EffectsArray3: ; 4014
; non-damaging, stat‐affecting or status‐causing moves?
; e.g., Meditate, Bide, Hypnosis
	db $01,$0A,$0B,$0C,$0D,$0E,$0F,$12,$13,$14,$15,$16,$17,$1A,$20,$32,$33,$34,$35,$36,$37,$3A,$3B,$3C,$3D,$3E,$3F,$FF
EffectsArray4: ; 4030
	db $03,$07,$08,$10,$1D,$1E,$2C,$30,$4D,$51,$FF
EffectsArray5: ; 403B
	db $03,$07,$08,$10,$11,$1D,$1E,$27,$28,$29,$2B,$2C,$2D,$30 ; fallthru
EffectsArray5B: ; 4049
; moves that prevent the player from switching moves?
	db $1B,$2A,$FF

INCBIN "baserom.gbc",$3c04c,$3c1a8 - $3c04c

UnnamedText_3c1a8: ; 0x3c1a8
	TX_FAR _UnnamedText_3c1a8
	db $50
; 0x3c1a8 + 5 bytes

INCBIN "baserom.gbc",$3c1ad,$3c229 - $3c1ad

UnnamedText_3c229: ; 0x3c229
	TX_FAR _UnnamedText_3c229
	db $50
; 0x3c229 + 5 bytes

UnnamedText_3c22e: ; 0x3c22e
	TX_FAR _UnnamedText_3c22e
	db $50
; 0x3c22e + 5 bytes

INCBIN "baserom.gbc",$3c233,$3c42e - $3c233

UnnamedText_3c42e: ; 0x3c42e
	TX_FAR _UnnamedText_3c42e
	db $50
; 0x3c42e + 5 bytes

UnnamedText_3c433: ; 0x3c433
	TX_FAR _UnnamedText_3c433
	db $50
; 0x3c433 + 5 bytes

UnnamedText_3c438: ; 0x3c438
	TX_FAR _UnnamedText_3c438
	db $50
; 0x3c438 + 5 bytes

INCBIN "baserom.gbc",$3c43d,$3c63e - $3c43d

UnnamedText_3c63e: ; 0x3c63e
	TX_FAR _UnnamedText_3c63e
	db $50
; 0x3c63e + 5 bytes

INCBIN "baserom.gbc",$3c643,$3c6e4 - $3c643

UnnamedText_3c6e4: ; 0x3c6e4
	TX_FAR _UnnamedText_3c6e4
	db $50
; 0x3c6e4 + 5 bytes

UnnamedText_3c6e9: ; 0x3c6e9
	TX_FAR _UnnamedText_3c6e9
	db $50
; 0x3c6e9 + 5 bytes

INCBIN "baserom.gbc",$3c6ee,$3c796 - $3c6ee

UnnamedText_3c796: ; 0x3c796
	TX_FAR _UnnamedText_3c796
	db $50
; 0x3c796 + 5 bytes

INCBIN "baserom.gbc",$3c79b,$3c7d3 - $3c79b

UnnamedText_3c7d3: ; 0x3c7d3
	TX_FAR _UnnamedText_3c7d3
	db $50
; 0x3c7d3 + 5 bytes

INCBIN "baserom.gbc",$3c7d8,$3c884 - $3c7d8

UnnamedText_3c884: ; 0x3c884
	TX_FAR _UnnamedText_3c884
	db $50
; 0x3c884 + 5 bytes

UnnamedText_3c889: ; 0x3c889
	TX_FAR _UnnamedText_3c889
	db $50
; 0x3c889 + 5 bytes

UnnamedText_3c88e: ; 0x3c88e
	TX_FAR _UnnamedText_3c88e
	db $50
; 0x3c88e + 5 bytes

INCBIN "baserom.gbc",$3c893,$7b

; XXX this needs cleaning up. it's what runs when a juggler switches pokemon
EnemySendOut: ; 490E
	ld hl,$D058
	xor a
	ld [hl],a
	ld a,[$CC2F]
	ld c,a
	ld b,1
	push bc
	ld a,$10
	call Predef
	ld hl,$CCF5
	xor a
	ld [hl],a
	pop bc
	ld a,$10
	call Predef
	xor a
	ld hl,$D065
	ld [hli],a
	ld [hli],a
	ld [hli],a
	ld [hli],a
	ld [hl],a
	ld [$D072],a
	ld [$CCEF],a
	ld [$CCF3],a
	ld hl,$CCF1
	ld [hli],a
	ld [hl],a
	dec a
	ld [W_AICOUNT],a
	ld hl,W_PLAYERBATTSTATUS1
	res 5,[hl]
	ld hl,$C3B2
	ld a,8
	call $48DF
	call $6E94
	call $3719
	ld a,[$D12B]
	cp 4
	jr nz,.next\@
	ld a,[$CC3E]
	sub 4
	ld [$CF92],a
	jr .next3\@
.next\@
	ld b,$FF
.next2\@
	inc b
	ld a,[$CFE8]
	cp b
	jr z,.next2\@
	ld hl,$D8A4
	ld a,b
	ld [$CF92],a
	push bc
	ld bc,$2C
	call AddNTimes
	pop bc
	inc hl
	ld a,[hli]
	ld c,a
	ld a,[hl]
	or c
	jr z,.next2\@
.next3\@
	ld a,[$CF92]
	ld hl,$D8C5
	ld bc,$2C
	call AddNTimes
	ld a,[hl]
	ld [$D127],a
	ld a,[$CF92]
	inc a
	ld hl,$D89C
	ld c,a
	ld b,0
	add hl,bc
	ld a,[hl]
	ld [$CFD8],a
	ld [$CF91],a
	call $6B01
	ld hl,$CFE6
	ld a,[hli]
	ld [$CCE3],a
	ld a,[hl]
	ld [$CCE4],a
	ld a,1
	ld [$CC26],a
	ld a,[$D11D]
	dec a
	jr z,.next4\@
	ld a,[W_NUMINPARTY]
	dec a
	jr z,.next4\@
	ld a,[$D12B]
	cp 4
	jr z,.next4\@
	ld a,[$D355]
	bit 6,a
	jr nz,.next4\@
	ld hl, TrainerAboutToUseText
	call PrintText
	ld hl,$C42C
	ld bc,$0801
	ld a,$14
	ld [$D125],a
	call $30E8
	ld a,[$CC26]
	and a
	jr nz,.next4\@
	ld a,2
	ld [$D07D],a
	call $13FC
.next9\@
	ld a,1
	ld [$CC26],a
	jr c,.next7\@
	ld hl,$CC2F
	ld a,[$CF92]
	cp [hl]
	jr nz,.next6\@
	ld hl,$51F5
	call PrintText
.next8\@
	call $1411
	jr .next9\@
.next6\@
	call $4A97
	jr z,.next8\@
	xor a
	ld [$CC26],a
.next7\@
	call $3DE5
	call $6E5B
	call $3725
.next4\@
	call $0082
	ld hl,$C3A0
	ld bc,$040B
	call $18C4
	ld b,1
	call $3DEF
	call $3DDC
	ld hl,TrainerSentOutText
	call PrintText
	ld a,[$CFD8]
	ld [$CF91],a
	ld [$D0B5],a
	call $1537
	ld de,$9000
	call $1665
	ld a,$CF
	ld [$FFE1],a
	ld hl,$C427
	ld a,2
	call Predef
	ld a,[$CFD8]
	call $13D0
	call $4DEC
	ld a,[$CC26]
	and a
	ret nz
	xor a
	ld [$D058],a
	ld [$CCF5],a
	call $3719
	jp $51BA

TrainerAboutToUseText: ; 0x3ca79
	TX_FAR _TrainerAboutToUseText
	db "@"

TrainerSentOutText: ; 0x3ca7e
	TX_FAR _TrainerSentOutText
	db "@"

INCBIN "baserom.gbc",$3ca83,$3cab4 - $3ca83

UnnamedText_3cab4: ; 0x3cab4
	TX_FAR _UnnamedText_3cab4
	db $50
; 0x3cab4 + 5 bytes

INCBIN "baserom.gbc",$3cab9,$3cb97 - $3cab9

UnnamedText_3cb97: ; 0x3cb97
	TX_FAR _UnnamedText_3cb97
	db $50
; 0x3cb97 + 5 bytes

UnnamedText_3cb9c: ; 0x3cb9c
	TX_FAR _UnnamedText_3cb9c
	db $50
; 0x3cb9c + 5 bytes

UnnamedText_3cba1: ; 0x3cba1
	TX_FAR _UnnamedText_3cba1
	db $50
; 0x3cba1 + 5 bytes

INCBIN "baserom.gbc",$3cba6,$3d0c5 - $3cba6

UnnamedText_3d0c5: ; 0x3d0c5
	TX_FAR _UnnamedText_3d0c5
	db $50
; 0x3d0c5 + 5 bytes

INCBIN "baserom.gbc",$3d0ca,$3d1f5 - $3d0ca

UnnamedText_3d1f5: ; 0x3d1f5
	TX_FAR _UnnamedText_3d1f5
	db $50
; 0x3d1f5 + 5 bytes

INCBIN "baserom.gbc",$3d1fa,$3d3ae - $3d1fa

UnnamedText_3d3ae: ; 0x3d3ae
	TX_FAR _UnnamedText_3d3ae
	db $50
; 0x3d3ae + 5 bytes

UnnamedText_3d3b3: ; 0x3d3b3
	TX_FAR _UnnamedText_3d3b3
	db $50
; 0x3d3b3 + 5 bytes

INCBIN "baserom.gbc",$3d3b8,$3d430 - $3d3b8

UnnamedText_3d430: ; 0x3d430
	TX_FAR _UnnamedText_3d430
	db $50
; 0x3d430 + 5 bytes

INCBIN "baserom.gbc",$3d435,$274

; in-battle stuff
	ld hl,W_PLAYERBATTSTATUS1
	res 4,[hl]
	res 6,[hl]
	call $5AF5
	ld hl,DecrementPP
	ld de,$CCDC ; pointer to the move just used
	ld b,BANK(DecrementPP)
	call Bankswitch
	ld a,[W_PLAYERMOVEEFFECT] ; effect of the move just used
	ld hl,EffectsArray1
	ld de,1
	call IsInArray
	jp c,$7132
	ld a,[W_PLAYERMOVEEFFECT]
	ld hl,EffectsArray5B
	ld de,1
	call IsInArray
	call c,$7132
	ld a,[W_PLAYERMOVEEFFECT]
	ld hl,EffectsArray2
	ld de,1
	call IsInArray
	jp c,$5702
	call $6023
	call $6093
	jr z,.next11\@
	call $5DCF
	call $5F65
	jp z,$574B
	call $63A5
	call $6687
	call $656B
.next11\@
	ld a,[W_MOVEMISSED]
	and a
	jr z,.next\@
	ld a,[W_PLAYERMOVEEFFECT]
	sub a,7
	jr z,.next2\@
	jr .next3\@ ; 574B
.next\@
	ld a,[W_PLAYERMOVEEFFECT]
	and a
	ld a,4
	jr z,.next2\@
	ld a,5
.next2\@
	push af
	ld a,[W_PLAYERBATTSTATUS2]
	bit 4,a
	ld hl,$5747
	ld b,$1E
	call nz,Bankswitch
	pop af
	ld [$CC5B],a
	ld a,[W_PLAYERMOVENUM]
	call $6F07
	call $6ED3
	call $4D60
	ld a,[W_PLAYERBATTSTATUS2]
	bit 4,a
	ld hl,$5771
	ld b,$1E
	call nz,Bankswitch
	jr .next4\@
.next3\@
	ld c,$1E
	call $3739
	ld a,[W_PLAYERMOVEEFFECT]
	cp a,$2B
	jr z,.next5\@
	cp a,$27 ; XXX SLP | FRZ ?
	jr z,.next5\@
	jr .next4\@
.next5\@
	xor a
	ld [$CC5B],a
	ld a,$A7
	call $6F07
.next4\@
	ld a,[W_PLAYERMOVEEFFECT]
	cp a,9
	jr nz,.next6\@ ; 577A
	call $62FD
	jp z,Function580A
	xor a
	ld [$CCED],a
	jp $569A
.next6\@
	cp a,$53
	jr nz,.next7\@ ; 5784
	call $6348
	jp $569A
.next7\@
	ld a,[W_PLAYERMOVEEFFECT]
	ld hl,EffectsArray3
	ld de,1
	call IsInArray
	jp c,$7132
	ld a,[W_MOVEMISSED]
	and a
	jr z,.next8\@ ; 57A6
	call $5BE2
	ld a,[W_PLAYERMOVEEFFECT]
	cp a,7
	jr z,.next9\@ ; 57B9
	jp Function580A
.next8\@
	call $60DF
	call $5C5C
	ld hl,$7B7B ; MyFunction
	ld b,$B ; BANK(MyFunction)
	call Bankswitch
	ld a,1
	ld [$CCF4],a
.next9\@
	ld a,[W_PLAYERMOVEEFFECT]
	ld hl,EffectsArray4
	ld de,1
	call IsInArray
	call c,$7132
	ld hl,$CFE6
	ld a,[hli]
	ld b,[hl]
	or b
	ret z
	call $62B6

	ld hl,W_PLAYERBATTSTATUS1
	bit 2,[hl]
	jr z,.next10\@ ; 57EF
	ld a,[$D06A]
	dec a
	ld [$D06A],a
	jp nz,$5714

	res 2,[hl]
	ld hl,MultiHitText
	call PrintText
	xor a
	ld [W_NUMHITS],a ; reset
.next10\@
	ld a,[W_PLAYERMOVEEFFECT]
	and a
	jp z,Function580A
	ld hl,EffectsArray5
	ld de,1
	call IsInArray
	call nc,$7132
	jp Function580A

MultiHitText: ; 0x3d805
	TX_FAR _MultiHitText
	db "@"

Function580A: ; 0x3d80a 580A
	xor a
	ld [$CD6A],a
	ld b,1
	ret

Function5811: ; 0x3d811 5811
; print the ghost battle messages
	call $583A
	ret nz
	ld a,[H_WHOSETURN]
	and a
	jr nz,.Ghost\@
	ld a,[W_PLAYERMONSTATUS] ; player’s turn
	and a,SLP | FRZ
	ret nz
	ld hl,ScaredText
	call PrintText
	xor a
	ret
.Ghost\@ ; ghost’s turn
	ld hl,GetOutText
	call PrintText
	xor a
	ret

ScaredText: ; 0x3d830
	TX_FAR _ScaredText
	db "@"

GetOutText: ; 0x3d835
	TX_FAR _GetOutText
	db "@"

Function583A: ; 0x3d83a 583A
	ld a,[W_ISINBATTLE]
	dec a
	ret nz
	ld a,[W_CURMAP]
	cp a,$8E ; Lavender Town
	jr c,.next\@
	cp a,$95 ; Pokémon Tower
	jr nc,.next\@
	ld b,SILPH_SCOPE
	call IsItemInBag ; $3493
	ret z
.next\@
	ld a,1
	and a
	ret

Function5854: ; 5854
	ld hl,W_PLAYERMONSTATUS
	ld a,[hl]
	and a,SLP
	jr z,.FrozenCheck\@ ; to 5884

	dec a
	ld [W_PLAYERMONSTATUS],a ; decrement sleep count
	and a
	jr z,.WakeUp\@ ; to 5874

	xor a
	ld [$CC5B],a
	ld a,SLP_ANIM - 1
	call $6F07
	ld hl,FastAsleepText
	call PrintText
	jr .sleepDone\@
.WakeUp\@
	ld hl,WokeUpText
	call PrintText
.sleepDone\@
	xor a
	ld [$CCF1],a
	ld hl,Function580A
	jp $5A37

.FrozenCheck\@
	bit 5,[hl] ; frozen?
	jr z,.HeldInPlaceCheck\@ ; to 5898
	ld hl,FrozenText
	call PrintText
	xor a
	ld [$CCF1],a
	ld hl,Function580A
	jp $5A37

.HeldInPlaceCheck\@
	ld a,[W_ENEMYBATTSTATUS1]
	bit 5,a
	jp z,FlinchedCheck
	ld hl,CantMoveText
	call PrintText
	ld hl,Function580A
	jp $5A37

FlinchedCheck: ; 58AC
	ld hl,W_PLAYERBATTSTATUS1
	bit 3,[hl]
	jp z,HyperBeamCheck
	res 3,[hl]
	ld hl,FlinchedText
	call PrintText
	ld hl,Function580A
	jp $5A37

HyperBeamCheck: ; 58C2
	ld hl,W_PLAYERBATTSTATUS2
	bit 5,[hl]
	jr z,.next\@ ; 58D7
	res 5,[hl]
	ld hl,MustRechargeText
	call PrintText
	ld hl,$580A
	jp $5A37
.next\@
	ld hl,$D06D
	ld a,[hl]
	and a
	jr z,.next2\@ ; 58EE
	dec a
	ld [hl],a
	and a,$F
	jr nz,.next2\@
	ld [hl],a
	ld [$CCEE],a
	ld hl,DisabledNoMoreText
	call PrintText
.next2\@
	ld a,[W_PLAYERBATTSTATUS1]
	add a
	jr nc,.next3\@ ; 5929
	ld hl,$D06B
	dec [hl]
	jr nz,.next4\@ ; 5907
	ld hl,W_PLAYERBATTSTATUS1
	res 7,[hl]
	ld hl,ConfusedNoMoreText
	call PrintText
	jr .next3\@
.next4\@
	ld hl,IsConfusedText
	call PrintText
	xor a
	ld [$CC5B],a
	ld a,CONF_ANIM - 1
	call $6F07
	call $6E9B
	cp a,$80
	jr c,.next3\@
	ld hl,W_PLAYERBATTSTATUS1
	ld a,[hl]
	and a,$80
	ld [hl],a
	call $5AAD
	jr .next5\@ ; 5952
.next3\@
	ld a,[$CCEE]
	and a
	jr z,.ParalysisCheck\@ ; 593E
	ld hl,$CCDC
	cp [hl]
	jr nz,.ParalysisCheck\@
	call $5A88
	ld hl,$580A
	jp $5A37
.ParalysisCheck\@
	ld hl,W_PLAYERMONSTATUS
	bit 6,[hl]
	jr z,.next7\@ ; 5975
	call $6E9B ; random number?
	cp a,$3F
	jr nc,.next7\@
	ld hl,FullyParalyzedText
	call PrintText
.next5\@
	ld hl,W_PLAYERBATTSTATUS1
	ld a,[hl]
	and a,$CC
	ld [hl],a
	ld a,[W_PLAYERMOVEEFFECT]
	cp a,$2B
	jr z,.next8\@ ; 5966
	cp a,$27
	jr z,.next8\@
	jr .next9\@ ; 596F
.next8\@
	xor a
	ld [$CC5B],a
	ld a,$A7
	call $6F07
.next9\@
	ld hl,$580A
	jp $5A37
.next7\@
	ld hl,W_PLAYERBATTSTATUS1
	bit 0,[hl]
	jr z,.next10\@ ; 59D0
	xor a
	ld [W_PLAYERMOVENUM],a
	ld hl,$D0D7
	ld a,[hli]
	ld b,a
	ld c,[hl]
	ld hl,$D075
	ld a,[hl]
	add c
	ld [hld],a
	ld a,[hl]
	adc b
	ld [hl],a
	ld hl,$D06A
	dec [hl]
	jr z,.next11\@ ; 599B
	ld hl,$580A
	jp $5A37
.next11\@
	ld hl,W_PLAYERBATTSTATUS1
	res 0,[hl]
	ld hl,UnleashedEnergyText
	call PrintText
	ld a,1
	ld [$CFD4],a
	ld hl,$D075
	ld a,[hld]
	add a
	ld b,a
	ld [$D0D8],a
	ld a,[hl]
	rl a
	ld [$D0D7],a
	or b
	jr nz,.next12\@ ; 59C2
	ld a,1
	ld [W_MOVEMISSED],a
.next12\@
	xor a
	ld [hli],a
	ld [hl],a
	ld a,$75
	ld [W_PLAYERMOVENUM],a
	ld hl,$5705
	jp $5A37
.next10\@
	bit 1,[hl]
	jr z,.next13\@ ; 59FF
	ld a,$25
	ld [W_PLAYERMOVENUM],a
	ld hl,ThrashingAboutText
	call PrintText
	ld hl,$D06A
	dec [hl]
	ld hl,$56DC
	jp nz,$5A37
	push hl
	ld hl,W_PLAYERBATTSTATUS1
	res 1,[hl]
	set 7,[hl]
	call $6E9B ; random number?
	and a,3
	inc a
	inc a
	ld [$D06B],a
	pop hl
	jp $5A37
.next13\@
	bit 5,[hl]
	jp z,$5A1A
	ld hl,AttackContinuesText
	call PrintText
	ld a,[$D06A]
	dec a
	ld [$D06A],a
	ld hl,$5714
	jp nz,$5A37
	jp $5A37

INCBIN "baserom.gbc",$3DA1A,$3DA3D - $3DA1A

FastAsleepText:
	TX_FAR _FastAsleepText
	db "@"

WokeUpText:
	TX_FAR _WokeUpText
	db "@"

FrozenText:
	TX_FAR _FrozenText
	db "@"

FullyParalyzedText:
	TX_FAR _FullyParalyzedText
	db "@"

FlinchedText:
	TX_FAR _FlinchedText
	db "@"

MustRechargeText:
	TX_FAR _MustRechargeText
	db "@"

DisabledNoMoreText:
	TX_FAR _DisabledNoMoreText
	db "@"

IsConfusedText:
	TX_FAR _IsConfusedText
	db "@"

HurtItselfText:
	TX_FAR _HurtItselfText
	db "@"

ConfusedNoMoreText:
	TX_FAR _ConfusedNoMoreText
	db "@"

SavingEnergyText:
	TX_FAR _SavingEnergyText
	db "@"

UnleashedEnergyText:
	TX_FAR _UnleashedEnergyText
	db "@"

ThrashingAboutText:
	TX_FAR _ThrashingAboutText
	db "@"

AttackContinuesText:
	TX_FAR _AttackContinuesText
	db "@"

CantMoveText:
	TX_FAR _CantMoveText
	db "@"

INCBIN "baserom.gbc",$3da88,$3daa8 - $3da88

UnnamedText_3daa8: ; 0x3daa8
	TX_FAR _UnnamedText_3daa8
	db $50
; 0x3daa8 + 5 bytes

INCBIN "baserom.gbc",$3daad,$3db6c - $3daad

UnnamedText_3db6c: ; 0x3db6c
	TX_FAR _UnnamedText_3db6c
	db $50
; 0x3db6c + 5 bytes

UnnamedText_3db71: ; 0x3db71
	TX_FAR _UnnamedText_3db71
	db $50
; 0x3db71 + 5 bytes

UnnamedText_3db76: ; 0x3db76
	TX_FAR _UnnamedText_3db76
	db $50
; 0x3db76 + 5 bytes

UnnamedText_3db7b: ; 0x3db7b
	TX_FAR _UnnamedText_3db7b
	db $50
; 0x3db7b + 5 bytes

UnnamedText_3db80: ; 0x3db80
	TX_FAR _UnnamedText_3db80
	db $50
; 0x3db80 + 5 bytes

INCBIN "baserom.gbc",$3db85,$3dc42 - $3db85

UnnamedText_3dc42: ; 0x3dc42
	TX_FAR _UnnamedText_3dc42
	db $50
; 0x3dc42 + 5 bytes

UnnamedText_3dc47: ; 0x3dc47
	TX_FAR _UnnamedText_3dc47
	db $50
; 0x3dc47 + 5 bytes

UnnamedText_3dc4c: ; 0x3dc4c
	TX_FAR _UnnamedText_3dc4c
	db $50
; 0x3dc4c + 5 bytes

INCBIN "baserom.gbc",$3dc51,$3dc57 - $3dc51

UnnamedText_3dc57: ; 0x3dc57
	TX_FAR _UnnamedText_3dc57
	db $50
; 0x3dc57 + 5 bytes

INCBIN "baserom.gbc",$3dc5c,$3dc7e - $3dc5c

UnnamedText_3dc7e: ; 0x3dc7e
	TX_FAR _UnnamedText_3dc7e
	db $50
; 0x3dc7e + 5 bytes

UnnamedText_3dc83: ; 0x3dc83
	TX_FAR _UnnamedText_3dc83
	db $50
; 0x3dc83 + 5 bytes

INCBIN "baserom.gbc",$3dc88,$3ddb6 - $3dc88

UnnamedText_3ddb6: ; 0x3ddb6
	TX_FAR _UnnamedText_3ddb6
	db $50
; 0x3ddb6 + 5 bytes

UnnamedText_3ddbb: ; 0x3ddbb
	TX_FAR _UnnamedText_3ddbb
	db $50
; 0x3ddbb + 5 bytes

UnnamedText_3ddc0: ; 0x3ddc0
	TX_FAR _UnnamedText_3ddc0
	db $50
; 0x3ddc0 + 5 bytes

UnnamedText_3ddc5: ; 0x3ddc5
	TX_FAR _UnnamedText_3ddc5
	db $50
; 0x3ddc5 + 5 bytes

UnnamedText_3ddca: ; 0x3ddca
	TX_FAR _UnnamedText_3ddca
	db $50
; 0x3ddca + 5 bytes

INCBIN "baserom.gbc",$3ddcf,$3e04f - $3ddcf

; azure heights claims "the fastest pokémon (who are,not coincidentally,
; among the most popular) tend to CH about 20 to 25% of the time."
CriticalHitProbability: ; 0x3e04f
	ld a, [hld]                  ; read base power from RAM
	and a
	ret z                        ; do nothing if zero
	dec hl
	ld c, [hl]                   ; read move id
	ld a, [de]
	bit 2, a
	jr nz, .asm_3e061
	sla b
	jr nc, .asm_3e063
	ld b, $ff
	jr .asm_3e063
.asm_3e061
	srl b
.asm_3e063
	ld hl, HighCriticalMoves      ; table of high critical hit moves
.Loop
	ld a, [hli]                  ; read move from move table
	cp c                         ; does it match the move about to be used?
	jr z, .HighCritical          ; if so, the move about to be used is a high critical hit ratio move 
	inc a                        ; move on to the next move, FF terminates loop
	jr nz, .Loop                 ; check the next move in HighCriticalMoves
	srl b                        ; /2 for regular move (effective 1/512?)
	jr .SkipHighCritical         ; continue as a normal move
.HighCritical
	sla b                        ; *2 for high critical hit moves
	jr nc, .asm_3e077
	ld b, $ff                    ; set to FF (max) on overflow
.asm_3e077
	sla b                        ; *4 for high critical move (effective 1/64?)
	jr nc, .SkipHighCritical
	ld b, $ff
.SkipHighCritical
	call $6e9b                   ; probably generates a random value, in "a"
	rlc a
	rlc a
	rlc a
	cp b                         ; check a against $ff
	ret nc                       ; no critical hit if no borrow
	ld a, $1
	ld [$d05e], a                ; set critical hit flag
	ret
; 0x3e08e

; high critical hit moves
HighCriticalMoves: ; 0x3e08e
	db KARATE_CHOP
	db RAZOR_LEAF
	db CRABHAMMER
	db SLASH
	db $FF
; 0x3e093

; function to determine if Counter hits and if so, how much damage it does
HandleCounterMove: ; 6093
	ld a,[H_WHOSETURN] ; whose turn
	and a
; player's turn
	ld hl,W_ENEMYSELECTEDMOVE
	ld de,W_ENEMYMOVEPOWER
	ld a,[W_PLAYERSELECTEDMOVE]
	jr z,.next\@
; enemy's turn
	ld hl,W_PLAYERSELECTEDMOVE
	ld de,W_PLAYERMOVEPOWER
	ld a,[W_ENEMYSELECTEDMOVE]
.next\@
	cp a,COUNTER
	ret nz ; return if not using Counter
	ld a,$01
	ld [W_MOVEMISSED],a ; initialize the move missed variable to true (it is set to false below if the move hits)
	ld a,[hl]
	cp a,COUNTER
	ret z ; if the target also used Counter, miss
	ld a,[de]
	and a
	ret z ; if the move the target used has 0 power, miss
; check if the move the target used was Normal or Fighting type
	inc de
	ld a,[de]
	and a ; normal type
	jr z,.counterableType\@
	cp a,FIGHTING
	jr z,.counterableType\@
; if the move wasn't Normal or Fighting type, miss
	xor a
	ret
.counterableType\@
	ld hl,W_DAMAGE
	ld a,[hli]
	or [hl]
	ret z ; Counter misses if the target did no damage to the Counter user
; double the damage that the target did to the Counter user
	ld a,[hl]
	add a
	ldd [hl],a
	ld a,[hl]
	adc a
	ld [hl],a
	jr nc,.noCarry\@
; damage is capped at 0xFFFF
	ld a,$ff
	ld [hli],a
	ld [hl],a
.noCarry\@
	xor a
	ld [W_MOVEMISSED],a
	call MoveHitTest ; do the normal move hit test in addition to Counter's special rules
	xor a
	ret

ApplyDamageToEnemyPokemon: ; 60DF
	ld a,[W_PLAYERMOVEEFFECT]
	cp a,OHKO_EFFECT
	jr z,.applyDamage\@
	cp a,SUPER_FANG_EFFECT
	jr z,.superFangEffect\@
	cp a,SPECIAL_DAMAGE_EFFECT
	jr z,.specialDamage\@
	ld a,[W_PLAYERMOVEPOWER]
	and a
	jp z,.done\@
	jr .applyDamage\@
.superFangEffect\@
; set the damage to half the target's HP
	ld hl,W_ENEMYMONCURHP
	ld de,W_DAMAGE
	ld a,[hli]
	srl a
	ld [de],a
	inc de
	ld b,a
	ld a,[hl]
	rr a
	ld [de],a
	or b
	jr nz,.applyDamage\@
; make sure Super Fang's damage is always at least 1
	ld a,$01
	ld [de],a
	jr .applyDamage\@
.specialDamage\@
	ld hl,W_PLAYERMONLEVEL
	ld a,[hl]
	ld b,a
	ld a,[W_PLAYERMOVENUM]
	cp a,SEISMIC_TOSS
	jr z,.storeDamage\@
	cp a,NIGHT_SHADE
	jr z,.storeDamage\@
	ld b,SONICBOOM_DAMAGE
	cp a,SONICBOOM
	jr z,.storeDamage\@
	ld b,DRAGON_RAGE_DAMAGE
	cp a,DRAGON_RAGE
	jr z,.storeDamage\@
; Psywave
	ld a,[hl]
	ld b,a
	srl a
	add b
	ld b,a ; b = level * 1.5
; loop until a random number in the range [1, b) is found
.loop\@
	call $6e9b ; random number
	and a
	jr z,.loop\@
	cp b
	jr nc,.loop\@
	ld b,a
.storeDamage\@
	ld hl,W_DAMAGE
	xor a
	ld [hli],a
	ld a,b
	ld [hl],a
.applyDamage\@
	ld hl,W_DAMAGE
	ld a,[hli]
	ld b,a
	ld a,[hl]
	or b
	jr z,.done\@ ; we're done if damage is 0
	ld a,[W_ENEMYBATTSTATUS2]
	bit 4,a ; does the enemy have a substitute?
	jp nz,AttackSubstitute
; subtract the damage from the pokemon's current HP
; also, save the current HP at $CEEB
	ld a,[hld]
	ld b,a
	ld a,[W_ENEMYMONCURHP + 1]
	ld [$ceeb],a
	sub b
	ld [W_ENEMYMONCURHP + 1],a
	ld a,[hl]
	ld b,a
	ld a,[W_ENEMYMONCURHP]
	ld [$ceec],a
	sbc b
	ld [W_ENEMYMONCURHP],a
	jr nc,.animateHpBar\@
; if more damage was done than the current HP, zero the HP and set the damage
; equal to how much HP the pokemon had before the attack
	ld a,[$ceec]
	ld [hli],a
	ld a,[$ceeb]
	ld [hl],a
	xor a
	ld hl,W_ENEMYMONCURHP
	ld [hli],a
	ld [hl],a
.animateHpBar\@
	ld hl,W_ENEMYMONMAXHP
	ld a,[hli]
	ld [$ceea],a
	ld a,[hl]
	ld [$cee9],a
	ld hl,W_ENEMYMONCURHP
	ld a,[hli]
	ld [$ceee],a
	ld a,[hl]
	ld [$ceed],a
	ld hl,$c3ca
	xor a
	ld [$cf94],a
	ld a,$48
	call Predef ; animate the HP bar shortening
.done\@
	jp $4d5a ; redraw pokemon names and HP bars

ApplyDamageToPlayerPokemon: ; 61A0
	ld a,[W_ENEMYMOVEEFFECT]
	cp a,OHKO_EFFECT
	jr z,.applyDamage\@
	cp a,SUPER_FANG_EFFECT
	jr z,.superFangEffect\@
	cp a,SPECIAL_DAMAGE_EFFECT
	jr z,.specialDamage\@
	ld a,[W_ENEMYMOVEPOWER]
	and a
	jp z,.done\@
	jr .applyDamage\@
.superFangEffect\@
; set the damage to half the target's HP
	ld hl,W_PLAYERMONCURHP
	ld de,W_DAMAGE
	ld a,[hli]
	srl a
	ld [de],a
	inc de
	ld b,a
	ld a,[hl]
	rr a
	ld [de],a
	or b
	jr nz,.applyDamage\@
; make sure Super Fang's damage is always at least 1
	ld a,$01
	ld [de],a
	jr .applyDamage\@
.specialDamage\@
	ld hl,W_ENEMYMONLEVEL
	ld a,[hl]
	ld b,a
	ld a,[W_ENEMYMOVENUM]
	cp a,SEISMIC_TOSS
	jr z,.storeDamage\@
	cp a,NIGHT_SHADE
	jr z,.storeDamage\@
	ld b,SONICBOOM_DAMAGE
	cp a,SONICBOOM
	jr z,.storeDamage\@
	ld b,DRAGON_RAGE_DAMAGE
	cp a,DRAGON_RAGE
	jr z,.storeDamage\@
; Psywave
	ld a,[hl]
	ld b,a
	srl a
	add b
	ld b,a ; b = attacker's level * 1.5
; loop until a random number in the range [0, b) is found
; this differs from the range when the player attacks, which is [1, b)
; it's possible for the enemy to do 0 damage with Psywave, but the player always does at least 1 damage
.loop\@
	call $6e9b ; random number
	cp b
	jr nc,.loop\@
	ld b,a
.storeDamage\@
	ld hl,W_DAMAGE
	xor a
	ld [hli],a
	ld a,b
	ld [hl],a
.applyDamage\@
	ld hl,W_DAMAGE
	ld a,[hli]
	ld b,a
	ld a,[hl]
	or b
	jr z,.done\@ ; we're done if damage is 0
	ld a,[W_PLAYERBATTSTATUS2]
	bit 4,a ; does the player have a substitute?
	jp nz,AttackSubstitute
; subtract the damage from the pokemon's current HP
; also, save the current HP at $CEEB and the new HP at $CEED
	ld a,[hld]
	ld b,a
	ld a,[W_PLAYERMONCURHP + 1]
	ld [$ceeb],a
	sub b
	ld [W_PLAYERMONCURHP + 1],a
	ld [$ceed],a
	ld b,[hl]
	ld a,[W_PLAYERMONCURHP]
	ld [$ceec],a
	sbc b
	ld [W_PLAYERMONCURHP],a
	ld [$ceee],a
	jr nc,.animateHpBar\@
; if more damage was done than the current HP, zero the HP and set the damage
; equal to how much HP the pokemon had before the attack
	ld a,[$ceec]
	ld [hli],a
	ld a,[$ceeb]
	ld [hl],a
	xor a
	ld hl,W_PLAYERMONCURHP
	ld [hli],a
	ld [hl],a
	ld hl,$ceed
	ld [hli],a
	ld [hl],a
.animateHpBar\@
	ld hl,W_PLAYERMONMAXHP
	ld a,[hli]
	ld [$ceea],a
	ld a,[hl]
	ld [$cee9],a
	ld hl,$c45e
	ld a,$01
	ld [$cf94],a
	ld a,$48
	call Predef ; animate the HP bar shortening
.done\@
	jp $4d5a ; redraw pokemon names and HP bars

AttackSubstitute: ; 625E
	ld hl,SubstituteTookDamageText
	call PrintText
; values for player turn
	ld de,W_ENEMYSUBSITUTEHP
	ld bc,W_ENEMYBATTSTATUS2
	ld a,[H_WHOSETURN]
	and a
	jr z,.applyDamageToSubstitute\@
; values for enemy turn
	ld de,W_PLAYERSUBSITUTEHP
	ld bc,W_PLAYERBATTSTATUS2
.applyDamageToSubstitute\@
	ld hl,W_DAMAGE
	ld a,[hli]
	and a
	jr nz,.substituteBroke\@ ; damage > 0xFF always breaks substitutes
; subtract damage from HP of substitute
	ld a,[de]
	sub [hl]
	ld [de],a
	ret nc
.substituteBroke\@
	ld h,b
	ld l,c
	res 4,[hl] ; unset the substitute bit
	ld hl,SubstituteBrokeText
	call PrintText
; flip whose turn it is for the next function call
	ld a,[H_WHOSETURN]
	xor a,$01
	ld [H_WHOSETURN],a
	ld hl,$5747
	ld b,$1e ; animate the substitute breaking
	call Bankswitch ; substitute
; flip the turn back to the way it was
	ld a,[H_WHOSETURN]
	xor a,$01
	ld [H_WHOSETURN],a
	ld hl,W_PLAYERMOVEEFFECT ; value for player's turn
	and a
	jr z,.nullifyEffect\@
	ld hl,W_ENEMYMOVEEFFECT ; value for enemy's turn
.nullifyEffect\@
	xor a
	ld [hl],a ; zero the effect of the attacker's move
	jp $4d5a ; redraw pokemon names and HP bars

SubstituteTookDamageText: ; 0x3e2ac
	TX_FAR _SubstituteTookDamageText
	db $50
; 0x3e2ac + 5 bytes

SubstituteBrokeText: ; 0x3e2b1
	TX_FAR _SubstituteBrokeText
	db $50
; 0x3e2b1 + 5 bytes

; this function raises the attack modifier of a pokemon using Rage when that pokemon is attacked
HandleBuildingRage: ; 62B6
; values for the player turn
	ld hl,W_ENEMYBATTSTATUS2
	ld de,W_ENEMYMONATTACKMOD
	ld bc,W_ENEMYMOVENUM
	ld a,[H_WHOSETURN]
	and a
	jr z,.next\@
; values for the enemy turn
	ld hl,W_PLAYERBATTSTATUS2
	ld de,W_PLAYERMONATTACKMOD
	ld bc,W_PLAYERMOVENUM
.next\@
	bit 6,[hl] ; is the pokemon being attacked under the effect of Rage?
	ret z ; return if not
	ld a,[de]
	cp a,$0d ; maximum stat modifier value
	ret z ; return if attack modifier is already maxed
	ld a,[H_WHOSETURN]
	xor a,$01 ; flip turn for the stat modifier raising function
	ld [H_WHOSETURN],a
; change the target pokemon's move to $00 and the effect to the one
; that causes the attack modifier to go up one stage
	ld h,b
	ld l,c
	ld [hl],$00 ; null move number
	inc hl
	ld [hl],ATTACK_UP1_EFFECT
	push hl
	ld hl,BuildingRageText
	call PrintText
	call $7428 ; stat modifier raising function
	pop hl
	xor a
	ldd [hl],a ; null move effect
	ld a,RAGE
	ld [hl],a ; restore the target pokemon's move number to Rage
	ld a,[H_WHOSETURN]
	xor a,$01 ; flip turn back to the way it was
	ld [H_WHOSETURN],a
	ret

BuildingRageText: ; 0x3e2f8
	TX_FAR _BuildingRageText
	db $50
; 0x3e2f8 + 5 bytes

; copy last move for Mirror Move
; sets zero flag on failure and unsets zero flag on success
MirrorMoveCopyMove: ; 62FD
	ld a,[H_WHOSETURN]
	and a
; values for player turn
	ld a,[$ccf2]
	ld hl,W_PLAYERSELECTEDMOVE
	ld de,W_PLAYERMOVENUM
	jr z,.next\@
; values for enemy turn
	ld a,[$ccf1]
	ld de,W_ENEMYMOVENUM
	ld hl,W_ENEMYSELECTEDMOVE
.next\@
	ld [hl],a
	cp a,MIRROR_MOVE ; did the target pokemon also use Mirror Move?
	jr z,.mirrorMoveFailed\@
	and a ; null move?
	jr nz,ReloadMoveData
.mirrorMoveFailed\@
; Mirror Move fails on itself and null moves
	ld hl,MirrorMoveFailedText
	call PrintText
	xor a
	ret

MirrorMoveFailedText: ; 0x3e324
	TX_FAR _MirrorMoveFailedText
	db $50
; 0x3e324 + 5 bytes

; function used to reload move data for moves like Mirror Move and Metronome
ReloadMoveData: ; 6329
	ld [$d11e],a
	dec a
	ld hl,Moves
	ld bc,$0006
	call AddNTimes
	ld a,BANK(Moves)
	call FarCopyData ; copy the move's stats
	call IncrementMovePP
; the follow two function calls are used to reload the move name
	call $3058
	call $3826
	ld a,$01
	and a
	ret

; function that picks a random move for metronome
MetronomePickMove: ; 6348
	xor a
	ld [$cc5b],a
	ld a,METRONOME
	call PlayMoveAnimation ; play Metronome's animation
; values for player turn
	ld de,W_PLAYERMOVENUM
	ld hl,W_PLAYERSELECTEDMOVE
	ld a,[H_WHOSETURN]
	and a
	jr z,.pickMoveLoop\@
; values for enemy turn
	ld de,W_ENEMYMOVENUM
	ld hl,W_ENEMYSELECTEDMOVE
; loop to pick a random number in the range [1, $a5) to be the move used by Metronome
.pickMoveLoop\@
	call $6e9b ; random number
	and a
	jr z,.pickMoveLoop\@
	cp a,$a5 ; max normal move number + 1 (this is Struggle's move number)
	jr nc,.pickMoveLoop\@
	cp a,METRONOME
	jr z,.pickMoveLoop\@
	ld [hl],a
	jr ReloadMoveData

; this function increments the current move's PP
; it's used to prevent moves that run another move within the same turn
; (like Mirror Move and Metronome) from losing 2 PP
IncrementMovePP: ; 6373
	ld a,[H_WHOSETURN]
	and a
; values for player turn
	ld hl,W_PLAYERMONPP
	ld de,W_PARTYMON1_MOVE1PP
	ld a,[W_PLAYERMOVELISTINDEX]
	jr z,.next\@
; values for enemy turn
	ld hl,W_ENEMYMONPP
	ld de,$d8c1 ; enemy party pokemon 1 PP
	ld a,[W_ENEMYMOVELISTINDEX]
.next\@
	ld b,$00
	ld c,a
	add hl,bc
	inc [hl] ; increment PP in the currently battling pokemon memory location
	ld h,d
	ld l,e
	add hl,bc
	ld a,[H_WHOSETURN]
	and a
	ld a,[W_PLAYERMONNUMBER] ; value for player turn
	jr z,.next2\@
	ld a,[W_ENEMYMONNUMBER] ; value for enemy turn
.next2\@
	ld bc,$002c
	call AddNTimes
	inc [hl] ; increment PP in the party memory location
	ret

; function to adjust the base damage of an attack to account for type effectiveness
AdjustDamageForMoveType: ; 63A5
; values for player turn
	ld hl,W_PLAYERMONTYPES
	ld a,[hli]
	ld b,a    ; b = type 1 of attacker
	ld c,[hl] ; c = type 2 of attacker
	ld hl,W_ENEMYMONTYPES
	ld a,[hli]
	ld d,a    ; d = type 1 of defender
	ld e,[hl] ; e = type 2 of defender
	ld a,[W_PLAYERMOVETYPE]
	ld [$d11e],a
	ld a,[H_WHOSETURN]
	and a
	jr z,.next\@
; values for enemy turn
	ld hl,W_ENEMYMONTYPES
	ld a,[hli]
	ld b,a    ; b = type 1 of attacker
	ld c,[hl] ; c = type 2 of attacker
	ld hl,W_PLAYERMONTYPES
	ld a,[hli]
	ld d,a    ; d = type 1 of defender
	ld e,[hl] ; e = type 2 of defender
	ld a,[W_ENEMYMOVETYPE]
	ld [$d11e],a
.next\@
	ld a,[$d11e] ; move type
	cp b ; does the move type match type 1 of the attacker?
	jr z,.sameTypeAttackBonus\@
	cp c ; does the move type match type 2 of the attacker?
	jr z,.sameTypeAttackBonus\@
	jr .skipSameTypeAttackBonus\@
.sameTypeAttackBonus\@
; if the move type matches one of the attacker's types
	ld hl,W_DAMAGE + 1
	ld a,[hld]
	ld h,[hl]
	ld l,a    ; hl = damage
	ld b,h
	ld c,l    ; bc = damage
	srl b
	rr c      ; bc = floor(0.5 * damage)
	add hl,bc ; hl = floor(1.5 * damage)
; store damage
	ld a,h
	ld [W_DAMAGE],a
	ld a,l
	ld [W_DAMAGE + 1],a
	ld hl,$d05b
	set 7,[hl]
.skipSameTypeAttackBonus\@
	ld a,[$d11e]
	ld b,a ; b = move type
	ld hl,TypeEffects
.loop\@
	ld a,[hli] ; a = "attacking type" of the current type pair
	cp a,$ff
	jr z,.done\@
	cp b ; does move type match "attacking type"?
	jr nz,.nextTypePair\@
	ld a,[hl] ; a = "defending type" of the current type pair
	cp d ; does type 1 of defender match "defending type"?
	jr z,.matchingPairFound\@
	cp e ; does type 2 of defender match "defending type"?
	jr z,.matchingPairFound\@
	jr .nextTypePair\@
.matchingPairFound\@
; if the move type matches the "attacking type" and one of the defender's types matches the "defending type"
	push hl
	push bc
	inc hl
	ld a,[$d05b]
	and a,$80
	ld b,a
	ld a,[hl] ; a = damage multiplier
	ld [H_MULTIPLIER],a
	add b
	ld [$d05b],a
	xor a
	ld [H_MULTIPLICAND],a
	ld hl,W_DAMAGE
	ld a,[hli]
	ld [H_MULTIPLICAND + 1],a
	ld a,[hld]
	ld [H_MULTIPLICAND + 2],a
	call Multiply
	ld a,10
	ld [H_DIVISOR],a
	ld b,$04
	call Divide
	ld a,[H_QUOTIENT + 2]
	ld [hli],a
	ld b,a
	ld a,[H_QUOTIENT + 3]
	ld [hl],a
	or b ; is damage 0?
	jr nz,.skipTypeImmunity\@
.typeImmunity\@
; if damage is 0, make the move miss
	inc a
	ld [W_MOVEMISSED],a
.skipTypeImmunity\@
	pop bc
	pop hl
.nextTypePair\@
	inc hl
	inc hl
	jp .loop\@
.done\@
	ret

; function to tell how effective the type of an enemy attack is on the player's current pokemon
; this doesn't take into account the effects that dual types can have
; (e.g. 4x weakness / resistance, weaknesses and resistances canceling)
; the result is stored in [$D11E]
; ($05 is not very effective, $10 is neutral, $14 is super effective)
; as far is can tell, this is only used once in some AI code to help decide which move to use
AIGetTypeEffectiveness: ; 6449
	ld a,[W_ENEMYMOVETYPE]
	ld d,a                 ; d = type of enemy move
	ld hl,W_PLAYERMONTYPES
	ld b,[hl]              ; b = type 1 of player's pokemon
	inc hl
	ld c,[hl]              ; c = type 2 of player's pokemon
	ld a,$10
	ld [$d11e],a           ; initialize [$D11E] to neutral effectiveness
	ld hl,TypeEffects
.loop\@
	ld a,[hli]
	cp a,$ff
	ret z
	cp d                   ; match the type of the move
	jr nz,.nextTypePair1\@
	ld a,[hli]
	cp b                   ; match with type 1 of pokemon
	jr z,.done\@
	cp c                   ; or match with type 2 of pokemon
	jr z,.done\@
	jr .nextTypePair2\@
.nextTypePair1\@
	inc hl
.nextTypePair2\@
	inc hl
	jr .loop\@
.done\@
	ld a,[hl]
	ld [$d11e],a           ; store damage multiplier
	ret

TypeEffects: ; 6474
; format: attacking type, defending type, damage multiplier
; the multiplier is a (decimal) fixed-point number:
;     20 is ×2.0
;     05 is ×0.5
;     00 is ×0
	db WATER,FIRE,20
	db FIRE,GRASS,20
	db FIRE,ICE,20
	db GRASS,WATER,20
	db ELECTRIC,WATER,20
	db WATER,ROCK,20
	db GROUND,FLYING,00
	db WATER,WATER,05
	db FIRE,FIRE,05
	db ELECTRIC,ELECTRIC,05
	db ICE,ICE,05
	db GRASS,GRASS,05
	db PSYCHIC,PSYCHIC,05
	db FIRE,WATER,05
	db GRASS,FIRE,05
	db WATER,GRASS,05
	db ELECTRIC,GRASS,05
	db NORMAL,ROCK,05
	db NORMAL,GHOST,00
	db GHOST,GHOST,20
	db FIRE,BUG,20
	db FIRE,ROCK,05
	db WATER,GROUND,20
	db ELECTRIC,GROUND,00
	db ELECTRIC,FLYING,20
	db GRASS,GROUND,20
	db GRASS,BUG,05
	db GRASS,POISON,05
	db GRASS,ROCK,20
	db GRASS,FLYING,05
	db ICE,WATER,05
	db ICE,GRASS,20
	db ICE,GROUND,20
	db ICE,FLYING,20
	db FIGHTING,NORMAL,20
	db FIGHTING,POISON,05
	db FIGHTING,FLYING,05
	db FIGHTING,PSYCHIC,05
	db FIGHTING,BUG,05
	db FIGHTING,ROCK,20
	db FIGHTING,ICE,20
	db FIGHTING,GHOST,00
	db POISON,GRASS,20
	db POISON,POISON,05
	db POISON,GROUND,05
	db POISON,BUG,20
	db POISON,ROCK,05
	db POISON,GHOST,05
	db GROUND,FIRE,20
	db GROUND,ELECTRIC,20
	db GROUND,GRASS,05
	db GROUND,BUG,05
	db GROUND,ROCK,20
	db GROUND,POISON,20
	db FLYING,ELECTRIC,05
	db FLYING,FIGHTING,20
	db FLYING,BUG,20
	db FLYING,GRASS,20
	db FLYING,ROCK,05
	db PSYCHIC,FIGHTING,20
	db PSYCHIC,POISON,20
	db BUG,FIRE,05
	db BUG,GRASS,20
	db BUG,FIGHTING,05
	db BUG,FLYING,05
	db BUG,PSYCHIC,20
	db BUG,GHOST,05
	db BUG,POISON,20
	db ROCK,FIRE,20
	db ROCK,FIGHTING,05
	db ROCK,GROUND,05
	db ROCK,FLYING,20
	db ROCK,BUG,20
	db ROCK,ICE,20
	db GHOST,NORMAL,00
	db GHOST,PSYCHIC,00
	db FIRE,DRAGON,05
	db WATER,DRAGON,05
	db ELECTRIC,DRAGON,05
	db GRASS,DRAGON,05
	db ICE,DRAGON,20
	db DRAGON,DRAGON,20
	db $FF

; some tests that need to pass for a move to hit
MoveHitTest: ; 656B
; player's turn
	ld hl,W_ENEMYBATTSTATUS1
	ld de,W_PLAYERMOVEEFFECT
	ld bc,W_ENEMYMONSTATUS
	ld a,[H_WHOSETURN]
	and a
	jr z,.dreamEaterCheck\@
; enemy's turn
	ld hl,W_PLAYERBATTSTATUS1
	ld de,W_ENEMYMOVEEFFECT
	ld bc,W_PLAYERMONSTATUS
.dreamEaterCheck\@
	ld a,[de]
	cp a,DREAM_EATER_EFFECT
	jr nz,.swiftCheck\@
	ld a,[bc]
	and a,$07 ; is the target pokemon sleeping?
	jp z,.moveMissed\@
.swiftCheck\@
	ld a,[de]
	cp a,SWIFT_EFFECT
	ret z ; Swift never misses (interestingly, Azure Heights lists this is a myth, but it appears to be true)
	call $7b79 ; substitute check (note that this overwrites a)
	jr z,.checkForDigOrFlyStatus\@
; this code is buggy. it's supposed to prevent HP draining moves from working on substitutes.
; since $7b79 overwrites a with either $00 or $01, it never works.
	cp a,DRAIN_HP_EFFECT ; $03
	jp z,.moveMissed\@
	cp a,DREAM_EATER_EFFECT ; $08
	jp z,.moveMissed\@
.checkForDigOrFlyStatus\@
	bit 6,[hl]
	jp nz,.moveMissed\@
	ld a,[H_WHOSETURN]
	and a
	jr nz,.enemyTurn\@
.playerTurn\@
; this checks if the move effect is disallowed by mist
	ld a,[W_PLAYERMOVEEFFECT]
	cp a,$12
	jr c,.skipEnemyMistCheck\@
	cp a,$1a
	jr c,.enemyMistCheck\@
	cp a,$3a
	jr c,.skipEnemyMistCheck\@
	cp a,$42
	jr c,.enemyMistCheck\@
	jr .skipEnemyMistCheck\@
.enemyMistCheck\@
; if move effect is from $12 to $19 inclusive or $3a to $41 inclusive
; i.e. the following moves
; GROWL, TAIL WHIP, LEER, STRING SHOT, SAND-ATTACK, SMOKESCREEN, KINESIS,
; FLASH, CONVERSION, HAZE*, SCREECH, LIGHT SCREEN*, REFLECT*
; the moves that are marked with an asterisk are not affected since this
; function is not called when those moves are used
; XXX are there are any others like those three?
	ld a,[W_ENEMYBATTSTATUS2]
	bit 1,a
	jp nz,.moveMissed\@
.skipEnemyMistCheck\@
	ld a,[W_PLAYERBATTSTATUS2]
	bit 0,a ; is the player using X Accuracy?
	ret nz ; if so, always hit regardless of accuracy/evasion
	jr .calcHitChance\@
.enemyTurn\@
	ld a,[W_ENEMYMOVEEFFECT]
	cp a,$12
	jr c,.skipPlayerMistCheck\@
	cp a,$1a
	jr c,.playerMistCheck\@
	cp a,$3a
	jr c,.skipPlayerMistCheck\@
	cp a,$42
	jr c,.playerMistCheck\@
	jr .skipPlayerMistCheck\@
.playerMistCheck\@
; similar to enemy mist check
	ld a,[W_PLAYERBATTSTATUS2]
	bit 1,a
	jp nz,.moveMissed\@
.skipPlayerMistCheck\@
	ld a,[W_ENEMYBATTSTATUS2]
	bit 0,a ; is the enemy using X Accuracy?
	ret nz ; if so, always hit regardless of accuracy/evasion
.calcHitChance\@
	call CalcHitChance ; scale the move accuracy according to attacker's accuracy and target's evasion
	ld a,[W_PLAYERMOVEACCURACY]
	ld b,a
	ld a,[H_WHOSETURN]
	and a
	jr z,.doAccuracyCheck\@
	ld a,[W_ENEMYMOVEACCURACY]
	ld b,a
.doAccuracyCheck\@
; if the random number generated is greater than or equal to the scaled accuracy, the move misses
; note that this means that even the highest accuracy is still just a 255/256 chance, not 100%
	call $6e9b ; random number
	cp b
	jr nc,.moveMissed\@
	ret
.moveMissed\@
	xor a
	ld hl,W_DAMAGE ; zero the damage
	ld [hli],a
	ld [hl],a
	inc a
	ld [W_MOVEMISSED],a
	ld a,[H_WHOSETURN]
	and a
	jr z,.playerTurn2\@
.enemyTurn2\@
	ld hl,W_ENEMYBATTSTATUS1
	res 5,[hl] ; end multi-turn attack e.g. wrap
	ret
.playerTurn2\@
	ld hl,W_PLAYERBATTSTATUS1
	res 5,[hl] ; end multi-turn attack e.g. wrap
	ret

; values for player turn
CalcHitChance: ; 6624
	ld hl,W_PLAYERMOVEACCURACY
	ld a,[H_WHOSETURN]
	and a
	ld a,[W_PLAYERMONACCURACYMOD]
	ld b,a
	ld a,[W_ENEMYMONEVASIONMOD]
	ld c,a
	jr z,.next\@
; values for enemy turn
	ld hl,W_ENEMYMOVEACCURACY
	ld a,[W_ENEMYMONACCURACYMOD]
	ld b,a
	ld a,[W_PLAYERMONEVASIONMOD]
	ld c,a
.next\@
	ld a,$0e
	sub c
	ld c,a ; c = 14 - EVASIONMOD (this "reflects" the value over 7, so that an increase in the target's evasion decreases the hit chance instead of increasing the hit chance)
; zero the high bytes of the multiplicand
	xor a
	ld [H_MULTIPLICAND],a
	ld [H_MULTIPLICAND + 1],a
	ld a,[hl]
	ld [H_MULTIPLICAND + 2],a ; set multiplicand to move accuracy
	push hl
	ld d,$02 ; loop has two iterations
; loop to do the calculations, the first iteration multiplies by the accuracy ratio and the second iteration multiplies by the evasion ratio
.loop\@
	push bc
	ld hl,$76cb ; stat modifier ratios
	dec b
	sla b
	ld c,b
	ld b,$00
	add hl,bc ; hl = address of stat modifier ratio
	pop bc
	ld a,[hli]
	ld [H_MULTIPLIER],a ; set multiplier to the numerator of the ratio
	call Multiply
	ld a,[hl]
	ld [H_DIVISOR],a ; set divisor to the the denominator of the ratio (the dividend is the product of the previous multiplication)
	ld b,$04 ; number of significant bytes in the dividend
	call Divide
	ld a,[H_QUOTIENT + 3]
	ld b,a
	ld a,[H_QUOTIENT + 2]
	or b
	jp nz,.nextCalculation\@
; make sure the result is always at least one
	ld [H_QUOTIENT + 2],a
	ld a,$01
	ld [H_QUOTIENT + 3],a
.nextCalculation\@
	ld b,c
	dec d
	jr nz,.loop\@
	ld a,[H_QUOTIENT + 2]
	and a ; is the calculated hit chance over 0xFF?
	ld a,[H_QUOTIENT + 3]
	jr z,.storeAccuracy\@
; if calculated hit chance over 0xFF
	ld a,$ff ; set the hit chance to 0xFF
.storeAccuracy\@
	pop hl
	ld [hl],a ; store the hit chance in the move accuracy variable
	ret

INCBIN "baserom.gbc",$3e687,$3e887 - $3e687

UnnamedText_3e887: ; 0x3e887
	TX_FAR _UnnamedText_3e887
	db $50
; 0x3e887 + 5 bytes

INCBIN "baserom.gbc",$3e88c,$67b

PlayMoveAnimation: ; 6F07
	ld [$D07C],a
	call Delay3
	ld a,8
	jp Predef

INCBIN "baserom.gbc",$3ef12,$3f245 - $3ef12

UnnamedText_3f245: ; 0x3f245
	TX_FAR _UnnamedText_3f245
	db $50
; 0x3f245 + 5 bytes

UnnamedText_3f24a: ; 0x3f24a
	TX_FAR _UnnamedText_3f24a
	db $50
; 0x3f24a + 5 bytes

INCBIN "baserom.gbc",$3f24f,$3f2df - $3f24f

UnnamedText_3f2df: ; 0x3f2df
	TX_FAR _UnnamedText_3f2df
	db $50
; 0x3f2df + 5 bytes

UnnamedText_3f2e4: ; 0x3f2e4
	TX_FAR _UnnamedText_3f2e4
	db $50
; 0x3f2e4 + 5 bytes

INCBIN "baserom.gbc",$3f2e9,$3f3d8 - $3f2e9

UnnamedText_3f3d8: ; 0x3f3d8
	TX_FAR _UnnamedText_3f3d8
	db $50
; 0x3f3d8 + 5 bytes

UnnamedText_3f3dd: ; 0x3f3dd
	TX_FAR _UnnamedText_3f3dd
	db $50
; 0x3f3dd + 5 bytes

INCBIN "baserom.gbc",$3f3e2,$3f423 - $3f3e2

UnnamedText_3f423: ; 0x3f423
	TX_FAR _UnnamedText_3f423
	db $50
; 0x3f423 + 5 bytes

INCBIN "baserom.gbc",$3f428,$3f547 - $3f428

UnnamedText_3f547: ; 0x3f547
	TX_FAR _UnnamedText_3f547
	db $50
; 0x3f547 + 5 bytes

INCBIN "baserom.gbc",$3f54c,$3f683 - $3f54c

UnnamedText_3f683: ; 0x3f683
	TX_FAR _UnnamedText_3f683
	db $50
; 0x3f683 + 5 bytes

INCBIN "baserom.gbc",$3f688,$3f802 - $3f688

UnnamedText_3f802: ; 0x3f802
	TX_FAR _UnnamedText_3f802
	db $50
; 0x3f802 + 5 bytes

UnnamedText_3f807: ; 0x3f807
	TX_FAR _UnnamedText_3f807
	db $50
; 0x3f807 + 5 bytes

UnnamedText_3f80c: ; 0x3f80c
	TX_FAR _UnnamedText_3f80c
	db $50
; 0x3f80c + 5 bytes

INCBIN "baserom.gbc",$3f811,$3f8f9 - $3f811

UnnamedText_3f8f9: ; 0x3f8f9
	TX_FAR _UnnamedText_3f8f9
	db $50
; 0x3f8f9 + 5 bytes

UnnamedText_3f8fe: ; 0x3f8fe
	TX_FAR _UnnamedText_3f8fe
	db $50
; 0x3f8fe + 5 bytes

UnnamedText_3f903: ; 0x3f903
	TX_FAR _UnnamedText_3f903
	db $50
; 0x3f903 + 5 bytes

UnnamedText_3f908: ; 0x3f908
	TX_FAR _UnnamedText_3f908
	db $50
; 0x3f908 + 5 bytes

UnnamedText_3f90d: ; 0x3f90d
	TX_FAR _UnnamedText_3f90d
	db $50
; 0x3f90d + 5 bytes

UnnamedText_3f912: ; 0x3f912
	TX_FAR _UnnamedText_3f912
	db $50
; 0x3f912 + 5 bytes

INCBIN "baserom.gbc",$3f917,$3f9a1 - $3f917

UnnamedText_3f9a1: ; 0x3f9a1
	TX_FAR _UnnamedText_3f9a1
	db $50
; 0x3f9a1 + 5 bytes

INCBIN "baserom.gbc",$3f9a6,$3fa77 - $3f9a6

UnnamedText_3fa77: ; 0x3fa77
	TX_FAR _UnnamedText_3fa77
	db $50
; 0x3fa77 + 5 bytes

INCBIN "baserom.gbc",$3fa7c,$3fb09 - $3fa7c

UnnamedText_3fb09: ; 0x3fb09
	TX_FAR _UnnamedText_3fb09
	db $50
; 0x3fb09 + 5 bytes

INCBIN "baserom.gbc",$3fb0e,$3fb3e - $3fb0e

UnnamedText_3fb3e: ; 0x3fb3e
	TX_FAR _UnnamedText_3fb3e
	db $50
; 0x3fb3e + 5 bytes

INCBIN "baserom.gbc",$3fb43,$3fb49 - $3fb43

UnnamedText_3fb49: ; 0x3fb49
	TX_FAR _UnnamedText_3fb49
	db $50
; 0x3fb49 + 5 bytes

INCBIN "baserom.gbc",$3fb4e,$3fb59 - $3fb4e

UnnamedText_3fb59: ; 0x3fb59
	TX_FAR _UnnamedText_3fb59
	db $50
; 0x3fb59 + 5 bytes

INCBIN "baserom.gbc",$3fb5e,$3fb64 - $3fb5e

UnnamedText_3fb64: ; 0x3fb64
	TX_FAR _UnnamedText_3fb64
	db $50
; 0x3fb64 + 5 bytes

UnnamedText_3fb69: ; 0x3fb69
	TX_FAR _UnnamedText_3fb69
	db $50
; 0x3fb69 + 5 bytes

INCBIN "baserom.gbc",$3fb6e,$3fb74 - $3fb6e

UnnamedText_3fb74: ; 0x3fb74
	TX_FAR _UnnamedText_3fb74
	db $50
; 0x3fb74 + 5 bytes

INCBIN "baserom.gbc",$3fb79,$487

SECTION "bank10",DATA,BANK[$10]

INCBIN "baserom.gbc",$40000,$47E

PokedexEntryPointers: ; 447E
	dw RhydonDexEntry
	dw KangaskhanDexEntry
	dw NidoranMDexEntry
	dw ClefairyDexEntry
	dw SpearowDexEntry
	dw VoltorbDexEntry
	dw NidokingDexEntry
	dw SlowbroDexEntry
	dw IvysaurDexEntry
	dw ExeggutorDexEntry
	dw LickitungDexEntry
	dw ExeggcuteDexEntry
	dw GrimerDexEntry
	dw GengarDexEntry
	dw NidoranFDexEntry
	dw NidoqueenDexEntry
	dw CuboneDexEntry
	dw RhyhornDexEntry
	dw LaprasDexEntry
	dw ArcanineDexEntry
	dw MewDexEntry
	dw GyaradosDexEntry
	dw ShellderDexEntry
	dw TentacoolDexEntry
	dw GastlyDexEntry
	dw ScytherDexEntry
	dw StaryuDexEntry
	dw BlastoiseDexEntry
	dw PinsirDexEntry
	dw TangelaDexEntry
	dw MissingNoDexEntry
	dw MissingNoDexEntry
	dw GrowlitheDexEntry
	dw OnixDexEntry
	dw FearowDexEntry
	dw PidgeyDexEntry
	dw SlowpokeDexEntry
	dw KadabraDexEntry
	dw GravelerDexEntry
	dw ChanseyDexEntry
	dw MachokeDexEntry
	dw MrMimeDexEntry
	dw HitmonleeDexEntry
	dw HitmonchanDexEntry
	dw ArbokDexEntry
	dw ParasectDexEntry
	dw PsyduckDexEntry
	dw DrowzeeDexEntry
	dw GolemDexEntry
	dw MissingNoDexEntry
	dw MagmarDexEntry
	dw MissingNoDexEntry
	dw ElectabuzzDexEntry
	dw MagnetonDexEntry
	dw KoffingDexEntry
	dw MissingNoDexEntry
	dw MankeyDexEntry
	dw SeelDexEntry
	dw DiglettDexEntry
	dw TaurosDexEntry
	dw MissingNoDexEntry
	dw MissingNoDexEntry
	dw MissingNoDexEntry
	dw FarfetchdDexEntry
	dw VenonatDexEntry
	dw DragoniteDexEntry
	dw MissingNoDexEntry
	dw MissingNoDexEntry
	dw MissingNoDexEntry
	dw DoduoDexEntry
	dw PoliwagDexEntry
	dw JynxDexEntry
	dw MoltresDexEntry
	dw ArticunoDexEntry
	dw ZapdosDexEntry
	dw DittoDexEntry
	dw MeowthDexEntry
	dw KrabbyDexEntry
	dw MissingNoDexEntry
	dw MissingNoDexEntry
	dw MissingNoDexEntry
	dw VulpixDexEntry
	dw NinetalesDexEntry
	dw PikachuDexEntry
	dw RaichuDexEntry
	dw MissingNoDexEntry
	dw MissingNoDexEntry
	dw DratiniDexEntry
	dw DragonairDexEntry
	dw KabutoDexEntry
	dw KabutopsDexEntry
	dw HorseaDexEntry
	dw SeadraDexEntry
	dw MissingNoDexEntry
	dw MissingNoDexEntry
	dw SandshrewDexEntry
	dw SandslashDexEntry
	dw OmanyteDexEntry
	dw OmastarDexEntry
	dw JigglypuffDexEntry
	dw WigglytuffDexEntry
	dw EeveeDexEntry
	dw FlareonDexEntry
	dw JolteonDexEntry
	dw VaporeonDexEntry
	dw MachopDexEntry
	dw ZubatDexEntry
	dw EkansDexEntry
	dw ParasDexEntry
	dw PoliwhirlDexEntry
	dw PoliwrathDexEntry
	dw WeedleDexEntry
	dw KakunaDexEntry
	dw BeedrillDexEntry
	dw MissingNoDexEntry
	dw DodrioDexEntry
	dw PrimeapeDexEntry
	dw DugtrioDexEntry
	dw VenomothDexEntry
	dw DewgongDexEntry
	dw MissingNoDexEntry
	dw MissingNoDexEntry
	dw CaterpieDexEntry
	dw MetapodDexEntry
	dw ButterfreeDexEntry
	dw MachampDexEntry
	dw MissingNoDexEntry
	dw GolduckDexEntry
	dw HypnoDexEntry
	dw GolbatDexEntry
	dw MewtwoDexEntry
	dw SnorlaxDexEntry
	dw MagikarpDexEntry
	dw MissingNoDexEntry
	dw MissingNoDexEntry
	dw MukDexEntry
	dw MissingNoDexEntry
	dw KinglerDexEntry
	dw CloysterDexEntry
	dw MissingNoDexEntry
	dw ElectrodeDexEntry
	dw ClefableDexEntry
	dw WeezingDexEntry
	dw PersianDexEntry
	dw MarowakDexEntry
	dw MissingNoDexEntry
	dw HaunterDexEntry
	dw AbraDexEntry
	dw AlakazamDexEntry
	dw PidgeottoDexEntry
	dw PidgeotDexEntry
	dw StarmieDexEntry
	dw BulbasaurDexEntry
	dw VenusaurDexEntry
	dw TentacruelDexEntry
	dw MissingNoDexEntry
	dw GoldeenDexEntry
	dw SeakingDexEntry
	dw MissingNoDexEntry
	dw MissingNoDexEntry
	dw MissingNoDexEntry
	dw MissingNoDexEntry
	dw PonytaDexEntry
	dw RapidashDexEntry
	dw RattataDexEntry
	dw RaticateDexEntry
	dw NidorinoDexEntry
	dw NidorinaDexEntry
	dw GeodudeDexEntry
	dw PorygonDexEntry
	dw AerodactylDexEntry
	dw MissingNoDexEntry
	dw MagnemiteDexEntry
	dw MissingNoDexEntry
	dw MissingNoDexEntry
	dw CharmanderDexEntry
	dw SquirtleDexEntry
	dw CharmeleonDexEntry
	dw WartortleDexEntry
	dw CharizardDexEntry
	dw MissingNoDexEntry
	dw MissingNoDexEntry
	dw MissingNoDexEntry
	dw MissingNoDexEntry
	dw OddishDexEntry
	dw GloomDexEntry
	dw VileplumeDexEntry
	dw BellsproutDexEntry
	dw WeepinbellDexEntry
	dw VictreebelDexEntry

; string: species name
; height in feet, inches
; weight in pounds
; text entry

RhydonDexEntry:
	db "DRILL@"
	db 6,3
	dw 2650
	TX_FAR _RhydonDexEntry
	db "@"

KangaskhanDexEntry:
	db "PARENT@"
	db 7,3
	dw 1760
	TX_FAR _KangaskhanDexEntry
	db "@"

NidoranMDexEntry:
	db "POISON PIN@"
	db 1,8
	dw 200
	TX_FAR _NidoranMDexEntry
	db "@"

ClefairyDexEntry:
	db "FAIRY@"
	db 2,0
	dw 170
	TX_FAR _ClefairyDexEntry
	db "@"

SpearowDexEntry:
	db "TINY BIRD@"
	db 1,0
	dw 40
	TX_FAR _SpearowDexEntry
	db "@"

VoltorbDexEntry:
	db "BALL@"
	db 1,8
	dw 230
	TX_FAR _VoltorbDexEntry
	db "@"

NidokingDexEntry:
	db "DRILL@"
	db 4,7
	dw 1370
	TX_FAR _NidokingDexEntry
	db "@"

SlowbroDexEntry:
	db "HERMITCRAB@"
	db 5,3
	dw 1730
	TX_FAR _SlowbroDexEntry
	db "@"

IvysaurDexEntry:
	db "SEED@"
	db 3,3
	dw 290
	TX_FAR _IvysaurDexEntry
	db "@"

ExeggutorDexEntry:
	db "COCONUT@"
	db 6,7
	dw 2650
	TX_FAR _ExeggutorDexEntry
	db "@"

LickitungDexEntry:
	db "LICKING@"
	db 3,11
	dw 1440
	TX_FAR _LickitungDexEntry
	db "@"

ExeggcuteDexEntry:
	db "EGG@"
	db 1,4
	dw 60
	TX_FAR _ExeggcuteDexEntry
	db "@"

GrimerDexEntry:
	db "SLUDGE@"
	db 2,11
	dw 660
	TX_FAR _GrimerDexEntry
	db "@"

GengarDexEntry:
	db "SHADOW@"
	db 4,11
	dw 890
	TX_FAR _GengarDexEntry
	db "@"

NidoranFDexEntry:
	db "POISON PIN@"
	db 1,4
	dw 150
	TX_FAR _NidoranFDexEntry
	db "@"

NidoqueenDexEntry:
	db "DRILL@"
	db 4,3
	dw 1320
	TX_FAR _NidoqueenDexEntry
	db "@"

CuboneDexEntry:
	db "LONELY@"
	db 1,4
	dw 140
	TX_FAR _CuboneDexEntry
	db "@"

RhyhornDexEntry:
	db "SPIKES@"
	db 3,3
	dw 2540
	TX_FAR _RhyhornDexEntry
	db "@"

LaprasDexEntry:
	db "TRANSPORT@"
	db 8,2
	dw 4850
	TX_FAR _LaprasDexEntry
	db "@"

ArcanineDexEntry:
	db "LEGENDARY@"
	db 6,3
	dw 3420
	TX_FAR _ArcanineDexEntry
	db "@"

MewDexEntry:
	db "NEW SPECIE@"
	db 1,4
	dw 90
	TX_FAR _MewDexEntry
	db "@"

GyaradosDexEntry:
	db "ATROCIOUS@"
	db 21,4
	dw 5180
	TX_FAR _GyaradosDexEntry
	db "@"

ShellderDexEntry:
	db "BIVALVE@"
	db 1,0
	dw 90
	TX_FAR _ShellderDexEntry
	db "@"

TentacoolDexEntry:
	db "JELLYFISH@"
	db 2,11
	dw 1000
	TX_FAR _TentacoolDexEntry
	db "@"

GastlyDexEntry:
	db "GAS@"
	db 4,3
	dw 2
	TX_FAR _GastlyDexEntry
	db "@"

ScytherDexEntry:
	db "MANTIS@"
	db 4,11
	dw 1230
	TX_FAR _ScytherDexEntry
	db "@"

StaryuDexEntry:
	db "STARSHAPE@"
	db 2,7
	dw 760
	TX_FAR _StaryuDexEntry
	db "@"

BlastoiseDexEntry:
	db "SHELLFISH@"
	db 5,3
	dw 1890
	TX_FAR _BlastoiseDexEntry
	db "@"

PinsirDexEntry:
	db "STAGBEETLE@"
	db 4,11
	dw 1210
	TX_FAR _PinsirDexEntry
	db "@"

TangelaDexEntry:
	db "VINE@"
	db 3,3
	dw 770
	TX_FAR _TangelaDexEntry
	db "@"

GrowlitheDexEntry:
	db "PUPPY@"
	db 2,4
	dw 420
	TX_FAR _GrowlitheDexEntry
	db "@"

OnixDexEntry:
	db "ROCK SNAKE@"
	db 28,10
	dw 4630
	TX_FAR _OnixDexEntry
	db "@"

FearowDexEntry:
	db "BEAK@"
	db 3,11
	dw 840
	TX_FAR _FearowDexEntry
	db "@"

PidgeyDexEntry:
	db "TINY BIRD@"
	db 1,0
	dw 40
	TX_FAR _PidgeyDexEntry
	db "@"

SlowpokeDexEntry:
	db "DOPEY@"
	db 3,11
	dw 790
	TX_FAR _SlowpokeDexEntry
	db "@"

KadabraDexEntry:
	db "PSI@"
	db 4,3
	dw 1250
	TX_FAR _KadabraDexEntry
	db "@"

GravelerDexEntry:
	db "ROCK@"
	db 3,3
	dw 2320
	TX_FAR _GravelerDexEntry
	db "@"

ChanseyDexEntry:
	db "EGG@"
	db 3,7
	dw 760
	TX_FAR _ChanseyDexEntry
	db "@"

MachokeDexEntry:
	db "SUPERPOWER@"
	db 4,11
	dw 1550
	TX_FAR _MachokeDexEntry
	db "@"

MrMimeDexEntry:
	db "BARRIER@"
	db 4,3
	dw 1200
	TX_FAR _MrMimeDexEntry
	db "@"

HitmonleeDexEntry:
	db "KICKING@"
	db 4,11
	dw 1100
	TX_FAR _HitmonleeDexEntry
	db "@"

HitmonchanDexEntry:
	db "PUNCHING@"
	db 4,7
	dw 1110
	TX_FAR _HitmonchanDexEntry
	db "@"

ArbokDexEntry:
	db "COBRA@"
	db 11,6
	dw 1430
	TX_FAR _ArbokDexEntry
	db "@"

ParasectDexEntry:
	db "MUSHROOM@"
	db 3,3
	dw 650
	TX_FAR _ParasectDexEntry
	db "@"

PsyduckDexEntry:
	db "DUCK@"
	db 2,7
	dw 430
	TX_FAR _PsyduckDexEntry
	db "@"

DrowzeeDexEntry:
	db "HYPNOSIS@"
	db 3,3
	dw 710
	TX_FAR _DrowzeeDexEntry
	db "@"

GolemDexEntry:
	db "MEGATON@"
	db 4,7
	dw 6620
	TX_FAR _GolemDexEntry
	db "@"

MagmarDexEntry:
	db "SPITFIRE@"
	db 4,3
	dw 980
	TX_FAR _MagmarDexEntry
	db "@"

ElectabuzzDexEntry:
	db "ELECTRIC@"
	db 3,7
	dw 660
	TX_FAR _ElectabuzzDexEntry
	db "@"

MagnetonDexEntry:
	db "MAGNET@"
	db 3,3
	dw 1320
	TX_FAR _MagnetonDexEntry
	db "@"

KoffingDexEntry:
	db "POISON GAS@"
	db 2,0
	dw 20
	TX_FAR _KoffingDexEntry
	db "@"

MankeyDexEntry:
	db "PIG MONKEY@"
	db 1,8
	dw 620
	TX_FAR _MankeyDexEntry
	db "@"

SeelDexEntry:
	db "SEA LION@"
	db 3,7
	dw 1980
	TX_FAR _SeelDexEntry
	db "@"

DiglettDexEntry:
	db "MOLE@"
	db 0,8
	dw 20
	TX_FAR _DiglettDexEntry
	db "@"

TaurosDexEntry:
	db "WILD BULL@"
	db 4,7
	dw 1950
	TX_FAR _TaurosDexEntry
	db "@"

FarfetchdDexEntry:
	db "WILD DUCK@"
	db 2,7
	dw 330
	TX_FAR _FarfetchdDexEntry
	db "@"

VenonatDexEntry:
	db "INSECT@"
	db 3,3
	dw 660
	TX_FAR _VenonatDexEntry
	db "@"

DragoniteDexEntry:
	db "DRAGON@"
	db 7,3
	dw 4630
	TX_FAR _DragoniteDexEntry
	db "@"

DoduoDexEntry:
	db "TWIN BIRD@"
	db 4,7
	dw 860
	TX_FAR _DoduoDexEntry
	db "@"

PoliwagDexEntry:
	db "TADPOLE@"
	db 2,0
	dw 270
	TX_FAR _PoliwagDexEntry
	db "@"

JynxDexEntry:
	db "HUMANSHAPE@"
	db 4,7
	dw 900
	TX_FAR _JynxDexEntry
	db "@"

MoltresDexEntry:
	db "FLAME@"
	db 6,7
	dw 1320
	TX_FAR _MoltresDexEntry
	db "@"

ArticunoDexEntry:
	db "FREEZE@"
	db 5,7
	dw 1220
	TX_FAR _ArticunoDexEntry
	db "@"

ZapdosDexEntry:
	db "ELECTRIC@"
	db 5,3
	dw 1160
	TX_FAR _ZapdosDexEntry
	db "@"

DittoDexEntry:
	db "TRANSFORM@"
	db 1,0
	dw 90
	TX_FAR _DittoDexEntry
	db "@"

MeowthDexEntry:
	db "SCRATCHCAT@"
	db 1,4
	dw 90
	TX_FAR _MeowthDexEntry
	db "@"

KrabbyDexEntry:
	db "RIVER CRAB@"
	db 1,4
	dw 140
	TX_FAR _KrabbyDexEntry
	db "@"

VulpixDexEntry:
	db "FOX@"
	db 2,0
	dw 220
	TX_FAR _VulpixDexEntry
	db "@"

NinetalesDexEntry:
	db "FOX@"
	db 3,7
	dw 440
	TX_FAR _NinetalesDexEntry
	db "@"

PikachuDexEntry:
	db "MOUSE@"
	db 1,4
	dw 130
	TX_FAR _PikachuDexEntry
	db "@"

RaichuDexEntry:
	db "MOUSE@"
	db 2,7
	dw 660
	TX_FAR _RaichuDexEntry
	db "@"

DratiniDexEntry:
	db "DRAGON@"
	db 5,11
	dw 70
	TX_FAR _DratiniDexEntry
	db "@"

DragonairDexEntry:
	db "DRAGON@"
	db 13,1
	dw 360
	TX_FAR _DragonairDexEntry
	db "@"

KabutoDexEntry:
	db "SHELLFISH@"
	db 1,8
	dw 250
	TX_FAR _KabutoDexEntry
	db "@"

KabutopsDexEntry:
	db "SHELLFISH@"
	db 4,3
	dw 890
	TX_FAR _KabutopsDexEntry
	db "@"

HorseaDexEntry:
	db "DRAGON@"
	db 1,4
	dw 180
	TX_FAR _HorseaDexEntry
	db "@"

SeadraDexEntry:
	db "DRAGON@"
	db 3,11
	dw 550
	TX_FAR _SeadraDexEntry
	db "@"

SandshrewDexEntry:
	db "MOUSE@"
	db 2,0
	dw 260
	TX_FAR _SandshrewDexEntry
	db "@"

SandslashDexEntry:
	db "MOUSE@"
	db 3,3
	dw 650
	TX_FAR _SandslashDexEntry
	db "@"

OmanyteDexEntry:
	db "SPIRAL@"
	db 1,4
	dw 170
	TX_FAR _OmanyteDexEntry
	db "@"

OmastarDexEntry:
	db "SPIRAL@"
	db 3,3
	dw 770
	TX_FAR _OmastarDexEntry
	db "@"

JigglypuffDexEntry:
	db "BALLOON@"
	db 1,8
	dw 120
	TX_FAR _JigglypuffDexEntry
	db "@"

WigglytuffDexEntry:
	db "BALLOON@"
	db 3,3
	dw 260
	TX_FAR _WigglytuffDexEntry
	db "@"

EeveeDexEntry:
	db "EVOLUTION@"
	db 1,0
	dw 140
	TX_FAR _EeveeDexEntry
	db "@"

FlareonDexEntry:
	db "FLAME@"
	db 2,11
	dw 550
	TX_FAR _FlareonDexEntry
	db "@"

JolteonDexEntry:
	db "LIGHTNING@"
	db 2,7
	dw 540
	TX_FAR _JolteonDexEntry
	db "@"

VaporeonDexEntry:
	db "BUBBLE JET@"
	db 3,3
	dw 640
	TX_FAR _VaporeonDexEntry
	db "@"

MachopDexEntry:
	db "SUPERPOWER@"
	db 2,7
	dw 430
	TX_FAR _MachopDexEntry
	db "@"

ZubatDexEntry:
	db "BAT@"
	db 2,7
	dw 170
	TX_FAR _ZubatDexEntry
	db "@"

EkansDexEntry:
	db "SNAKE@"
	db 6,7
	dw 150
	TX_FAR _EkansDexEntry
	db "@"

ParasDexEntry:
	db "MUSHROOM@"
	db 1,0
	dw 120
	TX_FAR _ParasDexEntry
	db "@"

PoliwhirlDexEntry:
	db "TADPOLE@"
	db 3,3
	dw 440
	TX_FAR _PoliwhirlDexEntry
	db "@"

PoliwrathDexEntry:
	db "TADPOLE@"
	db 4,3
	dw 1190
	TX_FAR _PoliwrathDexEntry
	db "@"

WeedleDexEntry:
	db "HAIRY BUG@"
	db 1,0
	dw 70
	TX_FAR _WeedleDexEntry
	db "@"

KakunaDexEntry:
	db "COCOON@"
	db 2,0
	dw 220
	TX_FAR _KakunaDexEntry
	db "@"

BeedrillDexEntry:
	db "POISON BEE@"
	db 3,3
	dw 650
	TX_FAR _BeedrillDexEntry
	db "@"

DodrioDexEntry:
	db "TRIPLEBIRD@"
	db 5,11
	dw 1880
	TX_FAR _DodrioDexEntry
	db "@"

PrimeapeDexEntry:
	db "PIG MONKEY@"
	db 3,3
	dw 710
	TX_FAR _PrimeapeDexEntry
	db "@"

DugtrioDexEntry:
	db "MOLE@"
	db 2,4
	dw 730
	TX_FAR _DugtrioDexEntry
	db "@"

VenomothDexEntry:
	db "POISONMOTH@"
	db 4,11
	dw 280
	TX_FAR _VenomothDexEntry
	db "@"

DewgongDexEntry:
	db "SEA LION@"
	db 5,7
	dw 2650
	TX_FAR _DewgongDexEntry
	db "@"

CaterpieDexEntry:
	db "WORM@"
	db 1,0
	dw 60
	TX_FAR _CaterpieDexEntry
	db "@"

MetapodDexEntry:
	db "COCOON@"
	db 2,4
	dw 220
	TX_FAR _MetapodDexEntry
	db "@"

ButterfreeDexEntry:
	db "BUTTERFLY@"
	db 3,7
	dw 710
	TX_FAR _ButterfreeDexEntry
	db "@"

MachampDexEntry:
	db "SUPERPOWER@"
	db 5,3
	dw 2870
	TX_FAR _MachampDexEntry
	db "@"

GolduckDexEntry:
	db "DUCK@"
	db 5,7
	dw 1690
	TX_FAR _GolduckDexEntry
	db "@"

HypnoDexEntry:
	db "HYPNOSIS@"
	db 5,3
	dw 1670
	TX_FAR _HypnoDexEntry
	db "@"

GolbatDexEntry:
	db "BAT@"
	db 5,3
	dw 1210
	TX_FAR _GolbatDexEntry
	db "@"

MewtwoDexEntry:
	db "GENETIC@"
	db 6,7
	dw 2690
	TX_FAR _MewtwoDexEntry
	db "@"

SnorlaxDexEntry:
	db "SLEEPING@"
	db 6,11
	dw 10140
	TX_FAR _SnorlaxDexEntry
	db "@"

MagikarpDexEntry:
	db "FISH@"
	db 2,11
	dw 220
	TX_FAR _MagikarpDexEntry
	db "@"

MukDexEntry:
	db "SLUDGE@"
	db 3,11
	dw 660
	TX_FAR _MukDexEntry
	db "@"

KinglerDexEntry:
	db "PINCER@"
	db 4,3
	dw 1320
	TX_FAR _KinglerDexEntry
	db "@"

CloysterDexEntry:
	db "BIVALVE@"
	db 4,11
	dw 2920
	TX_FAR _CloysterDexEntry
	db "@"

ElectrodeDexEntry:
	db "BALL@"
	db 3,11
	dw 1470
	TX_FAR _ElectrodeDexEntry
	db "@"

ClefableDexEntry:
	db "FAIRY@"
	db 4,3
	dw 880
	TX_FAR _ClefableDexEntry
	db "@"

WeezingDexEntry:
	db "POISON GAS@"
	db 3,11
	dw 210
	TX_FAR _WeezingDexEntry
	db "@"

PersianDexEntry:
	db "CLASSY CAT@"
	db 3,3
	dw 710
	TX_FAR _PersianDexEntry
	db "@"

MarowakDexEntry:
	db "BONEKEEPER@"
	db 3,3
	dw 990
	TX_FAR _MarowakDexEntry
	db "@"

HaunterDexEntry:
	db "GAS@"
	db 5,3
	dw 2
	TX_FAR _HaunterDexEntry
	db "@"

AbraDexEntry:
	db "PSI@"
	db 2,11
	dw 430
	TX_FAR _AbraDexEntry
	db "@"

AlakazamDexEntry:
	db "PSI@"
	db 4,11
	dw 1060
	TX_FAR _AlakazamDexEntry
	db "@"

PidgeottoDexEntry:
	db "BIRD@"
	db 3,7
	dw 660
	TX_FAR _PidgeottoDexEntry
	db "@"

PidgeotDexEntry:
	db "BIRD@"
	db 4,11
	dw 870
	TX_FAR _PidgeotDexEntry
	db "@"

StarmieDexEntry:
	db "MYSTERIOUS@"
	db 3,7
	dw 1760
	TX_FAR _StarmieDexEntry
	db "@"

BulbasaurDexEntry:
	db "SEED@"
	db 2,4
	dw 150
	TX_FAR _BulbasaurDexEntry
	db "@"

VenusaurDexEntry:
	db "SEED@"
	db 6,7
	dw 2210
	TX_FAR _VenusaurDexEntry
	db "@"

TentacruelDexEntry:
	db "JELLYFISH@"
	db 5,3
	dw 1210
	TX_FAR _TentacruelDexEntry
	db "@"

GoldeenDexEntry:
	db "GOLDFISH@"
	db 2,0
	dw 330
	TX_FAR _GoldeenDexEntry
	db "@"

SeakingDexEntry:
	db "GOLDFISH@"
	db 4,3
	dw 860
	TX_FAR _SeakingDexEntry
	db "@"

PonytaDexEntry:
	db "FIRE HORSE@"
	db 3,3
	dw 660
	TX_FAR _PonytaDexEntry
	db "@"

RapidashDexEntry:
	db "FIRE HORSE@"
	db 5,7
	dw 2090
	TX_FAR _RapidashDexEntry
	db "@"

RattataDexEntry:
	db "RAT@"
	db 1,0
	dw 80
	TX_FAR _RattataDexEntry
	db "@"

RaticateDexEntry:
	db "RAT@"
	db 2,4
	dw 410
	TX_FAR _RaticateDexEntry
	db "@"

NidorinoDexEntry:
	db "POISON PIN@"
	db 2,11
	dw 430
	TX_FAR _NidorinoDexEntry
	db "@"

NidorinaDexEntry:
	db "POISON PIN@"
	db 2,7
	dw 440
	TX_FAR _NidorinaDexEntry
	db "@"

GeodudeDexEntry:
	db "ROCK@"
	db 1,4
	dw 440
	TX_FAR _GeodudeDexEntry
	db "@"

PorygonDexEntry:
	db "VIRTUAL@"
	db 2,7
	dw 800
	TX_FAR _PorygonDexEntry
	db "@"

AerodactylDexEntry:
	db "FOSSIL@"
	db 5,11
	dw 1300
	TX_FAR _AerodactylDexEntry
	db "@"

MagnemiteDexEntry:
	db "MAGNET@"
	db 1,0
	dw 130
	TX_FAR _MagnemiteDexEntry
	db "@"

CharmanderDexEntry:
	db "LIZARD@"
	db 2,0
	dw 190
	TX_FAR _CharmanderDexEntry
	db "@"

SquirtleDexEntry:
	db "TINYTURTLE@"
	db 1,8
	dw 200
	TX_FAR _SquirtleDexEntry
	db "@"

CharmeleonDexEntry:
	db "FLAME@"
	db 3,7
	dw 420
	TX_FAR _CharmeleonDexEntry
	db "@"

WartortleDexEntry:
	db "TURTLE@"
	db 3,3
	dw 500
	TX_FAR _WartortleDexEntry
	db "@"

CharizardDexEntry:
	db "FLAME@"
	db 5,7
	dw 2000
	TX_FAR _CharizardDexEntry
	db "@"

OddishDexEntry:
	db "WEED@"
	db 1,8
	dw 120
	TX_FAR _OddishDexEntry
	db "@"

GloomDexEntry:
	db "WEED@"
	db 2,7
	dw 190
	TX_FAR _GloomDexEntry
	db "@"

VileplumeDexEntry:
	db "FLOWER@"
	db 3,11
	dw 410
	TX_FAR _VileplumeDexEntry
	db "@"

BellsproutDexEntry:
	db "FLOWER@"
	db 2,4
	dw 90
	TX_FAR _BellsproutDexEntry
	db "@"

WeepinbellDexEntry:
	db "FLYCATCHER@"
	db 3,3
	dw 140
	TX_FAR _WeepinbellDexEntry
	db "@"

VictreebelDexEntry:
	db "FLYCATCHER@"
	db 5,7
	dw 340
	TX_FAR _VictreebelDexEntry
	db "@"

MissingNoDexEntry:
	db "???@"
	db 10 ; 1.0 m
	db 100 ; 10.0 kg
	db 0,"コメント さくせいちゅう@" ; コメント作成中 (Comment to be written)

PokedexToIndex:
	; converts the Pokédex number at $D11E to an index
	push bc
	push hl
	ld a,[$D11E]
	ld b,a
	ld c,0
	ld hl,PokedexOrder

.loop\@ ; go through the list until we find an entry with a matching dex number
	inc c
	ld a,[hli]
	cp b
	jr nz,.loop\@

	ld a,c
	ld [$D11E],a
	pop hl
	pop bc
	ret

IndexToPokedex:
	; converts the indexédex number at $D11E to a Pokédex number
	push bc
	push hl
	ld a,[$D11E]
	dec a
	ld hl,PokedexOrder
	ld b,0
	ld c,a
	add hl,bc
	ld a,[hl]
	ld [$D11E],a
	pop hl
	pop bc
	ret

PokedexOrder: ; 5024
	db DEX_RHYDON
	db DEX_KANGASKHAN
	db DEX_NIDORAN_M
	db DEX_CLEFAIRY
	db DEX_SPEAROW
	db DEX_VOLTORB
	db DEX_NIDOKING
	db DEX_SLOWBRO
	db DEX_IVYSAUR
	db DEX_EXEGGUTOR
	db DEX_LICKITUNG
	db DEX_EXEGGCUTE
	db DEX_GRIMER
	db DEX_GENGAR
	db DEX_NIDORAN_F
	db DEX_NIDOQUEEN
	db DEX_CUBONE
	db DEX_RHYHORN
	db DEX_LAPRAS
	db DEX_ARCANINE
	db DEX_MEW
	db DEX_GYARADOS
	db DEX_SHELLDER
	db DEX_TENTACOOL
	db DEX_GASTLY
	db DEX_SCYTHER
	db DEX_STARYU
	db DEX_BLASTOISE
	db DEX_PINSIR
	db DEX_TANGELA
	db 0 ; MISSINGNO.
	db 0 ; MISSINGNO.
	db DEX_GROWLITHE
	db DEX_ONIX
	db DEX_FEAROW
	db DEX_PIDGEY
	db DEX_SLOWPOKE
	db DEX_KADABRA
	db DEX_GRAVELER
	db DEX_CHANSEY
	db DEX_MACHOKE
	db DEX_MR_MIME
	db DEX_HITMONLEE
	db DEX_HITMONCHAN
	db DEX_ARBOK
	db DEX_PARASECT
	db DEX_PSYDUCK
	db DEX_DROWZEE
	db DEX_GOLEM
	db 0 ; MISSINGNO.
	db DEX_MAGMAR
	db 0 ; MISSINGNO.
	db DEX_ELECTABUZZ
	db DEX_MAGNETON
	db DEX_KOFFING
	db 0 ; MISSINGNO.
	db DEX_MANKEY
	db DEX_SEEL
	db DEX_DIGLETT
	db DEX_TAUROS
	db 0 ; MISSINGNO.
	db 0 ; MISSINGNO.
	db 0 ; MISSINGNO.
	db DEX_FARFETCH_D
	db DEX_VENONAT
	db DEX_DRAGONITE
	db 0 ; MISSINGNO.
	db 0 ; MISSINGNO.
	db 0 ; MISSINGNO.
	db DEX_DODUO
	db DEX_POLIWAG
	db DEX_JYNX
	db DEX_MOLTRES
	db DEX_ARTICUNO
	db DEX_ZAPDOS
	db DEX_DITTO
	db DEX_MEOWTH
	db DEX_KRABBY
	db 0 ; MISSINGNO.
	db 0 ; MISSINGNO.
	db 0 ; MISSINGNO.
	db DEX_VULPIX
	db DEX_NINETALES
	db DEX_PIKACHU
	db DEX_RAICHU
	db 0 ; MISSINGNO.
	db 0 ; MISSINGNO.
	db DEX_DRATINI
	db DEX_DRAGONAIR
	db DEX_KABUTO
	db DEX_KABUTOPS
	db DEX_HORSEA
	db DEX_SEADRA
	db 0 ; MISSINGNO.
	db 0 ; MISSINGNO.
	db DEX_SANDSHREW
	db DEX_SANDSLASH
	db DEX_OMANYTE
	db DEX_OMASTAR
	db DEX_JIGGLYPUFF
	db DEX_WIGGLYTUFF
	db DEX_EEVEE
	db DEX_FLAREON
	db DEX_JOLTEON
	db DEX_VAPOREON
	db DEX_MACHOP
	db DEX_ZUBAT
	db DEX_EKANS
	db DEX_PARAS
	db DEX_POLIWHIRL
	db DEX_POLIWRATH
	db DEX_WEEDLE
	db DEX_KAKUNA
	db DEX_BEEDRILL
	db 0 ; MISSINGNO.
	db DEX_DODRIO
	db DEX_PRIMEAPE
	db DEX_DUGTRIO
	db DEX_VENOMOTH
	db DEX_DEWGONG
	db 0 ; MISSINGNO.
	db 0 ; MISSINGNO.
	db DEX_CATERPIE
	db DEX_METAPOD
	db DEX_BUTTERFREE
	db DEX_MACHAMP
	db 0 ; MISSINGNO.
	db DEX_GOLDUCK
	db DEX_HYPNO
	db DEX_GOLBAT
	db DEX_MEWTWO
	db DEX_SNORLAX
	db DEX_MAGIKARP
	db 0 ; MISSINGNO.
	db 0 ; MISSINGNO.
	db DEX_MUK
	db 0 ; MISSINGNO.
	db DEX_KINGLER
	db DEX_CLOYSTER
	db 0 ; MISSINGNO.
	db DEX_ELECTRODE
	db DEX_CLEFABLE
	db DEX_WEEZING
	db DEX_PERSIAN
	db DEX_MAROWAK
	db 0 ; MISSINGNO.
	db DEX_HAUNTER
	db DEX_ABRA
	db DEX_ALAKAZAM
	db DEX_PIDGEOTTO
	db DEX_PIDGEOT
	db DEX_STARMIE
	db DEX_BULBASAUR
	db DEX_VENUSAUR
	db DEX_TENTACRUEL
	db 0 ; MISSINGNO.
	db DEX_GOLDEEN
	db DEX_SEAKING
	db 0 ; MISSINGNO.
	db 0 ; MISSINGNO.
	db 0 ; MISSINGNO.
	db 0 ; MISSINGNO.
	db DEX_PONYTA
	db DEX_RAPIDASH
	db DEX_RATTATA
	db DEX_RATICATE
	db DEX_NIDORINO
	db DEX_NIDORINA
	db DEX_GEODUDE
	db DEX_PORYGON
	db DEX_AERODACTYL
	db 0 ; MISSINGNO.
	db DEX_MAGNEMITE
	db 0 ; MISSINGNO.
	db 0 ; MISSINGNO.
	db DEX_CHARMANDER
	db DEX_SQUIRTLE
	db DEX_CHARMELEON
	db DEX_WARTORTLE
	db DEX_CHARIZARD
	db 0 ; MISSINGNO.
	db 0 ; MISSINGNO.
	db 0 ; MISSINGNO.
	db 0 ; MISSINGNO.
	db DEX_ODDISH
	db DEX_GLOOM
	db DEX_VILEPLUME
	db DEX_BELLSPROUT
	db DEX_WEEPINBELL
	db DEX_VICTREEBEL

INCBIN "baserom.gbc",$410e2,$4160c - $410e2

UnnamedText_4160c: ; 0x4160c
	TX_FAR _UnnamedText_4160c
	db $50
; 0x4160c + 5 bytes

INCBIN "baserom.gbc",$41611,$41623 - $41611

UnnamedText_41623: ; 0x41623
	TX_FAR _UnnamedText_41623
	db $50
; 0x41623 + 5 bytes

UnnamedText_41628: ; 0x41628
	TX_FAR _UnnamedText_41628
	db $50
; 0x41628 + 5 bytes

INCBIN "baserom.gbc",$4162d,$41642 - $4162d

UnnamedText_41642: ; 0x41642
	TX_FAR _UnnamedText_41642
	db $50
; 0x41642 + 5 bytes

UnnamedText_41647: ; 0x41647
	TX_FAR _UnnamedText_41647
	db $50
; 0x41647 + 5 bytes

INCBIN "baserom.gbc",$4164c,$41655 - $4164c

UnnamedText_41655: ; 0x41655
	TX_FAR _UnnamedText_41655
	db $50
; 0x41655 + 5 bytes

INCBIN "baserom.gbc",$4165a,$4166c - $4165a

UnnamedText_4166c: ; 0x4166c
	TX_FAR _UnnamedText_4166c
	db $50
; 0x4166c + 5 bytes

UnnamedText_41671: ; 0x41671
	TX_FAR _UnnamedText_41671
	db $50
; 0x41671 + 5 bytes

INCBIN "baserom.gbc",$41676,$a63

IF _RED
	INCBIN "gfx/red/introfight.2bpp"
ENDC
IF _BLUE
	INCBIN "gfx/blue/introfight.2bpp"
ENDC

; XXX what do these do
	FuncCoord 5,0
	ld hl,Coord
	ld de,OTString67E5
	call PlaceString
	ld a,[$CD3D]
	ld [$D11E],a
	ld a,$3A
	call Predef
	ld hl,$C3A9
	ld de,$D11E
	ld bc,$8103
	call $3C5F
	FuncCoord 5,2
	ld hl,Coord
	ld de,$CF4B
	call PlaceString
	FuncCoord 8,4
	ld hl,Coord
	ld de,$CD41
	call PlaceString
	ld hl,$C420
	ld de,$CD4C
	ld bc,$8205
	jp $3C5F

	FuncCoord 5,10
	ld hl,Coord
	ld de,OTString67E5
	call PlaceString
	ld a,[$CD3E]
	ld [$D11E],a
	ld a,$3A
	call Predef
	ld hl,$C471
	ld de,$D11E
	ld bc,$8103
	call $3C5F
	FuncCoord 5,12
	ld hl,Coord
	ld de,$CD6D
	call PlaceString
	FuncCoord 8,14
	ld hl,Coord
	ld de,$CD4E
	call PlaceString
	ld hl,$C4E8
	ld de,$CD59
	ld bc,$8205
	jp $3C5F

OTString67E5: ; 67E5
	db "──",$74,$F2,$4E
	db $4E
	db "OT/",$4E
	db $73,"№",$F2,"@"

SECTION "bank11",DATA,BANK[$11]

LavenderTown_h: ; 0x44000 to 0x4402d (45 bytes) (bank=11) (id=4)
	db $00 ; tileset
	db LAVENDER_TOWN_HEIGHT, LAVENDER_TOWN_WIDTH ; dimensions (y, x)
	dw LavenderTownBlocks, LavenderTownTexts, LavenderTownScript ; blocks, texts, scripts
	db NORTH | SOUTH | WEST ; connections

	; connections data

	db ROUTE_10
	dw Route10Blocks + (ROUTE_10_HEIGHT - 3) * ROUTE_10_WIDTH ; connection strip location
	dw $C6EB + 0 ; current map position
	db ROUTE_10_WIDTH, ROUTE_10_WIDTH ; bigness, width
	db (ROUTE_10_HEIGHT * 2) - 1, (0 * -2) ; alignments (y, x)
	dw $C6E9 + ROUTE_10_HEIGHT * (ROUTE_10_WIDTH + 6) ; window

	db ROUTE_12
	dw Route12Blocks ; connection strip location
	dw $C6EB + (LAVENDER_TOWN_HEIGHT + 3) * (LAVENDER_TOWN_WIDTH + 6) + 0 ; current map position
	db ROUTE_12_WIDTH, ROUTE_12_WIDTH ; bigness, width
	db 0, (0 * -2) ; alignments (y, x)
	dw $C6EF + ROUTE_12_WIDTH ; window

	db ROUTE_8
	dw Route8Blocks - 3 + (ROUTE_8_WIDTH) ; connection strip location
	dw $C6E8 + (LAVENDER_TOWN_WIDTH + 6) * (0 + 3) ; current map position
	db ROUTE_8_HEIGHT, ROUTE_8_WIDTH ; bigness, width
	db (0 * -2), (ROUTE_8_WIDTH * 2) - 1 ; alignments (y, x)
	dw $C6EE + 2 * ROUTE_8_WIDTH ; window

	; end connections data

	dw LavenderTownObject ; objects

LavenderTownObject: ; 0x4402d (size=88)
	db $2c ; border tile

	db $6 ; warps
	db $5, $3, $0, LAVENDER_POKECENTER
	db $5, $e, $0, POKEMONTOWER_1
	db $9, $7, $0, LAVENDER_HOUSE_1
	db $d, $f, $0, LAVENDER_MART
	db $d, $3, $0, LAVENDER_HOUSE_2
	db $d, $7, $0, NAME_RATERS_HOUSE

	db $6 ; signs
	db $9, $b, $4 ; LavenderTownText4
	db $3, $9, $5 ; LavenderTownText5
	db $d, $10, $6 ; LavenderTownText6
	db $5, $4, $7 ; LavenderTownText7
	db $9, $5, $8 ; LavenderTownText8
	db $7, $11, $9 ; LavenderTownText9

	db $3 ; people
	db SPRITE_LITTLE_GIRL, $9 + 4, $f + 4, $fe, $0, $1 ; person
	db SPRITE_BLACK_HAIR_BOY_1, $a + 4, $9 + 4, $ff, $ff, $2 ; person
	db SPRITE_BLACK_HAIR_BOY_2, $7 + 4, $8 + 4, $fe, $2, $3 ; person

	; warp-to
	EVENT_DISP $a, $5, $3 ; LAVENDER_POKECENTER
	EVENT_DISP $a, $5, $e ; POKEMONTOWER_1
	EVENT_DISP $a, $9, $7 ; LAVENDER_HOUSE_1
	EVENT_DISP $a, $d, $f ; LAVENDER_MART
	EVENT_DISP $a, $d, $3 ; LAVENDER_HOUSE_2
	EVENT_DISP $a, $d, $7 ; NAME_RATERS_HOUSE

LavenderTownBlocks: ; 0x44085 90
	INCBIN "maps/lavendertown.blk"

ViridianPokecenterBlocks: ; 0x440df 28
	INCBIN "maps/viridianpokecenter.blk"

SafariZoneRestHouse1Blocks: ; 0x440fb 16
	INCBIN "maps/safarizoneresthouse1.blk"

LavenderTownScript: ; 0x4410b
	jp $3c3c
; 0x4410e

LavenderTownTexts: ; 0x4410e
	dw LavenderTownText1, LavenderTownText2, LavenderTownText3, LavenderTownText4, LavenderTownText5, LavenderTownText6, LavenderTownText7, LavenderTownText8, LavenderTownText9

LavenderTownText1: ; 0x44120
	db $08 ; asm
	ld hl, UnnamedText_4413c
	call PrintText
	call $35ec
	ld a, [$cc26]
	and a
	ld hl, UnnamedText_44146
	jr nz, .asm_40831 ; 0x44131
	ld hl, UnnamedText_44141
.asm_40831 ; 0x44136
	call PrintText
	jp TextScriptEnd

UnnamedText_4413c: ; 0x4413c
	TX_FAR _UnnamedText_4413c
	db $50
; 0x4413c + 5 bytes

UnnamedText_44141: ; 0x44141
	TX_FAR _UnnamedText_44141
	db $50
; 0x44141 + 5 bytes

UnnamedText_44146: ; 0x44146
	TX_FAR _UnnamedText_44146
	db $50
; 0x44146 + 5 bytes

LavenderTownText2: ; 0x4414b
	TX_FAR _LavenderTownText2
	db $50

LavenderTownText3: ; 0x44150
	TX_FAR _LavenderTownText3
	db $50

LavenderTownText4: ; 0x44155
	TX_FAR _LavenderTownText4
	db $50

LavenderTownText5: ; 0x4415a
	TX_FAR _LavenderTownText5
	db $50

LavenderTownText8: ; 0x4415f
	TX_FAR _LavenderTownText8
	db $50

LavenderTownText9: ; 0x44164
	TX_FAR _LavenderTownText9
	db $50

INCBIN "baserom.gbc",$44169,$441cc - $44169

UnnamedText_441cc: ; 0x441cc
	TX_FAR _UnnamedText_441cc
	db $50
; 0x441cc + 5 bytes

INCBIN "baserom.gbc",$441d1,$44201 - $441d1

UnnamedText_44201: ; 0x44201
	TX_FAR _UnnamedText_44201
	db $50
; 0x44201 + 5 bytes

UnnamedText_44206: ; 0x44206
	TX_FAR _UnnamedText_44206
	db $50
; 0x44206 + 5 bytes

UnnamedText_4420b: ; 0x4420b
	TX_FAR _UnnamedText_4420b
	db $50
; 0x4420b + 5 bytes

UnnamedText_44210: ; 0x44210
	TX_FAR _UnnamedText_44210
	db $50
; 0x44210 + 5 bytes

UnnamedText_44215: ; 0x44215
	TX_FAR _UnnamedText_44215
	db $50
; 0x44215 + 5 bytes

UnnamedText_4421a: ; 0x4421a
	TX_FAR _UnnamedText_4421a
	db $50
; 0x4421a + 5 bytes

UnnamedText_4421f: ; 0x4421f
	TX_FAR _UnnamedText_4421f
	db $50
; 0x4421f + 5 bytes

UnnamedText_44224: ; 0x44224
	TX_FAR _UnnamedText_44224
	db $50
; 0x44224 + 5 bytes

UnnamedText_44229: ; 0x44229
	TX_FAR _UnnamedText_44229
	db $50
; 0x44229 + 5 bytes

UnnamedText_4422e: ; 0x4422e
	TX_FAR _UnnamedText_4422e
	db $50
; 0x4422e + 5 bytes

UnnamedText_44233: ; 0x44233
	TX_FAR _UnnamedText_44233
	db $50
; 0x44233 + 5 bytes

UnnamedText_44238: ; 0x44238
	TX_FAR _UnnamedText_44238
	db $50
; 0x44238 + 5 bytes

UnnamedText_4423d: ; 0x4423d
	TX_FAR _UnnamedText_4423d
	db $50
; 0x4423d + 5 bytes

UnnamedText_44242: ; 0x44242
	TX_FAR _UnnamedText_44242
	db $50
; 0x44242 + 5 bytes

UnnamedText_44247: ; 0x44247
	TX_FAR _UnnamedText_44247
	db $50
; 0x44247 + 5 bytes

UnnamedText_4424c: ; 0x4424c
	TX_FAR _UnnamedText_4424c
	db $50
; 0x4424c + 5 bytes

ViridianPokecenter_h: ; 0x44251 to 0x4425d (12 bytes) (bank=11) (id=41)
	db $06 ; tileset
	db $04, $07 ; dimensions (y, x)
	dw ViridianPokecenterBlocks, ViridianPokecenterTexts, ViridianPokeCenterScript ; blocks, texts, scripts
	db $00 ; connections

	dw ViridianPokecenterObject ; objects

ViridianPokeCenterScript: ; 0x4425d
	call $22fa
	jp $3c3c
; 0x44263

ViridianPokecenterTexts: ; 0x44263
	dw ViridianPokeCenterText1, ViridianPokeCenterText2, ViridianPokeCenterText3, ViridianPokeCenterText4

ViridianPokeCenterText1: ; 0x4426b
	db $ff

ViridianPokeCenterText2: ; 0x4426c
	TX_FAR _ViridianPokeCenterText1
	db $50

INCBIN "baserom.gbc",$44271,$44271 - $44271

ViridianPokeCenterText3: ; 0x44271
	TX_FAR _ViridianPokeCenterText3
	db $50

ViridianPokeCenterText4:
	db $f6

ViridianPokecenterObject: ; 0x44277 (size=44)
	db $0 ; border tile

	db $2 ; warps
	db $7, $3, $0, $ff
	db $7, $4, $0, $ff

	db $0 ; signs

	db $4 ; people
	db SPRITE_NURSE, $1 + 4, $3 + 4, $ff, $d0, $1 ; person
	db SPRITE_GENTLEMAN, $5 + 4, $a + 4, $fe, $1, $2 ; person
	db SPRITE_BLACK_HAIR_BOY_1, $3 + 4, $4 + 4, $ff, $ff, $3 ; person
	db SPRITE_CABLE_CLUB_WOMAN, $2 + 4, $b + 4, $ff, $d0, $4 ; person

	; warp-to
	EVENT_DISP $7, $7, $3
	EVENT_DISP $7, $7, $4

Mansion1_h: ; 0x442a3 to 0x442af (12 bytes) (bank=11) (id=165)
	db $16 ; tileset
	db MANSION_1_HEIGHT, MANSION_1_WIDTH ; dimensions (y, x)
	dw Mansion1Blocks, Mansion1Texts, Mansion1Script ; blocks, texts, scripts
	db $00 ; connections

	dw Mansion1Object ; objects

Mansion1Script:
	call Mansion1Subscript1
	call $3c3c
	ld hl, Mansion1TrainerHeaders
	ld de, $4326
	ld a, [$d63a]
	call $3160
	ld [$d63a], a
	ret
; 0x442c5

Mansion1Subscript1: ; 0x442c5
	ld hl, $d126
	bit 5, [hl]
	res 5, [hl]
	ret z
	ld a, [$d796]
	bit 0, a
	jr nz, .asm_442ec ; 0x442d2 $18
	ld bc, $060c
	call $430b
	ld bc, $0308
	call $4304
	ld bc, $080a
	call $4304
	ld bc, $0d0d
	jp $4304
.asm_442ec
	ld bc, $060c
	call $4304
	ld bc, $0308
	call $430b
	ld bc, $080a
	call $430b
	ld bc, $0d0d
	jp $430b
; 0x44304

INCBIN "baserom.gbc",$44304,$4432c - $44304

Mansion1Texts: ; 0x4432c
	dw Mansion1Text1, Mansion1Text2, Mansion1Text3, Mansion1Text4

Mansion1TrainerHeaders:
Mansion1TrainerHeader0: ; 0x44334
	db $1 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d798 ; flag's byte
	dw Mansion1BattleText2 ; 0x434b TextBeforeBattle
	dw Mansion1AfterBattleText2 ; 0x4355 TextAfterBattle
	dw Mansion1EndBattleText2 ; 0x4350 TextEndBattle
	dw Mansion1EndBattleText2 ; 0x4350 TextEndBattle
; 0x44340

db $ff

Mansion1Text1: ; 0x44341
	db $08 ; asm
	ld hl, Mansion1TrainerHeader0
	call LoadTrainerHeader
	jp TextScriptEnd

Mansion1BattleText2: ; 0x4434b
	TX_FAR _Mansion1BattleText2
	db $50
; 0x4434b + 5 bytes

Mansion1EndBattleText2: ; 0x44350
	TX_FAR _Mansion1EndBattleText2
	db $50
; 0x44350 + 5 bytes

Mansion1AfterBattleText2: ; 0x44355
	TX_FAR _Mansion1AfterBattleText2
	db $50
; 0x44355 + 5 bytes

Mansion1Text4: ; 0x4435a
	db $8
	ld hl, UnnamedText_44395
	call PrintText
	call $35ec
	ld a, [$cc26]
	and a
	jr nz, .asm_4438c ; 0x44368 $22
	ld a, $1
	ld [$cc3c], a
	ld hl, $d126
	set 5, [hl]
	ld hl, UnnamedText_4439a
	call PrintText
	ld a, $ad
	call $23b1
	ld hl, $d796
	bit 0, [hl]
	set 0, [hl]
	jr z, .asm_44392 ; 0x44386 $a
	res 0, [hl]
	jr .asm_44392 ; 0x4438a $6
.asm_4438c
	ld hl, UnnamedText_4439f
	call PrintText
.asm_44392
	jp TextScriptEnd
; 0x44395

UnnamedText_44395: ; 0x44395
	TX_FAR _UnnamedText_44395
	db $50
; 0x44395 + 5 bytes

UnnamedText_4439a: ; 0x4439a
	TX_FAR _UnnamedText_4439a
	db $50
; 0x4439a + 5 bytes

UnnamedText_4439f: ; 0x4439f
	TX_FAR _UnnamedText_4439f
	db $50
; 0x4439f + 5 bytes

Mansion1Object: ; 0x443a4 (size=90)
	db $2e ; border tile

	db $8 ; warps
	db $1b, $4, $0, $ff
	db $1b, $5, $0, $ff
	db $1b, $6, $0, $ff
	db $1b, $7, $0, $ff
	db $a, $5, $0, MANSION_2
	db $17, $15, $0, MANSION_4
	db $1b, $1a, $0, $ff
	db $1b, $1b, $0, $ff

	db $0 ; signs

	db $3 ; people
	db SPRITE_OAK_AIDE, $11 + 4, $11 + 4, $ff, $d2, $41, SCIENTIST + $C8, $4 ; trainer
	db SPRITE_BALL, $3 + 4, $e + 4, $ff, $ff, $82, ESCAPE_ROPE ; item
	db SPRITE_BALL, $15 + 4, $12 + 4, $ff, $ff, $83, CARBOS ; item

	; warp-to
	EVENT_DISP $f, $1b, $4
	EVENT_DISP $f, $1b, $5
	EVENT_DISP $f, $1b, $6
	EVENT_DISP $f, $1b, $7
	EVENT_DISP $f, $a, $5 ; MANSION_2
	EVENT_DISP $f, $17, $15 ; MANSION_4
	EVENT_DISP $f, $1b, $1a
	EVENT_DISP $f, $1b, $1b

Mansion1Blocks: ; 0x44405 203
	INCBIN "maps/mansion1.blk"

RockTunnel1_h: ; 0x444d0 to 0x444dc (12 bytes) (bank=11) (id=82)
	db $11 ; tileset
	db ROCK_TUNNEL_1_HEIGHT, ROCK_TUNNEL_1_WIDTH ; dimensions (y, x)
	dw RockTunnel1Blocks, RockTunnel1Texts, RockTunnel1Script ; blocks, texts, scripts
	db $00 ; connections

	dw RockTunnel1Object ; objects

RockTunnel1Script: ; 0x444dc
	call $3c3c
	ld hl, Unnamed_44505 ; $4505
	ld de, Unnamed_444ef ; $44ef
	ld a, [$d621]
	call $3160
	ld [$d621], a
	ret
; 0x444ef

Unnamed_444ef:
INCBIN "baserom.gbc",$444ef,$6

RockTunnel1Texts: ; 0x444f5
	dw RockTunnel1Text1, RockTunnel1Text2, RockTunnel1Text3, RockTunnel1Text4, RockTunnel1Text5, RockTunnel1Text6, RockTunnel1Text7, RockTunnel1Text8

Unnamed_44505:
INCBIN "baserom.gbc",$44505,$55

RockTunnel1Text1: ; 0x4455a
	db $8
	ld hl, $4505
	jr asm_0c916 ; 0x4455e $22

RockTunnel1Text2:
	db $8
	ld hl, $4511
	jr asm_0c916 ; 0x44564 $1c

RockTunnel1Text3:
	db $8
	ld hl, $451d
	jr asm_0c916 ; 0x4456a $16

RockTunnel1Text4:
	db $8
	ld hl, $4529
	jr asm_0c916 ; 0x44570 $10

RockTunnel1Text5:
	db $8
	ld hl, $4535
	jr asm_0c916 ; 0x44576 $a

RockTunnel1Text6:
	db $8
	ld hl, $4541
	jr asm_0c916 ; 0x4457c $4

RockTunnel1Text7:
	db $8
	ld hl, $454d
asm_0c916: ; 0x44582
	call $31cc
	jp TextScriptEnd

UnnamedText_44588: ; 0x44588
	TX_FAR _UnnamedText_44588
	db $50
; 0x44588 + 5 bytes

UnnamedText_4458d: ; 0x4458d
	TX_FAR _UnnamedText_4458d
	db $50
; 0x4458d + 5 bytes

UnnamedText_44592: ; 0x44592
	TX_FAR _UnnamedText_44592
	db $50
; 0x44592 + 5 bytes

UnnamedText_44597: ; 0x44597
	TX_FAR _UnnamedText_44597
	db $50
; 0x44597 + 5 bytes

UnnamedText_4459c: ; 0x4459c
	TX_FAR _UnnamedText_4459c
	db $50
; 0x4459c + 5 bytes

UnnamedText_445a1: ; 0x445a1
	TX_FAR _UnnamedText_445a1
	db $50
; 0x445a1 + 5 bytes

UnnamedText_445a6: ; 0x445a6
	TX_FAR _UnnamedText_445a6
	db $50
; 0x445a6 + 5 bytes

UnnamedText_445ab: ; 0x445ab
	TX_FAR _UnnamedText_445ab
	db $50
; 0x445ab + 5 bytes

UnnamedText_445b0: ; 0x445b0
	TX_FAR _UnnamedText_445b0
	db $50
; 0x445b0 + 5 bytes

UnnamedText_445b5: ; 0x445b5
	TX_FAR _UnnamedText_445b5
	db $50
; 0x445b5 + 5 bytes

UnnamedText_445ba: ; 0x445ba
	TX_FAR _UnnamedText_445ba
	db $50
; 0x445ba + 5 bytes

UnnamedText_445bf: ; 0x445bf
	TX_FAR _UnnamedText_445bf
	db $50
; 0x445bf + 5 bytes

UnnamedText_445c4: ; 0x445c4
	TX_FAR _UnnamedText_445c4
	db $50
; 0x445c4 + 5 bytes

UnnamedText_445c9: ; 0x445c9
	TX_FAR _UnnamedText_445c9
	db $50
; 0x445c9 + 5 bytes

UnnamedText_445ce: ; 0x445ce
	TX_FAR _UnnamedText_445ce
	db $50
; 0x445ce + 5 bytes

UnnamedText_445d3: ; 0x445d3
	TX_FAR _UnnamedText_445d3
	db $50
; 0x445d3 + 5 bytes

UnnamedText_445d8: ; 0x445d8
	TX_FAR _UnnamedText_445d8
	db $50
; 0x445d8 + 5 bytes

UnnamedText_445dd: ; 0x445dd
	TX_FAR _UnnamedText_445dd
	db $50
; 0x445dd + 5 bytes

UnnamedText_445e2: ; 0x445e2
	TX_FAR _UnnamedText_445e2
	db $50
; 0x445e2 + 5 bytes

UnnamedText_445e7: ; 0x445e7
	TX_FAR _UnnamedText_445e7
	db $50
; 0x445e7 + 5 bytes

UnnamedText_445ec: ; 0x445ec
	TX_FAR _UnnamedText_445ec
	db $50
; 0x445ec + 5 bytes

RockTunnel1Text8: ; 0x445f1
	TX_FAR _RockTunnel1Text8
	db $50

RockTunnel1Object: ; 0x445f6 (size=127)
	db $3 ; border tile

	db $8 ; warps
	db $3, $f, $1, $ff
	db $0, $f, $1, $ff
	db $21, $f, $2, $ff
	db $23, $f, $2, $ff
	db $3, $25, $0, ROCK_TUNNEL_2
	db $3, $5, $1, ROCK_TUNNEL_2
	db $b, $11, $2, ROCK_TUNNEL_2
	db $11, $25, $3, ROCK_TUNNEL_2

	db $1 ; signs
	db $1d, $b, $8 ; RockTunnel1Text8

	db $7 ; people
	db SPRITE_HIKER, $5 + 4, $7 + 4, $ff, $d0, $41, HIKER + $C8, $c ; trainer
	db SPRITE_HIKER, $10 + 4, $5 + 4, $ff, $d0, $42, HIKER + $C8, $d ; trainer
	db SPRITE_HIKER, $f + 4, $11 + 4, $ff, $d2, $43, HIKER + $C8, $e ; trainer
	db SPRITE_BLACK_HAIR_BOY_2, $8 + 4, $17 + 4, $ff, $d2, $44, POKEMANIAC + $C8, $7 ; trainer
	db SPRITE_LASS, $15 + 4, $25 + 4, $ff, $d2, $45, JR__TRAINER_F + $C8, $11 ; trainer
	db SPRITE_LASS, $18 + 4, $16 + 4, $ff, $d0, $46, JR__TRAINER_F + $C8, $12 ; trainer
	db SPRITE_LASS, $18 + 4, $20 + 4, $ff, $d3, $47, JR__TRAINER_F + $C8, $13 ; trainer

	; warp-to
	EVENT_DISP $14, $3, $f
	EVENT_DISP $14, $0, $f
	EVENT_DISP $14, $21, $f
	EVENT_DISP $14, $23, $f
	EVENT_DISP $14, $3, $25 ; ROCK_TUNNEL_2
	EVENT_DISP $14, $3, $5 ; ROCK_TUNNEL_2
	EVENT_DISP $14, $b, $11 ; ROCK_TUNNEL_2
	EVENT_DISP $14, $11, $25 ; ROCK_TUNNEL_2

RockTunnel1Blocks: ; 0x44675 360
	INCBIN "maps/rocktunnel1.blk"

SeafoamIslands1_h: ; 0x447dd to 0x447e9 (12 bytes) (bank=11) (id=192)
	db $11 ; tileset
	db SEAFOAM_ISLANDS_1_HEIGHT, SEAFOAM_ISLANDS_1_WIDTH ; dimensions (y, x)
	dw SeafoamIslands1Blocks, SeafoamIslands1Texts, SeafoamIslands1Script ; blocks, texts, scripts
	db $00 ; connections

	dw SeafoamIslands1Object ; objects

SeafoamIslands1Script: ; 0x447e9
	call $3c3c
	ld hl, $d7e7
	set 0, [hl]
	ld hl, $cd60
	bit 7, [hl]
	res 7, [hl]
	jr z, .asm_4483b ; 0x447f8 $41
	ld hl, SeafoamIslands1Script_Unknown44846
	call $34e4
	ret nc
	ld hl, $d7e8
	ld a, [$cd3d]
	cp $1
	jr nz, .asm_44819 ; 0x44809 $e
	set 6, [hl]
	ld a, $d7
	ld [$d079], a
	ld a, $d9
	ld [$d07a], a
	jr .asm_44825 ; 0x44817 $c
.asm_44819
	set 7, [hl]
	ld a, $d8
	ld [$d079], a
	ld a, $da
	ld [$d07a], a
.asm_44825
	ld a, [$d079]
	ld [$cc4d], a
	ld a, $11
	call Predef
	ld a, [$d07a]
	ld [$cc4d], a
	ld a, $15
	jp $3e6d
.asm_4483b
	ld a, $9f
	ld [$d71d], a
	ld hl, SeafoamIslands1Script_Unknown44846
	jp $6981
; 0x44846

SeafoamIslands1Script_Unknown44846: ; 0x44846
INCBIN "baserom.gbc",$44846,$5

SeafoamIslands1Texts: ; 0x4484b
	dw SeafoamIslands1Text1, SeafoamIslands1Text2

SeafoamIslands1Object: ; 0x4484f (size=72)
	db $7d ; border tile

	db $7 ; warps
	db $11, $4, $0, $ff
	db $11, $5, $0, $ff
	db $11, $1a, $1, $ff
	db $11, $1b, $1, $ff
	db $5, $7, $1, SEAFOAM_ISLANDS_2
	db $3, $19, $6, SEAFOAM_ISLANDS_2
	db $f, $17, $4, SEAFOAM_ISLANDS_2

	db $0 ; signs

	db $2 ; people
	db SPRITE_BOULDER, $a + 4, $12 + 4, $ff, $10, $1 ; person
	db SPRITE_BOULDER, $7 + 4, $1a + 4, $ff, $10, $2 ; person

	; warp-to
	EVENT_DISP $f, $11, $4
	EVENT_DISP $f, $11, $5
	EVENT_DISP $f, $11, $1a
	EVENT_DISP $f, $11, $1b
	EVENT_DISP $f, $5, $7 ; SEAFOAM_ISLANDS_2
	EVENT_DISP $f, $3, $19 ; SEAFOAM_ISLANDS_2
	EVENT_DISP $f, $f, $17 ; SEAFOAM_ISLANDS_2

INCBIN "baserom.gbc",$44897,$8

SeafoamIslands1Blocks: ; 0x4489f 135
	INCBIN "maps/seafoamislands1.blk"

SSAnne3_h: ; 0x44926 to 0x44932 (12 bytes) (bank=11) (id=97)
	db $0d ; tileset
	db SS_ANNE_3_HEIGHT, SS_ANNE_3_WIDTH ; dimensions (y, x)
	dw SSAnne3Blocks, SSAnne3Texts, SSAnne3Script ; blocks, texts, scripts
	db $00 ; connections

	dw SSAnne3Object ; objects

SSAnne3Script: ; 0x44932
	jp $3c3c
; 0x44935

SSAnne3Texts: ; 0x44935
	dw SSAnne3Text1

SSAnne3Text1: ; 0x44937
	TX_FAR _SSAnne3Text1
	db $50

SSAnne3Object: ; 0x4493c (size=26)
	db $c ; border tile

	db $2 ; warps
	db $3, $0, $0, SS_ANNE_5
	db $3, $13, $7, SS_ANNE_2

	db $0 ; signs

	db $1 ; people
	db SPRITE_SAILOR, $3 + 4, $9 + 4, $fe, $2, $1 ; person

	; warp-to
	EVENT_DISP $a, $3, $0 ; SS_ANNE_5
	EVENT_DISP $a, $3, $13 ; SS_ANNE_2

SSAnne3Blocks: ; 0x44956 30
	INCBIN "maps/ssanne3.blk"

VictoryRoad3_h: ; 0x44974 to 0x44980 (12 bytes) (bank=11) (id=198)
	db $11 ; tileset
	db VICTORY_ROAD_3_HEIGHT, VICTORY_ROAD_3_WIDTH ; dimensions (y, x)
	dw VictoryRoad3Blocks, VictoryRoad3Texts, VictoryRoad3Script ; blocks, texts, scripts
	db $00 ; connections

	dw VictoryRoad3Object ; objects

VictoryRoad3Script: ; 0x44980
	call VictoryRoad3Script_Unknown44996
	call $3c3c
	ld hl, VictoryRoad3TrainerHeaders
	ld de, $49b1
	ld a, [$d640]
	call $3160
	ld [$d640], a
	ret
; 0x44996

VictoryRoad3Script_Unknown44996: ; 0x44996
INCBIN "baserom.gbc",$44996,$8e

VictoryRoad3Texts: ; 0x44a24
	dw VictoryRoad3Text1, VictoryRoad3Text2, VictoryRoad3Text3, VictoryRoad3Text4, VictoryRoad3Text5, VictoryRoad3Text6, VictoryRoad3Text7, VictoryRoad3Text8, VictoryRoad3Text9, VictoryRoad3Text10

VictoryRoad3TrainerHeaders:
VictoryRoad3TrainerHeader0: ; 0x44a38
	db $1 ; flag's bit
	db ($1 << 4) ; trainer's view range
	dw $d813 ; flag's byte
	dw VictoryRoad3BattleText2 ; 0x4a91 TextBeforeBattle
	dw VictoryRoad3AfterBattleText2 ; 0x4a9b TextAfterBattle
	dw VictoryRoad3EndBattleText2 ; 0x4a96 TextEndBattle
	dw VictoryRoad3EndBattleText2 ; 0x4a96 TextEndBattle
; 0x44a44

VictoryRoad3TrainerHeader2: ; 0x44a44
	db $2 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d813 ; flag's byte
	dw VictoryRoad3BattleText3 ; 0x4aa0 TextBeforeBattle
	dw VictoryRoad3AfterBattleText3 ; 0x4aaa TextAfterBattle
	dw VictoryRoad3EndBattleText3 ; 0x4aa5 TextEndBattle
	dw VictoryRoad3EndBattleText3 ; 0x4aa5 TextEndBattle
; 0x44a50

VictoryRoad3TrainerHeader3: ; 0x44a50
	db $3 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d813 ; flag's byte
	dw VictoryRoad3BattleText4 ; 0x4aaf TextBeforeBattle
	dw VictoryRoad3AfterBattleText4 ; 0x4ab9 TextAfterBattle
	dw VictoryRoad3EndBattleText4 ; 0x4ab4 TextEndBattle
	dw VictoryRoad3EndBattleText4 ; 0x4ab4 TextEndBattle
; 0x44a5c

VictoryRoad3TrainerHeader4: ; 0x44a5c
	db $4 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d813 ; flag's byte
	dw VictoryRoad3BattleText5 ; 0x4abe TextBeforeBattle
	dw VictoryRoad3AfterBattleText5 ; 0x4ac8 TextAfterBattle
	dw VictoryRoad3EndBattleText5 ; 0x4ac3 TextEndBattle
	dw VictoryRoad3EndBattleText5 ; 0x4ac3 TextEndBattle
; 0x44a68

db $ff

VictoryRoad3Text1: ; 0x44a69
	db $08 ; asm
	ld hl, VictoryRoad3TrainerHeader0
	call LoadTrainerHeader
	jp TextScriptEnd

VictoryRoad3Text2: ; 0x44a73
	db $08 ; asm
	ld hl, VictoryRoad3TrainerHeader2
	call LoadTrainerHeader
	jp TextScriptEnd

VictoryRoad3Text3: ; 0x44a7d
	db $08 ; asm
	ld hl, VictoryRoad3TrainerHeader3
	call LoadTrainerHeader
	jp TextScriptEnd

VictoryRoad3Text4: ; 0x44a87
	db $08 ; asm
	ld hl, VictoryRoad3TrainerHeader4
	call LoadTrainerHeader
	jp TextScriptEnd

VictoryRoad3BattleText2: ; 0x44a91
	TX_FAR _VictoryRoad3BattleText2
	db $50
; 0x44a91 + 5 bytes

VictoryRoad3EndBattleText2: ; 0x44a96
	TX_FAR _VictoryRoad3EndBattleText2
	db $50
; 0x44a96 + 5 bytes

VictoryRoad3AfterBattleText2: ; 0x44a9b
	TX_FAR _VictoryRoad3AfterBattleText2
	db $50
; 0x44a9b + 5 bytes

VictoryRoad3BattleText3: ; 0x44aa0
	TX_FAR _VictoryRoad3BattleText3
	db $50
; 0x44aa0 + 5 bytes

VictoryRoad3EndBattleText3: ; 0x44aa5
	TX_FAR _VictoryRoad3EndBattleText3
	db $50
; 0x44aa5 + 5 bytes

VictoryRoad3AfterBattleText3: ; 0x44aaa
	TX_FAR _VictoryRoad3AfterBattleText3
	db $50
; 0x44aaa + 5 bytes

VictoryRoad3BattleText4: ; 0x44aaf
	TX_FAR _VictoryRoad3BattleText4
	db $50
; 0x44aaf + 5 bytes

VictoryRoad3EndBattleText4: ; 0x44ab4
	TX_FAR _VictoryRoad3EndBattleText4
	db $50
; 0x44ab4 + 5 bytes

VictoryRoad3AfterBattleText4: ; 0x44ab9
	TX_FAR _VictoryRoad3AfterBattleText4
	db $50
; 0x44ab9 + 5 bytes

VictoryRoad3BattleText5: ; 0x44abe
	TX_FAR _VictoryRoad3BattleText5
	db $50
; 0x44abe + 5 bytes

VictoryRoad3EndBattleText5: ; 0x44ac3
	TX_FAR _VictoryRoad3EndBattleText5
	db $50
; 0x44ac3 + 5 bytes

VictoryRoad3AfterBattleText5: ; 0x44ac8
	TX_FAR _VictoryRoad3AfterBattleText5
	db $50
; 0x44ac8 + 5 bytes

VictoryRoad3Object: ; 0x44acd (size=106)
	db $7d ; border tile

	db $4 ; warps
	db $7, $17, $3, VICTORY_ROAD_2
	db $8, $1a, $5, VICTORY_ROAD_2
	db $f, $1b, $4, VICTORY_ROAD_2
	db $0, $2, $6, VICTORY_ROAD_2

	db $0 ; signs

	db $a ; people
	db SPRITE_BLACK_HAIR_BOY_1, $5 + 4, $1c + 4, $ff, $d2, $41, COOLTRAINER_M + $C8, $2 ; trainer
	db SPRITE_LASS, $d + 4, $7 + 4, $ff, $d3, $42, COOLTRAINER_F + $C8, $2 ; trainer
	db SPRITE_BLACK_HAIR_BOY_1, $e + 4, $6 + 4, $ff, $d2, $43, COOLTRAINER_M + $C8, $3 ; trainer
	db SPRITE_LASS, $3 + 4, $d + 4, $ff, $d3, $44, COOLTRAINER_F + $C8, $3 ; trainer
	db SPRITE_BALL, $5 + 4, $1a + 4, $ff, $ff, $85, MAX_REVIVE ; item
	db SPRITE_BALL, $7 + 4, $7 + 4, $ff, $ff, $86, TM_47 ; item
	db SPRITE_BOULDER, $3 + 4, $16 + 4, $ff, $10, $7 ; person
	db SPRITE_BOULDER, $c + 4, $d + 4, $ff, $10, $8 ; person
	db SPRITE_BOULDER, $a + 4, $18 + 4, $ff, $10, $9 ; person
	db SPRITE_BOULDER, $f + 4, $16 + 4, $ff, $10, $a ; person

	; warp-to
	EVENT_DISP $f, $7, $17 ; VICTORY_ROAD_2
	EVENT_DISP $f, $8, $1a ; VICTORY_ROAD_2
	EVENT_DISP $f, $f, $1b ; VICTORY_ROAD_2
	EVENT_DISP $f, $0, $2 ; VICTORY_ROAD_2

VictoryRoad3Blocks: ; 0x44b37 135
	INCBIN "maps/victoryroad3.blk"

RocketHideout1_h: ; 0x44bbe to 0x44bca (12 bytes) (bank=11) (id=199)
	db $16 ; tileset
	db ROCKET_HIDEOUT_1_HEIGHT, ROCKET_HIDEOUT_1_WIDTH ; dimensions (y, x)
	dw RocketHideout1Blocks, RocketHideout1Texts, RocketHideout1Script ; blocks, texts, scripts
	db $00 ; connections

	dw RocketHideout1Object ; objects

RocketHideout1Script: ; 0x44bca
	call Unknown_44be0
	call $3c3c
	ld hl, RocketHideout1TrainerHeaders
	ld de, $4c0e
	ld a, [$d631]
	call $3160
	ld [$d631], a
	ret
; 0x44be0

Unknown_44be0: ; 0x44be0
INCBIN "baserom.gbc",$44be0,$34

RocketHideout1Texts: ; 0x44c14
	dw RocketHideout1Text1, RocketHideout1Text2, RocketHideout1Text3, RocketHideout1Text4, RocketHideout1Text5, RocketHideout1Text6, RocketHideout1Text7

RocketHideout1TrainerHeaders:
RocketHideout1TrainerHeader0: ; 0x44c22
	db $1 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d815 ; flag's byte
	dw RocketHideout1BattleText2 ; 0x4ca1 TextBeforeBattle
	dw RocketHideout1AfterBattleTxt2 ; 0x4cab TextAfterBattle
	dw RocketHideout1EndBattleText2 ; 0x4ca6 TextEndBattle
	dw RocketHideout1EndBattleText2 ; 0x4ca6 TextEndBattle
; 0x44c2e

RocketHideout1TrainerHeader2: ; 0x44c2e
	db $2 ; flag's bit
	db ($2 << 4) ; trainer's view range
	dw $d815 ; flag's byte
	dw RocketHideout1BattleText3 ; 0x4cb0 TextBeforeBattle
	dw RocketHideout1AfterBattleTxt3 ; 0x4cba TextAfterBattle
	dw RocketHideout1EndBattleText3 ; 0x4cb5 TextEndBattle
	dw RocketHideout1EndBattleText3 ; 0x4cb5 TextEndBattle
; 0x44c3a

RocketHideout1TrainerHeader3: ; 0x44c3a
	db $3 ; flag's bit
	db ($2 << 4) ; trainer's view range
	dw $d815 ; flag's byte
	dw RocketHideout1BattleText4 ; 0x4cbf TextBeforeBattle
	dw RocketHideout1AfterBattleTxt4 ; 0x4cc9 TextAfterBattle
	dw RocketHideout1EndBattleText4 ; 0x4cc4 TextEndBattle
	dw RocketHideout1EndBattleText4 ; 0x4cc4 TextEndBattle
; 0x44c46

RocketHideout1TrainerHeader4: ; 0x44c46
	db $4 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d815 ; flag's byte
	dw RocketHideout1BattleText5 ; 0x4cce TextBeforeBattle
	dw RocketHideout1AfterBattleTxt5 ; 0x4cd8 TextAfterBattle
	dw RocketHideout1EndBattleText5 ; 0x4cd3 TextEndBattle
	dw RocketHideout1EndBattleText5 ; 0x4cd3 TextEndBattle
; 0x44c52

RocketHideout1TrainerHeader5: ; 0x44c52
	db $5 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d815 ; flag's byte
	dw RocketHideout1BattleText6 ; 0x4cdd TextBeforeBattle
	dw RocketHideout1AfterBattleTxt6 ; 0x4ce2 TextAfterBattle
	dw RocketHideout1EndBattleText6 ; 0x4c91 TextEndBattle
	dw RocketHideout1EndBattleText6 ; 0x4c91 TextEndBattle
; 0x44c5e

db $ff

RocketHideout1Text1: ; 0x44c5f
	db $08 ; asm
	ld hl, RocketHideout1TrainerHeader0
	call LoadTrainerHeader
	jp TextScriptEnd

RocketHideout1Text2: ; 0x44c69
	db $08 ; asm
	ld hl, RocketHideout1TrainerHeader2
	call LoadTrainerHeader
	jp TextScriptEnd

RocketHideout1Text3: ; 0x44c73
	db $08 ; asm
	ld hl, RocketHideout1TrainerHeader3
	call LoadTrainerHeader
	jp TextScriptEnd

RocketHideout1Text4: ; 0x44c7d
	db $08 ; asm
	ld hl, RocketHideout1TrainerHeader4
	call LoadTrainerHeader
	jp TextScriptEnd

RocketHideout1Text5: ; 0x44c87
	db $08 ; asm
	ld hl, RocketHideout1TrainerHeader5
	call LoadTrainerHeader
	jp TextScriptEnd

RocketHideout1EndBattleText6: ; 0x44c91
	TX_FAR _RocketHideout1EndBattleText6 ; 0x81f2a
	db $8
	ld hl, $d815
	set 5, [hl]
	ld hl, UnnamedText_44c9f
	ret
; 0x44c9f

UnnamedText_44c9f: ; 0x44c9f
	db $6, $50
; 0x44ca1

RocketHideout1BattleText2: ; 0x44ca1
	TX_FAR _RocketHideout1BattleText2
	db $50
; 0x44ca1 + 5 bytes

RocketHideout1EndBattleText2: ; 0x44ca6
	TX_FAR _RocketHideout1EndBattleText2
	db $50
; 0x44ca6 + 5 bytes

RocketHideout1AfterBattleTxt2: ; 0x44cab
	TX_FAR _RocketHideout1AfterBattleTxt2
	db $50
; 0x44cab + 5 bytes

RocketHideout1BattleText3: ; 0x44cb0
	TX_FAR _RocketHideout1BattleText3
	db $50
; 0x44cb0 + 5 bytes

RocketHideout1EndBattleText3: ; 0x44cb5
	TX_FAR _RocketHideout1EndBattleText3
	db $50
; 0x44cb5 + 5 bytes

RocketHideout1AfterBattleTxt3: ; 0x44cba
	TX_FAR _RocketHideout1AfterBattleTxt3
	db $50
; 0x44cba + 5 bytes

RocketHideout1BattleText4: ; 0x44cbf
	TX_FAR _RocketHideout1BattleText4
	db $50
; 0x44cbf + 5 bytes

RocketHideout1EndBattleText4: ; 0x44cc4
	TX_FAR _RocketHideout1EndBattleText4
	db $50
; 0x44cc4 + 5 bytes

RocketHideout1AfterBattleTxt4: ; 0x44cc9
	TX_FAR _RocketHideout1AfterBattleTxt4
	db $50
; 0x44cc9 + 5 bytes

RocketHideout1BattleText5: ; 0x44cce
	TX_FAR _RocketHideout1BattleText5
	db $50
; 0x44cce + 5 bytes

RocketHideout1EndBattleText5: ; 0x44cd3
	TX_FAR _RocketHideout1EndBattleText5
	db $50
; 0x44cd3 + 5 bytes

RocketHideout1AfterBattleTxt5: ; 0x44cd8
	TX_FAR _RocketHideout1AfterBattleTxt5
	db $50
; 0x44cd8 + 5 bytes

RocketHideout1BattleText6: ; 0x44cdd
	TX_FAR _RocketHideout1BattleText6
	db $50
; 0x44cdd + 5 bytes

RocketHideout1AfterBattleTxt6: ; 0x44ce2
	TX_FAR _RocketHideout1AfterBattleTxt6
	db $50
; 0x44ce2 + 5 bytes

RocketHideout1Object: ; 0x44ce7 (size=98)
	db $2e ; border tile

	db $5 ; warps
	db $2, $17, $0, ROCKET_HIDEOUT_2
	db $2, $15, $2, GAME_CORNER
	db $13, $18, $0, ROCKET_HIDEOUT_ELEVATOR
	db $18, $15, $3, ROCKET_HIDEOUT_2
	db $13, $19, $1, ROCKET_HIDEOUT_ELEVATOR

	db $0 ; signs

	db $7 ; people
	db SPRITE_ROCKET, $8 + 4, $1a + 4, $ff, $d2, $41, ROCKET + $C8, $8 ; trainer
	db SPRITE_ROCKET, $6 + 4, $c + 4, $ff, $d3, $42, ROCKET + $C8, $9 ; trainer
	db SPRITE_ROCKET, $11 + 4, $12 + 4, $ff, $d0, $43, ROCKET + $C8, $a ; trainer
	db SPRITE_ROCKET, $19 + 4, $f + 4, $ff, $d3, $44, ROCKET + $C8, $b ; trainer
	db SPRITE_ROCKET, $12 + 4, $1c + 4, $ff, $d2, $45, ROCKET + $C8, $c ; trainer
	db SPRITE_BALL, $e + 4, $b + 4, $ff, $ff, $86, ESCAPE_ROPE ; item
	db SPRITE_BALL, $11 + 4, $9 + 4, $ff, $ff, $87, HYPER_POTION ; item

	; warp-to
	EVENT_DISP $f, $2, $17 ; ROCKET_HIDEOUT_2
	EVENT_DISP $f, $2, $15 ; GAME_CORNER
	EVENT_DISP $f, $13, $18 ; ROCKET_HIDEOUT_ELEVATOR
	EVENT_DISP $f, $18, $15 ; ROCKET_HIDEOUT_2
	EVENT_DISP $f, $13, $19 ; ROCKET_HIDEOUT_ELEVATOR

RocketHideout1Blocks: ; 0x44d49 210
	INCBIN "maps/rockethideout1.blk"

RocketHideout2_h: ; 0x44e1b to 0x44e27 (12 bytes) (bank=11) (id=200)
	db $16 ; tileset
	db ROCKET_HIDEOUT_2_HEIGHT, ROCKET_HIDEOUT_2_WIDTH ; dimensions (y, x)
	dw RocketHideout2Blocks, RocketHideout2Texts, RocketHideout2Script ; blocks, texts, scripts
	db $00 ; connections

	dw RocketHideout2Object ; objects

RocketHideout2Script: ; 0x44e27
	call $3c3c
	ld hl, RocketHideout2TrainerHeaders
	ld de, RocketHideout2_Unknown44e3a
	ld a, [$d632]
	call $3160
	ld [$d632], a
	ret
; 0x44e3a

RocketHideout2_Unknown44e3a: ; 0x44ea
INCBIN "baserom.gbc",$44e3a,$28d

RocketHideout2Texts: ; 0x450c7
	dw RocketHideout2Text1, RocketHideout2Text2, RocketHideout2Text3, RocketHideout2Text4, RocketHideout2Text5

RocketHideout2TrainerHeaders:
RocketHideout2TrainerHeader0: ; 0x450d1
	db $1 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d817 ; flag's byte
	dw RocketHideout2BattleText2 ; 0x50e8 TextBeforeBattle
	dw RocketHideout2AfterBattleTxt2 ; 0x50f2 TextAfterBattle
	dw RocketHideout2EndBattleText2 ; 0x50ed TextEndBattle
	dw RocketHideout2EndBattleText2 ; 0x50ed TextEndBattle
; 0x450dd

db $ff

RocketHideout2Text1: ; 0x450de
	db $08 ; asm
	ld hl, RocketHideout2TrainerHeader0
	call LoadTrainerHeader
	jp TextScriptEnd

RocketHideout2BattleText2: ; 0x450e8
	TX_FAR _RocketHideout2BattleText2
	db $50
; 0x450e8 + 5 bytes

RocketHideout2EndBattleText2: ; 0x450ed
	TX_FAR _RocketHideout2EndBattleText2
	db $50
; 0x450ed + 5 bytes

RocketHideout2AfterBattleTxt2: ; 0x450f2
	TX_FAR _RocketHideout2AfterBattleTxt2
	db $50
; 0x450f2 + 5 bytes

RocketHideout2Object: ; 0x450f7 (size=80)
	db $2e ; border tile

	db $5 ; warps
	db $8, $1b, $0, ROCKET_HIDEOUT_1
	db $8, $15, $0, ROCKET_HIDEOUT_3
	db $13, $18, $0, ROCKET_HIDEOUT_ELEVATOR
	db $16, $15, $3, ROCKET_HIDEOUT_1
	db $13, $19, $1, ROCKET_HIDEOUT_ELEVATOR

	db $0 ; signs

	db $5 ; people
	db SPRITE_ROCKET, $c + 4, $14 + 4, $ff, $d0, $41, ROCKET + $C8, $d ; trainer
	db SPRITE_BALL, $b + 4, $1 + 4, $ff, $ff, $82, MOON_STONE ; item
	db SPRITE_BALL, $8 + 4, $10 + 4, $ff, $ff, $83, NUGGET ; item
	db SPRITE_BALL, $c + 4, $6 + 4, $ff, $ff, $84, TM_07 ; item
	db SPRITE_BALL, $15 + 4, $3 + 4, $ff, $ff, $85, SUPER_POTION ; item

	; warp-to
	EVENT_DISP $f, $8, $1b ; ROCKET_HIDEOUT_1
	EVENT_DISP $f, $8, $15 ; ROCKET_HIDEOUT_3
	EVENT_DISP $f, $13, $18 ; ROCKET_HIDEOUT_ELEVATOR
	EVENT_DISP $f, $16, $15 ; ROCKET_HIDEOUT_1
	EVENT_DISP $f, $13, $19 ; ROCKET_HIDEOUT_ELEVATOR

RocketHideout2Blocks: ; 0x45147 210
	INCBIN "maps/rockethideout2.blk"

RocketHideout3_h: ; 0x45219 to 0x45225 (12 bytes) (bank=11) (id=201)
	db $16 ; tileset
	db ROCKET_HIDEOUT_3_HEIGHT, ROCKET_HIDEOUT_3_WIDTH ; dimensions (y, x)
	dw RocketHideout3Blocks, RocketHideout3Texts, RocketHideout3Script ; blocks, texts, scripts
	db $00 ; connections

	dw RocketHideout3Object ; objects

RocketHideout3Script: ; 0x45225
	call $3c3c
	ld hl, RocketHideout3TrainerHeaders
	ld de, RocketHideout3Script_Unknown45238
	ld a, [$d633]
	call $3160
	ld [$d633], a
	ret
; 0x45238

RocketHideout3Script_Unknown45238: ; 0x45238
INCBIN "baserom.gbc",$45238,$c2

RocketHideout3Texts: ; 0x452fa
	dw RocketHideout3Text1, RocketHideout3Text2, RocketHideout3Text3, RocketHideout3Text4

RocketHideout3TrainerHeaders:
RocketHideout3TrainerHeader0: ; 0x45302
	db $1 ; flag's bit
	db ($2 << 4) ; trainer's view range
	dw $d819 ; flag's byte
	dw RocketHideout3BattleText2 ; 0x5325 TextBeforeBattle
	dw RocketHideout3AfterBattleTxt2 ; 0x532f TextAfterBattle
	dw RocketHideout3EndBattleText2 ; 0x532a TextEndBattle
	dw RocketHideout3EndBattleText2 ; 0x532a TextEndBattle
; 0x4530e

RocketHideout3TrainerHeader2: ; 0x4530e
	db $2 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d819 ; flag's byte
	dw RocketHideout3BattleTxt ; 0x533e TextBeforeBattle
	dw RocketHideout3AfterBattleText3 ; 0x5348 TextAfterBattle
	dw RocketHideout3EndBattleText3 ; 0x5343 TextEndBattle
	dw RocketHideout3EndBattleText3 ; 0x5343 TextEndBattle
; 0x4531a

db $ff

RocketHideout3Text1: ; 0x4531b
	db $08 ; asm
	ld hl, RocketHideout3TrainerHeader0
	call LoadTrainerHeader
	jp TextScriptEnd

RocketHideout3BattleText2: ; 0x45325
	TX_FAR _RocketHideout3BattleText2
	db $50
; 0x45325 + 5 bytes

RocketHideout3EndBattleText2: ; 0x4532a
	TX_FAR _RocketHideout3EndBattleText2
	db $50
; 0x4532a + 5 bytes

RocketHideout3AfterBattleTxt2: ; 0x4532f
	TX_FAR _RocketHideout3AfterBattleTxt2
	db $50
; 0x4532f + 5 bytes

RocketHideout3Text2: ; 0x45334
	db $08 ; asm
	ld hl, RocketHideout3TrainerHeader2
	call LoadTrainerHeader
	jp TextScriptEnd

RocketHideout3BattleTxt: ; 0x4533e
	TX_FAR _RocketHideout3BattleTxt
	db $50
; 0x4533e + 5 bytes

RocketHideout3EndBattleText3: ; 0x45343
	TX_FAR _RocketHideout3EndBattleText3
	db $50
; 0x45343 + 5 bytes

RocketHideout3AfterBattleText3: ; 0x45348
	;TX_FAR _RocketHideout3AfterBattleText3
	db $17
	dw _RocketHideout3AfterBattleText3
	db BANK(_RocketHideout3AfterBattleText3)
	db $50
; 0x45348 + 5 bytes

RocketHideout3Object: ; 0x4534d (size=50)
	db $2e ; border tile

	db $2 ; warps
	db $6, $19, $1, ROCKET_HIDEOUT_2
	db $12, $13, $0, ROCKET_HIDEOUT_4

	db $0 ; signs

	db $4 ; people
	db SPRITE_ROCKET, $16 + 4, $a + 4, $ff, $d3, $41, ROCKET + $C8, $e ; trainer
	db SPRITE_ROCKET, $c + 4, $1a + 4, $ff, $d1, $42, ROCKET + $C8, $f ; trainer
	db SPRITE_BALL, $11 + 4, $1a + 4, $ff, $ff, $83, TM_10 ; item
	db SPRITE_BALL, $e + 4, $14 + 4, $ff, $ff, $84, RARE_CANDY ; item

	; warp-to
	EVENT_DISP $f, $6, $19 ; ROCKET_HIDEOUT_2
	EVENT_DISP $f, $12, $13 ; ROCKET_HIDEOUT_4

RocketHideout3Blocks: ; 0x4537f 210
	INCBIN "maps/rockethideout3.blk"

RocketHideout4_h: ; 0x45451 to 0x4545d (12 bytes) (bank=11) (id=202)
	db $16 ; tileset
	db ROCKET_HIDEOUT_4_HEIGHT, ROCKET_HIDEOUT_4_WIDTH ; dimensions (y, x)
	dw RocketHideout4Blocks, RocketHideout4Texts, RocketHideout4Script ; blocks, texts, scripts
	db $00 ; connections

	dw RocketHideout4Object ; objects

RocketHideout4Script: ; 0x4545d
	call Unnamed_45473
	call $3c3c
	ld hl, RocketHideout4TrainerHeader0
	ld de, $54ae
	ld a, [$d634]
	call $3160
	ld [$d634], a
	ret
; 0x45473

Unnamed_45473: ; 0x45473
INCBIN "baserom.gbc",$45473,$8e

RocketHideout4Texts: ; 0x45501
	dw RocketHideout4Text1, RocketHideout4Text2, RocketHideout4Text3, RocketHideout4Text4, RocketHideout4Text5, RocketHideout4Text6, RocketHideout4Text7, RocketHideout4Text8, RocketHideout4Text9, RocketHideout4Text10

RocketHideout4TrainerHeaders:
RocketHideout4TrainerHeader0: ; 0x45515
	db $2 ; flag's bit
	db ($0 << 4) ; trainer's view range
	dw $d81b ; flag's byte
	dw RocketHideout4BattleText2 ; 0x5593 TextBeforeBattle
	dw RocketHideout4AfterBattleText2 ; 0x559d TextAfterBattle
	dw RocketHideout4EndBattleText2 ; 0x5598 TextEndBattle
	dw RocketHideout4EndBattleText2 ; 0x5598 TextEndBattle
; 0x45521

RocketHideout4TrainerHeader2: ; 0x45521
	db $3 ; flag's bit
	db ($0 << 4) ; trainer's view range
	dw $d81b ; flag's byte
	dw RocketHideout4BattleText3 ; 0x55ac TextBeforeBattle
	dw RocketHideout4AfterBattleText3 ; 0x55b6 TextAfterBattle
	dw RocketHideout4EndBattleText3 ; 0x55b1 TextEndBattle
	dw RocketHideout4EndBattleText3 ; 0x55b1 TextEndBattle
; 0x4552d

RocketHideout4TrainerHeader3: ; 0x4552d
	db $4 ; flag's bit
	db ($1 << 4) ; trainer's view range
	dw $d81b ; flag's byte
	dw RocketHideout4BattleText4 ; 0x55c5 TextBeforeBattle
	dw RocketHideout4AfterBattleText4 ; 0x55cf TextAfterBattle
	dw RocketHideout4EndBattleText4 ; 0x55ca TextEndBattle
	dw RocketHideout4EndBattleText4 ; 0x55ca TextEndBattle
; 0x45539

db $ff

RocketHideout4Text1: ; 0x4553a
	db $08 ; asm
	ld a, [$d81b]
	bit 7, a
	jp nz, .asm_545571
	ld hl, UnnamedText_4557a
	call PrintText
	ld hl, $d72d
	set 6, [hl]
	set 7, [hl]
	ld hl, UnnamedText_4557f
	ld de, UnnamedText_4557f
	call $3354
	ldh a, [$8c]
	ld [$cf13], a
	call $336a
	call $32d7
	xor a
	ldh [$b4], a
	ld a, $3
	ld [$d634], a
	ld [$da39], a
	jr .asm_209f0 ; 0x4556f
.asm_545571
	ld hl, RocketHideout4Text10
	call PrintText
.asm_209f0 ; 0x45577
	jp TextScriptEnd

UnnamedText_4557a: ; 0x4557a
	TX_FAR _UnnamedText_4557a
	db $50
; 0x4557a + 5 bytes

UnnamedText_4557f: ; 0x4557f
	TX_FAR _UnnamedText_4557f
	db $50
; 0x4557f + 5 bytes

RocketHideout4Text10: ; 0x45584
	TX_FAR _UnnamedText_45584
	db $50
; 0x45584 + 5 bytes

RocketHideout4Text2: ; 0x45589
	db $08 ; asm
	ld hl, RocketHideout4TrainerHeader0
	call LoadTrainerHeader
	jp TextScriptEnd

RocketHideout4BattleText2: ; 0x45593
	TX_FAR _RocketHideout4BattleText2
	db $50
; 0x45593 + 5 bytes

RocketHideout4EndBattleText2: ; 0x45598
	TX_FAR _RocketHideout4EndBattleText2
	db $50
; 0x45598 + 5 bytes

RocketHideout4AfterBattleText2: ; 0x4559d
	;TX_FAR _RocketHideout4AfterBattleText2
	db $17
	dw _RocketHideout4AfterBattleText2
	db BANK(_RocketHideout4AfterBattleText2)
	db $50
; 0x4559d + 5 bytes

RocketHideout4Text3: ; 0x455a2
	db $08 ; asm
	ld hl, RocketHideout4TrainerHeader2
	call LoadTrainerHeader
	jp TextScriptEnd

RocketHideout4BattleText3: ; 0x455ac
	TX_FAR _RocketHideout4BattleText3
	db $50
; 0x455ac + 5 bytes

RocketHideout4EndBattleText3: ; 0x455b1
	TX_FAR _RocketHideout4EndBattleText3
	db $50
; 0x455b1 + 5 bytes

RocketHideout4AfterBattleText3: ; 0x455b6
	;TX_FAR _RocketHideout4AfterBattleText3
	db $17
	dw _RocketHideout4AfterBattleText3
	db BANK(_RocketHideout4AfterBattleText3)
	db $50
; 0x455b6 + 5 bytes

RocketHideout4Text4: ; 0x455bb
	db $08 ; asm
	ld hl, RocketHideout4TrainerHeader3
	call LoadTrainerHeader
	jp TextScriptEnd

RocketHideout4BattleText4: ; 0x455c5
	TX_FAR _RocketHideout4BattleText4
	db $50
; 0x455c5 + 5 bytes

RocketHideout4EndBattleText4: ; 0x455ca
	TX_FAR _RocketHideout4EndBattleText4
	db $50
; 0x455ca + 5 bytes

RocketHideout4AfterBattleText4: ; 0x455cf
	db $8
	ld hl, $55ec
	call PrintText
	ld hl, $d81b
	bit 6, [hl]
	set 6, [hl]
	jr nz, .asm_455e9 ; 0x455dd $a
	ld a, $88
	ld [$cc4d], a
	ld a, $15
	call Predef
.asm_455e9
	jp TextScriptEnd
; 0x455ec

UnnamedText_455ec: ; 0x455ec
	TX_FAR _UnnamedText_455ec
	db $50
; 0x455ec + 5 bytes

RocketHideout4Object: ; 0x455f1 (size=95)
	db $2e ; border tile

	db $3 ; warps
	db $a, $13, $1, ROCKET_HIDEOUT_3
	db $f, $18, $0, ROCKET_HIDEOUT_ELEVATOR
	db $f, $19, $1, ROCKET_HIDEOUT_ELEVATOR

	db $0 ; signs

	db $9 ; people
	db SPRITE_GIOVANNI, $3 + 4, $19 + 4, $ff, $d0, $41, GIOVANNI + $C8, $1 ; trainer
	db SPRITE_ROCKET, $c + 4, $17 + 4, $ff, $d0, $42, ROCKET + $C8, $10 ; trainer
	db SPRITE_ROCKET, $c + 4, $1a + 4, $ff, $d0, $43, ROCKET + $C8, $11 ; trainer
	db SPRITE_ROCKET, $2 + 4, $b + 4, $ff, $d0, $44, ROCKET + $C8, $12 ; trainer
	db SPRITE_BALL, $c + 4, $a + 4, $ff, $ff, $85, HP_UP ; item
	db SPRITE_BALL, $4 + 4, $9 + 4, $ff, $ff, $86, TM_02 ; item
	db SPRITE_BALL, $14 + 4, $c + 4, $ff, $ff, $87, IRON ; item
	db SPRITE_BALL, $2 + 4, $19 + 4, $ff, $ff, $88, SILPH_SCOPE ; item
	db SPRITE_BALL, $2 + 4, $a + 4, $ff, $ff, $89, LIFT_KEY ; item

	; warp-to
	EVENT_DISP $f, $a, $13 ; ROCKET_HIDEOUT_3
	EVENT_DISP $f, $f, $18 ; ROCKET_HIDEOUT_ELEVATOR
	EVENT_DISP $f, $f, $19 ; ROCKET_HIDEOUT_ELEVATOR

RocketHideout4Blocks: ; 0x45650 180
	INCBIN "maps/rockethideout4.blk"

RocketHideoutElevator_h: ; 0x45704 to 0x45710 (12 bytes) (bank=11) (id=203)
	db $12 ; tileset
	db ROCKET_HIDEOUT_ELEVATOR_HEIGHT, ROCKET_HIDEOUT_ELEVATOR_WIDTH ; dimensions (y, x)
	dw RocketHideoutElevatorBlocks, RocketHideoutElevatorTexts, RocketHideoutElevatorScript ; blocks, texts, scripts
	db $00 ; connections

	dw RocketHideoutElevatorObject ; objects

RocketHideoutElevatorScript: ; 0x45710
	ld hl, $d126
	bit 5, [hl]
	res 5, [hl]
	push hl
	call nz, RocketHideoutElevatorScript_Unknown4572c
	pop hl
	bit 7, [hl]
	res 7, [hl]
	call nz, $575f
	xor a
	ld [$cf0c], a
	inc a
	ld [$cc3c], a
	ret
; 0x4572c

RocketHideoutElevatorScript_Unknown4572c: ; 0x4572c
INCBIN "baserom.gbc",$4572c,$3f

RocketHideoutElevatorTexts: ; 0x4576b
	dw RocketHideoutElevatorText1

RocketHideoutElevatorText1: ; 0x4576d
	db $08 ; asm
	ld b, LIFT_KEY
	call $3493
	jr z, .asm_8d8f0 ; 0x45773
	call $5741
	ld hl, $5759
	ld a, $61
	call Predef
	jr .asm_46c43 ; 0x45780
.asm_8d8f0 ; 0x45782
	ld hl, UnnamedText_4578b
	call PrintText
.asm_46c43 ; 0x45788
	jp TextScriptEnd

UnnamedText_4578b: ; 0x4578b
	TX_FAR _UnnamedText_4578b ; 0x82438
	db $d, $50

RocketHideoutElevatorObject: ; 0x45791 (size=23)
	db $f ; border tile

	db $2 ; warps
	db $1, $2, $2, ROCKET_HIDEOUT_1
	db $1, $3, $4, ROCKET_HIDEOUT_1

	db $1 ; signs
	db $1, $1, $1 ; RocketHideoutElevatorText1

	db $0 ; people

	; warp-to
	EVENT_DISP $3, $1, $2 ; ROCKET_HIDEOUT_1
	EVENT_DISP $3, $1, $3 ; ROCKET_HIDEOUT_1

RocketHideoutElevatorBlocks: ; 0x457a8 12
	INCBIN "maps/rockethideoutelevator.blk"

SilphCoElevator_h: ; 0x457b4 to 0x457c0 (12 bytes) (bank=11) (id=236)
	db $12 ; tileset
	db SILPH_CO_ELEVATOR_HEIGHT, SILPH_CO_ELEVATOR_WIDTH ; dimensions (y, x)
	dw SilphCoElevatorBlocks, SilphCoElevatorTexts, SilphCoElevatorScript ; blocks, texts, scripts
	db $00 ; connections

	dw SilphCoElevatorObject ; objects

SilphCoElevatorScript: ; 0x457c0
	ld hl, $d126
	bit 5, [hl]
	res 5, [hl]
	push hl
	call nz, SilphCoElevatorScript_Unknown457dc
	pop hl
	bit 7, [hl]
	res 7, [hl]
	call nz, $5827
	xor a
	ld [$cf0c], a
	inc a
	ld [$cc3c], a
	ret
; 0x457dc

SilphCoElevatorScript_Unknown457dc: ; 0x457dc
INCBIN "baserom.gbc",$457dc,$57

SilphCoElevatorTexts: ; 0x45833
	dw SilphCoElevatorText1

SilphCoElevatorText1: ; 0x45835
	db $08 ; asm
	call $57f1
	ld hl, $5811
	ld a, $61
	call Predef
	jp TextScriptEnd

SilphCoElevatorObject: ; 0x45844 (size=23)
	db $f ; border tile

	db $2 ; warps
	db $3, $1, $0, $ed
	db $3, $2, $0, $ed

	db $1 ; signs
	db $0, $3, $1 ; SilphCoElevatorText1

	db $0 ; people

	; warp-to
	EVENT_DISP $2, $3, $1
	EVENT_DISP $2, $3, $2

SilphCoElevatorBlocks: ; 0x4585b 4
	INCBIN "maps/silphcoelevator.blk"

SafariZoneEast_h: ; 0x4585f to 0x4586b (12 bytes) (bank=11) (id=217)
	db $03 ; tileset
	db SAFARI_ZONE_EAST_HEIGHT, SAFARI_ZONE_EAST_WIDTH ; dimensions (y, x)
	dw SafariZoneEastBlocks, SafariZoneEastTexts, SafariZoneEastScript ; blocks, texts, scripts
	db $00 ; connections

	dw SafariZoneEastObject ; objects

SafariZoneEastScript: ; 0x4586b
	jp $3c3c
; 0x4586e

SafariZoneEastTexts: ; 0x4586e
	dw SafariZoneEastText1, SafariZoneEastText2, SafariZoneEastText3, SafariZoneEastText4, SafariZoneEastText5, SafariZoneEastText6, SafariZoneEastText7

SafariZoneEastText5: ; 0x4587c
	TX_FAR _SafariZoneEastText5
	db $50

SafariZoneEastText6: ; 0x45881
	TX_FAR _SafariZoneEastText6
	db $50

SafariZoneEastText7: ; 0x45886
	TX_FAR _SafariZoneEastText7
	db $50

SafariZoneEastObject: ; 0x4588b (size=81)
	db $0 ; border tile

	db $5 ; warps
	db $4, $0, $6, SAFARI_ZONE_NORTH
	db $5, $0, $7, SAFARI_ZONE_NORTH
	db $16, $0, $6, SAFARI_ZONE_CENTER
	db $17, $0, $6, SAFARI_ZONE_CENTER
	db $9, $19, $0, SAFARI_ZONE_REST_HOUSE_3

	db $3 ; signs
	db $a, $1a, $5 ; SafariZoneEastText5
	db $4, $6, $6 ; SafariZoneEastText6
	db $17, $5, $7 ; SafariZoneEastText7

	db $4 ; people
	db SPRITE_BALL, $a + 4, $15 + 4, $ff, $ff, $81, FULL_RESTORE ; item
	db SPRITE_BALL, $7 + 4, $3 + 4, $ff, $ff, $82, MAX_POTION ; item
	db SPRITE_BALL, $d + 4, $14 + 4, $ff, $ff, $83, CARBOS ; item
	db SPRITE_BALL, $c + 4, $f + 4, $ff, $ff, $84, TM_37 ; item

	; warp-to
	EVENT_DISP $f, $4, $0 ; SAFARI_ZONE_NORTH
	EVENT_DISP $f, $5, $0 ; SAFARI_ZONE_NORTH
	EVENT_DISP $f, $16, $0 ; SAFARI_ZONE_CENTER
	EVENT_DISP $f, $17, $0 ; SAFARI_ZONE_CENTER
	EVENT_DISP $f, $9, $19 ; SAFARI_ZONE_REST_HOUSE_3

SafariZoneEastBlocks: ; 0x458dc 195
	INCBIN "maps/safarizoneeast.blk"

SafariZoneNorth_h: ; 0x4599f to 0x459ab (12 bytes) (bank=11) (id=218)
	db $03 ; tileset
	db SAFARI_ZONE_NORTH_HEIGHT, SAFARI_ZONE_NORTH_WIDTH ; dimensions (y, x)
	dw SafariZoneNorthBlocks, SafariZoneNorthTexts, SafariZoneNorthScript ; blocks, texts, scripts
	db $00 ; connections

	dw SafariZoneNorthObject ; objects

SafariZoneNorthScript: ; 0x459ab
	jp $3c3c
; 0x459ae

SafariZoneNorthTexts: ; 0x459ae
	dw SafariZoneNorthText1, SafariZoneNorthText2, SafariZoneNorthText3, SafariZoneNorthText4, SafariZoneNorthText5, SafariZoneNorthText6, SafariZoneNorthText7

SafariZoneNorthText3: ; 0x459bc
	TX_FAR _SafariZoneNorthText3
	db $50

SafariZoneNorthText4: ; 0x459c1
	TX_FAR _SafariZoneNorthText4
	db $50

SafariZoneNorthText5: ; 0x459c6
	TX_FAR _SafariZoneNorthText5
	db $50

SafariZoneNorthText6: ; 0x459cb
	TX_FAR _SafariZoneNorthText6
	db $50

SafariZoneNorthText7: ; 0x459d0
	TX_FAR _SafariZoneNorthText7
	db $50

SafariZoneNorthObject: ; 0x459d5 (size=105)
	db $0 ; border tile

	db $9 ; warps
	db $23, $2, $0, SAFARI_ZONE_WEST
	db $23, $3, $1, SAFARI_ZONE_WEST
	db $23, $8, $2, SAFARI_ZONE_WEST
	db $23, $9, $3, SAFARI_ZONE_WEST
	db $23, $14, $4, SAFARI_ZONE_CENTER
	db $23, $15, $5, SAFARI_ZONE_CENTER
	db $1e, $27, $0, SAFARI_ZONE_EAST
	db $1f, $27, $1, SAFARI_ZONE_EAST
	db $3, $23, $0, SAFARI_ZONE_REST_HOUSE_4

	db $5 ; signs
	db $4, $24, $3 ; SafariZoneNorthText3
	db $19, $4, $4 ; SafariZoneNorthText4
	db $1f, $d, $5 ; SafariZoneNorthText5
	db $21, $13, $6 ; SafariZoneNorthText6
	db $1c, $1a, $7 ; SafariZoneNorthText7

	db $2 ; people
	db SPRITE_BALL, $1 + 4, $19 + 4, $ff, $ff, $81, PROTEIN ; item
	db SPRITE_BALL, $7 + 4, $13 + 4, $ff, $ff, $82, TM_40 ; item

	; warp-to
	EVENT_DISP $14, $23, $2 ; SAFARI_ZONE_WEST
	EVENT_DISP $14, $23, $3 ; SAFARI_ZONE_WEST
	EVENT_DISP $14, $23, $8 ; SAFARI_ZONE_WEST
	EVENT_DISP $14, $23, $9 ; SAFARI_ZONE_WEST
	EVENT_DISP $14, $23, $14 ; SAFARI_ZONE_CENTER
	EVENT_DISP $14, $23, $15 ; SAFARI_ZONE_CENTER
	EVENT_DISP $14, $1e, $27 ; SAFARI_ZONE_EAST
	EVENT_DISP $14, $1f, $27 ; SAFARI_ZONE_EAST
	EVENT_DISP $14, $3, $23 ; SAFARI_ZONE_REST_HOUSE_4

SafariZoneNorthBlocks: ; 0x45a3e 360
	INCBIN "maps/safarizonenorth.blk"

SafariZoneCenter_h: ; 0x45ba6 to 0x45bb2 (12 bytes) (bank=11) (id=220)
	db $03 ; tileset
	db SAFARI_ZONE_CENTER_HEIGHT, SAFARI_ZONE_CENTER_WIDTH ; dimensions (y, x)
	dw SafariZoneCenterBlocks, SafariZoneCenterTexts, SafariZoneCenterScript ; blocks, texts, scripts
	db $00 ; connections

	dw SafariZoneCenterObject ; objects

SafariZoneCenterScript: ; 0x45bb2
	jp $3c3c
; 0x45bb5

SafariZoneCenterTexts: ; 0x45bb5
	dw SafariZoneCenterText1, SafariZoneCenterText2, SafariZoneCenterText3

SafariZoneCenterText2: ; 0x45bbb
	TX_FAR _SafariZoneCenterText2
	db $50

SafariZoneCenterText3: ; 0x45bc0
	TX_FAR _SafariZoneCenterText3
	db $50

SafariZoneCenterObject: ; 0x45bc5 (size=89)
	db $0 ; border tile

	db $9 ; warps
	db $19, $e, $2, SAFARIZONEENTRANCE
	db $19, $f, $3, SAFARIZONEENTRANCE
	db $a, $0, $4, SAFARI_ZONE_WEST
	db $b, $0, $5, SAFARI_ZONE_WEST
	db $0, $e, $4, SAFARI_ZONE_NORTH
	db $0, $f, $5, SAFARI_ZONE_NORTH
	db $a, $1d, $2, SAFARI_ZONE_EAST
	db $b, $1d, $3, SAFARI_ZONE_EAST
	db $13, $11, $0, SAFARI_ZONE_REST_HOUSE_1

	db $2 ; signs
	db $14, $12, $2 ; SafariZoneCenterText2
	db $16, $e, $3 ; SafariZoneCenterText3

	db $1 ; people
	db SPRITE_BALL, $a + 4, $e + 4, $ff, $ff, $81, NUGGET ; item

	; warp-to
	EVENT_DISP $f, $19, $e ; SAFARIZONEENTRANCE
	EVENT_DISP $f, $19, $f ; SAFARIZONEENTRANCE
	EVENT_DISP $f, $a, $0 ; SAFARI_ZONE_WEST
	EVENT_DISP $f, $b, $0 ; SAFARI_ZONE_WEST
	EVENT_DISP $f, $0, $e ; SAFARI_ZONE_NORTH
	EVENT_DISP $f, $0, $f ; SAFARI_ZONE_NORTH
	EVENT_DISP $f, $a, $1d ; SAFARI_ZONE_EAST
	EVENT_DISP $f, $b, $1d ; SAFARI_ZONE_EAST
	EVENT_DISP $f, $13, $11 ; SAFARI_ZONE_REST_HOUSE_1

SafariZoneCenterBlocks: ; 0x45c1e 195
	INCBIN "maps/safarizonecenter.blk"

SafariZoneRestHouse1_h: ; 0x45ce1 to 0x45ced (12 bytes) (bank=11) (id=221)
	db $0c ; tileset
	db SAFARI_ZONE_REST_HOUSE_1_HEIGHT, SAFARI_ZONE_REST_HOUSE_1_WIDTH ; dimensions (y, x)
	dw SafariZoneRestHouse1Blocks, SafariZoneRestHouse1Texts, SafariZoneRestHouse1Script ; blocks, texts, scripts
	db $00 ; connections

	dw SafariZoneRestHouse1Object ; objects

SafariZoneRestHouse1Script: ; 0x45ced
	jp $3c3c
; 0x45cf0

SafariZoneRestHouse1Texts: ; 0x45cf0
	dw SafariZoneRestHouse1Text1, SafariZoneRestHouse1Text2

SafariZoneRestHouse1Text1: ; 0x45cf4
	TX_FAR _SafariZoneRestHouse1Text1
	db $50

SafariZoneRestHouse1Text2: ; 0x45cf9
	TX_FAR _SafariZoneRestHouse1Text2
	db $50

SafariZoneRestHouse1Object: ; 0x45cfe (size=32)
	db $a ; border tile

	db $2 ; warps
	db $7, $2, $8, SAFARI_ZONE_CENTER
	db $7, $3, $8, SAFARI_ZONE_CENTER

	db $0 ; signs

	db $2 ; people
	db SPRITE_GIRL, $2 + 4, $3 + 4, $ff, $d0, $1 ; person
	db SPRITE_OAK_AIDE, $4 + 4, $1 + 4, $fe, $1, $2 ; person

	; warp-to
	EVENT_DISP $4, $7, $2 ; SAFARI_ZONE_CENTER
	EVENT_DISP $4, $7, $3 ; SAFARI_ZONE_CENTER

SafariZoneRestHouse2_h: ; 0x45d1e to 0x45d2a (12 bytes) (bank=11) (id=223)
	db $0c ; tileset
	db SAFARI_ZONE_REST_HOUSE_2_HEIGHT, SAFARI_ZONE_REST_HOUSE_2_WIDTH ; dimensions (y, x)
	dw $40fb, SafariZoneRestHouse2Texts, SafariZoneRestHouse2Script ; blocks, texts, scripts
	db $00 ; connections

	dw SafariZoneRestHouse2Object ; objects

SafariZoneRestHouse2Script: ; 0x45d2a
	call $3c3c
	ret
; 0x45d2e

SafariZoneRestHouse2Texts: ; 0x45d2e
	dw SafariZoneRestHouse2Text1, SafariZoneRestHouse2Text2, SafariZoneRestHouse2Text3

SafariZoneRestHouse2Text1: ; 0x45d34
	TX_FAR _SafariZoneRestHouse2Text1
	db $50

SafariZoneRestHouse2Text2: ; 0x45d39
	TX_FAR _SafariZoneRestHouse2Text2
	db $50

SafariZoneRestHouse2Text3: ; 0x45d3e
	TX_FAR _SafariZoneRestHouse2Text3
	db $50

SafariZoneRestHouse2Object: ; 0x45d43 (size=38)
	db $a ; border tile

	db $2 ; warps
	db $7, $2, $7, SAFARI_ZONE_WEST
	db $7, $3, $7, SAFARI_ZONE_WEST

	db $0 ; signs

	db $3 ; people
	db SPRITE_OAK_AIDE, $4 + 4, $4 + 4, $fe, $0, $1 ; person
	db SPRITE_BLACK_HAIR_BOY_1, $2 + 4, $0 + 4, $ff, $d3, $2 ; person
	db SPRITE_ERIKA, $2 + 4, $6 + 4, $ff, $d0, $3 ; person

	; warp-to
	EVENT_DISP $4, $7, $2 ; SAFARI_ZONE_WEST
	EVENT_DISP $4, $7, $3 ; SAFARI_ZONE_WEST

SafariZoneRestHouse3_h: ; 0x45d69 to 0x45d75 (12 bytes) (bank=11) (id=224)
	db $0c ; tileset
	db SAFARI_ZONE_REST_HOUSE_3_HEIGHT, SAFARI_ZONE_REST_HOUSE_3_WIDTH ; dimensions (y, x)
	dw $40fb, SafariZoneRestHouse3Texts, SafariZoneRestHouse3Script ; blocks, texts, scripts
	db $00 ; connections

	dw SafariZoneRestHouse3Object ; objects

SafariZoneRestHouse3Script: ; 0x45d75
	call $3c3c
	ret
; 0x45d79

SafariZoneRestHouse3Texts: ; 0x45d79
	dw SafariZoneRestHouse3Text1, SafariZoneRestHouse3Text2, SafariZoneRestHouse3Text3

SafariZoneRestHouse3Text1: ; 0x45d7f
	TX_FAR _SafariZoneRestHouse3Text1
	db $50

SafariZoneRestHouse3Text2: ; 0x45d84
	TX_FAR _SafariZoneRestHouse3Text2
	db $50

SafariZoneRestHouse3Text3: ; 0x45d89
	TX_FAR _SafariZoneRestHouse3Text3
	db $50

SafariZoneRestHouse3Object: ; 0x45d8e (size=38)
	db $a ; border tile

	db $2 ; warps
	db $7, $2, $4, SAFARI_ZONE_EAST
	db $7, $3, $4, SAFARI_ZONE_EAST

	db $0 ; signs

	db $3 ; people
	db SPRITE_OAK_AIDE, $3 + 4, $1 + 4, $fe, $1, $1 ; person
	db SPRITE_ROCKER, $2 + 4, $4 + 4, $ff, $ff, $2 ; person
	db SPRITE_LAPRAS_GIVER, $2 + 4, $5 + 4, $ff, $ff, $3 ; person

	; warp-to
	EVENT_DISP $4, $7, $2 ; SAFARI_ZONE_EAST
	EVENT_DISP $4, $7, $3 ; SAFARI_ZONE_EAST

SafariZoneRestHouse4_h: ; 0x45db4 to 0x45dc0 (12 bytes) (bank=11) (id=225)
	db $0c ; tileset
	db SAFARI_ZONE_REST_HOUSE_4_HEIGHT, SAFARI_ZONE_REST_HOUSE_4_WIDTH ; dimensions (y, x)
	dw $40fb, SafariZoneRestHouse4Texts, SafariZoneRestHouse4Script ; blocks, texts, scripts
	db $00 ; connections

	dw SafariZoneRestHouse4Object ; objects

SafariZoneRestHouse4Script: ; 0x45dc0
	call $3c3c
	ret
; 0x45dc4

SafariZoneRestHouse4Texts: ; 0x45dc4
	dw SafariZoneRestHouse4Text1, SafariZoneRestHouse4Text2, SafariZoneRestHouse4Text3

SafariZoneRestHouse4Text1: ; 0x45dca
	TX_FAR _SafariZoneRestHouse4Text1
	db $50

SafariZoneRestHouse4Text2: ; 0x45dcf
	TX_FAR _SafariZoneRestHouse4Text2
	db $50

SafariZoneRestHouse4Text3: ; 0x45dd4
	TX_FAR _SafariZoneRestHouse4Text3
	db $50

SafariZoneRestHouse4Object: ; 0x45dd9 (size=38)
	db $a ; border tile

	db $2 ; warps
	db $7, $2, $8, SAFARI_ZONE_NORTH
	db $7, $3, $8, SAFARI_ZONE_NORTH

	db $0 ; signs

	db $3 ; people
	db SPRITE_OAK_AIDE, $3 + 4, $6 + 4, $fe, $2, $1 ; person
	db SPRITE_WHITE_PLAYER, $4 + 4, $3 + 4, $ff, $ff, $2 ; person
	db SPRITE_GENTLEMAN, $5 + 4, $1 + 4, $fe, $1, $3 ; person

	; warp-to
	EVENT_DISP $4, $7, $2 ; SAFARI_ZONE_NORTH
	EVENT_DISP $4, $7, $3 ; SAFARI_ZONE_NORTH

UnknownDungeon2_h: ; 0x45dff to 0x45e0b (12 bytes) (bank=11) (id=226)
	db $11 ; tileset
	db UNKNOWN_DUNGEON_2_HEIGHT, UNKNOWN_DUNGEON_2_WIDTH ; dimensions (y, x)
	dw UnknownDungeon2Blocks, UnknownDungeon2Texts, UnknownDungeon2Script ; blocks, texts, scripts
	db $00 ; connections

	dw UnknownDungeon2Object ; objects

UnknownDungeon2Script: ; 0x45e0b
	jp $3c3c
; 0x45e0e

UnknownDungeon2Texts: ; 0x45e0e
	dw UnknownDungeon2Text1, UnknownDungeon2Text2, UnknownDungeon2Text3

UnknownDungeon2Object: ; 0x45e14 (size=73)
	db $7d ; border tile

	db $6 ; warps
	db $1, $1d, $2, UNKNOWN_DUNGEON_1
	db $6, $16, $3, UNKNOWN_DUNGEON_1
	db $7, $13, $4, UNKNOWN_DUNGEON_1
	db $1, $9, $5, UNKNOWN_DUNGEON_1
	db $3, $1, $6, UNKNOWN_DUNGEON_1
	db $b, $3, $7, UNKNOWN_DUNGEON_1

	db $0 ; signs

	db $3 ; people
	db SPRITE_BALL, $9 + 4, $1d + 4, $ff, $ff, $81, PP_UP ; item
	db SPRITE_BALL, $f + 4, $4 + 4, $ff, $ff, $82, ULTRA_BALL ; item
	db SPRITE_BALL, $6 + 4, $d + 4, $ff, $ff, $83, FULL_RESTORE ; item

	; warp-to
	EVENT_DISP $f, $1, $1d ; UNKNOWN_DUNGEON_1
	EVENT_DISP $f, $6, $16 ; UNKNOWN_DUNGEON_1
	EVENT_DISP $f, $7, $13 ; UNKNOWN_DUNGEON_1
	EVENT_DISP $f, $1, $9 ; UNKNOWN_DUNGEON_1
	EVENT_DISP $f, $3, $1 ; UNKNOWN_DUNGEON_1
	EVENT_DISP $f, $b, $3 ; UNKNOWN_DUNGEON_1

UnknownDungeon2Blocks: ; 0x45e5d 135
	INCBIN "maps/unknowndungeon2.blk"

UnknownDungeon3_h: ; 0x45ee4 to 0x45ef0 (12 bytes) (bank=11) (id=227)
	db $11 ; tileset
	db UNKNOWN_DUNGEON_3_HEIGHT, UNKNOWN_DUNGEON_3_WIDTH ; dimensions (y, x)
	dw UnknownDungeon3Blocks, UnknownDungeon3Texts, UnknownDungeon3Script ; blocks, texts, scripts
	db $00 ; connections

	dw UnknownDungeon3Object ; objects

UnknownDungeon3Script: ; 0x45ef0
	call $3c3c
	ld hl, UnknownDungeon3TrainerHeaders
	ld de, UnknownDungeon3Script_Unknown45f03
	ld a, [$d650]
	call $3160
	ld [$d650], a
	ret
; 0x45f03

UnknownDungeon3Script_Unknown45f03: ; 0x45f03
INCBIN "baserom.gbc",$45f03,$6

UnknownDungeon3Texts: ; 0x45f09
	dw UnknownDungeon3Text1, UnknownDungeon3Text2, UnknownDungeon3Text3

UnknownDungeon3TrainerHeaders:
UnknownDungeon3TrainerHeader0: ; 0x45f0f
	db $1 ; flag's bit
	db ($0 << 4) ; trainer's view range
	dw $d85f ; flag's byte
	dw UnknownDungeon3MewtwoText ; 0x5f26 TextBeforeBattle
	dw UnknownDungeon3MewtwoText ; 0x5f26 TextAfterBattle
	dw UnknownDungeon3MewtwoText ; 0x5f26 TextEndBattle
	dw UnknownDungeon3MewtwoText ; 0x5f26 TextEndBattle
; 0x45f1b

db $ff

UnknownDungeon3Text1: ; 0x45f1c
	db $08 ; asm
	ld hl, UnknownDungeon3TrainerHeader0
	call LoadTrainerHeader
	jp TextScriptEnd

UnknownDungeon3MewtwoText: ; 0x45f26
	TX_FAR _UnknownDungeon3MewtwoText ; 0x85c72
	db $8
	ld a, $83
	call $13d0
	call $3748
	jp TextScriptEnd
; 0x45f36

UnknownDungeon3Object: ; 0x45f36 (size=34)
	db $7d ; border tile

	db $1 ; warps
	db $6, $3, $8, UNKNOWN_DUNGEON_1

	db $0 ; signs

	db $3 ; people
	db SPRITE_SLOWBRO, $d + 4, $1b + 4, $ff, $d0, $41, MEWTWO, $46 ; trainer
	db SPRITE_BALL, $9 + 4, $10 + 4, $ff, $ff, $82, ULTRA_BALL ; item
	db SPRITE_BALL, $1 + 4, $12 + 4, $ff, $ff, $83, MAX_REVIVE ; item

	; warp-to
	EVENT_DISP $f, $6, $3 ; UNKNOWN_DUNGEON_1

UnknownDungeon3Blocks: ; 0x45f58 135
	INCBIN "maps/unknowndungeon3.blk"

RockTunnel2_h: ; 0x45fdf to 0x45feb (12 bytes) (bank=11) (id=232)
	db $11 ; tileset
	db ROCK_TUNNEL_2_HEIGHT, ROCK_TUNNEL_2_WIDTH ; dimensions (y, x)
	dw RockTunnel2Blocks, RockTunnel2Texts, RockTunnel2Script ; blocks, texts, scripts
	db $00 ; connections

	dw RockTunnel2Object ; objects

RockTunnel2Script: ; 0x45feb
	call $3c3c
	ld hl, RockTunnel2TrainerHeaders
	ld de, RockTunnel2Script_Unknown45ffe
	ld a, [$d620]
	call $3160
	ld [$d620], a
	ret
; 0x45ffe

RockTunnel2Script_Unknown45ffe: ; 0x45ffe
INCBIN "baserom.gbc",$45ffe,$6

RockTunnel2Texts: ; 0x46004
	dw RockTunnel2Text1, RockTunnel2Text2, RockTunnel2Text3, RockTunnel2Text4, RockTunnel2Text5, RockTunnel2Text6, RockTunnel2Text7, RockTunnel2Text8

RockTunnel2TrainerHeaders:
RockTunnel2TrainerHeader0: ; 0x46014
	db $1 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d87d ; flag's byte
	dw RockTunnel2BattleText2 ; 0x60c5 TextBeforeBattle
	dw RockTunnel2AfterBattleText2 ; 0x60cf TextAfterBattle
	dw RockTunnel2EndBattleText2 ; 0x60ca TextEndBattle
	dw RockTunnel2EndBattleText2 ; 0x60ca TextEndBattle
; 0x46020

RockTunnel2TrainerHeader2: ; 0x46020
	db $2 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d87d ; flag's byte
	dw RockTunnel2BattleText3 ; 0x60d4 TextBeforeBattle
	dw RockTunnel2AfterBattleText3 ; 0x60de TextAfterBattle
	dw RockTunnel2EndBattleText3 ; 0x60d9 TextEndBattle
	dw RockTunnel2EndBattleText3 ; 0x60d9 TextEndBattle
; 0x4602c

RockTunnel2TrainerHeader3: ; 0x4602c
	db $3 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d87d ; flag's byte
	dw RockTunnel2BattleText4 ; 0x60e3 TextBeforeBattle
	dw RockTunnel2AfterBattleText4 ; 0x60ed TextAfterBattle
	dw RockTunnel2EndBattleText4 ; 0x60e8 TextEndBattle
	dw RockTunnel2EndBattleText4 ; 0x60e8 TextEndBattle
; 0x46038

RockTunnel2TrainerHeader4: ; 0x46038
	db $4 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d87d ; flag's byte
	dw RockTunnel2BattleText5 ; 0x60f2 TextBeforeBattle
	dw RockTunnel2AfterBattleText5 ; 0x60fc TextAfterBattle
	dw RockTunnel2EndBattleText5 ; 0x60f7 TextEndBattle
	dw RockTunnel2EndBattleText5 ; 0x60f7 TextEndBattle
; 0x46044

RockTunnel2TrainerHeader5: ; 0x46044
	db $5 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d87d ; flag's byte
	dw RockTunnel2BattleText6 ; 0x6101 TextBeforeBattle
	dw RockTunnel2AfterBattleText6 ; 0x610b TextAfterBattle
	dw RockTunnel2EndBattleText6 ; 0x6106 TextEndBattle
	dw RockTunnel2EndBattleText6 ; 0x6106 TextEndBattle
; 0x46050

RockTunnel2TrainerHeader6: ; 0x46050
	db $6 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d87d ; flag's byte
	dw RockTunnel2BattleText7 ; 0x6110 TextBeforeBattle
	dw RockTunnel2AfterBattleText7 ; 0x611a TextAfterBattle
	dw RockTunnel2EndBattleText7 ; 0x6115 TextEndBattle
	dw RockTunnel2EndBattleText7 ; 0x6115 TextEndBattle
; 0x4605c

RockTunnel2TrainerHeader7: ; 0x4605c
	db $7 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d87d ; flag's byte
	dw RockTunnel2BattleText8 ; 0x611f TextBeforeBattle
	dw RockTunnel2AfterBattleText8 ; 0x6129 TextAfterBattle
	dw RockTunnel2EndBattleText8 ; 0x6124 TextEndBattle
	dw RockTunnel2EndBattleText8 ; 0x6124 TextEndBattle
; 0x46068

RockTunnel2TrainerHeader8: ; 0x46068
	db $8 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d87d ; flag's byte
	dw RockTunnel2BattleText9 ; 0x612e TextBeforeBattle
	dw RockTunnel2AfterBattleText9 ; 0x6138 TextAfterBattle
	dw RockTunnel2EndBattleText9 ; 0x6133 TextEndBattle
	dw RockTunnel2EndBattleText9 ; 0x6133 TextEndBattle
; 0x46074

db $ff

RockTunnel2Text1: ; 0x46075
	db $08 ; asm
	ld hl, RockTunnel2TrainerHeader0
	call LoadTrainerHeader
	jp TextScriptEnd

RockTunnel2Text2: ; 0x4607f
	db $08 ; asm
	ld hl, RockTunnel2TrainerHeader2
	call LoadTrainerHeader
	jp TextScriptEnd

RockTunnel2Text3: ; 0x46089
	db $08 ; asm
	ld hl, RockTunnel2TrainerHeader3
	call LoadTrainerHeader
	jp TextScriptEnd

RockTunnel2Text4: ; 0x46093
	db $08 ; asm
	ld hl, RockTunnel2TrainerHeader4
	call LoadTrainerHeader
	jp TextScriptEnd

RockTunnel2Text5: ; 0x4609d
	db $08 ; asm
	ld hl, RockTunnel2TrainerHeader5
	call LoadTrainerHeader
	jp TextScriptEnd

RockTunnel2Text6: ; 0x460a7
	db $08 ; asm
	ld hl, RockTunnel2TrainerHeader6
	call LoadTrainerHeader
	jp TextScriptEnd

RockTunnel2Text7: ; 0x460b1
	db $08 ; asm
	ld hl, RockTunnel2TrainerHeader7
	call LoadTrainerHeader
	jp TextScriptEnd

RockTunnel2Text8: ; 0x460bb
	db $08 ; asm
	ld hl, RockTunnel2TrainerHeader8
	call LoadTrainerHeader
	jp TextScriptEnd

RockTunnel2BattleText2: ; 0x460c5
	TX_FAR _RockTunnel2BattleText2
	db $50
; 0x460c5 + 5 bytes

RockTunnel2EndBattleText2: ; 0x460ca
	TX_FAR _RockTunnel2EndBattleText2
	db $50
; 0x460ca + 5 bytes

RockTunnel2AfterBattleText2: ; 0x460cf
	TX_FAR _RockTunnel2AfterBattleText2
	db $50
; 0x460cf + 5 bytes

RockTunnel2BattleText3: ; 0x460d4
	TX_FAR _RockTunnel2BattleText3
	db $50
; 0x460d4 + 5 bytes

RockTunnel2EndBattleText3: ; 0x460d9
	TX_FAR _RockTunnel2EndBattleText3
	db $50
; 0x460d9 + 5 bytes

RockTunnel2AfterBattleText3: ; 0x460de
	TX_FAR _RockTunnel2AfterBattleText3
	db $50
; 0x460de + 5 bytes

RockTunnel2BattleText4: ; 0x460e3
	TX_FAR _RockTunnel2BattleText4
	db $50
; 0x460e3 + 5 bytes

RockTunnel2EndBattleText4: ; 0x460e8
	TX_FAR _RockTunnel2EndBattleText4
	db $50
; 0x460e8 + 5 bytes

RockTunnel2AfterBattleText4: ; 0x460ed
	TX_FAR _RockTunnel2AfterBattleText4
	db $50
; 0x460ed + 5 bytes

RockTunnel2BattleText5: ; 0x460f2
	TX_FAR _RockTunnel2BattleText5
	db $50
; 0x460f2 + 5 bytes

RockTunnel2EndBattleText5: ; 0x460f7
	TX_FAR _RockTunnel2EndBattleText5
	db $50
; 0x460f7 + 5 bytes

RockTunnel2AfterBattleText5: ; 0x460fc
	TX_FAR _RockTunnel2AfterBattleText5
	db $50
; 0x460fc + 5 bytes

RockTunnel2BattleText6: ; 0x46101
	TX_FAR _RockTunnel2BattleText6
	db $50
; 0x46101 + 5 bytes

RockTunnel2EndBattleText6: ; 0x46106
	TX_FAR _RockTunnel2EndBattleText6
	db $50
; 0x46106 + 5 bytes

RockTunnel2AfterBattleText6: ; 0x4610b
	TX_FAR _RockTunnel2AfterBattleText6
	db $50
; 0x4610b + 5 bytes

RockTunnel2BattleText7: ; 0x46110
	TX_FAR _RockTunnel2BattleText7
	db $50
; 0x46110 + 5 bytes

RockTunnel2EndBattleText7: ; 0x46115
	TX_FAR _RockTunnel2EndBattleText7
	db $50
; 0x46115 + 5 bytes

RockTunnel2AfterBattleText7: ; 0x4611a
	TX_FAR _RockTunnel2AfterBattleText7
	db $50
; 0x4611a + 5 bytes

RockTunnel2BattleText8: ; 0x4611f
	TX_FAR _RockTunnel2BattleText8
	db $50
; 0x4611f + 5 bytes

RockTunnel2EndBattleText8: ; 0x46124
	TX_FAR _RockTunnel2EndBattleText8
	db $50
; 0x46124 + 5 bytes

RockTunnel2AfterBattleText8: ; 0x46129
	TX_FAR _RockTunnel2AfterBattleText8
	db $50
; 0x46129 + 5 bytes

RockTunnel2BattleText9: ; 0x4612e
	TX_FAR _RockTunnel2BattleText9
	db $50
; 0x4612e + 5 bytes

RockTunnel2EndBattleText9: ; 0x46133
	TX_FAR _RockTunnel2EndBattleText9
	db $50
; 0x46133 + 5 bytes

RockTunnel2AfterBattleText9: ; 0x46138
	TX_FAR _RockTunnel2AfterBattleText9
	db $50
; 0x46138 + 5 bytes

RockTunnel2Object: ; 0x4613d (size=100)
	db $3 ; border tile

	db $4 ; warps
	db $19, $21, $4, ROCK_TUNNEL_1
	db $3, $1b, $5, ROCK_TUNNEL_1
	db $b, $17, $6, ROCK_TUNNEL_1
	db $3, $3, $7, ROCK_TUNNEL_1

	db $0 ; signs

	db $8 ; people
	db SPRITE_LASS, $d + 4, $b + 4, $ff, $d0, $41, JR__TRAINER_F + $C8, $9 ; trainer
	db SPRITE_HIKER, $a + 4, $6 + 4, $ff, $d0, $42, HIKER + $C8, $9 ; trainer
	db SPRITE_BLACK_HAIR_BOY_2, $5 + 4, $3 + 4, $ff, $d0, $43, POKEMANIAC + $C8, $3 ; trainer
	db SPRITE_BLACK_HAIR_BOY_2, $15 + 4, $14 + 4, $ff, $d3, $44, POKEMANIAC + $C8, $4 ; trainer
	db SPRITE_HIKER, $a + 4, $1e + 4, $ff, $d0, $45, HIKER + $C8, $a ; trainer
	db SPRITE_LASS, $1c + 4, $e + 4, $ff, $d3, $46, JR__TRAINER_F + $C8, $a ; trainer
	db SPRITE_HIKER, $5 + 4, $21 + 4, $ff, $d3, $47, HIKER + $C8, $b ; trainer
	db SPRITE_BLACK_HAIR_BOY_2, $1e + 4, $1a + 4, $ff, $d0, $48, POKEMANIAC + $C8, $5 ; trainer

	; warp-to
	EVENT_DISP $14, $19, $21 ; ROCK_TUNNEL_1
	EVENT_DISP $14, $3, $1b ; ROCK_TUNNEL_1
	EVENT_DISP $14, $b, $17 ; ROCK_TUNNEL_1
	EVENT_DISP $14, $3, $3 ; ROCK_TUNNEL_1

RockTunnel2Blocks: ; 0x461a1 360
	INCBIN "maps/rocktunnel2.blk"

SeafoamIslands2_h: ; 0x46309 to 0x46315 (12 bytes) (bank=11) (id=159)
	db $11 ; tileset
	db SEAFOAM_ISLANDS_2_HEIGHT, SEAFOAM_ISLANDS_2_WIDTH ; dimensions (y, x)
	dw SeafoamIslands2Blocks, SeafoamIslands2Texts, SeafoamIslands2Script ; blocks, texts, scripts
	db $00 ; connections

	dw SeafoamIslands2Object ; objects

SeafoamIslands2Script: ; 0x46315
	call $3c3c
	ld hl, $cd60
	bit 7, [hl]
	res 7, [hl]
	jr z, .asm_46362 ; 0x4631f $41
	ld hl, SeafoamIslands2Script_Unknown4636d
	call $34e4
	ret nc
	ld hl, $d87f
	ld a, [$cd3d]
	cp $1
	jr nz, .asm_46340 ; 0x46330 $e
	set 0, [hl]
	ld a, $d9
	ld [$d079], a
	ld a, $db
	ld [$d07a], a
	jr .asm_4634c ; 0x4633e $c
.asm_46340
	set 1, [hl]
	ld a, $da
	ld [$d079], a
	ld a, $dc
	ld [$d07a], a
.asm_4634c
	ld a, [$d079]
	ld [$cc4d], a
	ld a, $11
	call Predef
	ld a, [$d07a]
	ld [$cc4d], a
	ld a, $15
	jp $3e6d
.asm_46362
	ld a, $a0
	ld [$d71d], a
	ld hl, SeafoamIslands2Script_Unknown4636d
	jp $6981
; 0x4636d

SeafoamIslands2Script_Unknown4636d: ; 0x4636d
INCBIN "baserom.gbc",$4636d,$5

SeafoamIslands2Texts: ; 0x46372
	dw SeafoamIslands2Text1, SeafoamIslands2Text2

SeafoamIslands2Object: ; 0x46376 (size=72)
	db $7d ; border tile

	db $7 ; warps
	db $2, $4, $0, SEAFOAM_ISLANDS_3
	db $5, $7, $4, SEAFOAM_ISLANDS_1
	db $7, $d, $2, SEAFOAM_ISLANDS_3
	db $f, $13, $3, SEAFOAM_ISLANDS_3
	db $f, $17, $6, SEAFOAM_ISLANDS_1
	db $b, $19, $5, SEAFOAM_ISLANDS_3
	db $3, $19, $5, SEAFOAM_ISLANDS_1

	db $0 ; signs

	db $2 ; people
	db SPRITE_BOULDER, $6 + 4, $11 + 4, $ff, $10, $1 ; person
	db SPRITE_BOULDER, $6 + 4, $16 + 4, $ff, $10, $2 ; person

	; warp-to
	EVENT_DISP $f, $2, $4 ; SEAFOAM_ISLANDS_3
	EVENT_DISP $f, $5, $7 ; SEAFOAM_ISLANDS_1
	EVENT_DISP $f, $7, $d ; SEAFOAM_ISLANDS_3
	EVENT_DISP $f, $f, $13 ; SEAFOAM_ISLANDS_3
	EVENT_DISP $f, $f, $17 ; SEAFOAM_ISLANDS_1
	EVENT_DISP $f, $b, $19 ; SEAFOAM_ISLANDS_3
	EVENT_DISP $f, $3, $19 ; SEAFOAM_ISLANDS_1

SeafoamIslands2Blocks: ; 0x463be 135
	INCBIN "maps/seafoamislands2.blk"

SeafoamIslands3_h: ; 0x46445 to 0x46451 (12 bytes) (bank=11) (id=160)
	db $11 ; tileset
	db SEAFOAM_ISLANDS_3_HEIGHT, SEAFOAM_ISLANDS_3_WIDTH ; dimensions (y, x)
	dw SeafoamIslands3Blocks, SeafoamIslands3Texts, SeafoamIslands3Script ; blocks, texts, scripts
	db $00 ; connections

	dw SeafoamIslands3Object ; objects

SeafoamIslands3Script: ; 0x46451
	call $3c3c
	ld hl, $cd60
	bit 7, [hl]
	res 7, [hl]
	jr z, .asm_4649e ; 0x4645b $41
	ld hl, SeafoamIslands3Script_Unknown464a9
	call $34e4
	ret nc
	ld hl, $d880
	ld a, [$cd3d]
	cp $1
	jr nz, .asm_4647c ; 0x4646c $e
	set 0, [hl]
	ld a, $db
	ld [$d079], a
	ld a, $df
	ld [$d07a], a
	jr .asm_46488 ; 0x4647a $c
.asm_4647c
	set 1, [hl]
	ld a, $dc
	ld [$d079], a
	ld a, $e0
	ld [$d07a], a
.asm_46488
	ld a, [$d079]
	ld [$cc4d], a
	ld a, $11
	call Predef
	ld a, [$d07a]
	ld [$cc4d], a
	ld a, $15
	jp $3e6d
.asm_4649e
	ld a, $a1
	ld [$d71d], a
	ld hl, SeafoamIslands3Script_Unknown464a9
	jp $6981
; 0x464a9

SeafoamIslands3Script_Unknown464a9: ; 0x464a9
INCBIN "baserom.gbc",$464a9,$5

SeafoamIslands3Texts: ; 0x464ae
	dw SeafoamIslands3Text1, SeafoamIslands3Text2

SeafoamIslands3Object: ; 0x464b2 (size=72)
	db $7d ; border tile

	db $7 ; warps
	db $3, $5, $0, SEAFOAM_ISLANDS_2
	db $d, $5, $0, SEAFOAM_ISLANDS_4
	db $7, $d, $2, SEAFOAM_ISLANDS_2
	db $f, $13, $3, SEAFOAM_ISLANDS_2
	db $3, $19, $3, SEAFOAM_ISLANDS_4
	db $b, $19, $5, SEAFOAM_ISLANDS_2
	db $e, $19, $4, SEAFOAM_ISLANDS_4

	db $0 ; signs

	db $2 ; people
	db SPRITE_BOULDER, $6 + 4, $12 + 4, $ff, $10, $1 ; person
	db SPRITE_BOULDER, $6 + 4, $17 + 4, $ff, $10, $2 ; person

	; warp-to
	EVENT_DISP $f, $3, $5 ; SEAFOAM_ISLANDS_2
	EVENT_DISP $f, $d, $5 ; SEAFOAM_ISLANDS_4
	EVENT_DISP $f, $7, $d ; SEAFOAM_ISLANDS_2
	EVENT_DISP $f, $f, $13 ; SEAFOAM_ISLANDS_2
	EVENT_DISP $f, $3, $19 ; SEAFOAM_ISLANDS_4
	EVENT_DISP $f, $b, $19 ; SEAFOAM_ISLANDS_2
	EVENT_DISP $f, $e, $19 ; SEAFOAM_ISLANDS_4

SeafoamIslands3Blocks: ; 0x464fa 135
	INCBIN "maps/seafoamislands3.blk"

SeafoamIslands4_h: ; 0x46581 to 0x4658d (12 bytes) (bank=11) (id=161)
	db $11 ; tileset
	db SEAFOAM_ISLANDS_4_HEIGHT, SEAFOAM_ISLANDS_4_WIDTH ; dimensions (y, x)
	dw SeafoamIslands4Blocks, SeafoamIslands4Texts, SeafoamIslands4Script ; blocks, texts, scripts
	db $00 ; connections

	dw SeafoamIslands4Object ; objects

SeafoamIslands4Script: ; 0x4658d
	call $3c3c
	ld hl, $cd60
	bit 7, [hl]
	res 7, [hl]
	jr z, .asm_465dc ; 0x46597 $43
	ld hl, SeafoamIslands4Script_Unknown465f6
	call $34e4
	ret nc
	ld hl, $d881
	ld a, [$cd3d]
	cp $1
	jr nz, .asm_465b8 ; 0x465a8 $e
	set 0, [hl]
	ld a, $dd
	ld [$d079], a
	ld a, $e1
	ld [$d07a], a
	jr .asm_465c4 ; 0x465b6 $c
.asm_465b8
	set 1, [hl]
	ld a, $de
	ld [$d079], a
	ld a, $e2
	ld [$d07a], a
.asm_465c4
	ld a, [$d079]
	ld [$cc4d], a
	ld a, $11
	call Predef
	ld a, [$d07a]
	ld [$cc4d], a
	ld a, $15
	call Predef
	jr .asm_465ed ; 0x465da $11
.asm_465dc
	ld a, $a2
	ld [$d71d], a
	ld hl, SeafoamIslands4Script_Unknown465f6
	call $6981
	ld a, [$d732]
	bit 4, a
	ret nz
.asm_465ed
	ld hl, SeafoamIslands4Scripts
	ld a, [$d666]
	jp $3d97
; 0x465f6

SeafoamIslands4Script_Unknown465f6: ; 0x465f6
INCBIN "baserom.gbc",$465f6,$465fb - $465f6

SeafoamIslands4Scripts: ; 0x465fb
	dw SeafoamIslands4Script0, SeafoamIslands4Script1

INCBIN "baserom.gbc",$465ff,$4

SeafoamIslands4Script0: ; 0x46603
	ld a, [$d880]
	and $3
	cp $3
	ret z
	ld a, [$d361]
	cp $8
	ret nz
	ld a, [$d362]
	cp $f
	ret nz
	ld hl, $ccd3
	ld de, SeafoamIslands4Script0_Unknown46632
	call $350c
	dec a
	ld [$cd38], a
	call $3486
	ld hl, $d733
	set 2, [hl]
	ld a, $1
	ld [$d666], a
	ret
; 0x46632

SeafoamIslands4Script0_Unknown46632: ; 0x46632
INCBIN "baserom.gbc",$46632,$46639 - $46632

SeafoamIslands4Script1: ; 0x46639
	ld a, [$cd38]
	and a
	ret nz
	ld a, $0
	ld [$d666], a
	ret
; 0x46644

INCBIN "baserom.gbc",$46644,$56

SeafoamIslands4Texts: ; 0x4669a
	dw SeafoamIslands4Text1, SeafoamIslands4Text2, SeafoamIslands4Text3, SeafoamIslands4Text4, SeafoamIslands4Text5, SeafoamIslands4Text6

SeafoamIslands4Object: ; 0x466a6 (size=96)
	db $7d ; border tile

	db $7 ; warps
	db $c, $5, $1, SEAFOAM_ISLANDS_3
	db $6, $8, $2, SEAFOAM_ISLANDS_5
	db $4, $19, $3, SEAFOAM_ISLANDS_5
	db $3, $19, $4, SEAFOAM_ISLANDS_3
	db $e, $19, $6, SEAFOAM_ISLANDS_3
	db $11, $14, $0, SEAFOAM_ISLANDS_5
	db $11, $15, $1, SEAFOAM_ISLANDS_5

	db $0 ; signs

	db $6 ; people
	db SPRITE_BOULDER, $e + 4, $5 + 4, $ff, $10, $1 ; person
	db SPRITE_BOULDER, $f + 4, $3 + 4, $ff, $10, $2 ; person
	db SPRITE_BOULDER, $e + 4, $8 + 4, $ff, $10, $3 ; person
	db SPRITE_BOULDER, $e + 4, $9 + 4, $ff, $10, $4 ; person
	db SPRITE_BOULDER, $6 + 4, $12 + 4, $ff, $ff, $5 ; person
	db SPRITE_BOULDER, $6 + 4, $13 + 4, $ff, $ff, $6 ; person

	; warp-to
	EVENT_DISP $f, $c, $5 ; SEAFOAM_ISLANDS_3
	EVENT_DISP $f, $6, $8 ; SEAFOAM_ISLANDS_5
	EVENT_DISP $f, $4, $19 ; SEAFOAM_ISLANDS_5
	EVENT_DISP $f, $3, $19 ; SEAFOAM_ISLANDS_3
	EVENT_DISP $f, $e, $19 ; SEAFOAM_ISLANDS_3
	EVENT_DISP $f, $11, $14 ; SEAFOAM_ISLANDS_5
	EVENT_DISP $f, $11, $15 ; SEAFOAM_ISLANDS_5

SeafoamIslands4Blocks: ; 0x46706 135
	INCBIN "maps/seafoamislands4.blk"

SeafoamIslands5_h: ; 0x4678d to 0x46799 (12 bytes) (bank=11) (id=162)
	db $11 ; tileset
	db SEAFOAM_ISLANDS_5_HEIGHT, SEAFOAM_ISLANDS_5_WIDTH ; dimensions (y, x)
	dw SeafoamIslands5Blocks, SeafoamIslands5Texts, SeafoamIslands5Script ; blocks, texts, scripts
	db $00 ; connections

	dw SeafoamIslands5Object ; objects

SeafoamIslands5Script: ; 0x46799
	call $3c3c
	ld a, [$d668]
	ld hl, SeafoamIslands5Scripts
	jp $3d97
; 0x467a5

INCBIN "baserom.gbc",$467a5,$467ad - $467a5

SeafoamIslands5Scripts: ; 0x467ad
	dw SeafoamIslands5Script0, SeafoamIslands5Script1

INCBIN "baserom.gbc",$467b1,$16

SeafoamIslands5Script0: ; 0x467c7
	ld a, [$d880]
	and $3
	cp $3
	ret z
	ld hl, $67fe
	call $34bf
	ret nc
	ld a, [$cd3d]
	cp $3
	jr nc, .asm_467e6 ; 0x467db $9
	ld a, $40
	ld [$ccd4], a
	ld a, $2
	jr .asm_467e8 ; 0x467e4 $2
.asm_467e6
	ld a, $1
.asm_467e8
	ld [$cd38], a
	ld a, $40
	ld [$ccd3], a
	call $3486
	ld hl, $d733
	res 2, [hl]
	ld a, $1
	ld [$d668], a
	ret
; 0x467fe

INCBIN "baserom.gbc",$467fe,$46807 - $467fe

SeafoamIslands5Script1: ; 0x46807
	ld a, [$cd38]
	and a
	ret nz
	xor a
	ld [$cd6b], a
	ld a, $0
	ld [$d668], a
	ret
; 0x46816

INCBIN "baserom.gbc",$46816,$66

SeafoamIslands5Texts: ; 0x4687c
	dw SeafoamIslands5Text1, SeafoamIslands5Text2, SeafoamIslands5Text3, SeafoamIslands5Text4, SeafoamIslands5Text5

SeafoamIslands5TrainerHeaders:
SeafoamIslands5TrainerHeader0: ; 0x46886
	db $2 ; flag's bit
	db ($0 << 4) ; trainer's view range
	dw $d882 ; flag's byte
	dw SeafoamIslands5BattleText2 ; 0x68a2 TextBeforeBattle
	dw SeafoamIslands5BattleText2 ; 0x68a2 TextAfterBattle
	dw SeafoamIslands5BattleText2 ; 0x68a2 TextEndBattle
	dw SeafoamIslands5BattleText2 ; 0x68a2 TextEndBattle
; 0x46892

db $ff

SeafoamIslands5Text3: ; 0x46893
	db $08 ; asm
	ld hl, SeafoamIslands5TrainerHeader0
	call LoadTrainerHeader
	ld a, $4
	ld [$d668], a
	jp TextScriptEnd

SeafoamIslands5BattleText2: ; 0x468a2
	TX_FAR _SeafoamIslands5BattleText2 ; 0x88075
	db $8
	ld a, $4a
	call $13d0
	call $3748
	jp TextScriptEnd
; 0x468b2

SeafoamIslands5Text4: ; 0x468b2
	TX_FAR _SeafoamIslands5Text4
	db $50

SeafoamIslands5Text5: ; 0x468b7
	TX_FAR _SeafoamIslands5Text5
	db $50

SeafoamIslands5Object: ; 0x468bc (size=62)
	db $7d ; border tile

	db $4 ; warps
	db $11, $14, $5, SEAFOAM_ISLANDS_4
	db $11, $15, $6, SEAFOAM_ISLANDS_4
	db $7, $b, $1, SEAFOAM_ISLANDS_4
	db $4, $19, $2, SEAFOAM_ISLANDS_4

	db $2 ; signs
	db $f, $9, $4 ; SeafoamIslands5Text4
	db $1, $17, $5 ; SeafoamIslands5Text5

	db $3 ; people
	db SPRITE_BOULDER, $f + 4, $4 + 4, $ff, $ff, $1 ; person
	db SPRITE_BOULDER, $f + 4, $5 + 4, $ff, $ff, $2 ; person
	db SPRITE_BIRD, $1 + 4, $6 + 4, $ff, $d0, $43, ARTICUNO, $32 ; trainer

	; warp-to
	EVENT_DISP $f, $11, $14 ; SEAFOAM_ISLANDS_4
	EVENT_DISP $f, $11, $15 ; SEAFOAM_ISLANDS_4
	EVENT_DISP $f, $7, $b ; SEAFOAM_ISLANDS_4
	EVENT_DISP $f, $4, $19 ; SEAFOAM_ISLANDS_4

SeafoamIslands5Blocks: ; 0x468fa 135
	INCBIN "maps/seafoamislands5.blk"

INCBIN "baserom.gbc",$46981,$167f

SECTION "bank12",DATA,BANK[$12]

Route7_h: ; 0x48000 to 0x48022 (34 bytes) (bank=12) (id=18)
	db $00 ; tileset
	db ROUTE_7_HEIGHT, ROUTE_7_WIDTH ; dimensions (y, x)
	dw Route7Blocks, $4155, Route7Script ; blocks, texts, scripts
	db WEST | EAST ; connections

	; connections data

	db CELADON_CITY
	dw CeladonCityBlocks - 3 + (CELADON_CITY_WIDTH * 2) ; connection strip location
	dw $C6E8 + (ROUTE_7_WIDTH + 6) * (-3 + 3) ; current map position
	db $f, CELADON_CITY_WIDTH ; bigness, width
	db (-4 * -2), (CELADON_CITY_WIDTH * 2) - 1 ; alignments (y, x)
	dw $C6EE + 2 * CELADON_CITY_WIDTH ; window

	db SAFFRON_CITY
	dw SaffronCityBlocks + (SAFFRON_CITY_WIDTH) ; connection strip location
	dw $C6E5 + (ROUTE_7_WIDTH + 6) * (-3 + 4) ; current map position
	db $f, SAFFRON_CITY_WIDTH ; bigness, width
	db (-4 * -2), 0 ; alignments (y, x)
	dw $C6EF + SAFFRON_CITY_WIDTH ; window

	; end connections data

	dw Route7Object ; objects

Route7Object: ; 0x48022 (size=47)
	db $f ; border tile

	db $5 ; warps
	db $9, $12, $2, ROUTE_7_GATE
	db $a, $12, $3, ROUTE_7_GATE
	db $9, $b, $0, ROUTE_7_GATE
	db $a, $b, $1, ROUTE_7_GATE
	db $d, $5, $0, PATH_ENTRANCE_ROUTE_7

	db $1 ; signs
	db $d, $3, $1 ; Route7Text1

	db $0 ; people

	; warp-to
	EVENT_DISP $a, $9, $12 ; ROUTE_7_GATE
	EVENT_DISP $a, $a, $12 ; ROUTE_7_GATE
	EVENT_DISP $a, $9, $b ; ROUTE_7_GATE
	EVENT_DISP $a, $a, $b ; ROUTE_7_GATE
	EVENT_DISP $a, $d, $5 ; PATH_ENTRANCE_ROUTE_7

Route7Blocks: ; 4051 90
	INCBIN "maps/route7.blk"

CeladonPokecenterBlocks:
RockTunnelPokecenterBlocks:
MtMoonPokecenterBlocks: ; 40ab 28
	INCBIN "maps/mtmoonpokecenter.blk"

Route18GateBlocks:
Route15GateBlocks:
Route11GateBlocks: ; 40c7 20
	INCBIN "maps/route11gate.blk"

Route18GateHeaderBlocks:
Route16GateUpstairsBlocks:
Route12GateUpstairsBlocks:
Route11GateUpstairsBlocks: ; 40db 16
	INCBIN "maps/route11gateupstairs.blk"

INCBIN "baserom.gbc",$480eb,$48152 - $480eb

Route7Script: ; 0x48152
	jp $3c3c
; 0x48155

; XXX
db $57, $41

Route7Text1: ; 0x48157
	TX_FAR _Route7Text1
	db $50

RedsHouse1F_h: ; 415C
	db $01 ; tileset
	db $04,$04 ; dimensions
	dw RedsHouse1FBlocks, RedsHouse1FTexts, RedsHouse1FScript
	db 0 ; no connections
	dw RedsHouse1FObject

RedsHouse1FScript: ; 4168
	jp $3C3C

RedsHouse1FTexts: ; 416B
	dw RedsHouse1FText1,RedsHouse1FText2

RedsHouse1FText1: ; 416F Mom
	db 8
	ld a, [$D72E]
	bit 3, a
	jr nz, .heal\@ ; if player has received a Pokémon from Oak, heal team
	ld hl, MomWakeUpText
	call PrintText
	jr .done\@
.heal\@
	call MomHealPokemon
.done\@
	jp TextScriptEnd

MomWakeUpText: ; 0x48185
	TX_FAR _MomWakeUpText
	db "@"

MomHealPokemon: ; 0x4818a
	ld hl, MomHealText1
	call PrintText
	call GBFadeOut2
	call $3071
	ld a, 7
	call Predef
	ld a, $E8
	ld [$C0EE], a
	call $23B1 ; play sound?
.next\@
	ld a, [$C026]
	cp $E8
	jr z, .next\@
	ld a, [$D35B]
	ld [$C0EE], a
	call $23B1
	call GBFadeIn2
	ld hl, MomHealText2
	jp PrintText

MomHealText1: ; 0x481bc
	TX_FAR _MomHealText1
	db "@"
MomHealText2: ; 0x481c1
	TX_FAR _MomHealText2
	db "@"

RedsHouse1FText2: ; 0x481c6 TV
	db 8
	ld a,[$C109]
	cp 4
	ld hl,TVWrongSideText
	jr nz,.done\@ ; if player is not facing up
	ld hl,StandByMeText
.done\@
	call PrintText
	jp TextScriptEnd

StandByMeText: ; 0x481da
	TX_FAR _StandByMeText
	db "@"

TVWrongSideText: ; 0x481df
	TX_FAR _TVWrongSideText
	db "@"

RedsHouse1FObject: ; 0x481e4
	db $0A ; border tile

	db 3 ; warps
	db 7,2,0,$FF ; exit1
	db 7,3,0,$FF ; exit2
	db 1,7,0,$26 ; staircase

	db 1 ; signs
	db 1,3,2 ; TV

	db 1 ; people
	db $33,4+4,5+4,$FF,$D2,1 ; Mom

	; warp-to

	dw $C6EF + 4 + (4 + 6) * (3) + 1
	db 7,2

	dw $C6EF + 4 + (4 + 6) * (3) + 1
	db 7,3

	dw $C6EF + 4 + (4 + 6) * (0) + 3
	db 1,7

RedsHouse1FBlocks:
	INCBIN "maps/redshouse1f.blk"

CeladonMart3_h: ; 0x48219 to 0x48225 (12 bytes) (bank=12) (id=124)
	db $12 ; tileset
	db CELADON_MART_3_HEIGHT, CELADON_MART_3_WIDTH ; dimensions (y, x)
	dw CeladonMart3Blocks, CeladonMart3Texts, CeladonMart3Script ; blocks, texts, scripts
	db $00 ; connections

	dw CeladonMart3Object ; objects

CeladonMart3Script: ; 0x48225
	jp $3c3c
; 0x48228

CeladonMart3Texts: ; 0x48228
	dw CeladonMart3Text1, CeladonMart3Text2, CeladonMart3Text3, CeladonMart3Text4, CeladonMart3Text5, CeladonMart3Text6, CeladonMart3Text7, CeladonMart3Text8, CeladonMart3Text9, CeladonMart3Text10, CeladonMart3Text11, CeladonMart3Text12, CeladonMart3Text13, CeladonMart3Text14, CeladonMart3Text15, CeladonMart3Text16, CeladonMart3Text17

CeladonMart3Text1: ; 0x4824a
	db $08 ; asm
	ld a, [$d778]
	bit 7, a
	jr nz, .asm_a5463 ; 0x48250
	ld hl, TM18PreReceiveText
	call PrintText
	ld bc, (TM_18 << 8) | 1
	call GiveItem
	jr nc, .asm_95f37 ; 0x4825e
	ld hl, $d778
	set 7, [hl]
	ld hl, ReceivedTM18Text
	jr .asm_81359 ; 0x48268
.asm_95f37 ; 0x4826a
	ld hl, TM18NoRoomText
	jr .asm_81359 ; 0x4826d
.asm_a5463 ; 0x4826f
	ld hl, TM18ExplanationText
.asm_81359 ; 0x48272
	call PrintText
	jp TextScriptEnd

TM18PreReceiveText: ; 0x48278
	TX_FAR _TM18PreReceiveText
	db $50
; 0x48278 + 5 bytes

ReceivedTM18Text: ; 0x4827d
	TX_FAR _ReceivedTM18Text ; 0x9c85a
	db $0B, $50
; 0x48283

TM18ExplanationText: ; 0x48283
	TX_FAR _TM18ExplanationText
	db $50
; 0x48283 + 5 bytes

TM18NoRoomText: ; 0x48288
	TX_FAR _TM18NoRoomText
	db $50
; 0x48288 + 5 bytes

CeladonMart3Text2: ; 0x4828d
	TX_FAR _CeladonMart3Text2
	db $50

CeladonMart3Text3: ; 0x48292
	TX_FAR _CeladonMart3Text3
	db $50

CeladonMart3Text4: ; 0x48297
	TX_FAR _CeladonMart3Text4
	db $50

CeladonMart3Text5: ; 0x4829c
	TX_FAR _CeladonMart3Text5
	db $50

CeladonMart3Text12
CeladonMart3Text10:
CeladonMart3Text8:
CeladonMart3Text6: ; 0x482a1
	TX_FAR _CeladonMart3Text6
	db $50

CeladonMart3Text7: ; 0x482a6
	TX_FAR _CeladonMart3Text7
	db $50

CeladonMart3Text9: ; 0x482ab
	TX_FAR _CeladonMart3Text9
	db $50

CeladonMart3Text11: ; 0x482b0
	TX_FAR _CeladonMart3Text11
	db $50

CeladonMart3Text13: ; 0x482b5
	TX_FAR _CeladonMart3Text13
	db $50

CeladonMart3Text14: ; 0x482ba
	TX_FAR _CeladonMart3Text14
	db $50

CeladonMart3Text17:
CeladonMart3Text16:
CeladonMart3Text15: ; 0x482bf
	TX_FAR _CeladonMart3Text15
	db $50

CeladonMart3Object: ; 0x482c4 (size=94)
	db $f ; border tile

	db $3 ; warps
	db $1, $c, $0, CELADON_MART_4
	db $1, $10, $1, CELADON_MART_2
	db $1, $1, $0, CELADON_MART_ELEVATOR

	db $c ; signs
	db $4, $2, $6 ; CeladonMart3Text6
	db $4, $3, $7 ; CeladonMart3Text7
	db $4, $5, $8 ; CeladonMart3Text8
	db $4, $6, $9 ; CeladonMart3Text9
	db $6, $2, $a ; CeladonMart3Text10
	db $6, $3, $b ; CeladonMart3Text11
	db $6, $5, $c ; CeladonMart3Text12
	db $6, $6, $d ; CeladonMart3Text13
	db $1, $e, $e ; CeladonMart3Text14
	db $1, $4, $f ; CeladonMart3Text15
	db $1, $6, $10 ; CeladonMart3Text16
	db $1, $a, $11 ; CeladonMart3Text17

	db $5 ; people
	db SPRITE_MART_GUY, $5 + 4, $10 + 4, $ff, $ff, $1 ; person
	db SPRITE_GAMEBOY_KID_COPY, $6 + 4, $b + 4, $ff, $d3, $2 ; person
	db SPRITE_GAMEBOY_KID_COPY, $2 + 4, $7 + 4, $ff, $d0, $3 ; person
	db SPRITE_GAMEBOY_KID_COPY, $2 + 4, $8 + 4, $ff, $d0, $4 ; person
	db SPRITE_YOUNG_BOY, $5 + 4, $2 + 4, $ff, $d1, $5 ; person

	; warp-to
	EVENT_DISP $a, $1, $c ; CELADON_MART_4
	EVENT_DISP $a, $1, $10 ; CELADON_MART_2
	EVENT_DISP $a, $1, $1 ; CELADON_MART_ELEVATOR

CeladonMart3Blocks: ; 0x48322 40
	INCBIN "maps/celadonmart3.blk"

CeladonMart4_h: ; 0x4834a to 0x48356 (12 bytes) (bank=12) (id=125)
	db $12 ; tileset
	db CELADON_MART_4_HEIGHT, CELADON_MART_4_WIDTH ; dimensions (y, x)
	dw CeladonMart4Blocks, CeladonMart4Texts, CeladonMart4Script ; blocks, texts, scripts
	db $00 ; connections

	dw CeladonMart4Object ; objects

CeladonMart4Script: ; 0x48356
	jp $3c3c
; 0x48359

CeladonMart4Texts: ; 0x48359
	dw CeladonMart4Text1, CeladonMart4Text2, CeladonMart4Text3, CeladonMart4Text4

CeladonMart4Text2: ; 0x48361
	TX_FAR _CeladonMart4Text2
	db $50

CeladonMart4Text3: ; 0x48366
	TX_FAR _CeladonMart4Text3
	db $50

CeladonMart4Text4: ; 0x4836b
	TX_FAR _CeladonMart4Text4
	db $50

CeladonMart4Object: ; 0x48370 (size=49)
	db $f ; border tile

	db $3 ; warps
	db $1, $c, $0, CELADON_MART_3
	db $1, $10, $1, CELADON_MART_5
	db $1, $1, $0, CELADON_MART_ELEVATOR

	db $1 ; signs
	db $1, $e, $4 ; CeladonMart4Text4

	db $3 ; people
	db SPRITE_MART_GUY, $7 + 4, $5 + 4, $ff, $ff, $1 ; person
	db SPRITE_BLACK_HAIR_BOY_2, $5 + 4, $f + 4, $fe, $2, $2 ; person
	db SPRITE_BUG_CATCHER, $2 + 4, $5 + 4, $fe, $2, $3 ; person

	; warp-to
	EVENT_DISP $a, $1, $c ; CELADON_MART_3
	EVENT_DISP $a, $1, $10 ; CELADON_MART_5
	EVENT_DISP $a, $1, $1 ; CELADON_MART_ELEVATOR

CeladonMart4Blocks: ; 0x483a1 40
	INCBIN "maps/celadonmart4.blk"

CeladonMartRoof_h: ; 0x483c9 to 0x483d5 (12 bytes) (bank=12) (id=126)
	db $12 ; tileset
	db CELADON_MART_5_HEIGHT, CELADON_MART_5_WIDTH ; dimensions (y, x)
	dw CeladonMartRoofBlocks, CeladonMartRoofTexts, CeladonMartRoofScript ; blocks, texts, scripts
	db $00 ; connections

	dw CeladonMartRoofObject ; objects

CeladonMartRoofScript: ; 0x483d5
	jp $3c3c
; 0x483d8

INCBIN "baserom.gbc",$483d8,$484ee - $483d8

UnnamedText_484ee: ; 0x484ee
	TX_FAR _UnnamedText_484ee
	db $50
; 0x484ee + 5 bytes

INCBIN "baserom.gbc",$484f3,$68

CeladonMartRoofTexts: ; 0x4855b
	dw CeladonMartRoofText1, CeladonMartRoofText2, CeladonMartRoofText5, CeladonMartRoofText5, CeladonMartRoofText5, CeladonMartRoofText6

CeladonMartRoofText1: ; 0x48567
	TX_FAR _CeladonMartRoofText1
	db $50

CeladonMartRoofText2: ; 0x4856c
	db $08 ; asm
	call $43d8
	ld a, [$cd37]
	and a
	jr z, .asm_914b9 ; 0x48574
	ld a, $1
	ld [$cc3c], a
	ld hl, CeladonMartRoofText4
	call PrintText
	call $35ec
	ld a, [$cc26]
	and a
	jr nz, .asm_05aa4 ; 0x48588
	call $440c
	jr .asm_05aa4 ; 0x4858d
.asm_914b9 ; 0x4858f
	ld hl, CeladonMartRoofText3
	call PrintText
.asm_05aa4 ; 0x48595
	jp TextScriptEnd

CeladonMartRoofText3: ; 0x48598
	TX_FAR _UnnamedText_48598
	db $50
; 0x48598 + 5 bytes

CeladonMartRoofText4:
UnnamedText_4859d: ; 0x4859d
	TX_FAR _UnnamedText_4859d
	db $50
; 0x4859d + 5 bytes

CeladonMartRoofText5: ; 0x485a2
	db $f5

CeladonMartRoofText6: ; 0x485a3
	TX_FAR _CeladonMartRoofText6
	db $50

CeladonMartRoofObject: ; 0x485a8 (size=36)
	db $42 ; border tile

	db $1 ; warps
	db $2, $f, $0, CELADON_MART_5

	db $4 ; signs
	db $1, $a, $3 ; CeladonMartRoofText3
	db $1, $b, $4 ; CeladonMartRoofText4
	db $2, $c, $5 ; CeladonMartRoofText5
	db $2, $d, $6 ; CeladonMartRoofText6

	db $2 ; people
	db SPRITE_BLACK_HAIR_BOY_2, $4 + 4, $a + 4, $ff, $d2, $1 ; person
	db SPRITE_LITTLE_GIRL, $5 + 4, $5 + 4, $fe, $0, $2 ; person

	; warp-to
	EVENT_DISP $a, $2, $f ; CELADON_MART_5

CeladonMartRoofBlocks: ; 0x485cc 40
	INCBIN "maps/celadonmart5.blk"

CeladonMartElevator_h: ; 0x485f4 to 0x48600 (12 bytes) (bank=12) (id=127)
	db $12 ; tileset
	db CELADON_MART_6_HEIGHT, CELADON_MART_6_WIDTH ; dimensions (y, x)
	dw CeladonMartElevatorBlocks, CeladonMartElevatorTexts, CeladonMartElevatorScript ; blocks, texts, scripts
	db $00 ; connections

	dw CeladonMartElevatorObject ; objects

CeladonMartElevatorScript: ; 0x48600
	ld hl, $d126
	bit 5, [hl]
	res 5, [hl]
	push hl
	call nz, CeladonMartElevatorScript_Unknown4861c
	pop hl
	bit 7, [hl]
	res 7, [hl]
	call nz, $4654
	xor a
	ld [$cf0c], a
	inc a
	ld [$cc3c], a
	ret
; 0x4861c

CeladonMartElevatorScript_Unknown4861c: ; 0x4861c
INCBIN "baserom.gbc",$4861c,$40

CeladonMartElevatorTexts: ; 0x4865c
	dw CeladonMartElevatorText1

CeladonMartElevatorText1: ; 0x4865e
	db $08 ; asm
	call $4631
	ld hl, $464a
	ld a, $61
	call Predef
	jp TextScriptEnd

CeladonMartElevatorObject: ; 0x4866d (size=23)
	db $f ; border tile

	db $2 ; warps
	db $3, $1, $5, CELADON_MART_1
	db $3, $2, $5, CELADON_MART_1

	db $1 ; signs
	db $0, $3, $1 ; CeladonMartElevatorText1

	db $0 ; people

	; warp-to
	EVENT_DISP $2, $3, $1 ; CELADON_MART_1
	EVENT_DISP $2, $3, $2 ; CELADON_MART_1

CeladonMartElevatorBlocks: ; 0x48684 4
	INCBIN "maps/celadonmart6.blk"

CeladonMansion1_h: ; 0x48688 to 0x48694 (12 bytes) (bank=12) (id=128)
	db $13 ; tileset
	db CELADON_MANSION_1_HEIGHT, CELADON_MANSION_1_WIDTH ; dimensions (y, x)
	dw CeladonMansion1Blocks, CeladonMansion1Texts, CeladonMansion1Script ; blocks, texts, scripts
	db $00 ; connections

	dw CeladonMansion1Object ; objects

CeladonMansion1Script: ; 0x48694
	jp $3c3c
; 0x48697

CeladonMansion1Texts: ; 0x48697
	dw CeladonMansion1Text1, CeladonMansion1Text2, CeladonMansion1Text3, CeladonMansion1Text4, CeladonMansion1Text5

;0x486a1
	call $13d0
	jp TextScriptEnd
; 0x486a7

CeladonMansion1Text1: ; 0x486a7
	TX_FAR _CeladonMansion1Text1
	db $08 ; asm
	ld a, $4d
	jp $46a1

CeladonMansion1Text2: ; 0x486b1
	TX_FAR _CeladonMansion1Text2
	db $50

CeladonMansion1Text3: ; 0x486b6
	TX_FAR _CeladonMansion1Text3
	db $8
	ld a, $4
	jp $46a1
; 0x486c0

CeladonMansion1Text4: ; 0x486c0
	TX_FAR _CeladonMansion1Text4
	db $8
	ld a, $f
	jp $46a1
; 0x486ca

CeladonMansion1Text5: ; 0x486ca
	TX_FAR _CeladonMansion1Text5
	db $50

CeladonMansion1Object: ; 0x486cf (size=71)
	db $f ; border tile

	db $5 ; warps
	db $b, $4, $2, $ff
	db $b, $5, $2, $ff
	db $0, $4, $4, $ff
	db $1, $7, $1, CELADON_MANSION_2
	db $1, $2, $2, CELADON_MANSION_2

	db $1 ; signs
	db $9, $4, $5 ; CeladonMansion1Text5

	db $4 ; people
	db SPRITE_SLOWBRO, $5 + 4, $0 + 4, $ff, $d3, $1 ; person
	db SPRITE_OLD_MEDIUM_WOMAN, $5 + 4, $1 + 4, $ff, $d0, $2 ; person
	db SPRITE_CLEFAIRY, $8 + 4, $1 + 4, $fe, $2, $3 ; person
	db SPRITE_SLOWBRO, $4 + 4, $4 + 4, $fe, $1, $4 ; person

	; warp-to
	EVENT_DISP $4, $b, $4
	EVENT_DISP $4, $b, $5
	EVENT_DISP $4, $0, $4
	EVENT_DISP $4, $1, $7 ; CELADON_MANSION_2
	EVENT_DISP $4, $1, $2 ; CELADON_MANSION_2

CeladonMansion1Blocks: ; 0x48716 24
	INCBIN "maps/celadonmansion1.blk"

CeladonMansion2_h: ; 0x4872e to 0x4873a (12 bytes) (bank=12) (id=129)
	db $13 ; tileset
	db CELADON_MANSION_2_HEIGHT, CELADON_MANSION_2_WIDTH ; dimensions (y, x)
	dw CeladonMansion2Blocks, CeladonMansion2Texts, CeladonMansion2Script ; blocks, texts, scripts
	db $00 ; connections

	dw CeladonMansion2Object ; objects

CeladonMansion2Script: ; 0x4873a
	call $3c3c
	ret
; 0x4873e

CeladonMansion2Texts: ; 0x4873e
	dw CeladonMansion2Text1

CeladonMansion2Text1: ; 0x48740
	TX_FAR _CeladonMansion2Text1
	db $50

CeladonMansion2Object: ; 0x48745 (size=39)
	db $f ; border tile

	db $4 ; warps
	db $1, $6, $0, CELADON_MANSION_3
	db $1, $7, $3, CELADON_MANSION_1
	db $1, $2, $4, CELADON_MANSION_1
	db $1, $4, $3, CELADON_MANSION_3

	db $1 ; signs
	db $9, $4, $1 ; CeladonMansion2Text1

	db $0 ; people

	; warp-to
	EVENT_DISP $4, $1, $6 ; CELADON_MANSION_3
	EVENT_DISP $4, $1, $7 ; CELADON_MANSION_1
	EVENT_DISP $4, $1, $2 ; CELADON_MANSION_1
	EVENT_DISP $4, $1, $4 ; CELADON_MANSION_3

CeladonMansion2Blocks: ; 0x4876c 24
	INCBIN "maps/celadonmansion2.blk"

CeladonMansion3_h: ; 0x48784 to 0x48790 (12 bytes) (bank=12) (id=130)
	db $13 ; tileset
	db CELADON_MANSION_3_HEIGHT, CELADON_MANSION_3_WIDTH ; dimensions (y, x)
	dw CeladonMansion3Blocks, CeladonMansion3Texts, CeladonMansion3Script ; blocks, texts, scripts
	db $00 ; connections

	dw CeladonMansion3Object ; objects

CeladonMansion3Script: ; 0x48790
	jp $3c3c
; 0x48793

CeladonMansion3Texts: ; 0x48793
	dw CeladonMansion3Text1, CeladonMansion3Text2, CeladonMansion3Text3, CeladonMansion3Text4, CeladonMansion3Text5, CeladonMansion3Text6, CeladonMansion3Text7, CeladonMansion3Text8

CeladonMansion3Text1: ; 0x487a3
	TX_FAR _CeladonMansion3Text1
	db $50

CeladonMansion3Text2: ; 0x487a8
	TX_FAR _CeladonMansion3Text2
	db $50

CeladonMansion3Text3: ; 0x487ad
	TX_FAR _CeladonMansion3Text3
	db $50

CeladonMansion3Text4: ; 0x487b2
	db $08 ; asm
	ld hl, $d2f7
	ld b, $13
	call $2b7f
	ld a, [$d11e]
	cp $96
	jr nc, .asm_f03d0 ; 0x487c0
	ld hl, UnnamedText_487d0
	jr .asm_c13f0 ; 0x487c5
.asm_f03d0 ; 0x487c7
	ld hl, UnnamedText_487d5
.asm_c13f0 ; 0x487ca
	call PrintText
	jp TextScriptEnd

UnnamedText_487d0: ; 0x487d0
	TX_FAR _UnnamedText_487d0
	db $50
; 0x487d5

UnnamedText_487d5: ; 0x487d5
	TX_FAR _UnnamedText_487d5 ; 0x9d0ad
	db $6
	db $8
	ld hl, $66e2
	ld b, $15
	call Bankswitch
	ld a, $1
	ld [$cc3c], a
	jp TextScriptEnd
; 0x487eb

CeladonMansion3Text5: ; 0x487eb
	TX_FAR _CeladonMansion3Text5
	db $50

CeladonMansion3Text6: ; 0x487f0
	TX_FAR _CeladonMansion3Text6
	db $50

CeladonMansion3Text7: ; 0x487f5
	TX_FAR _CeladonMansion3Text7
	db $50

CeladonMansion3Text8: ; 0x487fa
	TX_FAR _CeladonMansion3Text8
	db $50

CeladonMansion3Object: ; 0x487ff (size=72)
	db $f ; border tile

	db $4 ; warps
	db $1, $6, $0, CELADON_MANSION_2
	db $1, $7, $0, CELADON_MANSION_4
	db $1, $2, $1, CELADON_MANSION_4
	db $1, $4, $3, CELADON_MANSION_2

	db $4 ; signs
	db $3, $1, $5 ; CeladonMansion3Text5
	db $3, $4, $6 ; CeladonMansion3Text6
	db $6, $1, $7 ; CeladonMansion3Text7
	db $9, $4, $8 ; CeladonMansion3Text8

	db $4 ; people
	db SPRITE_BIKE_SHOP_GUY, $4 + 4, $0 + 4, $ff, $d1, $1 ; person
	db SPRITE_MART_GUY, $4 + 4, $3 + 4, $ff, $d1, $2 ; person
	db SPRITE_BLACK_HAIR_BOY_2, $7 + 4, $0 + 4, $ff, $d1, $3 ; person
	db SPRITE_LAPRAS_GIVER, $3 + 4, $2 + 4, $ff, $ff, $4 ; person

	; warp-to
	EVENT_DISP $4, $1, $6 ; CELADON_MANSION_2
	EVENT_DISP $4, $1, $7 ; CELADON_MANSION_4
	EVENT_DISP $4, $1, $2 ; CELADON_MANSION_4
	EVENT_DISP $4, $1, $4 ; CELADON_MANSION_2

CeladonMansion3Blocks: ; 0x48847 24
	INCBIN "maps/celadonmansion3.blk"

CeladonMansion4_h: ; 0x4885f to 0x4886b (12 bytes) (bank=12) (id=131)
	db $13 ; tileset
	db CELADON_MANSION_4_HEIGHT, CELADON_MANSION_4_WIDTH ; dimensions (y, x)
	dw CeladonMansion4Blocks, CeladonMansion4Texts, CeladonMansion4Script ; blocks, texts, scripts
	db $00 ; connections

	dw CeladonMansion4Object ; objects

CeladonMansion4Script: ; 0x4886b
	jp $3c3c
; 0x4886e

CeladonMansion4Texts: ; 0x4886e
	dw CeladonMansion4Text1

CeladonMansion4Text1: ; 0x48870
	TX_FAR _CeladonMansion4Text1
	db $50

CeladonMansion4Object: ; 0x48875 (size=31)
	db $9 ; border tile

	db $3 ; warps
	db $1, $6, $1, CELADON_MANSION_3
	db $1, $2, $2, CELADON_MANSION_3
	db $7, $2, $0, CELADON_MANSION_5

	db $1 ; signs
	db $7, $3, $1 ; CeladonMansion4Text1

	db $0 ; people

	; warp-to
	EVENT_DISP $4, $1, $6 ; CELADON_MANSION_3
	EVENT_DISP $4, $1, $2 ; CELADON_MANSION_3
	EVENT_DISP $4, $7, $2 ; CELADON_MANSION_5

CeladonMansion4Blocks: ; 0x48894 24
	INCBIN "maps/celadonmansion4.blk"

CeladonPokecenter_h: ; 0x488ac to 0x488b8 (12 bytes) (bank=12) (id=133)
	db $06 ; tileset
	db CELADON_POKECENTER_HEIGHT, CELADON_POKECENTER_WIDTH ; dimensions (y, x)
	dw CeladonPokecenterBlocks, CeladonPokecenterTexts, CeladonPokecenterScript ; blocks, texts, scripts
	db $00 ; connections

	dw CeladonPokecenterObject ; objects

CeladonPokecenterScript: ; 0x488b8
	call $22fa
	jp $3c3c
; 0x488be

CeladonPokecenterTexts:
	dw CeladonPokecenterText1, CeladonPokecenterText2, CeladonPokecenterText3, CeladonPokecenterText4

CeladonPokecenterText4:
	db $f6

CeladonPokecenterText1:
	db $ff

CeladonPokecenterText2: ; 0x488c8
	TX_FAR _CeladonPokecenterText2
	db $50

CeladonPokecenterText3: ; 0x488cd
	TX_FAR _CeladonPokecenterText3
	db $50

CeladonPokecenterObject: ; 0x488d2 (size=44)
	db $0 ; border tile

	db $2 ; warps
	db $7, $3, $5, $ff
	db $7, $4, $5, $ff

	db $0 ; signs

	db $4 ; people
	db SPRITE_NURSE, $1 + 4, $3 + 4, $ff, $d0, $1 ; person
	db SPRITE_GENTLEMAN, $3 + 4, $7 + 4, $fe, $2, $2 ; person
	db SPRITE_FOULARD_WOMAN, $5 + 4, $a + 4, $fe, $0, $3 ; person
	db SPRITE_CABLE_CLUB_WOMAN, $2 + 4, $b + 4, $ff, $d0, $4 ; person

	; warp-to
	EVENT_DISP $7, $7, $3
	EVENT_DISP $7, $7, $4

CeladonGym_h: ; 0x488fe to 0x4890a (12 bytes) (bank=12) (id=134)
	db $07 ; tileset
	db CELADON_GYM_HEIGHT, CELADON_GYM_WIDTH ; dimensions (y, x)
	dw CeladonGymBlocks, CeladonGymTexts, CeladonGymScript ; blocks, texts, scripts
	db $00 ; connections

	dw CeladonGymObject ; objects

CeladonGymScript: ; 0x4890a
	ld hl, $d126
	bit 6, [hl]
	res 6, [hl]
	call nz, CeladonGymScript_Unknown48927
	call $3c3c
	ld hl, CeladonGymTrainerHeaders
	ld de, $494e
	ld a, [$d5ff]
	call $3160
	ld [$d5ff], a
	ret
; 0x48927

CeladonGymScript_Unknown48927: ; 0x48927
INCBIN "baserom.gbc",$48927,$7f

CeladonGymTexts: ; 0x489a6
	dw CeladonGymText1, CeladonGymText2, CeladonGymText3, CeladonGymText4, CeladonGymText5, CeladonGymText6, CeladonGymText7, CeladonGymText8, CeladonGymText9, TM21Text, TM21NoRoomText

CeladonGymTrainerHeaders:
CeladonGymTrainerHeader0: ; 0x489bc
	db $2 ; flag's bit
	db ($2 << 4) ; trainer's view range
	dw $d77c ; flag's byte
	dw CeladonGymBattleText2 ; 0x4a8b TextBeforeBattle
	dw CeladonGymAfterBattleText2 ; 0x4a95 TextAfterBattle
	dw CeladonGymEndBattleText2 ; 0x4a90 TextEndBattle
	dw CeladonGymEndBattleText2 ; 0x4a90 TextEndBattle
; 0x489c8

CeladonGymTrainerHeader2: ; 0x489c8
	db $3 ; flag's bit
	db ($2 << 4) ; trainer's view range
	dw $d77c ; flag's byte
	dw CeladonGymBattleText3 ; 0x4aa4 TextBeforeBattle
	dw CeladonGymAfterBattleText3 ; 0x4aae TextAfterBattle
	dw CeladonGymEndBattleText3 ; 0x4aa9 TextEndBattle
	dw CeladonGymEndBattleText3 ; 0x4aa9 TextEndBattle
; 0x489d4

CeladonGymTrainerHeader3: ; 0x489d4
	db $4 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d77c ; flag's byte
	dw CeladonGymBattleText4 ; 0x4abd TextBeforeBattle
	dw CeladonGymAfterBattleText4 ; 0x4ac7 TextAfterBattle
	dw CeladonGymEndBattleText4 ; 0x4ac2 TextEndBattle
	dw CeladonGymEndBattleText4 ; 0x4ac2 TextEndBattle
; 0x489e0

CeladonGymTrainerHeader4: ; 0x489e0
	db $5 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d77c ; flag's byte
	dw CeladonGymBattleText5 ; 0x4ad6 TextBeforeBattle
	dw CeladonGymAfterBattleText5 ; 0x4ae0 TextAfterBattle
	dw CeladonGymEndBattleText5 ; 0x4adb TextEndBattle
	dw CeladonGymEndBattleText5 ; 0x4adb TextEndBattle
; 0x489ec

CeladonGymTrainerHeader5: ; 0x489ec
	db $6 ; flag's bit
	db ($2 << 4) ; trainer's view range
	dw $d77c ; flag's byte
	dw CeladonGymBattleText6 ; 0x4aef TextBeforeBattle
	dw CeladonGymAfterBattleText6 ; 0x4af9 TextAfterBattle
	dw CeladonGymEndBattleText6 ; 0x4af4 TextEndBattle
	dw CeladonGymEndBattleText6 ; 0x4af4 TextEndBattle
; 0x489f8

CeladonGymTrainerHeader6: ; 0x489f8
	db $7 ; flag's bit
	db ($2 << 4) ; trainer's view range
	dw $d77c ; flag's byte
	dw CeladonGymBattleText7 ; 0x4b08 TextBeforeBattle
	dw CeladonGymAfterBattleText7 ; 0x4b12 TextAfterBattle
	dw CeladonGymEndBattleText7 ; 0x4b0d TextEndBattle
	dw CeladonGymEndBattleText7 ; 0x4b0d TextEndBattle
; 0x48a04

CeladonGymTrainerHeader7: ; 0x48a04
	db $8 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d77c ; flag's byte
	dw CeladonGymBattleText8 ; 0x4b21 TextBeforeBattle
	dw CeladonGymAfterBattleText8 ; 0x4b2b TextAfterBattle
	dw CeladonGymEndBattleText8 ; 0x4b26 TextEndBattle
	dw CeladonGymEndBattleText8 ; 0x4b26 TextEndBattle
; 0x48a10

db $ff

CeladonGymText1: ; 0x48a11
	db $08 ; asm
	ld a, [$d77c]
	bit 1, a
	jr z, .asm_16064 ; 0x48a17
	bit 0, a
	jr nz, .asm_3b22c ; 0x48a1b
	call z, $4963
	call $30b6
	jr .asm_96252 ; 0x48a23
.asm_3b22c ; 0x48a25
	ld hl, UnnamedText_48a68
	call PrintText
	jr .asm_96252 ; 0x48a2b
.asm_16064 ; 0x48a2d
	ld hl, UnnamedText_48a5e
	call PrintText
	ld hl, $d72d
	set 6, [hl]
	set 7, [hl]
	ld hl, UnnamedText_48a63
	ld de, UnnamedText_48a63
	call $3354
	ldh a, [$8c]
	ld [$cf13], a
	call $336a
	call $32d7
	ld a, $4
	ld [$d05c], a
	ld a, $3
	ld [$d5ff], a
	ld [$da39], a
.asm_96252 ; 0x48a5b
	jp TextScriptEnd

UnnamedText_48a5e: ; 0x48a5e
	TX_FAR _UnnamedText_48a5e
	db $50
; 0x48a5e + 5 bytes

UnnamedText_48a63: ; 0x48a63
	TX_FAR _UnnamedText_48a63
	db $50
; 0x48a63 + 5 bytes

UnnamedText_48a68: ; 0x48a68
	TX_FAR _UnnamedText_48a68
	db $50
; 0x48a68 + 5 bytes

CeladonGymText9: ; 0x48a6d
UnnamedText_48a6d: ; 0x48a6d
	TX_FAR _UnnamedText_48a6d
	db $50
; 0x48a6d + 5 bytes

TM21Text: ; 0x48a72
	TX_FAR _ReceivedTM21Text ; 0x9d50c
	db $0B
	TX_FAR _TM21ExplanationText ; 0x9d520
	db $50
; 0x48a7c

TM21NoRoomText: ; 0x48a7c
	TX_FAR _TM21NoRoomText
	db $50
; 0x48a7c + 5 bytes

CeladonGymText2: ; 0x48a81
	db $08 ; asm
	ld hl, CeladonGymTrainerHeader0
	call LoadTrainerHeader
	jp TextScriptEnd

CeladonGymBattleText2: ; 0x48a8b
	TX_FAR _CeladonGymBattleText2
	db $50
; 0x48a8b + 5 bytes

CeladonGymEndBattleText2: ; 0x48a90
	TX_FAR _CeladonGymEndBattleText2
	db $50
; 0x48a90 + 5 bytes

CeladonGymAfterBattleText2: ; 0x48a95
	TX_FAR _CeladonGymAfterBattleText2
	db $50
; 0x48a95 + 5 bytes

CeladonGymText3: ; 0x48a9a
	db $08 ; asm
	ld hl, CeladonGymTrainerHeader2
	call LoadTrainerHeader
	jp TextScriptEnd

CeladonGymBattleText3: ; 0x48aa4
	TX_FAR _CeladonGymBattleText3
	db $50
; 0x48aa4 + 5 bytes

CeladonGymEndBattleText3: ; 0x48aa9
	TX_FAR _CeladonGymEndBattleText3
	db $50
; 0x48aa9 + 5 bytes

CeladonGymAfterBattleText3: ; 0x48aae
	TX_FAR _CeladonGymAfterBattleText3
	db $50
; 0x48aae + 5 bytes

CeladonGymText4: ; 0x48ab3
	db $08 ; asm
	ld hl, CeladonGymTrainerHeader3
	call LoadTrainerHeader
	jp TextScriptEnd

CeladonGymBattleText4: ; 0x48abd
	TX_FAR _CeladonGymBattleText4
	db $50
; 0x48abd + 5 bytes

CeladonGymEndBattleText4: ; 0x48ac2
	TX_FAR _CeladonGymEndBattleText4
	db $50
; 0x48ac2 + 5 bytes

CeladonGymAfterBattleText4: ; 0x48ac7
	TX_FAR _CeladonGymAfterBattleText4
	db $50
; 0x48ac7 + 5 bytes

CeladonGymText5: ; 0x48acc
	db $08 ; asm
	ld hl, CeladonGymTrainerHeader4
	call LoadTrainerHeader
	jp TextScriptEnd

CeladonGymBattleText5: ; 0x48ad6
	TX_FAR _CeladonGymBattleText5
	db $50
; 0x48ad6 + 5 bytes

CeladonGymEndBattleText5: ; 0x48adb
	TX_FAR _CeladonGymEndBattleText5
	db $50
; 0x48adb + 5 bytes

CeladonGymAfterBattleText5: ; 0x48ae0
	TX_FAR _CeladonGymAfterBattleText5
	db $50
; 0x48ae0 + 5 bytes

CeladonGymText6: ; 0x48ae5
	db $08 ; asm
	ld hl, CeladonGymTrainerHeader5
	call LoadTrainerHeader
	jp TextScriptEnd

CeladonGymBattleText6: ; 0x48aef
	TX_FAR _CeladonGymBattleText6
	db $50
; 0x48aef + 5 bytes

CeladonGymEndBattleText6: ; 0x48af4
	TX_FAR _CeladonGymEndBattleText6
	db $50
; 0x48af4 + 5 bytes

CeladonGymAfterBattleText6: ; 0x48af9
	TX_FAR _CeladonGymAfterBattleText6
	db $50
; 0x48af9 + 5 bytes

CeladonGymText7: ; 0x48afe
	db $08 ; asm
	ld hl, CeladonGymTrainerHeader6
	call LoadTrainerHeader
	jp TextScriptEnd

CeladonGymBattleText7: ; 0x48b08
	TX_FAR _CeladonGymBattleText7
	db $50
; 0x48b08 + 5 bytes

CeladonGymEndBattleText7: ; 0x48b0d
	TX_FAR _CeladonGymEndBattleText7
	db $50
; 0x48b0d + 5 bytes

CeladonGymAfterBattleText7: ; 0x48b12
	TX_FAR _CeladonGymAfterBattleText7
	db $50
; 0x48b12 + 5 bytes

CeladonGymText8: ; 0x48b17
	db $08 ; asm
	ld hl, CeladonGymTrainerHeader7
	call LoadTrainerHeader
	jp TextScriptEnd

CeladonGymBattleText8: ; 0x48b21
	TX_FAR _CeladonGymBattleText8
	db $50
; 0x48b21 + 5 bytes

CeladonGymEndBattleText8: ; 0x48b26
	TX_FAR _CeladonGymEndBattleText8
	db $50
; 0x48b26 + 5 bytes

CeladonGymAfterBattleText8: ; 0x48b2b
	TX_FAR _CeladonGymAfterBattleText8
	db $50
; 0x48b2b + 5 bytes

CeladonGymObject: ; 0x48b30 (size=84)
	db $3 ; border tile

	db $2 ; warps
	db $11, $4, $6, $ff
	db $11, $5, $6, $ff

	db $0 ; signs

	db $8 ; people
	db SPRITE_ERIKA, $3 + 4, $4 + 4, $ff, $d0, $41, ERIKA + $C8, $1 ; trainer
	db SPRITE_LASS, $b + 4, $2 + 4, $ff, $d3, $42, LASS + $C8, $11 ; trainer
	db SPRITE_FOULARD_WOMAN, $a + 4, $7 + 4, $ff, $d2, $43, BEAUTY + $C8, $1 ; trainer
	db SPRITE_LASS, $5 + 4, $9 + 4, $ff, $d0, $44, JR__TRAINER_F + $C8, $b ; trainer
	db SPRITE_FOULARD_WOMAN, $5 + 4, $1 + 4, $ff, $d0, $45, BEAUTY + $C8, $2 ; trainer
	db SPRITE_LASS, $3 + 4, $6 + 4, $ff, $d0, $46, LASS + $C8, $12 ; trainer
	db SPRITE_FOULARD_WOMAN, $3 + 4, $3 + 4, $ff, $d0, $47, BEAUTY + $C8, $3 ; trainer
	db SPRITE_LASS, $3 + 4, $5 + 4, $ff, $d0, $48, COOLTRAINER_F + $C8, $1 ; trainer

	; warp-to
	EVENT_DISP $5, $11, $4
	EVENT_DISP $5, $11, $5

CeladonGymBlocks: ; 0x48b84 45
	INCBIN "maps/celadongym.blk"

CeladonGameCorner_h: ; 0x48bb1 to 0x48bbd (12 bytes) (bank=12) (id=135)
	db $12 ; tileset
	db GAME_CORNER_HEIGHT, GAME_CORNER_WIDTH ; dimensions (y, x)
	dw CeladonGameCornerBlocks, CeladonGameCornerTexts, CeladonGameCornerScript ; blocks, texts, scripts
	db $00 ; connections

	dw CeladonGameCornerObject ; objects

CeladonGameCornerScript: ; 0x48bbd
	call Unknown_48bcf
	call $4bec
	call $3c3c
	ld hl, CeladonGameCornerScripts
	ld a, [$d65f]
	jp $3d97
; 0x48bcf

Unknown_48bcf: ; 0x48bcf
INCBIN "baserom.gbc",$48bcf,$48c12 - $48bcf

CeladonGameCornerScripts: ; 0x48c12
	dw CeladonGameCornerScript0, CeladonGameCornerScript1

INCBIN "baserom.gbc",$48c16,$2

CeladonGameCornerScript0: ; 0x48c18
	ret
; 0x48c19

CeladonGameCornerScript1: ; 0x48c19
INCBIN "baserom.gbc",$48c19,$71

CeladonGameCornerTexts: ; 0x48c8a
	dw CeladonGameCornerText1, CeladonGameCornerText2, CeladonGameCornerText3, CeladonGameCornerText4, CeladonGameCornerText5, CeladonGameCornerText6, CeladonGameCornerText7, CeladonGameCornerText8, CeladonGameCornerText9, CeladonGameCornerText10, CeladonGameCornerText11, CeladonGameCornerText12, CeladonGameCornerText13

CeladonGameCornerText1: ; 0x48ca4
	TX_FAR _CeladonGameCornerText1
	db $50

CeladonGameCornerText2: ; 0x48ca9
	db $08 ; asm
	call $4f1e
	ld hl, UnnamedText_48d22
	call PrintText
	call $35ec
	ld a, [$cc26]
	and a
	jr nz, .asm_c650b ; 0x48cba
	ld b,COIN_CASE
	call $3493
	jr z, .asm_ed086 ; 0x48cc1
	call $4f95
	jr nc, .asm_31338 ; 0x48cc6
	xor a
	ldh [$9f], a
	ldh [$a1], a
	ld a, $10
	ldh [$a0], a
	call $35a6
	jr nc, .asm_b6ef0 ; 0x48cd4
	ld hl, $4d31
	jr .asm_e2afd ; 0x48cd9
.asm_b6ef0 ; 0x48cdb
	xor a
	ldh [$9f], a
	ldh [$a1], a
	ld a, $10
	ldh [$a0], a
	ld hl, $ffa1
	ld de, $d349
	ld c, $3
	ld a, $c
	call Predef
	xor a
	ldh [$9f], a
	ldh [$a0], a
	ld a, $50
	ldh [$a1], a
	ld de, $d5a5
	ld hl, $ffa1
	ld c, $2
	ld a, $b
	call Predef
	call $4f1e
	ld hl, UnnamedText_48d27
	jr .asm_e2afd ; 0x48d0d
.asm_c650b ; 0x48d0f
	ld hl, UnnamedText_48d2c
	jr .asm_e2afd ; 0x48d12
.asm_31338 ; 0x48d14
	ld hl, UnnamedText_48d36
	jr .asm_e2afd ; 0x48d17
.asm_ed086 ; 0x48d19
	ld hl, UnnamedText_48d3b
.asm_e2afd ; 0x48d1c
	call PrintText
	jp TextScriptEnd

UnnamedText_48d22: ; 0x48d22
	TX_FAR _UnnamedText_48d22
	db $50
; 0x48d27

UnnamedText_48d27: ; 0x48d27
	TX_FAR _UnnamedText_48d27
	db $50
; 0x48d2c

UnnamedText_48d2c: ; 0x48d2c
	TX_FAR _UnnamedText_48d2c
	db $50
; 0x48d31

UnnamedText_48d31: ; 0x48d31
	TX_FAR _UnnamedText_48d31
	db $50
; 0x48d36

UnnamedText_48d36: ; 0x48d36
	TX_FAR _UnnamedText_48d36
	db $50
; 0x48d3b

UnnamedText_48d3b: ; 0x48d3b
	TX_FAR _UnnamedText_48d3b
	db $50
; 0x48d40

CeladonGameCornerText3: ; 0x48d40
	TX_FAR _CeladonGameCornerText3
	db $50

CeladonGameCornerText4: ; 0x48d45
	TX_FAR _CeladonGameCornerText4
	db $50

CeladonGameCornerText5: ; 0x48d4a
	db $08 ; asm
	ld a, [$d77e]
	bit 2, a
	jr nz, .asm_d0957 ; 0x48d50
	ld hl, UnnamedText_48d9c
	call PrintText
	ld b, COIN_CASE
	call $3493
	jr z, .asm_5aef9 ; 0x48d5d
	call $4f95
	jr nc, .asm_98546 ; 0x48d62
	xor a
	ldh [$9f], a
	ldh [$a0], a
	ld a, $10
	ldh [$a1], a
	ld de, $d5a5
	ld hl, $ffa1
	ld c, $2
	ld a, $b
	call Predef
	ld hl, $d77e
	set 2, [hl]
	ld a, $1
	ld [$cc3c], a
	ld hl, Received10CoinsText
	jr .asm_c7d1a ; 0x48d87
.asm_d0957 ; 0x48d89
	ld hl, UnnamedText_48dac
	jr .asm_c7d1a ; 0x48d8c
.asm_98546 ; 0x48d8e
	ld hl, UnnamedText_48da7
	jr .asm_c7d1a ; 0x48d91
.asm_5aef9 ; 0x48d93
	ld hl, UnnamedText_48f19
.asm_c7d1a ; 0x48d96
	call PrintText
	jp TextScriptEnd

UnnamedText_48d9c: ; 0x48d9c
	TX_FAR _UnnamedText_48d9c
	db $50
; 0x48d9c + 5 bytes

Received10CoinsText: ; 0x48da1
	TX_FAR _Received10CoinsText ; 0x9daa9
	db $0B, $50

UnnamedText_48da7: ; 0x48da7
	TX_FAR _UnnamedText_48da7
	db $50
; 0x48da7 + 5 bytes

UnnamedText_48dac: ; 0x48dac
	TX_FAR _UnnamedText_48dac
	db $50
; 0x48dac + 5 bytes

CeladonGameCornerText6: ; 0x48db1
	TX_FAR _CeladonGameCornerText6
	db $50

CeladonGameCornerText7: ; 0x48db6
	db $08 ; asm
	ld a, [$d77c]
	bit 1, a
	ld hl, $4dca
	jr z, .asm_be3fd ; 0x48dbf
	ld hl, $4dcf
.asm_be3fd ; 0x48dc4
	call PrintText
	jp TextScriptEnd

UnnamedText_48dca: ; 0x48dca
	TX_FAR _UnnamedText_48dca
	db $50
; 0x48dca + 5 bytes

UnnamedText_48dcf: ; 0x48dcf
	TX_FAR _UnnamedText_48dcf
	db $50
; 0x48dcf + 5 bytes

CeladonGameCornerText8: ; 0x48dd4
	TX_FAR _CeladonGameCornerText8
	db $50

CeladonGameCornerText9: ; 0x48dd9
	db $08 ; asm
	ld a, [$d77e]
	bit 4, a
	jr nz, .asm_ed8bc ; 0x48ddf
	ld hl, UnnamedText_48e26
	call PrintText
	ld b, COIN_CASE
	call $3493
	jr z, .asm_df794 ; 0x48dec
	call $4f95
	jr nc, .asm_f17c3 ; 0x48df1
	xor a
	ldh [$9f], a
	ldh [$a0], a
	ld a, $20
	ldh [$a1], a
	ld de, $d5a5
	ld hl, $ffa1
	ld c, $2
	ld a, $b
	call Predef
	ld hl, $d77e
	set 4, [hl]
	ld hl, Received20CoinsText
	jr .asm_0ddc2 ; 0x48e11
.asm_ed8bc ; 0x48e13
	ld hl, UnnamedText_48e36
	jr .asm_0ddc2 ; 0x48e16
.asm_f17c3 ; 0x48e18
	ld hl, UnnamedText_48e31
	jr .asm_0ddc2 ; 0x48e1b
.asm_df794 ; 0x48e1d
	ld hl, UnnamedText_48f19
.asm_0ddc2 ; 0x48e20
	call PrintText
	jp TextScriptEnd

UnnamedText_48e26: ; 0x48e26
	TX_FAR _UnnamedText_48e26
	db $50
; 0x48e26 + 5 bytes

Received20CoinsText: ; 0x48e2b
	TX_FAR _Received20CoinsText ; 0x9dc4f
	db $0B, $50
; 0x48e31

UnnamedText_48e31: ; 0x48e31
	TX_FAR _UnnamedText_48e31
	db $50
; 0x48e31 + 5 bytes

UnnamedText_48e36: ; 0x48e36
	TX_FAR _UnnamedText_48e36
	db $50
; 0x48e36 + 5 bytes

CeladonGameCornerText10: ; 0x48e3b
	db $08 ; asm
	ld a, [$d77e]
	bit 3, a
	jr nz, .asm_ff080 ; 0x48e41
	ld hl, $4e88
	call PrintText
	ld b,COIN_CASE
	call $3493
	jr z, .asm_4fb0c ; 0x48e4e
	call $4f95
	jr z, .asm_9505a ; 0x48e53
	xor a
	ldh [$9f], a
	ldh [$a0], a
	ld a, $20
	ldh [$a1], a
	ld de, $d5a5
	ld hl, $ffa1
	ld c, $2
	ld a, $b
	call Predef
	ld hl, $d77e
	set 3, [hl]
	ld hl, UnnamedText_48e8d
	jr .asm_78d65 ; 0x48e73
.asm_ff080 ; 0x48e75
	ld hl, UnnamedText_48e98
	jr .asm_78d65 ; 0x48e78
.asm_9505a ; 0x48e7a
	ld hl, UnnamedText_48e93
	jr .asm_78d65 ; 0x48e7d
.asm_4fb0c ; 0x48e7f
	ld hl, UnnamedText_48f19
.asm_78d65 ; 0x48e82
	call PrintText
	jp TextScriptEnd

UnnamedText_48e88: ; 0x48e88
	TX_FAR _UnnamedText_48e88
	db $50
; 0x48e88 + 5 bytes

UnnamedText_48e8d: ; 0x48e8d
	TX_FAR _UnnamedText_48e8d ; 0x9dceb
	db $0B, $50
; 0x48e93

UnnamedText_48e93: ; 0x48e93
	TX_FAR _UnnamedText_48e93
	db $50
; 0x48e93 + 5 bytes

UnnamedText_48e98: ; 0x48e98
	TX_FAR _UnnamedText_48e98
	db $50
; 0x48e98 + 5 bytes

CeladonGameCornerText11: ; 0x48e9d
	db $08 ; asm
	ld hl, UnnamedText_48ece
	call PrintText
	ld hl, $d72d
	set 6, [hl]
	set 7, [hl]
	ld hl, UnnamedText_48ed3
	ld de, UnnamedText_48ed3
	call $3354
	ldh a, [$8c]
	ld [$cf13], a
	call $336a
	call $32d7
	xor a
	ldh [$b4], a
	ldh [$b3], a
	ldh [$b2], a
	ld a, $1
	ld [$d65f], a
	jp TextScriptEnd

UnnamedText_48ece: ; 0x48ece
	TX_FAR _UnnamedText_48ece
	db $50
; 0x48ece + 5 bytes

UnnamedText_48ed3: ; 0x48ed3
	TX_FAR _UnnamedText_48ed3
	db $50
; 0x48ed3 + 5 bytes

CeladonGameCornerText13: ; 0x48ed8
	TX_FAR _UnnamedText_48ed8
	db $50
; 0x48ed8 + 5 bytes

CeladonGameCornerText12: ; 0x48edd
	db $08 ; asm
	ld a, $1
	ld [$cc3c], a
	ld hl, UnnamedText_48f09
	call PrintText
	call $3748
	ld a, $ad
	call $23b1
	call $3748
	ld hl, $d77e
	set 1, [hl]
	ld a, $43
	ld [$d09f], a
	ld bc, $0208
	ld a, $17
	call Predef
	jp TextScriptEnd

UnnamedText_48f09: ; 0x48f09
	TX_FAR _UnnamedText_48f09 ; 0x9ddb0
	db $8
	ld a, $9d
	call $23b1
	call $3748
	jp TextScriptEnd
; 0x48f19

UnnamedText_48f19: ; 0x48f19
	TX_FAR _UnnamedText_48f19
	db $50
; 0x48f19 + 5 bytes

INCBIN "baserom.gbc",$48f1e,$82

CeladonGameCornerObject: ; 0x48fa0 (size=99)
	db $f ; border tile

	db $3 ; warps
	db $11, $f, $7, $ff
	db $11, $10, $7, $ff
	db $4, $11, $1, ROCKET_HIDEOUT_1

	db $1 ; signs
	db $4, $9, $c ; CeladonGameCornerText12

	db $b ; people
	db SPRITE_FOULARD_WOMAN, $6 + 4, $2 + 4, $ff, $d0, $1 ; person
	db SPRITE_MART_GUY, $6 + 4, $5 + 4, $ff, $d0, $2 ; person
	db SPRITE_FAT_BALD_GUY, $a + 4, $2 + 4, $ff, $d2, $3 ; person
	db SPRITE_FOULARD_WOMAN, $d + 4, $2 + 4, $ff, $d2, $4 ; person
	db SPRITE_FISHER, $b + 4, $5 + 4, $ff, $d3, $5 ; person
	db SPRITE_MOM_GEISHA, $b + 4, $8 + 4, $ff, $d2, $6 ; person
	db SPRITE_GYM_HELPER, $e + 4, $8 + 4, $ff, $d2, $7 ; person
	db SPRITE_GAMBLER, $f + 4, $b + 4, $ff, $d3, $8 ; person
	db SPRITE_MART_GUY, $b + 4, $e + 4, $ff, $d2, $9 ; person
	db SPRITE_GENTLEMAN, $d + 4, $11 + 4, $ff, $d3, $a ; person
	db SPRITE_ROCKET, $5 + 4, $9 + 4, $ff, $d1, $4b, ROCKET + $C8, $7 ; trainer

	; warp-to
	EVENT_DISP $a, $11, $f
	EVENT_DISP $a, $11, $10
	EVENT_DISP $a, $4, $11 ; ROCKET_HIDEOUT_1

CeladonGameCornerBlocks: ; 0x49003 90
	INCBIN "maps/celadongamecorner.blk"

CeladonMart5_h: ; 0x4905d to 0x49069 (12 bytes) (bank=12) (id=136)
	db $12 ; tileset
	db CELADON_HOUSE_HEIGHT, CELADON_HOUSE_WIDTH ; dimensions (y, x)
	dw CeladonMart5Blocks, CeladonMart5Texts, CeladonMart5Script ; blocks, texts, scripts
	db $00 ; connections

	dw CeladonMart5Object ; objects

CeladonMart5Script: ; 0x49069
	jp $3c3c
; 0x4906c

CeladonMart5Texts: ; 0x4906c
	dw CeladonMart5Text1, CeladonMart5Text2, CeladonMart5Text3, CeladonMart5Text4, CeladonMart5Text5

CeladonMart5Text1: ; 0x49076
	TX_FAR _CeladonMart5Text1
	db $50

CeladonMart5Text2: ; 0x4907b
	TX_FAR _CeladonMart5Text2
	db $50

CeladonMart5Text5: ; 0x49080
	TX_FAR _CeladonMart5Text5
	db $50

CeladonMart5Object: ; 0x49085 (size=55)
	db $f ; border tile

	db $3 ; warps
	db $1, $c, $0, CELADON_MART_ROOF
	db $1, $10, $1, CELADON_MART_4
	db $1, $1, $0, CELADON_MART_ELEVATOR

	db $1 ; signs
	db $1, $e, $5 ; CeladonMart5Text5

	db $4 ; people
	db SPRITE_GENTLEMAN, $5 + 4, $e + 4, $fe, $1, $1 ; person
	db SPRITE_SAILOR, $6 + 4, $2 + 4, $ff, $ff, $2 ; person
	db SPRITE_MART_GUY, $3 + 4, $5 + 4, $ff, $d0, $3 ; person
	db SPRITE_MART_GUY, $3 + 4, $6 + 4, $ff, $d0, $4 ; person

	; warp-to
	EVENT_DISP $a, $1, $c ; CELADON_MART_ROOF
	EVENT_DISP $a, $1, $10 ; CELADON_MART_4
	EVENT_DISP $a, $1, $1 ; CELADON_MART_ELEVATOR

CeladonMart5Blocks: ; 0x490bc 40
	INCBIN "maps/celadonhouse.blk"

CeladonPrizeRoom_h: ; 0x490e4 to 0x490f0 (12 bytes) (bank=12) (id=137)
	db $12 ; tileset
	db CELADONPRIZE_ROOM_HEIGHT, CELADONPRIZE_ROOM_WIDTH ; dimensions (y, x)
	dw CeladonPrizeRoomBlocks, CeladonPrizeRoomTexts, CeladonPrizeRoomScript ; blocks, texts, scripts
	db $00 ; connections

	dw CeladonPrizeRoomObject ; objects

CeladonPrizeRoomScript: ; 0x490f0
	jp $3c3c
; 0x490f3

CeladonPrizeRoomTexts:
	dw CeladonPrizeRoomText1, CeladonPrizeRoomText2, CeladonPrizeRoomText3, CeladonPrizeRoomText3, CeladonPrizeRoomText3

CeladonPrizeRoomText1: ; 0x490fd
	TX_FAR _CeladonPrizeRoomText1
	db $50

CeladonPrizeRoomText2: ; 0x49102
	TX_FAR _CeladonPrizeRoomText2
	db $50

CeladonPrizeRoomText3: ; 0x49107
	db $f7

CeladonPrizeRoomObject: ; 0x49108 (size=41)
	db $f ; border tile

	db $2 ; warps
	db $7, $4, $9, $ff
	db $7, $5, $9, $ff

	db $3 ; signs
	db $2, $2, $3 ; CeladonPrizeRoomText3
	db $2, $4, $4 ; CeladonPrizeRoomText4
	db $2, $6, $5 ; CeladonPrizeRoomText5

	db $2 ; people
	db SPRITE_BALDING_GUY, $4 + 4, $1 + 4, $ff, $ff, $1 ; person
	db SPRITE_GAMBLER, $3 + 4, $7 + 4, $fe, $2, $2 ; person

	; warp-to
	EVENT_DISP $5, $7, $4
	EVENT_DISP $5, $7, $5

CeladonPrizeRoomBlocks: ; 0x49131 20
	INCBIN "maps/celadonprizeroom.blk"

CeladonDiner_h: ; 0x49145 to 0x49151 (12 bytes) (bank=12) (id=138)
	db $12 ; tileset
	db CELADON_DINER_HEIGHT, CELADON_DINER_WIDTH ; dimensions (y, x)
	dw CeladonDinerBlocks, CeladonDinerTexts, CeladonDinerScript ; blocks, texts, scripts
	db $00 ; connections

	dw CeladonDinerObject ; objects

CeladonDinerScript: ; 0x49151
	call $3c3c
	ret
; 0x49155

CeladonDinerTexts: ; 0x49155
	dw CeladonDinerText1, CeladonDinerText2, CeladonDinerText3, CeladonDinerText4, CeladonDinerText5

CeladonDinerText1: ; 0x4915f
	TX_FAR _CeladonDinerText1
	db $50

CeladonDinerText2: ; 0x49164
	TX_FAR _CeladonDinerText2
	db $50

CeladonDinerText3: ; 0x49169
	TX_FAR _CeladonDinerText3
	db $50

CeladonDinerText4: ; 0x4916e
	TX_FAR _CeladonDinerText4
	db $50

CeladonDinerText5: ; 0x49173
	db $08 ; asm
	ld a, [$d783]
	bit 0, a
	jr nz, .asm_eb14d ; 0x49179
	ld hl, UnnamedText_491a7
	call PrintText
	ld bc, (COIN_CASE << 8) | 1
	call GiveItem
	jr nc, .asm_78e93 ; 0x49187
	ld hl, $d783
	set 0, [hl]
	ld hl, ReceivedCoinCaseText
	call PrintText
	jr .asm_68b61 ; 0x49194
.asm_78e93 ; 0x49196
	ld hl, CoinCaseNoRoomText
	call PrintText
	jr .asm_68b61 ; 0x4919c
.asm_eb14d ; 0x4919e
	ld hl, UnnamedText_491b7
	call PrintText
.asm_68b61 ; 0x491a4
	jp TextScriptEnd

UnnamedText_491a7: ; 0x491a7
	TX_FAR _UnnamedText_491a7
	db $50
; 0x491a7 + 5 bytes

ReceivedCoinCaseText: ; 0x491ac
	TX_FAR _ReceivedCoinCaseText ; 0x9e07a
	db $11, $50
; 0x491b2

CoinCaseNoRoomText: ; 0x491b2
	TX_FAR _CoinCaseNoRoomText
	db $50
; 0x491b2 + 5 bytes

UnnamedText_491b7: ; 0x491b7
	TX_FAR _UnnamedText_491b7
	db $50
; 0x491b7 + 5 bytes

CeladonDinerObject: ; 0x491bc (size=50)
	db $f ; border tile

	db $2 ; warps
	db $7, $3, $a, $ff
	db $7, $4, $a, $ff

	db $0 ; signs

	db $5 ; people
	db SPRITE_COOK, $5 + 4, $8 + 4, $fe, $2, $1 ; person
	db SPRITE_MOM_GEISHA, $2 + 4, $7 + 4, $ff, $ff, $2 ; person
	db SPRITE_FAT_BALD_GUY, $4 + 4, $1 + 4, $ff, $d0, $3 ; person
	db SPRITE_FISHER2, $3 + 4, $5 + 4, $ff, $d3, $4 ; person
	db SPRITE_GYM_HELPER, $1 + 4, $0 + 4, $ff, $d0, $5 ; person

	; warp-to
	EVENT_DISP $5, $7, $3
	EVENT_DISP $5, $7, $4

CeladonDinerBlocks: ; 0x491ee 20
	INCBIN "maps/celadondiner.blk"

CeladonHouse_h: ; 0x49202 to 0x4920e (12 bytes) (bank=12) (id=139)
	db $13 ; tileset
	db CELADON_HOUSE_2_HEIGHT, CELADON_HOUSE_2_WIDTH ; dimensions (y, x)
	dw CeladonHouseBlocks, CeladonHouseTexts, CeladonHouseScript ; blocks, texts, scripts
	db $00 ; connections

	dw CeladonHouseObject ; objects

CeladonHouseScript: ; 0x4920e
	call $3c3c
	ret
; 0x49212

CeladonHouseTexts: ; 0x49212
	dw CeladonHouseText1, CeladonHouseText2, CeladonHouseText3

CeladonHouseText1: ; 0x49218
	TX_FAR _CeladonHouseText1
	db $50

CeladonHouseText2: ; 0x4921d
	TX_FAR _CeladonHouseText2
	db $50

CeladonHouseText3: ; 0x49222
	TX_FAR _CeladonHouseText3
	db $50

CeladonHouseObject: ; 0x49227 (size=38)
	db $f ; border tile

	db $2 ; warps
	db $7, $2, $b, $ff
	db $7, $3, $b, $ff

	db $0 ; signs

	db $3 ; people
	db SPRITE_OLD_PERSON, $2 + 4, $4 + 4, $ff, $d0, $1 ; person
	db SPRITE_ROCKET, $4 + 4, $1 + 4, $fe, $0, $2 ; person
	db SPRITE_SAILOR, $6 + 4, $5 + 4, $ff, $d2, $3 ; person

	; warp-to
	EVENT_DISP $4, $7, $2
	EVENT_DISP $4, $7, $3

CeladonHouseBlocks: ; 0x4924d 16
	INCBIN "maps/celadonhouse2.blk"

CeladonHotel_h: ; 0x4925d to 0x49269 (12 bytes) (bank=12) (id=140)
	db $06 ; tileset
	db CELADONHOTEL_HEIGHT, CELADONHOTEL_WIDTH ; dimensions (y, x)
	dw CeladonHotelBlocks, CeladonHotelTexts, CeladonHotelScript ; blocks, texts, scripts
	db $00 ; connections

	dw CeladonHotelObject ; objects

CeladonHotelScript: ; 0x49269
	jp $3c3c
; 0x4926c

CeladonHotelTexts: ; 0x4926c
	dw CeladonHotelText1, CeladonHotelText2, CeladonHotelText3

CeladonHotelText1: ; 0x49272
	TX_FAR _CeladonHotelText1
	db $50

CeladonHotelText2: ; 0x49277
	TX_FAR _CeladonHotelText2
	db $50

CeladonHotelText3: ; 0x4927c
	TX_FAR _CeladonHotelText3
	db $50

CeladonHotelObject: ; 0x49281 (size=38)
	db $0 ; border tile

	db $2 ; warps
	db $7, $3, $c, $ff
	db $7, $4, $c, $ff

	db $0 ; signs

	db $3 ; people
	db SPRITE_OLD_MEDIUM_WOMAN, $1 + 4, $3 + 4, $ff, $d0, $1 ; person
	db SPRITE_FOULARD_WOMAN, $4 + 4, $2 + 4, $ff, $ff, $2 ; person
	db SPRITE_BLACK_HAIR_BOY_2, $4 + 4, $8 + 4, $fe, $2, $3 ; person

	; warp-to
	EVENT_DISP $7, $7, $3
	EVENT_DISP $7, $7, $4

CeladonHotelBlocks: ; 0x492a7 28
	INCBIN "maps/celadonhotel.blk"

MtMoonPokecenter_h: ; 0x492c3 to 0x492cf (12 bytes) (bank=12) (id=68)
	db $06 ; tileset
	db MT_MOON_POKECENTER_HEIGHT, MT_MOON_POKECENTER_WIDTH ; dimensions (y, x)
	dw MtMoonPokecenterBlocks, MtMoonPokecenterTexts, MtMoonPokecenterScript ; blocks, texts, scripts
	db $00 ; connections

	dw MtMoonPokecenterObject ; objects

MtMoonPokecenterScript: ; 0x492cf
	call $22fa
	jp $3c3c
; 0x492d5

MtMoonPokecenterTexts:
	dw MtMoonPokecenterText1, MtMoonPokecenterText2, MtMoonPokecenterText3, MtMoonPokecenterText4, MtMoonPokecenterText5, MtMoonPokecenterText6

MtMoonPokecenterText1: ; 0x492e0
	db $ff

MtMoonPokecenterText2: ; 0x492e2
	TX_FAR _MtMoonPokecenterText1
	db $50

MtMoonPokecenterText3: ; 0x492e7
	TX_FAR _MtMoonPokecenterText3
	db $50

MtMoonPokecenterText4: ; 0x492ec
	db $08 ; asm
	ld a, [$d7c6]
	add a
	jp c, .asm_49353
	ld hl, UnnamedText_4935c
	call PrintText
	ld a, $13
	ld [$d125], a
	call $30e8
	call $35ec
	ld a, [$cc26]
	and a
	jp nz, .asm_4934e
	ldh [$9f], a
	ldh [$a1], a
	ld a, $5
	ldh [$a0], a
	call $35a6
	jr nc, .asm_faa09 ; 0x49317
	ld hl, UnnamedText_49366
	jr .asm_49356 ; 0x4931c
.asm_faa09 ; 0x4931e
	ld bc,(MAGIKARP << 8) | 5
	call GivePokemon
	jr nc, .asm_49359 ; 0x49324
	xor a
	ld [W_WHICHTRADE], a
	ld [$cd3f], a
	ld a, $5
	ld [$cd3e], a
	ld hl, $cd3f
	ld de, $d349
	ld c, $3
	ld a, $c
	call Predef
	ld a, $13
	ld [$d125], a
	call $30e8
	ld hl, $d7c6
	set 7, [hl]
	jr .asm_49359 ; 0x4934c
.asm_4934e ; 0x4934e
	ld hl, UnnamedText_49361
	jr .asm_49356 ; 0x49351
.asm_49353 ; 0x49353
	ld hl, UnnamedText_4936b
.asm_49356 ; 0x49356
	call PrintText
.asm_49359 ; 0x49359
	jp TextScriptEnd

UnnamedText_4935c: ; 0x4935c
	TX_FAR _UnnamedText_4935c
	db $50
; 0x4935c + 5 bytes

UnnamedText_49361: ; 0x49361
	TX_FAR _UnnamedText_49361
	db $50
; 0x49361 + 5 bytes

UnnamedText_49366: ; 0x49366
	TX_FAR _UnnamedText_49366
	db $50
; 0x49366 + 5 bytes

UnnamedText_4936b: ; 0x4936b
	TX_FAR _UnnamedText_4936b
	db $50
; 0x4936b + 5 bytes

MtMoonPokecenterText5: ; 0x49370
	TX_FAR _MtMoonPokecenterText5
	db $50

MtMoonPokecenterText6:
	db $f6

MtMoonPokecenterObject: ; 0x49376 (size=56)
	db $0 ; border tile

	db $2 ; warps
	db $7, $3, $0, $ff
	db $7, $4, $0, $ff

	db $0 ; signs

	db $6 ; people
	db SPRITE_NURSE, $1 + 4, $3 + 4, $ff, $d0, $1 ; person
	db SPRITE_BUG_CATCHER, $3 + 4, $4 + 4, $ff, $d1, $2 ; person
	db SPRITE_GENTLEMAN, $3 + 4, $7 + 4, $ff, $d1, $3 ; person
	db SPRITE_FAT_BALD_GUY, $6 + 4, $a + 4, $fe, $2, $4 ; person
	db SPRITE_CLIPBOARD, $2 + 4, $7 + 4, $ff, $ff, $5 ; person
	db SPRITE_CABLE_CLUB_WOMAN, $2 + 4, $b + 4, $ff, $d0, $6 ; person

	; warp-to
	EVENT_DISP $7, $7, $3
	EVENT_DISP $7, $7, $4

RockTunnelPokecenter_h: ; 0x493ae to 0x493ba (12 bytes) (id=81)
	db $06 ; tileset
	db ROCK_TUNNEL_POKECENTER_HEIGHT, ROCK_TUNNEL_POKECENTER_WIDTH ; dimensions (y, x)
	dw RockTunnelPokecenterBlocks, RockTunnelPokecenterTexts, RockTunnelPokecenterScript ; blocks, texts, scripts
	db $00 ; connections

	dw RockTunnelPokecenterObject ; objects

RockTunnelPokecenterScript: ; 0x493ba
	call $22fa
	jp $3c3c
; 0x493c0

RockTunnelPokecenterTexts:
	dw RockTunnelPokecenterText1, RockTunnelPokecenterText2, RockTunnelPokecenterText3, RockTunnelPokecenterText4

RockTunnelPokecenterText1: ; 0x493c8
	db $ff

RockTunnelPokecenterText2: ; 0x493c9
	TX_FAR _RockTunnelPokecenterText1
	db $50

RockTunnelPokecenterText3: ; 0x493ce
	TX_FAR _RockTunnelPokecenterText3
	db $50

RockTunnelPokecenterText4: ; 0x493d3
	db $f6

RockTunnelPokecenterObject: ; 0x493d4 (size=44)
	db $0 ; border tile

	db $2 ; warps
	db $7, $3, $0, $ff
	db $7, $4, $0, $ff

	db $0 ; signs

	db $4 ; people
	db SPRITE_NURSE, $1 + 4, $3 + 4, $ff, $d0, $1 ; person
	db SPRITE_GENTLEMAN, $3 + 4, $7 + 4, $fe, $2, $2 ; person
	db SPRITE_FISHER2, $5 + 4, $2 + 4, $ff, $ff, $3 ; person
	db SPRITE_CABLE_CLUB_WOMAN, $2 + 4, $b + 4, $ff, $d0, $4 ; person

	; warp-to
	EVENT_DISP $7, $7, $3
	EVENT_DISP $7, $7, $4

Route11Gate_h: ; 0x49400 to 0x4940c (12 bytes) (id=84)
	db $0c ; tileset
	db ROUTE_11_GATE_1F_HEIGHT, ROUTE_11_GATE_1F_WIDTH ; dimensions (y, x)
	dw Route11GateBlocks, Route11GateTexts, Route11GateScript ; blocks, texts, scripts
	db $00 ; connections

	dw Route11GateObject ; objects

Route11GateScript: ; 0x4940c
	jp $3c3c
; 0x4940f

Route11GateTexts: ; 0x4940f
	dw Route11GateText1

Route11GateText1: ; 0x49411
	TX_FAR _Route11GateText1
	db $50

Route11GateObject: ; 0x49416 (size=50)
	db $a ; border tile

	db $5 ; warps
	db $4, $0, $0, $ff
	db $5, $0, $1, $ff
	db $4, $7, $2, $ff
	db $5, $7, $3, $ff
	db $8, $6, $0, ROUTE_11_GATE_2F

	db $0 ; signs

	db $1 ; people
	db SPRITE_GUARD, $1 + 4, $4 + 4, $ff, $ff, $1 ; person

	; warp-to
	EVENT_DISP $4, $4, $0
	EVENT_DISP $4, $5, $0
	EVENT_DISP $4, $4, $7
	EVENT_DISP $4, $5, $7
	EVENT_DISP $4, $8, $6 ; ROUTE_11_GATE_2F

Route11GateUpstairs_h: ; 0x49448 to 0x49454 (12 bytes) (id=86)
	db $0c ; tileset
	db ROUTE_11_GATE_2F_HEIGHT, ROUTE_11_GATE_2F_WIDTH ; dimensions (y, x)
	dw Route11GateUpstairsBlocks, Route11GateUpstairsTexts, Route11GateUpstairsScript ; blocks, texts, scripts
	db $00 ; connections

	dw Route11GateUpstairsObject ; objects

Route11GateUpstairsScript: ; 0x49454
	jp $3c3f
; 0x49457

Route11GateUpstairsTexts:
	dw Route11GateUpstairsText1, Route11GateUpstairsText2, Route11GateUpstairsText3, Route11GateUpstairsText4

Route11GateUpstairsText1: ; 0x4945f
	db $08 ; asm
	xor a
	ld [W_WHICHTRADE], a
	ld a, $54
	call Predef
asm_49469:
	jp TextScriptEnd

Route11GateUpstairsText2: ; 0x4946c
	db $8
	ld a, [$d7d6]
	add a
	jr c, .asm_4949b ; 0x49471 $28
	ld a, $1e
	ld [$ff00+$db], a
	ld a, $47
	ld [$ff00+$dc], a
	ld [$d11e], a
	call $2fcf
	ld h, d
	ld l, e
	ld de, $cc5b
	ld bc, $000d
	call CopyData
	ld a, $62
	call Predef
	ld a, [$ff00+$db]
	dec a
	jr nz, .asm_494a1 ; 0x49494 $b
	ld hl, $d7d6
	set 7, [hl]
.asm_4949b
	ld hl, UnnamedText_494a3
	call PrintText
.asm_494a1
	jr asm_49469 ; 0x494a1 $c6
; 0x494a3

UnnamedText_494a3: ; 0x494a3
	TX_FAR _UnnamedText_494a3
	db $50
; 0x494a3 + 5 bytes

Route11GateUpstairsText3: ; 0x494a8
	db $08 ; asm
	ld a, [$c109]
	cp $4
	jp nz, Unnamed_55c9
	ld a, [$d7d8]
	bit 7, a
	ld hl, UnnamedText_494c4
	jr z, .asm_5ac80 ; 0x494b9
	ld hl, UnnamedText_494c9
.asm_5ac80 ; 0x494be
	call PrintText
	jp TextScriptEnd

UnnamedText_494c4: ; 0x494c4
	TX_FAR _UnnamedText_494c4
	db $50
; 0x494c4 + 5 bytes

UnnamedText_494c9: ; 0x494c9
	TX_FAR _UnnamedText_494c9
	db $50
; 0x494c9 + 5 bytes

Route11GateUpstairsText4: ; 0x494ce
	db $8
	ld hl, $54d5
	jp Unnamed_55c9
; 0x494d5

UnnamedText_494d5: ; 0x494d5
	TX_FAR _UnnamedText_494d5
	db $50
; 0x494d5 + 5 bytes

Route11GateUpstairsObject: ; 0x494da (size=30)
	db $a ; border tile

	db $1 ; warps
	db $7, $7, $4, ROUTE_11_GATE_1F

	db $2 ; signs
	db $2, $1, $3 ; Route11GateUpstairsText3
	db $2, $6, $4 ; Route11GateUpstairsText4

	db $2 ; people
	db SPRITE_BUG_CATCHER, $2 + 4, $4 + 4, $fe, $2, $1 ; person
	db SPRITE_OAK_AIDE, $6 + 4, $2 + 4, $ff, $ff, $2 ; person

	; warp-to
	EVENT_DISP $4, $7, $7 ; ROUTE_11_GATE_1F

Route12Gate_h: ; 0x494f8 to 0x49504 (12 bytes) (id=87)
	db $0c ; tileset
	db ROUTE_12_GATE_HEIGHT, ROUTE_12_GATE_WIDTH ; dimensions (y, x)
	dw Route12GateBlocks, Route12GateTexts, Route12GateScript ; blocks, texts, scripts
	db $00 ; connections

	dw Route12GateObject ; objects

Route12GateScript: ; 0x49504
	jp $3c3c
; 0x49507

Route12GateTexts: ; 0x49507
	dw Route12GateText1

Route12GateText1: ; 0x49509
	TX_FAR _Route12GateText1
	db $50

Route12GateObject: ; 0x4950e (size=50)
	db $a ; border tile

	db $5 ; warps
	db $0, $4, $0, $ff
	db $0, $5, $1, $ff
	db $7, $4, $2, $ff
	db $7, $5, $2, $ff
	db $6, $8, $0, ROUTE_12_GATE_2F

	db $0 ; signs

	db $1 ; people
	db SPRITE_GUARD, $3 + 4, $1 + 4, $ff, $ff, $1 ; person

	; warp-to
	EVENT_DISP $5, $0, $4
	EVENT_DISP $5, $0, $5
	EVENT_DISP $5, $7, $4
	EVENT_DISP $5, $7, $5
	EVENT_DISP $5, $6, $8 ; ROUTE_12_GATE_2F

Route12GateBlocks: ; 0x49540 20
	INCBIN "maps/route12gate.blk"

Route12GateUpstairs_h: ; 0x49554 to 0x49560 (12 bytes) (id=195)
	db $0c ; tileset
	db ROUTE_12_GATE_2F_HEIGHT, ROUTE_12_GATE_2F_WIDTH ; dimensions (y, x)
	dw Route12GateUpstairsBlocks, Route12GateUpstairsTexts, Route12GateUpstairsScript ; blocks, texts, scripts
	db $00 ; connections

	dw Route12GateUpstairsObject ; objects

Route12GateUpstairsScript: ; 0x49560
	jp $3c3f
; 0x49563

Route12GateUpstairsTexts: ; 0x49563
	dw Route12GateUpstairsText1, Route12GateUpstairsText2, Route12GateUpstairsText3

Route12GateUpstairsText1: ; 0x49569
	db $08 ; asm
	ld a, [$d7d7]
	rrca
	jr c, .asm_0ad3c ; 0x4956e
	ld hl, TM39PreReceiveText
	call PrintText
	ld bc, (TM_39 << 8) | 1
	call GiveItem
	jr nc, .asm_4c2be ; 0x4957c
	ld hl, ReceivedTM39Text
	call PrintText
	ld hl, $d7d7
	set 0, [hl]
	jr .asm_4ba56 ; 0x49589
.asm_4c2be ; 0x4958b
	ld hl, TM39NoRoomText
	call PrintText
	jr .asm_4ba56 ; 0x49591
.asm_0ad3c ; 0x49593
	ld hl, TM39ExplanationText
	call PrintText
.asm_4ba56 ; 0x49599
	jp TextScriptEnd

TM39PreReceiveText: ; 0x4959c
	TX_FAR _TM39PreReceiveText
	db $50
; 0x4959c + 5 bytes

ReceivedTM39Text: ; 0x495a1
	TX_FAR _ReceivedTM39Text ; 0x8c8c6
	db $0B, $50
; 0x495a7

TM39ExplanationText: ; 0x495a7
	TX_FAR _TM39ExplanationText
	db $50
; 0x495a7 + 5 bytes

TM39NoRoomText: ; 0x495ac
	TX_FAR _TM39NoRoomText
	db $50
; 0x495ac + 5 bytes

Route12GateUpstairsText2: ; 0x495b1
	db $08 ; asm
	ld hl, UnnamedText_495b8
	jp Unnamed_55c9

UnnamedText_495b8: ; 0x495b8
	TX_FAR _UnnamedText_495b8 ; 0x8c95a
	db $50
; 0x495bd

Route12GateUpstairsText3: ; 0x495bd
	db $8
	ld hl, UnnamedText_495c4
	jp Unnamed_55c9
; 0x495c4

UnnamedText_495c4: ; 0x495c4
	TX_FAR _UnnamedText_495c4
	db $50
; 0x495c4 + 5 bytes

Unnamed_55c9:
	ld a, [$c109]
	cp $4
	jr z, .asm_495d4 ; 0x495ce $4
	ld a, $1
	jr .asm_495d8 ; 0x495d2 $4
.asm_495d4
	call PrintText
	xor a
.asm_495d8
	ld [$cc3c], a
	jp TextScriptEnd
; 0x495de

Route12GateUpstairsObject: ; 0x495de (size=24)
	db $a ; border tile

	db $1 ; warps
	db $7, $7, $4, ROUTE_12_GATE

	db $2 ; signs
	db $2, $1, $2 ; Route12GateUpstairsText2
	db $2, $6, $3 ; Route12GateUpstairsText3

	db $1 ; people
	db SPRITE_BRUNETTE_GIRL, $4 + 4, $3 + 4, $fe, $1, $1 ; person

	; warp-to
	EVENT_DISP $4, $7, $7 ; ROUTE_12_GATE

Route15Gate_h: ; 0x495f6 to 0x49602 (12 bytes) (id=184)
	db $0c ; tileset
	db ROUTE_15_GATE_HEIGHT, ROUTE_15_GATE_WIDTH ; dimensions (y, x)
	dw Route15GateBlocks, Route15GateTexts, Route15GateScript ; blocks, texts, scripts
	db $00 ; connections

	dw Route15GateObject ; objects

Route15GateScript: ; 0x49602
	jp $3c3c
; 0x49605

Route15GateTexts: ; 0x49605
	dw Route15GateText1

Route15GateText1: ; 0x49607
	TX_FAR _Route15GateText1
	db $50

Route15GateObject: ; 0x4960c (size=50)
	db $a ; border tile

	db $5 ; warps
	db $4, $0, $0, $ff
	db $5, $0, $1, $ff
	db $4, $7, $2, $ff
	db $5, $7, $3, $ff
	db $8, $6, $0, $b9

	db $0 ; signs

	db $1 ; people
	db SPRITE_GUARD, $1 + 4, $4 + 4, $ff, $ff, $1 ; person

	; warp-to
	EVENT_DISP $4, $4, $0
	EVENT_DISP $4, $5, $0
	EVENT_DISP $4, $4, $7
	EVENT_DISP $4, $5, $7
	EVENT_DISP $4, $8, $6

INCBIN "baserom.gbc",$4963e,$4968c - $4963e

UnnamedText_4968c: ; 0x4968c
	TX_FAR _UnnamedText_4968c
	db $50
; 0x4968c + 5 bytes

INCBIN "baserom.gbc",$49691,$49698 - $49691

UnnamedText_49698: ; 0x49698
	TX_FAR _UnnamedText_49698
	db $50
; 0x49698 + 5 bytes

INCBIN "baserom.gbc",$4969d,$15

Route16GateMap_h: ; 0x496b2 to 0x496be (12 bytes) (id=186)
	db $0c ; tileset
	db ROUTE_16_GATE_1F_HEIGHT, ROUTE_16_GATE_1F_WIDTH ; dimensions (y, x)
	dw Route16GateMapBlocks, Route16GateMapTexts, Route16GateMapScript ; blocks, texts, scripts
	db $00 ; connections

	dw Route16GateMapObject ; objects

Route16GateMapScript: ; 0x496be
	ld hl, $d732
	res 5, [hl]
	call $3c3c
	ld a, [$d660]
	ld hl, Route16GateMapScripts
	jp $3d97
; 0x496cf

Route16GateMapScripts: ; 0x496cf
	dw Route16GateMapScript0

INCBIN "baserom.gbc",$496d1,$6

Route16GateMapScript0: ; 0x496d7
	call $5755
	ret nz
	ld hl, $5714
	call $34bf
	ret nc
	ld a, $3
	ld [$ff00+$8c], a
	call $2920
	xor a
	ld [$ff00+$b4], a
	ld a, [$cd3d]
	cp $1
	jr z, .asm_4970e ; 0x496f1 $1b
	ld a, [$cd3d]
	dec a
	ld [$cd38], a
	ld b, $0
	ld c, a
	ld a, $40
	ld hl, $ccd3
	call $36e0
	call $3486
	ld a, $1
	ld [$d660], a
	ret
.asm_4970e
	ld a, $2
	ld [$d660], a
	ret
; 0x49714

INCBIN "baserom.gbc",$49714,$46

Route16GateMapTexts: ; 0x4975a
	dw Route16GateMapText1, Route16GateMapText2, Route16GateMapText3

Route16GateMapText1: ; 0x49760
	db $08 ; asm
	call $5755
	jr z, .asm_0bdf3 ; 0x49764
	ld hl, UnnamedText_4977c
	call PrintText
	jr .asm_56c9d ; 0x4976c
.asm_0bdf3 ; 0x4976e
	ld hl, UnnamedText_49777
	call PrintText
.asm_56c9d ; 0x49774
	jp TextScriptEnd

UnnamedText_49777: ; 0x49777
	TX_FAR _UnnamedText_49777
	db $50
; 0x49777 + 5 bytes

UnnamedText_4977c: ; 0x4977c
	TX_FAR _UnnamedText_4977c
	db $50
; 0x4977c + 5 bytes

Route16GateMapText3: ; 0x49781
	TX_FAR _UnnamedText_49781
	db $50
; 0x49781 + 5 bytes

Route16GateMapText2: ; 0x49786
	TX_FAR _Route16GateMapText2
	db $50

Route16GateMapObject: ; 0x4978b (size=88)
	db $a ; border tile

	db $9 ; warps
	db $8, $0, $0, $ff
	db $9, $0, $1, $ff
	db $8, $7, $2, $ff
	db $9, $7, $2, $ff
	db $2, $0, $4, $ff
	db $3, $0, $5, $ff
	db $2, $7, $6, $ff
	db $3, $7, $7, $ff
	db $c, $6, $0, ROUTE_16_GATE_2F

	db $0 ; signs

	db $2 ; people
	db SPRITE_GUARD, $5 + 4, $4 + 4, $ff, $d0, $1 ; person
	db SPRITE_GAMBLER, $3 + 4, $4 + 4, $ff, $ff, $2 ; person

	; warp-to
	EVENT_DISP $4, $8, $0
	EVENT_DISP $4, $9, $0
	EVENT_DISP $4, $8, $7
	EVENT_DISP $4, $9, $7
	EVENT_DISP $4, $2, $0
	EVENT_DISP $4, $3, $0
	EVENT_DISP $4, $2, $7
	EVENT_DISP $4, $3, $7
	EVENT_DISP $4, $c, $6 ; ROUTE_16_GATE_2F

Route16GateMapBlocks: ; 0x497e3 28
	INCBIN "maps/route16gatemap.blk"

Route16GateUpstairs_h: ; 0x497ff to 0x4980b (12 bytes) (id=187)
	db $0c ; tileset
	db ROUTE_16_GATE_2F_HEIGHT, ROUTE_16_GATE_2F_WIDTH ; dimensions (y, x)
	dw Route16GateUpstairsBlocks, Route16GateUpstairsTexts, Route16GateUpstairsScript ; blocks, texts, scripts
	db $00 ; connections

	dw Route16GateUpstairsObject ; objects

Route16GateUpstairsScript: ; 0x4980b
	jp $3c3f
; 0x4980e

Route16GateUpstairsTexts: ; 0x4980e
	dw Route16GateUpstairsText1, Route16GateUpstairsText2, Route16GateUpstairsText3, Route16GateUpstairsText4

Route16GateUpstairsText1: ; 0x49816
	db $08 ; asm
	ld hl, UnnamedText_49820
	call PrintText
	jp TextScriptEnd

UnnamedText_49820: ; 0x49820
	TX_FAR _UnnamedText_49820
	db $50
; 0x49820 + 5 bytes

Route16GateUpstairsText2: ; 0x49825
	db $08 ; asm
	ld hl, UnnamedText_4982f
	call PrintText
	jp TextScriptEnd

UnnamedText_4982f: ; 0x4982f
	TX_FAR _UnnamedText_4982f
	db $50
; 0x4982f + 5 bytes

Route16GateUpstairsText3: ; 0x49834
	db $8
	ld hl, UnnamedText_4983b
	jp $55c9
; 0x4983b

UnnamedText_4983b: ; 0x4983b
	TX_FAR _UnnamedText_4983b
	db $50
; 0x4983b + 5 bytes

Route16GateUpstairsText4: ; 0x49840
	db $8
	ld hl, $5847
	jp $55c9
; 0x49847

UnnamedText_49847: ; 0x49847
	TX_FAR _UnnamedText_49847
	db $50
; 0x49847 + 5 bytes

Route16GateUpstairsObject: ; 0x4984c (size=30)
	db $a ; border tile

	db $1 ; warps
	db $7, $7, $8, ROUTE_16_GATE_1F

	db $2 ; signs
	db $2, $1, $3 ; Route16GateUpstairsText3
	db $2, $6, $4 ; Route16GateUpstairsText4

	db $2 ; people
	db SPRITE_YOUNG_BOY, $2 + 4, $4 + 4, $ff, $ff, $1 ; person
	db SPRITE_LITTLE_GIRL, $5 + 4, $2 + 4, $fe, $2, $2 ; person

	; warp-to
	EVENT_DISP $4, $7, $7 ; ROUTE_16_GATE_1F

Route18Gate_h: ; 0x4986a to 0x49876 (12 bytes) (id=190)
	db $0c ; tileset
	db ROUTE_18_GATE_1F_HEIGHT, ROUTE_18_GATE_1F_WIDTH ; dimensions (y, x)
	dw Route18GateBlocks, Route18GateTexts, Route18GateScript ; blocks, texts, scripts
	db $00 ; connections

	dw Route18GateObject ; objects

Route18GateScript: ; 0x49876
	ld hl, $d732
	res 5, [hl]
	call $3c3c
	ld a, [$d669]
	ld hl, Route18GateScripts
	jp $3d97
; 0x49887

Route18GateScripts: ; 0x49887
	dw Route18GateScript0

INCBIN "baserom.gbc",$49889,$6

Route18GateScript0: ; 0x4988f
	call $5755
	ret nz
	ld hl, $58cc
	call $34bf
	ret nc
	ld a, $2
	ld [$ff00+$8c], a
	call $2920
	xor a
	ld [$ff00+$b4], a
	ld a, [$cd3d]
	cp $1
	jr z, .asm_498c6 ; 0x498a9 $1b
	ld a, [$cd3d]
	dec a
	ld [$cd38], a
	ld b, $0
	ld c, a
	ld a, $40
	ld hl, $ccd3
	call $36e0
	call $3486
	ld a, $1
	ld [$d669], a
	ret
.asm_498c6
	ld a, $2
	ld [$d669], a
	ret
; 0x498cc

INCBIN "baserom.gbc",$498cc,$41

Route18GateTexts: ; 0x4990d
	dw Route18GateText1, Route18GateText2

Route18GateText1: ; 0x49911
	db $08 ; asm
	call $5755
	jr z, .asm_3c84d ; 0x49915
	ld hl, UnnamedText_4992d
	call PrintText
	jr .asm_a8410 ; 0x4991d
.asm_3c84d ; 0x4991f
	ld hl, UnnamedText_49928
	call PrintText
.asm_a8410 ; 0x49925
	jp TextScriptEnd

UnnamedText_49928: ; 0x49928
	TX_FAR _UnnamedText_49928
	db $50
; 0x4992d

UnnamedText_4992d: ; 0x4992d
	TX_FAR _UnnamedText_4992d
	db $50
; 0x49932

Route18GateText2: ; 0x49932
	TX_FAR _UnnamedText_49932
	db $50
; 0x49937

Route18GateObject: ; 0x49937 (size=50)
	db $a ; border tile

	db $5 ; warps
	db $4, $0, $0, $ff
	db $5, $0, $1, $ff
	db $4, $7, $2, $ff
	db $5, $7, $3, $ff
	db $8, $6, $0, ROUTE_18_GATE_2F

	db $0 ; signs

	db $1 ; people
	db SPRITE_GUARD, $1 + 4, $4 + 4, $ff, $d0, $1 ; person

	; warp-to
	EVENT_DISP $4, $4, $0
	EVENT_DISP $4, $5, $0
	EVENT_DISP $4, $4, $7
	EVENT_DISP $4, $5, $7
	EVENT_DISP $4, $8, $6 ; ROUTE_18_GATE_2F

Route18GateHeader_h: ; 0x49969 to 0x49975 (12 bytes) (id=191)
	db $0c ; tileset
	db ROUTE_18_GATE_2F_HEIGHT, ROUTE_18_GATE_2F_WIDTH ; dimensions (y, x)
	dw Route18GateHeaderBlocks, Route18GateHeaderTexts, Route18GateHeaderScript ; blocks, texts, scripts
	db $00 ; connections

	dw Route18GateHeaderObject ; objects

Route18GateHeaderScript: ; 0x49975
	jp $3c3f
; 0x49978

Route18GateHeaderTexts: ; 0x49978
	dw Route18GateHeaderText1, Route18GateHeaderText2, Route18GateHeaderText3

Route18GateHeaderText1: ; 0x4997e
	db $08 ; asm
	ld a, $5
	ld [W_WHICHTRADE], a
	ld a, $54
	call Predef
	jp TextScriptEnd

Route18GateHeaderText2: ; 0x4998c
	db $8
	ld hl, $5993
	jp $55c9
; 0x49993

UnnamedText_49993: ; 0x49993
	TX_FAR _UnnamedText_49993
	db $50
; 0x49993 + 5 bytes

Route18GateHeaderText3: ; 0x49998
	db $8
	ld hl, $599f
	jp $55c9
; 0x4999f

UnnamedText_4999f: ; 0x4999f
	TX_FAR _UnnamedText_4999f
	db $50
; 0x4999f + 5 bytes

Route18GateHeaderObject: ; 0x499a4 (size=24)
	db $a ; border tile

	db $1 ; warps
	db $7, $7, $4, ROUTE_18_GATE_1F

	db $2 ; signs
	db $2, $1, $2 ; Route18GateHeaderText2
	db $2, $6, $3 ; Route18GateHeaderText3

	db $1 ; people
	db SPRITE_BUG_CATCHER, $2 + 4, $4 + 4, $fe, $2, $1 ; person

	; warp-to
	EVENT_DISP $4, $7, $7 ; ROUTE_18_GATE_1F

MtMoon1_h: ; 0x499bc to 0x499c8 (12 bytes) (id=59)
	db $11 ; tileset
	db MT_MOON_1_HEIGHT, MT_MOON_1_WIDTH ; dimensions (y, x)
	dw MtMoon1Blocks, MtMoon1Texts, MtMoon1Script ; blocks, texts, scripts
	db $00 ; connections

	dw MtMoon1Object ; objects

MtMoon1Script: ; 0x499c8
	call $3c3c
	ld hl, MtMoon1TrainerHeader0
	ld de, Unknown_59db
	ld a, [$d606]
	call $3160
	ld [$d606], a
	ret
; 0x499db

Unknown_59db: ; 0x59db
INCBIN "baserom.gbc",$499db,$6

MtMoon1Texts: ; 0x499e1
	dw MtMoon1Text1, MtMoon1Text2, MtMoon1Text3, MtMoon1Text4, MtMoon1Text5, MtMoon1Text6, MtMoon1Text7, MtMoon1Text8, MtMoon1Text9, MtMoon1Text10, MtMoon1Text11, MtMoon1Text12, MtMoon1Text13, MtMoon1Text14

MtMoon1TrainerHeaders:
MtMoon1TrainerHeader0: ; 0x499fd
	db $1 ; flag's bit
	db ($2 << 4) ; trainer's view range
	dw $d7f5 ; flag's byte
	dw MtMoon1BattleText2 ; 0x5a98 TextBeforeBattle
	dw MtMoon1AfterBattleText2 ; 0x5aa2 TextAfterBattle
	dw MtMoon1EndBattleText2 ; 0x5a9d TextEndBattle
	dw MtMoon1EndBattleText2 ; 0x5a9d TextEndBattle
; 0x49a09

MtMoon1TrainerHeader2: ; 0x49a09
	db $2 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d7f5 ; flag's byte
	dw MtMoon1BattleText3 ; 0x5aa7 TextBeforeBattle
	dw MtMoon1AfterBattleText3 ; 0x5ab1 TextAfterBattle
	dw MtMoon1EndBattleText3 ; 0x5aac TextEndBattle
	dw MtMoon1EndBattleText3 ; 0x5aac TextEndBattle
; 0x49a15

MtMoon1TrainerHeader3: ; 0x49a15
	db $3 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d7f5 ; flag's byte
	dw MtMoon1BattleText4 ; 0x5ab6 TextBeforeBattle
	dw MtMoon1AfterBattleText4 ; 0x5ac0 TextAfterBattle
	dw MtMoon1EndBattleText4 ; 0x5abb TextEndBattle
	dw MtMoon1EndBattleText4 ; 0x5abb TextEndBattle
; 0x49a21

MtMoon1TrainerHeader4: ; 0x49a21
	db $4 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d7f5 ; flag's byte
	dw MtMoon1BattleText5 ; 0x5ac5 TextBeforeBattle
	dw MtMoon1AfterBattleText5 ; 0x5acf TextAfterBattle
	dw MtMoon1EndBattleText5 ; 0x5aca TextEndBattle
	dw MtMoon1EndBattleText5 ; 0x5aca TextEndBattle
; 0x49a2d

MtMoon1TrainerHeader5: ; 0x49a2d
	db $5 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d7f5 ; flag's byte
	dw MtMoon1BattleText6 ; 0x5ad4 TextBeforeBattle
	dw MtMoon1AfterBattleText6 ; 0x5ade TextAfterBattle
	dw MtMoon1EndBattleText6 ; 0x5ad9 TextEndBattle
	dw MtMoon1EndBattleText6 ; 0x5ad9 TextEndBattle
; 0x49a39

MtMoon1TrainerHeader6: ; 0x49a39
	db $6 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d7f5 ; flag's byte
	dw MtMoon1BattleText7 ; 0x5ae3 TextBeforeBattle
	dw MtMoon1AfterBattleText7 ; 0x5aed TextAfterBattle
	dw MtMoon1EndBattleText7 ; 0x5ae8 TextEndBattle
	dw MtMoon1EndBattleText7 ; 0x5ae8 TextEndBattle
; 0x49a45

MtMoon1TrainerHeader7: ; 0x49a45
	db $7 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d7f5 ; flag's byte
	dw MtMoon1BattleText8 ; 0x5af2 TextBeforeBattle
	dw MtMoon1AfterBattleText8 ; 0x5afc TextAfterBattle
	dw MtMoon1EndBattleText8 ; 0x5af7 TextEndBattle
	dw MtMoon1EndBattleText8 ; 0x5af7 TextEndBattle
; 0x49a51

db $ff

MtMoon1Text1: ; 0x49a52
	db $08 ; asm
	ld hl, MtMoon1TrainerHeader0
	call LoadTrainerHeader
	jp TextScriptEnd

MtMoon1Text2: ; 0x49a5c
	db $08 ; asm
	ld hl, MtMoon1TrainerHeader2
	call LoadTrainerHeader
	jp TextScriptEnd

MtMoon1Text3: ; 0x49a66
	db $08 ; asm
	ld hl, MtMoon1TrainerHeader3
	call LoadTrainerHeader
	jp TextScriptEnd

MtMoon1Text4: ; 0x49a70
	db $08 ; asm
	ld hl, MtMoon1TrainerHeader4
	call LoadTrainerHeader
	jp TextScriptEnd

MtMoon1Text5: ; 0x49a7a
	db $08 ; asm
	ld hl, MtMoon1TrainerHeader5
	call LoadTrainerHeader
	jp TextScriptEnd

MtMoon1Text6: ; 0x49a84
	db $08 ; asm
	ld hl, MtMoon1TrainerHeader6
	call LoadTrainerHeader
	jp TextScriptEnd

MtMoon1Text7: ; 0x49a8e
	db $08 ; asm
	ld hl, MtMoon1TrainerHeader7
	call LoadTrainerHeader
	jp TextScriptEnd

MtMoon1BattleText2: ; 0x49a98
	TX_FAR _MtMoon1BattleText2
	db $50
; 0x49a98 + 5 bytes

MtMoon1EndBattleText2: ; 0x49a9d
	TX_FAR _MtMoon1EndBattleText2
	db $50
; 0x49a9d + 5 bytes

MtMoon1AfterBattleText2: ; 0x49aa2
	TX_FAR _MtMoon1AfterBattleText2
	db $50
; 0x49aa2 + 5 bytes

MtMoon1BattleText3: ; 0x49aa7
	TX_FAR _MtMoon1BattleText3
	db $50
; 0x49aa7 + 5 bytes

MtMoon1EndBattleText3: ; 0x49aac
	TX_FAR _MtMoon1EndBattleText3
	db $50
; 0x49aac + 5 bytes

MtMoon1AfterBattleText3: ; 0x49ab1
	TX_FAR _MtMoon1AfterBattleText3
	db $50
; 0x49ab1 + 5 bytes

MtMoon1BattleText4: ; 0x49ab6
	TX_FAR _MtMoon1BattleText4
	db $50
; 0x49ab6 + 5 bytes

MtMoon1EndBattleText4: ; 0x49abb
	TX_FAR _MtMoon1EndBattleText4
	db $50
; 0x49abb + 5 bytes

MtMoon1AfterBattleText4: ; 0x49ac0
	TX_FAR _MtMoon1AfterBattleText4
	db $50
; 0x49ac0 + 5 bytes

MtMoon1BattleText5: ; 0x49ac5
	TX_FAR _MtMoon1BattleText5
	db $50
; 0x49ac5 + 5 bytes

MtMoon1EndBattleText5: ; 0x49aca
	TX_FAR _MtMoon1EndBattleText5
	db $50
; 0x49aca + 5 bytes

MtMoon1AfterBattleText5: ; 0x49acf
	TX_FAR _MtMoon1AfterBattleText5
	db $50
; 0x49acf + 5 bytes

MtMoon1BattleText6: ; 0x49ad4
	TX_FAR _MtMoon1BattleText6
	db $50
; 0x49ad4 + 5 bytes

MtMoon1EndBattleText6: ; 0x49ad9
	TX_FAR _MtMoon1EndBattleText6
	db $50
; 0x49ad9 + 5 bytes

MtMoon1AfterBattleText6: ; 0x49ade
	TX_FAR _MtMoon1AfterBattleText6
	db $50
; 0x49ade + 5 bytes

MtMoon1BattleText7: ; 0x49ae3
	TX_FAR _MtMoon1BattleText7
	db $50
; 0x49ae3 + 5 bytes

MtMoon1EndBattleText7: ; 0x49ae8
	TX_FAR _MtMoon1EndBattleText7
	db $50
; 0x49ae8 + 5 bytes

MtMoon1AfterBattleText7: ; 0x49aed
	TX_FAR _MtMoon1AfterBattleText7
	db $50
; 0x49aed + 5 bytes

MtMoon1BattleText8: ; 0x49af2
	TX_FAR _MtMoon1BattleText8
	db $50
; 0x49af2 + 5 bytes

MtMoon1EndBattleText8: ; 0x49af7
	TX_FAR _MtMoon1EndBattleText8
	db $50
; 0x49af7 + 5 bytes

MtMoon1AfterBattleText8: ; 0x49afc
	TX_FAR _MtMoon1AfterBattleText8
	db $50
; 0x49afc + 5 bytes

MtMoon1Text14: ; 0x49b01
	TX_FAR _MtMoon1Text14
	db $50

MtMoon1Object: ; 0x49b06 (size=145)
	db $3 ; border tile

	db $5 ; warps
	db $23, $e, $1, $ff
	db $23, $f, $1, $ff
	db $5, $5, $0, MT_MOON_2
	db $b, $11, $2, MT_MOON_2
	db $f, $19, $3, MT_MOON_2

	db $1 ; signs
	db $17, $f, $e ; MtMoon1Text14

	db $d ; people
	db SPRITE_HIKER, $6 + 4, $5 + 4, $ff, $d0, $41, HIKER + $C8, $1 ; trainer
	db SPRITE_BUG_CATCHER, $10 + 4, $c + 4, $ff, $d3, $42, YOUNGSTER + $C8, $3 ; trainer
	db SPRITE_LASS, $4 + 4, $1e + 4, $ff, $d0, $43, LASS + $C8, $5 ; trainer
	db SPRITE_BLACK_HAIR_BOY_2, $1f + 4, $18 + 4, $ff, $d1, $44, SUPER_NERD + $C8, $1 ; trainer
	db SPRITE_LASS, $17 + 4, $10 + 4, $ff, $d0, $45, LASS + $C8, $6 ; trainer
	db SPRITE_BUG_CATCHER, $16 + 4, $7 + 4, $ff, $d0, $46, BUG_CATCHER + $C8, $7 ; trainer
	db SPRITE_BUG_CATCHER, $1b + 4, $1e + 4, $ff, $d3, $47, BUG_CATCHER + $C8, $8 ; trainer
	db SPRITE_BALL, $14 + 4, $2 + 4, $ff, $ff, $88, POTION ; item
	db SPRITE_BALL, $2 + 4, $2 + 4, $ff, $ff, $89, MOON_STONE ; item
	db SPRITE_BALL, $1f + 4, $23 + 4, $ff, $ff, $8a, RARE_CANDY ; item
	db SPRITE_BALL, $17 + 4, $24 + 4, $ff, $ff, $8b, ESCAPE_ROPE ; item
	db SPRITE_BALL, $21 + 4, $14 + 4, $ff, $ff, $8c, POTION ; item
	db SPRITE_BALL, $20 + 4, $5 + 4, $ff, $ff, $8d, TM_12 ; item

	; warp-to
	EVENT_DISP $14, $23, $e
	EVENT_DISP $14, $23, $f
	EVENT_DISP $14, $5, $5 ; MT_MOON_2
	EVENT_DISP $14, $b, $11 ; MT_MOON_2
	EVENT_DISP $14, $f, $19 ; MT_MOON_2

MtMoon1Blocks: ; 0x49b97 360
	INCBIN "maps/mtmoon1.blk"

MtMoon3_h: ; 0x49cff to 0x49d0b (12 bytes) (id=61)
	db $11 ; tileset
	db MT_MOON_3_HEIGHT, MT_MOON_3_WIDTH ; dimensions (y, x)
	dw MtMoon3Blocks, MtMoon3Texts, MtMoon3Script ; blocks, texts, scripts
	db $00 ; connections

	dw MtMoon3Object ; objects

MtMoon3Script: ; 0x49d0b
	call $3c3c
	ld hl, $5e48
	ld de, $5d63
	ld a, [$d607]
	call $3160
	ld [$d607], a
	ld a, [$d7f6]
	bit 1, a
	ret z
	ld hl, $5d37
	call $34bf
	jr nc, .asm_49d31 ; 0x49d29 $6
	ld hl, $d72e
	set 4, [hl]
	ret
.asm_49d31
	ld hl, $d72e
	res 4, [hl]
	ret
; 0x49d37

INCBIN "baserom.gbc",$49d37,$fd

MtMoon3Texts: ; 0x49e34
	dw MtMoon3Text1, MtMoon3Text2, MtMoon3Text3, MtMoon3Text4, MtMoon3Text5, MtMoon3Text6, MtMoon3Text7, MtMoon3Text8, MtMoon3Text9, Unnamed_49f99

MtMoon3TrainerHeaders:
MtMoon3TrainerHeader0: ; 0x49e48
	db $2 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d7f6 ; flag's byte
	dw MtMoon3BattleText2 ; 0x5f9f TextBeforeBattle
	dw MtMoon3AfterBattleText2 ; 0x5fa9 TextAfterBattle
	dw MtMoon3EndBattleText2 ; 0x5fa4 TextEndBattle
	dw MtMoon3EndBattleText2 ; 0x5fa4 TextEndBattle
; 0x49e54

MtMoon3TrainerHeader2: ; 0x49e54
	db $3 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d7f6 ; flag's byte
	dw MtMoon3BattleText3 ; 0x5fae TextBeforeBattle
	dw MtMoon3AfterBattleText3 ; 0x5fb8 TextAfterBattle
	dw MtMoon3EndBattleText3 ; 0x5fb3 TextEndBattle
	dw MtMoon3EndBattleText3 ; 0x5fb3 TextEndBattle
; 0x49e60

MtMoon3TrainerHeader3: ; 0x49e60
	db $4 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d7f6 ; flag's byte
	dw MtMoon3BattleText4 ; 0x5fbd TextBeforeBattle
	dw MtMoon3AfterBattleText4 ; 0x5fc7 TextAfterBattle
	dw MtMoon3EndBattleText4 ; 0x5fc2 TextEndBattle
	dw MtMoon3EndBattleText4 ; 0x5fc2 TextEndBattle
; 0x49e6c

MtMoon3TrainerHeader4: ; 0x49e6c
	db $5 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d7f6 ; flag's byte
	dw MtMoon3BattleText5 ; 0x5fcc TextBeforeBattle
	dw MtMoon3AfterBattleText5 ; 0x5fd6 TextAfterBattle
	dw MtMoon3EndBattleText5 ; 0x5fd1 TextEndBattle
	dw MtMoon3EndBattleText5 ; 0x5fd1 TextEndBattle
; 0x49e78

db $ff

MtMoon3Text1: ; 0x49e79
	db $08 ; asm
	ld a, [$d7f6]
	bit 1, a
	jr z, .asm_be1e0 ; 0x49e7f
	and $c0
	jr nz, .asm_f8cd4 ; 0x49e83
	ld hl, UnnamedText_49f8f
	call PrintText
	jr .asm_f1fba ; 0x49e8b
.asm_be1e0 ; 0x49e8d
	ld hl, UnnamedText_49f85
	call PrintText
	ld hl, $d72d
	set 6, [hl]
	set 7, [hl]
	ld hl, UnnamedText_49f8a
	ld de, UnnamedText_49f8a
	call $3354
	ldh a, [$8c]
	ld [$cf13], a
	call $336a
	call $32d7
	ld a, $3
	ld [$d607], a
	ld [$da39], a
	jr .asm_f1fba ; 0x49eb6
.asm_f8cd4 ; 0x49eb8
	ld hl, UnnamedText_49f94
	call PrintText
.asm_f1fba ; 0x49ebe
	jp TextScriptEnd

MtMoon3Text2: ; 0x49ec1
	db $08 ; asm
	ld hl, MtMoon3TrainerHeader0
	call LoadTrainerHeader
	jp TextScriptEnd

MtMoon3Text3: ; 0x49ecb
	db $08 ; asm
	ld hl, MtMoon3TrainerHeader2
	call LoadTrainerHeader
	jp TextScriptEnd

MtMoon3Text4: ; 0x49ed5
	db $08 ; asm
	ld hl, MtMoon3TrainerHeader3
	call LoadTrainerHeader
	jp TextScriptEnd

MtMoon3Text5: ; 0x49edf
	db $08 ; asm
	ld hl, $5e6c
	call LoadTrainerHeader
	jp TextScriptEnd

MtMoon3Text6: ; 0x49ee9
	db $08 ; asm
	ld a, $1
	ld [$cc3c], a
	ld hl, UnnamedText_49f24
	call PrintText
	call $35ec
	ld a, [$cc26]
	and a
	jr nz, .asm_1fa5e ; 0x49efc
	ld bc,(DOME_FOSSIL << 8) | 1
	call GiveItem
	jp nc, $5f76
	call $5f69
	ld a, $6d
	ld [$cc4d], a
	ld a, $11
	call Predef
	ld hl, $d7f6
	set 6, [hl]
	ld a, $4
	ld [$d607], a
	ld [$da39], a
.asm_1fa5e ; 0x49f21
	jp TextScriptEnd

UnnamedText_49f24: ; 0x49f24
	TX_FAR _UnnamedText_49f24
	db $50
; 0x49f24 + 5 bytes

MtMoon3Text7: ; 0x49f29
	db $08 ; asm
	ld a, $1
	ld [$cc3c], a
	ld hl, UnnamedText_49f64
	call PrintText
	call $35ec
	ld a, [$cc26]
	and a
	jr nz, .asm_8e988 ; 0x49f3c
	ld bc, (HELIX_FOSSIL << 8) | 1
	call GiveItem
	jp nc, Unnamed_49f76
	call Unnamed_49f69
	ld a, $6e
	ld [$cc4d], a
	ld a, $11
	call Predef
	ld hl, $d7f6
	set 7, [hl]
	ld a, $4
	ld [$d607], a
	ld [$da39], a
.asm_8e988 ; 0x49f61
	jp TextScriptEnd

UnnamedText_49f64: ; 0x49f64
	TX_FAR _UnnamedText_49f64
	db $50
; 0x49f64 + 5 bytes

Unnamed_49f69: ; 0x49f69
	ld hl, UnnamedText_49f6f
	jp PrintText
; 0x49f6f

UnnamedText_49f6f: ; 0x49f6f
	TX_FAR _UnnamedText_49f6f ; 0x80995
	db $11, $d, $50
; 0x49f76

Unnamed_49f76: ; 0x49f76
	ld hl, UnnamedText_49f7f
	call PrintText
	jp TextScriptEnd
; 0x49f7f

UnnamedText_49f7f: ; 0x49f7f
	TX_FAR _UnnamedText_49f7f ; 0x809a8
	db $d, $50
; 0x49f85

UnnamedText_49f85: ; 0x49f85
	TX_FAR _UnnamedText_49f85
	db $50
; 0x49f85 + 5 bytes

UnnamedText_49f8a: ; 0x49f8a
	TX_FAR _UnnamedText_49f8a
	db $50
; 0x49f8a + 5 bytes

UnnamedText_49f8f: ; 0x49f8f
	TX_FAR _UnnamedText_49f8f
	db $50
; 0x49f8f + 5 bytes

UnnamedText_49f94: ; 0x49f94
	TX_FAR _UnnamedText_49f94
	db $50
; 0x49f94 + 5 bytes

Unnamed_49f99: ; 0x49f99
INCBIN "baserom.gbc",$49f99,$49f9f - $49f99

MtMoon3BattleText2: ; 0x49f9f
	TX_FAR _MtMoon3BattleText2
	db $50
; 0x49f9f + 5 bytes

MtMoon3EndBattleText2: ; 0x49fa4
	TX_FAR _MtMoon3EndBattleText2
	db $50
; 0x49fa4 + 5 bytes

MtMoon3AfterBattleText2: ; 0x49fa9
	TX_FAR _MtMoon3AfterBattleText2
	db $50
; 0x49fa9 + 5 bytes

MtMoon3BattleText3: ; 0x49fae
	TX_FAR _MtMoon3BattleText3
	db $50
; 0x49fae + 5 bytes

MtMoon3EndBattleText3: ; 0x49fb3
	TX_FAR _MtMoon3EndBattleText3
	db $50
; 0x49fb3 + 5 bytes

MtMoon3AfterBattleText3: ; 0x49fb8
	TX_FAR _MtMoon3AfterBattleText3
	db $50
; 0x49fb8 + 5 bytes

MtMoon3BattleText4: ; 0x49fbd
	TX_FAR _MtMoon3BattleText4
	db $50
; 0x49fbd + 5 bytes

MtMoon3EndBattleText4: ; 0x49fc2
	TX_FAR _MtMoon3EndBattleText4
	db $50
; 0x49fc2 + 5 bytes

MtMoon3AfterBattleText4: ; 0x49fc7
	TX_FAR _MtMoon3AfterBattleText4
	db $50
; 0x49fc7 + 5 bytes

MtMoon3BattleText5: ; 0x49fcc
	TX_FAR _MtMoon3BattleText5
	db $50
; 0x49fcc + 5 bytes

MtMoon3EndBattleText5: ; 0x49fd1
	TX_FAR _MtMoon3EndBattleText5
	db $50
; 0x49fd1 + 5 bytes

MtMoon3AfterBattleText5: ; 0x49fd6
	TX_FAR _MtMoon3AfterBattleText5
	db $50
; 0x49fd6 + 5 bytes

MtMoon3Object: ; 0x49fdb (size=102)
	db $3 ; border tile

	db $4 ; warps
	db $9, $19, $1, MT_MOON_2
	db $11, $15, $4, MT_MOON_2
	db $1b, $f, $5, MT_MOON_2
	db $7, $5, $6, MT_MOON_2

	db $0 ; signs

	db $9 ; people
	db SPRITE_BLACK_HAIR_BOY_2, $8 + 4, $c + 4, $ff, $d3, $41, SUPER_NERD + $C8, $2 ; trainer
	db SPRITE_ROCKET, $10 + 4, $b + 4, $ff, $d0, $42, ROCKET + $C8, $1 ; trainer
	db SPRITE_ROCKET, $16 + 4, $f + 4, $ff, $d0, $43, ROCKET + $C8, $2 ; trainer
	db SPRITE_ROCKET, $b + 4, $1d + 4, $ff, $d1, $44, ROCKET + $C8, $3 ; trainer
	db SPRITE_ROCKET, $11 + 4, $1d + 4, $ff, $d2, $45, ROCKET + $C8, $4 ; trainer
	db SPRITE_OMANYTE, $6 + 4, $c + 4, $ff, $ff, $6 ; person
	db SPRITE_OMANYTE, $6 + 4, $d + 4, $ff, $ff, $7 ; person
	db SPRITE_BALL, $15 + 4, $19 + 4, $ff, $ff, $88, HP_UP ; item
	db SPRITE_BALL, $5 + 4, $1d + 4, $ff, $ff, $89, TM_01 ; item

	; warp-to
	EVENT_DISP $14, $9, $19 ; MT_MOON_2
	EVENT_DISP $14, $11, $15 ; MT_MOON_2
	EVENT_DISP $14, $1b, $f ; MT_MOON_2
	EVENT_DISP $14, $7, $5 ; MT_MOON_2

MtMoon3Blocks: ; 0x4a041 360
	INCBIN "maps/mtmoon3.blk"

SafariZoneWest_h: ; 0x4a1a9 to 0x4a1b5 (12 bytes) (id=219)
	db $03 ; tileset
	db SAFARI_ZONE_WEST_HEIGHT, SAFARI_ZONE_WEST_WIDTH ; dimensions (y, x)
	dw SafariZoneWestBlocks, SafariZoneWestTexts, SafariZoneWestScript ; blocks, texts, scripts
	db $00 ; connections

	dw SafariZoneWestObject ; objects

SafariZoneWestScript: ; 0x4a1b5
	jp $3c3c
; 0x4a1b8

SafariZoneWestTexts: ; 0x4a1b8
	dw SafariZoneWestText1, SafariZoneWestText2, SafariZoneWestText3, SafariZoneWestText4, SafariZoneWestText5, SafariZoneWestText6, SafariZoneWestText7, SafariZoneWestText8

SafariZoneWestText5: ; 0x4a1c8
	TX_FAR _SafariZoneWestText5
	db $50

SafariZoneWestText6: ; 0x4a1cd
	TX_FAR _SafariZoneWestText6
	db $50

SafariZoneWestText7: ; 0x4a1d2
	TX_FAR _SafariZoneWestText7
	db $50

SafariZoneWestText8: ; 0x4a1d7
	TX_FAR _SafariZoneWestText8
	db $50

SafariZoneWestObject: ; 0x4a1dc (size=108)
	db $0 ; border tile

	db $8 ; warps
	db $0, $14, $0, SAFARI_ZONE_NORTH
	db $0, $15, $1, SAFARI_ZONE_NORTH
	db $0, $1a, $2, SAFARI_ZONE_NORTH
	db $0, $1b, $3, SAFARI_ZONE_NORTH
	db $16, $1d, $2, SAFARI_ZONE_CENTER
	db $17, $1d, $3, SAFARI_ZONE_CENTER
	db $3, $3, $0, SAFARI_ZONE_SECRET_HOUSE
	db $b, $b, $0, SAFARI_ZONE_REST_HOUSE_2

	db $4 ; signs
	db $c, $c, $5 ; SafariZoneWestText5
	db $3, $11, $6 ; SafariZoneWestText6
	db $4, $1a, $7 ; SafariZoneWestText7
	db $16, $18, $8 ; SafariZoneWestText8

	db $4 ; people
	db SPRITE_BALL, $14 + 4, $8 + 4, $ff, $ff, $81, MAX_POTION ; item
	db SPRITE_BALL, $7 + 4, $9 + 4, $ff, $ff, $82, TM_32 ; item
	db SPRITE_BALL, $12 + 4, $12 + 4, $ff, $ff, $83, MAX_REVIVE ; item
	db SPRITE_BALL, $7 + 4, $13 + 4, $ff, $ff, $84, GOLD_TEETH ; item

	; warp-to
	EVENT_DISP $f, $0, $14 ; SAFARI_ZONE_NORTH
	EVENT_DISP $f, $0, $15 ; SAFARI_ZONE_NORTH
	EVENT_DISP $f, $0, $1a ; SAFARI_ZONE_NORTH
	EVENT_DISP $f, $0, $1b ; SAFARI_ZONE_NORTH
	EVENT_DISP $f, $16, $1d ; SAFARI_ZONE_CENTER
	EVENT_DISP $f, $17, $1d ; SAFARI_ZONE_CENTER
	EVENT_DISP $f, $3, $3 ; SAFARI_ZONE_SECRET_HOUSE
	EVENT_DISP $f, $b, $b ; SAFARI_ZONE_REST_HOUSE_2

SafariZoneWestBlocks: ; 0x4a248 195
	INCBIN "maps/safarizonewest.blk"

SafariZoneSecretHouse_h: ; 0x4a30b to 0x4a317 (12 bytes) (id=222)
	db $14 ; tileset
	db SAFARI_ZONE_SECRET_HOUSE_HEIGHT, SAFARI_ZONE_SECRET_HOUSE_WIDTH ; dimensions (y, x)
	dw SafariZoneSecretHouseBlocks, SafariZoneSecretHouseTexts, SafariZoneSecretHouseScript ; blocks, texts, scripts
	db $00 ; connections

	dw SafariZoneSecretHouseObject ; objects

SafariZoneSecretHouseScript: ; 0x4a317
	jp $3c3c
; 0x4a31a

SafariZoneSecretHouseTexts: ; 0x4a31a
	dw SafariZoneSecretHouseText1

SafariZoneSecretHouseText1: ; 0x4a31c
	db $08 ; asm
	ld a, [$d857]
	bit 0, a
	jr nz, .asm_20a9b ; 0x4a322
	ld hl, UnnamedText_4a350
	call PrintText
	ld bc, (HM_03 << 8) | 1
	call GiveItem
	jr nc, .asm_a21d2 ; 0x4a330
	ld hl, ReceivedHM03Text
	call PrintText
	ld hl, $d857
	set 0, [hl]
	jr .asm_8f1fc ; 0x4a33d
.asm_a21d2 ; 0x4a33f
	ld hl, HM03NoRoomText
	call PrintText
	jr .asm_8f1fc ; 0x4a345
.asm_20a9b ; 0x4a347
	ld hl, HM03ExplanationText
	call PrintText
.asm_8f1fc ; 0x4a34d
	jp TextScriptEnd

UnnamedText_4a350: ; 0x4a350
	TX_FAR _UnnamedText_4a350
	db $50
; 0x4a350 + 5 bytes

ReceivedHM03Text: ; 0x4a355
	TX_FAR _ReceivedHM03Text ; 0x85943
	db $0B, $50
; 0x4a35b

HM03ExplanationText: ; 0x4a35b
	TX_FAR _HM03ExplanationText
	db $50
; 0x4a35b + 5 bytes

HM03NoRoomText: ; 0x4a360
	TX_FAR _HM03NoRoomText
	db $50
; 0x4a360 + 5 bytes

SafariZoneSecretHouseObject: ; 0x4a365 (size=26)
	db $17 ; border tile

	db $2 ; warps
	db $7, $2, $6, SAFARI_ZONE_WEST
	db $7, $3, $6, SAFARI_ZONE_WEST

	db $0 ; signs

	db $1 ; people
	db SPRITE_FISHER, $3 + 4, $3 + 4, $ff, $d0, $1 ; person

	; warp-to
	EVENT_DISP $4, $7, $2 ; SAFARI_ZONE_WEST
	EVENT_DISP $4, $7, $3 ; SAFARI_ZONE_WEST

SafariZoneSecretHouseBlocks: ; 0x4a37f 16
	INCBIN "maps/safarizonesecrethouse.blk"

INCBIN "baserom.gbc",$4a38f,$1c71

SECTION "bank13",DATA,BANK[$13]

YoungsterPic:
	INCBIN "pic/trainer/youngster.pic"
BugCatcherPic:
	INCBIN "pic/trainer/bugcatcher.pic"
LassPic:
	INCBIN "pic/trainer/lass.pic"
SailorPic:
	INCBIN "pic/trainer/sailor.pic"
JrTrainerMPic:
	INCBIN "pic/trainer/jr.trainerm.pic"
JrTrainerFPic:
	INCBIN "pic/trainer/jr.trainerf.pic"
PokemaniacPic:
	INCBIN "pic/trainer/pokemaniac.pic"
SuperNerdPic:
	INCBIN "pic/trainer/supernerd.pic"
HikerPic:
	INCBIN "pic/trainer/hiker.pic"
BikerPic:
	INCBIN "pic/trainer/biker.pic"
BurglarPic:
	INCBIN "pic/trainer/burglar.pic"
EngineerPic:
	INCBIN "pic/trainer/engineer.pic"
FisherPic:
	INCBIN "pic/trainer/fisher.pic"
SwimmerPic:
	INCBIN "pic/trainer/swimmer.pic"
CueBallPic:
	INCBIN "pic/trainer/cueball.pic"
GamblerPic:
	INCBIN "pic/trainer/gambler.pic"
BeautyPic:
	INCBIN "pic/trainer/beauty.pic"
PsychicPic:
	INCBIN "pic/trainer/psychic.pic"
RockerPic:
	INCBIN "pic/trainer/rocker.pic"
JugglerPic:
	INCBIN "pic/trainer/juggler.pic"
TamerPic:
	INCBIN "pic/trainer/tamer.pic"
BirdKeeperPic:
	INCBIN "pic/trainer/birdkeeper.pic"
BlackbeltPic:
	INCBIN "pic/trainer/blackbelt.pic"
Rival1Pic:
	INCBIN "pic/trainer/rival1.pic"
ProfOakPic:
	INCBIN "pic/trainer/prof.oak.pic"
ChiefPic:
ScientistPic:
	INCBIN "pic/trainer/scientist.pic"
GiovanniPic:
	INCBIN "pic/trainer/giovanni.pic"
RocketPic:
	INCBIN "pic/trainer/rocket.pic"
CooltrainerMPic:
	INCBIN "pic/trainer/cooltrainerm.pic"
CooltrainerFPic:
	INCBIN "pic/trainer/cooltrainerf.pic"
BrunoPic:
	INCBIN "pic/trainer/bruno.pic"
BrockPic:
	INCBIN "pic/trainer/brock.pic"
MistyPic:
	INCBIN "pic/trainer/misty.pic"
LtSurgePic:
	INCBIN "pic/trainer/lt.surge.pic"
ErikaPic:
	INCBIN "pic/trainer/erika.pic"
KogaPic:
	INCBIN "pic/trainer/koga.pic"
BlainePic:
	INCBIN "pic/trainer/blaine.pic"
SabrinaPic:
	INCBIN "pic/trainer/sabrina.pic"
GentlemanPic:
	INCBIN "pic/trainer/gentleman.pic"
Rival2Pic:
	INCBIN "pic/trainer/rival2.pic"
Rival3Pic:
	INCBIN "pic/trainer/rival3.pic"
LoreleiPic:
	INCBIN "pic/trainer/lorelei.pic"
ChannelerPic:
	INCBIN "pic/trainer/channeler.pic"
AgathaPic:
	INCBIN "pic/trainer/agatha.pic"
LancePic:
	INCBIN "pic/trainer/lance.pic"

BattleCenterM_h: ; 0x4fd04 to 0x4fd10 (12 bytes) (id=239)
	db $15 ; tileset
	db BATTLE_CENTER_HEIGHT, BATTLE_CENTER_WIDTH ; dimensions (y, x)
	dw BattleCenterMBlocks, BattleCenterMTexts, BattleCenterMScript ; blocks, texts, scripts
	db $00 ; connections

	dw BattleCenterMObject ; objects

BattleCenterMScript: ; 0x4fd10
	call $3c3c
	ld a, [$ff00+$aa]
	cp $2
	ld a, $8
	jr z, .asm_4fd1d ; 0x4fd19 $2
	ld a, $c
.asm_4fd1d
	ld [$ff00+$8d], a
	ld a, $1
	ld [$ff00+$8c], a
	call $34ae
	ld hl, $d72d
	bit 0, [hl]
	set 0, [hl]
	ret nz
	ld hl, $c214
	ld a, $8
	ld [hli], a
	ld a, $a
	ld [hl], a
	ld a, $8
	ld [$c119], a
	ld a, [$ff00+$aa]
	cp $2
	ret z
	ld a, $7
	ld [$c215], a
	ld a, $c
	ld [$c119], a
	ret
; 0x4fd4c

BattleCenterMTexts: ; 0x4fd4c
	dw BattleCenterMText1

BattleCenterMText1: ; 0x4fd4e
	TX_FAR _BattleCenterMText1
	db $50

BattleCenterMObject: ; 0x4fd53 (size=10)
	db $e ; border tile

	db $0 ; warps

	db $0 ; signs

	db $1 ; people
	db SPRITE_RED, $2 + 4, $2 + 4, $ff, $0, $1 ; person

BattleCenterMBlocks: ; 0x4fd5d 20
	INCBIN "maps/battlecenterm.blk"

TradeCenterM_h: ; 0x4fd71 to 0x4fd7d (12 bytes) (id=240)
	db $15 ; tileset
	db TRADE_CENTER_HEIGHT, TRADE_CENTER_WIDTH ; dimensions (y, x)
	dw TradeCenterMBlocks, TradeCenterMTexts, TradeCenterMScript ; blocks, texts, scripts
	db $00 ; connections

	dw TradeCenterMObject ; objects

TradeCenterMScript: ; 0x4fd7d
	jp $7d10
; 0x4fd80

TradeCenterMTexts: ; 0x4fd80
	dw TradeCenterMText1

TradeCenterMText1: ; 0x4fd82
	TX_FAR _TradeCenterMText1
	db $50

TradeCenterMObject: ; 0x4fd87 (size=10)
	db $e ; border tile

	db $0 ; warps

	db $0 ; signs

	db $1 ; people
	db SPRITE_RED, $2 + 4, $2 + 4, $ff, $0, $1 ; person

TradeCenterMBlocks: ; 0x4fd91 20
	INCBIN "maps/tradecenterm.blk"

INCBIN "baserom.gbc",$4fda5,$4fe3f - $4fda5

UnnamedText_4fe3f: ; 0x4fe3f
	TX_FAR _UnnamedText_4fe3f
	db $50
; 0x4fe3f + 5 bytes

UnnamedText_4fe44: ; 0x4fe44
	TX_FAR _UnnamedText_4fe44
	db $50
; 0x4fe44 + 5 bytes

GetPredefPointer: ; 7E49
; stores hl in $CC4F,$CC50
; stores de in $CC51,$CC52
; stores bc in $CC53,$CC54
; grabs a byte "n" from $CC4E,
;    and gets the nth (3-byte) pointer in PredefPointers
; stores the bank of said pointer in [$D0B7]
; stores the pointer in hl and returns
	; ld $CC4F,hl
	ld a,h
	ld [$CC4F],a
	ld a,l
	ld [$CC50],a

	; ld $CC51,de
	ld hl,$CC51
	ld a,d
	ld [hli],a
	ld a,e
	ld [hli],a

	; ld $CC53,bc
	ld a,b
	ld [hli],a
	ld [hl],c

	ld hl,PredefPointers
	ld de,0

	; de = 3 * [$CC4E]
	ld a,[$CC4E]
	ld e,a
	add a,a
	add a,e
	ld e,a
	jr nc,.next\@
	inc d

.next\@
	add hl,de
	ld d,h
	ld e,l

	; get bank of predef routine
	ld a,[de]
	ld [$D0B7],a

	; get pointer
	inc de
	ld a,[de]
	ld l,a
	inc de
	ld a,[de]
	ld h,a

	ret

PredefPointers: ; 7E79
; these are pointers to ASM routines.
; they appear to be used in overworld map scripts.
	dbw $0F,$4D60
	dbw $0F,$70C6
	dbw $0F,$7073
	dbw $0B,$7E40
	dbw $0F,$7103
	dbw $1E,$5ABA
	dbw $03,$7132
	dbw BANK(HealParty),HealParty
	dbw BANK(MoveAnimation),MoveAnimation; 08 play move animation
	dbw $03,$771E
	dbw $03,$771E
	dbw $03,$781D
	dbw $03,$7836
	dbw $03,$771E
	dbw $03,$771E
	dbw $03,$7850
	dbw $03,$7666
	dbw $03,$71D7
	dbw $03,$71A6
	dbw $03,$469C
	dbw $0F,$4A83
	dbw $03,$71C8
	dbw $03,$71C8
	dbw $03,$6E9E
	dbw $03,$7850
	dbw $03,$4754
	dbw $0E,$6F5B
	dbw $01,$6E43
	dbw $03,$78A5; 1C, used in Pokémon Tower
	dbw $03,$3EB5
	dbw $03,$3E2E
	dbw $12,$40EB
	dbw $03,$78BA
	dbw $12,$40FF
	dbw $03,$7929
	dbw $03,$79A0
	dbw $12,$4125
	dbw $03,$7A1D
	dbw $03,$79DC
	dbw $01,$5AB0
	dbw $0F,$6D02
	dbw $10,$4000
	dbw $0E,$6D1C
	dbw $1C,$778C
	dbw $0F,$6F18
	dbw $01,$5A5F
	dbw $03,$6A03
	dbw $10,$50F3
	dbw $1C,$496D
	dbw $1E,$5DDA
	dbw $10,$5682
	dbw $1E,$5869
	dbw $1C,$4B5D
	dbw $03,$4586
	dbw $04,$6953
	dbw $04,$6B57
	dbw $10,$50E2
	dbw $15,$690F
	dbw $10,$5010
	dbw BANK(Predef3B),Predef3B; 3B display pic?
	dbw $03,$6F54
	dbw $10,$42D1
	dbw $0E,$6FB8
	dbw $1C,$770A
	dbw $1C,$602B
	dbw $03,$7113
	dbw $17,$5B5E
	dbw $04,$773E
	dbw $04,$7763
	dbw $1C,$5DDF
	dbw $17,$40DC; 46 load dex screen
	dbw $03,$72E5
	dbw $03,$7A1D
	dbw $0F,$4DEC
	dbw $1C,$4F60
	dbw $09,$7D6B
	dbw $05,$7C47; 4C player exclamation
	dbw $01,$5AAF; return immediately
	dbw $01,$64EB
	dbw $0D,$7CA1
	dbw $1C,$780F
	dbw $1C,$76BD
	dbw $1C,$75E8
	dbw $1C,$77E2
	dbw BANK(Predef54),Predef54 ; 54 initiate trade
	dbw $1D,$405C
	dbw $11,$4169
	dbw $1E,$45BA
	dbw $1E,$4510
	dbw $03,$45BE
	dbw $03,$460B
	dbw $03,$4D99
	dbw $01,$4DE1
	dbw $09,$7D98
	dbw $03,$7473
	dbw $04,$68EF
	dbw $04,$68F6
	dbw $07,$49C6
	dbw $16,$5035

SECTION "bank14",DATA,BANK[$14]

Route22_h: ; 0x50000 to 0x50022 (34 bytes) (id=33)
	db $00 ; tileset
	db ROUTE_22_HEIGHT, ROUTE_22_WIDTH ; dimensions (y, x)
	dw Route22Blocks, Route22Texts, Route22Script ; blocks, texts, scripts
	db NORTH | EAST ; connections

	; connections data

	db ROUTE_23
	dw Route23Blocks + (ROUTE_23_HEIGHT - 3) * ROUTE_23_WIDTH ; connection strip location
	dw $C6EB + 0 ; current map position
	db ROUTE_23_WIDTH, ROUTE_23_WIDTH ; bigness, width
	db (ROUTE_23_HEIGHT * 2) - 1, (0 * -2) ; alignments (y, x)
	dw $C6E9 + ROUTE_23_HEIGHT * (ROUTE_23_WIDTH + 6) ; window

	db VIRIDIAN_CITY
	dw ViridianCityBlocks + (VIRIDIAN_CITY_WIDTH) ; connection strip location
	dw $C6E5 + (ROUTE_22_WIDTH + 6) * (-3 + 4) ; current map position
	db $f, VIRIDIAN_CITY_WIDTH ; bigness, width
	db (-4 * -2), 0 ; alignments (y, x)
	dw $C6EF + VIRIDIAN_CITY_WIDTH ; window

	; end connections data

	dw Route22Object ; objects

Route22Object: ; 0x50022 (size=27)
	db $2c ; border tile

	db $1 ; warps
	db $5, $8, $0, ROUTE_22_GATE

	db $1 ; signs
	db $b, $7, $3 ; Route22Text3

	db $2 ; people
	db SPRITE_BLUE, $5 + 4, $19 + 4, $ff, $ff, $1 ; person
	db SPRITE_BLUE, $5 + 4, $19 + 4, $ff, $ff, $2 ; person

	; warp-to
	EVENT_DISP $14, $5, $8 ; ROUTE_22_GATE

Route22Blocks: ; 0x5003d 180
	INCBIN "maps/route22.blk"

Route20_h: ; 0x500f1 to 0x50113 (34 bytes) (id=31)
	db $00 ; tileset
	db ROUTE_20_HEIGHT, ROUTE_20_WIDTH ; dimensions (y, x)
	dw Route20Blocks, Route20Texts, Route20Script ; blocks, texts, scripts
	db WEST | EAST ; connections

	; connections data

	db CINNABAR_ISLAND
	dw CinnabarIslandBlocks - 3 + (CINNABAR_ISLAND_WIDTH) ; connection strip location
	dw $C6E8 + (ROUTE_20_WIDTH + 6) * (0 + 3) ; current map position
	db CINNABAR_ISLAND_HEIGHT, CINNABAR_ISLAND_WIDTH ; bigness, width
	db (0 * -2), (CINNABAR_ISLAND_WIDTH * 2) - 1 ; alignments (y, x)
	dw $C6EE + 2 * CINNABAR_ISLAND_WIDTH ; window

	db ROUTE_19
	dw Route19Blocks + (ROUTE_19_WIDTH * 15) ; connection strip location
	dw $C6E5 + (ROUTE_20_WIDTH + 6) * (-3 + 4) ; current map position
	db $c, ROUTE_19_WIDTH ; bigness, width
	db (-18 * -2), 0 ; alignments (y, x)
	dw $C6EF + ROUTE_19_WIDTH ; window

	; end connections data

	dw Route20Object ; objects

Route20Object: ; 0x50113 (size=106)
	db $43 ; border tile

	db $2 ; warps
	db $5, $30, $0, SEAFOAM_ISLANDS_1
	db $9, $3a, $2, SEAFOAM_ISLANDS_1

	db $2 ; signs
	db $7, $33, $b ; Route20Text11
	db $b, $39, $c ; Route20Text12

	db $a ; people
	db SPRITE_SWIMMER, $8 + 4, $57 + 4, $ff, $d1, $41, SWIMMER + $C8, $9 ; trainer
	db SPRITE_SWIMMER, $b + 4, $44 + 4, $ff, $d1, $42, BEAUTY + $C8, $f ; trainer
	db SPRITE_SWIMMER, $a + 4, $2d + 4, $ff, $d0, $43, BEAUTY + $C8, $6 ; trainer
	db SPRITE_SWIMMER, $e + 4, $37 + 4, $ff, $d3, $44, JR__TRAINER_F + $C8, $18 ; trainer
	db SPRITE_SWIMMER, $d + 4, $26 + 4, $ff, $d0, $45, SWIMMER + $C8, $a ; trainer
	db SPRITE_SWIMMER, $d + 4, $57 + 4, $ff, $d1, $46, SWIMMER + $C8, $b ; trainer
	db SPRITE_BLACK_HAIR_BOY_1, $9 + 4, $22 + 4, $ff, $d1, $47, BIRD_KEEPER + $C8, $b ; trainer
	db SPRITE_SWIMMER, $7 + 4, $19 + 4, $ff, $d1, $48, BEAUTY + $C8, $7 ; trainer
	db SPRITE_SWIMMER, $c + 4, $18 + 4, $ff, $d0, $49, JR__TRAINER_F + $C8, $10 ; trainer
	db SPRITE_SWIMMER, $8 + 4, $f + 4, $ff, $d1, $4a, BEAUTY + $C8, $8 ; trainer

	; warp-to
	EVENT_DISP $32, $5, $30 ; SEAFOAM_ISLANDS_1
	EVENT_DISP $32, $9, $3a ; SEAFOAM_ISLANDS_1

Route20Blocks: ; 0x5017d 450
	INCBIN "maps/route20.blk"

Route23_h: ; 0x5033f to 0x50361 (34 bytes) (id=34)
	db $17 ; tileset
	db ROUTE_23_HEIGHT, ROUTE_23_WIDTH ; dimensions (y, x)
	dw Route23Blocks, Route23Texts, Route23Script ; blocks, texts, scripts
	db NORTH | SOUTH ; connections

	; connections data

	db INDIGO_PLATEAU
	dw IndigoPlateauBlocks + (INDIGO_PLATEAU_HEIGHT - 3) * INDIGO_PLATEAU_WIDTH ; connection strip location
	dw $C6EB + 0 ; current map position
	db INDIGO_PLATEAU_WIDTH, INDIGO_PLATEAU_WIDTH ; bigness, width
	db (INDIGO_PLATEAU_HEIGHT * 2) - 1, (0 * -2) ; alignments (y, x)
	dw $C6E9 + INDIGO_PLATEAU_HEIGHT * (INDIGO_PLATEAU_WIDTH + 6) ; window

	db ROUTE_22
	dw Route22Blocks ; connection strip location
	dw $C6EB + (ROUTE_23_HEIGHT + 3) * (ROUTE_23_WIDTH + 6) + 0 ; current map position
	db $d, ROUTE_22_WIDTH ; bigness, width
	db 0, (0 * -2) ; alignments (y, x)
	dw $C6EF + ROUTE_22_WIDTH ; window

	; end connections data

	dw Route23Object ; objects

Route23Object: ; 0x50361 (size=81)
	db $f ; border tile

	db $4 ; warps
	db $8b, $7, $2, ROUTE_22_GATE
	db $8b, $8, $3, ROUTE_22_GATE
	db $1f, $4, $0, VICTORY_ROAD_1
	db $1f, $e, $1, VICTORY_ROAD_2

	db $1 ; signs
	db $21, $3, $8 ; Route23Text8

	db $7 ; people
	db SPRITE_GUARD, $23 + 4, $4 + 4, $ff, $d0, $1 ; person
	db SPRITE_GUARD, $38 + 4, $a + 4, $ff, $d0, $2 ; person
	db SPRITE_SWIMMER, $55 + 4, $8 + 4, $ff, $d0, $3 ; person
	db SPRITE_SWIMMER, $60 + 4, $b + 4, $ff, $d0, $4 ; person
	db SPRITE_GUARD, $69 + 4, $c + 4, $ff, $d0, $5 ; person
	db SPRITE_GUARD, $77 + 4, $8 + 4, $ff, $d0, $6 ; person
	db SPRITE_GUARD, $88 + 4, $8 + 4, $ff, $d0, $7 ; person

	; warp-to
	EVENT_DISP $a, $8b, $7 ; ROUTE_22_GATE
	EVENT_DISP $a, $8b, $8 ; ROUTE_22_GATE
	EVENT_DISP $a, $1f, $4 ; VICTORY_ROAD_1
	EVENT_DISP $a, $1f, $e ; VICTORY_ROAD_2

Route23Blocks: ; 0x503b2 720
	INCBIN "maps/route23.blk"

Route24_h: ; 0x50682 to 0x506a4 (34 bytes) (id=35)
	db $00 ; tileset
	db ROUTE_24_HEIGHT, ROUTE_24_WIDTH ; dimensions (y, x)
	dw Route24Blocks, Route24Texts, Route24Script ; blocks, texts, scripts
	db SOUTH | EAST ; connections

	; connections data

	db CERULEAN_CITY
	dw CeruleanCityBlocks + 2 ; connection strip location
	dw $C6EB + (ROUTE_24_HEIGHT + 3) * (ROUTE_24_WIDTH + 6) + -3 ; current map position
	db $10, CERULEAN_CITY_WIDTH ; bigness, width
	db 0, (-5 * -2) ; alignments (y, x)
	dw $C6EF + CERULEAN_CITY_WIDTH ; window

	db ROUTE_25
	dw Route25Blocks + (ROUTE_25_WIDTH * 0) ; connection strip location
	dw $C6E5 + (ROUTE_24_WIDTH + 6) * (0 + 4) ; current map position
	db ROUTE_25_HEIGHT, ROUTE_25_WIDTH ; bigness, width
	db (0 * -2), 0 ; alignments (y, x)
	dw $C6EF + ROUTE_25_WIDTH ; window

	; end connections data

	dw Route24Object ; objects

Route24Object: ; 0x506a4 (size=67)
	db $2c ; border tile

	db $0 ; warps

	db $0 ; signs

	db $8 ; people
	db SPRITE_BLACK_HAIR_BOY_1, $f + 4, $b + 4, $ff, $d2, $41, ROCKET + $C8, $6 ; trainer
	db SPRITE_BLACK_HAIR_BOY_1, $14 + 4, $5 + 4, $ff, $d1, $42, JR__TRAINER_M + $C8, $2 ; trainer
	db SPRITE_BLACK_HAIR_BOY_1, $13 + 4, $b + 4, $ff, $d2, $43, JR__TRAINER_M + $C8, $3 ; trainer
	db SPRITE_LASS, $16 + 4, $a + 4, $ff, $d3, $44, LASS + $C8, $7 ; trainer
	db SPRITE_BUG_CATCHER, $19 + 4, $b + 4, $ff, $d2, $45, YOUNGSTER + $C8, $4 ; trainer
	db SPRITE_LASS, $1c + 4, $a + 4, $ff, $d3, $46, LASS + $C8, $8 ; trainer
	db SPRITE_BUG_CATCHER, $1f + 4, $b + 4, $ff, $d2, $47, BUG_CATCHER + $C8, $9 ; trainer
	db SPRITE_BALL, $5 + 4, $a + 4, $ff, $ff, $88, TM_45 ; item

Route24Blocks: ; 0x506e7 180
	INCBIN "maps/route24.blk"

Route25_h: ; 0x5079b to 0x507b2 (23 bytes) (id=36)
	db $00 ; tileset
	db ROUTE_25_HEIGHT, ROUTE_25_WIDTH ; dimensions (y, x)
	dw Route25Blocks, Route25Texts, Route25Script ; blocks, texts, scripts
	db WEST ; connections

	; connections data

	db ROUTE_24
	dw Route24Blocks - 3 + (ROUTE_24_WIDTH) ; connection strip location
	dw $C6E8 + (ROUTE_25_WIDTH + 6) * (0 + 3) ; current map position
	db $c, ROUTE_24_WIDTH ; bigness, width
	db (0 * -2), (ROUTE_24_WIDTH * 2) - 1 ; alignments (y, x)
	dw $C6EE + 2 * ROUTE_24_WIDTH ; window

	; end connections data

	dw Route25Object ; objects

Route25Object: ; 0x507b2 (size=94)
	db $2c ; border tile

	db $1 ; warps
	db $3, $2d, $0, BILLS_HOUSE

	db $1 ; signs
	db $3, $2b, $b ; Route25Text11

	db $a ; people
	db SPRITE_BUG_CATCHER, $2 + 4, $e + 4, $ff, $d0, $41, YOUNGSTER + $C8, $5 ; trainer
	db SPRITE_BUG_CATCHER, $5 + 4, $12 + 4, $ff, $d1, $42, YOUNGSTER + $C8, $6 ; trainer
	db SPRITE_BLACK_HAIR_BOY_1, $4 + 4, $18 + 4, $ff, $d0, $43, JR__TRAINER_M + $C8, $2 ; trainer
	db SPRITE_LASS, $8 + 4, $12 + 4, $ff, $d3, $44, LASS + $C8, $9 ; trainer
	db SPRITE_BUG_CATCHER, $3 + 4, $20 + 4, $ff, $d2, $45, YOUNGSTER + $C8, $7 ; trainer
	db SPRITE_LASS, $4 + 4, $25 + 4, $ff, $d0, $46, LASS + $C8, $a ; trainer
	db SPRITE_HIKER, $4 + 4, $8 + 4, $ff, $d3, $47, HIKER + $C8, $2 ; trainer
	db SPRITE_HIKER, $9 + 4, $17 + 4, $ff, $d1, $48, HIKER + $C8, $3 ; trainer
	db SPRITE_HIKER, $7 + 4, $d + 4, $ff, $d3, $49, HIKER + $C8, $4 ; trainer
	db SPRITE_BALL, $2 + 4, $16 + 4, $ff, $ff, $8a, TM_19 ; item

	; warp-to
	EVENT_DISP $1e, $3, $2d ; BILLS_HOUSE

Route25Blocks: ; 0x50810 270
	INCBIN "maps/route25.blk"

IndigoPlateau_h: ; 0x5091e to 0x50935 (23 bytes) (id=9)
	db $17 ; tileset
	db INDIGO_PLATEAU_HEIGHT, INDIGO_PLATEAU_WIDTH ; dimensions (y, x)
	dw IndigoPlateauBlocks, IndigoPlateauTexts, IndigoPlateauScript ; blocks, texts, scripts
	db SOUTH ; connections

	; connections data

	db ROUTE_23
	dw Route23Blocks ; connection strip location
	dw $C6EB + (INDIGO_PLATEAU_HEIGHT + 3) * (INDIGO_PLATEAU_WIDTH + 6) + 0 ; current map position
	db ROUTE_23_WIDTH, ROUTE_23_WIDTH ; bigness, width
	db 0, (0 * -2) ; alignments (y, x)
	dw $C6EF + ROUTE_23_WIDTH ; window

	; end connections data

	dw IndigoPlateauObject ; objects

IndigoPlateauScript: ; 0x50935
	ret
; 0x50936

IndigoPlateauTexts:
IndigoPlateauObject: ; 0x50936 (size=20)
	db $e ; border tile

	db $2 ; warps
	db $5, $9, $0, INDIGO_PLATEAU_LOBBY
	db $5, $a, $0, INDIGO_PLATEAU_LOBBY

	db $0 ; signs

	db $0 ; people

	; warp-to
	EVENT_DISP $a, $5, $9 ; INDIGO_PLATEAU_LOBBY
	EVENT_DISP $a, $5, $a ; INDIGO_PLATEAU_LOBBY

IndigoPlateauBlocks: ; 0x5094a 90
	INCBIN "maps/indigoplateau.blk"

SaffronCity_h: ; 0x509a4 to 0x509dc (56 bytes) (id=10)
	db $00 ; tileset
	db SAFFRON_CITY_HEIGHT, SAFFRON_CITY_WIDTH ; dimensions (y, x)
	dw SaffronCityBlocks, SaffronCityTexts, SaffronCityScript ; blocks, texts, scripts
	db NORTH | SOUTH | WEST | EAST ; connections

	; connections data

	db ROUTE_5
	dw Route5Blocks + (ROUTE_5_HEIGHT - 3) * ROUTE_5_WIDTH ; connection strip location
	dw $C6EB + 5 ; current map position
	db ROUTE_5_WIDTH, ROUTE_5_WIDTH ; bigness, width
	db (ROUTE_5_HEIGHT * 2) - 1, (5 * -2) ; alignments (y, x)
	dw $C6E9 + ROUTE_5_HEIGHT * (ROUTE_5_WIDTH + 6) ; window

	db ROUTE_6
	dw Route6Blocks ; connection strip location
	dw $C6EB + (SAFFRON_CITY_HEIGHT + 3) * (SAFFRON_CITY_WIDTH + 6) + 5 ; current map position
	db ROUTE_6_WIDTH, ROUTE_6_WIDTH ; bigness, width
	db 0, (5 * -2) ; alignments (y, x)
	dw $C6EF + ROUTE_6_WIDTH ; window

	db ROUTE_7
	dw Route7Blocks - 3 + (ROUTE_7_WIDTH) ; connection strip location
	dw $C6E8 + (SAFFRON_CITY_WIDTH + 6) * (4 + 3) ; current map position
	db ROUTE_7_HEIGHT, ROUTE_7_WIDTH ; bigness, width
	db (4 * -2), (ROUTE_7_WIDTH * 2) - 1 ; alignments (y, x)
	dw $C6EE + 2 * ROUTE_7_WIDTH ; window

	db ROUTE_8
	dw Route8Blocks + (ROUTE_8_WIDTH * 0) ; connection strip location
	dw $C6E5 + (SAFFRON_CITY_WIDTH + 6) * (4 + 4) ; current map position
	db ROUTE_8_HEIGHT, ROUTE_8_WIDTH ; bigness, width
	db (4 * -2), 0 ; alignments (y, x)
	dw $C6EF + ROUTE_8_WIDTH ; window

	; end connections data

	dw SaffronCityObject ; objects

SaffronCityObject: ; 0x509dc (size=188)
	db $f ; border tile

	db $8 ; warps
	db $5, $7, $0, COPYCATS_HOUSE_1F
	db $3, $1a, $0, FIGHTINGDOJO
	db $3, $22, $0, SAFFRON_GYM
	db $b, $d, $0, SAFFRON_HOUSE_1
	db $b, $19, $0, SAFFRON_MART
	db $15, $12, $0, SILPH_CO_1F
	db $1d, $9, $0, SAFFRON_POKECENTER
	db $1d, $1d, $0, SAFFRON_HOUSE_2

	db $a ; signs
	db $5, $11, $10 ; SaffronCityText16
	db $5, $1b, $11 ; SaffronCityText17
	db $5, $23, $12 ; SaffronCityText18
	db $b, $1a, $13 ; SaffronCityText19
	db $13, $27, $14 ; SaffronCityText20
	db $15, $5, $15 ; SaffronCityText21
	db $15, $f, $16 ; SaffronCityText22
	db $1d, $a, $17 ; SaffronCityText23
	db $1d, $1b, $18 ; SaffronCityText24
	db $13, $1, $19 ; SaffronCityText25

	db $f ; people
	db SPRITE_ROCKET, $6 + 4, $7 + 4, $ff, $ff, $1 ; person
	db SPRITE_ROCKET, $8 + 4, $14 + 4, $fe, $2, $2 ; person
	db SPRITE_ROCKET, $4 + 4, $22 + 4, $ff, $ff, $3 ; person
	db SPRITE_ROCKET, $c + 4, $d + 4, $ff, $ff, $4 ; person
	db SPRITE_ROCKET, $19 + 4, $b + 4, $fe, $2, $5 ; person
	db SPRITE_ROCKET, $d + 4, $20 + 4, $fe, $2, $6 ; person
	db SPRITE_ROCKET, $1e + 4, $12 + 4, $fe, $2, $7 ; person
	db SPRITE_OAK_AIDE, $e + 4, $8 + 4, $fe, $0, $8 ; person
	db SPRITE_LAPRAS_GIVER, $17 + 4, $17 + 4, $ff, $ff, $9 ; person
	db SPRITE_ERIKA, $1e + 4, $11 + 4, $fe, $2, $a ; person
	db SPRITE_GENTLEMAN, $c + 4, $1e + 4, $ff, $d0, $b ; person
	db SPRITE_BIRD, $c + 4, $1f + 4, $ff, $d0, $c ; person
	db SPRITE_ROCKER, $8 + 4, $12 + 4, $ff, $d1, $d ; person
	db SPRITE_ROCKET, $16 + 4, $12 + 4, $ff, $d0, $e ; person
	db SPRITE_ROCKET, $16 + 4, $13 + 4, $ff, $d0, $f ; person

	; warp-to
	EVENT_DISP $14, $5, $7 ; COPYCATS_HOUSE_1F
	EVENT_DISP $14, $3, $1a ; FIGHTINGDOJO
	EVENT_DISP $14, $3, $22 ; SAFFRON_GYM
	EVENT_DISP $14, $b, $d ; SAFFRON_HOUSE_1
	EVENT_DISP $14, $b, $19 ; SAFFRON_MART
	EVENT_DISP $14, $15, $12 ; SILPH_CO_1F
	EVENT_DISP $14, $1d, $9 ; SAFFRON_POKECENTER
	EVENT_DISP $14, $1d, $1d ; SAFFRON_HOUSE_2

SaffronCityBlocks: ; 0x50a98 360
	INCBIN "maps/saffroncity.blk"

SaffronCityScript: ; 0x50c00
	jp $3c3c
; 0x50c03

SaffronCityTexts: ; 0x50c03
	dw SaffronCityText1, SaffronCityText2, SaffronCityText3, SaffronCityText4, SaffronCityText5, SaffronCityText6, SaffronCityText7, SaffronCityText8, SaffronCityText9, SaffronCityText10, SaffronCityText11, SaffronCityText12, SaffronCityText13, SaffronCityText14, SaffronCityText15, SaffronCityText16, SaffronCityText17, SaffronCityText18, SaffronCityText19, SaffronCityText20, SaffronCityText21, SaffronCityText22, SaffronCityText23, SaffronCityText24, SaffronCityText25

SaffronCityText1: ; 0x50c35
	TX_FAR _SaffronCityText1
	db $50

SaffronCityText2: ; 0x50c3a
	TX_FAR _SaffronCityText2
	db $50

SaffronCityText3: ; 0x50c3f
	TX_FAR _SaffronCityText3
	db $50

SaffronCityText4: ; 0x50c44
	TX_FAR _SaffronCityText4
	db $50

SaffronCityText5: ; 0x50c49
	TX_FAR _SaffronCityText5
	db $50

SaffronCityText6: ; 0x50c4e
	TX_FAR _SaffronCityText6
	db $50

SaffronCityText7: ; 0x50c53
	TX_FAR _SaffronCityText7
	db $50

SaffronCityText8: ; 0x50c58
	TX_FAR _SaffronCityText8
	db $50

SaffronCityText9: ; 0x50c5d
	TX_FAR _SaffronCityText9
	db $50

SaffronCityText10: ; 0x50c62
	TX_FAR _SaffronCityText10
	db $50

SaffronCityText11: ; 0x50c67
	TX_FAR _SaffronCityText11
	db $50

SaffronCityText12: ; 0x50c6c
	TX_FAR _SaffronCityText12
	db $15, $50

SaffronCityText13: ; 0x50c72
	TX_FAR _SaffronCityText13
	db $50

SaffronCityText14: ; 0x50c77
	TX_FAR _SaffronCityText14
	db $50

SaffronCityText15: ; 0x50c7c
	TX_FAR _SaffronCityText15
	db $50

SaffronCityText16: ; 0x50c81
	TX_FAR _SaffronCityText16
	db $50

SaffronCityText17: ; 0x50c86
	TX_FAR _SaffronCityText17
	db $50

SaffronCityText18: ; 0x50c8b
	TX_FAR _SaffronCityText18
	db $50

SaffronCityText20: ; 0x50c90
	TX_FAR _SaffronCityText20
	db $50

SaffronCityText21: ; 0x50c95
	TX_FAR _SaffronCityText21
	db $50

SaffronCityText22: ; 0x50c9a
	TX_FAR _SaffronCityText22
	db $50

SaffronCityText24: ; 0x50c9f
	TX_FAR _SaffronCityText24
	db $50

SaffronCityText25: ; 0x50ca4
	TX_FAR _SaffronCityText25
	db $50

Route20Script: ; 0x50ca9
	ld hl, $d7e7
	bit 0, [hl]
	res 0, [hl]
	call nz, $4cc6
	call $3c3c
	ld hl, $4d3a
	ld de, $4d1c
	ld a, [$d628]
	call $3160
	ld [$d628], a
	ret
; 0x50cc6

INCBIN "baserom.gbc",$50cc6,$5c

Route20Texts: ; 0x50d22
	dw Route20Text1, Route20Text2, Route20Text3, Route20Text4, Route20Text5, Route20Text6, Route20Text7, Route20Text8, Route20Text9, Route20Text10, Route20Text11, Route20Text12

Route20TrainerHeaders:
Route20TrainerHeader0:
	db $1 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d7e7 ; flag's byte
	dw Route20BattleText1 ; 0x4e17 TextBeforeBattle
	dw Route20AfterBattleText1 ; 0x4e21 TextAfterBattle
	dw Route20EndBattleText1 ; 0x4e1c TextEndBattle
	dw Route20EndBattleText1 ; 0x4e1c TextEndBattle
; 0x50d46

Route20TrainerHeader2: ; 0x50d46
	db $2 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d7e7 ; flag's byte
	dw Route20BattleText2 ; 0x4e26 TextBeforeBattle
	dw Route20AfterBattleText2 ; 0x4e30 TextAfterBattle
	dw Route20EndBattleText2 ; 0x4e2b TextEndBattle
	dw Route20EndBattleText2 ; 0x4e2b TextEndBattle
; 0x50d52

Route20TrainerHeader3: ; 0x50d52
	db $3 ; flag's bit
	db ($2 << 4) ; trainer's view range
	dw $d7e7 ; flag's byte
	dw Route20BattleText3 ; 0x4e35 TextBeforeBattle
	dw Route20AfterBattleText3 ; 0x4e3f TextAfterBattle
	dw Route20EndBattleText3 ; 0x4e3a TextEndBattle
	dw Route20EndBattleText3 ; 0x4e3a TextEndBattle
; 0x50d5e

Route20TrainerHeader4: ; 0x50d5e
	db $4 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d7e7 ; flag's byte
	dw Route20BattleText4 ; 0x4e44 TextBeforeBattle
	dw Route20AfterBattleText4 ; 0x4e4e TextAfterBattle
	dw Route20EndBattleText4 ; 0x4e49 TextEndBattle
	dw Route20EndBattleText4 ; 0x4e49 TextEndBattle
; 0x50d6a

Route20TrainerHeader5: ; 0x50d6a
	db $5 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d7e7 ; flag's byte
	dw Route20BattleText5 ; 0x4e53 TextBeforeBattle
	dw Route20AfterBattleText5 ; 0x4e5d TextAfterBattle
	dw Route20EndBattleText5 ; 0x4e58 TextEndBattle
	dw Route20EndBattleText5 ; 0x4e58 TextEndBattle
; 0x50d76

Route20TrainerHeader6: ; 0x50d76
	db $6 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d7e7 ; flag's byte
	dw Route20BattleText6 ; 0x4e62 TextBeforeBattle
	dw Route20AfterBattleText6 ; 0x4e6c TextAfterBattle
	dw Route20EndBattleText6 ; 0x4e67 TextEndBattle
	dw Route20EndBattleText6 ; 0x4e67 TextEndBattle
; 0x50d82

Route20TrainerHeader7: ; 0x50d82
	db $7 ; flag's bit
	db ($2 << 4) ; trainer's view range
	dw $d7e7 ; flag's byte
	dw Route20BattleText7 ; 0x4e71 TextBeforeBattle
	dw Route20AfterBattleText7 ; 0x4e7b TextAfterBattle
	dw Route20EndBattleText7 ; 0x4e76 TextEndBattle
	dw Route20EndBattleText7 ; 0x4e76 TextEndBattle
; 0x50d8e

Route20TrainerHeader8: ; 0x50d8e
	db $8 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d7e7 ; flag's byte
	dw Route20BattleText8 ; 0x4e80 TextBeforeBattle
	dw Route20AfterBattleText8 ; 0x4e8a TextAfterBattle
	dw Route20EndBattleText8 ; 0x4e85 TextEndBattle
	dw Route20EndBattleText8 ; 0x4e85 TextEndBattle
; 0x50d9a

Route20TrainerHeader9: ; 0x50d9a
	db $9 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d7e7 ; flag's byte
	dw Route20BattleText9 ; 0x4e8f TextBeforeBattle
	dw Route20AfterBattleText9 ; 0x4e99 TextAfterBattle
	dw Route20EndBattleText9 ; 0x4e94 TextEndBattle
	dw Route20EndBattleText9 ; 0x4e94 TextEndBattle
; 0x50da6

Route20TrainerHeader10: ; 0x50da6
	db $a ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d7e7 ; flag's byte
	dw Route20BattleText10 ; 0x4e9e TextBeforeBattle
	dw Route20AfterBattleText10 ; 0x4ea8 TextAfterBattle
	dw Route20EndBattleText10 ; 0x4ea3 TextEndBattle
	dw Route20EndBattleText10 ; 0x4ea3 TextEndBattle
; 0x50db2

db $ff

Route20Text1: ; 0x50db3
	db $08 ; asm
	ld hl, Route20TrainerHeader0
	call LoadTrainerHeader
	jp TextScriptEnd

Route20Text2: ; 0x50dbd
	db $08 ; asm
	ld hl, Route20TrainerHeader2
	call LoadTrainerHeader
	jp TextScriptEnd

Route20Text3: ; 0x50dc7
	db $08 ; asm
	ld hl, Route20TrainerHeader3
	call LoadTrainerHeader
	jp TextScriptEnd

Route20Text4: ; 0x50dd1
	db $08 ; asm
	ld hl, Route20TrainerHeader4
	call LoadTrainerHeader
	jp TextScriptEnd

Route20Text5: ; 0x50ddb
	db $08 ; asm
	ld hl, Route20TrainerHeader5
	call LoadTrainerHeader
	jp TextScriptEnd

Route20Text6: ; 0x50de5
	db $08 ; asm
	ld hl, Route20TrainerHeader6
	call LoadTrainerHeader
	jp TextScriptEnd

Route20Text7: ; 0x50def
	db $08 ; asm
	ld hl, Route20TrainerHeader7
	call LoadTrainerHeader
	jp TextScriptEnd

Route20Text8: ; 0x50df9
	db $08 ; asm
	ld hl, Route20TrainerHeader8
	call LoadTrainerHeader
	jp TextScriptEnd

Route20Text9: ; 0x50e03
	db $08 ; asm
	ld hl, Route20TrainerHeader9
	call LoadTrainerHeader
	jp TextScriptEnd

Route20Text10: ; 0x50e0d
	db $08 ; asm
	ld hl, Route20TrainerHeader10
	call LoadTrainerHeader
	jp TextScriptEnd

Route20BattleText1: ; 0x50e17
	TX_FAR _Route20BattleText1
	db $50
; 0x50e17 + 5 bytes

Route20EndBattleText1: ; 0x50e1c
	TX_FAR _Route20EndBattleText1
	db $50
; 0x50e1c + 5 bytes

Route20AfterBattleText1: ; 0x50e21
	TX_FAR _Route20AfterBattleText1
	db $50
; 0x50e21 + 5 bytes

Route20BattleText2: ; 0x50e26
	TX_FAR _Route20BattleText2
	db $50
; 0x50e26 + 5 bytes

Route20EndBattleText2: ; 0x50e2b
	TX_FAR _Route20EndBattleText2
	db $50
; 0x50e2b + 5 bytes

Route20AfterBattleText2: ; 0x50e30
	TX_FAR _Route20AfterBattleText2
	db $50
; 0x50e30 + 5 bytes

Route20BattleText3: ; 0x50e35
	TX_FAR _Route20BattleText3
	db $50
; 0x50e35 + 5 bytes

Route20EndBattleText3: ; 0x50e3a
	TX_FAR _Route20EndBattleText3
	db $50
; 0x50e3a + 5 bytes

Route20AfterBattleText3: ; 0x50e3f
	TX_FAR _Route20AfterBattleText3
	db $50
; 0x50e3f + 5 bytes

Route20BattleText4: ; 0x50e44
	TX_FAR _Route20BattleText4
	db $50
; 0x50e44 + 5 bytes

Route20EndBattleText4: ; 0x50e49
	TX_FAR _Route20EndBattleText4
	db $50
; 0x50e49 + 5 bytes

Route20AfterBattleText4: ; 0x50e4e
	TX_FAR _Route20AfterBattleText4
	db $50
; 0x50e4e + 5 bytes

Route20BattleText5: ; 0x50e53
	TX_FAR _Route20BattleText5
	db $50
; 0x50e53 + 5 bytes

Route20EndBattleText5: ; 0x50e58
	TX_FAR _Route20EndBattleText5
	db $50
; 0x50e58 + 5 bytes

Route20AfterBattleText5: ; 0x50e5d
	TX_FAR _Route20AfterBattleText5
	db $50
; 0x50e5d + 5 bytes

Route20BattleText6: ; 0x50e62
	TX_FAR _Route20BattleText6
	db $50
; 0x50e62 + 5 bytes

Route20EndBattleText6: ; 0x50e67
	TX_FAR _Route20EndBattleText6
	db $50
; 0x50e67 + 5 bytes

Route20AfterBattleText6: ; 0x50e6c
	TX_FAR _Route20AfterBattleText6
	db $50
; 0x50e6c + 5 bytes

Route20BattleText7: ; 0x50e71
	TX_FAR _Route20BattleText7
	db $50
; 0x50e71 + 5 bytes

Route20EndBattleText7: ; 0x50e76
	TX_FAR _Route20EndBattleText7
	db $50
; 0x50e76 + 5 bytes

Route20AfterBattleText7: ; 0x50e7b
	TX_FAR _Route20AfterBattleText7
	db $50
; 0x50e7b + 5 bytes

Route20BattleText8: ; 0x50e80
	TX_FAR _Route20BattleText8
	db $50
; 0x50e80 + 5 bytes

Route20EndBattleText8: ; 0x50e85
	TX_FAR _Route20EndBattleText8
	db $50
; 0x50e85 + 5 bytes

Route20AfterBattleText8: ; 0x50e8a
	TX_FAR _Route20AfterBattleText8
	db $50
; 0x50e8a + 5 bytes

Route20BattleText9: ; 0x50e8f
	TX_FAR _Route20BattleText9
	db $50
; 0x50e8f + 5 bytes

Route20EndBattleText9: ; 0x50e94
	TX_FAR _Route20EndBattleText9
	db $50
; 0x50e94 + 5 bytes

Route20AfterBattleText9: ; 0x50e99
	TX_FAR _Route20AfterBattleText9
	db $50
; 0x50e99 + 5 bytes

Route20BattleText10: ; 0x50e9e
	TX_FAR _Route20BattleText10
	db $50
; 0x50e9e + 5 bytes

Route20EndBattleText10: ; 0x50ea3
	TX_FAR _Route20EndBattleText10
	db $50
; 0x50ea3 + 5 bytes

Route20AfterBattleText10: ; 0x50ea8
	TX_FAR _Route20AfterBattleText10
	db $50
; 0x50ea8 + 5 bytes

Route20Text12:
Route20Text11: ; 0x50ead
	TX_FAR _Route20Text11
	db $50

Route22Script: ; 0x50eb2
	call $3c3c
	ld hl, Route22Scripts
	ld a, [$d60a]
	jp $3d97
; 0x50ebe

Route22Scripts: ; 0x50ebe
	dw Route22Script0, Route22Script1, Route22Script2, Route22Script3

INCBIN "baserom.gbc",$50ec6,$3a

Route22Script0: ; 0x50f00
	ld a, [$d7eb]
	bit 7, a
	ret z
	ld hl, $4f2d
	call $34bf
	ret nc
	ld a, [$cd3d]
	ld [$cf0d], a
	xor a
	ld [$ff00+$b4], a
	ld a, $f0
	ld [$cd6b], a
	ld a, $2
	ld [$d528], a
	ld a, [$d7eb]
	bit 0, a
	jr nz, .asm_50f32 ; 0x50f25 $b
	bit 1, a
	jp nz, $504e
	ret
	inc b
	dec e
	dec b
	dec e
	rst $38
.asm_50f32
	ld a, $1
	ld [$cd4f], a
	xor a
	ld [$cd50], a
	ld a, $4c
	call Predef
	ld a, [$d700]
	and a
	jr z, .asm_50f4e ; 0x50f44 $8
	ld a, $ff
	ld [$c0ee], a
	call $23b1
.asm_50f4e
	ld c, $2
	ld a, $de
	call $23a1
	ld a, $1
	ld [$ff00+$8c], a
	call $4ee6
	ld a, $1
	ld [$d60a], a
	ret
; 0x50f62

Route22Script1: ; 0x50f62
	ld a, [$d730]
	bit 0, a
	ret nz
	ld a, [$cf0d]
	cp $1
	jr nz, .asm_50f78 ; 0x50f6d $9
	ld a, $4
	ld [$d528], a
	ld a, $4
	jr .asm_50f7a ; 0x50f76 $2
.asm_50f78
	ld a, $c
.asm_50f7a
	ld [$ff00+$8d], a
	ld a, $1
	ld [$ff00+$8c], a
	call $34a6
	xor a
	ld [$cd6b], a
	ld a, $1
	ld [$ff00+$8c], a
	call $2920
	ld hl, $d72d
	set 6, [hl]
	set 7, [hl]
	ld hl, UnnamedText_511b7
	ld de, UnnamedText_511bc
	call $3354
	ld a, $e1
	ld [$d059], a
	ld hl, $4faf
	call $4ed6
	ld a, $2
	ld [$d60a], a
	ret
; 0x50faf

INCBIN "baserom.gbc",$50faf,$50fb5 - $50faf

Route22Script2: ; 0x50fb5
	ld a, [$d057]
	cp $ff
	jp z, $4ece
	ld a, [$c109]
	and a
	jr nz, .asm_50fc7 ; 0x50fc1 $4
	ld a, $4
	jr .asm_50fc9 ; 0x50fc5 $2
.asm_50fc7
	ld a, $c
.asm_50fc9
	ld [$ff00+$8d], a
	ld a, $1
	ld [$ff00+$8c], a
	call $34a6
	ld a, $f0
	ld [$cd6b], a
	ld hl, $d7eb
	set 5, [hl]
	ld a, $1
	ld [$ff00+$8c], a
	call $2920
	ld a, $ff
	ld [$c0ee], a
	call $23b1
	ld b, $2
	ld hl, $5b47
	call Bankswitch
	ld a, [$cf0d]
	cp $1
	jr nz, .asm_50fff ; 0x50ff8 $5
	call $5008
	jr .asm_51002 ; 0x50ffd $3
.asm_50fff
	call $500d
.asm_51002
	ld a, $3
	ld [$d60a], a
	ret
; 0x51008

INCBIN "baserom.gbc",$51008,$5102a - $51008

Route22Script3: ; 0x5102a
	ld a, [$d730]
	bit 0, a
	ret nz
	xor a
	ld [$cd6b], a
	ld a, $22
	ld [$cc4d], a
	ld a, $11
	call Predef
	call $2307
	ld hl, $d7eb
	res 0, [hl]
	res 7, [hl]
	ld a, $0
	ld [$d60a], a
	ret
; 0x5104e

INCBIN "baserom.gbc",$5104e,$127

Route22Texts: ; 0x51175
	dw Route22Text1, Route22Text2, Route22Text3

Route22Text1: ; 0x5117b
	db $08 ; asm
	ld a, [$d7eb]
	bit 5, a
	jr z, .asm_a88cf ; 0x51181
	ld hl, UnnamedText_511b2
	call PrintText
	jr .asm_48088 ; 0x51189
.asm_a88cf ; 0x5118b
	ld hl, UnnamedText_511ad
	call PrintText
.asm_48088 ; 0x51191
	jp TextScriptEnd

Route22Text2: ; 0x51194
	db $08 ; asm
	ld a, [$d7eb]
	bit 6, a
	jr z, .asm_58c0a ; 0x5119a
	ld hl, UnnamedText_511c6
	call PrintText
	jr .asm_673ee ; 0x511a2
.asm_58c0a ; 0x511a4
	ld hl, UnnamedText_511c1
	call PrintText
.asm_673ee ; 0x511aa
	jp TextScriptEnd

UnnamedText_511ad: ; 0x511ad
	TX_FAR _UnnamedText_511ad
	db $50
; 0x511ad + 5 bytes

UnnamedText_511b2: ; 0x511b2
	TX_FAR _UnnamedText_511b2
	db $50
; 0x511b2 + 5 bytes

UnnamedText_511b7: ; 0x511b7
	TX_FAR _UnnamedText_511b7
	db $50
; 0x511b7 + 5 bytes

UnnamedText_511bc: ; 0x511bc
	TX_FAR _UnnamedText_511bc
	db $50
; 0x511bc + 5 bytes

UnnamedText_511c1: ; 0x511c1
	TX_FAR _UnnamedText_511c1
	db $50
; 0x511c1 + 5 bytes

UnnamedText_511c6: ; 0x511c6
	TX_FAR _UnnamedText_511c6
	db $50
; 0x511c6 + 5 bytes

UnnamedText_511cb: ; 0x511cb
	TX_FAR _UnnamedText_511cb
	db $50
; 0x511cb + 5 bytes

UnnamedText_511d0: ; 0x511d0
	TX_FAR _UnnamedText_511d0
	db $50
; 0x511d0 + 5 bytes

Route22Text3: ; 0x511d5
	TX_FAR _Route22Text3
	db $50

Route23Script: ; 0x511da
	call $51e9
	call $3c3c
	ld hl, Route23Scripts
	ld a, [$d667]
	jp $3d97
; 0x511e9

INCBIN "baserom.gbc",$511e9,$51213 - $511e9

Route23Scripts: ; 0x51213
	dw Route23Script0

INCBIN "baserom.gbc",$51215,$4

Route23Script0: ; 0x51219
	ld hl, $5255
	ld a, [$d361]
	ld b, a
	ld e, $0
	ld c, $7
.asm_51224
	ld a, [hli]
	cp $ff
	ret z
	inc e
	dec c
	cp b
	jr nz, .asm_51224 ; 0x5122b $f7
	cp $23
	jr nz, .asm_51237 ; 0x5122f $6
	ld a, [$d362]
	cp $e
	ret nc
.asm_51237
	ld a, e
	ld [$ff00+$8c], a
	ld a, c
	ld [$cd3d], a
	ld b, $2
	ld hl, $d7ed
	ld a, $10
	call Predef
	ld a, c
	and a
	ret nz
	call $525d
	call $2920
	xor a
	ld [$ff00+$b4], a
	ret
; 0x51255

INCBIN "baserom.gbc",$51255,$a2

Route23Texts: ; 0x512f7
	dw Route23Text1, Route23Text2, Route23Text3, Route23Text4, Route23Text5, Route23Text6, Route23Text7, Route23Text8

Route23Text1: ; 0x51307
	db $08 ; asm
	ld a, $6
	call $5346
	jp TextScriptEnd

Route23Text2: ; 0x51310
	db $08 ; asm
	ld a, $5
	call $5346
	jp TextScriptEnd

Route23Text3: ; 0x51319
	db $08 ; asm
	ld a, $4
	call $5346
	jp TextScriptEnd

Route23Text4: ; 0x51322
	db $08 ; asm
	ld a, $3
	call $5346
	jp TextScriptEnd

Route23Text5: ; 0x5132b
	db $08 ; asm
	ld a, $2
	call $5346
	jp TextScriptEnd

Route23Text6: ; 0x51334
	db $08 ; asm
	ld a, $1
	call $5346
	jp TextScriptEnd

Route23Text7: ; 0x5133d
	db $8
	ld a, $0
	call $5346
	jp TextScriptEnd
; 0x51346

INCBIN "baserom.gbc",$51346,$513a3 - $51346

UnnamedText_513a3: ; 0x513a3
	TX_FAR _UnnamedText_513a3
	db $50
; 0x513a3 + 5 bytes

Route23Text8: ; 0x513a8
	TX_FAR _Route23Text8
	db $50

Route24Script: ; 0x513ad
	call $3c3c
	ld hl, Route24TrainerHeaders
	ld de, $53cb
	ld a, [$d602]
	call $3160
	ld [$d602], a
	ret
; 0x513c0

INCBIN "baserom.gbc",$513c0,$8b

Route24Texts: ; 0x5144b
	dw Route24Text1, Route24Text2, Route24Text3, Route24Text4, Route24Text5, Route24Text6, Route24Text7, Route24Text8

Route24TrainerHeaders:
Route24TrainerHeader0: ; 0x5145b
	db $2 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d7ef ; flag's byte
	dw Route24BattleText1 ; 0x5571 TextBeforeBattle
	dw Route24AfterBattleText1 ; 0x557b TextAfterBattle
	dw Route24EndBattleText1 ; 0x5576 TextEndBattle
	dw Route24EndBattleText1 ; 0x5576 TextEndBattle
; 0x51467

Route24TrainerHeader2: ; 0x51467
	db $3 ; flag's bit
	db ($1 << 4) ; trainer's view range
	dw $d7ef ; flag's byte
	dw Route24BattleText2 ; 0x5580 TextBeforeBattle
	dw Route24AfterBattleText2 ; 0x558a TextAfterBattle
	dw Route24EndBattleText2 ; 0x5585 TextEndBattle
	dw Route24EndBattleText2 ; 0x5585 TextEndBattle
; 0x51473

Route24TrainerHeader3: ; 0x51473
	db $4 ; flag's bit
	db ($1 << 4) ; trainer's view range
	dw $d7ef ; flag's byte
	dw Route24BattleText3 ; 0x558f TextBeforeBattle
	dw Route24AfterBattleText3 ; 0x5599 TextAfterBattle
	dw Route24EndBattleText3 ; 0x5594 TextEndBattle
	dw Route24EndBattleText3 ; 0x5594 TextEndBattle
; 0x5147f

Route24TrainerHeader4: ; 0x5147f
	db $5 ; flag's bit
	db ($1 << 4) ; trainer's view range
	dw $d7ef ; flag's byte
	dw Route24BattleText4 ; 0x559e TextBeforeBattle
	dw Route24AfterBattleText4 ; 0x55a8 TextAfterBattle
	dw Route24EndBattleText4 ; 0x55a3 TextEndBattle
	dw Route24EndBattleText4 ; 0x55a3 TextEndBattle
; 0x5148b

Route24TrainerHeader5: ; 0x5148b
	db $6 ; flag's bit
	db ($1 << 4) ; trainer's view range
	dw $d7ef ; flag's byte
	dw Route24BattleText5 ; 0x55ad TextBeforeBattle
	dw Route24AfterBattleText5 ; 0x55b7 TextAfterBattle
	dw Route24EndBattleText5 ; 0x55b2 TextEndBattle
	dw Route24EndBattleText5 ; 0x55b2 TextEndBattle
; 0x51497

Route24TrainerHeader6: ; 0x51497
	db $7 ; flag's bit
	db ($1 << 4) ; trainer's view range
	dw $d7ef ; flag's byte
	dw Route24BattleText6 ; 0x55bc TextBeforeBattle
	dw Route24AfterBattleText6 ; 0x55c6 TextAfterBattle
	dw Route24EndBattleText6 ; 0x55c1 TextEndBattle
	dw Route24EndBattleText6 ; 0x55c1 TextEndBattle
; 0x514a3

db $ff

Route24Text1: ; 0x514a4
	db $8
	ld hl, $d7f0
	res 1, [hl]
	ld a, [$d7ef]
	bit 0, a
	jr nz, .asm_a03f5 ; 0x514af $48
	ld hl, UnnamedText_51510
	call PrintText
	ld bc, $3101
	call GiveItem
	jr nc, .asm_3a23d ; 0x514bd $43
	ld hl, $d7ef
	set 0, [hl]
	ld hl, UnnamedText_5151a
	call PrintText
	ld hl, UnnamedText_51526
	call PrintText
	ld hl, $d72d
	set 6, [hl]
	set 7, [hl]
	ld hl, UnnamedText_5152b
	ld de, UnnamedText_5152b
	call $3354
	ld a, [$ff00+$8c]
	ld [$cf13], a
	call $336a
	call $32d7
	xor a
	ld [$ff00+$b4], a
	ld a, $3
	ld [$d602], a
	ld [$da39], a
	jp TextScriptEnd
.asm_a03f5 ; 0x514f9
	ld hl, UnnamedText_51530
	call PrintText
	jp TextScriptEnd
.asm_3a23d ; 0x51502
	ld hl, UnnamedText_51521
	call PrintText
	ld hl, $d7f0
	set 1, [hl]
	jp TextScriptEnd
; 0x51510

UnnamedText_51510: ; 0x51510
	TX_FAR _UnnamedText_51510 ; 0x92721
	db $0B
	TX_FAR _UnnamedText_51515 ; 0x92755
	db $50
; 0x5151a

UnnamedText_5151a: ; 0x5151a
	TX_FAR _UnnamedText_5151a ; 0x92779
	db $0B, $6, $50

UnnamedText_51521: ; 0x51521
	TX_FAR _UnnamedText_51521
	db $50
; 0x51521 + 5 bytes

UnnamedText_51526: ; 0x51526
	TX_FAR _UnnamedText_51526
	db $50
; 0x51526 + 5 bytes

UnnamedText_5152b: ; 0x5152b
	TX_FAR _UnnamedText_5152b
	db $50
; 0x5152b + 5 bytes

UnnamedText_51530: ; 0x51530
	TX_FAR _UnnamedText_51530
	db $50
; 0x51530 + 5 bytes

Route24Text2: ; 0x51535
	db $08 ; asm
	ld hl, Route24TrainerHeader0
	call LoadTrainerHeader
	jp TextScriptEnd

Route24Text3: ; 0x5153f
	db $08 ; asm
	ld hl, Route24TrainerHeader2
	call LoadTrainerHeader
	jp TextScriptEnd

Route24Text4: ; 0x51549
	db $08 ; asm
	ld hl, Route24TrainerHeader3
	call LoadTrainerHeader
	jp TextScriptEnd

Route24Text5: ; 0x51553
	db $08 ; asm
	ld hl, Route24TrainerHeader4
	call LoadTrainerHeader
	jp TextScriptEnd

Route24Text6: ; 0x5155d
	db $08 ; asm
	ld hl, Route24TrainerHeader5
	call LoadTrainerHeader
	jp TextScriptEnd

Route24Text7: ; 0x51567
	db $08 ; asm
	ld hl, Route24TrainerHeader6
	call LoadTrainerHeader
	jp TextScriptEnd

Route24BattleText1: ; 0x51571
	TX_FAR _Route24BattleText1
	db $50
; 0x51571 + 5 bytes

Route24EndBattleText1: ; 0x51576
	TX_FAR _Route24EndBattleText1
	db $50
; 0x51576 + 5 bytes

Route24AfterBattleText1: ; 0x5157b
	TX_FAR _Route24AfterBattleText1
	db $50
; 0x5157b + 5 bytes

Route24BattleText2: ; 0x51580
	TX_FAR _Route24BattleText2
	db $50
; 0x51580 + 5 bytes

Route24EndBattleText2: ; 0x51585
	TX_FAR _Route24EndBattleText2
	db $50
; 0x51585 + 5 bytes

Route24AfterBattleText2: ; 0x5158a
	TX_FAR _Route24AfterBattleText2
	db $50
; 0x5158a + 5 bytes

Route24BattleText3: ; 0x5158f
	TX_FAR _Route24BattleText3
	db $50
; 0x5158f + 5 bytes

Route24EndBattleText3: ; 0x51594
	TX_FAR _Route24EndBattleText3
	db $50
; 0x51594 + 5 bytes

Route24AfterBattleText3: ; 0x51599
	TX_FAR _Route24AfterBattleText3
	db $50
; 0x51599 + 5 bytes

Route24BattleText4: ; 0x5159e
	TX_FAR _Route24BattleText4
	db $50
; 0x5159e + 5 bytes

Route24EndBattleText4: ; 0x515a3
	TX_FAR _Route24EndBattleText4
	db $50
; 0x515a3 + 5 bytes

Route24AfterBattleText4: ; 0x515a8
	TX_FAR _Route24AfterBattleText4
	db $50
; 0x515a8 + 5 bytes

Route24BattleText5: ; 0x515ad
	TX_FAR _Route24BattleText5
	db $50
; 0x515ad + 5 bytes

Route24EndBattleText5: ; 0x515b2
	TX_FAR _Route24EndBattleText5
	db $50
; 0x515b2 + 5 bytes

Route24AfterBattleText5: ; 0x515b7
	TX_FAR _Route24AfterBattleText5
	db $50
; 0x515b7 + 5 bytes

Route24BattleText6: ; 0x515bc
	TX_FAR _Route24BattleText6
	db $50
; 0x515bc + 5 bytes

Route24EndBattleText6: ; 0x515c1
	TX_FAR _Route24EndBattleText6
	db $50
; 0x515c1 + 5 bytes

Route24AfterBattleText6: ; 0x515c6
	TX_FAR _Route24AfterBattleText6
	db $50
; 0x515c6 + 5 bytes

Route25Script: ; 0x515cb
	call Unknown_515e1
	call $3c3c
	ld hl, Route25TrainerHeaders
	ld de, $5622
	ld a, [$d603]
	call $3160
	ld [$d603], a
	ret
; 0x515e1

Unknown_515e1: ; 0x515e1
INCBIN "baserom.gbc",$515e1,$47

Route25Texts: ; 0x51628
	dw Route25Text1, Route25Text2, Route25Text3, Route25Text4, Route25Text5, Route25Text6, Route25Text7, Route25Text8, Route25Text9, Route25Text10, Route25Text11

Route25TrainerHeaders:
Route25TrainerHeader0: ; 0x5163e
	db $1 ; flag's bit
	db ($2 << 4) ; trainer's view range
	dw $d7f1 ; flag's byte
	dw Route25BattleText1 ; 0x5705 TextBeforeBattle
	dw Route25AfterBattleText1 ; 0x570f TextAfterBattle
	dw Route25EndBattleText1 ; 0x570a TextEndBattle
	dw Route25EndBattleText1 ; 0x570a TextEndBattle
; 0x5164a

Route25TrainerHeader2: ; 0x5164a
	db $2 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d7f1 ; flag's byte
	dw Route25BattleText2 ; 0x5714 TextBeforeBattle
	dw Route25AfterBattleText2 ; 0x571e TextAfterBattle
	dw Route25EndBattleText2 ; 0x5719 TextEndBattle
	dw Route25EndBattleText2 ; 0x5719 TextEndBattle
; 0x51656

Route25TrainerHeader3: ; 0x51656
	db $3 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d7f1 ; flag's byte
	dw Route25BattleText3 ; 0x5723 TextBeforeBattle
	dw Route25AfterBattleText3 ; 0x572d TextAfterBattle
	dw Route25EndBattleText3 ; 0x5728 TextEndBattle
	dw Route25EndBattleText3 ; 0x5728 TextEndBattle
; 0x51662

Route25TrainerHeader4: ; 0x51662
	db $4 ; flag's bit
	db ($2 << 4) ; trainer's view range
	dw $d7f1 ; flag's byte
	dw Route25BattleText4 ; 0x5732 TextBeforeBattle
	dw Route25AfterBattleText4 ; 0x573c TextAfterBattle
	dw Route25EndBattleText4 ; 0x5737 TextEndBattle
	dw Route25EndBattleText4 ; 0x5737 TextEndBattle
; 0x5166e

Route25TrainerHeader5: ; 0x5166e
	db $5 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d7f1 ; flag's byte
	dw Route25BattleText5 ; 0x5741 TextBeforeBattle
	dw Route25AfterBattleText5 ; 0x574b TextAfterBattle
	dw Route25EndBattleText5 ; 0x5746 TextEndBattle
	dw Route25EndBattleText5 ; 0x5746 TextEndBattle
; 0x5167a

Route25TrainerHeader6: ; 0x5167a
	db $6 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d7f1 ; flag's byte
	dw Route25BattleText6 ; 0x5750 TextBeforeBattle
	dw Route25AfterBattleText6 ; 0x575a TextAfterBattle
	dw Route25EndBattleText6 ; 0x5755 TextEndBattle
	dw Route25EndBattleText6 ; 0x5755 TextEndBattle
; 0x51686

Route25TrainerHeader7: ; 0x51686
	db $7 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d7f1 ; flag's byte
	dw Route25BattleText7 ; 0x575f TextBeforeBattle
	dw Route25AfterBattleText7 ; 0x5769 TextAfterBattle
	dw Route25EndBattleText7 ; 0x5764 TextEndBattle
	dw Route25EndBattleText7 ; 0x5764 TextEndBattle
; 0x51692

Route25TrainerHeader8: ; 0x51692
	db $8 ; flag's bit
	db ($2 << 4) ; trainer's view range
	dw $d7f1 ; flag's byte
	dw Route25BattleText8 ; 0x576e TextBeforeBattle
	dw Route25AfterBattleText8 ; 0x5778 TextAfterBattle
	dw Route25EndBattleText8 ; 0x5773 TextEndBattle
	dw Route25EndBattleText8 ; 0x5773 TextEndBattle
; 0x5169e

Route25TrainerHeader9: ; 0x5169e
	db $9 ; flag's bit
	db ($2 << 4) ; trainer's view range
	dw $d7f1 ; flag's byte
	dw Route25BattleText9 ; 0x577d TextBeforeBattle
	dw Route25AfterBattleText9 ; 0x5787 TextAfterBattle
	dw Route25EndBattleText9 ; 0x5782 TextEndBattle
	dw Route25EndBattleText9 ; 0x5782 TextEndBattle
; 0x516aa

db $ff

Route25Text1: ; 0x516ab
	db $08 ; asm
	ld hl, Route25TrainerHeader0
	call LoadTrainerHeader
	jp TextScriptEnd

Route25Text2: ; 0x516b5
	db $08 ; asm
	ld hl, Route25TrainerHeader2
	call LoadTrainerHeader
	jp TextScriptEnd

Route25Text3: ; 0x516bf
	db $08 ; asm
	ld hl, Route25TrainerHeader3
	call LoadTrainerHeader
	jp TextScriptEnd

Route25Text4: ; 0x516c9
	db $08 ; asm
	ld hl, Route25TrainerHeader4
	call LoadTrainerHeader
	jp TextScriptEnd

Route25Text5: ; 0x516d3
	db $08 ; asm
	ld hl, Route25TrainerHeader5
	call LoadTrainerHeader
	jp TextScriptEnd

Route25Text6: ; 0x516dd
	db $08 ; asm
	ld hl, Route25TrainerHeader6
	call LoadTrainerHeader
	jp TextScriptEnd

Route25Text7: ; 0x516e7
	db $08 ; asm
	ld hl, Route25TrainerHeader7
	call LoadTrainerHeader
	jp TextScriptEnd

Route25Text8: ; 0x516f1
	db $08 ; asm
	ld hl, Route25TrainerHeader8
	call LoadTrainerHeader
	jp TextScriptEnd

Route25Text9: ; 0x516fb
	db $08 ; asm
	ld hl, Route25TrainerHeader9
	call LoadTrainerHeader
	jp TextScriptEnd

Route25BattleText1: ; 0x51705
	TX_FAR _Route25BattleText1
	db $50
; 0x51705 + 5 bytes

Route25EndBattleText1: ; 0x5170a
	TX_FAR _Route25EndBattleText1
	db $50
; 0x5170a + 5 bytes

Route25AfterBattleText1: ; 0x5170f
	TX_FAR _Route25AfterBattleText1
	db $50
; 0x5170f + 5 bytes

Route25BattleText2: ; 0x51714
	TX_FAR _Route25BattleText2
	db $50
; 0x51714 + 5 bytes

Route25EndBattleText2: ; 0x51719
	TX_FAR _Route25EndBattleText2
	db $50
; 0x51719 + 5 bytes

Route25AfterBattleText2: ; 0x5171e
	TX_FAR _Route25AfterBattleText2
	db $50
; 0x5171e + 5 bytes

Route25BattleText3: ; 0x51723
	TX_FAR _Route25BattleText3
	db $50
; 0x51723 + 5 bytes

Route25EndBattleText3: ; 0x51728
	TX_FAR _Route25EndBattleText3
	db $50
; 0x51728 + 5 bytes

Route25AfterBattleText3: ; 0x5172d
	TX_FAR _Route25AfterBattleText3
	db $50
; 0x5172d + 5 bytes

Route25BattleText4: ; 0x51732
	TX_FAR _Route25BattleText4
	db $50
; 0x51732 + 5 bytes

Route25EndBattleText4: ; 0x51737
	TX_FAR _Route25EndBattleText4
	db $50
; 0x51737 + 5 bytes

Route25AfterBattleText4: ; 0x5173c
	TX_FAR _Route25AfterBattleText4
	db $50
; 0x5173c + 5 bytes

Route25BattleText5: ; 0x51741
	TX_FAR _Route25BattleText5
	db $50
; 0x51741 + 5 bytes

Route25EndBattleText5: ; 0x51746
	TX_FAR _Route25EndBattleText5
	db $50
; 0x51746 + 5 bytes

Route25AfterBattleText5: ; 0x5174b
	TX_FAR _Route25AfterBattleText5
	db $50
; 0x5174b + 5 bytes

Route25BattleText6: ; 0x51750
	TX_FAR _Route25BattleText6
	db $50
; 0x51750 + 5 bytes

Route25EndBattleText6: ; 0x51755
	TX_FAR _Route25EndBattleText6
	db $50
; 0x51755 + 5 bytes

Route25AfterBattleText6: ; 0x5175a
	TX_FAR _Route25AfterBattleText6
	db $50
; 0x5175a + 5 bytes

Route25BattleText7: ; 0x5175f
	TX_FAR _Route25BattleText7
	db $50
; 0x5175f + 5 bytes

Route25EndBattleText7: ; 0x51764
	TX_FAR _Route25EndBattleText7
	db $50
; 0x51764 + 5 bytes

Route25AfterBattleText7: ; 0x51769
	TX_FAR _Route25AfterBattleText7
	db $50
; 0x51769 + 5 bytes

Route25BattleText8: ; 0x5176e
	TX_FAR _Route25BattleText8
	db $50
; 0x5176e + 5 bytes

Route25EndBattleText8: ; 0x51773
	TX_FAR _Route25EndBattleText8
	db $50
; 0x51773 + 5 bytes

Route25AfterBattleText8: ; 0x51778
	TX_FAR _Route25AfterBattleText8
	db $50
; 0x51778 + 5 bytes

Route25BattleText9: ; 0x5177d
	TX_FAR _Route25BattleText9
	db $50
; 0x5177d + 5 bytes

Route25EndBattleText9: ; 0x51782
	TX_FAR _Route25EndBattleText9
	db $50
; 0x51782 + 5 bytes

Route25AfterBattleText9: ; 0x51787
	TX_FAR _Route25AfterBattleText9
	db $50
; 0x51787 + 5 bytes

Route25Text11: ; 0x5178c
	TX_FAR _Route25Text11
	db $50

VictoryRoad2_h: ; 0x51791 to 0x5179d (12 bytes) (id=194)
	db $11 ; tileset
	db VICTORY_ROAD_2_HEIGHT, VICTORY_ROAD_2_WIDTH ; dimensions (y, x)
	dw VictoryRoad2Blocks, VictoryRoad2Texts, VictoryRoad2Script ; blocks, texts, scripts
	db $00 ; connections

	dw VictoryRoad2Object ; objects

VictoryRoad2Script: ; 0x5179d
	ld hl, $d126
	bit 6, [hl]
	res 6, [hl]
	call nz, VictoryRoad2Script_Unknown517c4
	ld hl, $d126
	bit 5, [hl]
	res 5, [hl]
	call nz, $57c9
	call $3c3c
	ld hl, VictoryRoad2TrainerHeaders
	ld de, $57eb
	ld a, [$d63f]
	call $3160
	ld [$d63f], a
	ret
; 0x517c4

VictoryRoad2Script_Unknown517c4: ; 0x517c4
INCBIN "baserom.gbc",$517c4,$57

VictoryRoad2Texts: ; 0x5181b
	dw VictoryRoad2Text1, VictoryRoad2Text2, VictoryRoad2Text3, VictoryRoad2Text4, VictoryRoad2Text5, VictoryRoad2Text6, VictoryRoad2Text7, VictoryRoad2Text8, VictoryRoad2Text9, VictoryRoad2Text10, VictoryRoad2Text11, VictoryRoad2Text12, VictoryRoad2Text13

VictoryRoad2TrainerHeaders:
VictoryRoad2TrainerHeader0: ; 0x51835
	db $1 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d7ee ; flag's byte
	dw VictoryRoad2BattleText1 ; 0x58ca TextBeforeBattle
	dw VictoryRoad2AfterBattleText1 ; 0x58d4 TextAfterBattle
	dw VictoryRoad2EndBattleText1 ; 0x58cf TextEndBattle
	dw VictoryRoad2EndBattleText1 ; 0x58cf TextEndBattle
; 0x51841

VictoryRoad2TrainerHeader2: ; 0x51841
	db $2 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d7ee ; flag's byte
	dw VictoryRoad2BattleText2 ; 0x58d9 TextBeforeBattle
	dw VictoryRoad2AfterBattleText2 ; 0x58e3 TextAfterBattle
	dw VictoryRoad2EndBattleText2 ; 0x58de TextEndBattle
	dw VictoryRoad2EndBattleText2 ; 0x58de TextEndBattle
; 0x5184d

VictoryRoad2TrainerHeader3: ; 0x5184d
	db $3 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d7ee ; flag's byte
	dw VictoryRoad2BattleText3 ; 0x58e8 TextBeforeBattle
	dw VictoryRoad2AfterBattleText3 ; 0x58f2 TextAfterBattle
	dw VictoryRoad2EndBattleText3 ; 0x58ed TextEndBattle
	dw VictoryRoad2EndBattleText3 ; 0x58ed TextEndBattle
; 0x51859

VictoryRoad2TrainerHeader4: ; 0x51859
	db $4 ; flag's bit
	db ($1 << 4) ; trainer's view range
	dw $d7ee ; flag's byte
	dw VictoryRoad2BattleText4 ; 0x58f7 TextBeforeBattle
	dw VictoryRoad2AfterBattleText4 ; 0x5901 TextAfterBattle
	dw VictoryRoad2EndBattleText4 ; 0x58fc TextEndBattle
	dw VictoryRoad2EndBattleText4 ; 0x58fc TextEndBattle
; 0x51865

VictoryRoad2TrainerHeader5: ; 0x51865
	db $5 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d7ee ; flag's byte
	dw VictoryRoad2BattleText5 ; 0x5906 TextBeforeBattle
	dw VictoryRoad2AfterBattleText5 ; 0x5910 TextAfterBattle
	dw VictoryRoad2EndBattleText5 ; 0x590b TextEndBattle
	dw VictoryRoad2EndBattleText5 ; 0x590b TextEndBattle
; 0x51871

VictoryRoad2TrainerHeader6: ; 0x51871
	db $6 ; flag's bit
	db ($0 << 4) ; trainer's view range
	dw $d7ee ; flag's byte
	dw VictoryRoad2BattleText6 ; 0x58ba TextBeforeBattle
	dw VictoryRoad2BattleText6 ; 0x58ba TextAfterBattle
	dw VictoryRoad2BattleText6 ; 0x58ba TextEndBattle
	dw VictoryRoad2BattleText6 ; 0x58ba TextEndBattle
; 0x5187d

db $ff

VictoryRoad2Text1: ; 0x5187e
	db $08 ; asm
	ld hl, VictoryRoad2TrainerHeader0
	call LoadTrainerHeader
	jp TextScriptEnd

VictoryRoad2Text2: ; 0x51888
	db $08 ; asm
	ld hl, VictoryRoad2TrainerHeader2
	call LoadTrainerHeader
	jp TextScriptEnd

VictoryRoad2Text3: ; 0x51892
	db $08 ; asm
	ld hl, VictoryRoad2TrainerHeader3
	call LoadTrainerHeader
	jp TextScriptEnd

VictoryRoad2Text4: ; 0x5189c
	db $08 ; asm
	ld hl, VictoryRoad2TrainerHeader4
	call LoadTrainerHeader
	jp TextScriptEnd

VictoryRoad2Text5: ; 0x518a6
	db $08 ; asm
	ld hl, VictoryRoad2TrainerHeader5
	call LoadTrainerHeader
	jp TextScriptEnd

VictoryRoad2Text6: ; 0x518b0
	db $08 ; asm
	ld hl, VictoryRoad2TrainerHeader6
	call LoadTrainerHeader
	jp TextScriptEnd

VictoryRoad2BattleText6: ; 0x518ba
	TX_FAR _VictoryRoad2BattleText6 ; 0x8d06e
	db $8
	ld a, $49
	call $13d0
	call $3748
	jp TextScriptEnd
; 0x518ca

VictoryRoad2BattleText1: ; 0x518ca
	TX_FAR _VictoryRoad2BattleText1
	db $50
; 0x518ca + 5 bytes

VictoryRoad2EndBattleText1: ; 0x518cf
	TX_FAR _VictoryRoad2EndBattleText1
	db $50
; 0x518cf + 5 bytes

VictoryRoad2AfterBattleText1: ; 0x518d4
	TX_FAR _VictoryRoad2AfterBattleText1
	db $50
; 0x518d4 + 5 bytes

VictoryRoad2BattleText2: ; 0x518d9
	TX_FAR _VictoryRoad2BattleText2
	db $50
; 0x518d9 + 5 bytes

VictoryRoad2EndBattleText2: ; 0x518de
	TX_FAR _VictoryRoad2EndBattleText2
	db $50
; 0x518de + 5 bytes

VictoryRoad2AfterBattleText2: ; 0x518e3
	TX_FAR _VictoryRoad2AfterBattleText2
	db $50
; 0x518e3 + 5 bytes

VictoryRoad2BattleText3: ; 0x518e8
	TX_FAR _VictoryRoad2BattleText3
	db $50
; 0x518e8 + 5 bytes

VictoryRoad2EndBattleText3: ; 0x518ed
	TX_FAR _VictoryRoad2EndBattleText3
	db $50
; 0x518ed + 5 bytes

VictoryRoad2AfterBattleText3: ; 0x518f2
	TX_FAR _VictoryRoad2AfterBattleText3
	db $50
; 0x518f2 + 5 bytes

VictoryRoad2BattleText4: ; 0x518f7
	TX_FAR _VictoryRoad2BattleText4
	db $50
; 0x518f7 + 5 bytes

VictoryRoad2EndBattleText4: ; 0x518fc
	TX_FAR _VictoryRoad2EndBattleText4
	db $50
; 0x518fc + 5 bytes

VictoryRoad2AfterBattleText4: ; 0x51901
	TX_FAR _VictoryRoad2AfterBattleText4
	db $50
; 0x51901 + 5 bytes

VictoryRoad2BattleText5: ; 0x51906
	TX_FAR _VictoryRoad2BattleText5
	db $50
; 0x51906 + 5 bytes

VictoryRoad2EndBattleText5: ; 0x5190b
	TX_FAR _VictoryRoad2EndBattleText5
	db $50
; 0x5190b + 5 bytes

VictoryRoad2AfterBattleText5: ; 0x51910
	TX_FAR _VictoryRoad2AfterBattleText5
	db $50
; 0x51910 + 5 bytes

VictoryRoad2Object: ; 0x51915 (size=154)
	db $7d ; border tile

	db $7 ; warps
	db $8, $0, $2, VICTORY_ROAD_1
	db $7, $1d, $3, $ff
	db $8, $1d, $3, $ff
	db $7, $17, $0, VICTORY_ROAD_3
	db $e, $19, $2, VICTORY_ROAD_3
	db $7, $1b, $1, VICTORY_ROAD_3
	db $1, $1, $3, VICTORY_ROAD_3

	db $0 ; signs

	db $d ; people
	db SPRITE_HIKER, $9 + 4, $c + 4, $ff, $d2, $41, BLACKBELT + $C8, $9 ; trainer
	db SPRITE_BLACK_HAIR_BOY_2, $d + 4, $15 + 4, $ff, $d2, $42, JUGGLER + $C8, $2 ; trainer
	db SPRITE_BLACK_HAIR_BOY_1, $8 + 4, $13 + 4, $ff, $d0, $43, TAMER + $C8, $5 ; trainer
	db SPRITE_BLACK_HAIR_BOY_2, $2 + 4, $4 + 4, $ff, $d0, $44, POKEMANIAC + $C8, $6 ; trainer
	db SPRITE_BLACK_HAIR_BOY_2, $3 + 4, $1a + 4, $ff, $d2, $45, JUGGLER + $C8, $5 ; trainer
	db SPRITE_BIRD, $5 + 4, $b + 4, $ff, $d1, $46, MOLTRES, $32 ; trainer
	db SPRITE_BALL, $5 + 4, $1b + 4, $ff, $ff, $87, TM_17 ; item
	db SPRITE_BALL, $9 + 4, $12 + 4, $ff, $ff, $88, FULL_HEAL ; item
	db SPRITE_BALL, $b + 4, $9 + 4, $ff, $ff, $89, TM_05 ; item
	db SPRITE_BALL, $0 + 4, $b + 4, $ff, $ff, $8a, GUARD_SPEC_ ; item
	db SPRITE_BOULDER, $e + 4, $4 + 4, $ff, $10, $b ; person
	db SPRITE_BOULDER, $5 + 4, $5 + 4, $ff, $10, $c ; person
	db SPRITE_BOULDER, $10 + 4, $17 + 4, $ff, $10, $d ; person

	; warp-to
	EVENT_DISP $f, $8, $0 ; VICTORY_ROAD_1
	EVENT_DISP $f, $7, $1d
	EVENT_DISP $f, $8, $1d
	EVENT_DISP $f, $7, $17 ; VICTORY_ROAD_3
	EVENT_DISP $f, $e, $19 ; VICTORY_ROAD_3
	EVENT_DISP $f, $7, $1b ; VICTORY_ROAD_3
	EVENT_DISP $f, $1, $1 ; VICTORY_ROAD_3

VictoryRoad2Blocks: ; 0x519af 135
	INCBIN "maps/victoryroad2.blk"

MtMoon2_h: ; 0x51a36 to 0x51a42 (12 bytes) (id=60)
	db $11 ; tileset
	db MT_MOON_2_HEIGHT, MT_MOON_2_WIDTH ; dimensions (y, x)
	dw MtMoon2Blocks, MtMoon2Texts, MtMoon2Script ; blocks, texts, scripts
	db $00 ; connections

	dw MtMoon2Object ; objects

MtMoon2Script: ; 0x51a42
	call $3c3c
	ret
; 0x51a46

MtMoon2Texts:
	dw MtMoonText1

MtMoonText1: ; 0x51a48
	TX_FAR _UnnamedText_51a48
	db $50
; 0x51a48 + 5 bytes

MtMoon2Object: ; 0x51a4d (size=68)
	db $3 ; border tile

	db $8 ; warps
	db $5, $5, $2, MT_MOON_1
	db $b, $11, $0, MT_MOON_3
	db $9, $19, $3, MT_MOON_1
	db $f, $19, $4, MT_MOON_1
	db $11, $15, $1, MT_MOON_3
	db $1b, $d, $2, MT_MOON_3
	db $3, $17, $3, MT_MOON_3
	db $3, $1b, $2, $ff

	db $0 ; signs

	db $0 ; people

	; warp-to
	EVENT_DISP $e, $5, $5 ; MT_MOON_1
	EVENT_DISP $e, $b, $11 ; MT_MOON_3
	EVENT_DISP $e, $9, $19 ; MT_MOON_1
	EVENT_DISP $e, $f, $19 ; MT_MOON_1
	EVENT_DISP $e, $11, $15 ; MT_MOON_3
	EVENT_DISP $e, $1b, $d ; MT_MOON_3
	EVENT_DISP $e, $3, $17 ; MT_MOON_3
	EVENT_DISP $e, $3, $1b

MtMoon2Blocks: ; 0x51a91 196
	INCBIN "maps/mtmoon2.blk"

SilphCo7_h: ; 0x51b55 to 0x51b61 (12 bytes) (id=212)
	db $16 ; tileset
	db SILPH_CO_7F_HEIGHT, SILPH_CO_7F_WIDTH ; dimensions (y, x)
	dw SilphCo7Blocks, SilphCo7Texts, SilphCo7Script ; blocks, texts, scripts
	db $00 ; connections

	dw SilphCo7Object ; objects

SilphCo7Script: ; 0x51b61
	call SilphCo7Script_Unknown51b77
	call $3c3c
	ld hl, SilphCo7TrainerHeaders
	ld de, $5c17
	ld a, [$d648]
	call $3160
	ld [$d648], a
	ret
; 0x51b77

SilphCo7Script_Unknown51b77: ; 0x5177
INCBIN "baserom.gbc",$51b77,$1c8

SilphCo7Texts: ; 0x51d3f
	dw SilphCo7Text1, SilphCo7Text2, SilphCo7Text3, SilphCo7Text4, SilphCo7Text5, SilphCo7Text6, SilphCo7Text7, SilphCo7Text8, SilphCo7Text9, SilphCo7Text10, SilphCo7Text11, SilphCo7Text12, SilphCo7Text13, SilphCo7Text14, SilphCo7Text15

SilphCo7TrainerHeaders:
SilphCo7TrainerHeader0: ; 0x51d5d
	db $5 ; flag's bit
	db ($2 << 4) ; trainer's view range
	dw $d82f ; flag's byte
	dw SilphCo7BattleText1 ; 0x5e5a TextBeforeBattle
	dw SilphCo7AfterBattleText1 ; 0x5e64 TextAfterBattle
	dw SilphCo7EndBattleText1 ; 0x5e5f TextEndBattle
	dw SilphCo7EndBattleText1 ; 0x5e5f TextEndBattle
; 0x51d69

SilphCo7TrainerHeader2: ; 0x51d69
	db $6 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d82f ; flag's byte
	dw SilphCo7BattleText2 ; 0x5e73 TextBeforeBattle
	dw SilphCo7AfterBattleText2 ; 0x5e7d TextAfterBattle
	dw SilphCo7EndBattleText2 ; 0x5e78 TextEndBattle
	dw SilphCo7EndBattleText2 ; 0x5e78 TextEndBattle
; 0x51d75

SilphCo7TrainerHeader3: ; 0x51d75
	db $7 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d82f ; flag's byte
	dw SilphCo7BattleText3 ; 0x5e8c TextBeforeBattle
	dw SilphCo7AfterBattleText3 ; 0x5e96 TextAfterBattle
	dw SilphCo7EndBattleText3 ; 0x5e91 TextEndBattle
	dw SilphCo7EndBattleText3 ; 0x5e91 TextEndBattle
; 0x51d81

SilphCo7TrainerHeader4: ; 0x51d81
	db $8 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d82f ; flag's byte
	dw SilphCo7BattleText4 ; 0x5ea5 TextBeforeBattle
	dw SilphCo7AfterBattleText4 ; 0x5eaf TextAfterBattle
	dw SilphCo7EndBattleText4 ; 0x5eaa TextEndBattle
	dw SilphCo7EndBattleText4 ; 0x5eaa TextEndBattle
; 0x51d8d

db $ff

SilphCo7Text1: ; 0x51d8e
	db $08 ; asm
	ld a, [$d72e]
	bit 0, a
	jr z, .asm_d7e17 ; 0x51d94
	ld a, [$d838]
	bit 7, a
	jr nz, .asm_688b4 ; 0x51d9b
	ld hl, UnnamedText_51ddd
	call PrintText
	jr .asm_b3069 ; 0x51da3
.asm_d7e17 ; 0x51da5
	ld hl, UnnamedText_51dd3
	call PrintText
	ld bc, (LAPRAS << 8) | 15
	call GivePokemon
	jr nc, .asm_b3069 ; 0x51db1
	ld a, [$ccd3]
	and a
	call z, $3865
	call $3c3c
	ld hl, UnnamedText_51dd8
	call PrintText
	ld hl, $d72e
	set 0, [hl]
	jr .asm_b3069 ; 0x51dc8
.asm_688b4 ; 0x51dca
	ld hl, UnnamedText_51de2
	call PrintText
.asm_b3069 ; 0x51dd0
	jp TextScriptEnd

UnnamedText_51dd3: ; 0x51dd3
	TX_FAR _UnnamedText_51dd3
	db $50
; 0x51dd3 + 5 bytes

UnnamedText_51dd8: ; 0x51dd8
	TX_FAR _UnnamedText_51dd8
	db $50
; 0x51dd8 + 5 bytes

UnnamedText_51ddd: ; 0x51ddd
	TX_FAR _UnnamedText_51ddd
	db $50
; 0x51ddd + 5 bytes

UnnamedText_51de2: ; 0x51de2
	TX_FAR _UnnamedText_51de2
	db $50
; 0x51de2 + 5 bytes

SilphCo7Text2: ; 0x51de7
	db $8
	ld a, [$d838]
	bit 7, a
	jr nz, .asm_892ce ; 0x51ded $8
	ld hl, UnnamedText_51e00
	call PrintText
	jr .asm_e4d89 ; 0x51df5 $6
.asm_892ce ; 0x51df7
	ld hl, UnnamedText_51e05
	call PrintText
.asm_e4d89 ; 0x51dfd
	jp TextScriptEnd
; 0x51e00

UnnamedText_51e00: ; 0x51e00
	TX_FAR _UnnamedText_51e00
	db $50
; 0x51e00 + 5 bytes

UnnamedText_51e05: ; 0x51e05
	TX_FAR _UnnamedText_51e05
	db $50
; 0x51e05 + 5 bytes

SilphCo7Text3: ; 0x51e0a
	db $08 ; asm
	ld a, [$d838]
	bit 7, a
	jr nz, .asm_254aa ; 0x51e10
	ld hl, UnnamedText_51e23
	call PrintText
	jr .asm_6472b ; 0x51e18
.asm_254aa ; 0x51e1a
	ld hl, UnnamedText_51e28
	call PrintText
.asm_6472b ; 0x51e20
	jp TextScriptEnd

UnnamedText_51e23: ; 0x51e23
	TX_FAR _UnnamedText_51e23
	db $50
; 0x51e23 + 5 bytes

UnnamedText_51e28: ; 0x51e28
	TX_FAR _UnnamedText_51e28
	db $50
; 0x51e28 + 5 bytes

SilphCo7Text4: ; 0x51e2d
	db $08 ; asm
	ld a, [$d838]
	bit 7, a
	jr nz, .asm_0f7ee ; 0x51e33
	ld hl, UnnamedText_51e46
	call PrintText
	jr .asm_27a32 ; 0x51e3b
.asm_0f7ee ; 0x51e3d
	ld hl, UnnamedText_51e4b
	call PrintText
.asm_27a32 ; 0x51e43
	jp TextScriptEnd

UnnamedText_51e46: ; 0x51e46
	TX_FAR _UnnamedText_51e46
	db $50
; 0x51e46 + 5 bytes

UnnamedText_51e4b: ; 0x51e4b
	TX_FAR _UnnamedText_51e4b
	db $50
; 0x51e4b + 5 bytes

SilphCo7Text5: ; 0x51e50
	db $08 ; asm
	ld hl, SilphCo7TrainerHeader0
	call LoadTrainerHeader
	jp TextScriptEnd

SilphCo7BattleText1: ; 0x51e5a
	TX_FAR _SilphCo7BattleText1
	db $50
; 0x51e5a + 5 bytes

SilphCo7EndBattleText1: ; 0x51e5f
	TX_FAR _SilphCo7EndBattleText1
	db $50
; 0x51e5f + 5 bytes

SilphCo7AfterBattleText1: ; 0x51e64
	TX_FAR _SilphCo7AfterBattleText1
	db $50
; 0x51e64 + 5 bytes

SilphCo7Text6: ; 0x51e69
	db $08 ; asm
	ld hl, SilphCo7TrainerHeader2
	call LoadTrainerHeader
	jp TextScriptEnd

SilphCo7BattleText2: ; 0x51e73
	TX_FAR _SilphCo7BattleText2
	db $50
; 0x51e73 + 5 bytes

SilphCo7EndBattleText2: ; 0x51e78
	TX_FAR _SilphCo7EndBattleText2
	db $50
; 0x51e78 + 5 bytes

SilphCo7AfterBattleText2: ; 0x51e7d
	TX_FAR _SilphCo7AfterBattleText2
	db $50
; 0x51e7d + 5 bytes

SilphCo7Text7: ; 0x51e82
	db $08 ; asm
	ld hl, SilphCo7TrainerHeader3
	call LoadTrainerHeader
	jp TextScriptEnd

SilphCo7BattleText3: ; 0x51e8c
	TX_FAR _SilphCo7BattleText3
	db $50
; 0x51e8c + 5 bytes

SilphCo7EndBattleText3: ; 0x51e91
	TX_FAR _SilphCo7EndBattleText3
	db $50
; 0x51e91 + 5 bytes

SilphCo7AfterBattleText3: ; 0x51e96
	TX_FAR _SilphCo7AfterBattleText3
	db $50
; 0x51e96 + 5 bytes

SilphCo7Text8: ; 0x51e9b
	db $08 ; asm
	ld hl, SilphCo7TrainerHeader4
	call LoadTrainerHeader
	jp TextScriptEnd

SilphCo7BattleText4: ; 0x51ea5
	TX_FAR _SilphCo7BattleText4
	db $50
; 0x51ea5 + 5 bytes

SilphCo7EndBattleText4: ; 0x51eaa
	TX_FAR _SilphCo7EndBattleText4
	db $50
; 0x51eaa + 5 bytes

SilphCo7AfterBattleText4: ; 0x51eaf
	TX_FAR _SilphCo7AfterBattleText4
	db $50
; 0x51eaf + 5 bytes

SilphCo7Text9: ; 0x51eb4
	db $08 ; asm
	ld hl, UnnamedText_51ebe
	call PrintText
	jp TextScriptEnd

UnnamedText_51ebe: ; 0x51ebe
	TX_FAR _UnnamedText_51ebe
	db $50
; 0x51ebe + 5 bytes

SilphCo7Text13: ; 0x51ec3
	TX_FAR _UnnamedText_51ec3
	db $50
; 0x51ec3 + 5 bytes

SilphCo7Text14: ; 0x51ec8
	TX_FAR _UnnamedText_51ec8
	db $50
; 0x51ec8 + 5 bytes

UnnamedText_51ecd: ; 0x51ecd
	TX_FAR _UnnamedText_51ecd
	db $50
; 0x51ecd + 5 bytes

SilphCo7Text15: ; 0x51ed2
	TX_FAR _UnnamedText_51ed2
	db $50
; 0x51ed2 + 5 bytes

SilphCo7Object: ; 0x51ed7 (size=128)
	db $2e ; border tile

	db $6 ; warps
	db $0, $10, $1, SILPH_CO_8F
	db $0, $16, $0, SILPH_CO_6F
	db $0, $12, $0, SILPH_CO_ELEVATOR
	db $7, $5, $3, SILPH_CO_11F
	db $3, $5, $8, SILPH_CO_3F
	db $f, $15, $3, SILPH_CO_5F

	db $0 ; signs

	db $b ; people
	db SPRITE_LAPRAS_GIVER, $5 + 4, $1 + 4, $ff, $ff, $1 ; person
	db SPRITE_LAPRAS_GIVER, $d + 4, $d + 4, $ff, $d1, $2 ; person
	db SPRITE_LAPRAS_GIVER, $a + 4, $7 + 4, $ff, $ff, $3 ; person
	db SPRITE_ERIKA, $8 + 4, $a + 4, $ff, $ff, $4 ; person
	db SPRITE_ROCKET, $1 + 4, $d + 4, $ff, $d0, $45, ROCKET + $C8, $20 ; trainer
	db SPRITE_OAK_AIDE, $d + 4, $2 + 4, $ff, $d0, $46, SCIENTIST + $C8, $8 ; trainer
	db SPRITE_ROCKET, $2 + 4, $14 + 4, $ff, $d2, $47, ROCKET + $C8, $21 ; trainer
	db SPRITE_ROCKET, $e + 4, $13 + 4, $ff, $d3, $48, ROCKET + $C8, $22 ; trainer
	db SPRITE_BLUE, $7 + 4, $3 + 4, $ff, $d1, $9 ; person
	db SPRITE_BALL, $9 + 4, $1 + 4, $ff, $ff, $8a, CALCIUM ; item
	db SPRITE_BALL, $b + 4, $18 + 4, $ff, $ff, $8b, TM_03 ; item

	; warp-to
	EVENT_DISP $d, $0, $10 ; SILPH_CO_8F
	EVENT_DISP $d, $0, $16 ; SILPH_CO_6F
	EVENT_DISP $d, $0, $12 ; SILPH_CO_ELEVATOR
	EVENT_DISP $d, $7, $5 ; SILPH_CO_11F
	EVENT_DISP $d, $3, $5 ; SILPH_CO_3F
	EVENT_DISP $d, $f, $15 ; SILPH_CO_5F

SilphCo7Blocks: ; 0x51f57 117
	INCBIN "maps/silphco7.blk"

Mansion2_h: ; 0x51fcc to 0x51fd8 (12 bytes) (id=214)
	db $16 ; tileset
	db MANSION_2_HEIGHT, MANSION_2_WIDTH ; dimensions (y, x)
	dw Mansion2Blocks, Mansion2Texts, Mansion2Script ; blocks, texts, scripts
	db $00 ; connections

	dw Mansion2Object ; objects

Mansion2Script:
	call Mansion2Script_Unknown51fee
	call $3c3c
	ld hl, Mansion2TrainerHeaders
	ld de, $6047
	ld a, [$d63c]
	call $3160
	ld [$d63c], a
	ret
; 0x51fee

Mansion2Script_Unknown51fee: ; 0x51fee
INCBIN "baserom.gbc",$51fee,$5204d - $51fee

Mansion2Texts: ; 0x5204d
	dw Mansion2Text1, Mansion2Text2, Mansion2Text3, Mansion2Text4, Mansion2Text5

Mansion2TrainerHeaders:
Mansion2TrainerHeader0: ; 0x52057
	db $1 ; flag's bit
	db ($0 << 4) ; trainer's view range
	dw $d847 ; flag's byte
	dw Mansion2BattleText1 ; 0x606e TextBeforeBattle
	dw Mansion2AfterBattleText1 ; 0x6078 TextAfterBattle
	dw Mansion2EndBattleText1 ; 0x6073 TextEndBattle
	dw Mansion2EndBattleText1 ; 0x6073 TextEndBattle
; 0x52063

db $ff

Mansion2Text1: ; 0x52064
	db $08 ; asm
	ld hl, Mansion2TrainerHeader0
	call LoadTrainerHeader
	jp TextScriptEnd

Mansion2BattleText1: ; 0x5206e
	TX_FAR _Mansion2BattleText1
	db $50
; 0x5206e + 5 bytes

Mansion2EndBattleText1: ; 0x52073
	TX_FAR _Mansion2EndBattleText1
	db $50
; 0x52073 + 5 bytes

Mansion2AfterBattleText1: ; 0x52078
	TX_FAR _Mansion2AfterBattleText1
	db $50
; 0x52078 + 5 bytes

Mansion2Text3: ; 0x5207d
	TX_FAR _Mansion2Text3
	db $50

Mansion2Text4: ; 0x52082
	TX_FAR _Mansion2Text4
	db $50

Mansion3Text6:
Mansion2Text5: ; 0x52087
	db $8
	ld hl, UnnamedText_520c2
	call PrintText
	call $35ec
	ld a, [$cc26]
	and a
	jr nz, .asm_520b9 ; 0x52095 $22
	ld a, $1
	ld [$cc3c], a
	ld hl, $d126
	set 5, [hl]
	ld hl, UnnamedText_520c7
	call PrintText
	ld a, $ad
	call $23b1
	ld hl, $d796
	bit 0, [hl]
	set 0, [hl]
	jr z, .asm_520bf ; 0x520b3 $a
	res 0, [hl]
	jr .asm_520bf ; 0x520b7 $6
.asm_520b9
	ld hl, UnnamedText_520cc
	call PrintText
.asm_520bf
	jp TextScriptEnd
; 0x520c2

UnnamedText_520c2: ; 0x520c2
	TX_FAR _UnnamedText_520c2
	db $50
; 0x520c2 + 5 bytes

UnnamedText_520c7: ; 0x520c7
	TX_FAR _UnnamedText_520c7
	db $50
; 0x520c7 + 5 bytes

UnnamedText_520cc: ; 0x520cc
	TX_FAR _UnnamedText_520cc
	db $50
; 0x520cc + 5 bytes

Mansion2Object: ; 0x520d1 (size=63)
	db $1 ; border tile

	db $4 ; warps
	db $a, $5, $4, MANSION_1
	db $a, $7, $0, MANSION_3
	db $e, $19, $2, MANSION_3
	db $1, $6, $1, MANSION_3

	db $0 ; signs

	db $4 ; people
	db SPRITE_BLACK_HAIR_BOY_2, $11 + 4, $3 + 4, $fe, $2, $41, BURGLAR + $C8, $7 ; trainer
	db SPRITE_BALL, $7 + 4, $1c + 4, $ff, $ff, $82, CALCIUM ; item
	db SPRITE_BOOK_MAP_DEX, $2 + 4, $12 + 4, $ff, $ff, $3 ; person
	db SPRITE_BOOK_MAP_DEX, $16 + 4, $3 + 4, $ff, $ff, $4 ; person

	; warp-to
	EVENT_DISP $f, $a, $5 ; MANSION_1
	EVENT_DISP $f, $a, $7 ; MANSION_3
	EVENT_DISP $f, $e, $19 ; MANSION_3
	EVENT_DISP $f, $1, $6 ; MANSION_3

Mansion2Blocks:
	INCBIN "maps/mansion2.blk"

Mansion3_h: ; 0x521e2 to 0x521ee (12 bytes) (id=215)
	db $16 ; tileset
	db MANSION_3_HEIGHT, MANSION_3_WIDTH ; dimensions (y, x)
	dw Mansion3Blocks, Mansion3Texts, Mansion3Script ; blocks, texts, scripts
	db $00 ; connections

	dw Mansion3Object ; objects

Mansion3Script:
	call Unnamed_52204
	call $3c3c
	ld hl, Mansion3TrainerHeader0
	ld de, $6235
	ld a, [$d63d]
	call $3160
	ld [$d63d], a
	ret
; 0x52204

Unnamed_52204: ; 0x52204
INCBIN "baserom.gbc",$52204,$5228a - $52204

Mansion3Texts: ; 0x5228a
	dw Mansion3Text1, Mansion3Text2, Mansion3Text3, Mansion3Text4, Mansion3Text5, Mansion3Text6

Mansion3TrainerHeaders:
Mansion3TrainerHeader0: ; 0x52296
	db $1 ; flag's bit
	db ($0 << 4) ; trainer's view range
	dw $d849 ; flag's byte
	dw Mansion3BattleText1 ; 0x62c3 TextBeforeBattle
	dw Mansion3AfterBattleText1 ; 0x62cd TextAfterBattle
	dw Mansion3EndBattleText1 ; 0x62c8 TextEndBattle
	dw Mansion3EndBattleText1 ; 0x62c8 TextEndBattle
; 0x522a2

Mansion3TrainerHeader2: ; 0x522a2
	db $2 ; flag's bit
	db ($2 << 4) ; trainer's view range
	dw $d849 ; flag's byte
	dw Mansion3BattleText2 ; 0x62d2 TextBeforeBattle
	dw Mansion3AfterBattleText2 ; 0x62dc TextAfterBattle
	dw Mansion3EndBattleText2 ; 0x62d7 TextEndBattle
	dw Mansion3EndBattleText2 ; 0x62d7 TextEndBattle
; 0x522ae

db $ff

Mansion3Text1: ; 0x522af
	db $08 ; asm
	ld hl, Mansion3TrainerHeader0
	call LoadTrainerHeader
	jp TextScriptEnd

Mansion3Text2: ; 0x522b9
	db $08 ; asm
	ld hl, Mansion3TrainerHeader2
	call LoadTrainerHeader
	jp TextScriptEnd

Mansion3BattleText1: ; 0x522c3
	TX_FAR _Mansion3BattleText1
	db $50
; 0x522c3 + 5 bytes

Mansion3EndBattleText1: ; 0x522c8
	TX_FAR _Mansion3EndBattleText1
	db $50
; 0x522c8 + 5 bytes

Mansion3AfterBattleText1: ; 0x522cd
	TX_FAR _Mansion3AfterBattleText1
	db $50
; 0x522cd + 5 bytes

Mansion3BattleText2: ; 0x522d2
	TX_FAR _Mansion3BattleText2
	db $50
; 0x522d2 + 5 bytes

Mansion3EndBattleText2: ; 0x522d7
	TX_FAR _Mansion3EndBattleText2
	db $50
; 0x522d7 + 5 bytes

Mansion3AfterBattleText2: ; 0x522dc
	TX_FAR _Mansion3AfterBattleText2
	db $50
; 0x522dc + 5 bytes

Mansion3Text5: ; 0x522e1
	TX_FAR _Mansion3Text5
	db $50

Mansion3Object: ; 0x522e6 (size=64)
	db $1 ; border tile

	db $3 ; warps
	db $a, $7, $1, MANSION_2
	db $1, $6, $3, MANSION_2
	db $e, $19, $2, MANSION_2

	db $0 ; signs

	db $5 ; people
	db SPRITE_BLACK_HAIR_BOY_2, $b + 4, $5 + 4, $fe, $2, $41, BURGLAR + $C8, $8 ; trainer
	db SPRITE_OAK_AIDE, $b + 4, $14 + 4, $ff, $d2, $42, SCIENTIST + $C8, $c ; trainer
	db SPRITE_BALL, $10 + 4, $1 + 4, $ff, $ff, $83, MAX_POTION ; item
	db SPRITE_BALL, $5 + 4, $19 + 4, $ff, $ff, $84, IRON ; item
	db SPRITE_BOOK_MAP_DEX, $c + 4, $6 + 4, $ff, $ff, $5 ; person

	; warp-to
	EVENT_DISP $f, $a, $7 ; MANSION_2
	EVENT_DISP $f, $1, $6 ; MANSION_2
	EVENT_DISP $f, $e, $19 ; MANSION_2

Mansion3Blocks:
	INCBIN "maps/mansion3.blk"

Mansion4_h: ; 0x523ad to 0x523b9 (12 bytes) (id=216)
	db $16 ; tileset
	db MANSION_4_HEIGHT, MANSION_4_WIDTH ; dimensions (y, x)
	dw Mansion4Blocks, Mansion4Texts, Mansion4Script ; blocks, texts, scripts
	db $00 ; connections

	dw Mansion4Object ; objects

Mansion4Script: ; 0x523b9
	call Unknown_523cf
	call $3c3c
	ld hl, Mansion4TrainerHeader0
	ld de, $6430
	ld a, [$d63e]
	call $3160
	ld [$d63e], a
	ret
; 0x523cf

Unknown_523cf: ; 0x523cf
INCBIN "baserom.gbc",$523cf,$52436 - $523cf

Mansion4Texts: ; 0x52436
INCBIN "baserom.gbc",$52436,$52448 - $52436

Mansion4TrainerHeaders:
Mansion4TrainerHeader0: ; 0x52448
	db $1 ; flag's bit
	db ($0 << 4) ; trainer's view range
	dw $d84b ; flag's byte
	dw Mansion4BattleText1 ; 0x6475 TextBeforeBattle
	dw Mansion4AfterBattleText1 ; 0x647f TextAfterBattle
	dw Mansion4EndBattleText1 ; 0x647a TextEndBattle
	dw Mansion4EndBattleText1 ; 0x647a TextEndBattle
; 0x52454

Mansion4TrainerHeader2: ; 0x52454
	db $2 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d84b ; flag's byte
	dw Mansion4BattleText2 ; 0x6484 TextBeforeBattle
	dw Mansion4AfterBattleText2 ; 0x648e TextAfterBattle
	dw Mansion4EndBattleText2 ; 0x6489 TextEndBattle
	dw Mansion4EndBattleText2 ; 0x6489 TextEndBattle
; 0x52460

db $ff

Mansion4Text1: ; 0x52461
	db $08 ; asm
	ld hl, Mansion4TrainerHeader0
	call LoadTrainerHeader
	jp TextScriptEnd

Mansion4Text2: ; 0x5246b
	db $08 ; asm
	ld hl, Mansion4TrainerHeader2
	call LoadTrainerHeader
	jp TextScriptEnd

Mansion4BattleText1: ; 0x52475
	TX_FAR _Mansion4BattleText1
	db $50
; 0x52475 + 5 bytes

Mansion4EndBattleText1: ; 0x5247a
	TX_FAR _Mansion4EndBattleText1
	db $50
; 0x5247a + 5 bytes

Mansion4AfterBattleText1: ; 0x5247f
	TX_FAR _Mansion4AfterBattleText1
	db $50
; 0x5247f + 5 bytes

Mansion4BattleText2: ; 0x52484
	TX_FAR _Mansion4BattleText2
	db $50
; 0x52484 + 5 bytes

Mansion4EndBattleText2: ; 0x52489
	TX_FAR _Mansion4EndBattleText2
	db $50
; 0x52489 + 5 bytes

Mansion4AfterBattleText2: ; 0x5248e
	TX_FAR _Mansion4AfterBattleText2
	db $50
; 0x5248e + 5 bytes

Mansion4Text7: ; 0x52493
	TX_FAR _Mansion4Text7
	db $50

Mansion4Object: ; 0x52498 (size=69)
	db $1 ; border tile

	db $1 ; warps
	db $16, $17, $5, MANSION_1

	db $0 ; signs

	db $8 ; people
	db SPRITE_BLACK_HAIR_BOY_2, $17 + 4, $10 + 4, $ff, $ff, $41, BURGLAR + $C8, $9 ; trainer
	db SPRITE_OAK_AIDE, $b + 4, $1b + 4, $ff, $d0, $42, SCIENTIST + $C8, $d ; trainer
	db SPRITE_BALL, $2 + 4, $a + 4, $ff, $ff, $83, RARE_CANDY ; item
	db SPRITE_BALL, $16 + 4, $1 + 4, $ff, $ff, $84, FULL_RESTORE ; item
	db SPRITE_BALL, $19 + 4, $13 + 4, $ff, $ff, $85, TM_14 ; item
	db SPRITE_BALL, $4 + 4, $5 + 4, $ff, $ff, $86, TM_22 ; item
	db SPRITE_BOOK_MAP_DEX, $14 + 4, $10 + 4, $ff, $ff, $7 ; person
	db SPRITE_BALL, $d + 4, $5 + 4, $ff, $ff, $88, SECRET_KEY ; item

	; warp-to
	EVENT_DISP $f, $16, $17 ; MANSION_1

Mansion4Blocks:
	INCBIN "maps/mansion4.blk"

INCBIN "baserom.gbc",$525af,$526f3 - $525af

UnnamedText_526f3: ; 0x526f3
	TX_FAR _UnnamedText_526f3
	db $50
; 0x526f3 + 5 bytes

UnnamedText_526f8: ; 0x526f8
	TX_FAR _UnnamedText_526f8
	db $50
; 0x526f8 + 5 bytes

INCBIN "baserom.gbc",$526fd,$1e

CeladonPrizeMenu: ; 0x5271b 14:671B
	ld b,COIN_CASE
	call IsItemInBag
	jr nz,.havingCoinCase\@
	ld hl,RequireCoinCaseTextPtr
	jp PrintText
.havingCoinCase\@
	ld hl,$D730
	set 6,[hl]
	ld hl,ExchangeCoinsForPrizesTextPtr
	call PrintText
; the following are the menu settings
	xor a
	ld [$CC26],a
	ld [$CC2A],a
	ld a,$03
	ld [$CC29],a
	ld a,$03
	ld [$CC28],a
	ld a,$04
	ld [$CC24],a
	ld a,$01
	ld [$CC25],a
	call PrintPrizePrice ; 687A
	FuncCoord 0,2
	ld hl,Coord
	ld b,$08
	ld c,$10
	call TextBoxBorder
	call GetPrizeMenuId ;678E
	call $2429
	ld hl,WhichPrizeTextPtr
	call PrintText
	call $3ABE ; menu choice handler
	bit 1,a ; keypress = B (Cancel)
	jr nz,.NoChoice\@
	ld a,[$CC26]
	cp a,$03 ; "NO,THANKS" choice
	jr z,.NoChoice\@
	call HandlePrizeChoice ; 14:68C6
.NoChoice\@
	ld hl,$D730
	res 6,[hl]
	ret

RequireCoinCaseTextPtr: ; 14:677E
	TX_FAR _RequireCoinCaseText ; 22:628E
	db $0D
	db "@"

ExchangeCoinsForPrizesTextPtr: ; 14:6784
	TX_FAR _ExchangeCoinsForPrizesText ; 22:62A9
	db "@"

WhichPrizeTextPtr: ; 14:6789
	TX_FAR _WhichPrizeText ; 22:62CD
	db "@"

GetPrizeMenuId: ; 14:678E
; determine which one among the three
; prize-texts has been selected
; using the text ID (stored in [$FF8C])
; load the three prizes at $D13D-$D13F
; load the three prices ar $D141-$D146
; display the three prizes' names
; (distinguishing between Pokemon names
; and Items (specifically TMs) names)
	ld a,[$FF8C]
	sub a,$03       ; prize-texts' id are 3, 4 and 5
	ld [$D12F],a    ; prize-texts' id (relative, i.e. 0, 1 or 2)
	add a
	add a
	ld d,$00
	ld e,a
	ld hl,PrizeDifferentMenuPtrs
	add hl,de
	ld a,[hli]
	ld d,[hl]
	ld e,a
	inc hl
	push hl
	ld hl,W_PRIZE1
	call $3829      ; XXX what does this do
	pop hl
	ld a,[hli]
	ld h,[hl]
	ld l,a
	ld de,$D141
	ld bc,$0006
	call CopyData
	ld a,[$D12F]
	cp a,$02        ;is TM_menu?
	jr nz,.putMonName\@
	ld a,[W_PRIZE1]
	ld [$D11E],a
	call GetItemName
	FuncCoord 2,4
	ld hl,Coord
	call PlaceString
	ld a,[W_PRIZE2]
	ld [$D11E],a
	call GetItemName
	FuncCoord 2,6
	ld hl,Coord
	call PlaceString
	ld a,[W_PRIZE3]
	ld [$D11E],a
	call GetItemName
	FuncCoord 2,8
	ld hl,Coord
	call PlaceString
	jr .putNoThanksText\@
.putMonName\@ ; 14:67EC
	ld a,[W_PRIZE1]
	ld [$D11E],a
	call GetMonName
	FuncCoord 2,4
	ld hl,Coord
	call PlaceString
	ld a,[W_PRIZE2]
	ld [$D11E],a
	call GetMonName
	FuncCoord 2,6
	ld hl,Coord
	call PlaceString
	ld a,[W_PRIZE3]
	ld [$D11E],a
	call GetMonName
	FuncCoord 2,8
	ld hl,Coord
	call PlaceString
.putNoThanksText\@ ; 14:6819
	FuncCoord 2,10
	ld hl,Coord
	ld de,NoThanksText
	call PlaceString
; put prices on the right side of the textbox
	ld de,$D141
	FuncCoord 13,5
	ld hl,Coord
; reg. c:
; [low nybble] number of bytes
; [bit 765 = %100] space-padding (not zero-padding)
	ld c,(1 << 7 | 2)
; Function $15CD displays BCD value (same routine
; used by text-command $02)
	call $15CD ; Print_BCD
	ld de,$D143
	FuncCoord 13,7
	ld hl,Coord
	ld c,(%1 << 7 | 2)
	call $15CD
	ld de,$D145
	FuncCoord 13,9
	ld hl,Coord
	ld c,(1 << 7 | 2)
	jp $15CD

PrizeDifferentMenuPtrs: ; 14:6843
	dw PrizeMenuMon1Entries
	dw PrizeMenuMon1Cost

	dw PrizeMenuMon2Entries
	dw PrizeMenuMon2Cost

	dw PrizeMenuTMsEntries
	dw PrizeMenuTMsCost

NoThanksText: ; 14:684F
	db "NO THANKS@"

PrizeMenuMon1Entries: ; 14:6859
	db ABRA
	db CLEFAIRY
IF _RED
	db NIDORINA
ENDC
IF _BLUE
	db NIDORINO
ENDC
	db "@"
PrizeMenuMon1Cost: ; 14:685D
IF _RED
	db $01,$80
	db $05,$00
ENDC
IF _BLUE
	db $01,$20
	db $07,$50
ENDC
	db $12,$00
	db "@"

PrizeMenuMon2Entries: ; 14:6864
IF _RED
	db DRATINI
	db SCYTHER
ENDC
IF _BLUE
	db PINSIR
	db DRATINI
ENDC
	db PORYGON
	db "@"
PrizeMenuMon2Cost: ; 14:6868
IF _RED
	db $28,$00
	db $55,$00
	db $99,$99
ENDC
IF _BLUE
	db $25,$00
	db $46,$00
	db $65,$00
ENDC
	db "@"

PrizeMenuTMsEntries: ; 14:686F
	db TM_23
	db TM_15
	db TM_50
	db "@"
PrizeMenuTMsCost: ; 14:6873
	db $33,$00 ; 3300 Coins
	db $55,$00 ; 5500 Coins
	db $77,$00 ; 7700 Coins
	db "@"

PrintPrizePrice: ; 14:687A
	FuncCoord 11,0
	ld hl,Coord
	ld b,$01
	ld c,$07
	call TextBoxBorder
	call $2429      ; XXX save OAM?
	FuncCoord 12,0
	ld hl,Coord
	ld de,.CoinText\@
	call PlaceString
	FuncCoord 13,1
	ld hl,Coord
	ld de,.SixSpacesText\@
	call PlaceString
	FuncCoord 13,1
	ld hl,Coord
	ld de,W_PLAYERCOINS1
	ld c,%10000010
	call $15CD
	ret

.CoinText\@ ; 14:68A5
	db "COIN@"

.SixSpacesText\@ ; 14:68AA
	db "      @"

LoadCoinsToSubtract: ; 14:68B1
	ld a,[$D139] ; backup of selected menu_entry
	add a
	ld d,$00
	ld e,a
	ld hl,$D141 ; first prize's price
	add hl,de ; get selected prize's price
	xor a
	ld [$FF9F],a
	ld a,[hli]
	ld [$FFA0],a
	ld a,[hl]
	ld [$FFA1],a
	ret

HandlePrizeChoice: ; 14:68C6
	ld a,[$CC26] ; selected menu_entry
	ld [$D139],a
	ld d,$00
	ld e,a
	ld hl,W_PRIZE1
	add hl,de
	ld a,[hl]
	ld [$D11E],a
	ld a,[$D12F]
	cp a,$02 ; is prize a TM?
	jr nz,.GetMonName\@
	call GetItemName
	jr .GivePrize\@
.GetMonName\@ ; 14:68E3
	call GetMonName
.GivePrize\@ ; 14:68E6
	ld hl,SoYouWantPrizeTextPtr
	call PrintText
	call $35EC ; yes/no textbox
	ld a,[$CC26] ; yes/no answer (Y=0, N=1)
	and a
	jr nz,.PrintOhFineThen\@
	call LoadCoinsToSubtract
	call $35B1 ; subtract COINs from COIN_CASE
	jr c,.NotEnoughCoins\@
	ld a,[$D12F]
	cp a,$02
	jr nz,.GiveMon\@
	ld a,[$D11E]
	ld b,a
	ld a,$01
	ld c,a
	call $3E2E ; GiveItem
	jr nc,.BagIsFull\@
	jr .SubtractCoins\@
.GiveMon\@ ; 14:6912
	ld a,[$D11E]
	ld [$CF91],a
	push af
	call GetPrizeMonLevel ; 14:6977
	ld c,a
	pop af
	ld b,a
	call GivePokemon
	push af
	ld a,[$CCD3] ; XXX is there room?
	and a
	call z,$3865
	pop af
	ret nc
.SubtractCoins\@ ; 14:692C
	call LoadCoinsToSubtract
	ld hl,$FFA1
	ld de,W_PLAYERCOINS2
	ld c,$02 ; how many bytes
	ld a,$0C
	call Predef ; subtract coins (BCD daa operations)
	jp PrintPrizePrice
.BagIsFull\@ ; 14:693F
	ld hl,PrizeRoomBagIsFullTextPtr
	jp PrintText
.NotEnoughCoins\@ ; 14:6945
	ld hl,SorryNeedMoreCoinsTextPtr
	jp PrintText
.PrintOhFineThen\@ ; 14:694B
	ld hl,OhFineThenTextPtr
	jp PrintText

UnknownData52951: ; 14:6951
; XXX what's this?
	db $00,$01,$00,$01,$00,$01,$00,$00,$01

HereYouGoTextPtr:
	TX_FAR _HereYouGoText ; 22:62E7
	db $0D
	db "@"

SoYouWantPrizeTextPtr: ; 14:6960
	TX_FAR _SoYouWantPrizeText ; 22:62F6
	db "@"

SorryNeedMoreCoinsTextPtr: ; 14:6965
	TX_FAR _SorryNeedMoreCoins ; 22:630B
	db $0D
	db "@"

PrizeRoomBagIsFullTextPtr: ; 14:696B
	TX_FAR _OopsYouDontHaveEnoughRoomText ; 22:6329
	db $0D
	db "@"

OhFineThenTextPtr: ; 14:6971
	TX_FAR _OhFineThenText; 22:634C
	db $0D ; wait keypress (A/B) without blink
	db "@"

GetPrizeMonLevel: ; 14:6977
	ld a,[$CF91]
	ld b,a
	ld hl,PrizeMonLevelDictionary
.loop\@ ; 14:697E
	ld a,[hli]
	cp b
	jr z,.matchFound\@
	inc hl
	jr .loop\@
.matchFound\@ ; 14:6985
	ld a,[hl]
	ld [$D127],a
	ret

PrizeMonLevelDictionary: ; 14:698A
IF _RED
	db ABRA,9
	db CLEFAIRY,8
	db NIDORINA,17

	db DRATINI,18
	db SCYTHER,25
	db PORYGON,26
ENDC
IF _BLUE
	db ABRA,6
	db CLEFAIRY,12
	db NIDORINO,17

	db PINSIR,20
	db DRATINI,24
	db PORYGON,18
ENDC

INCBIN "baserom.gbc",$52996,$529e9 - $52996

UnnamedText_529e9: ; 0x529e9
	TX_FAR _UnnamedText_529e9
	db $50
; 0x529e9 + 5 bytes

INCBIN "baserom.gbc",$529ee,$529f4 - $529ee

UnnamedText_529f4: ; 0x529f4
	TX_FAR _UnnamedText_529f4
	db $50
; 0x529f4 + 5 bytes

UnnamedText_529f9: ; 0x529f9
	TX_FAR _UnnamedText_529f9
	db $50
; 0x529f9 + 5 bytes

UnnamedText_529fe: ; 0x529fe
	TX_FAR _UnnamedText_529fe
	db $50
; 0x529fe + 5 bytes

UnnamedText_52a03: ; 0x52a03
	TX_FAR _UnnamedText_52a03
	db $50
; 0x52a03 + 5 bytes

INCBIN "baserom.gbc",$52a08,$52a10 - $52a08

UnnamedText_52a10: ; 0x52a10
	TX_FAR _UnnamedText_52a10
	db $50
; 0x52a10 + 5 bytes

INCBIN "baserom.gbc",$52a15,$52a1d - $52a15

UnnamedText_52a1d: ; 0x52a1d
	TX_FAR _UnnamedText_52a1d
	db $50
; 0x52a1d + 5 bytes

INCBIN "baserom.gbc",$52a22,$52a2a - $52a22

UnnamedText_52a2a: ; 0x52a2a
	TX_FAR _UnnamedText_52a2a
	db $50
; 0x52a2a + 5 bytes

INCBIN "baserom.gbc",$52a2f,$52a3d - $52a2f

UnnamedText_52a3d: ; 0x52a3d
	TX_FAR _UnnamedText_52a3d
	db $50
; 0x52a3d + 5 bytes

INCBIN "baserom.gbc",$52a42,$15be

SECTION "bank15",DATA,BANK[$15]

Route2_h:
	db 00 ; Tileset
	db ROUTE_2_HEIGHT,ROUTE_2_WIDTH ;Height,Width blocks (1 block = 4x4 tiles)
	dw Route2Blocks ;Map-Pointer
	dw Route2Texts ;Maps text pointer
	dw Route2Script ;Maps script pointer
	db NORTH | SOUTH ;Connection Byte

	;Connection data
	db PEWTER_CITY ;Map
	dw $4714 ;y, x Strip Starting Point
	dw $C6E8 ;Strip X-Offset to current map
	db 16 ;"Bigness" (Unsure) ;Something to do with MapData
	db 20 ;"Map Width" (Unsure) ;Something to do with TileSet
	db 35 ;Player's new Y-Coordinates
	db 10 ;Player's new X-Coordinates
	dw $C8BD ;New UL Block Pos (Window)

	db VIRIDIAN_CITY ;Map
	dw $43EE ;y, x Strip Starting Point
	dw $C958 ;Strip X-Offset to current map
	db 16 ;"Bigness" (Unsure) ;Something to do with MapData
	db 20 ;"Map Width" (Unsure) ;Something to do with TileSet
	db 0 ;Player's new Y-Coordinates
	db 10 ;Player's new X-Coordinates
	dw $C703 ;New UL Block Pos (Window)

	dw Route2Object ;Object Data Pointer

Route2Object: ; 0x54022 (size=72)
	db $f ; border tile

	db $6 ; warps
	db $9, $c, $0, DIGLETTS_CAVE_EXIT
	db $b, $3, $1, VIRIDIAN_FOREST_EXIT
	db $13, $f, $0, ROUTE_2_HOUSE
	db $23, $10, $1, ROUTE_2_GATE
	db $27, $f, $2, ROUTE_2_GATE
	db $2b, $3, $2, VIRIDIAN_FOREST_ENTRANCE

	db $2 ; signs
	db $41, $5, $3 ; Route2Text3
	db $b, $b, $4 ; Route2Text4

	db $2 ; people
	db SPRITE_BALL, $36 + 4, $d + 4, $ff, $ff, $81, MOON_STONE ; item
	db SPRITE_BALL, $2d + 4, $d + 4, $ff, $ff, $82, HP_UP ; item

	; warp-to
	EVENT_DISP $a, $9, $c ; DIGLETTS_CAVE_EXIT
	EVENT_DISP $a, $b, $3 ; VIRIDIAN_FOREST_EXIT
	EVENT_DISP $a, $13, $f ; ROUTE_2_HOUSE
	EVENT_DISP $a, $23, $10 ; ROUTE_2_GATE
	EVENT_DISP $a, $27, $f ; ROUTE_2_GATE
	EVENT_DISP $a, $2b, $3 ; VIRIDIAN_FOREST_ENTRANCE

INCBIN "baserom.gbc",$5406a,$14

Route2Blocks: ; 0x5407e 360
	INCBIN "maps/route2.blk"

Route3_h: ; 0x541e6 to 0x54208 (34 bytes) (id=14)
	db $00 ; tileset
	db ROUTE_3_HEIGHT, ROUTE_3_WIDTH ; dimensions (y, x)
	dw Route3Blocks, Route3Texts, Route3Script ; blocks, texts, scripts
	db NORTH | WEST ; connections

	; connections data

	db ROUTE_4
	dw Route4Blocks + (ROUTE_4_HEIGHT - 3) * ROUTE_4_WIDTH ; connection strip location
	dw $C6EB + 25 ; current map position
	db $d, ROUTE_4_WIDTH ; bigness, width
	db (ROUTE_4_HEIGHT * 2) - 1, (25 * -2) ; alignments (y, x)
	dw $C6E9 + ROUTE_4_HEIGHT * (ROUTE_4_WIDTH + 6) ; window

	db PEWTER_CITY
	dw PewterCityBlocks - 3 + (PEWTER_CITY_WIDTH * 2) ; connection strip location
	dw $C6E8 + (ROUTE_3_WIDTH + 6) * (-3 + 3) ; current map position
	db $f, PEWTER_CITY_WIDTH ; bigness, width
	db (-4 * -2), (PEWTER_CITY_WIDTH * 2) - 1 ; alignments (y, x)
	dw $C6EE + 2 * PEWTER_CITY_WIDTH ; window

	; end connections data

	dw Route3Object ; objects

Route3Object: ; 0x54208 (size=77)
	db $2c ; border tile

	db $0 ; warps

	db $1 ; signs
	db $9, $3b, $a ; Route3Text10

	db $9 ; people
	db SPRITE_BLACK_HAIR_BOY_2, $b + 4, $39 + 4, $ff, $ff, $1 ; person
	db SPRITE_BUG_CATCHER, $6 + 4, $a + 4, $ff, $d3, $42, BUG_CATCHER + $C8, $4 ; trainer
	db SPRITE_BUG_CATCHER, $4 + 4, $e + 4, $ff, $d0, $43, YOUNGSTER + $C8, $1 ; trainer
	db SPRITE_LASS, $9 + 4, $10 + 4, $ff, $d2, $44, LASS + $C8, $1 ; trainer
	db SPRITE_BUG_CATCHER, $5 + 4, $13 + 4, $ff, $d0, $45, BUG_CATCHER + $C8, $5 ; trainer
	db SPRITE_LASS, $4 + 4, $17 + 4, $ff, $d2, $46, LASS + $C8, $2 ; trainer
	db SPRITE_BUG_CATCHER, $9 + 4, $16 + 4, $ff, $d2, $47, YOUNGSTER + $C8, $2 ; trainer
	db SPRITE_BUG_CATCHER, $6 + 4, $18 + 4, $ff, $d3, $48, BUG_CATCHER + $C8, $6 ; trainer
	db SPRITE_LASS, $a + 4, $21 + 4, $ff, $d1, $49, LASS + $C8, $3 ; trainer

Route3Blocks: ; 0x54255 315
	INCBIN "maps/route3.blk"

Route4_h: ; 0x54390 to 0x543b2 (34 bytes) (id=15)
	db $00 ; tileset
	db ROUTE_4_HEIGHT, ROUTE_4_WIDTH ; dimensions (y, x)
	dw Route4Blocks, Route4Texts, Route4Script; blocks, texts, scripts
	db SOUTH | EAST ; connections

	; connections data

	db ROUTE_3
	dw Route3Blocks + 22 ; connection strip location
	dw $C6EB + (ROUTE_4_HEIGHT + 3) * (ROUTE_4_WIDTH + 6) + -3 ; current map position
	db $d, ROUTE_3_WIDTH ; bigness, width
	db 0, (-25 * -2) ; alignments (y, x)
	dw $C6EF + ROUTE_3_WIDTH ; window

	db CERULEAN_CITY
	dw CeruleanCityBlocks + (CERULEAN_CITY_WIDTH) ; connection strip location
	dw $C6E5 + (ROUTE_4_WIDTH + 6) * (-3 + 4) ; current map position
	db $f, CERULEAN_CITY_WIDTH ; bigness, width
	db (-4 * -2), 0 ; alignments (y, x)
	dw $C6EF + CERULEAN_CITY_WIDTH ; window

	; end connections data

	dw Route4Object ; objects

Route4Object: ; 0x543b2 (size=58)
	db $2c ; border tile

	db $3 ; warps
	db $5, $b, $0, MT_MOON_POKECENTER
	db $5, $12, $0, MT_MOON_1
	db $5, $18, $7, MT_MOON_2

	db $3 ; signs
	db $5, $c, $4 ; Route4Text4
	db $7, $11, $5 ; Route4Text5
	db $7, $1b, $6 ; Route4Text6

	db $3 ; people
	db SPRITE_LASS, $8 + 4, $9 + 4, $fe, $0, $1 ; person
	db SPRITE_LASS, $3 + 4, $3f + 4, $ff, $d3, $42, LASS + $C8, $4 ; trainer
	db SPRITE_BALL, $3 + 4, $39 + 4, $ff, $ff, $83, TM_04 ; item

	; warp-to
	EVENT_DISP $2d, $5, $b ; MT_MOON_POKECENTER
	EVENT_DISP $2d, $5, $12 ; MT_MOON_1
	EVENT_DISP $2d, $5, $18 ; MT_MOON_2

Route4Blocks: ; 0x543ec 405
	INCBIN "maps/route4.blk"

Route5_h: ; 0x54581 to 0x545a3 (34 bytes) (id=16)
	db $00 ; tileset
	db ROUTE_5_HEIGHT, ROUTE_5_WIDTH ; dimensions (y, x)
	dw Route5Blocks, Route5Texts, Route5Script ; blocks, texts, scripts
	db NORTH | SOUTH ; connections

	; connections data

	db CERULEAN_CITY
	dw CeruleanCityBlocks + (CERULEAN_CITY_HEIGHT - 3) * CERULEAN_CITY_WIDTH + 2 ; connection strip location
	dw $C6EB + -3 ; current map position
	db $10, CERULEAN_CITY_WIDTH ; bigness, width
	db (CERULEAN_CITY_HEIGHT * 2) - 1, (-5 * -2) ; alignments (y, x)
	dw $C6E9 + CERULEAN_CITY_HEIGHT * (CERULEAN_CITY_WIDTH + 6) ; window

	db SAFFRON_CITY
	dw SaffronCityBlocks + 2 ; connection strip location
	dw $C6EB + (ROUTE_5_HEIGHT + 3) * (ROUTE_5_WIDTH + 6) + -3 ; current map position
	db $10, SAFFRON_CITY_WIDTH ; bigness, width
	db 0, (-5 * -2) ; alignments (y, x)
	dw $C6EF + SAFFRON_CITY_WIDTH ; window

	; end connections data

	dw Route5Object ; objects

Route5Object: ; 0x545a3 (size=47)
	db $a ; border tile

	db $5 ; warps
	db $1d, $a, $3, ROUTE_5_GATE
	db $1d, $9, $2, ROUTE_5_GATE
	db $21, $a, $0, ROUTE_5_GATE
	db $1b, $11, $0, PATH_ENTRANCE_ROUTE_5
	db $15, $a, $0, DAYCAREM

	db $1 ; signs
	db $1d, $11, $1 ; Route5Text1

	db $0 ; people

	; warp-to
	EVENT_DISP $a, $1d, $a ; ROUTE_5_GATE
	EVENT_DISP $a, $1d, $9 ; ROUTE_5_GATE
	EVENT_DISP $a, $21, $a ; ROUTE_5_GATE
	EVENT_DISP $a, $1b, $11 ; PATH_ENTRANCE_ROUTE_5
	EVENT_DISP $a, $15, $a ; DAYCAREM

Route5Blocks: ; 0x545d2 180
	INCBIN "maps/route5.blk"

Route9_h: ; 0x54686 to 0x546a8 (34 bytes) (id=20)
	db $00 ; tileset
	db ROUTE_9_HEIGHT, ROUTE_9_WIDTH ; dimensions (y, x)
	dw Route9Blocks, Route9Texts, Route9Script ; blocks, texts, scripts
	db WEST | EAST ; connections

	; connections data

	db CERULEAN_CITY
	dw CeruleanCityBlocks - 3 + (CERULEAN_CITY_WIDTH * 2) ; connection strip location
	dw $C6E8 + (ROUTE_9_WIDTH + 6) * (-3 + 3) ; current map position
	db $f, CERULEAN_CITY_WIDTH ; bigness, width
	db (-4 * -2), (CERULEAN_CITY_WIDTH * 2) - 1 ; alignments (y, x)
	dw $C6EE + 2 * CERULEAN_CITY_WIDTH ; window

	db ROUTE_10
	dw Route10Blocks + (ROUTE_10_WIDTH * 0) ; connection strip location
	dw $C6E5 + (ROUTE_9_WIDTH + 6) * (0 + 4) ; current map position
	db $c, ROUTE_10_WIDTH ; bigness, width
	db (0 * -2), 0 ; alignments (y, x)
	dw $C6EF + ROUTE_10_WIDTH ; window

	; end connections data

	dw Route9Object ; objects

Route9Object: ; 0x546a8 (size=86)
	db $2c ; border tile

	db $0 ; warps

	db $1 ; signs
	db $7, $19, $b ; Route9Text11

	db $a ; people
	db SPRITE_LASS, $a + 4, $d + 4, $ff, $d2, $41, JR__TRAINER_F + $C8, $5 ; trainer
	db SPRITE_BLACK_HAIR_BOY_1, $7 + 4, $18 + 4, $ff, $d2, $42, JR__TRAINER_M + $C8, $7 ; trainer
	db SPRITE_BLACK_HAIR_BOY_1, $7 + 4, $1f + 4, $ff, $d3, $43, JR__TRAINER_M + $C8, $8 ; trainer
	db SPRITE_LASS, $8 + 4, $30 + 4, $ff, $d3, $44, JR__TRAINER_F + $C8, $6 ; trainer
	db SPRITE_HIKER, $f + 4, $10 + 4, $ff, $d2, $45, HIKER + $C8, $b ; trainer
	db SPRITE_HIKER, $3 + 4, $2b + 4, $ff, $d2, $46, HIKER + $C8, $6 ; trainer
	db SPRITE_BUG_CATCHER, $2 + 4, $16 + 4, $ff, $d0, $47, BUG_CATCHER + $C8, $d ; trainer
	db SPRITE_HIKER, $f + 4, $2d + 4, $ff, $d3, $48, HIKER + $C8, $5 ; trainer
	db SPRITE_BUG_CATCHER, $8 + 4, $28 + 4, $ff, $d3, $49, BUG_CATCHER + $C8, $e ; trainer
	db SPRITE_BALL, $f + 4, $a + 4, $ff, $ff, $8a, TM_30 ; item

Route9Blocks: ; 0x546fe 270
	INCBIN "maps/route9.blk"

Route13_h: ; 0x5480c to 0x5482e (34 bytes) (id=24)
	db $00 ; tileset
	db ROUTE_13_HEIGHT, ROUTE_13_WIDTH ; dimensions (y, x)
	dw Route13Blocks, Route13Texts, Route13Script ; blocks, texts, scripts
	db NORTH | WEST ; connections

	; connections data

	db ROUTE_12
	dw Route12Blocks + (ROUTE_12_HEIGHT - 3) * ROUTE_12_WIDTH ; connection strip location
	dw $C6EB + 20 ; current map position
	db ROUTE_12_WIDTH, ROUTE_12_WIDTH ; bigness, width
	db (ROUTE_12_HEIGHT * 2) - 1, (20 * -2) ; alignments (y, x)
	dw $C6E9 + ROUTE_12_HEIGHT * (ROUTE_12_WIDTH + 6) ; window

	db ROUTE_14
	dw Route14Blocks - 3 + (ROUTE_14_WIDTH) ; connection strip location
	dw $C6E8 + (ROUTE_13_WIDTH + 6) * (0 + 3) ; current map position
	db $c, ROUTE_14_WIDTH ; bigness, width
	db (0 * -2), (ROUTE_14_WIDTH * 2) - 1 ; alignments (y, x)
	dw $C6EE + 2 * ROUTE_14_WIDTH ; window

	; end connections data

	dw Route13Object ; objects

Route13Object: ; 0x5482e (size=93)
	db $43 ; border tile

	db $0 ; warps

	db $3 ; signs
	db $d, $f, $b ; Route13Text11
	db $5, $21, $c ; Route13Text12
	db $b, $1f, $d ; Route13Text13

	db $a ; people
	db SPRITE_BLACK_HAIR_BOY_1, $a + 4, $31 + 4, $ff, $d3, $41, BIRD_KEEPER + $C8, $1 ; trainer
	db SPRITE_LASS, $a + 4, $30 + 4, $ff, $d0, $42, JR__TRAINER_F + $C8, $c ; trainer
	db SPRITE_LASS, $9 + 4, $1b + 4, $ff, $d0, $43, JR__TRAINER_F + $C8, $d ; trainer
	db SPRITE_LASS, $a + 4, $17 + 4, $ff, $d2, $44, JR__TRAINER_F + $C8, $e ; trainer
	db SPRITE_LASS, $5 + 4, $32 + 4, $ff, $d0, $45, JR__TRAINER_F + $C8, $f ; trainer
	db SPRITE_BLACK_HAIR_BOY_1, $4 + 4, $c + 4, $ff, $d3, $46, BIRD_KEEPER + $C8, $2 ; trainer
	db SPRITE_FOULARD_WOMAN, $6 + 4, $21 + 4, $ff, $d0, $47, BEAUTY + $C8, $4 ; trainer
	db SPRITE_FOULARD_WOMAN, $6 + 4, $20 + 4, $ff, $d0, $48, BEAUTY + $C8, $5 ; trainer
	db SPRITE_BIKER, $7 + 4, $a + 4, $ff, $d1, $49, BIKER + $C8, $1 ; trainer
	db SPRITE_BLACK_HAIR_BOY_1, $d + 4, $7 + 4, $ff, $d1, $4a, BIRD_KEEPER + $C8, $3 ; trainer

Route13Blocks: ; 0x5488b 270
	INCBIN "maps/route13.blk"

Route14_h: ; 0x54999 to 0x549bb (34 bytes) (id=25)
	db $00 ; tileset
	db ROUTE_14_HEIGHT, ROUTE_14_WIDTH ; dimensions (y, x)
	dw Route14Blocks, Route14Texts, Route14Script ; blocks, texts, scripts
	db WEST | EAST ; connections

	; connections data

	db ROUTE_15
	dw Route15Blocks - 3 + (ROUTE_15_WIDTH) ; connection strip location
	dw $C6E8 + (ROUTE_14_WIDTH + 6) * (18 + 3) ; current map position
	db ROUTE_15_HEIGHT, ROUTE_15_WIDTH ; bigness, width
	db (18 * -2), (ROUTE_15_WIDTH * 2) - 1 ; alignments (y, x)
	dw $C6EE + 2 * ROUTE_15_WIDTH ; window

	db ROUTE_13
	dw Route13Blocks + (ROUTE_13_WIDTH * 0) ; connection strip location
	dw $C6E5 + (ROUTE_14_WIDTH + 6) * (0 + 4) ; current map position
	db ROUTE_13_HEIGHT, ROUTE_13_WIDTH ; bigness, width
	db (0 * -2), 0 ; alignments (y, x)
	dw $C6EF + ROUTE_13_WIDTH ; window

	; end connections data

	dw Route14Object ; objects

Route14Object: ; 0x549bb (size=87)
	db $43 ; border tile

	db $0 ; warps

	db $1 ; signs
	db $d, $11, $b ; Route14Text11

	db $a ; people
	db SPRITE_BLACK_HAIR_BOY_1, $4 + 4, $4 + 4, $ff, $d0, $41, BIRD_KEEPER + $C8, $e ; trainer
	db SPRITE_BLACK_HAIR_BOY_1, $6 + 4, $f + 4, $ff, $d0, $42, BIRD_KEEPER + $C8, $f ; trainer
	db SPRITE_BLACK_HAIR_BOY_1, $b + 4, $c + 4, $ff, $d0, $43, BIRD_KEEPER + $C8, $10 ; trainer
	db SPRITE_BLACK_HAIR_BOY_1, $f + 4, $e + 4, $ff, $d1, $44, BIRD_KEEPER + $C8, $11 ; trainer
	db SPRITE_BLACK_HAIR_BOY_1, $1f + 4, $f + 4, $ff, $d2, $45, BIRD_KEEPER + $C8, $4 ; trainer
	db SPRITE_BLACK_HAIR_BOY_1, $31 + 4, $6 + 4, $ff, $d1, $46, BIRD_KEEPER + $C8, $5 ; trainer
	db SPRITE_BIKER, $27 + 4, $5 + 4, $ff, $d0, $47, BIKER + $C8, $d ; trainer
	db SPRITE_BIKER, $1e + 4, $4 + 4, $ff, $d3, $48, BIKER + $C8, $e ; trainer
	db SPRITE_BIKER, $1e + 4, $f + 4, $ff, $d2, $49, BIKER + $C8, $f ; trainer
	db SPRITE_BIKER, $1f + 4, $4 + 4, $ff, $d3, $4a, BIKER + $C8, $2 ; trainer

Route14Blocks: ; 0x54a12 270
	INCBIN "maps/route14.blk"

Route17_h: ; 0x54b20 to 0x54b42 (34 bytes) (id=28)
	db $00 ; tileset
	db ROUTE_17_HEIGHT, ROUTE_17_WIDTH ; dimensions (y, x)
	dw Route17Blocks, Route17Texts, Route17Script ; blocks, texts, scripts
	db NORTH | SOUTH ; connections

	; connections data

	db ROUTE_16
	dw Route16Blocks + (ROUTE_16_HEIGHT - 3) * ROUTE_16_WIDTH ; connection strip location
	dw $C6EB + 0 ; current map position
	db $d, ROUTE_16_WIDTH ; bigness, width
	db (ROUTE_16_HEIGHT * 2) - 1, (0 * -2) ; alignments (y, x)
	dw $C6E9 + ROUTE_16_HEIGHT * (ROUTE_16_WIDTH + 6) ; window

	db ROUTE_18
	dw Route18Blocks ; connection strip location
	dw $C6EB + (ROUTE_17_HEIGHT + 3) * (ROUTE_17_WIDTH + 6) + 0 ; current map position
	db $d, ROUTE_18_WIDTH ; bigness, width
	db 0, (0 * -2) ; alignments (y, x)
	dw $C6EF + ROUTE_18_WIDTH ; window

	; end connections data

	dw Route17Object ; objects

Route17Object: ; 0x54b42 (size=102)
	db $43 ; border tile

	db $0 ; warps

	db $6 ; signs
	db $33, $9, $b ; Route17Text11
	db $3f, $9, $c ; Route17Text12
	db $4b, $9, $d ; Route17Text13
	db $57, $9, $e ; Route17Text14
	db $6f, $9, $f ; Route17Text15
	db $8d, $9, $10 ; Route17Text16

	db $a ; people
	db SPRITE_BIKER, $13 + 4, $c + 4, $ff, $d2, $41, CUE_BALL + $C8, $4 ; trainer
	db SPRITE_BIKER, $10 + 4, $b + 4, $ff, $d3, $42, CUE_BALL + $C8, $5 ; trainer
	db SPRITE_BIKER, $12 + 4, $4 + 4, $ff, $d1, $43, BIKER + $C8, $8 ; trainer
	db SPRITE_BIKER, $20 + 4, $7 + 4, $ff, $d2, $44, BIKER + $C8, $9 ; trainer
	db SPRITE_BIKER, $22 + 4, $e + 4, $ff, $d3, $45, BIKER + $C8, $a ; trainer
	db SPRITE_BIKER, $3a + 4, $11 + 4, $ff, $d2, $46, CUE_BALL + $C8, $6 ; trainer
	db SPRITE_BIKER, $44 + 4, $2 + 4, $ff, $d3, $47, CUE_BALL + $C8, $7 ; trainer
	db SPRITE_BIKER, $62 + 4, $e + 4, $ff, $d3, $48, CUE_BALL + $C8, $8 ; trainer
	db SPRITE_BIKER, $62 + 4, $5 + 4, $ff, $d2, $49, BIKER + $C8, $b ; trainer
	db SPRITE_BIKER, $76 + 4, $a + 4, $ff, $d0, $4a, BIKER + $C8, $c ; trainer

Route17Blocks: ; 0x54ba8 720
	INCBIN "maps/route17.blk"

Route19_h: ; 0x54e78 to 0x54e9a (34 bytes) (id=30)
	db $00 ; tileset
	db ROUTE_19_HEIGHT, ROUTE_19_WIDTH ; dimensions (y, x)
	dw Route19Blocks, Route19Texts, Route19Script ; blocks, texts, scripts
	db NORTH | WEST ; connections

	; connections data

	db FUCHSIA_CITY
	dw FuchsiaCityBlocks + (FUCHSIA_CITY_HEIGHT - 3) * FUCHSIA_CITY_WIDTH + 2 ; connection strip location
	dw $C6EB + -3 ; current map position
	db $10, FUCHSIA_CITY_WIDTH ; bigness, width
	db (FUCHSIA_CITY_HEIGHT * 2) - 1, (-5 * -2) ; alignments (y, x)
	dw $C6E9 + FUCHSIA_CITY_HEIGHT * (FUCHSIA_CITY_WIDTH + 6) ; window

	db ROUTE_20
	dw Route20Blocks - 3 + (ROUTE_20_WIDTH) ; connection strip location
	dw $C6E8 + (ROUTE_19_WIDTH + 6) * (18 + 3) ; current map position
	db ROUTE_20_HEIGHT, ROUTE_20_WIDTH ; bigness, width
	db (18 * -2), (ROUTE_20_WIDTH * 2) - 1 ; alignments (y, x)
	dw $C6EE + 2 * ROUTE_20_WIDTH ; window

	; end connections data

	dw Route19Object ; objects

Route19Object: ; 0x54e9a (size=87)
	db $43 ; border tile

	db $0 ; warps

	db $1 ; signs
	db $9, $b, $b ; Route19Text11

	db $a ; people
	db SPRITE_BLACK_HAIR_BOY_1, $7 + 4, $8 + 4, $ff, $d2, $41, SWIMMER + $C8, $2 ; trainer
	db SPRITE_BLACK_HAIR_BOY_1, $7 + 4, $d + 4, $ff, $d2, $42, SWIMMER + $C8, $3 ; trainer
	db SPRITE_SWIMMER, $19 + 4, $d + 4, $ff, $d2, $43, SWIMMER + $C8, $4 ; trainer
	db SPRITE_SWIMMER, $1b + 4, $4 + 4, $ff, $d3, $44, SWIMMER + $C8, $5 ; trainer
	db SPRITE_SWIMMER, $1f + 4, $10 + 4, $ff, $d1, $45, SWIMMER + $C8, $6 ; trainer
	db SPRITE_SWIMMER, $b + 4, $9 + 4, $ff, $d0, $46, SWIMMER + $C8, $7 ; trainer
	db SPRITE_SWIMMER, $2b + 4, $8 + 4, $ff, $d2, $47, BEAUTY + $C8, $c ; trainer
	db SPRITE_SWIMMER, $2b + 4, $b + 4, $ff, $d3, $48, BEAUTY + $C8, $d ; trainer
	db SPRITE_SWIMMER, $2a + 4, $9 + 4, $ff, $d1, $49, SWIMMER + $C8, $8 ; trainer
	db SPRITE_SWIMMER, $2c + 4, $a + 4, $ff, $d0, $4a, BEAUTY + $C8, $e ; trainer

Route19Blocks: ; 0x54ef1 270
	INCBIN "maps/route19.blk"

Route21_h: ; 0x54fff to 0x55021 (34 bytes) (id=32)
	db $00 ; tileset
	db ROUTE_21_HEIGHT, ROUTE_21_WIDTH ; dimensions (y, x)
	dw Route21Blocks, Route21Texts, Route21Script ; blocks, texts, scripts
	db NORTH | SOUTH ; connections

	; connections data

	db PALLET_TOWN
	dw PalletTownBlocks + (PALLET_TOWN_HEIGHT - 3) * PALLET_TOWN_WIDTH ; connection strip location
	dw $C6EB + 0 ; current map position
	db PALLET_TOWN_WIDTH, PALLET_TOWN_WIDTH ; bigness, width
	db (PALLET_TOWN_HEIGHT * 2) - 1, (0 * -2) ; alignments (y, x)
	dw $C6E9 + PALLET_TOWN_HEIGHT * (PALLET_TOWN_WIDTH + 6) ; window

	db CINNABAR_ISLAND
	dw CinnabarIslandBlocks ; connection strip location
	dw $C6EB + (ROUTE_21_HEIGHT + 3) * (ROUTE_21_WIDTH + 6) + 0 ; current map position
	db CINNABAR_ISLAND_WIDTH, CINNABAR_ISLAND_WIDTH ; bigness, width
	db 0, (0 * -2) ; alignments (y, x)
	dw $C6EF + CINNABAR_ISLAND_WIDTH ; window

	; end connections data

	dw Route21Object ; objects

Route21Object: ; 0x55021 (size=76)
	db $43 ; border tile

	db $0 ; warps

	db $0 ; signs

	db $9 ; people
	db SPRITE_FISHER2, $18 + 4, $4 + 4, $ff, $d2, $41, FISHER + $C8, $7 ; trainer
	db SPRITE_FISHER2, $19 + 4, $6 + 4, $ff, $d0, $42, FISHER + $C8, $9 ; trainer
	db SPRITE_SWIMMER, $1f + 4, $a + 4, $ff, $d1, $43, SWIMMER + $C8, $c ; trainer
	db SPRITE_SWIMMER, $1e + 4, $c + 4, $ff, $d3, $44, CUE_BALL + $C8, $9 ; trainer
	db SPRITE_SWIMMER, $3f + 4, $10 + 4, $ff, $d0, $45, SWIMMER + $C8, $d ; trainer
	db SPRITE_SWIMMER, $47 + 4, $5 + 4, $ff, $d3, $46, SWIMMER + $C8, $e ; trainer
	db SPRITE_SWIMMER, $47 + 4, $f + 4, $ff, $d2, $47, SWIMMER + $C8, $f ; trainer
	db SPRITE_FISHER2, $38 + 4, $e + 4, $ff, $d2, $48, FISHER + $C8, $8 ; trainer
	db SPRITE_FISHER2, $39 + 4, $11 + 4, $ff, $d3, $49, FISHER + $C8, $a ; trainer

Route21Blocks: ; 0x5506d 450
	INCBIN "maps/route21.blk"

VermilionHouse2Blocks:
Route12HouseBlocks:
DayCareMBlocks: ; 0x5522f 522F 16
	INCBIN "maps/daycarem.blk"

FuchsiaHouse3Blocks: ; 0x5523f 16
	INCBIN "maps/fuchsiahouse3.blk"

INCBIN "baserom.gbc",$5524f,$554d8 - $5524f

UnnamedText_554d8: ; 0x554d8
	TX_FAR _UnnamedText_554d8 ; 0x89bee
	db $50
; 0x554dd

INCBIN "baserom.gbc",$554dd,$554e3 - $554dd

Route2Script: ; 0x554e3
	jp $3c3c
; 0x554e6

Route2Texts:
	dw Route2Text1, Route2Text2, Route2Text3, Route2Text4

Route2Text3: ; 0x554ee
	TX_FAR _Route2Text3
	db $50

Route2Text4: ; 0x554f3
	TX_FAR _Route2Text4
	db $50

Route3Script: ; 0x554f8
	call $3c3c
	ld hl, Route3TrainerHeader0
	ld de, Unknown_5550b
	ld a, [$d5f8]
	call $3160
	ld [$d5f8], a
	ret
; 0x5550b

Unknown_5550b: ; 0x5550b
INCBIN "baserom.gbc",$5550b,$6

Route3Texts: ; 0x55511
	dw Route3Text1, Route3Text2, Route3Text3, Route3Text4, Route3Text5, Route3Text6, Route3Text7, Route3Text8, Route3Text9, Route3Text10

Route3TrainerHeaders:
Route3TrainerHeader0: ; 0x55525
	db $2 ; flag's bit
	db ($2 << 4) ; trainer's view range
	dw $d7c3 ; flag's byte
	dw Route3BattleText1 ; 0x5595 TextBeforeBattle
	dw Route3AfterBattleText1 ; 0x559f TextAfterBattle
	dw Route3EndBattleText1 ; 0x559a TextEndBattle
	dw Route3EndBattleText1 ; 0x559a TextEndBattle
; 0x55531

Route3TrainerHeader2: ; 0x55531
	db $3 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d7c3 ; flag's byte
	dw Route3BattleText2 ; 0x55ae TextBeforeBattle
	dw Route3AfterBattleText2 ; 0x55b8 TextAfterBattle
	dw Route3EndBattleText2 ; 0x55b3 TextEndBattle
	dw Route3EndBattleText2 ; 0x55b3 TextEndBattle
; 0x5553d

Route3TrainerHeader3: ; 0x5553d
	db $4 ; flag's bit
	db ($2 << 4) ; trainer's view range
	dw $d7c3 ; flag's byte
	dw Route3BattleText3 ; 0x55c7 TextBeforeBattle
	dw Route3AfterBattleText3 ; 0x55d1 TextAfterBattle
	dw Route3EndBattleText3 ; 0x55cc TextEndBattle
	dw Route3EndBattleText3 ; 0x55cc TextEndBattle
; 0x55549

Route3TrainerHeader4: ; 0x55549
	db $5 ; flag's bit
	db ($1 << 4) ; trainer's view range
	dw $d7c3 ; flag's byte
	dw Route3BattleText4 ; 0x55e0 TextBeforeBattle
	dw Route3AfterBattleText4 ; 0x55ea TextAfterBattle
	dw Route3EndBattleText4 ; 0x55e5 TextEndBattle
	dw Route3EndBattleText4 ; 0x55e5 TextEndBattle
; 0x55555

Route3TrainerHeader5: ; 0x55555
	db $6 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d7c3 ; flag's byte
	dw Route3BattleText5 ; 0x55f9 TextBeforeBattle
	dw Route3AfterBattleText5 ; 0x5603 TextAfterBattle
	dw Route3EndBattleText5 ; 0x55fe TextEndBattle
	dw Route3EndBattleText5 ; 0x55fe TextEndBattle
; 0x55561

Route3TrainerHeader6: ; 0x55561
	db $7 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d7c3 ; flag's byte
	dw Route3BattleText6 ; 0x5612 TextBeforeBattle
	dw Route3AfterBattleText6 ; 0x561c TextAfterBattle
	dw Route3EndBattleText6 ; 0x5617 TextEndBattle
	dw Route3EndBattleText6 ; 0x5617 TextEndBattle
; 0x5556d

Route3TrainerHeader7: ; 0x5556d
	db $8 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d7c3 ; flag's byte
	dw Route3BattleText7 ; 0x562b TextBeforeBattle
	dw Route3AfterBattleText7 ; 0x5635 TextAfterBattle
	dw Route3EndBattleText7 ; 0x5630 TextEndBattle
	dw Route3EndBattleText7 ; 0x5630 TextEndBattle
; 0x55579

Route3TrainerHeader8: ; 0x55579
	db $9 ; flag's bit
	db ($2 << 4) ; trainer's view range
	dw $d7c3 ; flag's byte
	dw Route3BattleText8 ; 0x5644 TextBeforeBattle
	dw Route3AfterBattleText8 ; 0x564e TextAfterBattle
	dw Route3EndBattleText8 ; 0x5649 TextEndBattle
	dw Route3EndBattleText8 ; 0x5649 TextEndBattle
; 0x55585

db $ff

Route3Text1: ; 0x55586
	TX_FAR _Route3Text1
	db $50

Route3Text2: ; 0x5558b
	db $08 ; asm
	ld hl, Route3TrainerHeader0
	call LoadTrainerHeader
	jp TextScriptEnd

Route3BattleText1: ; 0x55595
	TX_FAR _Route3BattleText1
	db $50
; 0x55595 + 5 bytes

Route3EndBattleText1: ; 0x5559a
	TX_FAR _Route3EndBattleText1
	db $50
; 0x5559a + 5 bytes

Route3AfterBattleText1: ; 0x5559f
	TX_FAR _Route3AfterBattleText1
	db $50
; 0x5559f + 5 bytes

Route3Text3: ; 0x555a4
	db $08 ; asm
	ld hl, Route3TrainerHeader2
	call LoadTrainerHeader
	jp TextScriptEnd

Route3BattleText2: ; 0x555ae
	TX_FAR _Route3BattleText2
	db $50
; 0x555ae + 5 bytes

Route3EndBattleText2: ; 0x555b3
	TX_FAR _Route3EndBattleText2
	db $50
; 0x555b3 + 5 bytes

Route3AfterBattleText2: ; 0x555b8
	TX_FAR _Route3AfterBattleText2
	db $50
; 0x555b8 + 5 bytes

Route3Text4: ; 0x555bd
	db $08 ; asm
	ld hl, Route3TrainerHeader3
	call LoadTrainerHeader
	jp TextScriptEnd

Route3BattleText3: ; 0x555c7
	TX_FAR _Route3BattleText3
	db $50
; 0x555c7 + 5 bytes

Route3EndBattleText3: ; 0x555cc
	TX_FAR _Route3EndBattleText3
	db $50
; 0x555cc + 5 bytes

Route3AfterBattleText3: ; 0x555d1
	TX_FAR _Route3AfterBattleText3
	db $50
; 0x555d1 + 5 bytes

Route3Text5: ; 0x555d6
	db $08 ; asm
	ld hl, Route3TrainerHeader4
	call LoadTrainerHeader
	jp TextScriptEnd

Route3BattleText4: ; 0x555e0
	TX_FAR _Route3BattleText4
	db $50
; 0x555e0 + 5 bytes

Route3EndBattleText4: ; 0x555e5
	TX_FAR _Route3EndBattleText4
	db $50
; 0x555e5 + 5 bytes

Route3AfterBattleText4: ; 0x555ea
	TX_FAR _Route3AfterBattleText4
	db $50
; 0x555ea + 5 bytes

Route3Text6: ; 0x555ef
	db $08 ; asm
	ld hl, Route3TrainerHeader5
	call LoadTrainerHeader
	jp TextScriptEnd

Route3BattleText5: ; 0x555f9
	TX_FAR _Route3BattleText5
	db $50
; 0x555f9 + 5 bytes

Route3EndBattleText5: ; 0x555fe
	TX_FAR _Route3EndBattleText5
	db $50
; 0x555fe + 5 bytes

Route3AfterBattleText5: ; 0x55603
	TX_FAR _Route3AfterBattleText5
	db $50
; 0x55603 + 5 bytes

Route3Text7: ; 0x55608
	db $08 ; asm
	ld hl, Route3TrainerHeader6
	call LoadTrainerHeader
	jp TextScriptEnd

Route3BattleText6: ; 0x55612
	TX_FAR _Route3BattleText6
	db $50
; 0x55612 + 5 bytes

Route3EndBattleText6: ; 0x55617
	TX_FAR _Route3EndBattleText6
	db $50
; 0x55617 + 5 bytes

Route3AfterBattleText6: ; 0x5561c
	TX_FAR _Route3AfterBattleText6
	db $50
; 0x5561c + 5 bytes

Route3Text8: ; 0x55621
	db $08 ; asm
	ld hl, Route3TrainerHeader7
	call LoadTrainerHeader
	jp TextScriptEnd

Route3BattleText7: ; 0x5562b
	TX_FAR _Route3BattleText7
	db $50
; 0x5562b + 5 bytes

Route3EndBattleText7: ; 0x55630
	TX_FAR _Route3EndBattleText7
	db $50
; 0x55630 + 5 bytes

Route3AfterBattleText7: ; 0x55635
	TX_FAR _Route3AfterBattleText7
	db $50
; 0x55635 + 5 bytes

Route3Text9: ; 0x5563a
	db $08 ; asm
	ld hl, Route3TrainerHeader8
	call LoadTrainerHeader
	jp TextScriptEnd

Route3BattleText8: ; 0x55644
	TX_FAR _Route3BattleText8
	db $50
; 0x55644 + 5 bytes

Route3EndBattleText8: ; 0x55649
	TX_FAR _Route3EndBattleText8
	db $50
; 0x55649 + 5 bytes

Route3AfterBattleText8: ; 0x5564e
	TX_FAR _Route3AfterBattleText8
	db $50
; 0x5564e + 5 bytes

Route3Text10: ; 0x55653
	TX_FAR _Route3Text10
	db $50

Route4Script: ; 0x55658
	call $3c3c
	ld hl, Route4TrainerHeaders
	ld de, Unknown_5566b
	ld a, [$d5f9]
	call $3160
	ld [$d5f9], a
	ret
; 0x5566b

Unknown_5566b: ; 0x5566b
INCBIN "baserom.gbc",$5566b,$6

Route4Texts: ; 0x55671
	dw Route4Text1, Route4Text2, Route4Text3, Route4Text4, Route4Text5, Route4Text6

Route4TrainerHeaders:
Route4TrainerHeader0: ; 0x5567d
	db $2 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d7c5 ; flag's byte
	dw Route4BattleText1 ; 0x5699 TextBeforeBattle
	dw Route4AfterBattleText1 ; 0x56a3 TextAfterBattle
	dw Route4EndBattleText1 ; 0x569e TextEndBattle
	dw Route4EndBattleText1 ; 0x569e TextEndBattle
; 0x55689

db $ff

Route4Text1: ; 0x5568a
	TX_FAR _Route4Text1
	db $50

Route4Text2: ; 0x5568f
	db $08 ; asm
	ld hl, Route4TrainerHeader0
	call LoadTrainerHeader
	jp TextScriptEnd

Route4BattleText1: ; 0x55699
	TX_FAR _Route4BattleText1
	db $50
; 0x55699 + 5 bytes

Route4EndBattleText1: ; 0x5569e
	TX_FAR _Route4EndBattleText1
	db $50
; 0x5569e + 5 bytes

Route4AfterBattleText1: ; 0x556a3
	TX_FAR _Route4AfterBattleText1
	db $50
; 0x556a3 + 5 bytes

Route4Text5: ; 0x556a8
	TX_FAR _Route4Text5
	db $50

Route4Text6: ; 0x556ad
	TX_FAR _Route4Text6
	db $50

Route5Script: ; 0x556b2
	jp $3c3c
; 0x556b5

Route5Texts: ; 0x556b5
	dw Route5Text1

Route5Text1: ; 0x556b7
	TX_FAR _Route5Text1
	db $50

Route9Script: ; 0x556bc
	call $3c3c
	ld hl, Route9TrainerHeaders
	ld de, Unknown_556cf
	ld a, [$d604]
	call $3160
	ld [$d604], a
	ret
; 0x556cf

Unknown_556cf: ; 0x556cf
INCBIN "baserom.gbc",$556cf,$6

Route9Texts: ; 0x556d5
	dw Route9Text1, Route9Text2, Route9Text3, Route9Text4, Route9Text5, Route9Text6, Route9Text7, Route9Text8, Route9Text9, Route9Text10, Route9Text11

Route9TrainerHeaders:
Route9TrainerHeader0: ; 0x556eb
	db $1 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d7cf ; flag's byte
	dw Route9BattleText1 ; 0x5792 TextBeforeBattle
	dw Route9AfterBattleText1 ; 0x579c TextAfterBattle
	dw Route9EndBattleText1 ; 0x5797 TextEndBattle
	dw Route9EndBattleText1 ; 0x5797 TextEndBattle
; 0x556f7

Route9TrainerHeader2: ; 0x556f7
	db $2 ; flag's bit
	db ($2 << 4) ; trainer's view range
	dw $d7cf ; flag's byte
	dw Route9BattleText2 ; 0x57a1 TextBeforeBattle
	dw Route9AfterBattleText2 ; 0x57ab TextAfterBattle
	dw Route9EndBattleText2 ; 0x57a6 TextEndBattle
	dw Route9EndBattleText2 ; 0x57a6 TextEndBattle
; 0x55703

Route9TrainerHeader3: ; 0x55703
	db $3 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d7cf ; flag's byte
	dw Route9BattleText3 ; 0x57b0 TextBeforeBattle
	dw Route9AfterBattleText3 ; 0x57ba TextAfterBattle
	dw Route9EndBattleText3 ; 0x57b5 TextEndBattle
	dw Route9EndBattleText3 ; 0x57b5 TextEndBattle
; 0x5570f

Route9TrainerHeader4: ; 0x5570f
	db $4 ; flag's bit
	db ($2 << 4) ; trainer's view range
	dw $d7cf ; flag's byte
	dw Route9BattleText4 ; 0x57bf TextBeforeBattle
	dw Route9AfterBattleText4 ; 0x57c9 TextAfterBattle
	dw Route9EndBattleText4 ; 0x57c4 TextEndBattle
	dw Route9EndBattleText4 ; 0x57c4 TextEndBattle
; 0x5571b

Route9TrainerHeader5: ; 0x5571b
	db $5 ; flag's bit
	db ($2 << 4) ; trainer's view range
	dw $d7cf ; flag's byte
	dw Route9BattleText5 ; 0x57ce TextBeforeBattle
	dw Route9AfterBattleText5 ; 0x57d8 TextAfterBattle
	dw Route9EndBattleText5 ; 0x57d3 TextEndBattle
	dw Route9EndBattleText5 ; 0x57d3 TextEndBattle
; 0x55727

Route9TrainerHeader6: ; 0x55727
	db $6 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d7cf ; flag's byte
	dw Route9BattleText6 ; 0x57dd TextBeforeBattle
	dw Route9AfterBattleText6 ; 0x57e7 TextAfterBattle
	dw Route9EndBattleText6 ; 0x57e2 TextEndBattle
	dw Route9EndBattleText6 ; 0x57e2 TextEndBattle
; 0x55733

Route9TrainerHeader7: ; 0x55733
	db $7 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d7cf ; flag's byte
	dw Route9BattleText7 ; 0x57ec TextBeforeBattle
	dw Route9AfterBattleText7 ; 0x57f6 TextAfterBattle
	dw Route9EndBattleText7 ; 0x57f1 TextEndBattle
	dw Route9EndBattleText7 ; 0x57f1 TextEndBattle
; 0x5573f

Route9TrainerHeader8: ; 0x5573f
	db $8 ; flag's bit
	db ($2 << 4) ; trainer's view range
	dw $d7cf ; flag's byte
	dw Route9BattleText8 ; 0x57fb TextBeforeBattle
	dw Route9AfterBattleText8 ; 0x5805 TextAfterBattle
	dw Route9EndBattleText8 ; 0x5800 TextEndBattle
	dw Route9EndBattleText8 ; 0x5800 TextEndBattle
; 0x5574b

Route9TrainerHeader9: ; 0x5574b
	db $9 ; flag's bit
	db ($2 << 4) ; trainer's view range
	dw $d7cf ; flag's byte
	dw Route9BattleText9 ; 0x580a TextBeforeBattle
	dw Route9AfterBattleText9 ; 0x5814 TextAfterBattle
	dw Route9EndBattleText9 ; 0x580f TextEndBattle
	dw Route9EndBattleText9 ; 0x580f TextEndBattle
; 0x55757

db $ff

Route9Text1: ; 0x55758
	db $8 ; asm
	ld hl, Route9TrainerHeader0
	jr asm_8be3d ; 0x5575c $2e

Route9Text2:
	db $8 ; asm
	ld hl, Route9TrainerHeader2
	jr asm_8be3d ; 0x55762 $28

Route9Text3:
	db $8 ; asm
	ld hl, Route9TrainerHeader3
	jr asm_8be3d ; 0x55768 $22

Route9Text4:
	db $8 ; asm
	ld hl, Route9TrainerHeader4
	jr asm_8be3d ; 0x5576e $1c

Route9Text5:
	db $8 ; asm
	ld hl, Route9TrainerHeader5
	jr asm_8be3d ; 0x55774 $16

Route9Text6:
	db $8 ; asm
	ld hl, Route9TrainerHeader6
	jr asm_8be3d ; 0x5577a $10

Route9Text7:
	db $8 ; asm
	ld hl, Route9TrainerHeader7
	jr asm_8be3d ; 0x55780 $a

Route9Text8:
	db $8 ; asm
	ld hl, Route9TrainerHeader8
	jr asm_8be3d ; 0x55786 $4

Route9Text9:
	db $8 ; asm
	ld hl, Route9TrainerHeader9
asm_8be3d: ; 0x5578c
	call LoadTrainerHeader
	jp TextScriptEnd
; 0x55792

Route9BattleText1: ; 0x55792
	TX_FAR _Route9BattleText1
	db $50
; 0x55792 + 5 bytes

Route9EndBattleText1: ; 0x55797
	TX_FAR _Route9EndBattleText1
	db $50
; 0x55797 + 5 bytes

Route9AfterBattleText1: ; 0x5579c
	TX_FAR _Route9AfterBattleText1
	db $50
; 0x5579c + 5 bytes

Route9BattleText2: ; 0x557a1
	TX_FAR _Route9BattleText2
	db $50
; 0x557a1 + 5 bytes

Route9EndBattleText2: ; 0x557a6
	TX_FAR _Route9EndBattleText2
	db $50
; 0x557a6 + 5 bytes

Route9AfterBattleText2: ; 0x557ab
	TX_FAR _Route9AfterBattleText2
	db $50
; 0x557ab + 5 bytes

Route9BattleText3: ; 0x557b0
	TX_FAR _Route9BattleText3
	db $50
; 0x557b0 + 5 bytes

Route9EndBattleText3: ; 0x557b5
	TX_FAR _Route9EndBattleText3
	db $50
; 0x557b5 + 5 bytes

Route9AfterBattleText3: ; 0x557ba
	TX_FAR _Route9AfterBattleText3
	db $50
; 0x557ba + 5 bytes

Route9BattleText4: ; 0x557bf
	TX_FAR _Route9BattleText4
	db $50
; 0x557bf + 5 bytes

Route9EndBattleText4: ; 0x557c4
	TX_FAR _Route9EndBattleText4
	db $50
; 0x557c4 + 5 bytes

Route9AfterBattleText4: ; 0x557c9
	TX_FAR _Route9AfterBattleText4
	db $50
; 0x557c9 + 5 bytes

Route9BattleText5: ; 0x557ce
	TX_FAR _Route9BattleText5
	db $50
; 0x557ce + 5 bytes

Route9EndBattleText5: ; 0x557d3
	TX_FAR _Route9EndBattleText5
	db $50
; 0x557d3 + 5 bytes

Route9AfterBattleText5: ; 0x557d8
	TX_FAR _Route9AfterBattleText5
	db $50
; 0x557d8 + 5 bytes

Route9BattleText6: ; 0x557dd
	TX_FAR _Route9BattleText6
	db $50
; 0x557dd + 5 bytes

Route9EndBattleText6: ; 0x557e2
	TX_FAR _Route9EndBattleText6
	db $50
; 0x557e2 + 5 bytes

Route9AfterBattleText6: ; 0x557e7
	TX_FAR _Route9AfterBattleText6
	db $50
; 0x557e7 + 5 bytes

Route9BattleText7: ; 0x557ec
	TX_FAR _Route9BattleText7
	db $50
; 0x557ec + 5 bytes

Route9EndBattleText7: ; 0x557f1
	TX_FAR _Route9EndBattleText7
	db $50
; 0x557f1 + 5 bytes

Route9AfterBattleText7: ; 0x557f6
	TX_FAR _Route9AfterBattleText7
	db $50
; 0x557f6 + 5 bytes

Route9BattleText8: ; 0x557fb
	TX_FAR _Route9BattleText8
	db $50
; 0x557fb + 5 bytes

Route9EndBattleText8: ; 0x55800
	TX_FAR _Route9EndBattleText8
	db $50
; 0x55800 + 5 bytes

Route9AfterBattleText8: ; 0x55805
	TX_FAR _Route9AfterBattleText8
	db $50
; 0x55805 + 5 bytes

Route9BattleText9: ; 0x5580a
	TX_FAR _Route9BattleText9
	db $50
; 0x5580a + 5 bytes

Route9EndBattleText9: ; 0x5580f
	TX_FAR _Route9EndBattleText9
	db $50
; 0x5580f + 5 bytes

Route9AfterBattleText9: ; 0x55814
	TX_FAR _Route9AfterBattleText9
	db $50
; 0x55814 + 5 bytes

Route9Text11: ; 0x55819
	TX_FAR _Route9Text11
	db $50

Route13Script: ; 0x5581e
	call $3c3c
	ld hl, Route13TrainerHeaders
	ld de, Route13Script_Unknown55831
	ld a, [$d61a]
	call $3160
	ld [$d61a], a
	ret
; 0x55831

Route13Script_Unknown55831: ; 0x55831
INCBIN "baserom.gbc",$55831,$6

Route13Texts: ; 0x55837
	dw Route13Text1, Route13Text2, Route13Text3, Route13Text4, Route13Text5, Route13Text6, Route13Text7, Route13Text8, Route13Text9, Route13Text10, Route13Text11, Route13Text12, Route13Text13

Route13TrainerHeaders:
Route13TrainerHeader0: ; 0x55851
	db $1 ; flag's bit
	db ($2 << 4) ; trainer's view range
	dw $d7d9 ; flag's byte
	dw Route13BattleText2 ; 0x58d4 TextBeforeBattle
	dw Route13AfterBattleText2 ; 0x58de TextAfterBattle
	dw Route13EndBattleText2 ; 0x58d9 TextEndBattle
	dw Route13EndBattleText2 ; 0x58d9 TextEndBattle
; 0x5585d

Route13TrainerHeader2: ; 0x5585d
	db $2 ; flag's bit
	db ($2 << 4) ; trainer's view range
	dw $d7d9 ; flag's byte
	dw Route13BattleText3 ; 0x58ed TextBeforeBattle
	dw Route13AfterBattleText3 ; 0x58f7 TextAfterBattle
	dw Route13EndBattleText3 ; 0x58f2 TextEndBattle
	dw Route13EndBattleText3 ; 0x58f2 TextEndBattle
; 0x55869

Route13TrainerHeader3: ; 0x55869
	db $3 ; flag's bit
	db ($2 << 4) ; trainer's view range
	dw $d7d9 ; flag's byte
	dw Route13BattleText4 ; 0x5906 TextBeforeBattle
	dw Route13AfterBattleText4 ; 0x5910 TextAfterBattle
	dw Route13EndBattleText4 ; 0x590b TextEndBattle
	dw Route13EndBattleText4 ; 0x590b TextEndBattle
; 0x55875

Route13TrainerHeader4: ; 0x55875
	db $4 ; flag's bit
	db ($2 << 4) ; trainer's view range
	dw $d7d9 ; flag's byte
	dw Route13BattleText5 ; 0x591f TextBeforeBattle
	dw Route13AfterBattleText5 ; 0x5929 TextAfterBattle
	dw Route13EndBattleText5 ; 0x5924 TextEndBattle
	dw Route13EndBattleText5 ; 0x5924 TextEndBattle
; 0x55881

Route13TrainerHeader5: ; 0x55881
	db $5 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d7d9 ; flag's byte
	dw Route13BattleText6 ; 0x5938 TextBeforeBattle
	dw Route13AfterBattleText6 ; 0x5942 TextAfterBattle
	dw Route13EndBattleText6 ; 0x593d TextEndBattle
	dw Route13EndBattleText6 ; 0x593d TextEndBattle
; 0x5588d

Route13TrainerHeader6: ; 0x5588d
	db $6 ; flag's bit
	db ($2 << 4) ; trainer's view range
	dw $d7d9 ; flag's byte
	dw Route13BattleText7 ; 0x5951 TextBeforeBattle
	dw Route13AfterBattleText7 ; 0x595b TextAfterBattle
	dw Route13EndBattleText7 ; 0x5956 TextEndBattle
	dw Route13EndBattleText7 ; 0x5956 TextEndBattle
; 0x55899

Route13TrainerHeader7: ; 0x55899
	db $7 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d7d9 ; flag's byte
	dw Route13BattleText8 ; 0x596a TextBeforeBattle
	dw Route13AfterBattleText8 ; 0x5974 TextAfterBattle
	dw Route13EndBattleText8 ; 0x596f TextEndBattle
	dw Route13EndBattleText8 ; 0x596f TextEndBattle
; 0x558a5

Route13TrainerHeader8: ; 0x558a5
	db $8 ; flag's bit
	db ($2 << 4) ; trainer's view range
	dw $d7d9 ; flag's byte
	dw Route13BattleText9 ; 0x5983 TextBeforeBattle
	dw Route13AfterBattleText9 ; 0x598d TextAfterBattle
	dw Route13EndBattleText9 ; 0x5988 TextEndBattle
	dw Route13EndBattleText9 ; 0x5988 TextEndBattle
; 0x558b1

Route13TrainerHeader9: ; 0x558b1
	db $9 ; flag's bit
	db ($2 << 4) ; trainer's view range
	dw $d7d9 ; flag's byte
	dw Route13BattleText10 ; 0x599c TextBeforeBattle
	dw Route13AfterBattleText10 ; 0x59a6 TextAfterBattle
	dw Route13EndBattleText10 ; 0x59a1 TextEndBattle
	dw Route13EndBattleText10 ; 0x59a1 TextEndBattle
; 0x558bd

Route13TrainerHeader10: ; 0x558bd
	db $a ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d7d9 ; flag's byte
	dw Route13BattleText11 ; 0x59b5 TextBeforeBattle
	dw Route13AfterBattleText11 ; 0x59bf TextAfterBattle
	dw Route13EndBattleText11 ; 0x59ba TextEndBattle
	dw Route13EndBattleText11 ; 0x59ba TextEndBattle
; 0x558c9

db $ff

Route13Text1: ; 0x558ca
	db $08 ; asm
	ld hl, Route13TrainerHeader0
	call LoadTrainerHeader
	jp TextScriptEnd

Route13BattleText2: ; 0x558d4
	TX_FAR _Route13BattleText2
	db $50
; 0x558d4 + 5 bytes

Route13EndBattleText2: ; 0x558d9
	TX_FAR _Route13EndBattleText2
	db $50
; 0x558d9 + 5 bytes

Route13AfterBattleText2: ; 0x558de
	TX_FAR _Route13AfterBattleText2
	db $50
; 0x558de + 5 bytes

Route13Text2: ; 0x558e3
	db $08 ; asm
	ld hl, Route13TrainerHeader2
	call LoadTrainerHeader
	jp TextScriptEnd

Route13BattleText3: ; 0x558ed
	TX_FAR _Route13BattleText3
	db $50
; 0x558ed + 5 bytes

Route13EndBattleText3: ; 0x558f2
	TX_FAR _Route13EndBattleText3
	db $50
; 0x558f2 + 5 bytes

Route13AfterBattleText3: ; 0x558f7
	TX_FAR _Route13AfterBattleText3
	db $50
; 0x558f7 + 5 bytes

Route13Text3: ; 0x558fc
	db $08 ; asm
	ld hl, Route13TrainerHeader3
	call LoadTrainerHeader
	jp TextScriptEnd

Route13BattleText4: ; 0x55906
	TX_FAR _Route13BattleText4
	db $50
; 0x55906 + 5 bytes

Route13EndBattleText4: ; 0x5590b
	TX_FAR _Route13EndBattleText4
	db $50
; 0x5590b + 5 bytes

Route13AfterBattleText4: ; 0x55910
	TX_FAR _Route13AfterBattleText4
	db $50
; 0x55910 + 5 bytes

Route13Text4: ; 0x55915
	db $08 ; asm
	ld hl, Route13TrainerHeader4
	call LoadTrainerHeader
	jp TextScriptEnd

Route13BattleText5: ; 0x5591f
	TX_FAR _Route13BattleText5
	db $50
; 0x5591f + 5 bytes

Route13EndBattleText5: ; 0x55924
	TX_FAR _Route13EndBattleText5
	db $50
; 0x55924 + 5 bytes

Route13AfterBattleText5: ; 0x55929
	TX_FAR _Route13AfterBattleText5
	db $50
; 0x55929 + 5 bytes

Route13Text5: ; 0x5592e
	db $08 ; asm
	ld hl, Route13TrainerHeader5
	call LoadTrainerHeader
	jp TextScriptEnd

Route13BattleText6: ; 0x55938
	TX_FAR _Route13BattleText6
	db $50
; 0x55938 + 5 bytes

Route13EndBattleText6: ; 0x5593d
	TX_FAR _Route13EndBattleText6
	db $50
; 0x5593d + 5 bytes

Route13AfterBattleText6: ; 0x55942
	TX_FAR _Route13AfterBattleText6
	db $50
; 0x55942 + 5 bytes

Route13Text6: ; 0x55947
	db $08 ; asm
	ld hl, Route13TrainerHeader6
	call LoadTrainerHeader
	jp TextScriptEnd

Route13BattleText7: ; 0x55951
	TX_FAR _Route13BattleText7
	db $50
; 0x55951 + 5 bytes

Route13EndBattleText7: ; 0x55956
	TX_FAR _Route13EndBattleText7
	db $50
; 0x55956 + 5 bytes

Route13AfterBattleText7: ; 0x5595b
	TX_FAR _Route13AfterBattleText7
	db $50
; 0x5595b + 5 bytes

Route13Text7: ; 0x55960
	db $08 ; asm
	ld hl, Route13TrainerHeader7
	call LoadTrainerHeader
	jp TextScriptEnd

Route13BattleText8: ; 0x5596a
	TX_FAR _Route13BattleText8
	db $50
; 0x5596a + 5 bytes

Route13EndBattleText8: ; 0x5596f
	TX_FAR _Route13EndBattleText8
	db $50
; 0x5596f + 5 bytes

Route13AfterBattleText8: ; 0x55974
	TX_FAR _Route13AfterBattleText8
	db $50
; 0x55974 + 5 bytes

Route13Text8: ; 0x55979
	db $08 ; asm
	ld hl, Route13TrainerHeader8
	call LoadTrainerHeader
	jp TextScriptEnd

Route13BattleText9: ; 0x55983
	TX_FAR _Route13BattleText9
	db $50
; 0x55983 + 5 bytes

Route13EndBattleText9: ; 0x55988
	TX_FAR _Route13EndBattleText9
	db $50
; 0x55988 + 5 bytes

Route13AfterBattleText9: ; 0x5598d
	TX_FAR _Route13AfterBattleText9
	db $50
; 0x5598d + 5 bytes

Route13Text9: ; 0x55992
	db $08 ; asm
	ld hl, Route13TrainerHeader9
	call LoadTrainerHeader
	jp TextScriptEnd

Route13BattleText10: ; 0x5599c
	TX_FAR _Route13BattleText10
	db $50
; 0x5599c + 5 bytes

Route13EndBattleText10: ; 0x559a1
	TX_FAR _Route13EndBattleText10
	db $50
; 0x559a1 + 5 bytes

Route13AfterBattleText10: ; 0x559a6
	TX_FAR _Route13AfterBattleText10
	db $50
; 0x559a6 + 5 bytes

Route13Text10: ; 0x559ab
	db $08 ; asm
	ld hl, Route13TrainerHeader10
	call LoadTrainerHeader
	jp TextScriptEnd

Route13BattleText11: ; 0x559b5
	TX_FAR _Route13BattleText11
	db $50
; 0x559b5 + 5 bytes

Route13EndBattleText11: ; 0x559ba
	TX_FAR _Route13EndBattleText11
	db $50
; 0x559ba + 5 bytes

Route13AfterBattleText11: ; 0x559bf
	TX_FAR _Route13AfterBattleText11
	db $50
; 0x559bf + 5 bytes

Route13Text11: ; 0x559c4
	TX_FAR _Route13Text11
	db $50

Route13Text12: ; 0x559c9
	TX_FAR _Route13Text12
	db $50

Route13Text13: ; 0x559ce
	TX_FAR _Route13Text13
	db $50

Route14Script: ; 0x559d3
	call $3c3c
	ld hl, Route14TrainerHeaders
	ld de, Unknown_559e6
	ld a, [$d61b]
	call $3160
	ld [$d61b], a
	ret
; 0x559e6

Unknown_559e6: ; 0x559e6
INCBIN "baserom.gbc",$559e6,$6

Route14Texts: ; 0x559ec
	dw Route14Text1, Route14Text2, Route14Text3, Route14Text4, Route14Text5, Route14Text6, Route14Text7, Route14Text8, Route14Text9, Route14Text10, Route14Text11

Route14TrainerHeaders:
Route14TrainerHeader0: ; 0x55a02
	db $1 ; flag's bit
	db ($2 << 4) ; trainer's view range
	dw $d7db ; flag's byte
	dw Route14BattleText1 ; 0x5a85 TextBeforeBattle
	dw Route14AfterBattleText1 ; 0x5a8f TextAfterBattle
	dw Route14EndBattleText1 ; 0x5a8a TextEndBattle
	dw Route14EndBattleText1 ; 0x5a8a TextEndBattle
; 0x55a0e

Route14TrainerHeader1: ; 0x55a0e
	db $2 ; flag's bit
	db ($2 << 4) ; trainer's view range
	dw $d7db ; flag's byte
	dw Route14BattleText2 ; 0x5a9e TextBeforeBattle
	dw Route14AfterBattleText2 ; 0x5aa8 TextAfterBattle
	dw Route14EndBattleText2 ; 0x5aa3 TextEndBattle
	dw Route14EndBattleText2 ; 0x5aa3 TextEndBattle
; 0x55a1a

Route14TrainerHeader2: ; 0x55a1a
	db $3 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d7db ; flag's byte
	dw Route14BattleText3 ; 0x5ab7 TextBeforeBattle
	dw Route14AfterBattleText3 ; 0x5ac1 TextAfterBattle
	dw Route14EndBattleText3 ; 0x5abc TextEndBattle
	dw Route14EndBattleText3 ; 0x5abc TextEndBattle
; 0x55a26

Route14TrainerHeader3: ; 0x55a26
	db $4 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d7db ; flag's byte
	dw Route14BattleText4 ; 0x5ad0 TextBeforeBattle
	dw Route14AfterBattleText4 ; 0x5ada TextAfterBattle
	dw Route14EndBattleText4 ; 0x5ad5 TextEndBattle
	dw Route14EndBattleText4 ; 0x5ad5 TextEndBattle
; 0x55a32

Route14TrainerHeader4: ; 0x55a32
	db $5 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d7db ; flag's byte
	dw Route14BattleText5 ; 0x5ae9 TextBeforeBattle
	dw Route14AfterBattleText5 ; 0x5af3 TextAfterBattle
	dw Route14EndBattleText5 ; 0x5aee TextEndBattle
	dw Route14EndBattleText5 ; 0x5aee TextEndBattle
; 0x55a3e

Route14TrainerHeader5: ; 0x55a3e
	db $6 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d7db ; flag's byte
	dw Route14BattleText6 ; 0x5b02 TextBeforeBattle
	dw Route14AfterBattleText6 ; 0x5b0c TextAfterBattle
	dw Route14EndBattleText6 ; 0x5b07 TextEndBattle
	dw Route14EndBattleText6 ; 0x5b07 TextEndBattle
; 0x55a4a

Route14TrainerHeader6: ; 0x55a4a
	db $7 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d7db ; flag's byte
	dw Route14BattleText7 ; 0x5b1b TextBeforeBattle
	dw Route14AfterBattleText7 ; 0x5b25 TextAfterBattle
	dw Route14EndBattleText7 ; 0x5b20 TextEndBattle
	dw Route14EndBattleText7 ; 0x5b20 TextEndBattle
; 0x55a56

Route14TrainerHeader7: ; 0x55a56
	db $8 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d7db ; flag's byte
	dw Route14BattleText8 ; 0x5b34 TextBeforeBattle
	dw Route14AfterBattleText8 ; 0x5b3e TextAfterBattle
	dw Route14EndBattleText8 ; 0x5b39 TextEndBattle
	dw Route14EndBattleText8 ; 0x5b39 TextEndBattle
; 0x55a62

Route14TrainerHeader8: ; 0x55a62
	db $9 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d7db ; flag's byte
	dw Route14BattleText9 ; 0x5b4d TextBeforeBattle
	dw Route14AfterBattleText9 ; 0x5b57 TextAfterBattle
	dw Route14EndBattleText9 ; 0x5b52 TextEndBattle
	dw Route14EndBattleText9 ; 0x5b52 TextEndBattle
; 0x55a6e

Route14TrainerHeader9: ; 0x55a6e
	db $a ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d7db ; flag's byte
	dw Route14BattleText10 ; 0x5b66 TextBeforeBattle
	dw Route14AfterBattleText10 ; 0x5b70 TextAfterBattle
	dw Route14EndBattleText10 ; 0x5b6b TextEndBattle
	dw Route14EndBattleText10 ; 0x5b6b TextEndBattle
; 0x55a7a

db $ff

Route14Text1: ; 0x55a7b
	db $08 ; asm
	ld hl, Route14TrainerHeader0
	call LoadTrainerHeader
	jp TextScriptEnd

Route14BattleText1: ; 0x55a85
	TX_FAR _Route14BattleText1
	db $50
; 0x55a85 + 5 bytes

Route14EndBattleText1: ; 0x55a8a
	TX_FAR _Route14EndBattleText1
	db $50
; 0x55a8a + 5 bytes

Route14AfterBattleText1: ; 0x55a8f
	TX_FAR _Route14AfterBattleText1
	db $50
; 0x55a8f + 5 bytes

Route14Text2: ; 0x55a94
	db $08 ; asm
	ld hl, Route14TrainerHeader1
	call LoadTrainerHeader
	jp TextScriptEnd

Route14BattleText2: ; 0x55a9e
	TX_FAR _Route14BattleText2
	db $50
; 0x55a9e + 5 bytes

Route14EndBattleText2: ; 0x55aa3
	TX_FAR _Route14EndBattleText2
	db $50
; 0x55aa3 + 5 bytes

Route14AfterBattleText2: ; 0x55aa8
	TX_FAR _Route14AfterBattleText2
	db $50
; 0x55aa8 + 5 bytes

Route14Text3: ; 0x55aad
	db $08 ; asm
	ld hl, Route14TrainerHeader2
	call LoadTrainerHeader
	jp TextScriptEnd

Route14BattleText3: ; 0x55ab7
	TX_FAR _Route14BattleText3
	db $50
; 0x55ab7 + 5 bytes

Route14EndBattleText3: ; 0x55abc
	TX_FAR _Route14EndBattleText3
	db $50
; 0x55abc + 5 bytes

Route14AfterBattleText3: ; 0x55ac1
	TX_FAR _Route14AfterBattleText3
	db $50
; 0x55ac1 + 5 bytes

Route14Text4: ; 0x55ac6
	db $08 ; asm
	ld hl, Route14TrainerHeader3
	call LoadTrainerHeader
	jp TextScriptEnd

Route14BattleText4: ; 0x55ad0
	TX_FAR _Route14BattleText4
	db $50
; 0x55ad0 + 5 bytes

Route14EndBattleText4: ; 0x55ad5
	TX_FAR _Route14EndBattleText4
	db $50
; 0x55ad5 + 5 bytes

Route14AfterBattleText4: ; 0x55ada
	TX_FAR _Route14AfterBattleText4
	db $50
; 0x55ada + 5 bytes

Route14Text5: ; 0x55adf
	db $08 ; asm
	ld hl, Route14TrainerHeader4
	call LoadTrainerHeader
	jp TextScriptEnd

Route14BattleText5: ; 0x55ae9
	TX_FAR _Route14BattleText5
	db $50
; 0x55ae9 + 5 bytes

Route14EndBattleText5: ; 0x55aee
	TX_FAR _Route14EndBattleText5
	db $50
; 0x55aee + 5 bytes

Route14AfterBattleText5: ; 0x55af3
	TX_FAR _Route14AfterBattleText5
	db $50
; 0x55af3 + 5 bytes

Route14Text6: ; 0x55af8
	db $08 ; asm
	ld hl, Route14TrainerHeader5
	call LoadTrainerHeader
	jp TextScriptEnd

Route14BattleText6: ; 0x55b02
	TX_FAR _Route14BattleText6
	db $50
; 0x55b02 + 5 bytes

Route14EndBattleText6: ; 0x55b07
	TX_FAR _Route14EndBattleText6
	db $50
; 0x55b07 + 5 bytes

Route14AfterBattleText6: ; 0x55b0c
	TX_FAR _Route14AfterBattleText6
	db $50
; 0x55b0c + 5 bytes

Route14Text7: ; 0x55b11
	db $08 ; asm
	ld hl, Route14TrainerHeader6
	call LoadTrainerHeader
	jp TextScriptEnd

Route14BattleText7: ; 0x55b1b
	TX_FAR _Route14BattleText7
	db $50
; 0x55b1b + 5 bytes

Route14EndBattleText7: ; 0x55b20
	TX_FAR _Route14EndBattleText7
	db $50
; 0x55b20 + 5 bytes

Route14AfterBattleText7: ; 0x55b25
	TX_FAR _Route14AfterBattleText7
	db $50
; 0x55b25 + 5 bytes

Route14Text8: ; 0x55b2a
	db $08 ; asm
	ld hl, Route14TrainerHeader7
	call LoadTrainerHeader
	jp TextScriptEnd

Route14BattleText8: ; 0x55b34
	TX_FAR _Route14BattleText8
	db $50
; 0x55b34 + 5 bytes

Route14EndBattleText8: ; 0x55b39
	TX_FAR _Route14EndBattleText8
	db $50
; 0x55b39 + 5 bytes

Route14AfterBattleText8: ; 0x55b3e
	TX_FAR _Route14AfterBattleText8
	db $50
; 0x55b3e + 5 bytes

Route14Text9: ; 0x55b43
	db $08 ; asm
	ld hl, Route14TrainerHeader8
	call LoadTrainerHeader
	jp TextScriptEnd

Route14BattleText9: ; 0x55b4d
	TX_FAR _Route14BattleText9
	db $50
; 0x55b4d + 5 bytes

Route14EndBattleText9: ; 0x55b52
	TX_FAR _Route14EndBattleText9
	db $50
; 0x55b52 + 5 bytes

Route14AfterBattleText9: ; 0x55b57
	TX_FAR _Route14AfterBattleText9
	db $50
; 0x55b57 + 5 bytes

Route14Text10: ; 0x55b5c
	db $08 ; asm
	ld hl, Route14TrainerHeader9
	call LoadTrainerHeader
	jp TextScriptEnd

Route14BattleText10: ; 0x55b66
	TX_FAR _Route14BattleText10
	db $50
; 0x55b66 + 5 bytes

Route14EndBattleText10: ; 0x55b6b
	TX_FAR _Route14EndBattleText10
	db $50
; 0x55b6b + 5 bytes

Route14AfterBattleText10: ; 0x55b70
	TX_FAR _Route14AfterBattleText10
	db $50
; 0x55b70 + 5 bytes

Route14Text11: ; 0x55b75
	TX_FAR _Route14Text11
	db $50

Route17Script: ; 0x55b7a
	call $3c3c
	ld hl, Route17TrainerHeaders
	ld de, Route17_Unknown55b8d
	ld a, [$d61c]
	call $3160
	ld [$d61c], a
	ret
; 0x55b8d

Route17_Unknown55b8d: ; 0x55b8d
INCBIN "baserom.gbc",$55b8d,$6

Route17Texts: ; 0x55b93
	dw Route17Text1, Route17Text2, Route17Text3, Route17Text4, Route17Text5, Route17Text6, Route17Text7, Route17Text8, Route17Text9, Route17Text10, Route17Text11, Route17Text12, Route17Text13, Route17Text14, Route17Text15, Route17Text16

Route17TrainerHeaders:
Route17TrainerHeader0: ; 0x55bb3
	db $1 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d7e1 ; flag's byte
	dw Route17BattleText1 ; 0x5c36 TextBeforeBattle
	dw Route17AfterBattleText1 ; 0x5c40 TextAfterBattle
	dw Route17EndBattleText1 ; 0x5c3b TextEndBattle
	dw Route17EndBattleText1 ; 0x5c3b TextEndBattle
; 0x55bbf

Route17TrainerHeader1: ; 0x55bbf
	db $2 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d7e1 ; flag's byte
	dw Route17BattleText2 ; 0x5c4f TextBeforeBattle
	dw Route17AfterBattleText2 ; 0x5c59 TextAfterBattle
	dw Route17EndBattleText2 ; 0x5c54 TextEndBattle
	dw Route17EndBattleText2 ; 0x5c54 TextEndBattle
; 0x55bcb

Route17TrainerHeader2: ; 0x55bcb
	db $3 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d7e1 ; flag's byte
	dw Route17BattleText3 ; 0x5c68 TextBeforeBattle
	dw Route17AfterBattleText3 ; 0x5c72 TextAfterBattle
	dw Route17EndBattleText3 ; 0x5c6d TextEndBattle
	dw Route17EndBattleText3 ; 0x5c6d TextEndBattle
; 0x55bd7

Route17TrainerHeader3: ; 0x55bd7
	db $4 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d7e1 ; flag's byte
	dw Route17BattleText4 ; 0x5c81 TextBeforeBattle
	dw Route17AfterBattleText4 ; 0x5c8b TextAfterBattle
	dw Route17EndBattleText4 ; 0x5c86 TextEndBattle
	dw Route17EndBattleText4 ; 0x5c86 TextEndBattle
; 0x55be3

Route17TrainerHeader4: ; 0x55be3
	db $5 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d7e1 ; flag's byte
	dw Route17BattleText5 ; 0x5c9a TextBeforeBattle
	dw Route17AfterBattleText5 ; 0x5ca4 TextAfterBattle
	dw Route17EndBattleText5 ; 0x5c9f TextEndBattle
	dw Route17EndBattleText5 ; 0x5c9f TextEndBattle
; 0x55bef

Route17TrainerHeader5: ; 0x55bef
	db $6 ; flag's bit
	db ($2 << 4) ; trainer's view range
	dw $d7e1 ; flag's byte
	dw Route17BattleText6 ; 0x5cb3 TextBeforeBattle
	dw Route17AfterBattleText6 ; 0x5cbd TextAfterBattle
	dw Route17EndBattleText6 ; 0x5cb8 TextEndBattle
	dw Route17EndBattleText6 ; 0x5cb8 TextEndBattle
; 0x55bfb

Route17TrainerHeader6: ; 0x55bfb
	db $7 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d7e1 ; flag's byte
	dw Route17BattleText7 ; 0x5ccc TextBeforeBattle
	dw Route17AfterBattleText7 ; 0x5cd6 TextAfterBattle
	dw Route17EndBattleText7 ; 0x5cd1 TextEndBattle
	dw Route17EndBattleText7 ; 0x5cd1 TextEndBattle
; 0x55c07

Route17TrainerHeader7: ; 0x55c07
	db $8 ; flag's bit
	db ($2 << 4) ; trainer's view range
	dw $d7e1 ; flag's byte
	dw Route17BattleText8 ; 0x5ce5 TextBeforeBattle
	dw Route17AfterBattleText8 ; 0x5cef TextAfterBattle
	dw Route17EndBattleText8 ; 0x5cea TextEndBattle
	dw Route17EndBattleText8 ; 0x5cea TextEndBattle
; 0x55c13

Route17TrainerHeader8: ; 0x55c13
	db $9 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d7e1 ; flag's byte
	dw Route17BattleText9 ; 0x5cfe TextBeforeBattle
	dw Route17AfterBattleText9 ; 0x5d08 TextAfterBattle
	dw Route17EndBattleText9 ; 0x5d03 TextEndBattle
	dw Route17EndBattleText9 ; 0x5d03 TextEndBattle
; 0x55c1f

Route17TrainerHeader9: ; 0x55c1f
	db $a ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d7e1 ; flag's byte
	dw Route17BattleText10 ; 0x5d17 TextBeforeBattle
	dw Route17AfterBattleText10 ; 0x5d21 TextAfterBattle
	dw Route17EndBattleText10 ; 0x5d1c TextEndBattle
	dw Route17EndBattleText10 ; 0x5d1c TextEndBattle
; 0x55c2b

db $ff

Route17Text1: ; 0x55c2c
	db $08 ; asm
	ld hl, Route17TrainerHeader0
	call LoadTrainerHeader
	jp TextScriptEnd

Route17BattleText1: ; 0x55c36
	TX_FAR _Route17BattleText1
	db $50
; 0x55c36 + 5 bytes

Route17EndBattleText1: ; 0x55c3b
	TX_FAR _Route17EndBattleText1
	db $50
; 0x55c3b + 5 bytes

Route17AfterBattleText1: ; 0x55c40
	TX_FAR _Route17AfterBattleText1
	db $50
; 0x55c40 + 5 bytes

Route17Text2: ; 0x55c45
	db $08 ; asm
	ld hl, Route17TrainerHeader1
	call LoadTrainerHeader
	jp TextScriptEnd

Route17BattleText2: ; 0x55c4f
	TX_FAR _Route17BattleText2
	db $50
; 0x55c4f + 5 bytes

Route17EndBattleText2: ; 0x55c54
	TX_FAR _Route17EndBattleText2
	db $50
; 0x55c54 + 5 bytes

Route17AfterBattleText2: ; 0x55c59
	TX_FAR _Route17AfterBattleText2
	db $50
; 0x55c59 + 5 bytes

Route17Text3: ; 0x55c5e
	db $08 ; asm
	ld hl, Route17TrainerHeader2
	call LoadTrainerHeader
	jp TextScriptEnd

Route17BattleText3: ; 0x55c68
	TX_FAR _Route17BattleText3
	db $50
; 0x55c68 + 5 bytes

Route17EndBattleText3: ; 0x55c6d
	TX_FAR _Route17EndBattleText3
	db $50
; 0x55c6d + 5 bytes

Route17AfterBattleText3: ; 0x55c72
	TX_FAR _Route17AfterBattleText3
	db $50
; 0x55c72 + 5 bytes

Route17Text4: ; 0x55c77
	db $08 ; asm
	ld hl, Route17TrainerHeader3
	call LoadTrainerHeader
	jp TextScriptEnd

Route17BattleText4: ; 0x55c81
	TX_FAR _Route17BattleText4
	db $50
; 0x55c81 + 5 bytes

Route17EndBattleText4: ; 0x55c86
	TX_FAR _Route17EndBattleText4
	db $50
; 0x55c86 + 5 bytes

Route17AfterBattleText4: ; 0x55c8b
	TX_FAR _Route17AfterBattleText4
	db $50
; 0x55c8b + 5 bytes

Route17Text5: ; 0x55c90
	db $08 ; asm
	ld hl, Route17TrainerHeader4
	call LoadTrainerHeader
	jp TextScriptEnd

Route17BattleText5: ; 0x55c9a
	TX_FAR _Route17BattleText5
	db $50
; 0x55c9a + 5 bytes

Route17EndBattleText5: ; 0x55c9f
	TX_FAR _Route17EndBattleText5
	db $50
; 0x55c9f + 5 bytes

Route17AfterBattleText5: ; 0x55ca4
	TX_FAR _Route17AfterBattleText5
	db $50
; 0x55ca4 + 5 bytes

Route17Text6: ; 0x55ca9
	db $08 ; asm
	ld hl, Route17TrainerHeader5
	call LoadTrainerHeader
	jp TextScriptEnd

Route17BattleText6: ; 0x55cb3
	TX_FAR _Route17BattleText6
	db $50
; 0x55cb3 + 5 bytes

Route17EndBattleText6: ; 0x55cb8
	TX_FAR _Route17EndBattleText6
	db $50
; 0x55cb8 + 5 bytes

Route17AfterBattleText6: ; 0x55cbd
	TX_FAR _Route17AfterBattleText6
	db $50
; 0x55cbd + 5 bytes

Route17Text7: ; 0x55cc2
	db $08 ; asm
	ld hl, Route17TrainerHeader6
	call LoadTrainerHeader
	jp TextScriptEnd

Route17BattleText7: ; 0x55ccc
	TX_FAR _Route17BattleText7
	db $50
; 0x55ccc + 5 bytes

Route17EndBattleText7: ; 0x55cd1
	TX_FAR _Route17EndBattleText7
	db $50
; 0x55cd1 + 5 bytes

Route17AfterBattleText7: ; 0x55cd6
	TX_FAR _Route17AfterBattleText7
	db $50
; 0x55cd6 + 5 bytes

Route17Text8: ; 0x55cdb
	db $08 ; asm
	ld hl, Route17TrainerHeader7
	call LoadTrainerHeader
	jp TextScriptEnd

Route17BattleText8: ; 0x55ce5
	TX_FAR _Route17BattleText8
	db $50
; 0x55ce5 + 5 bytes

Route17EndBattleText8: ; 0x55cea
	TX_FAR _Route17EndBattleText8
	db $50
; 0x55cea + 5 bytes

Route17AfterBattleText8: ; 0x55cef
	TX_FAR _Route17AfterBattleText8
	db $50
; 0x55cef + 5 bytes

Route17Text9: ; 0x55cf4
	db $08 ; asm
	ld hl, Route17TrainerHeader8
	call LoadTrainerHeader
	jp TextScriptEnd

Route17BattleText9: ; 0x55cfe
	TX_FAR _Route17BattleText9
	db $50
; 0x55cfe + 5 bytes

Route17EndBattleText9: ; 0x55d03
	TX_FAR _Route17EndBattleText9
	db $50
; 0x55d03 + 5 bytes

Route17AfterBattleText9: ; 0x55d08
	TX_FAR _Route17AfterBattleText9
	db $50
; 0x55d08 + 5 bytes

Route17Text10: ; 0x55d0d
	db $08 ; asm
	ld hl, Route17TrainerHeader9
	call LoadTrainerHeader
	jp TextScriptEnd

Route17BattleText10: ; 0x55d17
	TX_FAR _Route17BattleText10
	db $50
; 0x55d17 + 5 bytes

Route17EndBattleText10: ; 0x55d1c
	TX_FAR _Route17EndBattleText10
	db $50
; 0x55d1c + 5 bytes

Route17AfterBattleText10: ; 0x55d21
	TX_FAR _Route17AfterBattleText10
	db $50
; 0x55d21 + 5 bytes

Route17Text11: ; 0x55d26
	TX_FAR _Route17Text11
	db $50

Route17Text12: ; 0x55d2b
	TX_FAR _Route17Text12
	db $50

Route17Text13: ; 0x55d30
	TX_FAR _Route17Text13
	db $50

Route17Text14: ; 0x55d35
	TX_FAR _Route17Text14
	db $50

Route17Text15: ; 0x55d3a
	TX_FAR _Route17Text15
	db $50

Route17Text16: ; 0x55d3f
	TX_FAR _Route17Text16
	db $50

Route19Script: ; 0x55d44
	call $3c3c
	ld hl, Route19TrainerHeaders
	ld de, Route19_Unknown55d57
	ld a, [$d61d]
	call $3160
	ld [$d61d], a
	ret
; 0x55d57

Route19_Unknown55d57: ; 0x55d57
INCBIN "baserom.gbc",$55d57,$6

Route19Texts: ; 0x55d5d
	dw Route19Text1, Route19Text2, Route19Text3, Route19Text4, Route19Text5, Route19Text6, Route19Text7, Route19Text8, Route19Text9, Route19Text10, Route19Text11

Route19TrainerHeaders:
Route19TrainerHeader0: ; 0x55d73
	db $1 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d7e5 ; flag's byte
	dw Route19BattleText1 ; 0x5e50 TextBeforeBattle
	dw Route19AfterBattleText1 ; 0x5e5a TextAfterBattle
	dw Route19EndBattleText1 ; 0x5e55 TextEndBattle
	dw Route19EndBattleText1 ; 0x5e55 TextEndBattle
; 0x55d7f

Route19TrainerHeader1: ; 0x55d7f
	db $2 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d7e5 ; flag's byte
	dw Route19BattleText2 ; 0x5e5f TextBeforeBattle
	dw Route19AfterBattleText2 ; 0x5e69 TextAfterBattle
	dw Route19EndBattleText2 ; 0x5e64 TextEndBattle
	dw Route19EndBattleText2 ; 0x5e64 TextEndBattle
; 0x55d8b

Route19TrainerHeader2: ; 0x55d8b
	db $3 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d7e5 ; flag's byte
	dw Route19BattleText3 ; 0x5e6e TextBeforeBattle
	dw Route19AfterBattleText3 ; 0x5e78 TextAfterBattle
	dw Route19EndBattleText3 ; 0x5e73 TextEndBattle
	dw Route19EndBattleText3 ; 0x5e73 TextEndBattle
; 0x55d97

Route19TrainerHeader3: ; 0x55d97
	db $4 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d7e5 ; flag's byte
	dw Route19BattleText4 ; 0x5e7d TextBeforeBattle
	dw Route19AfterBattleText4 ; 0x5e87 TextAfterBattle
	dw Route19EndBattleText4 ; 0x5e82 TextEndBattle
	dw Route19EndBattleText4 ; 0x5e82 TextEndBattle
; 0x55da3

Route19TrainerHeader4: ; 0x55da3
	db $5 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d7e5 ; flag's byte
	dw Route19BattleText5 ; 0x5e8c TextBeforeBattle
	dw Route19AfterBattleText5 ; 0x5e96 TextAfterBattle
	dw Route19EndBattleText5 ; 0x5e91 TextEndBattle
	dw Route19EndBattleText5 ; 0x5e91 TextEndBattle
; 0x55daf

Route19TrainerHeader5: ; 0x55daf
	db $6 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d7e5 ; flag's byte
	dw Route19BattleText6 ; 0x5e9b TextBeforeBattle
	dw Route19AfterBattleText6 ; 0x5ea5 TextAfterBattle
	dw Route19EndBattleText6 ; 0x5ea0 TextEndBattle
	dw Route19EndBattleText6 ; 0x5ea0 TextEndBattle
; 0x55dbb

Route19TrainerHeader6: ; 0x55dbb
	db $7 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d7e5 ; flag's byte
	dw Route19BattleText7 ; 0x5eaa TextBeforeBattle
	dw Route19AfterBattleText7 ; 0x5eb4 TextAfterBattle
	dw Route19EndBattleText7 ; 0x5eaf TextEndBattle
	dw Route19EndBattleText7 ; 0x5eaf TextEndBattle
; 0x55dc7

Route19TrainerHeader7: ; 0x55dc7
	db $8 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d7e5 ; flag's byte
	dw Route19BattleText8 ; 0x5eb9 TextBeforeBattle
	dw Route19AfterBattleText8 ; 0x5ec3 TextAfterBattle
	dw Route19EndBattleText8 ; 0x5ebe TextEndBattle
	dw Route19EndBattleText8 ; 0x5ebe TextEndBattle
; 0x55dd3

Route19TrainerHeader8: ; 0x55dd3
	db $9 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d7e5 ; flag's byte
	dw Route19BattleText9 ; 0x5ec8 TextBeforeBattle
	dw Route19AfterBattleText9 ; 0x5ed2 TextAfterBattle
	dw Route19EndBattleText9 ; 0x5ecd TextEndBattle
	dw Route19EndBattleText9 ; 0x5ecd TextEndBattle
; 0x55ddf

Route19TrainerHeader9: ; 0x55ddf
	db $a ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d7e5 ; flag's byte
	dw Route19BattleText10 ; 0x5ed7 TextBeforeBattle
	dw Route19AfterBattleText10 ; 0x5ee1 TextAfterBattle
	dw Route19EndBattleText10 ; 0x5edc TextEndBattle
	dw Route19EndBattleText10 ; 0x5edc TextEndBattle
; 0x55deb

db $ff

Route19Text1: ; 0x55dec
	db $08 ; asm
	ld hl, Route19TrainerHeader0
	call LoadTrainerHeader
	jp TextScriptEnd

Route19Text2: ; 0x55df6
	db $08 ; asm
	ld hl, Route19TrainerHeader1
	call LoadTrainerHeader
	jp TextScriptEnd

Route19Text3: ; 0x55e00
	db $08 ; asm
	ld hl, Route19TrainerHeader2
	call LoadTrainerHeader
	jp TextScriptEnd

Route19Text4: ; 0x55e0a
	db $08 ; asm
	ld hl, Route19TrainerHeader3
	call LoadTrainerHeader
	jp TextScriptEnd

Route19Text5: ; 0x55e14
	db $08 ; asm
	ld hl, Route19TrainerHeader4
	call LoadTrainerHeader
	jp TextScriptEnd

Route19Text6: ; 0x55e1e
	db $08 ; asm
	ld hl, Route19TrainerHeader5
	call LoadTrainerHeader
	jp TextScriptEnd

Route19Text7: ; 0x55e28
	db $08 ; asm
	ld hl, Route19TrainerHeader6
	call LoadTrainerHeader
	jp TextScriptEnd

Route19Text8: ; 0x55e32
	db $08 ; asm
	ld hl, Route19TrainerHeader7
	call LoadTrainerHeader
	jp TextScriptEnd

Route19Text9: ; 0x55e3c
	db $08 ; asm
	ld hl, Route19TrainerHeader8
	call LoadTrainerHeader
	jp TextScriptEnd

Route19Text10: ; 0x55e46
	db $08 ; asm
	ld hl, Route19TrainerHeader9
	call LoadTrainerHeader
	jp TextScriptEnd

Route19BattleText1: ; 0x55e50
	TX_FAR _Route19BattleText1
	db $50
; 0x55e50 + 5 bytes

Route19EndBattleText1: ; 0x55e55
	TX_FAR _Route19EndBattleText1
	db $50
; 0x55e55 + 5 bytes

Route19AfterBattleText1: ; 0x55e5a
	TX_FAR _Route19AfterBattleText1
	db $50
; 0x55e5a + 5 bytes

Route19BattleText2: ; 0x55e5f
	TX_FAR _Route19BattleText2
	db $50
; 0x55e5f + 5 bytes

Route19EndBattleText2: ; 0x55e64
	TX_FAR _Route19EndBattleText2
	db $50
; 0x55e64 + 5 bytes

Route19AfterBattleText2: ; 0x55e69
	TX_FAR _Route19AfterBattleText2
	db $50
; 0x55e69 + 5 bytes

Route19BattleText3: ; 0x55e6e
	TX_FAR _Route19BattleText3
	db $50
; 0x55e6e + 5 bytes

Route19EndBattleText3: ; 0x55e73
	TX_FAR _Route19EndBattleText3
	db $50
; 0x55e73 + 5 bytes

Route19AfterBattleText3: ; 0x55e78
	TX_FAR _Route19AfterBattleText3
	db $50
; 0x55e78 + 5 bytes

Route19BattleText4: ; 0x55e7d
	TX_FAR _Route19BattleText4
	db $50
; 0x55e7d + 5 bytes

Route19EndBattleText4: ; 0x55e82
	TX_FAR _Route19EndBattleText4
	db $50
; 0x55e82 + 5 bytes

Route19AfterBattleText4: ; 0x55e87
	TX_FAR _Route19AfterBattleText4
	db $50
; 0x55e87 + 5 bytes

Route19BattleText5: ; 0x55e8c
	TX_FAR _Route19BattleText5
	db $50
; 0x55e8c + 5 bytes

Route19EndBattleText5: ; 0x55e91
	TX_FAR _Route19EndBattleText5
	db $50
; 0x55e91 + 5 bytes

Route19AfterBattleText5: ; 0x55e96
	TX_FAR _Route19AfterBattleText5
	db $50
; 0x55e96 + 5 bytes

Route19BattleText6: ; 0x55e9b
	TX_FAR _Route19BattleText6
	db $50
; 0x55e9b + 5 bytes

Route19EndBattleText6: ; 0x55ea0
	TX_FAR _Route19EndBattleText6
	db $50
; 0x55ea0 + 5 bytes

Route19AfterBattleText6: ; 0x55ea5
	TX_FAR _Route19AfterBattleText6
	db $50
; 0x55ea5 + 5 bytes

Route19BattleText7: ; 0x55eaa
	TX_FAR _Route19BattleText7
	db $50
; 0x55eaa + 5 bytes

Route19EndBattleText7: ; 0x55eaf
	TX_FAR _Route19EndBattleText7
	db $50
; 0x55eaf + 5 bytes

Route19AfterBattleText7: ; 0x55eb4
	TX_FAR _Route19AfterBattleText7
	db $50
; 0x55eb4 + 5 bytes

Route19BattleText8: ; 0x55eb9
	TX_FAR _Route19BattleText8
	db $50
; 0x55eb9 + 5 bytes

Route19EndBattleText8: ; 0x55ebe
	TX_FAR _Route19EndBattleText8
	db $50
; 0x55ebe + 5 bytes

Route19AfterBattleText8: ; 0x55ec3
	TX_FAR _Route19AfterBattleText8
	db $50
; 0x55ec3 + 5 bytes

Route19BattleText9: ; 0x55ec8
	TX_FAR _Route19BattleText9
	db $50
; 0x55ec8 + 5 bytes

Route19EndBattleText9: ; 0x55ecd
	TX_FAR _Route19EndBattleText9
	db $50
; 0x55ecd + 5 bytes

Route19AfterBattleText9: ; 0x55ed2
	TX_FAR _Route19AfterBattleText9
	db $50
; 0x55ed2 + 5 bytes

Route19BattleText10: ; 0x55ed7
	TX_FAR _Route19BattleText10
	db $50
; 0x55ed7 + 5 bytes

Route19EndBattleText10: ; 0x55edc
	TX_FAR _Route19EndBattleText10
	db $50
; 0x55edc + 5 bytes

Route19AfterBattleText10: ; 0x55ee1
	TX_FAR _Route19AfterBattleText10
	db $50
; 0x55ee1 + 5 bytes

Route19Text11: ; 0x55ee6
	TX_FAR _Route19Text11
	db $50

Route21Script: ; 0x55eeb
	call $3c3c
	ld hl, Route21TrainerHeaders
	ld de, Route21_Unknown55efe
	ld a, [$d61e]
	call $3160
	ld [$d61e], a
	ret
; 0x55efe

Route21_Unknown55efe: ; 0x55efe
INCBIN "baserom.gbc",$55efe,$6

Route21Texts: ; 0x55f04
	dw Route21Text1, Route21Text2, Route21Text3, Route21Text4, Route21Text5, Route21Text6, Route21Text7, Route21Text8, Route21Text9

Route21TrainerHeaders:
Route21TrainerHeader0: ; 0x55f16
	db $1 ; flag's bit
	db ($0 << 4) ; trainer's view range
	dw $d7e9 ; flag's byte
	dw Route21BattleText1 ; 0x5fdd TextBeforeBattle
	dw Route21AfterBattleText1 ; 0x5fe7 TextAfterBattle
	dw Route21EndBattleText1 ; 0x5fe2 TextEndBattle
	dw Route21EndBattleText1 ; 0x5fe2 TextEndBattle
; 0x55f22

Route21TrainerHeader1: ; 0x55f22
	db $2 ; flag's bit
	db ($0 << 4) ; trainer's view range
	dw $d7e9 ; flag's byte
	dw Route21BattleText2 ; 0x5fec TextBeforeBattle
	dw Route21AfterBattleText2 ; 0x5ff6 TextAfterBattle
	dw Route21EndBattleText2 ; 0x5ff1 TextEndBattle
	dw Route21EndBattleText2 ; 0x5ff1 TextEndBattle
; 0x55f2e

Route21TrainerHeader2: ; 0x55f2e
	db $3 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d7e9 ; flag's byte
	dw Route21BattleText3 ; 0x5ffb TextBeforeBattle
	dw Route21AfterBattleText3 ; 0x6005 TextAfterBattle
	dw Route21EndBattleText3 ; 0x6000 TextEndBattle
	dw Route21EndBattleText3 ; 0x6000 TextEndBattle
; 0x55f3a

Route21TrainerHeader3: ; 0x55f3a
	db $4 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d7e9 ; flag's byte
	dw Route21BattleText4 ; 0x600a TextBeforeBattle
	dw Route21AfterBattleText4 ; 0x6014 TextAfterBattle
	dw Route21EndBattleText4 ; 0x600f TextEndBattle
	dw Route21EndBattleText4 ; 0x600f TextEndBattle
; 0x55f46

Route21TrainerHeader4: ; 0x55f46
	db $5 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d7e9 ; flag's byte
	dw Route21BattleText5 ; 0x6019 TextBeforeBattle
	dw Route21AfterBattleText5 ; 0x6023 TextAfterBattle
	dw Route21EndBattleText5 ; 0x601e TextEndBattle
	dw Route21EndBattleText5 ; 0x601e TextEndBattle
; 0x55f52

Route21TrainerHeader5: ; 0x55f52
	db $6 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d7e9 ; flag's byte
	dw Route21BattleText6 ; 0x6028 TextBeforeBattle
	dw Route21AfterBattleText6 ; 0x6032 TextAfterBattle
	dw Route21EndBattleText6 ; 0x602d TextEndBattle
	dw Route21EndBattleText6 ; 0x602d TextEndBattle
; 0x55f5e

Route21TrainerHeader6: ; 0x55f5e
	db $7 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d7e9 ; flag's byte
	dw Route21BattleText7 ; 0x6037 TextBeforeBattle
	dw Route21AfterBattleText7 ; 0x6041 TextAfterBattle
	dw Route21EndBattleText7 ; 0x603c TextEndBattle
	dw Route21EndBattleText7 ; 0x603c TextEndBattle
; 0x55f6a

Route21TrainerHeader7: ; 0x55f6a
	db $8 ; flag's bit
	db ($0 << 4) ; trainer's view range
	dw $d7e9 ; flag's byte
	dw Route21BattleText8 ; 0x6046 TextBeforeBattle
	dw Route21AfterBattleText8 ; 0x6050 TextAfterBattle
	dw Route21EndBattleText8 ; 0x604b TextEndBattle
	dw Route21EndBattleText8 ; 0x604b TextEndBattle
; 0x55f76

Route21TrainerHeader8: ; 0x55f76
	db $9 ; flag's bit
	db ($0 << 4) ; trainer's view range
	dw $d7e9 ; flag's byte
	dw Route21BattleText9 ; 0x6055 TextBeforeBattle
	dw Route21AfterBattleText9 ; 0x605f TextAfterBattle
	dw Route21EndBattleText9 ; 0x605a TextEndBattle
	dw Route21EndBattleText9 ; 0x605a TextEndBattle
; 0x55f82

db $ff

Route21Text1: ; 0x55f83
	db $08 ; asm
	ld hl, Route21TrainerHeader0
	call LoadTrainerHeader
	jp TextScriptEnd

Route21Text2: ; 0x55f8d
	db $08 ; asm
	ld hl, Route21TrainerHeader1
	call LoadTrainerHeader
	jp TextScriptEnd

Route21Text3: ; 0x55f97
	db $08 ; asm
	ld hl, Route21TrainerHeader2
	call LoadTrainerHeader
	jp TextScriptEnd

Route21Text4: ; 0x55fa1
	db $08 ; asm
	ld hl, Route21TrainerHeader3
	call LoadTrainerHeader
	jp TextScriptEnd

Route21Text5: ; 0x55fab
	db $08 ; asm
	ld hl, Route21TrainerHeader4
	call LoadTrainerHeader
	jp TextScriptEnd

Route21Text6: ; 0x55fb5
	db $08 ; asm
	ld hl, Route21TrainerHeader5
	call LoadTrainerHeader
	jp TextScriptEnd

Route21Text7: ; 0x55fbf
	db $08 ; asm
	ld hl, Route21TrainerHeader6
	call LoadTrainerHeader
	jp TextScriptEnd

Route21Text8: ; 0x55fc9
	db $08 ; asm
	ld hl, Route21TrainerHeader7
	call LoadTrainerHeader
	jp TextScriptEnd

Route21Text9: ; 0x55fd3
	db $08 ; asm
	ld hl, Route21TrainerHeader8
	call LoadTrainerHeader
	jp TextScriptEnd

Route21BattleText1: ; 0x55fdd
	TX_FAR _Route21BattleText1
	db $50
; 0x55fdd + 5 bytes

Route21EndBattleText1: ; 0x55fe2
	TX_FAR _Route21EndBattleText1
	db $50
; 0x55fe2 + 5 bytes

Route21AfterBattleText1: ; 0x55fe7
	TX_FAR _Route21AfterBattleText1
	db $50
; 0x55fe7 + 5 bytes

Route21BattleText2: ; 0x55fec
	TX_FAR _Route21BattleText2
	db $50
; 0x55fec + 5 bytes

Route21EndBattleText2: ; 0x55ff1
	TX_FAR _Route21EndBattleText2
	db $50
; 0x55ff1 + 5 bytes

Route21AfterBattleText2: ; 0x55ff6
	TX_FAR _Route21AfterBattleText2
	db $50
; 0x55ff6 + 5 bytes

Route21BattleText3: ; 0x55ffb
	TX_FAR _Route21BattleText3
	db $50
; 0x55ffb + 5 bytes

Route21EndBattleText3: ; 0x56000
	TX_FAR _Route21EndBattleText3
	db $50
; 0x56000 + 5 bytes

Route21AfterBattleText3: ; 0x56005
	TX_FAR _Route21AfterBattleText3
	db $50
; 0x56005 + 5 bytes

Route21BattleText4: ; 0x5600a
	TX_FAR _Route21BattleText4
	db $50
; 0x5600a + 5 bytes

Route21EndBattleText4: ; 0x5600f
	TX_FAR _Route21EndBattleText4
	db $50
; 0x5600f + 5 bytes

Route21AfterBattleText4: ; 0x56014
	TX_FAR _Route21AfterBattleText4
	db $50
; 0x56014 + 5 bytes

Route21BattleText5: ; 0x56019
	TX_FAR _Route21BattleText5
	db $50
; 0x56019 + 5 bytes

Route21EndBattleText5: ; 0x5601e
	TX_FAR _Route21EndBattleText5
	db $50
; 0x5601e + 5 bytes

Route21AfterBattleText5: ; 0x56023
	TX_FAR _Route21AfterBattleText5
	db $50
; 0x56023 + 5 bytes

Route21BattleText6: ; 0x56028
	TX_FAR _Route21BattleText6
	db $50
; 0x56028 + 5 bytes

Route21EndBattleText6: ; 0x5602d
	TX_FAR _Route21EndBattleText6
	db $50
; 0x5602d + 5 bytes

Route21AfterBattleText6: ; 0x56032
	TX_FAR _Route21AfterBattleText6
	db $50
; 0x56032 + 5 bytes

Route21BattleText7: ; 0x56037
	TX_FAR _Route21BattleText7
	db $50
; 0x56037 + 5 bytes

Route21EndBattleText7: ; 0x5603c
	TX_FAR _Route21EndBattleText7
	db $50
; 0x5603c + 5 bytes

Route21AfterBattleText7: ; 0x56041
	TX_FAR _Route21AfterBattleText7
	db $50
; 0x56041 + 5 bytes

Route21BattleText8: ; 0x56046
	TX_FAR _Route21BattleText8
	db $50
; 0x56046 + 5 bytes

Route21EndBattleText8: ; 0x5604b
	TX_FAR _Route21EndBattleText8
	db $50
; 0x5604b + 5 bytes

Route21AfterBattleText8: ; 0x56050
	TX_FAR _Route21AfterBattleText8
	db $50
; 0x56050 + 5 bytes

Route21BattleText9: ; 0x56055
	TX_FAR _Route21BattleText9
	db $50
; 0x56055 + 5 bytes

Route21EndBattleText9: ; 0x5605a
	TX_FAR _Route21EndBattleText9
	db $50
; 0x5605a + 5 bytes

Route21AfterBattleText9: ; 0x5605f
	TX_FAR _Route21AfterBattleText9
	db $50
; 0x5605f + 5 bytes

VermilionHouse2_h: ; 0x56064 to 0x56070 (12 bytes) (id=163)
	db $08 ; tileset
	db VERMILION_HOUSE_2_HEIGHT, VERMILION_HOUSE_2_WIDTH ; dimensions (y, x)
	dw VermilionHouse2Blocks, VermilionHouse2Texts, VermilionHouse2Script ; blocks, texts, scripts
	db $00 ; connections

	dw VermilionHouse2Object ; objects

VermilionHouse2Script: ; 0x56070
	jp $3c3c
; 0x56073

VermilionHouse2Texts: ; 0x56073
	dw VermilionHouse2Text1

VermilionHouse2Text1: ; 0x56075
	db $08 ; asm
	ld a, [$d728]
	bit 3, a
	jr nz, asm_03ef5 ; 0x5607b
	ld hl, UnnamedText_560b1
	call PrintText
	call $35ec
	ld a, [$cc26]
	and a
	jr nz, asm_eb1b7 ; 0x5608a
	ld bc, (OLD_ROD << 8) | 1
	call GiveItem
	jr nc, asm_fd67b ; 0x56092
	ld hl, $d728
	set 3, [hl]
	ld hl, UnnamedText_560b6
	jr asm_5dd95 ; 0x5609c
asm_fd67b ; 0x5609e
	ld hl, UnnamedText_560ca
	jr asm_5dd95 ; 0x560a1
asm_eb1b7 ; 0x560a3
	ld hl, UnnamedText_560c0
	jr asm_5dd95 ; 0x560a6
asm_03ef5 ; 0x560a8
	ld hl, UnnamedText_560c5
asm_5dd95 ; 0x560ab
	call PrintText
	jp TextScriptEnd

UnnamedText_560b1: ; 0x560b1
	TX_FAR _UnnamedText_560b1
	db $50
; 0x560b1 + 5 bytes

UnnamedText_560b6: ; 0x560b6
	TX_FAR _UnnamedText_560b6 ; 0x9c554
	db $0B
	TX_FAR _UnnamedText_560bb ; 0x9c5a4
	db $50
; 0x560c0

UnnamedText_560c0: ; 0x560c0
	TX_FAR _UnnamedText_560c0
	db $50
; 0x560c0 + 5 bytes

UnnamedText_560c5: ; 0x560c5
	TX_FAR _UnnamedText_560c5
	db $50
; 0x560c5 + 5 bytes

UnnamedText_560ca: ; 0x560ca
	TX_FAR _UnnamedText_560ca
	db $50
; 0x560ca + 5 bytes

VermilionHouse2Object: ; 0x560cf (size=26)
	db $a ; border tile

	db $2 ; warps
	db $7, $2, $8, $ff
	db $7, $3, $8, $ff

	db $0 ; signs

	db $1 ; people
	db SPRITE_FISHER, $4 + 4, $2 + 4, $ff, $d3, $1 ; person

	; warp-to
	EVENT_DISP $4, $7, $2
	EVENT_DISP $4, $7, $3

CeladonMart2_h: ; 0x560e9 to 0x560f5 (12 bytes) (id=123)
	db $12 ; tileset
	db CELADON_MART_2_HEIGHT, CELADON_MART_2_WIDTH ; dimensions (y, x)
	dw CeladonMart2Blocks, CeladonMart2Texts, CeladonMart2Script ; blocks, texts, scripts
	db $00 ; connections

	dw CeladonMart2Object ; objects

CeladonMart2Script: ; 0x560f5
	jp $3c3c
; 0x560f8

CeladonMart2Texts: ; 0x560f8
	dw CeladonMart2Text1, CeladonMart2Text2, CeladonMart2Text3, CeladonMart2Text4, CeladonMart2Text5

CeladonMart2Text3: ; 0x56102
	TX_FAR _CeladonMart2Text3
	db $50

CeladonMart2Text4: ; 0x56107
	TX_FAR _CeladonMart2Text4
	db $50

CeladonMart2Text5: ; 0x5610c
	TX_FAR _CeladonMart2Text5
	db $50

CeladonMart2Object: ; 0x56111 (size=55)
	db $f ; border tile

	db $3 ; warps
	db $1, $c, $4, CELADON_MART_1
	db $1, $10, $1, CELADON_MART_3
	db $1, $1, $0, CELADON_MART_ELEVATOR

	db $1 ; signs
	db $1, $e, $5 ; CeladonMart2Text5

	db $4 ; people
	db SPRITE_MART_GUY, $3 + 4, $5 + 4, $ff, $d0, $1 ; person
	db SPRITE_MART_GUY, $3 + 4, $6 + 4, $ff, $d0, $2 ; person
	db SPRITE_FAT_BALD_GUY, $5 + 4, $13 + 4, $ff, $ff, $3 ; person
	db SPRITE_GIRL, $4 + 4, $e + 4, $fe, $1, $4 ; person

	; warp-to
	EVENT_DISP $a, $1, $c ; CELADON_MART_1
	EVENT_DISP $a, $1, $10 ; CELADON_MART_3
	EVENT_DISP $a, $1, $1 ; CELADON_MART_ELEVATOR

CeladonMart2Blocks: ; 0x56148 40
	INCBIN "maps/celadonmart2.blk"

FuchsiaHouse3_h: ; 0x56170 to 0x5617c (12 bytes) (id=164)
	db $0d ; tileset
	db FUCHSIA_HOUSE_3_HEIGHT, FUCHSIA_HOUSE_3_WIDTH ; dimensions (y, x)
	dw FuchsiaHouse3Blocks, FuchsiaHouse3Texts, FuchsiaHouse3Script ; blocks, texts, scripts
	db $00 ; connections

	dw FuchsiaHouse3Object ; objects

FuchsiaHouse3Script: ; 0x5617c
	jp $3c3c
; 0x5617f

FuchsiaHouse3Texts: ; 0x5617f
	dw FuchsiaHouse3Text1

FuchsiaHouse3Text1: ; 0x56181
	db $08 ; asm
	ld a, [$d728]
	bit 4, a
	jr nz, asm_6084e ; 0x56187
	ld hl, UnnamedText_561bd
	call PrintText
	call $35ec
	ld a, [$cc26]
	and a
	jr nz, asm_3ace4 ; 0x56196
	ld bc, (GOOD_ROD << 8) | 1
	call GiveItem
	jr nc, asm_628ee ; 0x5619e
	ld hl, $d728
	set 4, [hl]
	ld hl, UnnamedText_561c2
	jr asm_1b09c ; 0x561a8
asm_628ee ; 0x561aa
	ld hl, UnnamedText_5621c
	jr asm_1b09c ; 0x561ad
asm_3ace4 ; 0x561af
	ld hl, UnnamedText_56212
	jr asm_1b09c ; 0x561b2
asm_6084e ; 0x561b4
	ld hl, UnnamedText_56217
asm_1b09c ; 0x561b7
	call PrintText
	jp TextScriptEnd

UnnamedText_561bd: ; 0x561bd
	TX_FAR _UnnamedText_561bd
	db $50
; 0x561bd + 5 bytes

UnnamedText_561c2: ; 0x561c2
	TX_FAR _UnnamedText_561c2 ; 0xa06e8
	db $0B, $50
; 0x561c8

INCBIN "baserom.gbc",$561c8,$56212 - $561c8

UnnamedText_56212: ; 0x56212
	TX_FAR _UnnamedText_56212
	db $50
; 0x56212 + 5 bytes

UnnamedText_56217: ; 0x56217
	TX_FAR _UnnamedText_56217
	db $50
; 0x56217 + 5 bytes

UnnamedText_5621c: ; 0x5621c
	TX_FAR _UnnamedText_5621c
	db $50
; 0x5621c + 5 bytes

FuchsiaHouse3Object: ; 0x56221 (size=34)
	db $c ; border tile

	db $3 ; warps
	db $0, $2, $8, $ff
	db $7, $2, $7, $ff
	db $7, $3, $7, $ff

	db $0 ; signs

	db $1 ; people
	db SPRITE_FISHER, $3 + 4, $5 + 4, $ff, $d3, $1 ; person

	; warp-to
	EVENT_DISP $4, $0, $2
	EVENT_DISP $4, $7, $2
	EVENT_DISP $4, $7, $3

DayCareM_h: ; 0x56243 to 0x5624f (12 bytes) (id=72)
	db $08 ; tileset
	db DAYCAREM_HEIGHT, DAYCAREM_WIDTH ; dimensions (y, x)
	dw DayCareMBlocks, DayCareMTexts, DayCareMScript ; blocks, texts, scripts
	db $00 ; connections

	dw DayCareMObject ; objects

DayCareMScript: ; 0x5624f
	jp $3c3c
; 0x56252

DayCareMTexts: ; 0x56252
	dw DayCareMText1

DayCareMText1: ; 0x56254
	db $8
	call $36f4
	ld a, [$da48]
	and a
	jp nz, Unnamed_562e1
	ld hl, UnnamedText_5640f
	call PrintText
	call $35ec
	ld a, [$cc26]
	and a
	ld hl, UnnamedText_5643b
	jp nz, Unnamed_56409
	ld a, [$d163]
	dec a
	ld hl, UnnamedText_56445
	jp z, Unnamed_56409
	ld hl, UnnamedText_56414
	call PrintText
	xor a
	ld [$cfcb], a
	ld [$d07d], a
	ld [$cc35], a
	call $13fc
	push af
	call $3dd4
	call $3dbe
	call $20ba
	pop af
	ld hl, UnnamedText_56437
	jp c, Unnamed_56409
	ld hl, Route9TrainerHeader5
	ld b, $8
	call Bankswitch
	ld hl, UnnamedText_5644a
	jp c, Unnamed_56409
	xor a
	ld [$cc2b], a
	ld a, [$cf92]
	ld hl, $d2b5
	call $15ba
	ld hl, UnnamedText_56419
	call PrintText
	ld a, $1
	ld [$da48], a
	ld a, $3
	ld [$cf95], a
	call $3a68
	xor a
	ld [$cf95], a
	call $391f
	ld a, [$cf91]
	call $13d0
	ld hl, UnnamedText_5641e
	jp Unnamed_56409
; 0x562e1

Unnamed_562e1:
INCBIN "baserom.gbc",$562e1,$56409 - $562e1

Unnamed_56409: ; 0x56409
	call PrintText
	jp TextScriptEnd
; 0x5640f

UnnamedText_5640f: ; 0x5640f
	TX_FAR _UnnamedText_5640f
	db $50
; 0x5640f + 5 bytes

UnnamedText_56414: ; 0x56414
	TX_FAR _UnnamedText_56414
	db $50
; 0x56414 + 5 bytes

UnnamedText_56419: ; 0x56419
	TX_FAR _UnnamedText_56419
	db $50
; 0x56419 + 5 bytes

UnnamedText_5641e: ; 0x5641e
	TX_FAR _UnnamedText_5641e
	db $50
; 0x5641e + 5 bytes

UnnamedText_56423: ; 0x56423
	TX_FAR _UnnamedText_56423
	db $50
; 0x56423 + 5 bytes

UnnamedText_56428: ; 0x56428
	TX_FAR _UnnamedText_56428
	db $50
; 0x56428 + 5 bytes

UnnamedText_5642d: ; 0x5642d
	TX_FAR _UnnamedText_5642d
	db $50
; 0x5642d + 5 bytes

UnnamedText_56432: ; 0x56432
	TX_FAR _UnnamedText_56432
	db $50
; 0x56432 + 5 bytes

UnnamedText_56437: ; 0x56437
	TX_FAR _UnnamedText_56437 ; 0x8c000
UnnamedText_5643b: ; 0x5643b
	TX_FAR _UnnamedText_5643b ; 0x8c013
	db $50
; 0x5643b + 5 bytes

UnnamedText_56440: ; 0x56440
	TX_FAR _UnnamedText_56440
	db $50
; 0x56440 + 5 bytes

UnnamedText_56445: ; 0x56445
	TX_FAR _UnnamedText_56445
	db $50
; 0x56445 + 5 bytes

UnnamedText_5644a: ; 0x5644a
	TX_FAR _UnnamedText_5644a
	db $50
; 0x5644a + 5 bytes

UnnamedText_5644f: ; 0x5644f
	TX_FAR _UnnamedText_5644f
	db $50
; 0x5644f + 5 bytes

UnnamedText_56454: ; 0x56454
	TX_FAR _UnnamedText_56454
	db $50
; 0x56454 + 5 bytes

DayCareMObject: ; 0x56459 (size=26)
	db $a ; border tile

	db $2 ; warps
	db $7, $2, $4, $ff
	db $7, $3, $4, $ff

	db $0 ; signs

	db $1 ; people
	db SPRITE_GENTLEMAN, $3 + 4, $2 + 4, $ff, $d3, $1 ; person

	; warp-to
	EVENT_DISP $4, $7, $2
	EVENT_DISP $4, $7, $3

Route12House_h: ; 0x56473 to 0x5647f (12 bytes) (id=189)
	db $08 ; tileset
	db ROUTE_12_HOUSE_HEIGHT, ROUTE_12_HOUSE_WIDTH ; dimensions (y, x)
	dw Route12HouseBlocks, Route12HouseTexts, Route12HouseScript ; blocks, texts, scripts
	db $00 ; connections

	dw Route12HouseObject ; objects

Route12HouseScript: ; 0x5647f
	jp $3c3c
; 0x56482

Route12HouseTexts: ; 0x56482
	dw Route12HouseText1

Route12HouseText1: ; 0x56484
	db $08 ; asm
	ld a, [$d728]
	bit 5, a
	jr nz, asm_b4cad ; 0x5648a
	ld hl, UnnamedText_564c0
	call PrintText
	call $35ec
	ld a, [$cc26]
	and a
	jr nz, asm_a2d76 ; 0x56499
	ld bc, (SUPER_ROD << 8) | 1
	call GiveItem
	jr nc, asm_e3b89 ; 0x564a1
	ld hl, $d728
	set 5, [hl]
	ld hl, UnnamedText_564c5
	jr asm_df984 ; 0x564ab
asm_e3b89 ; 0x564ad
	ld hl, UnnamedText_564d9
	jr asm_df984 ; 0x564b0
asm_a2d76 ; 0x564b2
	ld hl, UnnamedText_564cf
	jr asm_df984 ; 0x564b5
asm_b4cad ; 0x564b7
	ld hl, UnnamedText_564d4
asm_df984 ; 0x564ba
	call PrintText
	jp TextScriptEnd

UnnamedText_564c0: ; 0x564c0
	TX_FAR _UnnamedText_564c0
	db $50
; 0x564c0 + 5 bytes

UnnamedText_564c5: ; 0x564c5
	TX_FAR _UnnamedText_564c5 ; 0x8ca00
	db $0B
	TX_FAR _UnnamedText_564ca ; 0x8ca4f
	db $50
; 0x564c5 + 10 bytes = 0x564cf

UnnamedText_564cf: ; 0x564cf
	TX_FAR _UnnamedText_564cf
	db $50
; 0x564cf + 5 bytes

UnnamedText_564d4: ; 0x564d4
	TX_FAR _UnnamedText_564d4
	db $50
; 0x564d4 + 5 bytes

UnnamedText_564d9: ; 0x564d9
	TX_FAR _UnnamedText_564d9
	db $50
; 0x564d9 + 5 bytes

Route12HouseObject: ; 0x564de (size=26)
	db $a ; border tile

	db $2 ; warps
	db $7, $2, $3, $ff
	db $7, $3, $3, $ff

	db $0 ; signs

	db $1 ; people
	db SPRITE_FISHER, $4 + 4, $2 + 4, $ff, $d3, $1 ; person

	; warp-to
	EVENT_DISP $4, $7, $2
	EVENT_DISP $4, $7, $3

SilphCo8_h: ; 0x564f8 to 0x56504 (12 bytes) (id=213)
	db $16 ; tileset
	db SILPH_CO_8F_HEIGHT, SILPH_CO_8F_WIDTH ; dimensions (y, x)
	dw SilphCo8Blocks, SilphCo8Texts, SilphCo8Script ; blocks, texts, scripts
	db $00 ; connections

	dw SilphCo8Object ; objects

SilphCo8Script: ; 0x56504
	call SilphCo8_Unknown5651a
	call $3c3c
	ld hl, SilphCo8TrainerHeader0
	ld de, $6577
	ld a, [$d649]
	call $3160
	ld [$d649], a
	ret
; 0x5651a

SilphCo8_Unknown5651a: ; 0x5651a
INCBIN "baserom.gbc",$5651a,$63

SilphCo8Texts: ; 0x5657d
	dw SilphCo8Text1, SilphCo8Text2, SilphCo8Text3, SilphCo8Text4

SilphCo8TrainerHeaders:
SilphCo8TrainerHeader0: ; 0x56585
	db $2 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d831 ; flag's byte
	dw SilphCo8BattleText1 ; 0x65e6 TextBeforeBattle
	dw SilphCo8AfterBattleText1 ; 0x65f0 TextAfterBattle
	dw SilphCo8EndBattleText1 ; 0x65eb TextEndBattle
	dw SilphCo8EndBattleText1 ; 0x65eb TextEndBattle
; 0x56591

SilphCo8TrainerHeader1: ; 0x56591
	db $3 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d831 ; flag's byte
	dw SilphCo8BattleText2 ; 0x65f5 TextBeforeBattle
	dw SilphCo8AfterBattleText2 ; 0x65ff TextAfterBattle
	dw SilphCo8EndBattleText2 ; 0x65fa TextEndBattle
	dw SilphCo8EndBattleText2 ; 0x65fa TextEndBattle
; 0x5659d

SilphCo8TrainerHeader2: ; 0x5659d
	db $4 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d831 ; flag's byte
	dw SilphCo8BattleText3 ; 0x6604 TextBeforeBattle
	dw SilphCo8AfterBattleText3 ; 0x660e TextAfterBattle
	dw SilphCo8EndBattleText3 ; 0x6609 TextEndBattle
	dw SilphCo8EndBattleText3 ; 0x6609 TextEndBattle
; 0x565a9

db $ff

SilphCo8Text1: ; 0x565aa
	db $08 ; asm
	ld a, [$d838]
	bit 7, a
	ld hl, UnnamedText_565c3
	jr nz, asm_a468f ; 0x565b3
	ld hl, UnnamedText_565be
asm_a468f ; 0x565b8
	call PrintText
	jp TextScriptEnd

UnnamedText_565be: ; 0x565be
	TX_FAR _UnnamedText_565be
	db $50
; 0x565be + 5 bytes

UnnamedText_565c3: ; 0x565c3
	TX_FAR _UnnamedText_565c3
	db $50
; 0x565c3 + 5 bytes

SilphCo8Text2: ; 0x565c8
	db $08 ; asm
	ld hl, SilphCo8TrainerHeader0
	call LoadTrainerHeader
	jp TextScriptEnd

SilphCo8Text3: ; 0x565d2
	db $08 ; asm
	ld hl, SilphCo8TrainerHeader1
	call LoadTrainerHeader
	jp TextScriptEnd

SilphCo8Text4: ; 0x565dc
	db $08 ; asm
	ld hl, SilphCo8TrainerHeader2
	call LoadTrainerHeader
	jp TextScriptEnd

SilphCo8BattleText1: ; 0x565e6
	TX_FAR _SilphCo8BattleText1
	db $50
; 0x565e6 + 5 bytes

SilphCo8EndBattleText1: ; 0x565eb
	TX_FAR _SilphCo8EndBattleText1
	db $50
; 0x565eb + 5 bytes

SilphCo8AfterBattleText1: ; 0x565f0
	TX_FAR _SilphCo8AfterBattleText1
	db $50
; 0x565f0 + 5 bytes

SilphCo8BattleText2: ; 0x565f5
	TX_FAR _SilphCo8BattleText2
	db $50
; 0x565f5 + 5 bytes

SilphCo8EndBattleText2: ; 0x565fa
	TX_FAR _SilphCo8EndBattleText2
	db $50
; 0x565fa + 5 bytes

SilphCo8AfterBattleText2: ; 0x565ff
	TX_FAR _SilphCo8AfterBattleText2
	db $50
; 0x565ff + 5 bytes

SilphCo8BattleText3: ; 0x56604
	TX_FAR _SilphCo8BattleText3
	db $50
; 0x56604 + 5 bytes

SilphCo8EndBattleText3: ; 0x56609
	TX_FAR _SilphCo8EndBattleText3
	db $50
; 0x56609 + 5 bytes

SilphCo8AfterBattleText3: ; 0x5660e
	TX_FAR _SilphCo8AfterBattleText3
	db $50
; 0x5660e + 5 bytes

SilphCo8Object: ; 0x56613 (size=90)
	db $2e ; border tile

	db $7 ; warps
	db $0, $10, $1, SILPH_CO_9F
	db $0, $e, $0, SILPH_CO_7F
	db $0, $12, $0, SILPH_CO_ELEVATOR
	db $b, $3, $6, SILPH_CO_8F
	db $f, $3, $4, SILPH_CO_2F
	db $5, $b, $5, SILPH_CO_2F
	db $9, $b, $3, SILPH_CO_8F

	db $0 ; signs

	db $4 ; people
	db SPRITE_LAPRAS_GIVER, $2 + 4, $4 + 4, $ff, $ff, $1 ; person
	db SPRITE_ROCKET, $2 + 4, $13 + 4, $ff, $d2, $42, ROCKET + $C8, $23 ; trainer
	db SPRITE_OAK_AIDE, $2 + 4, $a + 4, $ff, $d0, $43, SCIENTIST + $C8, $9 ; trainer
	db SPRITE_ROCKET, $f + 4, $c + 4, $ff, $d3, $44, ROCKET + $C8, $24 ; trainer

	; warp-to
	EVENT_DISP $d, $0, $10 ; SILPH_CO_9F
	EVENT_DISP $d, $0, $e ; SILPH_CO_7F
	EVENT_DISP $d, $0, $12 ; SILPH_CO_ELEVATOR
	EVENT_DISP $d, $b, $3 ; SILPH_CO_8F
	EVENT_DISP $d, $f, $3 ; SILPH_CO_2F
	EVENT_DISP $d, $5, $b ; SILPH_CO_2F
	EVENT_DISP $d, $9, $b ; SILPH_CO_8F

SilphCo8Blocks: ; 0x5666d 117
	INCBIN "maps/silphco8.blk"

INCBIN "baserom.gbc",$566e2,$191e

SECTION "bank16",DATA,BANK[$16]

Route6_h: ; 0x58000 to 0x58022 (34 bytes) (id=17)
	db $00 ; tileset
	db ROUTE_6_HEIGHT, ROUTE_6_WIDTH ; dimensions (y, x)
	dw Route6Blocks, Route6Texts, Route6Script ; blocks, texts, scripts
	db NORTH | SOUTH ; connections

	; connections data

	db SAFFRON_CITY
	dw SaffronCityBlocks + (SAFFRON_CITY_HEIGHT - 3) * SAFFRON_CITY_WIDTH + 2 ; connection strip location
	dw $C6EB + -3 ; current map position
	db $10, SAFFRON_CITY_WIDTH ; bigness, width
	db (SAFFRON_CITY_HEIGHT * 2) - 1, (-5 * -2) ; alignments (y, x)
	dw $C6E9 + SAFFRON_CITY_HEIGHT * (SAFFRON_CITY_WIDTH + 6) ; window

	db VERMILION_CITY
	dw VermilionCityBlocks + 2 ; connection strip location
	dw $C6EB + (ROUTE_6_HEIGHT + 3) * (ROUTE_6_WIDTH + 6) + -3 ; current map position
	db $10, VERMILION_CITY_WIDTH ; bigness, width
	db 0, (-5 * -2) ; alignments (y, x)
	dw $C6EF + VERMILION_CITY_WIDTH ; window

	; end connections data

	dw Route6Object ; objects

Route6Object: ; 0x58022 (size=87)
	db $f ; border tile

	db $4 ; warps
	db $1, $9, $2, ROUTE_6_GATE
	db $1, $a, $2, ROUTE_6_GATE
	db $7, $a, $0, ROUTE_6_GATE
	db $d, $11, $0, PATH_ENTRANCE_ROUTE_6

	db $1 ; signs
	db $f, $13, $7 ; Route6Text7

	db $6 ; people
	db SPRITE_BLACK_HAIR_BOY_1, $15 + 4, $a + 4, $ff, $d3, $41, JR__TRAINER_M + $C8, $4 ; trainer
	db SPRITE_LASS, $15 + 4, $b + 4, $ff, $d2, $42, JR__TRAINER_F + $C8, $2 ; trainer
	db SPRITE_BUG_CATCHER, $f + 4, $0 + 4, $ff, $d3, $43, BUG_CATCHER + $C8, $a ; trainer
	db SPRITE_BLACK_HAIR_BOY_1, $1f + 4, $b + 4, $ff, $d2, $44, JR__TRAINER_M + $C8, $5 ; trainer
	db SPRITE_LASS, $1e + 4, $b + 4, $ff, $d2, $45, JR__TRAINER_F + $C8, $3 ; trainer
	db SPRITE_BUG_CATCHER, $1a + 4, $13 + 4, $ff, $d2, $46, BUG_CATCHER + $C8, $b ; trainer

	; warp-to
	EVENT_DISP $a, $1, $9 ; ROUTE_6_GATE
	EVENT_DISP $a, $1, $a ; ROUTE_6_GATE
	EVENT_DISP $a, $7, $a ; ROUTE_6_GATE
	EVENT_DISP $a, $d, $11 ; PATH_ENTRANCE_ROUTE_6

Route6Blocks: ; 0x58079 180
	INCBIN "maps/route6.blk"

Route8_h: ; 0x5812d to 0x5814f (34 bytes) (id=19)
	db $00 ; tileset
	db ROUTE_8_HEIGHT, ROUTE_8_WIDTH ; dimensions (y, x)
	dw Route8Blocks, Route8Texts, Route8Script ; blocks, texts, scripts
	db WEST | EAST ; connections

	; connections data

	db SAFFRON_CITY
	dw SaffronCityBlocks - 3 + (SAFFRON_CITY_WIDTH * 2) ; connection strip location
	dw $C6E8 + (ROUTE_8_WIDTH + 6) * (-3 + 3) ; current map position
	db $f, SAFFRON_CITY_WIDTH ; bigness, width
	db (-4 * -2), (SAFFRON_CITY_WIDTH * 2) - 1 ; alignments (y, x)
	dw $C6EE + 2 * SAFFRON_CITY_WIDTH ; window

	db LAVENDER_TOWN
	dw LavenderTownBlocks + (LAVENDER_TOWN_WIDTH * 0) ; connection strip location
	dw $C6E5 + (ROUTE_8_WIDTH + 6) * (0 + 4) ; current map position
	db LAVENDER_TOWN_HEIGHT, LAVENDER_TOWN_WIDTH ; bigness, width
	db (0 * -2), 0 ; alignments (y, x)
	dw $C6EF + LAVENDER_TOWN_WIDTH ; window

	; end connections data

	dw Route8Object ; objects

Route8Object: ; 0x5814f (size=119)
	db $2c ; border tile

	db $5 ; warps
	db $9, $1, $0, ROUTE_8_GATE
	db $a, $1, $1, ROUTE_8_GATE
	db $9, $8, $2, ROUTE_8_GATE
	db $a, $8, $3, ROUTE_8_GATE
	db $3, $d, $0, PATH_ENTRANCE_ROUTE_8

	db $1 ; signs
	db $3, $11, $a ; Route8Text10

	db $9 ; people
	db SPRITE_BLACK_HAIR_BOY_2, $5 + 4, $8 + 4, $ff, $d3, $41, SUPER_NERD + $C8, $3 ; trainer
	db SPRITE_GAMBLER, $9 + 4, $d + 4, $ff, $d1, $42, GAMBLER + $C8, $5 ; trainer
	db SPRITE_BLACK_HAIR_BOY_2, $6 + 4, $2a + 4, $ff, $d1, $43, SUPER_NERD + $C8, $4 ; trainer
	db SPRITE_LASS, $3 + 4, $1a + 4, $ff, $d2, $44, LASS + $C8, $d ; trainer
	db SPRITE_BLACK_HAIR_BOY_2, $4 + 4, $1a + 4, $ff, $d3, $45, SUPER_NERD + $C8, $5 ; trainer
	db SPRITE_LASS, $5 + 4, $1a + 4, $ff, $d2, $46, LASS + $C8, $e ; trainer
	db SPRITE_LASS, $6 + 4, $1a + 4, $ff, $d3, $47, LASS + $C8, $f ; trainer
	db SPRITE_GAMBLER, $d + 4, $2e + 4, $ff, $d0, $48, GAMBLER + $C8, $7 ; trainer
	db SPRITE_LASS, $c + 4, $33 + 4, $ff, $d2, $49, LASS + $C8, $10 ; trainer

	; warp-to
	EVENT_DISP $1e, $9, $1 ; ROUTE_8_GATE
	EVENT_DISP $1e, $a, $1 ; ROUTE_8_GATE
	EVENT_DISP $1e, $9, $8 ; ROUTE_8_GATE
	EVENT_DISP $1e, $a, $8 ; ROUTE_8_GATE
	EVENT_DISP $1e, $3, $d ; PATH_ENTRANCE_ROUTE_8

Route8Blocks: ; 0x581c6 270
	INCBIN "maps/route8.blk"

Route10_h: ; 0x582d4 to 0x582f6 (34 bytes) (id=21)
	db $00 ; tileset
	db ROUTE_10_HEIGHT, ROUTE_10_WIDTH ; dimensions (y, x)
	dw Route10Blocks, Route10Texts, Route10Script ; blocks, texts, scripts
	db SOUTH | WEST ; connections

	; connections data

	db LAVENDER_TOWN
	dw LavenderTownBlocks ; connection strip location
	dw $C6EB + (ROUTE_10_HEIGHT + 3) * (ROUTE_10_WIDTH + 6) + 0 ; current map position
	db LAVENDER_TOWN_WIDTH, LAVENDER_TOWN_WIDTH ; bigness, width
	db 0, (0 * -2) ; alignments (y, x)
	dw $C6EF + LAVENDER_TOWN_WIDTH ; window

	db ROUTE_9
	dw Route9Blocks - 3 + (ROUTE_9_WIDTH) ; connection strip location
	dw $C6E8 + (ROUTE_10_WIDTH + 6) * (0 + 3) ; current map position
	db ROUTE_9_HEIGHT, ROUTE_9_WIDTH ; bigness, width
	db (0 * -2), (ROUTE_9_WIDTH * 2) - 1 ; alignments (y, x)
	dw $C6EE + 2 * ROUTE_9_WIDTH ; window

	; end connections data

	dw Route10Object ; objects

Route10Object: ; 0x582f6 (size=96)
	db $2c ; border tile

	db $4 ; warps
	db $13, $b, $0, ROCK_TUNNEL_POKECENTER
	db $11, $8, $0, ROCK_TUNNEL_1
	db $35, $8, $2, ROCK_TUNNEL_1
	db $27, $6, $0, POWER_PLANT

	db $4 ; signs
	db $13, $7, $7 ; Route10Text7
	db $13, $c, $8 ; Route10Text8
	db $37, $9, $9 ; Route10Text9
	db $29, $5, $a ; Route10Text10

	db $6 ; people
	db SPRITE_BLACK_HAIR_BOY_2, $2c + 4, $a + 4, $ff, $d2, $41, POKEMANIAC + $C8, $1 ; trainer
	db SPRITE_HIKER, $39 + 4, $3 + 4, $ff, $d1, $42, HIKER + $C8, $7 ; trainer
	db SPRITE_BLACK_HAIR_BOY_2, $40 + 4, $e + 4, $ff, $d2, $43, POKEMANIAC + $C8, $2 ; trainer
	db SPRITE_LASS, $19 + 4, $7 + 4, $ff, $d2, $44, JR__TRAINER_F + $C8, $7 ; trainer
	db SPRITE_HIKER, $3d + 4, $3 + 4, $ff, $d0, $45, HIKER + $C8, $8 ; trainer
	db SPRITE_LASS, $36 + 4, $7 + 4, $ff, $d0, $46, JR__TRAINER_F + $C8, $8 ; trainer

	; warp-to
	EVENT_DISP $a, $13, $b ; ROCK_TUNNEL_POKECENTER
	EVENT_DISP $a, $11, $8 ; ROCK_TUNNEL_1
	EVENT_DISP $a, $35, $8 ; ROCK_TUNNEL_1
	EVENT_DISP $a, $27, $6 ; POWER_PLANT

Route10Blocks: ; 0x58356 360
	INCBIN "maps/route10.blk"

Route11_h: ; 0x584be to 0x584e0 (34 bytes) (id=22)
	db $00 ; tileset
	db ROUTE_11_HEIGHT, ROUTE_11_WIDTH ; dimensions (y, x)
	dw Route11Blocks, Route11Texts, Route11Script ; blocks, texts, scripts
	db WEST | EAST ; connections

	; connections data

	db VERMILION_CITY
	dw VermilionCityBlocks - 3 + (VERMILION_CITY_WIDTH * 2) ; connection strip location
	dw $C6E8 + (ROUTE_11_WIDTH + 6) * (-3 + 3) ; current map position
	db $f, VERMILION_CITY_WIDTH ; bigness, width
	db (-4 * -2), (VERMILION_CITY_WIDTH * 2) - 1 ; alignments (y, x)
	dw $C6EE + 2 * VERMILION_CITY_WIDTH ; window

	db ROUTE_12
	dw Route12Blocks + (ROUTE_12_WIDTH * 24) ; connection strip location
	dw $C6E5 + (ROUTE_11_WIDTH + 6) * (-3 + 4) ; current map position
	db $f, ROUTE_12_WIDTH ; bigness, width
	db (-27 * -2), 0 ; alignments (y, x)
	dw $C6EF + ROUTE_12_WIDTH ; window

	; end connections data

	dw Route11Object ; objects

Route11Object: ; 0x584e0 (size=127)
	db $f ; border tile

	db $5 ; warps
	db $8, $31, $0, ROUTE_11_GATE_1F
	db $9, $31, $1, ROUTE_11_GATE_1F
	db $8, $3a, $2, ROUTE_11_GATE_1F
	db $9, $3a, $3, ROUTE_11_GATE_1F
	db $5, $4, $0, DIGLETTS_CAVE_ENTRANCE

	db $1 ; signs
	db $5, $1, $b ; Route11Text11

	db $a ; people
	db SPRITE_GAMBLER, $e + 4, $a + 4, $ff, $d0, $41, GAMBLER + $C8, $1 ; trainer
	db SPRITE_GAMBLER, $9 + 4, $1a + 4, $ff, $d0, $42, GAMBLER + $C8, $2 ; trainer
	db SPRITE_BUG_CATCHER, $5 + 4, $d + 4, $ff, $d2, $43, YOUNGSTER + $C8, $9 ; trainer
	db SPRITE_BLACK_HAIR_BOY_2, $b + 4, $24 + 4, $ff, $d0, $44, ENGINEER + $C8, $2 ; trainer
	db SPRITE_BUG_CATCHER, $4 + 4, $16 + 4, $ff, $d1, $45, YOUNGSTER + $C8, $a ; trainer
	db SPRITE_GAMBLER, $7 + 4, $2d + 4, $ff, $d0, $46, GAMBLER + $C8, $3 ; trainer
	db SPRITE_GAMBLER, $3 + 4, $21 + 4, $ff, $d1, $47, GAMBLER + $C8, $4 ; trainer
	db SPRITE_BUG_CATCHER, $5 + 4, $2b + 4, $ff, $d3, $48, YOUNGSTER + $C8, $b ; trainer
	db SPRITE_BLACK_HAIR_BOY_2, $10 + 4, $2d + 4, $ff, $d2, $49, ENGINEER + $C8, $3 ; trainer
	db SPRITE_BUG_CATCHER, $c + 4, $16 + 4, $ff, $d1, $4a, YOUNGSTER + $C8, $c ; trainer

	; warp-to
	EVENT_DISP $1e, $8, $31 ; ROUTE_11_GATE_1F
	EVENT_DISP $1e, $9, $31 ; ROUTE_11_GATE_1F
	EVENT_DISP $1e, $8, $3a ; ROUTE_11_GATE_1F
	EVENT_DISP $1e, $9, $3a ; ROUTE_11_GATE_1F
	EVENT_DISP $1e, $5, $4 ; DIGLETTS_CAVE_ENTRANCE

Route11Blocks: ; 0x5855f 270
	INCBIN "maps/route11.blk"

Route12_h: ; 0x5866d to 0x5869a (45 bytes) (id=23)
	db $00 ; tileset
	db ROUTE_12_HEIGHT, ROUTE_12_WIDTH ; dimensions (y, x)
	dw Route12Blocks, Route12Texts, Route12Script ; blocks, texts, scripts
	db NORTH | SOUTH | WEST ; connections

	; connections data

	db LAVENDER_TOWN
	dw LavenderTownBlocks + (LAVENDER_TOWN_HEIGHT - 3) * LAVENDER_TOWN_WIDTH ; connection strip location
	dw $C6EB + 0 ; current map position
	db LAVENDER_TOWN_WIDTH, LAVENDER_TOWN_WIDTH ; bigness, width
	db (LAVENDER_TOWN_HEIGHT * 2) - 1, (0 * -2) ; alignments (y, x)
	dw $C6E9 + LAVENDER_TOWN_HEIGHT * (LAVENDER_TOWN_WIDTH + 6) ; window

	db ROUTE_13
	dw Route13Blocks + 17 ; connection strip location
	dw $C6EB + (ROUTE_12_HEIGHT + 3) * (ROUTE_12_WIDTH + 6) + -3 ; current map position
	db $d, ROUTE_13_WIDTH ; bigness, width
	db 0, (-20 * -2) ; alignments (y, x)
	dw $C6EF + ROUTE_13_WIDTH ; window

	db ROUTE_11
	dw Route11Blocks - 3 + (ROUTE_11_WIDTH) ; connection strip location
	dw $C6E8 + (ROUTE_12_WIDTH + 6) * (27 + 3) ; current map position
	db ROUTE_11_HEIGHT, ROUTE_11_WIDTH ; bigness, width
	db (27 * -2), (ROUTE_11_WIDTH * 2) - 1 ; alignments (y, x)
	dw $C6EE + 2 * ROUTE_11_WIDTH ; window

	; end connections data

	dw Route12Object ; objects

Route12Object: ; 0x5869a (size=118)
	db $43 ; border tile

	db $4 ; warps
	db $f, $a, $0, ROUTE_12_GATE
	db $f, $b, $1, ROUTE_12_GATE
	db $15, $a, $2, ROUTE_12_GATE
	db $4d, $b, $0, ROUTE_12_HOUSE

	db $2 ; signs
	db $d, $d, $b ; Route12Text11
	db $3f, $b, $c ; Route12Text12

	db $a ; people
	db SPRITE_SNORLAX, $3e + 4, $a + 4, $ff, $d0, $1 ; person
	db SPRITE_FISHER2, $1f + 4, $e + 4, $ff, $d2, $42, FISHER + $C8, $3 ; trainer
	db SPRITE_FISHER2, $27 + 4, $5 + 4, $ff, $d1, $43, FISHER + $C8, $4 ; trainer
	db SPRITE_BLACK_HAIR_BOY_1, $5c + 4, $b + 4, $ff, $d2, $44, JR__TRAINER_M + $C8, $9 ; trainer
	db SPRITE_BLACK_HAIR_BOY_2, $4c + 4, $e + 4, $ff, $d1, $45, ROCKER + $C8, $2 ; trainer
	db SPRITE_FISHER2, $28 + 4, $c + 4, $ff, $d2, $46, FISHER + $C8, $5 ; trainer
	db SPRITE_FISHER2, $34 + 4, $9 + 4, $ff, $d3, $47, FISHER + $C8, $6 ; trainer
	db SPRITE_FISHER2, $57 + 4, $6 + 4, $ff, $d0, $48, FISHER + $C8, $b ; trainer
	db SPRITE_BALL, $23 + 4, $e + 4, $ff, $ff, $89, TM_16 ; item
	db SPRITE_BALL, $59 + 4, $5 + 4, $ff, $ff, $8a, IRON ; item

	; warp-to
	EVENT_DISP $a, $f, $a ; ROUTE_12_GATE
	EVENT_DISP $a, $f, $b ; ROUTE_12_GATE
	EVENT_DISP $a, $15, $a ; ROUTE_12_GATE
	EVENT_DISP $a, $4d, $b ; ROUTE_12_HOUSE

Route12Blocks: ; 0x58710 540
	INCBIN "maps/route12.blk"

Route15_h: ; 0x5892c to 0x5894e (34 bytes) (id=26)
	db $00 ; tileset
	db ROUTE_15_HEIGHT, ROUTE_15_WIDTH ; dimensions (y, x)
	dw Route15Blocks, Route15Texts, Route15Script ; blocks, texts, scripts
	db WEST | EAST ; connections

	; connections data

	db FUCHSIA_CITY
	dw FuchsiaCityBlocks - 3 + (FUCHSIA_CITY_WIDTH * 2) ; connection strip location
	dw $C6E8 + (ROUTE_15_WIDTH + 6) * (-3 + 3) ; current map position
	db $f, FUCHSIA_CITY_WIDTH ; bigness, width
	db (-4 * -2), (FUCHSIA_CITY_WIDTH * 2) - 1 ; alignments (y, x)
	dw $C6EE + 2 * FUCHSIA_CITY_WIDTH ; window

	db ROUTE_14
	dw Route14Blocks + (ROUTE_14_WIDTH * 15) ; connection strip location
	dw $C6E5 + (ROUTE_15_WIDTH + 6) * (-3 + 4) ; current map position
	db $c, ROUTE_14_WIDTH ; bigness, width
	db (-18 * -2), 0 ; alignments (y, x)
	dw $C6EF + ROUTE_14_WIDTH ; window

	; end connections data

	dw Route15Object ; objects

Route15Object: ; 0x5894e (size=126)
	db $43 ; border tile

	db $4 ; warps
	db $8, $7, $0, ROUTE_15_GATE
	db $9, $7, $1, ROUTE_15_GATE
	db $8, $e, $2, ROUTE_15_GATE
	db $9, $e, $3, ROUTE_15_GATE

	db $1 ; signs
	db $9, $27, $c ; Route15Text12

	db $b ; people
	db SPRITE_LASS, $b + 4, $29 + 4, $ff, $d0, $41, JR__TRAINER_F + $C8, $14 ; trainer
	db SPRITE_LASS, $a + 4, $35 + 4, $ff, $d2, $42, JR__TRAINER_F + $C8, $15 ; trainer
	db SPRITE_BLACK_HAIR_BOY_1, $d + 4, $1f + 4, $ff, $d1, $43, BIRD_KEEPER + $C8, $6 ; trainer
	db SPRITE_BLACK_HAIR_BOY_1, $d + 4, $23 + 4, $ff, $d1, $44, BIRD_KEEPER + $C8, $7 ; trainer
	db SPRITE_FOULARD_WOMAN, $b + 4, $35 + 4, $ff, $d0, $45, BEAUTY + $C8, $9 ; trainer
	db SPRITE_FOULARD_WOMAN, $a + 4, $29 + 4, $ff, $d3, $46, BEAUTY + $C8, $a ; trainer
	db SPRITE_BIKER, $a + 4, $30 + 4, $ff, $d0, $47, BIKER + $C8, $3 ; trainer
	db SPRITE_BIKER, $a + 4, $2e + 4, $ff, $d0, $48, BIKER + $C8, $4 ; trainer
	db SPRITE_LASS, $5 + 4, $25 + 4, $ff, $d3, $49, JR__TRAINER_F + $C8, $16 ; trainer
	db SPRITE_LASS, $d + 4, $12 + 4, $ff, $d1, $4a, JR__TRAINER_F + $C8, $17 ; trainer
	db SPRITE_BALL, $5 + 4, $12 + 4, $ff, $ff, $8b, TM_20 ; item

	; warp-to
	EVENT_DISP $1e, $8, $7 ; ROUTE_15_GATE
	EVENT_DISP $1e, $9, $7 ; ROUTE_15_GATE
	EVENT_DISP $1e, $8, $e ; ROUTE_15_GATE
	EVENT_DISP $1e, $9, $e ; ROUTE_15_GATE

Route15Blocks: ; 0x589cc 270
	INCBIN "maps/route15.blk"

Route16_h: ; 0x58ada to 0x58afc (34 bytes) (id=27)
	db $00 ; tileset
	db ROUTE_16_HEIGHT, ROUTE_16_WIDTH ; dimensions (y, x)
	dw Route16Blocks, Route16Texts, Route16Script ; blocks, texts, scripts
	db SOUTH | EAST ; connections

	; connections data

	db ROUTE_17
	dw Route17Blocks ; connection strip location
	dw $C6EB + (ROUTE_16_HEIGHT + 3) * (ROUTE_16_WIDTH + 6) + 0 ; current map position
	db ROUTE_17_WIDTH, ROUTE_17_WIDTH ; bigness, width
	db 0, (0 * -2) ; alignments (y, x)
	dw $C6EF + ROUTE_17_WIDTH ; window

	db CELADON_CITY
	dw CeladonCityBlocks + (CELADON_CITY_WIDTH) ; connection strip location
	dw $C6E5 + (ROUTE_16_WIDTH + 6) * (-3 + 4) ; current map position
	db $f, CELADON_CITY_WIDTH ; bigness, width
	db (-4 * -2), 0 ; alignments (y, x)
	dw $C6EF + CELADON_CITY_WIDTH ; window

	; end connections data

	dw Route16Object ; objects

Route16Object: ; 0x58afc (size=136)
	db $f ; border tile

	db $9 ; warps
	db $a, $11, $0, ROUTE_16_GATE_1F
	db $b, $11, $1, ROUTE_16_GATE_1F
	db $a, $18, $2, ROUTE_16_GATE_1F
	db $b, $18, $3, ROUTE_16_GATE_1F
	db $4, $11, $4, ROUTE_16_GATE_1F
	db $5, $11, $5, ROUTE_16_GATE_1F
	db $4, $18, $6, ROUTE_16_GATE_1F
	db $5, $18, $7, ROUTE_16_GATE_1F
	db $5, $7, $0, ROUTE_16_HOUSE

	db $2 ; signs
	db $b, $1b, $8 ; Route16Text8
	db $11, $5, $9 ; Route16Text9

	db $7 ; people
	db SPRITE_BIKER, $c + 4, $11 + 4, $ff, $d2, $41, BIKER + $C8, $5 ; trainer
	db SPRITE_BIKER, $d + 4, $e + 4, $ff, $d3, $42, CUE_BALL + $C8, $1 ; trainer
	db SPRITE_BIKER, $c + 4, $b + 4, $ff, $d1, $43, CUE_BALL + $C8, $2 ; trainer
	db SPRITE_BIKER, $b + 4, $9 + 4, $ff, $d2, $44, BIKER + $C8, $6 ; trainer
	db SPRITE_BIKER, $a + 4, $6 + 4, $ff, $d3, $45, CUE_BALL + $C8, $3 ; trainer
	db SPRITE_BIKER, $c + 4, $3 + 4, $ff, $d3, $46, BIKER + $C8, $7 ; trainer
	db SPRITE_SNORLAX, $a + 4, $1a + 4, $ff, $d0, $7 ; person

	; warp-to
	EVENT_DISP $14, $a, $11 ; ROUTE_16_GATE_1F
	EVENT_DISP $14, $b, $11 ; ROUTE_16_GATE_1F
	EVENT_DISP $14, $a, $18 ; ROUTE_16_GATE_1F
	EVENT_DISP $14, $b, $18 ; ROUTE_16_GATE_1F
	EVENT_DISP $14, $4, $11 ; ROUTE_16_GATE_1F
	EVENT_DISP $14, $5, $11 ; ROUTE_16_GATE_1F
	EVENT_DISP $14, $4, $18 ; ROUTE_16_GATE_1F
	EVENT_DISP $14, $5, $18 ; ROUTE_16_GATE_1F
	EVENT_DISP $14, $5, $7 ; ROUTE_16_HOUSE

Route16Blocks: ; 0x58b84 180
	INCBIN "maps/route16.blk"

Route18_h: ; 0x58c38 to 0x58c5a (34 bytes) (id=29)
	db $00 ; tileset
	db ROUTE_18_HEIGHT, ROUTE_18_WIDTH ; dimensions (y, x)
	dw Route18Blocks, Route18Texts, Route18Script ; blocks, texts, scripts
	db NORTH | EAST ; connections

	; connections data

	db ROUTE_17
	dw Route17Blocks + (ROUTE_17_HEIGHT - 3) * ROUTE_17_WIDTH ; connection strip location
	dw $C6EB + 0 ; current map position
	db ROUTE_17_WIDTH, ROUTE_17_WIDTH ; bigness, width
	db (ROUTE_17_HEIGHT * 2) - 1, (0 * -2) ; alignments (y, x)
	dw $C6E9 + ROUTE_17_HEIGHT * (ROUTE_17_WIDTH + 6) ; window

	db FUCHSIA_CITY
	dw FuchsiaCityBlocks + (FUCHSIA_CITY_WIDTH) ; connection strip location
	dw $C6E5 + (ROUTE_18_WIDTH + 6) * (-3 + 4) ; current map position
	db $f, FUCHSIA_CITY_WIDTH ; bigness, width
	db (-4 * -2), 0 ; alignments (y, x)
	dw $C6EF + FUCHSIA_CITY_WIDTH ; window

	; end connections data

	dw Route18Object ; objects

Route18Object: ; 0x58c5a (size=66)
	db $43 ; border tile

	db $4 ; warps
	db $8, $21, $0, ROUTE_18_GATE_1F
	db $9, $21, $1, ROUTE_18_GATE_1F
	db $8, $28, $2, ROUTE_18_GATE_1F
	db $9, $28, $3, ROUTE_18_GATE_1F

	db $2 ; signs
	db $7, $2b, $4 ; Route18Text4
	db $5, $21, $5 ; Route18Text5

	db $3 ; people
	db SPRITE_BLACK_HAIR_BOY_1, $b + 4, $24 + 4, $ff, $d3, $41, BIRD_KEEPER + $C8, $8 ; trainer
	db SPRITE_BLACK_HAIR_BOY_1, $f + 4, $28 + 4, $ff, $d2, $42, BIRD_KEEPER + $C8, $9 ; trainer
	db SPRITE_BLACK_HAIR_BOY_1, $d + 4, $2a + 4, $ff, $d2, $43, BIRD_KEEPER + $C8, $a ; trainer

	; warp-to
	EVENT_DISP $19, $8, $21 ; ROUTE_18_GATE_1F
	EVENT_DISP $19, $9, $21 ; ROUTE_18_GATE_1F
	EVENT_DISP $19, $8, $28 ; ROUTE_18_GATE_1F
	EVENT_DISP $19, $9, $28 ; ROUTE_18_GATE_1F

Route18Blocks: ; 0x58c9c 225
	INCBIN "maps/route18.blk"

INCBIN "baserom.gbc",$58d7d,$58e3b - $58d7d

UnnamedText_58e3b: ; 0x58e3b
	TX_FAR _UnnamedText_58e3b
	db $50
; 0x58e3b + 5 bytes

UnnamedText_58e40: ; 0x58e40
	TX_FAR _UnnamedText_58e40
	db $50
; 0x58e40 + 5 bytes

UnnamedText_58e45: ; 0x58e45
	TX_FAR _UnnamedText_58e45
	db $50
; 0x58e45 + 5 bytes

UnnamedText_58e4a: ; 0x58e4a
	TX_FAR _UnnamedText_58e4a
	db $50
; 0x58e4a + 5 bytes

UnnamedText_58e4f: ; 0x58e4f
	TX_FAR _UnnamedText_58e4f
	db $50
; 0x58e4f + 5 bytes

UnnamedText_58e54: ; 0x58e54
	TX_FAR _UnnamedText_58e54
	db $50
; 0x58e54 + 5 bytes

INCBIN "baserom.gbc",$58e59,$58ecc - $58e59

UnnamedText_58ecc: ; 0x58ecc
	TX_FAR _UnnamedText_58ecc
	db $50
; 0x58ecc + 5 bytes

INCBIN "baserom.gbc",$58ed1,$58f3e - $58ed1

UnnamedText_58f3e: ; 0x58f3e
	TX_FAR _UnnamedText_58f3e
	db $50
; 0x58f3e + 5 bytes

INCBIN "baserom.gbc",$58f43,$59091 - $58f43

UnnamedText_59091: ; 0x59091
	TX_FAR _UnnamedText_59091
	db $50
; 0x59091 + 5 bytes

UnnamedText_59096: ; 0x59096
	TX_FAR _UnnamedText_59096
	db $50
; 0x59096 + 5 bytes

UnnamedText_5909b: ; 0x5909b
	TX_FAR _UnnamedText_5909b
	db $50
; 0x5909b + 5 bytes

UnnamedText_590a0: ; 0x590a0
	TX_FAR _UnnamedText_590a0
	db $50
; 0x590a0 + 5 bytes

INCBIN "baserom.gbc",$590a5,$590ab - $590a5

UnnamedText_590ab: ; 0x590ab
	TX_FAR _UnnamedText_590ab
	db $50
; 0x590ab + 5 bytes

Route6Script: ; 0x590b0
	call $3c3c
	ld hl, Route6TrainerHeaders
	ld de, Route6_Unknown590c3
	ld a, [$d600]
	call $3160
	ld [$d600], a
	ret
; 0x590c3

Route6_Unknown590c3: ; 0x590c3
INCBIN "baserom.gbc",$590c3,$590c9 - $590c3

Route6Texts:
	dw Route6Text1, Route6Text2, Route6Text3, Route6Text4, Route6Text5, Route6Text6, Route6Text7

Route6TrainerHeaders:
Route6TrainerHeader0: ; 0x590d7
	db $1 ; flag's bit
	db ($0 << 4) ; trainer's view range
	dw $d7c9 ; flag's byte
	dw Route6BattleText1 ; 0x512a TextBeforeBattle
	dw Route6AfterBattleText1 ; 0x5134 TextAfterBattle
	dw Route6EndBattleText1 ; 0x512f TextEndBattle
	dw Route6EndBattleText1 ; 0x512f TextEndBattle
; 0x590e3

Route6TrainerHeader1: ; 0x590e3
	db $2 ; flag's bit
	db ($0 << 4) ; trainer's view range
	dw $d7c9 ; flag's byte
	dw Route6BattleText2 ; 0x5143 TextBeforeBattle
	dw Route6AfterBattleText1 ; 0x5134 TextAfterBattle
	dw Route6EndBattleText2 ; 0x5148 TextEndBattle
	dw Route6EndBattleText2 ; 0x5148 TextEndBattle
; 0x590ef

Route6TrainerHeader2: ; 0x590ef
	db $3 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d7c9 ; flag's byte
	dw Route6BattleText3 ; 0x5157 TextBeforeBattle
	dw Route6AfterBattleText3 ; 0x5161 TextAfterBattle
	dw Route6EndBattleText3 ; 0x515c TextEndBattle
	dw Route6EndBattleText3 ; 0x515c TextEndBattle
; 0x590fb

Route6TrainerHeader3: ; 0x590fb
	db $4 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d7c9 ; flag's byte
	dw Route6BattleText4 ; 0x5170 TextBeforeBattle
	dw Route6AfterBattleText4 ; 0x517a TextAfterBattle
	dw Route6EndBattleText4 ; 0x5175 TextEndBattle
	dw Route6EndBattleText4 ; 0x5175 TextEndBattle
; 0x59107

Route6TrainerHeader4: ; 0x59107
	db $5 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d7c9 ; flag's byte
	dw Route6BattleText5 ; 0x5189 TextBeforeBattle
	dw Route6AfterBattleText5 ; 0x5193 TextAfterBattle
	dw Route6EndBattleText5 ; 0x518e TextEndBattle
	dw Route6EndBattleText5 ; 0x518e TextEndBattle
; 0x59113

Route6TrainerHeader5: ; 0x59113
	db $6 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d7c9 ; flag's byte
	dw Route6BattleText6 ; 0x51a2 TextBeforeBattle
	dw Route6AfterBattleText6 ; 0x51ac TextAfterBattle
	dw Route6EndBattleText6 ; 0x51a7 TextEndBattle
	dw Route6EndBattleText6 ; 0x51a7 TextEndBattle
; 0x5911e

db $ff

Route6Text1: ; 0x59120
	db $8
	ld hl, Route6TrainerHeader0
	call LoadTrainerHeader
	jp TextScriptEnd
; 0x5912a

Route6BattleText1: ; 0x5912a
	TX_FAR _Route6BattleText1
	db $50
; 0x5912a + 5 bytes

Route6EndBattleText1: ; 0x5912f
	TX_FAR _Route6EndBattleText1
	db $50
; 0x5912f + 5 bytes

Route6AfterBattleText1: ; 0x59134
	TX_FAR _Route6AfterBattleText1
	db $50
; 0x59134 + 5 bytes

Route6Text2: ; 0x59139
	db $08 ; asm
	ld hl, Route6TrainerHeader1
	call LoadTrainerHeader
	jp TextScriptEnd

Route6BattleText2: ; 0x59143
	TX_FAR _Route6BattleText2
	db $50
; 0x59143 + 5 bytes

Route6EndBattleText2: ; 0x59148
	TX_FAR _Route6EndBattleText2
	db $50
; 0x59148 + 5 bytes

Route6Text3: ; 0x5914d
	db $08 ; asm
	ld hl, Route6TrainerHeader2
	call LoadTrainerHeader
	jp TextScriptEnd

Route6BattleText3: ; 0x59157
	TX_FAR _Route6BattleText3
	db $50
; 0x59157 + 5 bytes

Route6EndBattleText3: ; 0x5915c
	TX_FAR _Route6EndBattleText3
	db $50
; 0x5915c + 5 bytes

Route6AfterBattleText3: ; 0x59161
	TX_FAR _Route6AfterBattleText3
	db $50
; 0x59161 + 5 bytes

Route6Text4: ; 0x59166
	db $08 ; asm
	ld hl, Route6TrainerHeader3
	call LoadTrainerHeader
	jp TextScriptEnd

Route6BattleText4: ; 0x59170
	TX_FAR _Route6BattleText4
	db $50
; 0x59170 + 5 bytes

Route6EndBattleText4: ; 0x59175
	TX_FAR _Route6EndBattleText4
	db $50
; 0x59175 + 5 bytes

Route6AfterBattleText4: ; 0x5917a
	TX_FAR _Route6AfterBattleText4
	db $50
; 0x5917a + 5 bytes

Route6Text5: ; 0x5917f
	db $08 ; asm
	ld hl, Route6TrainerHeader4
	call LoadTrainerHeader
	jp TextScriptEnd

Route6BattleText5: ; 0x59189
	TX_FAR _Route6BattleText5
	db $50
; 0x59189 + 5 bytes

Route6EndBattleText5: ; 0x5918e
	TX_FAR _Route6EndBattleText5
	db $50
; 0x5918e + 5 bytes

Route6AfterBattleText5: ; 0x59193
	TX_FAR _Route6AfterBattleText5
	db $50
; 0x59193 + 5 bytes

Route6Text6: ; 0x59198
	db $08 ; asm
	ld hl, Route6TrainerHeader5
	call LoadTrainerHeader
	jp TextScriptEnd

Route6BattleText6: ; 0x591a2
	TX_FAR _Route6BattleText6
	db $50
; 0x591a2 + 5 bytes

Route6EndBattleText6: ; 0x591a7
	TX_FAR _Route6EndBattleText6
	db $50
; 0x591a7 + 5 bytes

Route6AfterBattleText6: ; 0x591ac
	TX_FAR _Route6AfterBattleText6
	db $50
; 0x591ac + 5 bytes

Route6Text7: ; 0x591b1
	TX_FAR _Route6Text7
	db $50

Route8Script: ; 0x591b6
	call $3c3c
	ld hl, Route8TrainerHeaders
	ld de, Route8_Unknown591c9
	ld a, [$d601]
	call $3160
	ld [$d601], a
	ret
; 0x591c9

Route8_Unknown591c9: ; 0x591c9
INCBIN "baserom.gbc",$591c9,$591cf - $591c9

Route8Texts: ; 0x591cf
	dw Route8Text1, Route8Text2, Route8Text3, Route8Text4, Route8Text5, Route8Text6, Route8Text7, Route8Text8, Route8Text9, Route8Text10

Route8TrainerHeaders: ; 0x591e3
Route8TrainerHeader0: ; 0x591e3
	db $1 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d7cd ; flag's byte
	dw Route8BattleText1 ; 0x525a TextBeforeBattle
	dw Route8AfterBattleText1 ; 0x5264 TextAfterBattle
	dw Route8EndBattleText1 ; 0x525f TextEndBattle
	dw Route8EndBattleText1 ; 0x525f TextEndBattle
; 0x591ef

Route8TrainerHeader1: ; 0x591ef
	db $2 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d7cd ; flag's byte
	dw Route8BattleText2 ; 0x5273 TextBeforeBattle
	dw Route8AfterBattleText2 ; 0x527d TextAfterBattle
	dw Route8EndBattleText2 ; 0x5278 TextEndBattle
	dw Route8EndBattleText2 ; 0x5278 TextEndBattle
; 0x591fb

Route8TrainerHeader2: ; 0x591fb
	db $3 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d7cd ; flag's byte
	dw Route8BattleText3 ; 0x528c TextBeforeBattle
	dw Route8AfterBattleText3 ; 0x5296 TextAfterBattle
	dw Route8EndBattleText3 ; 0x5291 TextEndBattle
	dw Route8EndBattleText3 ; 0x5291 TextEndBattle
; 0x59207

Route8TrainerHeader3: ; 0x59207
	db $4 ; flag's bit
	db ($2 << 4) ; trainer's view range
	dw $d7cd ; flag's byte
	dw Route8BattleText4 ; 0x52a5 TextBeforeBattle
	dw Route8AfterBattleText4 ; 0x52af TextAfterBattle
	dw Route8EndBattleText4 ; 0x52aa TextEndBattle
	dw Route8EndBattleText4 ; 0x52aa TextEndBattle
; 0x59213

Route8TrainerHeader4: ; 0x59213
	db $5 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d7cd ; flag's byte
	dw Route8BattleText5 ; 0x52be TextBeforeBattle
	dw Route8AfterBattleText5 ; 0x52c8 TextAfterBattle
	dw Route8EndBattleText5 ; 0x52c3 TextEndBattle
	dw Route8EndBattleText5 ; 0x52c3 TextEndBattle
; 0x5921f

Route8TrainerHeader5: ; 0x5921f
	db $6 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d7cd ; flag's byte
	dw Route8BattleText6 ; 0x52d7 TextBeforeBattle
	dw Route8AfterBattleText6 ; 0x52e1 TextAfterBattle
	dw Route8EndBattleText6 ; 0x52dc TextEndBattle
	dw Route8EndBattleText6 ; 0x52dc TextEndBattle
; 0x5922b

Route8TrainerHeader6: ; 0x5922b
	db $7 ; flag's bit
	db ($2 << 4) ; trainer's view range
	dw $d7cd ; flag's byte
	dw Route8BattleText7 ; 0x52f0 TextBeforeBattle
	dw Route8AfterBattleText7 ; 0x52fa TextAfterBattle
	dw Route8EndBattleText7 ; 0x52f5 TextEndBattle
	dw Route8EndBattleText7 ; 0x52f5 TextEndBattle
; 0x59237

Route8TrainerHeader7: ; 0x59237
	db $8 ; flag's bit
	db ($2 << 4) ; trainer's view range
	dw $d7cd ; flag's byte
	dw Route8BattleText8 ; 0x5309 TextBeforeBattle
	dw Route8AfterBattleText8 ; 0x5313 TextAfterBattle
	dw Route8EndBattleText8 ; 0x530e TextEndBattle
	dw Route8EndBattleText8 ; 0x530e TextEndBattle
; 0x59243

Route8TrainerHeader8: ; 0x59243
	db $9 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d7cd ; flag's byte
	dw Route8BattleText9 ; 0x5322 TextBeforeBattle
	dw Route8AfterBattleText9 ; 0x532c TextAfterBattle
	dw Route8EndBattleText9 ; 0x5327 TextEndBattle
	dw Route8EndBattleText9 ; 0x5327 TextEndBattle
; 0x5924e

db $ff

Route8Text1: ; 0x59250
	db $8
	ld hl, Route8TrainerHeader0
	call LoadTrainerHeader
	jp TextScriptEnd
; 0x5925a

Route8BattleText1: ; 0x5925a
	TX_FAR _Route8BattleText1
	db $50
; 0x5925f

Route8EndBattleText1: ; 0x5925f
	TX_FAR _Route8EndBattleText1
	db $50
; 0x5925f + 5 bytes

Route8AfterBattleText1: ; 0x59264
	TX_FAR _Route8AfterBattleText1
	db $50
; 0x59264 + 5 bytes

Route8Text2: ; 0x59269
	db $08 ; asm
	ld hl, Route8TrainerHeader1
	call LoadTrainerHeader
	jp TextScriptEnd

Route8BattleText2: ; 0x59273
	TX_FAR _Route8BattleText2
	db $50
; 0x59273 + 5 bytes

Route8EndBattleText2: ; 0x59278
	TX_FAR _Route8EndBattleText2
	db $50
; 0x59278 + 5 bytes

Route8AfterBattleText2: ; 0x5927d
	TX_FAR _Route8AfterBattleText2
	db $50
; 0x5927d + 5 bytes

Route8Text3: ; 0x59282
	db $08 ; asm
	ld hl, Route8TrainerHeader2
	call LoadTrainerHeader
	jp TextScriptEnd

Route8BattleText3: ; 0x5928c
	TX_FAR _Route8BattleText3
	db $50
; 0x5928c + 5 bytes

Route8EndBattleText3: ; 0x59291
	TX_FAR _Route8EndBattleText3
	db $50
; 0x59291 + 5 bytes

Route8AfterBattleText3: ; 0x59296
	TX_FAR _Route8AfterBattleText3
	db $50
; 0x59296 + 5 bytes

Route8Text4: ; 0x5929b
	db $08 ; asm
	ld hl, Route8TrainerHeader3
	call LoadTrainerHeader
	jp TextScriptEnd

Route8BattleText4: ; 0x592a5
	TX_FAR _Route8BattleText4
	db $50
; 0x592a5 + 5 bytes

Route8EndBattleText4: ; 0x592aa
	TX_FAR _Route8EndBattleText4
	db $50
; 0x592aa + 5 bytes

Route8AfterBattleText4: ; 0x592af
	TX_FAR _Route8AfterBattleText4
	db $50
; 0x592af + 5 bytes

Route8Text5: ; 0x592b4
	db $08 ; asm
	ld hl, Route8TrainerHeader4
	call LoadTrainerHeader
	jp TextScriptEnd

Route8BattleText5: ; 0x592be
	TX_FAR _Route8BattleText5
	db $50
; 0x592be + 5 bytes

Route8EndBattleText5: ; 0x592c3
	TX_FAR _Route8EndBattleText5
	db $50
; 0x592c3 + 5 bytes

Route8AfterBattleText5: ; 0x592c8
	TX_FAR _Route8AfterBattleText5
	db $50
; 0x592c8 + 5 bytes

Route8Text6: ; 0x592cd
	db $08 ; asm
	ld hl, Route8TrainerHeader5
	call LoadTrainerHeader
	jp TextScriptEnd

Route8BattleText6: ; 0x592d7
	TX_FAR _Route8BattleText6
	db $50
; 0x592d7 + 5 bytes

Route8EndBattleText6: ; 0x592dc
	TX_FAR _Route8EndBattleText6
	db $50
; 0x592dc + 5 bytes

Route8AfterBattleText6: ; 0x592e1
	TX_FAR _Route8AfterBattleText6
	db $50
; 0x592e1 + 5 bytes

Route8Text7: ; 0x592e6
	db $08 ; asm
	ld hl, Route8TrainerHeader6
	call LoadTrainerHeader
	jp TextScriptEnd

Route8BattleText7: ; 0x592f0
	TX_FAR _Route8BattleText7
	db $50
; 0x592f0 + 5 bytes

Route8EndBattleText7: ; 0x592f5
	TX_FAR _Route8EndBattleText7
	db $50
; 0x592f5 + 5 bytes

Route8AfterBattleText7: ; 0x592fa
	TX_FAR _Route8AfterBattleText7
	db $50
; 0x592fa + 5 bytes

Route8Text8: ; 0x592ff
	db $08 ; asm
	ld hl, Route8TrainerHeader7
	call LoadTrainerHeader
	jp TextScriptEnd

Route8BattleText8: ; 0x59309
	TX_FAR _Route8BattleText8
	db $50
; 0x59309 + 5 bytes

Route8EndBattleText8: ; 0x5930e
	TX_FAR _Route8EndBattleText8
	db $50
; 0x5930e + 5 bytes

Route8AfterBattleText8: ; 0x59313
	TX_FAR _Route8AfterBattleText8
	db $50
; 0x59313 + 5 bytes

Route8Text9: ; 0x59318
	db $08 ; asm
	ld hl, Route8TrainerHeader8
	call LoadTrainerHeader
	jp TextScriptEnd

Route8BattleText9: ; 0x59322
	TX_FAR _Route8BattleText9
	db $50
; 0x59322 + 5 bytes

Route8EndBattleText9: ; 0x59327
	TX_FAR _Route8EndBattleText9
	db $50
; 0x59327 + 5 bytes

Route8AfterBattleText9: ; 0x5932c
	TX_FAR _Route8AfterBattleText9
	db $50
; 0x5932c + 5 bytes

Route8Text10: ; 0x59331
	TX_FAR _Route8Text10
	db $50

Route10Script: ; 0x59336
	call $3c3c
	ld hl, Route10TrainerHeaders
	ld de, Route10_Unknown59349
	ld a, [$d605]
	call $3160
	ld [$d605], a
	ret
; 0x59349

Route10_Unknown59349: ; 0x59349
INCBIN "baserom.gbc",$59349,$6

Route10Texts: ; 0x5934f
	dw Route10Text1, Route10Text2, Route10Text3, Route10Text4, Route10Text5, Route10Text6, Route10Text7, Route10Text8, Route10Text9, Route10Text10

Route10TrainerHeaders:
Route10TrainerHeader0: ; 0x59363
	db $1 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d7d1 ; flag's byte
	dw Route10BattleText1 ; 0x53b6 TextBeforeBattle
	dw Route10AfterBattleText1 ; 0x53c0 TextAfterBattle
	dw Route10EndBattleText1 ; 0x53bb TextEndBattle
	dw Route10EndBattleText1 ; 0x53bb TextEndBattle
; 0x5936f

Route10TrainerHeader1: ; 0x5936f
	db $2 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d7d1 ; flag's byte
	dw Route10BattleText2 ; 0x53cf TextBeforeBattle
	dw Route10AfterBattleText2 ; 0x53d9 TextAfterBattle
	dw Route10EndBattleText2 ; 0x53d4 TextEndBattle
	dw Route10EndBattleText2 ; 0x53d4 TextEndBattle
; 0x5937b

Route10TrainerHeader2: ; 0x5937b
	db $3 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d7d1 ; flag's byte
	dw Route10BattleText3 ; 0x53e8 TextBeforeBattle
	dw Route10AfterBattleText3 ; 0x53f2 TextAfterBattle
	dw Route10EndBattleText3 ; 0x53ed TextEndBattle
	dw Route10EndBattleText3 ; 0x53ed TextEndBattle
; 0x59387

Route10TrainerHeader3: ; 0x59387
	db $4 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d7d1 ; flag's byte
	dw Route10BattleText4 ; 0x5401 TextBeforeBattle
	dw Route10AfterBattleText4 ; 0x540b TextAfterBattle
	dw Route10EndBattleText4 ; 0x5406 TextEndBattle
	dw Route10EndBattleText4 ; 0x5406 TextEndBattle
; 0x59393

Route10TrainerHeader4: ; 0x59393
	db $5 ; flag's bit
	db ($2 << 4) ; trainer's view range
	dw $d7d1 ; flag's byte
	dw Route10BattleText5 ; 0x541a TextBeforeBattle
	dw Route10AfterBattleText5 ; 0x5424 TextAfterBattle
	dw Route10EndBattleText5 ; 0x541f TextEndBattle
	dw Route10EndBattleText5 ; 0x541f TextEndBattle
; 0x5939f

Route10TrainerHeader5: ; 0x5939f
	db $6 ; flag's bit
	db ($2 << 4) ; trainer's view range
	dw $d7d1 ; flag's byte
	dw Route10BattleText6 ; 0x5433 TextBeforeBattle
	dw Route10AfterBattleText6 ; 0x543d TextAfterBattle
	dw Route10EndBattleText6 ; 0x5438 TextEndBattle
	dw Route10EndBattleText6 ; 0x5438 TextEndBattle
; 0x593ab

db $ff

Route10Text1: ; 0x593ac
	db $08 ; asm
	ld hl, Route10TrainerHeader0
	call LoadTrainerHeader
	jp TextScriptEnd

Route10BattleText1: ; 0x593b6
	TX_FAR _Route10BattleText1
	db $50
; 0x593b6 + 5 bytes

Route10EndBattleText1: ; 0x593bb
	TX_FAR _Route10EndBattleText1
	db $50
; 0x593bb + 5 bytes

Route10AfterBattleText1: ; 0x593c0
	TX_FAR _Route10AfterBattleText1
	db $50
; 0x593c0 + 5 bytes

Route10Text2: ; 0x593c5
	db $08 ; asm
	ld hl, Route10TrainerHeader1
	call LoadTrainerHeader
	jp TextScriptEnd

Route10BattleText2: ; 0x593cf
	TX_FAR _Route10BattleText2
	db $50
; 0x593cf + 5 bytes

Route10EndBattleText2: ; 0x593d4
	TX_FAR _Route10EndBattleText2
	db $50
; 0x593d4 + 5 bytes

Route10AfterBattleText2: ; 0x593d9
	TX_FAR _Route10AfterBattleText2
	db $50
; 0x593d9 + 5 bytes

Route10Text3: ; 0x593de
	db $08 ; asm
	ld hl, Route10TrainerHeader2
	call LoadTrainerHeader
	jp TextScriptEnd

Route10BattleText3: ; 0x593e8
	TX_FAR _Route10BattleText3
	db $50
; 0x593e8 + 5 bytes

Route10EndBattleText3: ; 0x593ed
	TX_FAR _Route10EndBattleText3
	db $50
; 0x593ed + 5 bytes

Route10AfterBattleText3: ; 0x593f2
	TX_FAR _Route10AfterBattleText3
	db $50
; 0x593f2 + 5 bytes

Route10Text4: ; 0x593f7
	db $08 ; asm
	ld hl, Route10TrainerHeader3
	call LoadTrainerHeader
	jp TextScriptEnd

Route10BattleText4: ; 0x59401
	TX_FAR _Route10BattleText4
	db $50
; 0x59401 + 5 bytes

Route10EndBattleText4: ; 0x59406
	TX_FAR _Route10EndBattleText4
	db $50
; 0x59406 + 5 bytes

Route10AfterBattleText4: ; 0x5940b
	TX_FAR _Route10AfterBattleText4
	db $50
; 0x5940b + 5 bytes

Route10Text5: ; 0x59410
	db $08 ; asm
	ld hl, Route10TrainerHeader4
	call LoadTrainerHeader
	jp TextScriptEnd

Route10BattleText5: ; 0x5941a
	TX_FAR _Route10BattleText5
	db $50
; 0x5941a + 5 bytes

Route10EndBattleText5: ; 0x5941f
	TX_FAR _Route10EndBattleText5
	db $50
; 0x5941f + 5 bytes

Route10AfterBattleText5: ; 0x59424
	TX_FAR _Route10AfterBattleText5
	db $50
; 0x59424 + 5 bytes

Route10Text6: ; 0x59429
	db $08 ; asm
	ld hl, Route10TrainerHeader5
	call LoadTrainerHeader
	jp TextScriptEnd

Route10BattleText6: ; 0x59433
	TX_FAR _Route10BattleText6
	db $50
; 0x59433 + 5 bytes

Route10EndBattleText6: ; 0x59438
	TX_FAR _Route10EndBattleText6
	db $50
; 0x59438 + 5 bytes

Route10AfterBattleText6: ; 0x5943d
	TX_FAR _Route10AfterBattleText6
	db $50
; 0x5943d + 5 bytes

Route10Text9: ; 0x59442
Route10Text7: ; 0x59442
	TX_FAR _Route10Text7 ; _Route10Text9
	db $50

Route10Text10: ; 0x59447
	TX_FAR _Route10Text10
	db $50

Route11Script: ; 0x5944c
	call $3c3c
	ld hl, Route11TrainerHeaders
	ld de, Route11_Unknown5945f
	ld a, [$d623]
	call $3160
	ld [$d623], a
	ret
; 0x5945f

Route11_Unknown5945f: ; 0x5945f
INCBIN "baserom.gbc",$5945f,$59465 - $5945f

Route11Texts: ; 0x59465
	dw UnnamedText_594f4, Route11Text2, Route11Text3, Route11Text4, Route11Text5, Route11Text6, Route11Text7, Route11Text8, Route11Text9, Route11Text10, Route11Text11

Route11TrainerHeaders:
Route11TrainerHeader0: ; 0x5947b
	db $1 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d7d5 ; flag's byte
	dw Route11BattleText1 ; 0x54fe TextBeforeBattle
	dw Route11AfterBattleText1 ; 0x5508 TextAfterBattle
	dw Route11EndBattleText1 ; 0x5503 TextEndBattle
	dw Route11EndBattleText1 ; 0x5503 TextEndBattle
; 0x59487

Route11TrainerHeader1: ; 0x59487
	db $2 ; flag's bit
	db ($2 << 4) ; trainer's view range
	dw $d7d5 ; flag's byte
	dw Route11BattleText2 ; 0x5517 TextBeforeBattle
	dw Route11AfterBattleText2 ; 0x5521 TextAfterBattle
	dw Route11EndBattleText2 ; 0x551c TextEndBattle
	dw Route11EndBattleText2 ; 0x551c TextEndBattle
; 0x59493

Route11TrainerHeader2: ; 0x59493
	db $3 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d7d5 ; flag's byte
	dw Route11BattleText3 ; 0x5530 TextBeforeBattle
	dw Route11AfterBattleText3 ; 0x553a TextAfterBattle
	dw Route11EndBattleText3 ; 0x5535 TextEndBattle
	dw Route11EndBattleText3 ; 0x5535 TextEndBattle
; 0x5949f

Route11TrainerHeader3: ; 0x5949f
	db $4 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d7d5 ; flag's byte
	dw Route11BattleText4 ; 0x5549 TextBeforeBattle
	dw Route11AfterBattleText4 ; 0x5553 TextAfterBattle
	dw Route11EndBattleText4 ; 0x554e TextEndBattle
	dw Route11EndBattleText4 ; 0x554e TextEndBattle
; 0x594ab

Route11TrainerHeader4: ; 0x594ab
	db $5 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d7d5 ; flag's byte
	dw Route11BattleText5 ; 0x5562 TextBeforeBattle
	dw Route11AfterBattleText5 ; 0x556c TextAfterBattle
	dw Route11EndBattleText5 ; 0x5567 TextEndBattle
	dw Route11EndBattleText5 ; 0x5567 TextEndBattle
; 0x594b7

Route11TrainerHeader5: ; 0x594b7
	db $6 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d7d5 ; flag's byte
	dw Route11BattleText6 ; 0x557b TextBeforeBattle
	dw Route11AfterBattleText6 ; 0x5585 TextAfterBattle
	dw Route11EndBattleText6 ; 0x5580 TextEndBattle
	dw Route11EndBattleText6 ; 0x5580 TextEndBattle
; 0x594c3

Route11TrainerHeader6: ; 0x594c3
	db $7 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d7d5 ; flag's byte
	dw Route11BattleText7 ; 0x5594 TextBeforeBattle
	dw Route11AfterBattleText7 ; 0x559e TextAfterBattle
	dw Route11EndBattleText7 ; 0x5599 TextEndBattle
	dw Route11EndBattleText7 ; 0x5599 TextEndBattle
; 0x594cf

Route11TrainerHeader7: ; 0x594cf
	db $8 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d7d5 ; flag's byte
	dw Route11BattleText8 ; 0x55ad TextBeforeBattle
	dw Route11AfterBattleText8 ; 0x55b7 TextAfterBattle
	dw Route11EndBattleText8 ; 0x55b2 TextEndBattle
	dw Route11EndBattleText8 ; 0x55b2 TextEndBattle
; 0x594db

Route11TrainerHeader8: ; 0x594db
	db $9 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d7d5 ; flag's byte
	dw Route11BattleText9 ; 0x55c6 TextBeforeBattle
	dw Route11AfterBattleText9 ; 0x55d0 TextAfterBattle
	dw Route11EndBattleText9 ; 0x55cb TextEndBattle
	dw Route11EndBattleText9 ; 0x55cb TextEndBattle
; 0x594e7

Route11TrainerHeader9: ; 0x594e7
	db $a ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d7d5 ; flag's byte
	dw Route11BattleText10 ; 0x55df TextBeforeBattle
	dw Route11AfterBattleText10 ; 0x55e9 TextAfterBattle
	dw Route11EndBattleText10 ; 0x55e4 TextEndBattle
	dw Route11EndBattleText10 ; 0x55e4 TextEndBattle
; 0x594f3

db $ff

UnnamedText_594f4: ; 0x594f4
	db $8
	ld hl, Route11TrainerHeader0
	call LoadTrainerHeader
	jp TextScriptEnd
; 0x594fe

Route11BattleText1: ; 0x594fe
	TX_FAR _Route11BattleText1
	db $50
; 0x594fe + 5 bytes

Route11EndBattleText1: ; 0x59503
	TX_FAR _Route11EndBattleText1
	db $50
; 0x59503 + 5 bytes

Route11AfterBattleText1: ; 0x59508
	TX_FAR _Route11AfterBattleText1
	db $50
; 0x59508 + 5 bytes

Route11Text2: ; 0x5950d
	db $08 ; asm
	ld hl, Route11TrainerHeader1
	call LoadTrainerHeader
	jp TextScriptEnd

Route11BattleText2: ; 0x59517
	TX_FAR _Route11BattleText2
	db $50
; 0x59517 + 5 bytes

Route11EndBattleText2: ; 0x5951c
	TX_FAR _Route11EndBattleText2
	db $50
; 0x5951c + 5 bytes

Route11AfterBattleText2: ; 0x59521
	TX_FAR _Route11AfterBattleText2
	db $50
; 0x59521 + 5 bytes

Route11Text3: ; 0x59526
	db $08 ; asm
	ld hl, Route11TrainerHeader2
	call LoadTrainerHeader
	jp TextScriptEnd

Route11BattleText3: ; 0x59530
	TX_FAR _Route11BattleText3
	db $50
; 0x59530 + 5 bytes

Route11EndBattleText3: ; 0x59535
	TX_FAR _Route11EndBattleText3
	db $50
; 0x59535 + 5 bytes

Route11AfterBattleText3: ; 0x5953a
	TX_FAR _Route11AfterBattleText3
	db $50
; 0x5953a + 5 bytes

Route11Text4: ; 0x5953f
	db $08 ; asm
	ld hl, Route11TrainerHeader3
	call LoadTrainerHeader
	jp TextScriptEnd

Route11BattleText4: ; 0x59549
	TX_FAR _Route11BattleText4
	db $50
; 0x59549 + 5 bytes

Route11EndBattleText4: ; 0x5954e
	TX_FAR _Route11EndBattleText4
	db $50
; 0x5954e + 5 bytes

Route11AfterBattleText4: ; 0x59553
	TX_FAR _Route11AfterBattleText4
	db $50
; 0x59553 + 5 bytes

Route11Text5: ; 0x59558
	db $08 ; asm
	ld hl, Route11TrainerHeader4
	call LoadTrainerHeader
	jp TextScriptEnd

Route11BattleText5: ; 0x59562
	TX_FAR _Route11BattleText5
	db $50
; 0x59562 + 5 bytes

Route11EndBattleText5: ; 0x59567
	TX_FAR _Route11EndBattleText5
	db $50
; 0x59567 + 5 bytes

Route11AfterBattleText5: ; 0x5956c
	TX_FAR _Route11AfterBattleText5
	db $50
; 0x5956c + 5 bytes

Route11Text6: ; 0x59571
	db $08 ; asm
	ld hl, Route11TrainerHeader5
	call LoadTrainerHeader
	jp TextScriptEnd

Route11BattleText6: ; 0x5957b
	TX_FAR _Route11BattleText6
	db $50
; 0x5957b + 5 bytes

Route11EndBattleText6: ; 0x59580
	TX_FAR _Route11EndBattleText6
	db $50
; 0x59580 + 5 bytes

Route11AfterBattleText6: ; 0x59585
	TX_FAR _Route11AfterBattleText6
	db $50
; 0x59585 + 5 bytes

Route11Text7: ; 0x5958a
	db $08 ; asm
	ld hl, Route11TrainerHeader6
	call LoadTrainerHeader
	jp TextScriptEnd

Route11BattleText7: ; 0x59594
	TX_FAR _Route11BattleText7
	db $50
; 0x59594 + 5 bytes

Route11EndBattleText7: ; 0x59599
	TX_FAR _Route11EndBattleText7
	db $50
; 0x59599 + 5 bytes

Route11AfterBattleText7: ; 0x5959e
	TX_FAR _Route11AfterBattleText7
	db $50
; 0x5959e + 5 bytes

Route11Text8: ; 0x595a3
	db $08 ; asm
	ld hl, Route11TrainerHeader7
	call LoadTrainerHeader
	jp TextScriptEnd

Route11BattleText8: ; 0x595ad
	TX_FAR _Route11BattleText8
	db $50
; 0x595ad + 5 bytes

Route11EndBattleText8: ; 0x595b2
	TX_FAR _Route11EndBattleText8
	db $50
; 0x595b2 + 5 bytes

Route11AfterBattleText8: ; 0x595b7
	TX_FAR _Route11AfterBattleText8
	db $50
; 0x595b7 + 5 bytes

Route11Text9: ; 0x595bc
	db $08 ; asm
	ld hl, Route11TrainerHeader8
	call LoadTrainerHeader
	jp TextScriptEnd

Route11BattleText9: ; 0x595c6
	TX_FAR _Route11BattleText9
	db $50
; 0x595c6 + 5 bytes

Route11EndBattleText9: ; 0x595cb
	TX_FAR _Route11EndBattleText9
	db $50
; 0x595cb + 5 bytes

Route11AfterBattleText9: ; 0x595d0
	TX_FAR _Route11AfterBattleText9
	db $50
; 0x595d0 + 5 bytes

Route11Text10: ; 0x595d5
	db $08 ; asm
	ld hl, Route11TrainerHeader9
	call LoadTrainerHeader
	jp TextScriptEnd

Route11BattleText10: ; 0x595df
	TX_FAR _Route11BattleText10
	db $50
; 0x595df + 5 bytes

Route11EndBattleText10: ; 0x595e4
	TX_FAR _Route11EndBattleText10
	db $50
; 0x595e4 + 5 bytes

Route11AfterBattleText10: ; 0x595e9
	TX_FAR _Route11AfterBattleText10
	db $50
; 0x595e9 + 5 bytes

Route11Text11: ; 0x595ee
	TX_FAR _Route11Text11
	db $50

Route12Script: ; 0x595f3
	call $3c3c
	ld hl, Route12TrainerHeaders
	ld de, $5611
	ld a, [$d624]
	call $3160
	ld [$d624], a
	ret
; 0x59606

INCBIN "baserom.gbc",$59606,$6f

Route12Texts: ; 0x59675
	dw Route12Text1, Route12Text2, Route12Text3, Route12Text4, Route12Text5, Route12Text6, Route12Text7, Route12Text8, Route12Text9, Route12Text10, Route12Text11, Route12Text12, Route12Text13, Route12Text14

Route12TrainerHeaders:
Route12TrainerHeader0: ; 0x59691
	db $2 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d7d7 ; flag's byte
	dw Route12BattleText1 ; 0x56ff TextBeforeBattle
	dw Route12AfterBattleText1 ; 0x5709 TextAfterBattle
	dw Route12EndBattleText1 ; 0x5704 TextEndBattle
	dw Route12EndBattleText1 ; 0x5704 TextEndBattle
; 0x5969d

Route12TrainerHeader1: ; 0x5969d
	db $3 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d7d7 ; flag's byte
	dw Route12BattleText2 ; 0x5718 TextBeforeBattle
	dw Route12AfterBattleText2 ; 0x5722 TextAfterBattle
	dw Route12EndBattleText2 ; 0x571d TextEndBattle
	dw Route12EndBattleText2 ; 0x571d TextEndBattle
; 0x596a9

Route12TrainerHeader2: ; 0x596a9
	db $4 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d7d7 ; flag's byte
	dw Route12BattleText3 ; 0x5731 TextBeforeBattle
	dw Route12AfterBattleText3 ; 0x573b TextAfterBattle
	dw Route12EndBattleText3 ; 0x5736 TextEndBattle
	dw Route12EndBattleText3 ; 0x5736 TextEndBattle
; 0x596b5

Route12TrainerHeader3: ; 0x596b5
	db $5 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d7d7 ; flag's byte
	dw Route12BattleText4 ; 0x574a TextBeforeBattle
	dw Route12AfterBattleText4 ; 0x5754 TextAfterBattle
	dw Route12EndBattleText4 ; 0x574f TextEndBattle
	dw Route12EndBattleText4 ; 0x574f TextEndBattle
; 0x596c1

Route12TrainerHeader4: ; 0x596c1
	db $6 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d7d7 ; flag's byte
	dw Route12BattleText5 ; 0x5763 TextBeforeBattle
	dw Route12AfterBattleText5 ; 0x576d TextAfterBattle
	dw Route12EndBattleText5 ; 0x5768 TextEndBattle
	dw Route12EndBattleText5 ; 0x5768 TextEndBattle
; 0x596cd

Route12TrainerHeader5: ; 0x596cd
	db $7 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d7d7 ; flag's byte
	dw Route12BattleText6 ; 0x577c TextBeforeBattle
	dw Route12AfterBattleText6 ; 0x5786 TextAfterBattle
	dw Route12EndBattleText6 ; 0x5781 TextEndBattle
	dw Route12EndBattleText6 ; 0x5781 TextEndBattle
; 0x596d9

Route12TrainerHeader6: ; 0x596d9
	db $8 ; flag's bit
	db ($1 << 4) ; trainer's view range
	dw $d7d7 ; flag's byte
	dw Route12BattleText7 ; 0x5795 TextBeforeBattle
	dw Route12AfterBattleText7 ; 0x579f TextAfterBattle
	dw Route12EndBattleText7 ; 0x579a TextEndBattle
	dw Route12EndBattleText7 ; 0x579a TextEndBattle
; 0x596e5

db $ff

Route12Text1: ; 0x596e6
	TX_FAR _Route12Text1
	db $50

Route12Text13:
UnnamedText_596eb: ; 0x596eb
	TX_FAR _UnnamedText_596eb
	db $50
; 0x596eb + 5 bytes

Route12Text14:
UnnamedText_596f0: ; 0x596f0
	TX_FAR _UnnamedText_596f0
	db $50
; 0x596f0 + 5 bytes

Route12Text2: ; 0x596f5
	db $08 ; asm
	ld hl, Route12TrainerHeader0
	call LoadTrainerHeader
	jp TextScriptEnd

Route12BattleText1: ; 0x596ff
	TX_FAR _Route12BattleText1
	db $50
; 0x596ff + 5 bytes

Route12EndBattleText1: ; 0x59704
	TX_FAR _Route12EndBattleText1
	db $50
; 0x59704 + 5 bytes

Route12AfterBattleText1: ; 0x59709
	TX_FAR _Route12AfterBattleText1
	db $50
; 0x59709 + 5 bytes

Route12Text3: ; 0x5970e
	db $08 ; asm
	ld hl, Route12TrainerHeader1
	call LoadTrainerHeader
	jp TextScriptEnd

Route12BattleText2: ; 0x59718
	TX_FAR _Route12BattleText2
	db $50
; 0x59718 + 5 bytes

Route12EndBattleText2: ; 0x5971d
	TX_FAR _Route12EndBattleText2
	db $50
; 0x5971d + 5 bytes

Route12AfterBattleText2: ; 0x59722
	TX_FAR _Route12AfterBattleText2
	db $50
; 0x59722 + 5 bytes

Route12Text4: ; 0x59727
	db $08 ; asm
	ld hl, Route12TrainerHeader2
	call LoadTrainerHeader
	jp TextScriptEnd

Route12BattleText3: ; 0x59731
	TX_FAR _Route12BattleText3
	db $50
; 0x59731 + 5 bytes

Route12EndBattleText3: ; 0x59736
	TX_FAR _Route12EndBattleText3
	db $50
; 0x59736 + 5 bytes

Route12AfterBattleText3: ; 0x5973b
	TX_FAR _Route12AfterBattleText3
	db $50
; 0x5973b + 5 bytes

Route12Text5: ; 0x59740
	db $08 ; asm
	ld hl, Route12TrainerHeader3
	call LoadTrainerHeader
	jp TextScriptEnd

Route12BattleText4: ; 0x5974a
	TX_FAR _Route12BattleText4
	db $50
; 0x5974a + 5 bytes

Route12EndBattleText4: ; 0x5974f
	TX_FAR _Route12EndBattleText4
	db $50
; 0x5974f + 5 bytes

Route12AfterBattleText4: ; 0x59754
	TX_FAR _Route12AfterBattleText4
	db $50
; 0x59754 + 5 bytes

Route12Text6: ; 0x59759
	db $08 ; asm
	ld hl, Route12TrainerHeader4
	call LoadTrainerHeader
	jp TextScriptEnd

Route12BattleText5: ; 0x59763
	TX_FAR _Route12BattleText5
	db $50
; 0x59763 + 5 bytes

Route12EndBattleText5: ; 0x59768
	TX_FAR _Route12EndBattleText5
	db $50
; 0x59768 + 5 bytes

Route12AfterBattleText5: ; 0x5976d
	TX_FAR _Route12AfterBattleText5
	db $50
; 0x5976d + 5 bytes

Route12Text7: ; 0x59772
	db $08 ; asm
	ld hl, Route12TrainerHeader5
	call LoadTrainerHeader
	jp TextScriptEnd

Route12BattleText6: ; 0x5977c
	TX_FAR _Route12BattleText6
	db $50
; 0x5977c + 5 bytes

Route12EndBattleText6: ; 0x59781
	TX_FAR _Route12EndBattleText6
	db $50
; 0x59781 + 5 bytes

Route12AfterBattleText6: ; 0x59786
	TX_FAR _Route12AfterBattleText6
	db $50
; 0x59786 + 5 bytes

Route12Text8: ; 0x5978b
	db $08 ; asm
	ld hl, Route12TrainerHeader6
	call LoadTrainerHeader
	jp TextScriptEnd

Route12BattleText7: ; 0x59795
	TX_FAR _Route12BattleText7
	db $50
; 0x59795 + 5 bytes

Route12EndBattleText7: ; 0x5979a
	TX_FAR _Route12EndBattleText7
	db $50
; 0x5979a + 5 bytes

Route12AfterBattleText7: ; 0x5979f
	TX_FAR _Route12AfterBattleText7
	db $50
; 0x5979f + 5 bytes

Route12Text11: ; 0x597a4
	TX_FAR _Route12Text11
	db $50

Route12Text12: ; 0x597a9
	TX_FAR _Route12Text12
	db $50

Route15Script: ; 0x597ae
	call $3c3c
	ld hl, Route15TrainerHeaders
	ld de, Route15_Unknown597c1
	ld a, [$d625]
	call $3160
	ld [$d625], a
	ret
; 0x597c1

Route15_Unknown597c1: ; 0x597c1
INCBIN "baserom.gbc",$597c1,$6

Route15Texts: ; 0x597c7
	dw Route15Text1, Route15Text2, Route15Text3, Route15Text4, Route15Text5, Route15Text6, Route15Text7, Route15Text8, Route15Text9, Route15Text10, Route15Text11, Route15Text12

Route15TrainerHeaders:
Route15TrainerHeader0: ; 0x597df
	db $1 ; flag's bit
	db ($2 << 4) ; trainer's view range
	dw $d7dd ; flag's byte
	dw Route15BattleText1 ; 0x5898 TextBeforeBattle
	dw Route15AfterBattleText1 ; 0x58a2 TextAfterBattle
	dw Route15EndBattleText1 ; 0x589d TextEndBattle
	dw Route15EndBattleText1 ; 0x589d TextEndBattle
; 0x597eb

Route15TrainerHeader1: ; 0x597eb
	db $2 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d7dd ; flag's byte
	dw Route15BattleText2 ; 0x58a7 TextBeforeBattle
	dw Route15AfterBattleText2 ; 0x58b1 TextAfterBattle
	dw Route15EndBattleText2 ; 0x58ac TextEndBattle
	dw Route15EndBattleText2 ; 0x58ac TextEndBattle
; 0x597f7

Route15TrainerHeader2: ; 0x597f7
	db $3 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d7dd ; flag's byte
	dw Route15BattleText3 ; 0x58b6 TextBeforeBattle
	dw Route15AfterBattleText3 ; 0x58c0 TextAfterBattle
	dw Route15EndBattleText3 ; 0x58bb TextEndBattle
	dw Route15EndBattleText3 ; 0x58bb TextEndBattle
; 0x59803

Route15TrainerHeader3: ; 0x59803
	db $4 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d7dd ; flag's byte
	dw Route15BattleText4 ; 0x58c5 TextBeforeBattle
	dw Route15AfterBattleText4 ; 0x58cf TextAfterBattle
	dw Route15EndBattleText4 ; 0x58ca TextEndBattle
	dw Route15EndBattleText4 ; 0x58ca TextEndBattle
; 0x5980f

Route15TrainerHeader4: ; 0x5980f
	db $5 ; flag's bit
	db ($2 << 4) ; trainer's view range
	dw $d7dd ; flag's byte
	dw Route15BattleText5 ; 0x58d4 TextBeforeBattle
	dw Route15AfterBattleText5 ; 0x58de TextAfterBattle
	dw Route15EndBattleText5 ; 0x58d9 TextEndBattle
	dw Route15EndBattleText5 ; 0x58d9 TextEndBattle
; 0x5981b

Route15TrainerHeader5: ; 0x5981b
	db $6 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d7dd ; flag's byte
	dw Route15BattleText6 ; 0x58e3 TextBeforeBattle
	dw Route15AfterBattleText6 ; 0x58ed TextAfterBattle
	dw Route15EndBattleText6 ; 0x58e8 TextEndBattle
	dw Route15EndBattleText6 ; 0x58e8 TextEndBattle
; 0x59827

Route15TrainerHeader6: ; 0x59827
	db $7 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d7dd ; flag's byte
	dw Route15BattleText7 ; 0x58f2 TextBeforeBattle
	dw Route15AfterBattleText7 ; 0x58fc TextAfterBattle
	dw Route15EndBattleText7 ; 0x58f7 TextEndBattle
	dw Route15EndBattleText7 ; 0x58f7 TextEndBattle
; 0x59833

Route15TrainerHeader7: ; 0x59833
	db $8 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d7dd ; flag's byte
	dw Route15BattleText8 ; 0x5901 TextBeforeBattle
	dw Route15AfterBattleText8 ; 0x590b TextAfterBattle
	dw Route15EndBattleText8 ; 0x5906 TextEndBattle
	dw Route15EndBattleText8 ; 0x5906 TextEndBattle
; 0x5983f

Route15TrainerHeader8: ; 0x5983f
	db $9 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d7dd ; flag's byte
	dw Route15BattleText9 ; 0x5910 TextBeforeBattle
	dw Route15AfterBattleText9 ; 0x591a TextAfterBattle
	dw Route15EndBattleText9 ; 0x5915 TextEndBattle
	dw Route15EndBattleText9 ; 0x5915 TextEndBattle
; 0x5984b

Route15TrainerHeader9: ; 0x5984b
	db $a ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d7dd ; flag's byte
	dw Route15BattleText10 ; 0x591f TextBeforeBattle
	dw Route15AfterBattleText10 ; 0x5929 TextAfterBattle
	dw Route15EndBattleText10 ; 0x5924 TextEndBattle
	dw Route15EndBattleText10 ; 0x5924 TextEndBattle
; 0x59857

db $ff

Route15Text1: ; 0x59858
	db $8 ; asm
	ld hl, Route15TrainerHeader0
	jr asm_33cb7 ; 0x5985c $34

Route15Text2:
	db $8 ; asm
	ld hl, Route15TrainerHeader1
	jr asm_33cb7 ; 0x59862 $2e

Route15Text3:
	db $8 ; asm
	ld hl, Route15TrainerHeader2
	jr asm_33cb7 ; 0x59868 $28

Route15Text4:
	db $8 ; asm
	ld hl, Route15TrainerHeader3
	jr asm_33cb7 ; 0x5986e $22

Route15Text5:
	db $8 ; asm
	ld hl, Route15TrainerHeader4
	jr asm_33cb7 ; 0x59874 $1c

Route15Text6:
	db $8 ; asm
	ld hl, Route15TrainerHeader5
	jr asm_33cb7 ; 0x5987a $16

Route15Text7:
	db $8 ; asm
	ld hl, Route15TrainerHeader6
	jr asm_33cb7 ; 0x59880 $10

Route15Text8:
	db $8 ; asm
	ld hl, Route15TrainerHeader7
	jr asm_33cb7 ; 0x59886 $a

Route15Text9:
	db $8 ; asm
	ld hl, Route15TrainerHeader8
	jr asm_33cb7 ; 0x5988c $4

Route15Text10:
	db $8 ; asm
	ld hl, Route15TrainerHeader9
asm_33cb7: ; 0x59892
	call LoadTrainerHeader
	jp TextScriptEnd
; 0x59898

Route15BattleText1: ; 0x59898
	TX_FAR _Route15BattleText1
	db $50
; 0x59898 + 5 bytes

Route15EndBattleText1: ; 0x5989d
	TX_FAR _Route15EndBattleText1
	db $50
; 0x5989d + 5 bytes

Route15AfterBattleText1: ; 0x598a2
	TX_FAR _Route15AfterBattleText1
	db $50
; 0x598a2 + 5 bytes

Route15BattleText2: ; 0x598a7
	TX_FAR _Route15BattleText2
	db $50
; 0x598a7 + 5 bytes

Route15EndBattleText2: ; 0x598ac
	TX_FAR _Route15EndBattleText2
	db $50
; 0x598ac + 5 bytes

Route15AfterBattleText2: ; 0x598b1
	TX_FAR _Route15AfterBattleText2
	db $50
; 0x598b1 + 5 bytes

Route15BattleText3: ; 0x598b6
	TX_FAR _Route15BattleText3
	db $50
; 0x598b6 + 5 bytes

Route15EndBattleText3: ; 0x598bb
	TX_FAR _Route15EndBattleText3
	db $50
; 0x598bb + 5 bytes

Route15AfterBattleText3: ; 0x598c0
	TX_FAR _Route15AfterBattleText3
	db $50
; 0x598c0 + 5 bytes

Route15BattleText4: ; 0x598c5
	TX_FAR _Route15BattleText4
	db $50
; 0x598c5 + 5 bytes

Route15EndBattleText4: ; 0x598ca
	TX_FAR _Route15EndBattleText4
	db $50
; 0x598ca + 5 bytes

Route15AfterBattleText4: ; 0x598cf
	TX_FAR _Route15AfterBattleText4
	db $50
; 0x598cf + 5 bytes

Route15BattleText5: ; 0x598d4
	TX_FAR _Route15BattleText5
	db $50
; 0x598d4 + 5 bytes

Route15EndBattleText5: ; 0x598d9
	TX_FAR _Route15EndBattleText5
	db $50
; 0x598d9 + 5 bytes

Route15AfterBattleText5: ; 0x598de
	TX_FAR _Route15AfterBattleText5
	db $50
; 0x598de + 5 bytes

Route15BattleText6: ; 0x598e3
	TX_FAR _Route15BattleText6
	db $50
; 0x598e3 + 5 bytes

Route15EndBattleText6: ; 0x598e8
	TX_FAR _Route15EndBattleText6
	db $50
; 0x598e8 + 5 bytes

Route15AfterBattleText6: ; 0x598ed
	TX_FAR _Route15AfterBattleText6
	db $50
; 0x598ed + 5 bytes

Route15BattleText7: ; 0x598f2
	TX_FAR _Route15BattleText7
	db $50
; 0x598f2 + 5 bytes

Route15EndBattleText7: ; 0x598f7
	TX_FAR _Route15EndBattleText7
	db $50
; 0x598f7 + 5 bytes

Route15AfterBattleText7: ; 0x598fc
	TX_FAR _Route15AfterBattleText7
	db $50
; 0x598fc + 5 bytes

Route15BattleText8: ; 0x59901
	TX_FAR _Route15BattleText8
	db $50
; 0x59901 + 5 bytes

Route15EndBattleText8: ; 0x59906
	TX_FAR _Route15EndBattleText8
	db $50
; 0x59906 + 5 bytes

Route15AfterBattleText8: ; 0x5990b
	TX_FAR _Route15AfterBattleText8
	db $50
; 0x5990b + 5 bytes

Route15BattleText9: ; 0x59910
	TX_FAR _Route15BattleText9
	db $50
; 0x59910 + 5 bytes

Route15EndBattleText9: ; 0x59915
	TX_FAR _Route15EndBattleText9
	db $50
; 0x59915 + 5 bytes

Route15AfterBattleText9: ; 0x5991a
	TX_FAR _Route15AfterBattleText9
	db $50
; 0x5991a + 5 bytes

Route15BattleText10: ; 0x5991f
	TX_FAR _Route15BattleText10
	db $50
; 0x5991f + 5 bytes

Route15EndBattleText10: ; 0x59924
	TX_FAR _Route15EndBattleText10
	db $50
; 0x59924 + 5 bytes

Route15AfterBattleText10: ; 0x59929
	TX_FAR _Route15AfterBattleText10
	db $50
; 0x59929 + 5 bytes

Route15Text12: ; 0x5992e
	TX_FAR _Route15Text12
	db $50

Route16Script: ; 0x59933
	call $3c3c
	ld hl, Route16TrainerHeaders
	ld de, $5951
	ld a, [$d626]
	call $3160
	ld [$d626], a
	ret
; 0x59946

INCBIN "baserom.gbc",$59946,$73

Route16Texts: ; 0x599b9
	dw Route16Text1, Route16Text2, Route16Text3, Route16Text4, Route16Text5, Route16Text6, Route16Text7, Route16Text8, Route16Text9, Route16Text10, Route16Text11

Route16TrainerHeaders:
Route16TrainerHeader0: ; 0x599cf
	db $1 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d7df ; flag's byte
	dw Route16BattleText1 ; 0x5a22 TextBeforeBattle
	dw Route16AfterBattleText1 ; 0x5a2c TextAfterBattle
	dw Route16EndBattleText1 ; 0x5a27 TextEndBattle
	dw Route16EndBattleText1 ; 0x5a27 TextEndBattle
; 0x599db

Route16TrainerHeader1: ; 0x599db
	db $2 ; flag's bit
	db ($2 << 4) ; trainer's view range
	dw $d7df ; flag's byte
	dw Route16BattleText2 ; 0x5a3b TextBeforeBattle
	dw Route16AfterBattleText2 ; 0x5a45 TextAfterBattle
	dw Route16EndBattleText2 ; 0x5a40 TextEndBattle
	dw Route16EndBattleText2 ; 0x5a40 TextEndBattle
; 0x599e7

Route16TrainerHeader2: ; 0x599e7
	db $3 ; flag's bit
	db ($2 << 4) ; trainer's view range
	dw $d7df ; flag's byte
	dw Route16BattleText3 ; 0x5a54 TextBeforeBattle
	dw Route16AfterBattleText3 ; 0x5a5e TextAfterBattle
	dw Route16EndBattleText3 ; 0x5a59 TextEndBattle
	dw Route16EndBattleText3 ; 0x5a59 TextEndBattle
; 0x599f3

Route16TrainerHeader3: ; 0x599f3
	db $4 ; flag's bit
	db ($2 << 4) ; trainer's view range
	dw $d7df ; flag's byte
	dw Route16BattleText4 ; 0x5a6d TextBeforeBattle
	dw Route16AfterBattleText4 ; 0x5a77 TextAfterBattle
	dw Route16EndBattleText4 ; 0x5a72 TextEndBattle
	dw Route16EndBattleText4 ; 0x5a72 TextEndBattle
; 0x599ff

Route16TrainerHeader4: ; 0x599ff
	db $5 ; flag's bit
	db ($2 << 4) ; trainer's view range
	dw $d7df ; flag's byte
	dw Route16BattleText5 ; 0x5a86 TextBeforeBattle
	dw Route16AfterBattleText5 ; 0x5a90 TextAfterBattle
	dw Route16EndBattleText5 ; 0x5a8b TextEndBattle
	dw Route16EndBattleText5 ; 0x5a8b TextEndBattle
; 0x59a0b

Route16TrainerHeader5: ; 0x59a0b
	db $6 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d7df ; flag's byte
	dw Route16BattleText6 ; 0x5a9f TextBeforeBattle
	dw Route16AfterBattleText6 ; 0x5aa9 TextAfterBattle
	dw Route16EndBattleText6 ; 0x5aa4 TextEndBattle
	dw Route16EndBattleText6 ; 0x5aa4 TextEndBattle
; 0x59a17

db $ff

Route16Text1: ; 0x59a18
	db $08 ; asm
	ld hl, Route16TrainerHeader0
	call LoadTrainerHeader
	jp TextScriptEnd

Route16BattleText1: ; 0x59a22
	TX_FAR _Route16BattleText1
	db $50
; 0x59a22 + 5 bytes

Route16EndBattleText1: ; 0x59a27
	TX_FAR _Route16EndBattleText1
	db $50
; 0x59a27 + 5 bytes

Route16AfterBattleText1: ; 0x59a2c
	TX_FAR _Route16AfterBattleText1
	db $50
; 0x59a2c + 5 bytes

Route16Text2: ; 0x59a31
	db $08 ; asm
	ld hl, Route16TrainerHeader1
	call LoadTrainerHeader
	jp TextScriptEnd

Route16BattleText2: ; 0x59a3b
	TX_FAR _Route16BattleText2
	db $50
; 0x59a3b + 5 bytes

Route16EndBattleText2: ; 0x59a40
	TX_FAR _Route16EndBattleText2
	db $50
; 0x59a40 + 5 bytes

Route16AfterBattleText2: ; 0x59a45
	TX_FAR _Route16AfterBattleText2
	db $50
; 0x59a45 + 5 bytes

Route16Text3: ; 0x59a4a
	db $08 ; asm
	ld hl, Route16TrainerHeader2
	call LoadTrainerHeader
	jp TextScriptEnd

Route16BattleText3: ; 0x59a54
	TX_FAR _Route16BattleText3
	db $50
; 0x59a54 + 5 bytes

Route16EndBattleText3: ; 0x59a59
	TX_FAR _Route16EndBattleText3
	db $50
; 0x59a59 + 5 bytes

Route16AfterBattleText3: ; 0x59a5e
	TX_FAR _Route16AfterBattleText3
	db $50
; 0x59a5e + 5 bytes

Route16Text4: ; 0x59a63
	db $08 ; asm
	ld hl, Route16TrainerHeader3
	call LoadTrainerHeader
	jp TextScriptEnd

Route16BattleText4: ; 0x59a6d
	TX_FAR _Route16BattleText4
	db $50
; 0x59a6d + 5 bytes

Route16EndBattleText4: ; 0x59a72
	TX_FAR _Route16EndBattleText4
	db $50
; 0x59a72 + 5 bytes

Route16AfterBattleText4: ; 0x59a77
	TX_FAR _Route16AfterBattleText4
	db $50
; 0x59a77 + 5 bytes

Route16Text5: ; 0x59a7c
	db $08 ; asm
	ld hl, Route16TrainerHeader4
	call LoadTrainerHeader
	jp TextScriptEnd

Route16BattleText5: ; 0x59a86
	TX_FAR _Route16BattleText5
	db $50
; 0x59a86 + 5 bytes

Route16EndBattleText5: ; 0x59a8b
	TX_FAR _Route16EndBattleText5
	db $50
; 0x59a8b + 5 bytes

Route16AfterBattleText5: ; 0x59a90
	TX_FAR _Route16AfterBattleText5
	db $50
; 0x59a90 + 5 bytes

Route16Text6: ; 0x59a95
	db $08 ; asm
	ld hl, Route16TrainerHeader5
	call LoadTrainerHeader
	jp TextScriptEnd

Route16BattleText6: ; 0x59a9f
	TX_FAR _Route16BattleText6
	db $50
; 0x59a9f + 5 bytes

Route16EndBattleText6: ; 0x59aa4
	TX_FAR _Route16EndBattleText6
	db $50
; 0x59aa4 + 5 bytes

Route16AfterBattleText6: ; 0x59aa9
	TX_FAR _Route16AfterBattleText6
	db $50
; 0x59aa9 + 5 bytes

Route16Text7: ; 0x59aae
	TX_FAR _Route16Text7
	db $50

Route16Text10: ; 0x59ab3
	TX_FAR _UnnamedText_59ab3
	db $50
; 0x59ab3 + 5 bytes

Route16Text11: ; 0x59ab8
	TX_FAR _UnnamedText_59ab8
	db $50
; 0x59ab8 + 5 bytes

Route16Text8: ; 0x59abd
	TX_FAR _Route16Text8
	db $50

Route16Text9: ; 0x59ac2
	TX_FAR _Route16Text9
	db $50

Route18Script: ; 0x59ac7
	call $3c3c
	ld hl, Route18TrainerHeaders
	ld de, Route18_Unknown59ada
	ld a, [$d627]
	call $3160
	ld [$d627], a
	ret
; 0x59ada

Route18_Unknown59ada: ; 0x59ada
INCBIN "baserom.gbc",$59ada,$6

Route18Texts: ; 0x59ae0
	dw Route18Text1, Route18Text2, Route18Text3, Route18Text4, Route18Text5

Route18TrainerHeaders:
Route18TrainerHeader0: ; 0x59aea
	db $1 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d7e3 ; flag's byte
	dw Route18BattleText1 ; 0x5b19 TextBeforeBattle
	dw Route18AfterBattleText1 ; 0x5b23 TextAfterBattle
	dw Route18EndBattleText1 ; 0x5b1e TextEndBattle
	dw Route18EndBattleText1 ; 0x5b1e TextEndBattle
; 0x59af6

Route18TrainerHeader1: ; 0x59af6
	db $2 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d7e3 ; flag's byte
	dw Route18BattleText2 ; 0x5b32 TextBeforeBattle
	dw Route18AfterBattleText2 ; 0x5b3c TextAfterBattle
	dw Route18EndBattleText2 ; 0x5b37 TextEndBattle
	dw Route18EndBattleText2 ; 0x5b37 TextEndBattle
; 0x59b02

Route18TrainerHeader2: ; 0x59b02
	db $3 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d7e3 ; flag's byte
	dw Route18BattleText3 ; 0x5b4b TextBeforeBattle
	dw Route18AfterBattleText3 ; 0x5b55 TextAfterBattle
	dw Route18EndBattleText3 ; 0x5b50 TextEndBattle
	dw Route18EndBattleText3 ; 0x5b50 TextEndBattle
; 0x59b0e

db $ff

Route18Text1: ; 0x59b0f
	db $08 ; asm
	ld hl, Route18TrainerHeader0
	call LoadTrainerHeader
	jp TextScriptEnd

Route18BattleText1: ; 0x59b19
	TX_FAR _Route18BattleText1
	db $50
; 0x59b19 + 5 bytes

Route18EndBattleText1: ; 0x59b1e
	TX_FAR _Route18EndBattleText1
	db $50
; 0x59b1e + 5 bytes

Route18AfterBattleText1: ; 0x59b23
	TX_FAR _Route18AfterBattleText1
	db $50
; 0x59b23 + 5 bytes

Route18Text2: ; 0x59b28
	db $08 ; asm
	ld hl, Route18TrainerHeader1
	call LoadTrainerHeader
	jp TextScriptEnd

Route18BattleText2: ; 0x59b32
	TX_FAR _Route18BattleText2
	db $50
; 0x59b32 + 5 bytes

Route18EndBattleText2: ; 0x59b37
	TX_FAR _Route18EndBattleText2
	db $50
; 0x59b37 + 5 bytes

Route18AfterBattleText2: ; 0x59b3c
	TX_FAR _Route18AfterBattleText2
	db $50
; 0x59b3c + 5 bytes

Route18Text3: ; 0x59b41
	db $08 ; asm
	ld hl, Route18TrainerHeader2
	call LoadTrainerHeader
	jp TextScriptEnd

Route18BattleText3: ; 0x59b4b
	TX_FAR _Route18BattleText3
	db $50
; 0x59b4b + 5 bytes

Route18EndBattleText3: ; 0x59b50
	TX_FAR _Route18EndBattleText3
	db $50
; 0x59b50 + 5 bytes

Route18AfterBattleText3: ; 0x59b55
	TX_FAR _Route18AfterBattleText3
	db $50
; 0x59b55 + 5 bytes

Route18Text4: ; 0x59b5a
	TX_FAR _Route18Text4
	db $50

Route18Text5: ; 0x59b5f
	TX_FAR _Route18Text5
	db $50

FanClub_h: ; 0x59b64 to 0x59b70 (12 bytes) (id=90)
	db $10 ; tileset
	db POKEMON_FAN_CLUB_HEIGHT, POKEMON_FAN_CLUB_WIDTH ; dimensions (y, x)
	dw FanClubBlocks, FanClubTexts, FanClubScript ; blocks, texts, scripts
	db $00 ; connections

	dw FanClubObject ; objects

FanClubScript: ; 0x59b70
	jp $3c3c
; 0x59b73

INCBIN "baserom.gbc",$59b73,$11

FanClubTexts: ; 0x59b84
	dw FanClubText1, FanClubText2, FanClubText3, FanClubText4, FanClubText5, FanClubText6, FanClubText7, FanClubText8

FanClubText1: ; 0x59b94
	db $08 ; asm
	ld a, [$d771]
	bit 7, a
	jr nz, asm_67b22 ; 0x59b9a
	ld hl, UnnamedText_59bb7
	call PrintText
	ld hl, $d771
	set 6, [hl]
	jr asm_64f01 ; 0x59ba7
asm_67b22 ; 0x59ba9
	ld hl, UnnamedText_59bbc
	call PrintText
	ld hl, $d771
	res 7, [hl]
asm_64f01 ; 0x59bb4
	jp TextScriptEnd

UnnamedText_59bb7: ; 0x59bb7
	TX_FAR _UnnamedText_59bb7
	db $50
; 0x59bb7 + 5 bytes

UnnamedText_59bbc: ; 0x59bbc
	TX_FAR _UnnamedText_59bbc
	db $50
; 0x59bbc + 5 bytes

FanClubText2: ; 0x59bc1
	db $08 ; asm
	ld a, [$d771]
	bit 6, a
	jr nz, asm_5cd59 ; 0x59bc7
	ld hl, UnnamedText_59be4
	call PrintText
	ld hl, $d771
	set 7, [hl]
	jr asm_59625 ; 0x59bd4
asm_5cd59 ; 0x59bd6
	ld hl, UnnamedText_59be9
	call PrintText
	ld hl, $d771
	res 6, [hl]
asm_59625 ; 0x59be1
	jp TextScriptEnd

UnnamedText_59be4: ; 0x59be4
	TX_FAR _UnnamedText_59be4
	db $50
; 0x59be4 + 5 bytes

UnnamedText_59be9: ; 0x59be9
	TX_FAR _UnnamedText_59be9
	db $50
; 0x59be9 + 5 bytes

FanClubText3: ; 0x59bee
	db $8
	ld hl, UnnamedText_59c00
	call PrintText
	ld a, $54
	call $13d0
	call $3748
	jp TextScriptEnd
; 0x59c00

UnnamedText_59c00: ; 0x59c00
	TX_FAR _UnnamedText_59c00
	db $50
; 0x59c00 + 5 bytes

FanClubText4: ; 0x59c05
	db $08 ; asm
	ld hl, UnnamedText_59c17
	call PrintText
	ld a, SEEL
	call $13d0
	call $3748
	jp TextScriptEnd

UnnamedText_59c17: ; 0x59c17
	TX_FAR _UnnamedText_59c17
	db $50
; 0x59c17 + 5 bytes

FanClubText5: ; 0x59c1c
	db $08 ; asm
	call $5b73
	jr nz, asm_38bb3 ; 0x59c20
	ld hl, UnnamedText_59c65
	call PrintText
	call $35ec
	ld a, [$cc26]
	and a
	jr nz, asm_2c8d7 ; 0x59c2f
	ld hl, UnnamedText_59c6a
	call PrintText
	ld bc, (BIKE_VOUCHER << 8) | 1
	call GiveItem
	jr nc, asm_867d4 ; 0x59c3d
	ld hl, ReceivedBikeVoucherText
	call PrintText
	ld hl, $d771
	set 1, [hl]
	jr asm_d3c26 ; 0x59c4a
asm_867d4 ; 0x59c4c
	ld hl, UnnamedText_59c83
	call PrintText
	jr asm_d3c26 ; 0x59c52
asm_2c8d7 ; 0x59c54
	ld hl, UnnamedText_59c79
	call PrintText
	jr asm_d3c26 ; 0x59c5a
asm_38bb3 ; 0x59c5c
	ld hl, UnnamedText_59c7e
	call PrintText
asm_d3c26 ; 0x59c62
	jp TextScriptEnd

UnnamedText_59c65: ; 0x59c65
	TX_FAR _UnnamedText_59c65
	db $50
; 0x59c65 + 5 bytes

UnnamedText_59c6a: ; 0x59c6a
	TX_FAR _UnnamedText_59c6a
	db $50
; 0x59c6a + 5 bytes

ReceivedBikeVoucherText: ; 0x59c6f
	TX_FAR _ReceivedBikeVoucherText ; 0x9a82e
	db $11
	TX_FAR _UnnamedText_59c74 ; 0x9a844
	db $50
; 0x59c6f + 10 bytes = 0x59c79

UnnamedText_59c79: ; 0x59c79
	TX_FAR _UnnamedText_59c79
	db $50
; 0x59c79 + 5 bytes

UnnamedText_59c7e: ; 0x59c7e
	TX_FAR _UnnamedText_59c7e
	db $50
; 0x59c7e + 5 bytes

UnnamedText_59c83: ; 0x59c83
	TX_FAR _UnnamedText_59c83
	db $50
; 0x59c83 + 5 bytes

FanClubText6:
	TX_FAR _FanClubText6
	db $50

FanClubText7:
	TX_FAR _FanClubText7
	db $50

FanClubText8: ; 0x59c92
	TX_FAR _FanClubText8
	db $50

FanClubObject: ; 0x59c97 (size=62)
	db $d ; border tile

	db $2 ; warps
	db $7, $2, $1, $ff
	db $7, $3, $1, $ff

	db $2 ; signs
	db $0, $1, $7 ; FanClubText7
	db $0, $6, $8 ; FanClubText8

	db $6 ; people
	db SPRITE_FISHER2, $3 + 4, $6 + 4, $ff, $d2, $1 ; person
	db SPRITE_GIRL, $3 + 4, $1 + 4, $ff, $d3, $2 ; person
	db SPRITE_CLEFAIRY, $4 + 4, $6 + 4, $ff, $d2, $3 ; person
	db SPRITE_SEEL, $4 + 4, $1 + 4, $ff, $d3, $4 ; person
	db SPRITE_GENTLEMAN, $1 + 4, $3 + 4, $ff, $d0, $5 ; person
	db SPRITE_CABLE_CLUB_WOMAN, $1 + 4, $5 + 4, $ff, $d0, $6 ; person

	; warp-to
	EVENT_DISP $4, $7, $2
	EVENT_DISP $4, $7, $3

FanClubBlocks: ; 0x59cd5 16
	INCBIN "maps/fanclub.blk"

SilphCo2_h: ; 0x59ce5 to 0x59cf1 (12 bytes) (id=207)
	db $16 ; tileset
	db SILPH_CO_2F_HEIGHT, SILPH_CO_2F_WIDTH ; dimensions (y, x)
	dw SilphCo2Blocks, SilphCo2Texts, SilphCo2Script ; blocks, texts, scripts
	db $00 ; connections

	dw SilphCo2Object ; objects

SilphCo2Script: ; 0x59cf1
	call SilphCo2_Unknown59d07
	call $3c3c
	ld hl, SilphCo2TrainerHeaders
	ld de, $5d80
	ld a, [$d643]
	call $3160
	ld [$d643], a
	ret
; 0x59d07

SilphCo2_Unknown59d07: ; 0x59d07
INCBIN "baserom.gbc",$59d07,$7f

SilphCo2Texts: ; 0x59d86
	dw SilphCo2Text1, SilphCo2Text2, SilphCo2Text3, SilphCo2Text4, SilphCo2Text5

SilphCo2TrainerHeaders:
SilphCo2TrainerHeader0: ; 0x59d90
	db $2 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d825 ; flag's byte
	dw SilphCo2BattleText1 ; 0x5e2a TextBeforeBattle
	dw SilphCo2AfterBattleText1 ; 0x5e34 TextAfterBattle
	dw SilphCo2EndBattleText1 ; 0x5e2f TextEndBattle
	dw SilphCo2EndBattleText1 ; 0x5e2f TextEndBattle
; 0x59d9c

SilphCo2TrainerHeader1: ; 0x59d9c
	db $3 ; flag's bit
	db ($4 << 4) ; trainer's view range
	dw $d825 ; flag's byte
	dw SilphCo2BattleText2 ; 0x5e39 TextBeforeBattle
	dw SilphCo2AfterBattleText2 ; 0x5e43 TextAfterBattle
	dw SilphCo2EndBattleText2 ; 0x5e3e TextEndBattle
	dw SilphCo2EndBattleText2 ; 0x5e3e TextEndBattle
; 0x59da8

SilphCo2TrainerHeader2: ; 0x59da8
	db $4 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d825 ; flag's byte
	dw SilphCo2BattleText3 ; 0x5e48 TextBeforeBattle
	dw SilphCo2AfterBattleText3 ; 0x5e52 TextAfterBattle
	dw SilphCo2EndBattleText3 ; 0x5e4d TextEndBattle
	dw SilphCo2EndBattleText3 ; 0x5e4d TextEndBattle
; 0x59db4

SilphCo2TrainerHeader3: ; 0x59db4
	db $5 ; flag's bit
	db ($3 << 4) ; trainer's view range
	dw $d825 ; flag's byte
	dw SilphCo2BattleText4 ; 0x5e57 TextBeforeBattle
	dw SilphCo2AfterBattleText4 ; 0x5e61 TextAfterBattle
	dw SilphCo2EndBattleText4 ; 0x5e5c TextEndBattle
	dw SilphCo2EndBattleText4 ; 0x5e5c TextEndBattle
; 0x59dc0

db $ff

SilphCo2Text1: ; 0x59dc1
	db $08 ; asm
	ld a, [$d826]
	bit 7, a
	jr nz, asm_b8a0d ; 0x59dc7
	ld hl, UnnamedText_59ded
	call PrintText
	ld bc, (TM_36 << 8) | 1
	call GiveItem
	ld hl, TM36NoRoomText
	jr nc, asm_2c1e0 ; 0x59dd8
	ld hl, $d826
	set 7, [hl]
	ld hl, ReceivedTM36Text
	jr asm_2c1e0 ; 0x59de2
asm_b8a0d ; 0x59de4
	ld hl, TM36ExplanationText
asm_2c1e0 ; 0x59de7
	call PrintText
	jp TextScriptEnd

UnnamedText_59ded: ; 0x59ded
	TX_FAR _UnnamedText_59ded
	db $50
; 0x59ded + 5 bytes

ReceivedTM36Text: ; 0x59df2
	TX_FAR _ReceivedTM36Text ; 0x824ba
	db $0B, $50
; 0x59df2 + 6 bytes = 0x59df8

TM36ExplanationText: ; 0x59df8
	TX_FAR _TM36ExplanationText
	db $50
; 0x59df8 + 5 bytes

TM36NoRoomText: ; 0x59dfd
	TX_FAR _TM36NoRoomText
	db $50
; 0x59dfd + 5 bytes

SilphCo2Text2: ; 0x59e02
	db $08 ; asm
	ld hl, SilphCo2TrainerHeader0
	call LoadTrainerHeader
	jp TextScriptEnd

SilphCo2Text3: ; 0x59e0c
	db $08 ; asm
	ld hl, SilphCo2TrainerHeader1
	call LoadTrainerHeader
	jp TextScriptEnd

SilphCo2Text4: ; 0x59e16
	db $08 ; asm
	ld hl, SilphCo2TrainerHeader2
	call LoadTrainerHeader
	jp TextScriptEnd

SilphCo2Text5: ; 0x59e20
	db $08 ; asm
	ld hl, SilphCo2TrainerHeader3
	call LoadTrainerHeader
	jp TextScriptEnd

SilphCo2BattleText1: ; 0x59e2a
	TX_FAR _SilphCo2BattleText1
	db $50
; 0x59e2a + 5 bytes

SilphCo2EndBattleText1: ; 0x59e2f
	TX_FAR _SilphCo2EndBattleText1
	db $50
; 0x59e2f + 5 bytes

SilphCo2AfterBattleText1: ; 0x59e34
	TX_FAR _SilphCo2AfterBattleText1
	db $50
; 0x59e34 + 5 bytes