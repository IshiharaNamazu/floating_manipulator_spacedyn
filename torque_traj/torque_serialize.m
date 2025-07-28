function serialized = torque_serialize(torque_param)
serialized = [];
for i = 1:size(torque_param, 1)
    % 時間
    serialized = [serialized; torque_param{i, 1}];
    % 初期トルク（6成分）
    serialized = [serialized; torque_param{i, 2}'];
    % 終了トルク（6成分）
    serialized = [serialized; torque_param{i, 3}'];
end

serialized = serialized';