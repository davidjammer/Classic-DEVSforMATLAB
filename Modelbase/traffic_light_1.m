classdef traffic_light_1 < handle



  properties
    s
    name
    debug
  end
    
  methods
    function obj = traffic_light_1(name, debug)
      obj.s = "green";
      obj.name = name;
      obj.debug = debug;
    end
        
    function dint(obj)
      if obj.s == "green"
        obj.s = "yellow";
      elseif obj.s == "yellow"
        obj.s = "red";
      else
        obj.s = "green";
      end
    end
    
    function dext(obj,e,x)
      
    end
    

    function y = lambda(obj)
      if obj.s == "green"
        y.out = "show_yellow";
      elseif obj.s == "yellow"
        y.out = "show_red";
      else
        y.out = "show_green";
      end
    end
        
    function t = ta(obj)
      if obj.s == "green"
        t = 57;
      elseif obj.s == "yellow"
        t = 3;
      else
        t = 60;
      end 
    end

  end
end