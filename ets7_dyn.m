function value = ets7_dyn(torque_param)

%%%%%%%%%%%%%%%%% global 変数の定義 %%%%%%%%%%%%%%%%%%%%
global d_time
global Gravity
global Ez


%%%%%% 関節の単位回転軸ベクトル %%%%%
Ez =[0 0 1]';
Gravity =[0 0 0]'; % 重力（地球重力ならば Gravity = [0 0 -9.8]）

d_time =0.01; % シミュレーションの１ステップあたりの時間

%%%%%%%%%%%%%%% 変数初期化 %%%%%%%%%%%%%%%%%
value = 0;
t_all = 0;
for i = 1:size(torque_param, 1)
        t_all = t_all + torque_param{i, 1};
end

%%%%%%%%%%%% リンクパラメータ定義と変数の初期化 %%%%%%%%%%%%%%%%%
LP = ets7_linkparam();%LP１とかにしてもよいi.         Sample_LP()を呼び出してLPに格納
SV = make_sv( LP );%SVも名前は自分で定義できる       Sample_SV(LP)を呼び出してSVに格納   同時にサイズを決めている

%%%%% ベースから num_e で指定された手先までを結ぶ関節(リンク)を求める %%%%%
num_e = 1;% num_e番目の末端リンクの位置見る
joints = j_num(LP, num_e);%アームの手先までリンクを求める

%%%%% ロボットの初期関節角度を設定 %%%%%
SV.q = zeros(6,1);

% fidw = fopen( 'sample.dat','w' );

%%%%%%%% history %%%%%%%%
time_array = 0:d_time:t_all;
pos_e_history = zeros(3, length(time_array));

%%%%%%%%%%%%%%%%% ここからシミュレーションループスタート %%%%%%%%%%%%%%%%%%%%%%%%%%
tic; % 計測開始
itr = 0;
for time = time_array
        itr = itr + 1;
        % if mod(itr, 100) == 0
        %         fprintf('\rprogress: %f/%f', time, t_all);
        % end

        %%%%%%%%%%%%%%%% 目標トルク制御の計算 %%%%%%%%%%%%%%%%%%%
        SV.tau = calc_torque(torque_param, time);

        %%%%%%%%%%%%%%%%%%%% 順動力学の計算 %%%%%%%%%%%%%%%%%%%%%
        SV = f_dyn_rk2( LP, SV );

        %%%%%%%%%%%%%%%%%%%%%%% 順運動学 %%%%%%%%%%%%%%%%%%%%%%%%%

        %%%%% 手先位置姿勢の計算 (順運動学) %%%%%%
        % 各リンクの座標変換行列(方向余弦行列)の計算（リンクi → 慣性座標系）
        SV =calc_aa( LP, SV );
        % 各リンク重心の位置ベクトル(6×1)を計算
        SV =calc_pos( LP, SV );

        %%%%% 手先位置姿勢の計算 %%%%%
        [ POS_e, ORI_e ] =f_kin_e(LP, SV, joints);

        pos_e_history(:, round(time/d_time) + 1) = POS_e;
end
elapsedTime = toc;
disp(['処理時間: ', num2str(elapsedTime), '/', num2str(t_all), ' 秒']);

%%%%%%%%%%%%%%%%%%%%%%%%%%% シミュレーションループここまで %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%% 評価関数の計算 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 目標位置と手先位置の誤差を計算
desired_pos_e = [-0.480; -1.551; 2.51]; % 目標手先位置
pos_e_error = pos_e_history - desired_pos_e;

% 評価関数の値を計算
value = sum(pos_e_error(:, end).^2);

%%% EOF
