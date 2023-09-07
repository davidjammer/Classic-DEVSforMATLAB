classdef comparator < handle
%% Description
%  comparator
%% Ports
%  inputs: 
%    
%  outputs: 
%    out      "out2" if in > C else "out1"
%% States
%  s: idle|out
%  C: comp value
%% System Parameters
%  name:  object name
%  debug: flag to enable debug information

  properties
    s
    C
    input
    name
  end
    
  methods
    function obj = comparator(name, C)
      obj.s = "idle";
      obj.name = name;
      obj.C = C;
      obj.input = 0;
    end
        
    function dint(obj)
        obj.s = "idle";
    end
    
    function dext(obj,e,x)    
        if isfield(x, "in")
            obj.input = x.in;
            obj.s = "out";
        end
    end
    
    function y = lambda(obj)
        if obj.input > obj.C
            y.out = "out1";
        else
            y.out = "out2";
        end
    end
        
    function t = ta(obj)
      if obj.s == "out"
          t = 0;
      else
          t = inf;
      end
    end


  end
end
