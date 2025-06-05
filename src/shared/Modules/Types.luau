export type UserData = {
	Cash: number,
	Slots: { [number]: string },
	LastJoin: number?,
	Index: {},
}

export type MemeSpawn = {
	Price: number,
	Income: number, -- income per second
}

export type Spawn = {
	Rarity: number,
	Spawns: { [string]: MemeSpawn },
}

return {}
