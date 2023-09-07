classdef rand_generator < handle
%% Description
%  produce random numbers
%% Ports
%  inputs: 
%    
%  outputs: 
%    out      random numbers
%% States
%  s: idle
%% System Parameters
%  name:  object name
%  debug: flag to enable debug information

  properties
    s
    name
  end
    
  methods
      function obj = rand_generator(name, seed)
      obj.s = "idle";
      obj.name = name;
      rng(seed);
    end
        
    function dint(obj)
      
    end
    
    function dext(obj,e,x)
     
    end
    
    function y = lambda(obj)
     y.out = randi(10,1);
    end
        
    function t = ta(obj)
      t = 1;
    end


  end
end
