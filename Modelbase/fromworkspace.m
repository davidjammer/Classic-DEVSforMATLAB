classdef fromworkspace < handle
%% Description
%  set output from global simin
%% Ports
%  inputs: 
%  outputs: 
%    out      
%% States
%  s:   running
%% System Parameters
%  name:  object name
%  debug: flag to enable debug information
%  value:   const. value    
  properties
    s
    name
    debug
    varname
    index
    sigma
  end
  
  methods
    function obj = fromworkspace(name, varname, debug)
      obj.s ="start"; 
      obj.name = name;
      obj.varname = varname;
      obj.debug = debug;
	 obj.index = 1;
	 obj.sigma = 0;
    end
          
    function dint(obj)
	   global simin
	   
	   obj.s = "running";
	   
	   if obj.index == length(simin.(obj.varname).t)
		  obj.sigma = inf;
	   else
		  obj.index = obj.index + 1;
		  obj.sigma = simin.(obj.varname).t(obj.index) - simin.(obj.varname).t(obj.index - 1);
	   end
    end

    function dext(obj,e,x)

    end     

    function y = lambda(obj,e,x)
	   global simin
	   
	   y.out = simin.(obj.varname).y(obj.index);
    end
    
    function t = ta(obj)
	   global simin
	   
	   if obj.s == "start"
		  t = simin.(obj.varname).t(1);
	   else
		  t = obj.sigma;
	   end
    end
   
  end
end
