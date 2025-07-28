function torque_param = torque_deserialize(serialized)
serialized = serialized'
n_segments = length(serialized) / 13; % 1時間 + 6初期 + 6終了 = 13
torque_param = cell(n_segments, 3);

idx = 1;
for i = 1:n_segments
    % 時間
    torque_param{i, 1} = serialized(idx);
    idx = idx + 1;
    % 初期トルク
    torque_param{i, 2} = serialized(idx:idx+5)';
    idx = idx + 6;
    % 終了トルク
    torque_param{i, 3} = serialized(idx:idx+5)';
    idx = idx + 6;
end