function torque = calc_torque(torque_param, t)

torque = torque_param{1, 2}'*0; % 初期化

t_sum = 0;

i = 1;
while t > t_sum+ torque_param{i, 1}
    if(i == length(torque_param))
        torque = torque_param{1, 2}'*0; %経路終わったらtorqueをゼロにする
        return
    end
    t_sum = t_sum + torque_param{i, 1};
    i = i + 1;
end

k1= (t_sum + torque_param{i, 1}-t)/torque_param{i, 1};
k2 = (t-t_sum) / torque_param{i, 1};
torque = torque_param{i, 2}' * k1 + torque_param{i, 3}' * k2;