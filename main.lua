Font = love.graphics.newFont("clacon2.ttf", 16)

Up = true
Range = 0

Mph = 0
Rpm = 0
Milage = 60000
Trip = 0

Tachometer = {}
Tachometer.height = 16
Tachometer.status = 0
Tachometer.width = 256
Tachometer.boarder_px = 1
Tachometer.x = 32
Tachometer.y = 64
Tachometer.shift_Rpm = 5000
Tachometer.redline_Rpm = 6000
Tachometer.redline_percent = 0.85
Tachometer.max_Rpm = Tachometer.redline_Rpm/Tachometer.redline_percent
Tachometer.font = love.graphics.newFont("clacon2.ttf", 16)

function Tachometer.tach_lines(offset)
	for i = 1, Tachometer.max_Rpm/1000 do
		local x1 = math.floor(Tachometer.x + Tachometer.width/(Tachometer.max_Rpm/1000) * i)
		local x2 = x1
		local y1 = Tachometer.y
		local y2 = y1 + Tachometer.height
		love.graphics.line(x1+offset, y1 + 2, x2+offset, y2 - 2)
		if offset == 0 then
			love.graphics.print(i, x2 - 4, y2 + 8)
		end
	end
end

function Tachometer.draw()
	love.graphics.setColor(0.5,0,0,1)
	love.graphics.rectangle("fill",
	Tachometer.x + Tachometer.width * Tachometer.redline_percent,
	Tachometer.y,
	Tachometer.width * (1 - Tachometer.redline_percent),
	Tachometer.height
	)
	love.graphics.setColor(1,1,1)
	Tachometer.tach_lines(0)
	love.graphics.setFont(Tachometer.font)
	love.graphics.rectangle("line", Tachometer.x, Tachometer.y, Tachometer.width, Tachometer.height)
	if Rpm > Tachometer.shift_Rpm and Rpm < Tachometer.redline_Rpm then
		love.graphics.setColor(0, 1, 0)
	elseif Rpm >= Tachometer.redline_Rpm then
		love.graphics.setColor(1, 0, 0)
	else
		love.graphics.setColor(1, 1, 1)
	end
	love.graphics.rectangle("fill", Tachometer.x, Tachometer.y, Tachometer.status, Tachometer.height)
	love.graphics.setColor(1, 1, 1)
	love.graphics.rectangle("line", Tachometer.x, Tachometer.y, Tachometer.width, Tachometer.height)
	love.graphics.print(string.format("RPM %4d", Rpm),Tachometer.x, Tachometer.y - 16)
	love.graphics.setColor(0,0,0)
	Tachometer.tach_lines(2)
end

function Tachometer.update(dt)
	Tachometer.status = Tachometer.width*(Rpm/Tachometer.max_Rpm)
end

Speedometer = {}
Speedometer.x = 0
Speedometer.y = 8
Speedometer.font = love.graphics.newFont("clacon2.ttf", 32)

function Speedometer.draw()
	in_mph = math.ceil(Mph)
	if in_mph == 88 then
		love.graphics.setColor(1,0.5,0)
	else
		love.graphics.setColor(1,1,1)
	end
	love.graphics.setFont(Speedometer.font)
	love.graphics.printf(string.format("MPH\n%d", in_mph), Speedometer.x, Speedometer.y, 320 ,"center")
end

Odometer = {}
Odometer.x = 0
Odometer.y = 8
Odometer.font = love.graphics.newFont("clacon2.ttf", 16)

function Odometer.draw()
	love.graphics.setColor(1,1,1)
	love.graphics.setFont(Odometer.font)
	love.graphics.printf(string.format("ODOMETER\n%.1f", Milage + Trip), Odometer.x, Odometer.y, 128, "center")
	love.graphics.printf(string.format("TRIP\n%.1f", Trip), 320-128, Odometer.y, 128, "center")
end

VerticalGauge = {
	x = 0,
	y = 0, 
	height = 64,
	width = 16,
	lable = "Gauge",
	format = "&d",
	value = 50,
	needle_y = 0,
	min = 0,
	max = 100,
	low_warning_enabled = false,
	low_warning = 0,
	high_warning_enabled = false,
	high_warning = 100,
	low_redline_enabled = false,
	low_redline = 0,
	high_redline_enabled = false,
	high_redline = 100
}

function VerticalGauge:new(x, y, lable, format, min, max)
	o = {}
	setmetatable(o, self)
	self.__index = self
	o.x = x
	o.y = y
	o.lable = lable
	o.format = format
	o.min = min
	o.max = max
	o.redline = redline
	return o
end

function VerticalGauge:update()
	local y = self.height - (self.height * (self.value - self.min)/(self.max - self.min))
	if y < 0 then
		y = 0
	elseif y > self.height then
		y = self.height
	end
	self.needle_y = math.floor(self.y + y)
end

