classdef traffic_light_2 < handle
    properties
        s
        name
        debug
    end

    methods
        function obj = traffic_light_2(name, debug)
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
            if isfield(x,'in')
                if x.in == "manual"
                    obj.s = "manual";
                else
                    obj.s = "red";
                end
            end
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
            elseif obj.s == "red"
                t = 60;
            else
                t = inf;
            end
        end

    end
end