Threads = {}
Threads_Alive = {}

Threads_Timers = {}
Threads_Functions = {}
Threads_Once = {}
Threads_ActionTables = {}


Threads_Timers_Custom = {}
Threads_Functions_Custom = {}
Threads_Once_Custom = {}
Threads_ActionTables_Custom = {}

debuglog = false
busyspin = true

local function IsActionTableCreated(timer) return Threads_ActionTables[timer]  end 


Threads_Total = 0

local _CreateThread = CreateThread
local CreateThread = function(...)
    Threads_Total = Threads_Total + 1
    if debuglog then 
    print('CreateThread Total By Threads:'..Threads_Total.." on "..GetCurrentResourceName())
    end 
    return _CreateThread(...)
end 

Threads.loop = function(func,_timer, _name)
    if Threads_Once[_name] then return end 
	if debuglog and not _timer then 
		print("[BAD Hobbits]Some Threads.loop timer is nil on "..GetCurrentResourceName())
	end 
	
    local name = _name or 'default'
    local timer = _timer or 0

    local IsThreadCreated = IsActionTableCreated(timer) --Threads_ActionTables[timer] Exist
        
    
	if IsThreadCreated then  
        if Threads_Functions[name] then 
            print('[Warning]Threads'..name..' is doubly and replaced')  
            
        end 
        Threads_Alive[name] = true 
        Threads_Functions[name] = func
        Threads_Timers[name] = timer 
        
        table.insert(Threads_ActionTables[timer],name ) -- 如果default此毫秒已存在 則添加到循環流程中
    else                                -- 否則新建一個default的毫秒表 以及新建一個循環線程
		if Threads_Functions[name] then 
            print('[Warning]Threads'..name..' is doubly and replaced')  
            
        end 
        Threads_Alive[name] = true 
        Threads_Functions[name] = func
        Threads_Timers[name] = timer 
        
        Threads_ActionTables[timer] = {}	
        
        
		local actiontable = Threads_ActionTables[timer] 
		table.insert(Threads_ActionTables[timer] , name)
     
        
		CreateThread(function() 
			while true do
                local loadWait = false
                local _Wait = Wait
                local Wait = function(ms)
                    loadWait = true 
                    return _Wait(ms)
                end 
                if timer >= 0 then Wait(timer) end -- timer -1 -2 -3... is for Custom Wait but want to group all -1 -2 -3 ... loops together
                if not loadWait then 
                
                    Wait(0)
                end 
                
                if debuglog then print("Timer:"..timer,"Exist action threads total:"..#actiontable) end
                if #actiontable == 0 then 
                    return 
                end 
				for i=1,#actiontable do 
                    if Threads_Alive[actiontable[i]] and Threads_Functions[actiontable[i]] and Threads_Timers[actiontable[i]] == timer then 
                        Threads_Functions[actiontable[i]]()
                    else 
                        table.remove(Threads_ActionTables[timer] ,i);
                    end 
				end 
                
                
            end 
            return 
		end)
	end 
end

Threads.CreateLoop = function(...) 
    local tbl = {...}
    local length = #tbl
    local func,timer,name
    if length == 3 then 
        name = tbl[1]
        timer = tbl[2]
        func = tbl[3]
    elseif  length == 2 then 
        name = GetCurrentResourceName()
        timer = tbl[1]
        func = tbl[2]
    elseif  length == 1 then 
        name = GetCurrentResourceName()
        timer = 0
        func = tbl[1]
    end 
    if debuglog then print('threads:CreateLoop:CreateThread:'..timer, name) end
    Threads.loop(func,timer,name)
end


Threads.CreateLoopOnce = function(...) 
    local tbl = {...}
    local length = #tbl
    local func,timer,name
    if length == 3 then 
        name = tbl[1]
        timer = tbl[2]
        func = tbl[3]
    elseif  length == 2 then 
        name = GetCurrentResourceName()
        timer = tbl[1]
        func = tbl[2]
    elseif  length == 1 then 
        name = GetCurrentResourceName()
        timer = 0
        func = tbl[1]
    end 
    if not Threads_Once[name] then 
        if debuglog then print('threads:CreateLoopOnce:CreateThread:'..timer, name) end
        Threads.loop(func,timer,name)
        Threads_Once[name] = true 
    end 
end


Threads.loop_custom = function(func,_timer, _name)
    if Threads_Once[_name] then return end 
	if debuglog and not _timer then 
		print("[BAD Hobbits]Some Threads.loop timer is nil on "..GetCurrentResourceName())
	end 
	
    local name = _name or 'default'
    local timer = _timer or 0

    local IsThreadCreated = IsActionTableCreated(timer) --Threads_ActionTables_Custom[timer] Exist
        
    
	if IsThreadCreated then  
        if Threads_Functions_Custom[name] then 
            print('[Warning]Threads'..name..' is doubly and replaced')  
            
        end 
        Threads_Alive[name] = true 
        Threads_Functions_Custom[name] = func
        Threads_Timers_Custom[name] = timer 
        
        table.insert(Threads_ActionTables_Custom[timer],name ) -- 如果default此毫秒已存在 則添加到循環流程中
    else                                -- 否則新建一個default的毫秒表 以及新建一個循環線程
		if Threads_Functions_Custom[name] then 
            print('[Warning]Threads'..name..' is doubly and replaced')  
            
        end 
        Threads_Alive[name] = true 
        Threads_Functions_Custom[name] = func
        Threads_Timers_Custom[name] = timer 
        Threads_ActionTables_Custom[timer] = {}	
        
        
		local actiontable = Threads_ActionTables_Custom[timer] 
		table.insert(Threads_ActionTables_Custom[timer] , name)
     
        
		CreateThread(function() 
			while true do
                local loadWait = false
                local _Wait = Wait
                local Wait = function(ms)
                    loadWait = true 
                    return _Wait(ms)
                end 
                if timer >= 0 then Wait(timer) end -- timer -1 -2 -3... is for Custom Wait but want to group all -1 -2 -3 ... loops together
                if not loadWait then 
                
                    Wait(0)
                end 
                
                if debuglog then print("Timer:"..timer,"Exist action threads total:"..#actiontable) end
                if #actiontable == 0 then 
                    return 
                end 
				for i=1,#actiontable do 
                    if Threads_Alive[actiontable[i]] and Threads_Functions_Custom[actiontable[i]] and Threads_Timers_Custom[actiontable[i]] == timer then 
                        Threads_Functions_Custom[actiontable[i]]()
                    else 
                        table.remove(Threads_ActionTables_Custom[timer] ,i);
                    end 
				end 
                
                
            end 
            return 
		end)
	end 
end

Threads.CreateLoop = function(...) 
    local tbl = {...}
    local length = #tbl
    local func,timer,name
    if length == 3 then 
        name = tbl[1]
        timer = tbl[2]
        func = tbl[3]
    elseif  length == 2 then 
        name = GetCurrentResourceName()
        timer = tbl[1]
        func = tbl[2]
    elseif  length == 1 then 
        name = GetCurrentResourceName()
        timer = 0
        func = tbl[1]
    end 
    if debuglog then print('threads:CreateLoop:CreateThread:'..timer, name) end
    Threads.loop(func,timer,name)
end


Threads.CreateLoopOnce = function(...) 
    local tbl = {...}
    local length = #tbl
    local func,timer,name
    if length == 3 then 
        name = tbl[1]
        timer = tbl[2]
        func = tbl[3]
    elseif  length == 2 then 
        name = GetCurrentResourceName()
        timer = tbl[1]
        func = tbl[2]
    elseif  length == 1 then 
        name = GetCurrentResourceName()
        timer = 0
        func = tbl[1]
    end 
    if not Threads_Once[name] then 
        if debuglog then print('threads:CreateLoopOnce:CreateThread:'..timer, name) end
        Threads.loop(func,timer,name)
        Threads_Once[name] = true 
    end 
end

Threads.KillLoop = function(name)
    Threads_Alive[name] = false 
end 

Threads.CreateLoad = function(thing,loadfunc,checkfunc,cb)
    if debuglog then print('threads:CreateLoad:'..thing) end
    local handle = loadfunc(thing)
    local SinceTime = GetGameTimer()
    
    local failed = false
    local nowcb = nil     
    while true do 
        if not(checkfunc(thing)) and GetGameTimer() > SinceTime + 1000 then 
            if busyspin then 
            AddTextEntry("TEXT_LOAD", "Loading...")
            BeginTextCommandBusyspinnerOn("TEXT_LOAD")
            EndTextCommandBusyspinnerOn(4)
            end 
        end 
        if not(checkfunc(thing)) and GetGameTimer() > SinceTime + 5000 then 
            failed = true 
        end 
        if HasScaleformMovieLoaded ~= checkfunc then 
            if checkfunc(thing) then 
                nowcb = thing 
            end 
        else 
            local handle = loadfunc(thing)
            if checkfunc(handle) then 
                nowcb = handle 
            end 
        end 
        if failed then 
            break 
        elseif nowcb then  
            break
        end 
        Wait(33)
    end 
    if busyspin then 
        BusyspinnerOff()
    end 
    if failed then
        if debuglog then print('threads:CreateLoad:'..thing.."Loading Failed") end
    elseif nowcb then  
        cb(nowcb)
    end 
end
--[=[
CreateThread(function()
    
    Threads.CreateLoopOnce("test",1500,function()
        print(123)
    end)
     Threads.CreateLoopOnce("test",1500,function()
        print(999)
    end)
    Threads.CreateLoopOnce("test",999,function()
        print(999)
    end)
    Threads.CreateLoop("test2",1500,function()
        print(234)
        Threads.CreateLoop("test2",5000,function()
            print(155)
            Threads.KillLoop('test')
        end)
    end)
    
     Threads.CreateLoopOnce("test3",999,function()
        print(123123123)
    end)
    Threads.CreateLoop("test3",555,function()
        print(5555555)
    end)
    
end)
--]=]
--debug 
if debuglog then 
local thisname = "threads"

CreateThread(function()
	if IsDuplicityVersion() then 

		if GetCurrentResourceName() ~= thisname then 
			print('\x1B[32m[server-utils]\x1B[0m'..thisname..' is used on '..GetCurrentResourceName().." \n\x1B[32m[\x1B[33m"..thisname.."\x1B[32m]\x1B[33m"..GetResourcePath(GetCurrentResourceName())..'\x1B[0m')
		end 
		
		RegisterServerEvent(thisname..':log')
		AddEventHandler(thisname..':log', function(strings,sourcename)
			print(strings.." player:"..GetPlayerName(source).." \n\x1B[32m[\x1B[33m"..thisname.."\x1B[32m]\x1B[33m"..GetResourcePath(sourcename)..'\x1B[0m')
			
		end)
		
	else 
		if GetCurrentResourceName() ~= thisname then 
			TriggerServerEvent(thisname..':log','\x1B[32m[client-utils]\x1B[0m'..thisname..'" is used on '..GetCurrentResourceName(),GetCurrentResourceName())
		end 
	end 
end)
end 