clear all;
close all;
clc;

global DEBUGLEVEL
global simout

DEBUGLEVEL = 0;
simout = [];

tend = 10;

N1 = coordinator('N1');

Generator = devs(generator('Generator',1.0));
Pipe = devs(pipe('Pipe'));
Terminator = devs(terminator('Terminator'));
ToWorkspace = devs(toworkspace('logpipe','pipe',0));

N1.add_model(Generator);
N1.add_model(Pipe);
N1.add_model(Terminator);
N1.add_model(ToWorkspace);

N1.add_coupling('Generator','out','Pipe','in');
N1.add_coupling('Pipe','out_d','Terminator','in');
N1.add_coupling('Pipe','out_p','logpipe','in');




root = rootcoordinator('root',0,tend,N1,0);
tic;
root.sim();
ta=toc

figure(2)
stem(simout.pipe.t,simout.pipe.y); grid on;
xlim([0 tend]);
xlabel('simulation time');
ylabel('out_p');
title('pipe');