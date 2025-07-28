%%%%%%%%%%%%%%%% 関節トルクの時間関数(最適化対象) %%%%%%%%%%%%%%%

% 経路[t, 初期トルク, 終トルク]の連続
torque_param = {
    2, [0 0 0 0 0 0], [1 2 3 4 5 6];
    1, [2 2 2 2 2 2], [2 2 2 2 2 2];
    3, [1 2 3 4 5 6], [-1 -2 -3 -4 -5 -6];
    };

% 時間配列とトルク配列を準備
time_array = 0:0.01:10;
torque_array = zeros(length(time_array), 6);

serialized = torque_serialize(torque_param);
deserialized = torque_deserialize(serialized);
disp('シリアライズ結果:');
disp(serialized);
disp('復元結果:');
disp(deserialized);

% トルクデータを計算
for i = 1:length(time_array)
    t = time_array(i);
    torque = calc_torque(torque_param, t);
    torque_array(i, :) = torque';  % 6x1を1x6に転置
end

% プロット
figure;
plot(time_array, torque_array, 'LineWidth', 2);
xlabel('Time [s]');
ylabel('Torque [Nm]');
title('Joint Torques vs Time');
legend('Joint 1', 'Joint 2', 'Joint 3', 'Joint 4', 'Joint 5', 'Joint 6');
grid on;