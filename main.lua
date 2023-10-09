frame = 0
love.window.setTitle("Clicker Game")
countDownTime = {60*9000,60*22,60*10,60*6.5,60*4.5,60*2.5,4}
difficultyNames = {"Not Even Fun","Baby", "EZ","Normal","Harder","Hard","Imposible"}
difficulty = 4
fade = nil
fade = love.graphics.newCanvas(1,love.graphics.getHeight()/2)
fade:renderTo(function()
	love.graphics.clear()
	for i=1,fade:getHeight() do
		love.graphics.setColor(1,1,1,(1/fade:getHeight())*i)
		--love.graphics.setColor(0,0,0,(1/fade:getHeight())*i)
		love.graphics.points(0,i)
	end
end)
fadeC = love.graphics.newCanvas(200,200)
local rings = 90
fadeC:renderTo(function()
	love.graphics.setColor(0,0,0,1/rings)
	for i=1,rings do
		love.graphics.circle("line",100,100,100)
		love.graphics.setLineWidth(i-rings)
	end
end)
function love.load()
	gameover = false--
	gameStarted = false
	font = love.graphics.newFont(24)
	love.mouse.setVisible(false)
	adsShowable = false
	adCoundownRange = {60*6,60*16}
	adLifespanRange = {60*3.5,60*9}
	adCountdown = 60*2.25
	adLifespan = 60*4
	adLifespan = 0
	currentAd = {}
	rframes = 0
	clicks = 1
	nerfsAdded = 0
	nerfCountdown = countDownTime[difficulty]
	--nerfCountdown = 85
	startingNerfCountdown = nerfCountdown
	bgbars = 16
	nerfs = {}
	nerfGroup = 1
	buffGroup = 1
	onBuyButton=false
	screenScale = 0
	--for i=1,16 do table.insert(nerfs,{name="",group="blank"})
	nerfs[2] = {name="Welcome!",effect=2,group="memo",time=60*3.5,delete=true}
	nerfs[1] = {name="Time Freeze",effect=2,new=true,buff=true,group="freeze"}
	nerfs[3] = {name="Click circle to start. Hold 'R' to reset.",effect=2,new=true,buff=false,group="memo"}
	nerfs[4] = {name="Buffs are effects that help you out.",effect=2,group="memo"}
	nerfs[5] = {name="Nerfs are effects that hurt you!",effect=2,group="memo"}
	nerfs[6] = {name="Temporary effects (marked with 'Temp') wear off over time.",effect=2,group="memo"}
	nerfs[7] = {name="Each time the timer in the corner runs out, a new nerf is added!",effect=2,group="memo"}
	nerfs[8] = {name="Look out for the ads that show up in the bottom.",effect=2,group="memo"}
	nerfs[9] = {name="They can sell buffs that help you out.",effect=2,group="memo"}
	nerfs[10] = {name="If you have enough points, you can purchase items with space bar.",effect=2,group="memo"}
	nerfs[12] = {name="If you get to 0 points, you lose!",effect=2,group="memo"}
	nerfs[13] = {name="",group="blank",effect=2}
	nerfs[14] = {name="",group="blank",effect=2}
	nerfs[15] = {name="",group="blank",effect=2}
	nerfs[16] = {name="",group="blank",effect=2}
	nerfs[11] = {name="",group="blank",effect=2}
	buttonOffset={x=0,y=0}
	bmemo = "Currently untitled clicker game build 3"
	timeToNerf = nerfCountdown
	love.graphics.setBackgroundColor(50/255, 151/255, 168/255)
	circleSize = 100
	colorOffset = {}
	for i=1,150 do
		colorOffset[i] = love.math.random()
		--print(colorOffset[i])
	end


	mouseTrail = {}
	--for i=1,24 do
	--	table.insert(mouseTrail,{-1,-1})
	--end
end

function timerStencil()
	love.graphics.arc("fill",love.graphics.getWidth()-40,love.graphics.getHeight()-40,30,math.rad((timeToNerf/countDownTime[difficulty])*360),0)
