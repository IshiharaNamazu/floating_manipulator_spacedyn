%%WS初期化
clc
clear
close all
addpath('./SpaceDyn/src/matlab/spacedyn_v2r1'); % SpaceDynのパスを追加
addpath('./torque_traj'); % SpaceDynのパスを追加

%%%%%%%%%%%%%%%%% global 変数の定義 %%%%%%%%%%%%%%%%%%%%
global d_time
global Gravity
global Ez

%%%%%% 関節の単位回転軸ベクトル %%%%%
Ez =[0 0 1]';
Gravity =[0 0 0]'; % 重力（地球重力ならば Gravity = [0 0 -9.8]）

d_time =0.01; % シミュレーションの１ステップあたりの時間

%%%%%%%%%%%% リンクパラメータ定義と変数の初期化 %%%%%%%%%%%%%%%%%
LP = ets7_linkparam();%LP１とかにしてもよいi.         Sample_LP()を呼び出してLPに格納
SV = make_sv( LP );%SVも名前は自分で定義できる       Sample_SV(LP)を呼び出してSVに格納   同時にサイズを決めている

%%%%% ベースから num_e で指定された手先までを結ぶ関節(リンク)を求める %%%%%
num_e = 1;% num_e番目の末端リンクの位置見る
joints = j_num(LP, num_e);%アームの手先までリンクを求める

%%%%% ロボットの初期関節角度を設定 %%%%%
SV.q = zeros(6,1);


%PD制御をする
desired_q = [ pi pi/4 pi/3 -pi/6 -pi/3 -pi/2]'; % 目標関節角度
gain_spring = 75; % ばね定数と減衰係数
gain_dumper = 100;



fidw = fopen( 'sample.dat','w' );

%%%%%%%% 描画関連 %%%%%%%%
figure(6);
FIG3D = ets7_fig3d();
axis equal;
xlabel('X'); ylabel('Y'); zlabel('Z');
view(3); grid on;
xlim([-6 6]);
ylim([-6 6]);
zlim([-6 6]);
title('Figure');

%%%%%%%%%%%%%%%%% ここからシミュレーションループスタート %%%%%%%%%%%%%%%%%%%%%%%%%%
tic;
for time = 0:d_time:10

        time % 現在どのステップを計算しているかを画面に出力（；ついてないので ）

        %%%%%%%%%%%%%%%% 目標トルク制御の計算 %%%%%%%%%%%%%%%%%%%
        SV.tau = gain_spring.*( desired_q - SV.q ) - gain_dumper.*SV.qd;

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

        %%%%% 手先姿勢のオイラー角表現 %%%%%
        Qe_rad =dc2rpy(ORI_e');%ORI_eの転置を忘れない！(SpceDynの特性上そうなっている)
        %%%%% ベース姿勢のオイラー角表現 %%%%%%
        SV.Q0 =dc2rpy(SV.A0');  %方向余弦行列からオイラー角に変換

        %%%%% 角度をradからdegへ変換 %%%%%
        Qe_deg =Qe_rad*180/pi;
        Q0_deg =SV.Q0*180/pi;
        q_deg =SV.q*180/pi;

        %%%%%%%%%%%%%%%%%%%%% 結果をファイルに出力 %%%%%%%%%%%%%%%%%%%%%
        fprintf(fidw,'%g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g\n',time,SV.R0,Q0_deg,POS_e,Qe_deg,q_deg);

        %%%%%%%%%%%%%%%%%%%%%%% 描画 %%%%%%%%%%%%%%%%%%%%%%%%%
        set(FIG3D.base.base, 'Vertices', (SV.A0 * FIG3D.base.vertices_local')' + SV.R0');
        for i = 1:6
                set(FIG3D.link(i).link, 'Vertices', (SV.AA(:,i*3-2:i*3) * FIG3D.link(i).vertices_local')' + SV.RR(:,i)');
        end
        drawnow;
end
elapsedTime = toc;
disp(['処理時間: ', num2str(elapsedTime), ' 秒']);

%%%%%%%%%%%%%%%%%%%%%%%%%%% シミュレーションループここまで %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 結果の表示 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fid = fopen('sample.dat','r');
tmp = fscanf(fid,'%g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g',[19 inf]);
tmp = tmp';
fclose(fid);

%%%%% グラフの描画 %%%%%
%%% ベースの位置
figure(1)
plot(tmp(:,1),tmp(:,2:4),'-');
title('SV.R0');
xlabel('Time [s]'); ylabel('position of Base [m]');
grid on;

%%% ベースの姿勢
figure(2)
plot(tmp(:,1),tmp(:,5:7),'-');
title('Q0\_deg');
xlabel('Time [s]'); ylabel('Rotation of Base [deg]');
grid on;

%%% 手先の位置
figure(3)
plot(tmp(:,1),tmp(:,8:10),'-');
title('POS_e');
xlabel('Time [s]'); ylabel('position of Hand [m]');
grid on;

%%% 手先の姿勢
figure(4)
plot(tmp(:,1),tmp(:,11:13),'-');
title('Qe\_deg');
xlabel('Time [s]'); ylabel('Rotation of Hand [deg]');
grid on;

%%% 関節角度
figure(5)
plot(tmp(:,1),tmp(:,14:19),'-');
title('q\_deg');
xlabel('Time [s]'); ylabel('Joint angle [deg]');
grid on;


%%% EOF