function VerticalGauge:draw()
	--love.graphics.rectangle("line", self.x, self.y - 16, 64, self.height + 16)
	love.graphics.setColor(0.5,0.25,0)
	if self.high_warning_enabled then
		local h = self.height - self.height * (self.high_warning - self.min)/(self.max - self.min)
		love.graphics.rectangle("fill", self.x, self.y, self.width, h)
	end

	if self.low_warning_enabled then
		local h = self.height * (self.low_warning - self.min)/(self.max - self.min)
		love.graphics.rectangle("fill", self.x, self.y + self.height, self.width, -h)
	end

	love.graphics.setColor(0.5,0,0)
	if self.high_redline_enabled then
		local h = self.height - self.height * (self.high_redline - self.min)/(self.max - self.min)
		love.graphics.rectangle("fill", self.x, self.y, self.width, h)
	end

	if self.low_redline_enabled then
		local h = self.height * (self.low_redline - self.min)/(self.max - self.min)
		love.graphics.rectangle("fill", self.x, self.y + self.height, self.width, -h)
	end
	love.graphics.setColor(1,1,1)
	love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
	if self.value > self.high_redline or self.value < self.low_redline then
		love.graphics.setColor(1,0,0)
	elseif (self.high_warning_enabled and self.value > self.high_warning) or (self.low_warning_enabled and self.value < self.low_warning) then
		love.graphics.setColor(1,0.5,0)
	end
	love.graphics.print(self.lable, self.x, self.y - 16)
	local x1 = self.x
	local x2 = self.x + self.width
	local y1 = self.needle_y
	local y2 = y1
	love.graphics.print(string.format(self.format, self.value), x2 + 2, y2 - 4)
	love.graphics.setColor(1,1,1)
	love.graphics.line(x1, y1, x2, y2)
end

function VerticalGauge:setHighRedline(redline)
	self.high_redline = redline
	self.high_redline_enabled = true
end

function VerticalGauge:setLowRedline(redline)
	self.low_redline = redline
	self.low_redline_enabled = true
end

function VerticalGauge:setHighWarning(warning)
	self.high_warning = warning
	self.high_warning_enabled = true
end

function VerticalGauge:setLowWarning(warning)
	self.low_warning = warning
	self.low_warning_enabled = true
end

function VerticalGauge:test()
	self.value = (self.max - self.min) * Range + self.min
end

Gauge_x = 32
Gauge_spacing = 64

Temp_gauge = VerticalGauge:new(Gauge_x + Gauge_spacing,128, "COOLANT", "%d\u{00B0}F", 100, 265)
Temp_gauge:setHighRedline(230)
Fuel_gauge = VerticalGauge:new(Gauge_x,128, "FUEL", "%d%%", 0, 100)
Fuel_gauge:setLowRedline(10)
Volt_gauge = VerticalGauge:new(Gauge_x + Gauge_spacing * 2, 128,"VOLTAGE", "%.1fV", 10.5, 15.2)
Volt_gauge:setHighRedline(14.8)
Volt_gauge:setLowWarning(13.8)
Volt_gauge.percent = 0
Volt_gauge.percent_map = {
	{10.50, 0},
	{11.31, 10},
	{11.58, 20},
	{11.75, 30},
	{11.9, 40},
	{12.06, 50},
	{12.2, 60},
	{12.32, 70},
	{12.42, 80},
	{12.5, 90},
	{12.6, 100},
}

function Volt_gauge:updateBatteryPercent()
	if self.value > 12.6 then
		self.percent = 100
	elseif self.value < 10.50 then
		self.percent = 0
	else
		local i = 1
		while self.value > self.percent_map[i+1][1] do
			i = i + 1
		end
		self.percent = (self.value - self.percent_map[i][1]) / (self.percent_map[i+1][1] - self.percent_map[i][1]) * (self.percent_map[i+1][2] - self.percent_map[i][2]) + self.percent_map[i][2]
	end

end

function Volt_gauge:drawBatteryPercent()
	if self.value < self.low_warning then
		if self.percent > 40 then
			love.graphics.setColor(0,1,0)
		elseif self.percent < 40 and self.percent > 25 then
			love.graphics.setColor(1,0.5,0)
		elseif self.percent < 25 then
			love.graphics.setColor(1,0,0)
		end
		local x = self.x + self.width + 2
		local y = self.needle_y - 20
		love.graphics.print(string.format("%d%%", self.percent), x, y)
	end
end

Oil_gauge = VerticalGauge:new(Gauge_x + Gauge_spacing * 3, 128,"OIL", "%dpsi", 0, 80)
Oil_gauge:setLowRedline(14)

function love.load()
	require "shaders"
	love.graphics.setColor(1,1,1,1)
	love.graphics.setDefaultFilter("nearest", "nearest", 1)
	shaders:init()
	shaders:set(1,"CRT.frag")
end

function love.update(dt)
	love.graphics.setShader(shader)
	if Range < 1 and Up then
		Range = Range + 0.01 * dt
	else
		Up = false
	end

	if Range > 0 and not Up then
		Range = Range - 0.01 * dt
	else
		Up = true
	end

	Mph = 90 * Range
	Rpm = Tachometer.redline_Rpm/Tachometer.redline_percent * Range


	Trip = Trip + (Mph * dt / 60 / 60)

	Tachometer.update(dt)

	Temp_gauge:test()
	Fuel_gauge:test()
	Volt_gauge:test()
	Oil_gauge:test()

	Temp_gauge:update()
	Fuel_gauge:update()
	Volt_gauge:update()
	Volt_gauge:updateBatteryPercent()
	Oil_gauge:update()
end

function love.draw()
	shaders:predraw()

	Tachometer.draw()
	Speedometer.draw()
	Odometer.draw()
	Temp_gauge:draw()
	Fuel_gauge:draw()
	Volt_gauge:draw()
	Volt_gauge:drawBatteryPercent()
	Oil_gauge:draw()

	shaders:postdraw()
end
