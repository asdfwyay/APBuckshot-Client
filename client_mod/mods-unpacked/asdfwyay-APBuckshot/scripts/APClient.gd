class_name APClient extends Node

const APPacket = preload("res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/common/APPacket.gd")
const NetworkVersion = preload("res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/common/NetworkVersion.gd")

const Connect = preload("res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/client/Connect.gd")
const LocationChecks = preload("res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/client/LocationChecks.gd")
const StatusUpdate = preload("res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/client/StatusUpdate.gd")
const Sync = preload("res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/client/Sync.gd")

const Connected = preload("res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/server/Connected.gd")
const ReceivedItems = preload("res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/server/ReceivedItems.gd")
const RoomInfo = preload("res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/server/RoomInfo.gd")

enum ConnectionState {
	DISCONNECTED = 0,
	CONNECTING = 1,
	CONNECTED = 2,
	DISCONNECTING = 3
}

var shotsanityLiveCount: int = 0
var shotsanityBlankCount: int = 0
var donAccessReq: int = 0
var canAccessDON: bool = false
var goalAmt: int = 0

var slot: String = "asdfwyay-BR"
var hostname: String = "archipelago.gg"
var port: String = "49430"
var password: String = ""

const uuidUtil = preload("res://mods-unpacked/asdfwyay-APBuckshot/scripts/utils/uuid.gd")

var itemIndex: int = 0

var inventory: Array = []
var checkedLocations: Array = []
var obtainedItems: Array = []

var socket = WebSocketPeer.new()
var connectionState: ConnectionState = ConnectionState.DISCONNECTED
var syncing: bool = false

var CONNECTION_TIMEOUT: float = 5.0

func _ready():
	pass
	#socket.connect_to_url("wss://%s:%d" % [hostname, port])
	
func APConnect(_slot, _hostname, _port, _password) -> void:
	slot = _slot
	hostname = _hostname
	port = _port
	password = _password
	
	socket = WebSocketPeer.new()
	connectionState = ConnectionState.CONNECTING
	
	var result = socket.connect_to_url("wss://%s:%s" % [hostname, port])
	await get_tree().create_timer(CONNECTION_TIMEOUT).timeout
	if result != OK or socket.get_ready_state() != socket.STATE_OPEN:
		result = socket.connect_to_url("ws://%s:%s" % [hostname, port])
		await get_tree().create_timer(CONNECTION_TIMEOUT).timeout
		if result != OK or socket.get_ready_state() != socket.STATE_OPEN:
			connectionState = ConnectionState.DISCONNECTED
			return

func _process(delta):
	if connectionState == ConnectionState.DISCONNECTED:
		return
		
	socket.poll()
	var state = socket.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count():
			ParsePacket(socket.get_packet())
	elif state == WebSocketPeer.STATE_CLOSING:
		# Keep polling to achieve proper close.
		pass
	elif state == WebSocketPeer.STATE_CLOSED:
		var code = socket.get_close_code()
		var reason = socket.get_close_reason()
		print("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
		#set_process(false) # Stop processing.
		
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
		if item.item == 22:
			var statusUpdatePck = StatusUpdate.new(StatusUpdate.ClientStatus.CLIENT_GOAL)
			SendPacket(statusUpdatePck)
		elif item.item <= 10 && !obtainedItems.has(item.item):
			obtainedItems.append(item.item)
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
					var syncPck = Sync.new()
					syncing = true
					itemIndex = recItemsPck.index + 1
					SendPacket(syncPck)
					UpdateLocations()
	else:
		match incPckData.cmd:
			"RoomInfo":
				var roomInfoPck = RoomInfo.new()
				roomInfoPck.from_dict(incPckData)
				
				connectPck = Connect.new(
					password,
					"Buckshot Roulette",
					slot,
					uuidUtil.v4(),
					NetworkVersion.new(
						roomInfoPck.version.major,
						roomInfoPck.version.minor,
						roomInfoPck.version.build
					)
				)
				SendPacket(connectPck)
			"ConnectionRefused":
				SendPacket(connectPck)
			"Connected":
				var connectedPck = Connected.new()
				connectedPck.from_dict(incPckData)
				
				checkedLocations = connectedPck.checked_locations.duplicate()
				connectionState = ConnectionState.CONNECTED
				
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
