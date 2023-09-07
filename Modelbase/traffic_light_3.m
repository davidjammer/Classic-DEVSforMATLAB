classdef traffic_light_3 < handle
    properties
        s
        name
        debug
    end

    methods
        function obj = traffic_light_3(name, debug)
            obj.s = "green";
            obj.name = name;
            obj.debug = debug;
        end

        function dint(obj)
            if obj.s == "green"
                obj.s = "yellow";
            elseif obj.s == "yellow"
                obj.s = "red";
            elseif obj.s == "red"
                obj.s = "green";
            elseif obj.s == "ToManual"
                obj.s = "Manual";
            elseif obj.s == "ToAutomatic"
                obj.s = "red";
            end
        end

        function dext(obj,e,x)
            if isfield(x,'in')
                if x.in == "manual"
                    obj.s = "ToManual";
                else
                    obj.s = "ToAutomatic";
                end
            end
        end


        function y = lambda(obj)
            if obj.s == "green"
                y.out = "show_yellow";
            elseif obj.s == "yellow"
                y.out = "show_red";
            elseif obj.s == "red"
                y.out = "show_green";
            elseif obj.s == "ToManual"
                y.out =  "show_black";
            elseif obj.s == "ToAutomatic"
                y.out = "show_red";
            end
        end

        function t = ta(obj)
            if obj.s == "green"
                t = 57;
            elseif obj.s == "yellow"
                t = 3;
            elseif obj.s == "red"
                t = 60;
            elseif obj.s == "Manual"
                t = inf;
            elseif obj.s == "ToManual"
                t = 0;
            elseif obj.s == "ToAutomatic"
                t = 0;
            end
        end

    end
end