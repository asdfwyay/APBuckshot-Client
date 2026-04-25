class_name APClient extends Node

signal send_notification(msg: String)
signal send_error(msg: String)
signal send_chat(msg: String)
signal data_store_retrieved(data)
signal location_info_retrieved(items_in_locations)

signal request_mag_choice()
signal send_mag_choice(choice: String)
signal request_beer_choice()
signal send_beer_choice(choice: bool)
signal request_phone_choice(num_shells: int)
signal send_phone_choice(num_shells: int)

enum ConnectionState {
	DISCONNECTED = 0,
	CONNECTING = 1,
	CONNECTED = 2,
	DISCONNECTING = 3
}

const APPacket = preload("res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/common/APPacket.gd")
const JSONMessagePart = preload("res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/common/JSONMessagePart.gd")
const NetworkPlayer = preload("res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/common/NetworkPlayer.gd")
const NetworkSlot = preload("res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/common/NetworkSlot.gd")
const NetworkVersion = preload("res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/common/NetworkVersion.gd")

const Bounce = preload("res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/client/Bounce.gd")
const Connect = preload("res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/client/Connect.gd")
const ConnectUpdate = preload("res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/client/ConnectUpdate.gd")
const CreateHints = preload("res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/client/CreateHints.gd")
const Get = preload("res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/client/Get.gd")
const GetDataPackage = preload("res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/client/GetDataPackage.gd")
const LocationChecks = preload("res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/client/LocationChecks.gd")
const LocationScouts = preload("res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/client/LocationScouts.gd")
const Say = preload("res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/client/Say.gd")
const Set = preload("res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/client/Set.gd")
const StatusUpdate = preload("res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/client/StatusUpdate.gd")
const Sync = preload("res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/client/Sync.gd")

const Bounced = preload("res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/server/Bounced.gd")
const Connected = preload("res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/server/Connected.gd")
const ConnectionRefused = preload("res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/server/ConnectionRefused.gd")
const DataPackage = preload("res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/server/DataPackage.gd")
const LocationInfo = preload("res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/server/LocationInfo.gd")
const PrintJSON = preload("res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/server/PrintJSON.gd")
const ReceivedItems = preload("res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/server/ReceivedItems.gd")
const RoomInfo = preload("res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/server/RoomInfo.gd")

const uuidUtil = preload("res://mods-unpacked/asdfwyay-APBuckshot/scripts/utils/uuid.gd")

const I_OFST_MECH = 0x0100 + 1
const I_OFST_TRAP = 0x0400 + 1
const I_OFST_FILL = 0x0700 + 1

const I_ITEM_LUCK = 0x0100 + 1
const I_LIFE_BANK = 0x0100 + 2
const I_OFST_ITEM_BUFF = 0x0100 + 3
const I_OFST_ITEM_DEBUFF = 0x0100 + 12

const I_ITEM_TRAP = 0x0400 + 1
const I_BULLET_TRAP = 0x0400 + 2

const N_MECH_ITEMS = 20

const L_OFST_SS = 0x1000 + 1
const L_OFST_STS = 0x2000 + 1
const L_CASH_OUT = 0x2100 + 1
const WINNER_ITEM_ID = 0x0F00 + 2

var hint_mode: bool = false

var shotsanityCount: int = 0
var streak: int = 0
var poison: int = 0
var donAccessReq: int = 0
var canAccessDON: bool = false
var goalAmt: int = 0

var deathLink: bool = false
var awaitingDeathLink: bool = false
var deathLinkCD: bool = false
var deathLinkCDTimer: float = 0.0

var slot: String = ""
var hostname: String = "archipelago.gg"
var port: String = "38281"
var password: String = ""

var itemIndex: int = 0

var mechanicItems: Dictionary = {} #[int, int]
var checkedLocations: Array = []
var missingLocations: Array = []
var obtainedItems: Array = []
var trapQueue: Array = []
var dealerTrapQueue: Array = []

var lifeBankCharges: int = 0
var isPlayerTurn: bool = false
var hasUsedHandsaw: bool = false

var socket = WebSocketPeer.new()
var connectionState: ConnectionState = ConnectionState.DISCONNECTED
var syncing: bool = false

var CONNECTION_TIMEOUT: float = 3.0

var attemptReconnection: bool = true
var failedAttempts: int = 0
var MAX_FAILED_ATTEMPTS: int = 5

