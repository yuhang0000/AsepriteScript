--by:yuhang0000 2024-5-19
--现在不仅对话框窗口重做了, 连负责计时的代码也重写了, 真正完全自己写的 LOL

--初始变量
local SSS = 0
local MMM = 0
local HHH = 0
local startorpause = 0

--生成对话框
local TimerBar = Dialog("00:00:00")
local Hide233 = 0

--这又是一个循环器，但它不会堵塞主线程，在 https://aseprite.com/api/timer#timer 上找到的，这不比用死循环好用多了。
local timer1 = Timer
{
  interval=1.0,
  ontick=function()
    --计时器本体
    if (startorpause == 1) then 
      if (tonumber(SSS) < 59) then
      --呃，1+1=2，01+1=nil，这什么运算？？？
      SSS = SSS + 1;
      else
      SSS = 0;
        if (tonumber(MMM) < 59) then
        MMM = MMM + 1;
        else 
        MMM = 0;
        HHH = HHH + 1;
        end
      end
    end
    check()
  end 
}

	--默认窗口样式
	TimerBar:button{
	  id = "stopbutton",
		text = "■",
		onclick = 	function() 
            	timer1:stop()
		TimerBar:modify {id = "stopbutton",visible = false}
		TimerBar:modify {id = "startbutton",visible = false}
		TimerBar:modify {id = "Hidebutton",visible = false}
		TimerBar:modify {id = "yesbutton",visible = true}
		TimerBar:modify {id = "nobutton",visible = true,focus = true}
					end
	}
	TimerBar:button{
	  id = "startbutton",
		text = ">",
		focus = true,
		onclick = function() playbutton() end
	}
	TimerBar:button{
    id = "Hidebutton",
		text = "__",
		onclick = function() showorhide() end
	}
	TimerBar:button{
    id = "nobutton",
		text = "X",
		visible = false,
		onclick = function() 
            	timer1:start()
		TimerBar:modify {id = "stopbutton",visible = true}
		TimerBar:modify {id = "startbutton",visible = true,focus = true}
		TimerBar:modify {id = "Hidebutton",visible = true}
		TimerBar:modify {id = "yesbutton",visible = false}
		TimerBar:modify {id = "nobutton",visible = false} 
		end
	}
	TimerBar:show({wait=false})
	TimerBar:button{
    id = "yesbutton",
		text = "V",
		visible = false,
		onclick = 	function()
            startorpause = 1
		        TimerBar:modify {id = "stopbutton",visible = true}
		        TimerBar:modify {id = "startbutton",visible = true,focus = true}
		        TimerBar:modify {id = "Hidebutton",visible = true}
		        TimerBar:modify {id = "yesbutton",visible = false}
		        TimerBar:modify {id = "nobutton",visible = false} 
		        playbutton()
            SSS = 0;
            MMM = 0;
            HHH = 0;
            TimerBar:modify{ title = "00:00:00" }
					end
	}

--最小化与最大化
function showorhide ()
  if (Hide233 == 0) then
		  Hide233 = 1;
		  TimerBar:modify {
      id = "startbutton",
		  visible = false,
		  }
		  TimerBar:modify {
      id = "stopbutton",
	  	visible = false,
	  	}
	  	check();
      TimerBar:modify{ title = "" }
	  	else
		  Hide233 = 0;
		  TimerBar:modify {
      id = "startbutton",
	   	focus = true,
		  visible = true,
		  }
		  TimerBar:modify {
      id = "stopbutton",
	  	visible = true,
	  	}
		  TimerBar:modify {
      id = "Hidebutton",
	  	text = "__",
	  	check();
	  	}
  end
end

--开始或者暂停的判断
function playbutton ()
  if startorpause == 0 then
    startorpause = 1
    timer1:start()
    TimerBar:modify {
    id = "startbutton",
		text = "||",
		}
  else
    startorpause = 0
    timer1:stop()
    TimerBar:modify {
    id = "startbutton",
		focus = true,
		text = ">",
		}
  end
end

--打印当前时间
function check()
  if(string.len(SSS) < 2) then
    SSS = "0"..SSS;
    else
    SSS = SSS
  end
  if(string.len(MMM) < 2) then
    MMM = "0"..MMM;
    else
    MMM = MMM
  end
  if(string.len(HHH) < 2) then
    HHH = "0"..HHH;
    else
    HHH = HHH
  end
  if (Hide233 == 1) then
  TimerBar:modify {
    id = "Hidebutton",
    text = HHH .. ":" .. MMM .. ":" .. SSS
  }
  else
  TimerBar:modify{ title = HHH .. ":" .. MMM .. ":" .. SSS }
  end
end
