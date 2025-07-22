function SV = make_sv( LP ) %
% make state variables from link parameters (LP)

SV.v0  = [0 0 0]'; % 衛星本体(Base)位置
SV.w0  = [0 0 0]'; % 角位置
SV.vd0 = [0 0 0]'; % 速度
SV.wd0 = [0 0 0]'; % 角速度

SV.R0 = [0 0 0]'; % 衛星の位置
SV.Q0 = [0 0 0]'; % 衛星の姿勢(RPY)
SV.A0 = eye(3); % 衛星の姿勢 (方向余弦)

SV.Fe = zeros(3,LP.num_q); % 末端の外力
SV.Te = zeros(3,LP.num_q); % 末端の外トルク

SV.q = zeros(LP.num_q,1); % 関節角
SV.qd  = zeros(LP.num_q,1); % 関節角速度
SV.qdd = zeros(LP.num_q,1); % 関節角加速度 (使われていない可能性あり)

SV.vv = zeros(3,LP.num_q); % 関節の状態
SV.ww = zeros(3,LP.num_q);
SV.vd = zeros(3,LP.num_q);
SV.wd = zeros(3,LP.num_q);

SV.tau = zeros(LP.num_q,1); % 関節のトルク

SV.F0 = [0 0 0]'; % 衛星の外力
SV.T0 = [0 0 0]'; % 衛星の外トルク