var slot_num: int = 0
var death_msg: String = "YOU'VE BEEN DEATHLINKED"

var latest_error_msg: String = ""

var games_present: Array = []

var item_name_to_id: Dictionary = {}
var item_id_to_name: Dictionary = {}
var location_name_to_id: Dictionary = {}
var location_id_to_name: Dictionary = {}

var players: Dictionary = {}
var slot_info: Dictionary = {}
var data_store: Dictionary = {}

var prog_locs: Array = []
var useful_locs: Array = []
var filler_locs: Array = []
var trap_locs: Array = []

var item_buff_states: Dictionary = {
	"handcuffs": false,
	"beer": true,
}
var included_item_debuffs: Array = []

func _ready():
	socket.set_inbound_buffer_size(50000000)
	GlobalVariables.set_meta("burner_phone_choice", 0)
	#socket.connect_to_url("wss://%s:%d" % [hostname, port])


func APConnect(_slot=slot, _hostname=hostname, _port=port, _password=password) -> bool:
	slot = _slot
	hostname = _hostname
	port = _port
	password = _password
	
	resetLifeBank()
	
	if (
		connectionState == ConnectionState.CONNECTED or
		!attemptReconnection and connectionState != ConnectionState.DISCONNECTED
	):
		return false
	
	socket = WebSocketPeer.new()
	socket.set_inbound_buffer_size(50000000)
	connectionState = ConnectionState.CONNECTING
	
	var result
	if (hostname in ["localhost", "127.0.0.1"]):
		result = socket.connect_to_url("ws://%s:%s" % [hostname, port])
	else:
		result = socket.connect_to_url("wss://%s:%s" % [hostname, port])
	
	await get_tree().create_timer(CONNECTION_TIMEOUT).timeout
	if result != OK or socket.get_ready_state() != socket.STATE_OPEN:
		print("Failed wss. Attempting ws.")
		result = socket.connect_to_url("ws://%s:%s" % [hostname, port])
		await get_tree().create_timer(CONNECTION_TIMEOUT).timeout
		if result != OK or socket.get_ready_state() != socket.STATE_OPEN:
			print("Failed ws.")
			connectionState = ConnectionState.DISCONNECTED
			return false
	return true


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		print("Closing socket")
		if socket and socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
			attemptReconnection = false
			socket.close()
			while socket.get_ready_state() != WebSocketPeer.STATE_CLOSED:
				socket.poll()
		get_tree().quit()


