classdef comp_switch < handle
%% Description
%  switch
%% Ports
%  inputs: 
%    in        number
%    port      active port
%  outputs: 
%    out1      numbers <= C
%    out2      numbers > C
%% States
%  s: idle|out
%  port: active port
%  value
%% System Parameters
%  name:  object name

  properties
    s
    port
    value
    name
  end
    
  methods
    function obj = comp_switch(name)
      obj.s = "idle";
      obj.name = name;
      obj.port = "out1";
      obj.value = [];
    end
        
    function dint(obj)
        obj.s = "idle";
        obj.value = [];
    end
    
    function dext(obj,e,x)

        if isfield(x, "in")
            obj.value = x.in;
            obj.s = "out";
        end
        if isfield(x, "port")
            obj.port = x.port;
        end
    end
    
    function y = lambda(obj)
        y=[];
        if ~isempty(obj.value)
            if obj.port == "out1"
                y.out1 = obj.value;
            else
                y.out2 = obj.value;
            end
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
