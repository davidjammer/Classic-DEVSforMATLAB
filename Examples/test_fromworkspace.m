clear all;
close all;
clc;

global DEBUGLEVEL
global simout
global simin

DEBUGLEVEL = 0;
simout = [];
simin = [];

tend = 20;

simin.in.t = [0,2,4,8,16];
simin.in.y = [1,2,3,4,5];

N1 = coordinator('N1');

FromWorkspace = devs(fromworkspace("fw1","in",0));
ToWorkspace = devs(toworkspace('tw1','out',0));

N1.add_model(FromWorkspace);
N1.add_model(ToWorkspace);

N1.add_coupling('fw1','out','tw1','in');

root = rootcoordinator('root',0,tend,N1,0);
tic;
root.sim();
ta=toc

figure
stem(simout.out.t,simout.out.y); grid on;
xlim([0 tend]);
xlabel('simulation time');
ylabel('out');