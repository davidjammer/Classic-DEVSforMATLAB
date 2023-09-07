clear all;
close all;
clc;

global DEBUGLEVEL
global simout
global simin

DEBUGLEVEL = 0;
simout = [];

simin.in.t = [250,400];
simin.in.y = ["manual","automatic"];

A1 = devs(traffic_light_3("A1",0));
TW1 = devs(toworkspace("tw1","out_A1",0));
FromWorkspace = devs(fromworkspace("fw1","in",0));

N1 = coordinator("N1");
N1.add_model(A1);
N1.add_model(TW1);
N1.add_model(FromWorkspace);

N1.add_coupling("fw1","out","A1","in");
N1.add_coupling("A1","out","tw1","in");

root = rootcoordinator("root",0,600,N1,0);

root.sim();

figure
stairs(simout.out_A1.t, arrayfun(@(x)((x=="show_green")*1+(x=="show_yellow")*2+(x=="show_red")*3+(x=="show_black")*4),simout.out_A1.y));
grid on;
yticks([1,2,3,4]);
yticklabels({'green','yellow','red','black'});
ylim([0.9,4.1]);
