do
	Life = {}
	local mt = { __index = Life }

	function Life.new(m, n)
		local matrix = {}
		local next = {}
		return setmetatable({
			matrix = matrix,
			next = next,
			m = m,
			n = n,
		}, mt)
	end

	function Life:set_pos(x,y,M)
		if M == nil then M = self.matrix end
		if M[x] == nil then M[x]={} end
		M[x][y]=1
	end

	function Life:unset_pos(x,y,M)
		if M == nil then M = self.matrix end
		if M[x] == nil then M[x]={} end
		M[x][y]=0
	end

	function Life:get_pos(x,y,M)
		if M == nil then M = self.matrix end
		if M[x] == nil then M[x]={} end
		if M[x][y] == nil then M[x][y] = 0 end
		return M[x][y]
	end

	function Life:next_gen()
		local X = self.next
		local matrix = self.matrix
		local modified = false
		for i = 1, self.m do
			for j = 1, self.n do
				local s = 0
				for p = i-1,i+1 do
					for q = j-1,j+1 do
						if p > 0 and p <= self.m and q > 0 and q <= self.n then
							s = s + self:get_pos(p,q)
						end
					end
				end
				s = s - self:get_pos(i,j)
				if s == 3 or (s+self:get_pos(i,j)) == 3 then
					if self:get_pos(i,j,X) ~= 1 then
						modified = true
					end
					self:set_pos(i,j,X)
				else
					if self:get_pos(i,j,X) ~= 0 then
						modified = true
					end
					self:unset_pos(i,j,X)
				end
			end
		end
		if modified then
			self.stagnant = 0
		else
			self.stagnant = self.stagnant + 1
		end
		self.next = self.matrix
		self.matrix = X
	end

	function Life:display(scale)
		disp:clearBuffer()
		local matrix = self.matrix
		for i = 1, self.m do
			for j = 1, self.n do
				if self:get_pos(i,j) == 1 then
					disp:drawBox(i*scale,j*scale,scale,scale)
				end
			end
		end
		disp:sendBuffer()
	end
end

local function start()
	local life = Life.new(32, 16)
	life.stagnant = 100

	local function randomizeLife()
		math.randomseed(time)
		for i=0,31 do
			for j=0,15 do
				if math.random()<0.4 then
					life:set_pos(i,j)
				end
			end
		end
	end

	local function doStep()
		if life.stagnant >= 10 then randomizeLife() end
		life:next_gen()
		life:display(4)
	end

	doStep()

	local timer = tmr.create()
	timer:alarm(500, tmr.ALARM_AUTO, doStep)
	registerButtons(function()
		timer:unregister()
		require('main-menu')()
	end)
end

return start
