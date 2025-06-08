export type UserData = {
	Cash: number,
	Slots: { [number]: string },
	LastJoin: number?,
	Index: {},
	NewPlayer: boolean,
	ClaimedFreePet: boolean,
	ClaimedVIPPet: boolean,
}

export type MemeSpawn = {
	Price: number,
	Income: number, -- income per second
}

export type Spawn = {
	Rarity: number,
	Spawns: { [string]: MemeSpawn },
}

export type NPCDialogueOption = {
	Option: string,
	Callback: () -> ()?,
}

export type NPCDialogueOptions = {
	[string]: NPCDialogueOption,
}

return {}