end
function buttonStencil()
	love.graphics.circle("fill",love.graphics.getWidth()/2+buttonOffset.x, love.graphics.getHeight()/2+buttonOffset.y,circleSize)
end

function love.update()
	local trash = love.math.random(1,512)
	presets = {}

	presets[1] = {name="Very Tiny Leak",nerf=true,buff=false,group="leak",effect=1,option1=120,option2=-3,addableAt=1,real=true,time=60*7.5}

	presets[2] = {name="El Cheapo Wrench",buff=true,group="wrench",effect=3,option1="leak",option2=0,time=60*9,desc="A flimsy wrench that fixes all leaks.",price=99,byableAt=1,real=true}

	presets[3] = {name="Hacker AutoClicker",buff=true,group="clicker",effect=1,option1=1,option2=4096*4,desc="The only way to get this is by cheating, it is is a little bit overpowered.",price=115,real=true}

	presets[4] = {name="Thief",nerf=true,effect=1,option1=8,option2=-1,time=28*6,group="thief"}

	presets[5] = {name="Part-time Cop",buff=true,effect=3,option1="thief",option2=-4,time=500,price=125,desc="A part time cop that swiftly arrests all thieves, but charges a small fee",group="cop"}

	presets[6] = {name="Tiny Leak", nerf = true,group="leak",effect=1,option1=60,option2=-1}

	presets[7] = {name="Basic Autoclicker",buff=true,group="clicker",effect=1,option1=10,option2=1,price=115,time=10*135,desc="Autoclicker that slowly click the button for you."}

	presets[8] = {name="Leak",nerf=true,group="leak",effect=1,option1=55,option2=-1}

	presets[9] = {name="Timer speedup",nerf=true,group="misc",effect=4,option1=-1,time=60*14}

	presets[10] = {name="Small Anti-Freeze",nerf=true,group="antifreeze",effect=3,option1="freeze",option2=0,time=60*4}

	presets[11] = {name="Better AutoClicker",buff=true,group=clicker,option1=10,option2=2,price=115,time=10*135,desc="Autoclicker that slowly click the button for you.",price=259}

	presets[12] = {name="Ice Cube",buff=true,group="freeze",effect=4,option1=1,time=60*8,desc="An ice cube that freezes the timer but melts quickly.",price=199}

	presets[13] = {name="Cop",buff=true,group="cop",effect=3,option1="thief",option2=0,price=339,desc="A cop that arrests thieves.",time=60*40}

	presets[14] = {name="Mystery Box",buff=true,group="misc",effect=0,price=375,desc="A super cool mystery box you don't want to miss out on! Who know what it will do or what is inside! Better find out!"}

	presets[15] = {name="Toilet Paper Rolls",group="tp",effect=0,price=19,desc="If you stock up on these now, you can sell them when the price goes up!"}

	--------------------------------------------------
	nerfSpawns = {
		{presets[1],presets[1],presets[4],presets[1]},
		{presets[9],presets[8],presets[4],presets[6],presets[10],presets[8]},		
	}

	adSpawns = {
		{presets[2],presets[2],presets[5],presets[7],presets[15]},
		{presets[2],presets[12],presets[13],presets[7],presets[11],presets[14],presets[15],}
	}
	--print( (nerfSpawns[1])[1].time )
	--print( (presets[1].time ) )

	if clicks < 0 then clicks = 0 end

	local g = 1
	frame = frame + 1
	--nerfs[1] = {name="Basic AutoClicker",buff=true,group="clicker",effect=1,option1=1,option2=-8,desc="A basic autoclicker that will click for you.",time=265,price=115,buyableAt=2}
	timeToNerf = timeToNerf - 1

	---------------------------------------
	nerfCountdown = countDownTime[difficulty]

	if nerfGroup == 1 and clicks > 300 then
		nerfGroup = 2
	end

	if buffGroup == 1 and clicks > 375 then
		buffGroup = 2
	end

	if timeToNerf < 1 then
		nerfsAdded = nerfsAdded + 1

		timeToNerf = nerfCountdown
		adsShowable = true

		--table.insert(nerfs, presets[(nerfSpawns[1])[love.math.random(1,3)]] )
		local insert = (nerfSpawns[nerfGroup])[math.random(1,#nerfSpawns[nerfGroup])]
		table.insert(nerfs, insert)
		--print(insert.time)
		--print(love.math.random(1,3))
		--print("pleas help me!!!")
		onBuyButton=false
	if love.mouse.getY()>love.graphics.getHeight()-125 and math.abs(love.mouse.getX()-love.graphics.getWidth()/2)<love.graphics.getWidth()/6 then
		onBuyButton=true
	end

		cleanTable()
	end
	if adsShowable then
		adLifespan = adLifespan - 1
		if adLifespan < 1 then
			adCountdown = adCountdown - 1
		end
		if adLifespan < 0 then currentAd = {} end
		if adCountdown < 0 then
			adCountdown = love.math.random(adCoundownRange[1],adCoundownRange[2])
			currentAd = (adSpawns[buffGroup])[love.math.random(1,#adSpawns[buffGroup])]
			adLifespan = love.math.random(adLifespanRange[1],adLifespanRange[2])
		end
		if love.keyboard.isDown("space") and adLifespan > 1 then
			if clicks >= currentAd.price then
				clicks = clicks - currentAd.price
				table.insert(nerfs,currentAd)
				adLifespan = 1
				currentAd = {}
			end
		end
		
	end

	if love.keyboard.isDown("r") then
		rframes = rframes + 2
	else rframes = rframes - 2 end
	if rframes > 120 then love.load() end
	rframes = math.clamp(0, rframes, 200)
	nerfCountdown = startingNerfCountdown

	if clicks == 0 then gameover = true end

	if not gameover then
		doNerfs()
	else
		clicks = 0
		adLifespan = 0
		adCountdown = 1000
		timeToNerf = timeToNerf + 1
	end

	cleanTable()
	if #nerfs > 16 then
		table.remove(nerfs,1)
	end

	table.insert(mouseTrail,{love.mouse.getX(),love.mouse.getY()})
	if #mouseTrail > 25 then table.remove(mouseTrail,1) end

end

function love.draw()
		if screenScale < 1 then
			love.graphics.scale(screenScale,1)
			screenScale = screenScale + 0.05
		end
		--doNerfs()

		bg()
        dist = math.sqrt( ((love.mouse.getX()-(love.graphics.getWidth()/2+buttonOffset.x))^2) + ((love.mouse.getY()-(love.graphics.getHeight()/2+buttonOffset.y))^2) )
        love.graphics.setColor(1,1,1)

        love.graphics.print(clicks,font, love.graphics.getWidth()/2, 50,0,2,nil,font:getWidth(clicks)/2)

        love.graphics.setColor(28/255, 85/255, 94/255)

        love.graphics.circle("fill",love.graphics.getWidth()/2+buttonOffset.x, love.graphics.getHeight()/2+buttonOffset.y,circleSize)
        if love.mouse.isDown(1) and dist < circleSize then
                love.graphics.setColor(37/255, 114/255, 128/255)
                love.graphics.circle("fill",love.graphics.getWidth()/2+buttonOffset.x, love.graphics.getHeight()/2+buttonOffset.y,circleSize+0)
        end
		--love.graphics.setColor(1,1,1,0.5)
		love.graphics.stencil(buttonStencil, "replace", 1)
    	love.graphics.setStencilTest("greater", 0)
			--love.graphics.rectangle("fill",love.mouse.getX(),love.mouse.getY(),300,300)
			--love.graphics.circle("fill",love.graphics.getWidth()/2+buttonOffset.x-circleSize, love.graphics.getHeight()/2+buttonOffset.y-circleSize,10)
			love.graphics.setColor(1,1,1,0.1)
			for i=1,10 do
				love.graphics.circle("line",love.graphics.getWidth()/2+buttonOffset.x, love.graphics.getHeight()/2+buttonOffset.y,circleSize-((i-1)*10)-(frame/4)%10)
			end
			love.graphics.setColor(1,1,1,0.5)
			love.graphics.draw(fadeC,love.graphics.getWidth()/2+buttonOffset.x-circleSize, love.graphics.getHeight()/2+buttonOffset.y-circleSize)

    	love.graphics.setStencilTest()
		love.graphics.print(bmemo,8,love.graphics.getHeight()-20)
		love.graphics.print(love.timer.getFPS(),love.graphics.getWidth()-25,0)
		if math.abs(love.timer.getFPS()-60) > 3 then
			love.graphics.print("Game is not running at intended frame-rate!",love.graphics.getWidth()-300,25)
		end

	
love.graphics.arc("line",love.graphics.getWidth()-40,love.graphics.getHeight()-40,30,math.rad((timeToNerf/countDownTime[difficulty])*360),0)	

		love.graphics.setColor(1,1,1,0.5)
love.graphics.arc("fill",love.graphics.getWidth()-40,love.graphics.getHeight()-40,30,math.rad((timeToNerf/countDownTime[difficulty])*360),0)

		love.graphics.stencil(timerStencil, "replace", 1)
    	love.graphics.setStencilTest("greater", 0)
		local spacing = 8
		--love.graphics.setColor(1,1,1,0.25)
		for i=1,12 do
		--love.graphics.setLineWidth(4)
			love.graphics.line(love.graphics.getWidth()-80,love.graphics.getHeight()-80+((i-1)*spacing)+frame/2%spacing,love.graphics.getWidth(),love.graphics.getHeight()-80+((i-1)*spacing)+frame/2%spacing)
		--love.graphics.setLineWidth(1)
		--	love.graphics.line(love.graphics.getWidth()-80,love.graphics.getHeight()-80+((i-1)*spacing)+frame/2%spacing,love.graphics.getWidth(),love.graphics.getHeight()-80+((i-1)*spacing)+frame/2%spacing)
		end
		love.graphics.setStencilTest()
	


		love.graphics.setColor(1,1,1)
		love.graphics.rectangle("fill",0,love.graphics.getHeight()-(math.clamp(0,rframes/2,20)), (love.graphics.getWidth()/120)*rframes,20)

		love.graphics.print("Current Effects:")

		for i=1,#nerfs do
			local outprint = "["
			if nerfs[i].nerf then outprint = outprint .. "Nerf" end
			if nerfs[i].buff then outprint = outprint .. "Buff" end
			if nerfs[i].group == "memo" then outprint = outprint .. "Memo" end
			if nerfs[i].time ~= nil then outprint = outprint .. ", Temp" end
			outprint = outprint .. "] " .. nerfs[i].name


			love.graphics.print(outprint,0,i*25)
		end
		if currentAd.name ~= nil then
			--print(currentAd.name)
			love.graphics.printf( currentAd.name, font, math.floor(love.graphics.getWidth()/2), love.graphics.getHeight()-100, font:getWidth(currentAd.name), "center", nil, nil, nil, font:getWidth(currentAd.name)/2)

			love.graphics.print("For Sale! ("..currentAd.price.." points)",math.floor((love.graphics.getWidth()/2)-(font:getWidth(currentAd.name)/2)),love.graphics.getHeight()-150)

	love.graphics.print("Press spacebar to buy! ("..math.floor(adLifespan/60).." secs left)",math.floor((love.graphics.getWidth()/2)-(font:getWidth(currentAd.name)/2)),love.graphics.getHeight()-125)

			love.graphics.printf( currentAd.desc, math.floor(love.graphics.getWidth()/2), love.graphics.getHeight()-70, math.floor(font:getWidth(currentAd.name)), "center", nil, nil, nil, math.floor(font:getWidth(currentAd.name)/2))

			love.graphics.setColor(1,1,1,0.5)
			--love.graphics.rectangle("fill",math.floor((love.graphics.getWidth()/2)-font:getWidth(currentAd.name)/2),love.graphics.getHeight()-100,(love.graphics.getWidth()/2)-font:getWidth(currentAd.name),1000)
		end

	love.graphics.setColor(0,0,0)
	love.graphics.circle("line",love.mouse.getX()+1,love.mouse.getY()+1,10)
	love.graphics.line(love.mouse.getX()+1,love.mouse.getY()+5+1,love.mouse.getX()+1,love.mouse.getY()+15+1)
	love.graphics.line(love.mouse.getX()+1,love.mouse.getY()-5+1,love.mouse.getX()+1,love.mouse.getY()-15+1)
	love.graphics.line(love.mouse.getX()+5+1,love.mouse.getY()+1,love.mouse.getX()+15+1,love.mouse.getY()+1)
	love.graphics.line(love.mouse.getX()-5+1,love.mouse.getY()+1,love.mouse.getX()-15+1,love.mouse.getY()+1)
	love.graphics.setColor(1,1,1)
	love.graphics.circle("line",love.mouse.getX(),love.mouse.getY(),10)
	love.graphics.line(love.mouse.getX(),love.mouse.getY()+5,love.mouse.getX(),love.mouse.getY()+15)
	love.graphics.line(love.mouse.getX(),love.mouse.getY()-5,love.mouse.getX(),love.mouse.getY()-15)
	love.graphics.line(love.mouse.getX()+5,love.mouse.getY(),love.mouse.getX()+15,love.mouse.getY())
	love.graphics.line(love.mouse.getX()-5,love.mouse.getY(),love.mouse.getX()-15,love.mouse.getY())

	if love.mouse.getY()>love.graphics.getHeight()-125 and math.abs(love.mouse.getX()-love.graphics.getWidth()/2)<love.graphics.getWidth()/6 
 and currentAd.price ~= nil and currentAd.price < clicks then
		love.graphics.print("Buy",love.mouse.getX()+15,love.mouse.getY()-5)
	end

	love.graphics.setPointSize(5)
	for i=1,#mouseTrail-1 do
		if (mouseTrail[i])[1] ~= -1 then
		love.graphics.setLineWidth((5/#mouseTrail)*i)
		love.graphics.setColor(1,1,1,(1/#mouseTrail)*i)
		love.graphics.setColor(1,1,1)
		love.graphics.line((mouseTrail[i])[1],(mouseTrail[i])[2],(mouseTrail[i+1])[1],(mouseTrail[i+1])[2])
	end end
	love.graphics.setLineWidth(2)

	if gameover then
		love.graphics.setColor(0,0,0,0.5)
		love.graphics.rectangle("fill",0,0,love.graphics.getWidth(),love.graphics.getHeight())
		love.graphics.setColor(1,0,0)
		love.graphics.printf("Game Over",font,(love.graphics.getWidth()/2)-(font:getWidth("Game Over")/2),love.graphics.getHeight()/2,font:getWidth("Game Over"),"center")
		love.graphics.printf("Hold 'R'",font,(love.graphics.getWidth()/2)-(font:getWidth("Hold 'R'")/2),love.graphics.getHeight()/2+100,font:getWidth("Hold 'R'"),"center")
	end
	if not gameStarted then
		local m = "Use keys 1-"..#countDownTime.." to pick difficulty"
		love.graphics.print(m,font,love.graphics.getWidth()/2,(love.graphics.getHeight()/4)*3,nil,nil,nil,font:getWidth(m)/2)
		m = "Current Difficulty("..difficulty.."): "..difficultyNames[difficulty]
		love.graphics.print(m,font,math.floor(love.graphics.getWidth()/2),(love.graphics.getHeight()/4)*3+75,nil,nil,nil,font:getWidth(m)/2)
		for i=1,#countDownTime do
			if love.keyboard.isDown(tostring(i)) then
				difficulty = i
			end
		end
		nerfCountdown = countDownTime[difficulty]
		timeToNerf = nerfCountdown
	end
end


function love.mousepressed()
	clicked()
end
function bg()
	offsets={}
	for i=1,bgbars do --VVV very bad VVV
		offsets[i] = math.sin(((6)*frame+(i*(4.375*bgbars)))/100)/25
	end
	for i=1,bgbars do
		love.graphics.setColor((50/255)+offsets[i], (151/255)+offsets[i], (168/255)+offsets[i])
		love.graphics.rectangle("fill",0,(love.graphics.getHeight()/bgbars)*(i-1),love.graphics.getWidth(),love.graphics.getHeight()/bgbars)
	end

	for i=1,bgbars do
		love.graphics.setColor((50/255)+offsets[i], (151/255)+offsets[i], (168/255)+offsets[i])
		love.graphics.rectangle("fill",0,(love.graphics.getHeight()/bgbars)*(i-1),love.graphics.getWidth(),love.graphics.getHeight()/bgbars)
	end
	love.graphics.setColor(50/255, 151/255, 168/255)
	love.graphics.draw(fade,0,love.graphics.getHeight()-fade:getHeight(),0,love.graphics.getWidth(),1)
	love.graphics.draw(fade,0,fade:getHeight(),0,love.graphics.getWidth(),-1)
end

-- Clamps a number to within a certain range.
function math.clamp(low, n, high) return math.min(math.max(low, n), high) end

--[[
	effects:
	0: No effect

	1: Click add/remove
		changes score by a certian amout ever X frames
		opt1(numb):modify clicks every {X} frames
		opt2(numb):modify clicks by {X} amount

	2: Start of game freezer
		Fully freezes time and gets deleted when score passes one

	3: Group deleter
		Each frame all of the effects of a certain group are removed
		opt1(string):target group
		opt2(numb):change score by X each delete

	4: Nerf countdown chage
		opt1(numb): Change timer by X


--]]

function doNerfs()
--	love.graphics.setColor(1,1,1)
--	love.graphics.circle("fill",50,50,50)
--	love.graphics.print("Current Effects:")
	for i=1,#nerfs do
	if nerfs[i] ~= nil then
		local printout = "["
		if nerfs[i].nerf then printout = printout.."Nerf" end
	

		love.graphics.print(printout,0,i*25)

		if nerfs[i].effect == 1 then
			if frame % nerfs[i].option1 == 0 then
				clicks = clicks + nerfs[i].option2
			end
		elseif nerfs[i].effect == 2 then
			timeToNerf = countDownTime[difficulty]
			if clicks > 1 then
				--nerfs[i]=nil	
				nerfs[i].delete=true	
				gameStarted	= true
			end
		elseif nerfs[i].effect == 3 then
			for j=1,#nerfs do
				if nerfs[j].group == nerfs[i].option1 then
					nerfs[j].delete = true
					clicks=clicks+nerfs[i].option2
				end
			end
		elseif nerfs[i].effect == 4 then
			timeToNerf = timeToNerf + nerfs[i].option1
		end

		if nerfs[i].time ~= nil then
			nerfs[i].time = nerfs[i].time - 1
		end
		if nerfs[i].time ~= nil and nerfs[i].time < 0 then
			nerfs[i].delete = true
		end
		if nerfs[i].delete then
			nerfs[i] = {name="",group="blank",time=nil}
		end
	end
			
end
function clicked()
        --print(dist)
    if dist < circleSize then
		clicks = clicks + 1
	end
end
function cleanTable()
		local tmp = {}
		for i=1,#nerfs do
			if nerfs[i].name ~= "" then
				table.insert(tmp,nerfs[i])
			end
		end
	nerfs = tmp
	for i=1,16-#nerfs do
		table.insert(nerfs,{name="",group="blank",time=nil})
	end
end
end