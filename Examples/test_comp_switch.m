clear all;
close all;
clc;

global DEBUGLEVEL
global simout

DEBUGLEVEL = 0;
simout = [];

Gen = devs(rand_generator("Gen",10));
Comp = devs(comparator("Comp",5));
sw = devs(comp_switch("switch"));
tw1 = devs(toworkspace("tw1","gen_out",0));
tw2 = devs(toworkspace("tw2","out1",0));
tw3 = devs(toworkspace("tw3","out2",0));
tw4 = devs(toworkspace("tw4","port",0));

N1 = coordinator("N1");
N1.add_model(sw);
N1.add_model(Gen);
N1.add_model(Comp);
N1.add_model(tw1);
N1.add_model(tw2);
N1.add_model(tw3);
N1.add_model(tw4);

N1.add_coupling("Gen","out","Comp","in");
N1.add_coupling("Gen","out","switch","in");
N1.add_coupling("Comp","out","switch","port");

N1.add_coupling("Gen","out","tw1","in");
N1.add_coupling("switch","out1","tw2","in");
N1.add_coupling("switch","out2","tw3","in");
N1.add_coupling("Comp","out","tw4","in");

N1.add_Select(@N1select);

root = rootcoordinator("root",0,20,N1,0);

root.sim();

subplot(3,1,1)
stem(simout.gen_out.t,simout.gen_out.y);
ylabel("Generator output");
xlabel("t");

subplot(3,1,2)
stem(simout.out1.t,simout.out1.y);
ylabel("Switch out1");
xlabel("t");

subplot(3,1,3)
stem(simout.out2.t,simout.out2.y);
ylabel("Switch out2");
xlabel("t");

function d = N1select(IMM)
    id = find_mdl_in_cell(IMM, "Comp");
    if isempty(id)
        d = IMM{1};
    else
        d = IMM{id};
    end
end