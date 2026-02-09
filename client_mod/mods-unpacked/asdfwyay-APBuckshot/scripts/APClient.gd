class_name APClient extends Node

const APPacket = preload("res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/common/APPacket.gd")
const NetworkVersion = preload("res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/common/NetworkVersion.gd")

const Bounce = preload("res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/client/Bounce.gd")
const Connect = preload("res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/client/Connect.gd")
const ConnectUpdate = preload("res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/client/ConnectUpdate.gd")
const LocationChecks = preload("res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/client/LocationChecks.gd")
const StatusUpdate = preload("res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/client/StatusUpdate.gd")
const Sync = preload("res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/client/Sync.gd")

const Bounced = preload("res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/server/Bounced.gd")
const Connected = preload("res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/server/Connected.gd")
const ReceivedItems = preload("res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/server/ReceivedItems.gd")
const RoomInfo = preload("res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/server/RoomInfo.gd")

enum ConnectionState {
	DISCONNECTED = 0,
	CONNECTING = 1,
	CONNECTED = 2,
	DISCONNECTING = 3
}

const L_OFST_SS = 94
const WINNER_ITEM_ID = 26

const I_OFST_MECH = 11
const I_OFST_TRAP = 13
const I_OFST_FILL = 15

const I_ITEM_LUCK = 11
const I_LIFE_BANK = 12

const I_ITEM_TRAP = 13
const I_BULLET_TRAP = 14

var shotsanityCount: int = 0
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

const uuidUtil = preload("res://mods-unpacked/asdfwyay-APBuckshot/scripts/utils/uuid.gd")

var itemIndex: int = 0

var inventory: Array = []
var mechanicItems: Dictionary = {} #[int, int]
var checkedLocations: Array = []
var obtainedItems: Array = []
var trapQueue: Array = []

var lifeBankCharges: int = 0
var isPlayerTurn: bool = false

var socket = WebSocketPeer.new()
var connectionState: ConnectionState = ConnectionState.DISCONNECTED
var syncing: bool = false

var CONNECTION_TIMEOUT: float = 5.0

var attemptReconnection: bool = true
var failedAttempts: int = 0
var MAX_FAILED_ATTEMPTS: int = 5

var slot_num: int = 0

func _ready():
	pass
	#socket.connect_to_url("wss://%s:%d" % [hostname, port])
	
func APConnect(_slot, _hostname, _port, _password) -> bool:
	slot = _slot
	hostname = _hostname
	port = _port
	password = _password
	
	resetLifeBank()
	
	socket = WebSocketPeer.new()
	connectionState = ConnectionState.CONNECTING
	
	var result
	if (hostname in ["localhost", "127.0.0.1"]):
		result = socket.connect_to_url("ws://%s:%s" % [hostname, port])
	else:
		result = socket.connect_to_url("wss://%s:%s" % [hostname, port])
	
	await get_tree().create_timer(CONNECTION_TIMEOUT).timeout
	if result != OK or socket.get_ready_state() != socket.STATE_OPEN:
		result = socket.connect_to_url("ws://%s:%s" % [hostname, port])
		await get_tree().create_timer(CONNECTION_TIMEOUT).timeout
		if result != OK or socket.get_ready_state() != socket.STATE_OPEN:
			connectionState = ConnectionState.DISCONNECTED
			return false
	return true

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
		# Keep polling to achieve proper close.
		pass
	elif state == WebSocketPeer.STATE_CLOSED:
		var code = socket.get_close_code()
		var reason = socket.get_close_reason()
		#print("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
		#set_process(false) # Stop processing.
		if (attemptReconnection):
			var result = await APConnect(slot, hostname, port, password)
			if not result:
				failedAttempts += 1
			if (failedAttempts > MAX_FAILED_ATTEMPTS):
				attemptReconnection = false
		
func SendPacket(packet: APPacket) -> void:
	socket.send_text(packet.serialize())
	
func UpdateLocations() -> void:
	var locationChecksPck = LocationChecks.new(checkedLocations)
	SendPacket(locationChecksPck)
	CheckDONAccess()
	
func SendLocation(id: float) -> void:
	if !checkedLocations.has(id):
		checkedLocations.append(id)
		UpdateLocations()
	print(checkedLocations)
	
func ReceiveItem(recItemsPck: ReceivedItems) -> void:
	for item in recItemsPck.items:
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
			trapQueue.append(int(item.item))
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
	var incPckData
	var connectPck
	
	var err = incPckJSON.parse(packet.get_string_from_ascii())
	if err == OK:
		incPckData = incPckJSON.data[0]
		print("Packet: ", incPckData)
		
	if connectionState == ConnectionState.CONNECTED:
		match incPckData.cmd:
			"ReceivedItems":
				var recItemsPck = ReceivedItems.new()
				recItemsPck.from_dict(incPckData)
				
				if (syncing || recItemsPck.index == itemIndex):
					ReceiveItem(recItemsPck)
					if (!syncing):
						itemIndex = recItemsPck.index + 1
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

				print(deathLink, bouncedPck.tags)
				
				if (deathLink and !deathLinkCD
				and bouncedPck.tags and "DeathLink" in bouncedPck.tags):
					awaitingDeathLink = true
					
	else:
		match incPckData.cmd:
			"RoomInfo":
				var roomInfoPck = RoomInfo.new()
				roomInfoPck.from_dict(incPckData)
				
				var tags
				if deathLink:
					tags = ["NoText", "DeathLink"]
				else:
					tags = ["NoText"]
				
				connectPck = Connect.new(
					password,
					"Buckshot Roulette",
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
			"ConnectionRefused":
				SendPacket(connectPck)
			"Connected":
				var connectedPck = Connected.new()
				connectedPck.from_dict(incPckData)
				
				checkedLocations = connectedPck.checked_locations.duplicate()
				connectionState = ConnectionState.CONNECTED
				
				slot_num = connectedPck.slot
				
				for i in range(L_OFST_SS, L_OFST_SS + 1000):
					if float(i) not in checkedLocations:
						shotsanityCount = i - L_OFST_SS
						break
				
				donAccessReq = connectedPck.slot_data["double_or_nothing_requirements"]
				CheckDONAccess()
				
				DirAccess.copy_absolute(
					"user://buckshotroulette_pills.shell",
					"user://buckshotroulette_pills.shell.bkp"
				)
				DirAccess.remove_absolute("user://buckshotroulette_pills.shell")
				
				if connectedPck.slot_data["goal"] == 2:
					goalAmt = 1000000
				else:
					goalAmt = connectedPck.slot_data["custom_goal_amount"]
				
				var syncPck = Sync.new()
				syncing = true
				SendPacket(syncPck)

func setDeathLink(value: bool) -> void:
	var tags
	if value:
		tags = ["NoText", "DeathLink"]
	else:
		tags = ["NoText"]
	
	var connectUpdatePck = ConnectUpdate.new(
		0b111,
		tags
	)
	SendPacket(connectUpdatePck)
	
	deathLink = value

func resetLifeBank() -> void:
	for i in range(I_OFST_MECH, I_OFST_TRAP):
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
			"source": slot
		}
	)
	SendPacket(deathLinkPacket)
