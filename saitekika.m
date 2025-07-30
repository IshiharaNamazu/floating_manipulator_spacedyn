addpath('./SpaceDyn/src/matlab/spacedyn_v2r1'); % SpaceDyn のパスを追加
addpath('./torque_traj'); % SpaceDyn のパスを追加

clc
clear
close all

torque_param = {
    2, zeros(1,6), zeros(1,6);
    2, zeros(1,6), zeros(1,6);
    2, zeros(1,6), zeros(1,6);
    };

x0 = torque_serialize(torque_param);
%% 目的関数

function total = sum_torque_param_first_column(x)
torque_param = torque_deserialize(x);
total = 0;
for i = 1:size(torque_param, 1)
    total = total + torque_param{i, 1};
end
end

%% 線形不等式制約
A = [];

bb = [];

% disp('線形制約A:');
% disp(A);
% disp('線形制約bb:');
% disp(bb);

%% 線形等式制約
Aeq = [];
beq = [];

%% 上限，下限
lb = [];
ub = [];
for i = 1:length(torque_param)
    lb = [lb 0.5 -10.*ones(1,6) -10.*ones(1,6)]; % 各トルクの時間は0.5秒以上
    ub = [ub 30 10.*ones(1,6) 10.*ones(1,6)]; % 各トルクの時間は0.5秒以上
end

%% 非線形制約
function [c, ceq] = nonlinear_con(x)
v = ets7_dyn(torque_deserialize(x))
c = [];
ceq = [v];

end

x = fmincon(@sum_torque_param_first_column, x0, A, bb, Aeq, beq, lb, ub, @nonlinear_con);
disp(torque_deserialize(x))
% disp(sum_torque_param_first_column(x))
% disp([A*x' bb])

%ets7_dyn(torque_param)

