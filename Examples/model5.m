clear all;
close all;
clc;

global DEBUGLEVEL
global simout

DEBUGLEVEL = 0;
simout = [];

tend = 10;

N1 = coordinator('N1');
N2 = coordinator('N2');
N3 = coordinator('N3');

Generator11 = devs(generator('Generator11',1.00));
Generator12 = devs(generator('Generator12',1.00));
Pipe21 = devs(pipe('Pipe21'));
Pipe22 = devs(pipe('Pipe22'));
Pipe23 = devs(pipe('Pipe23'));
Pipe24 = devs(pipe('Pipe24'));
Pipe31 = devs(pipe('Pipe31'));
Pipe32 = devs(pipe('Pipe32'));
Terminator11 = devs(terminator('Terminator11'));
Terminator12 = devs(terminator('Terminator12'));
ToWorkspace21 = devs(toworkspace('logpipe21','pipe21',0));
ToWorkspace22 = devs(toworkspace('logpipe22','pipe22',0));
ToWorkspace23 = devs(toworkspace('logpipe23','pipe23',0));
ToWorkspace24 = devs(toworkspace('logpipe24','pipe24',0));
ToWorkspace31 = devs(toworkspace('logpipe31','pipe31',0));
ToWorkspace32 = devs(toworkspace('logpipe32','pipe32',0));

N1.add_model(Generator11);
N1.add_model(Generator12);
N1.add_model(Terminator11);
N1.add_model(Terminator12);
N1.add_model(N2);

N2.add_model(Pipe21);
N2.add_model(Pipe22);
N2.add_model(Pipe23);
N2.add_model(Pipe24);
N2.add_model(ToWorkspace21);
N2.add_model(ToWorkspace22);
N2.add_model(ToWorkspace23);
N2.add_model(ToWorkspace24);
N2.add_model(N3);

N3.add_model(Pipe31);
N3.add_model(Pipe32);
N3.add_model(ToWorkspace31);
N3.add_model(ToWorkspace32);

N1.add_coupling('Generator11','out','N2','in0');
N1.add_coupling('Generator12','out','N2','in1');
N1.add_coupling('N2','out0','Terminator11','in');
N1.add_coupling('N2','out1','Terminator12','in');

N2.add_coupling('N2','in0','Pipe21','in');
N2.add_coupling('N2','in1','Pipe22','in');
N2.add_coupling('Pipe21','out_d','N3','in0');
N2.add_coupling('Pipe22','out_d','N3','in1');
N2.add_coupling('Pipe21','out_p','logpipe21','in');
N2.add_coupling('Pipe22','out_p','logpipe22','in');
N2.add_coupling('N3','out0','Pipe23','in');
N2.add_coupling('N3','out1','Pipe24','in');
N2.add_coupling('Pipe23','out_d','N2','out0');
N2.add_coupling('Pipe24','out_d','N2','out1');
N2.add_coupling('Pipe23','out_p','logpipe23','in');
N2.add_coupling('Pipe24','out_p','logpipe24','in');

N3.add_coupling('N3','in0','Pipe31','in');
N3.add_coupling('N3','in1','Pipe32','in');
N3.add_coupling('Pipe31','out_d','N3','out0');
N3.add_coupling('Pipe32','out_d','N3','out1');
N3.add_coupling('Pipe31','out_p','logpipe31','in');
N3.add_coupling('Pipe32','out_p','logpipe32','in');

N1.add_Select(@N1select);
N2.add_Select(@N2select);

root = rootcoordinator('root',0,tend,N1,0);
tic;
root.sim();
ta=toc

figure(2)
subplot(3,2,1)
stem(simout.pipe21.t,simout.pipe21.y); grid on;
xlim([0 tend]);
xlabel('simulation time');
ylabel('out_p');
title('pipe21');

subplot(3,2,3)
stem(simout.pipe31.t,simout.pipe31.y); grid on;
xlim([0 tend]);
xlabel('simulation time');
ylabel('out_p');
title('pipe31');

subplot(3,2,5)
stem(simout.pipe23.t,simout.pipe23.y); grid on;
xlim([0 tend]);
xlabel('simulation time');
ylabel('out_p');
title('pipe23');

subplot(3,2,2)
stem(simout.pipe22.t,simout.pipe22.y); grid on;
xlim([0 tend]);
xlabel('simulation time');
ylabel('out_p');
title('pipe22');

subplot(3,2,4)
stem(simout.pipe32.t,simout.pipe32.y); grid on;
xlim([0 tend]);
xlabel('simulation time');
ylabel('out_p');
title('pipe32');

subplot(3,2,6)
stem(simout.pipe24.t,simout.pipe24.y); grid on;
xlim([0 tend]);
xlabel('simulation time');
ylabel('out_p');
title('pipe24');

function d = N1select(IMM)
id = find_mdl_in_cell(IMM, "N2");
if isempty(id)
    d = IMM{1};
else
    d = IMM{id};
end
end

function d = N2select(IMM)
id = find_mdl_in_cell(IMM, "Pipe23");
if isempty(id)
    id = find_mdl_in_cell(IMM, "Pipe24");
end

if isempty(id)
    id = find_mdl_in_cell(IMM, "N3");
    if isempty(id)
        d = IMM{1};
    else
        d = IMM{id};
    end
else
    d = IMM{id};
end
end