func _process(delta):
	if deathLinkCD:
		deathLinkCDTimer += delta
		if deathLinkCDTimer >= 15.0:
			deathLinkCD = false
			deathLinkCDTimer = 0.0
	
	if connectionState == ConnectionState.DISCONNECTED:
		return
	
	socket.poll()
	var state = socket.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		attemptReconnection = true
		failedAttempts = 0
		while socket.get_available_packet_count():
			ParsePacket(socket.get_packet())
	elif state == WebSocketPeer.STATE_CLOSING:
		pass
	elif state == WebSocketPeer.STATE_CLOSED:
		var code = socket.get_close_code()
		var reason = socket.get_close_reason()
		print("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
		if (attemptReconnection):
			print("Attempt: %d" % [failedAttempts + 1])
			set_process(false)
			var result = await APConnect(slot, hostname, port, password)
			if not result:
				failedAttempts += 1
			if (failedAttempts > MAX_FAILED_ATTEMPTS):
				attemptReconnection = false
			set_process(true)
		else:
			connectionState = ConnectionState.DISCONNECTED


func SendPacket(packet: APPacket) -> void:
	var out = packet.serialize()
	if out.length() <= 32760:
		print("Outgoing Packet: ", out)
	socket.send_text(out)


func UpdateLocations() -> void:
	var locationChecksPck = LocationChecks.new(checkedLocations)
	SendPacket(locationChecksPck)
	CheckDONAccess()


func ScoutLocations(locations: Array, create_as_hint: int = 0) -> Array: #NetworkItem
	var locationScoutsPck = LocationScouts.new(locations, create_as_hint)
	SendPacket(locationScoutsPck)
	
	var location_ids_in_packet = []
	var items_in_locations
	while not locations.all(func(x): return int(x) in location_ids_in_packet):
		items_in_locations = await location_info_retrieved
		for item in items_in_locations:
			location_ids_in_packet.append(int(item.location))
	return items_in_locations

func SendLocation(id: float) -> void:
	if hint_mode:
		if id >= L_OFST_SS:
			return
		
		var r: float = randf()
		var location
		var status
		
		var getPck = Get.new("BuckshotRouletteHint_%d" % slot_num)
		SendPacket(getPck)
		
		var retrieved_data = await data_store_retrieved
		print(retrieved_data)
		if (
			retrieved_data
			and retrieved_data.has("BuckshotRouletteHint_%d" % slot_num)
			and id in retrieved_data["BuckshotRouletteHint_%d" % slot_num]
		):
			return
		
		if r <= 0.2 and prog_locs:
			location = prog_locs.pop_front()
			status = CreateHints.HintStatus.HINT_UNSPECIFIED
		elif r <= 0.5 and useful_locs:
			location = useful_locs.pop_front()
			status = CreateHints.HintStatus.HINT_UNSPECIFIED
		elif filler_locs:
			location = filler_locs.pop_front()
			status = CreateHints.HintStatus.HINT_UNSPECIFIED
		elif trap_locs:
			location = trap_locs.pop_front()
			status = CreateHints.HintStatus.HINT_AVOID
		else:
			return
		
		var createHintsPck = CreateHints.new(
			[location],
			slot_num,
			status
		)
		SendPacket(createHintsPck)
		
		var setPck = Set.new(
			"BuckshotRouletteHint_%d" % slot_num,
			[],
			false,
			[
				{"operation": "default", "value": 0},
				{"operation": "update", "value": [id]},
			]
		)
		SendPacket(setPck)
		return
	
	if !checkedLocations.has(id):
		checkedLocations.append(id)
		UpdateLocations()
		
		if !missingLocations.has(id):
			return
		
		var items_in_locations = await ScoutLocations([id], 0)
		if not items_in_locations.is_empty():
			var network_item = items_in_locations[0]
			var game = slot_info[int(network_item.player)]["game"]
			var player_name = slot_info[int(network_item.player)]["name"]
			var item_name = item_id_to_name[game][network_item.item]
			
			send_notification.emit("Sent %s to %s" % [item_name, player_name])
	print("Checked Location IDs: ", checkedLocations)


func ReceiveItem(recItemsPck: ReceivedItems) -> void:
	if hint_mode:
		return
	
	for item in recItemsPck.items:
		var shouldBroadcast = true
		if item.item == WINNER_ITEM_ID:
			var statusUpdatePck = StatusUpdate.new(StatusUpdate.ClientStatus.CLIENT_GOAL)
			SendPacket(statusUpdatePck)
		elif item.item < I_OFST_MECH and !obtainedItems.has(item.item):
			obtainedItems.append(item.item)
		elif item.item >= I_OFST_MECH and item.item < I_OFST_TRAP:
			mechanicItems[int(item.item)] += 1
			if (item.item == I_LIFE_BANK):
				lifeBankCharges += 1
		elif item.item >= I_OFST_TRAP and item.item < I_OFST_FILL:
			if (!syncing):
				trapQueue.append(int(item.item))
		else:
			shouldBroadcast = false
		
		if (shouldBroadcast):
			send_notification.emit("Received %s" % [item_id_to_name["Buckshot Roulette"][item.item]])
	
	itemIndex = recItemsPck.index + recItemsPck.items.size()
	CheckDONAccess()


func CheckDONAccess() -> void:
	match donAccessReq:
		0:
			canAccessDON = true
		1:
			canAccessDON = 5.0 in checkedLocations
		2:
			canAccessDON = 1.0 in obtainedItems
		3:
			canAccessDON = 5.0 in checkedLocations and 1.0 in obtainedItems
	
	if canAccessDON:
		var unlocker = Unlocker.new()
		unlocker.UnlockMode()


func ParsePacket(packet: PackedByteArray) -> void:
	var incPckJSON = JSON.new()
	var err = incPckJSON.parse(packet.get_string_from_utf8())
	if err == OK:
		for cmd in incPckJSON.data:
			#print("Incoming Command: %s, Bytes: %d" % [cmd.cmd, str(cmd).length()])
			HandleCommand(cmd)


func HandleCommand(incPckData) -> void:
	if connectionState == ConnectionState.CONNECTED:
		match incPckData.cmd:
			"ReceivedItems":
				var recItemsPck = ReceivedItems.new()
				recItemsPck.from_dict(incPckData)
				
				if (syncing || recItemsPck.index == itemIndex):
					ReceiveItem(recItemsPck)
					syncing = false
				else:
					resetLifeBank()
					var syncPck = Sync.new()
					syncing = true
					itemIndex = recItemsPck.index + 1
					SendPacket(syncPck)
					UpdateLocations()
			"Bounced":
				var bouncedPck = Bounced.new()
				bouncedPck.from_dict(incPckData)
				
				if (
					deathLink
					and !deathLinkCD
					and bouncedPck.data
					and bouncedPck.data.source != slot
					and bouncedPck.tags
					and "DeathLink" in bouncedPck.tags
				):
					death_msg = bouncedPck.data.cause
					awaitingDeathLink = true
			"DataPackage":
				handleDataPackage(incPckData)
			"PrintJSON":
				handleMessage(incPckData)
			"Retrieved":
				data_store_retrieved.emit(incPckData["keys"])
			"LocationInfo":
				location_info_retrieved.emit(incPckData["locations"])
			"RoomUpdate":
				if "checked_locations" in incPckData:
					var updateCount = false
					
					for location in incPckData["checked_locations"]:
						if not checkedLocations.has(location):
							checkedLocations.append(location)
						if location >= L_OFST_SS and location < L_OFST_SS + 1000:
							updateCount = true
					
					if updateCount:
						for i in range(L_OFST_SS, L_OFST_SS + 1000):
							if float(i) not in checkedLocations:
								shotsanityCount = i - L_OFST_SS
								break
	else:
		match incPckData.cmd:
			"RoomInfo":
				var roomInfoPck = RoomInfo.new()
				roomInfoPck.from_dict(incPckData)
				
				games_present = roomInfoPck.games
				
				var tags = []
				if deathLink:
					tags.append("DeathLink")
				if hint_mode:
					tags.append("HintGame")
				
				if not item_id_to_name or not location_id_to_name:
					var getDataPackagePck = GetDataPackage.new(games_present)
					SendPacket(getDataPackagePck)
				
				var connectPck = Connect.new(
					password,
					"" if hint_mode else "Buckshot Roulette",
					slot,
					uuidUtil.v4(),
					NetworkVersion.new(
						roomInfoPck.version.major,
						roomInfoPck.version.minor,
						roomInfoPck.version.build
					),
					0b111,
					tags
				)
				SendPacket(connectPck)
			"DataPackage":
				handleDataPackage(incPckData)
			"ConnectionRefused":
				var connectionRefusedPck = ConnectionRefused.new()
				connectionRefusedPck.from_dict(incPckData)
				
				if connectionRefusedPck.errors:
					latest_error_msg = connectionRefusedPck.errors[0]
				else:
					latest_error_msg = ""
				
				attemptReconnection = false
				socket.close(1000, latest_error_msg)
				
				send_error.emit(latest_error_msg)
			"Connected":
				var connectedPck = Connected.new()
				connectedPck.from_dict(incPckData)
				
				checkedLocations = connectedPck.checked_locations.duplicate()
				missingLocations = connectedPck.missing_locations.duplicate()
				connectionState = ConnectionState.CONNECTED
				
				slot_num = int(connectedPck.slot)
				
				for slot in connectedPck.slot_info:
					var info = connectedPck.slot_info[slot]
					slot_info[int(slot)] = info
				
				for player in connectedPck.players:
					var network_player = NetworkPlayer.new()
					network_player.from_dict(player)
					if network_player.team == connectedPck.team:
						players[network_player.slot] = network_player.name
				
				DirAccess.copy_absolute(
					"user://buckshotroulette_pills.shell",
					"user://buckshotroulette_pills.shell.bkp"
				)
				DirAccess.remove_absolute("user://buckshotroulette_pills.shell")
				
				if hint_mode:
					donAccessReq = 0
					var locationScoutsPck = LocationScouts.new(missingLocations, 0)
					SendPacket(locationScoutsPck)
				else:
					for i in range(L_OFST_SS, L_OFST_SS + 1000):
						if float(i) not in checkedLocations:
							shotsanityCount = i - L_OFST_SS
							break
					
					donAccessReq = connectedPck.slot_data["double_or_nothing_requirements"]
					CheckDONAccess()
					
					if connectedPck.slot_data["goal"] == 2:
						goalAmt = 1000000
					else:
						goalAmt = connectedPck.slot_data["custom_goal_amount"]
					
					if (
						"included_custom_mechanics" in connectedPck.slot_data # 0.3.0 compatability
						and "Item Debuffs" not in connectedPck.slot_data["included_custom_mechanics"]
					):
						included_item_debuffs = []
					else:
						included_item_debuffs = connectedPck.slot_data["item_debuffs"]
					
					var i = 0
					for debuff in included_item_debuffs:
						included_item_debuffs[i] = int(item_name_to_id["Buckshot Roulette"][debuff.to_lower()])
						i += 1
					print("Included Item Debuffs: ", included_item_debuffs)
					
					var syncPck = Sync.new()
					syncing = true
					SendPacket(syncPck)
			"PrintJSON":
				handleMessage(incPckData)


func connectedHintMode(missingLocations) -> void:
	donAccessReq = 0
	prog_locs = []
	useful_locs = []
	filler_locs = []
	trap_locs = []
	
	var items_in_locations = await ScoutLocations(missingLocations, 0)
	for item in items_in_locations:
		match int(item["flags"]):
			0b001:
				prog_locs.append(int(item["location"]))
			0b010:
				useful_locs.append(int(item["location"]))
			0b100:
				trap_locs.append(int(item["location"]))
			_:
				filler_locs.append(int(item["location"]))
	
	prog_locs.shuffle()
	useful_locs.shuffle()
	filler_locs.shuffle()
	trap_locs.shuffle()

func handleDataPackage(incPckData) -> void:
	var dataPackagePck = DataPackage.new()
	dataPackagePck.from_dict(incPckData)
	
	for game in dataPackagePck.data["games"]:
		item_id_to_name[game] = {}
		location_id_to_name[game] = {}
		item_name_to_id[game] = {}
		location_name_to_id[game] = {}
		
		var _item_name_to_id = dataPackagePck.data["games"][game]["item_name_to_id"]
		for item_name in _item_name_to_id:
			var item_id = _item_name_to_id[item_name]
			item_id_to_name[game][item_id] = item_name
			item_name_to_id[game][item_name.to_lower()] = item_id
		
		var _location_name_to_id = dataPackagePck.data["games"][game]["location_name_to_id"]
		for location_name in _location_name_to_id:
			var location_id = _location_name_to_id[location_name]
			location_id_to_name[game][location_id] = location_name
			location_name_to_id[game][location_name.to_lower()] = location_id


func handleMessage(incPckData) -> void:
	var printJSONPck = PrintJSON.new()
	printJSONPck.from_dict(incPckData)
	
	var msg = ""
	for msg_part in printJSONPck.data:
		var test = JSONMessagePart.new()
		test.from_dict(msg_part)
		
		match test.type:
			"player_id":
				test.text = players[int(test.text)]
			"item_id":
				var game = slot_info[test.player]["game"]
				test.text = item_id_to_name[game][float(test.text)]
			"location_id":
				var game = slot_info[test.player]["game"]
				test.text = location_id_to_name[game][float(test.text)]
		
		msg += test.text
	msg += "\n"
	send_chat.emit(msg)

func setDeathLink(value: bool) -> void:
	deathLink = value
	
	if !socket or socket.get_ready_state() != WebSocketPeer.STATE_OPEN:
		return
	
	var tags
	if value:
		tags = ["DeathLink"]
	else:
		tags = []
	
	var connectUpdatePck = ConnectUpdate.new(
		0b111,
		tags
	)
	SendPacket(connectUpdatePck)


func setHintMode(value: bool) -> void:
	if socket and socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		return
	hint_mode = value


func resetLifeBank() -> void:
	for i in range(I_OFST_MECH, I_OFST_MECH + N_MECH_ITEMS):
		mechanicItems[i] = 0
	lifeBankCharges = 0


func sendDeathLink() -> void:
	var deathLinkPacket = Bounce.new(
		[],
		[],
		["DeathLink"],
		{
			"time": Time.get_unix_time_from_system(),
			"cause": "%s took a bullet to the face." % [slot],
			"source": slot,
		},
	)
	SendPacket(deathLinkPacket)


func checkItemDebuff(id: int) -> bool:
	return (
		id in included_item_debuffs
		and mechanicItems[I_OFST_ITEM_DEBUFF + id - 2] == 0
	)
