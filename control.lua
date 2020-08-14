require("interface")

SIGNAL_COUPLE = {type="virtual", name="signal-couple"}
SIGNAL_UNCOUPLE = {type="virtual", name="signal-uncouple"}

-- Returns sum of given signal across red and green wires as read by given entity
function getSignal(entity, signal)
  local red = entity.get_circuit_network(defines.wire_type.red)
  local green = entity.get_circuit_network(defines.wire_type.green)
  local value = 0
  if red then
    value = red.get_signal(signal)
  end
  if green then
    value = value + green.get_signal(signal)
  end
  if value == 0 then
    return nil
  else
    return value
  end
end

-- Compares two orientations and returns true if the difference is <90°
function orientationMatch(orient1, orient2)
  return math.abs(orient1 - orient2) < 0.25 or math.abs(orient1 - orient2) > 0.75
end

-- Return the bearing from entity to target as an orientation, for comparison
function getOrientation(entity, target)
  local x = target.position.x - entity.position.x
  local y = target.position.y - entity.position.y
  return (math.atan2(y,x) / 2 / math.pi + 0.25) % 1
end

-- Get rectilinear distance between two points - good enough for our purposes
function getTileDistance(pos_a, pos_b)
  return math.abs(pos_a.x - pos_b.x) + math.abs(pos_a.y - pos_b.y)
end

-- Sure we could just do some modulo but defines sometimes change
function swapRailDir(raildir)
  if raildir == defines.rail_direction.front then
    return defines.rail_direction.back
  else
    return defines.rail_direction.front
  end
end

-- Couples at the station end of the train if positive, otherwise the rear end (who knows, somebody might make that happen)
function attemptCouple(train, count)
  if count then
    local direction = defines.rail_direction.front
    if count < 0 then
      direction = defines.rail_direction.back
    end
    local front = getRealFront(train)
    if not orientationMatch(front.orientation, train.station.orientation) then
      direction = swapRailDir(direction)
    end
    if front.connect_rolling_stock(direction) then
      return front
    end
  end
end

-- Disconnects first n cars from station end if positive, else first n cars from other end if negative
-- front must be REAL front
function attemptUncouple(front, count)
  local frontCar = front.train.front_stock
  local backCar = front.train.back_stock
  if count and math.abs(count) < #front.train.carriages then
    local direction = defines.rail_direction.front
    if front ~= front.train.front_stock then -- train is backwards, swap ends
      count = count * -1
    end
    local target = count -- the last wagon we're cutting off
    if count < 0 then
      count = #front.train.carriages + count
      target = count + 1
    else
      count = count + 1
    end
    local wagon = front.train.carriages[count] -- the first wagon that will remain on the train
    if not orientationMatch(getOrientation(wagon, front.train.carriages[target]), wagon.orientation) then
      direction = swapRailDir(direction) -- wagon facing away from target, disconnect backwards instead
    end
    if wagon.disconnect_rolling_stock(direction) then
	  local frontLocos = 0
	  local backLocos = 0
	  local wagons = frontCar.train.carriages
	  for _,carriage in pairs(wagons) do
	    if (string.find(carriage.type, "locomotive")) then
		  frontLocos = frontLocos + 1
		end
	  end
	  local wagons = backCar.train.carriages
	  for _,carriage in pairs(wagons) do
	    if (string.find(carriage.type, "locomotive")) then
		  backLocos = backLocos + 1
		end
	  end
	  if frontLocos > 0 then frontCar.train.manual_mode = false end
	  if backLocos > 0 then backCar.train.manual_mode = false end
      return wagon -- return the wagon not disconnect
    end
  end
end

-- Return the piece of rolling stock at the end of the train that's actually at the station
function getRealFront(train)
  if getTileDistance(train.front_stock.position, train.station.position) < getTileDistance(train.back_stock.position, train.station.position) then
    return train.front_stock
  else
    return train.back_stock
  end
end

-- As above but for the back of the train
function getRealBack(train)
  local back = train.back_stock
  if getTileDistance(train.front_stock.position, train.station.position) < getTileDistance(train.back_stock.position, train.station.position) then
    return train.back_stock
  else
    return train.front_stock
  end
end

script.on_event(defines.events.on_train_created, function(event)
  if global.debug then game.print("Train created") end end)

script.on_event(defines.events.on_train_changed_state, function(event)
  if event.train.state == defines.train_state.wait_station then
    local couple = false
    local train = event.train
    local station = train.station
    if station then
      local front = getRealFront(train) -- station end
      local back = getRealBack(train) -- not station end
      local schedule = train.schedule -- save for later
      local changed = false
      if attemptCouple(train, getSignal(station, SIGNAL_COUPLE)) then
        changed = true
		couple = true
        train = front.train -- train has changed, need reference to new one
        if front == train.front_stock or back == train.back_stock then -- one end of the train will have changed
          front = train.front_stock
          back = train.back_stock
        else
          front = train.back_stock
          back = train.front_stock
        end
      end
      front = attemptUncouple(front, getSignal(station, SIGNAL_UNCOUPLE)) -- don't care if actually front, just storing for comparison
      if front then -- non nil result, wagon(s) disconnected
        changed = true
      else -- nope, nothing disconnected
        front = back
      end
      if changed then -- train now in manual mode, schedule lost
        schedule.current = (schedule.current)% #schedule.records + 1 -- advance schedule to next station
        front.train.schedule = schedule -- assign schedule back to train
        if #front.train.locomotives > 0 or couple then front.train.manual_mode = false end -- turn automatic back on
		back.train.schedule = schedule -- assign schedule back to train
        if #back.train.locomotives > 0 or couple then back.train.manual_mode = false end -- turn automatic back on
      end
    end
  end
end)

local function on_init(event)
  global.debug = global.debug or false
end
script.on_init(on_init)

local function debug()
	for name, value in pairs(global) do
		game.print(name..": "..tostring(value))
	end
end
commands.add_command("debug-coupler", "command-help.debug-coupler", debug)