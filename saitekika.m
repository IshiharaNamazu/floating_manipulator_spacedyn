function saitekika(pid, par_i)
if nargin < 2
    pid = 0;
    par_i = 0;
end

% disp(['pid:', num2str(pid)])
% disp(['par_i:', num2str(par_i)])

addpath('./SpaceDyn/src/matlab/spacedyn_v2r1'); % SpaceDyn のパスを追加
addpath('./torque_traj'); % SpaceDyn のパスを追加

global onetime_execution

% 値が未定義（未初期化）なら初期化する
if ~evalin('base', 'exist(''onetime_execution'', ''var'')')
    onetime_execution = false;
end

disp(["onetime_execution="+ string(onetime_execution)])


%% 非線形制約
    function [c, ceq] = nonlinear_con(x)
        v = ets7_dyn(torque_deserialize(x));
        c = [];
        ceq = [v];
    end

%% 目的関数

    function total = sum_torque_param_first_column(x)
        torque_param = torque_deserialize(x);
        total = 01;
        for i = 1:size(torque_param, 1)
            total = total + torque_param{i, 1};
        end
    end

for loop_saitekika=1:300
    %clc
    %close all
    nanoTime = java.lang.System.nanoTime();
    clk = sum(100000 * clock);
    rng(mod(bitxor(nanoTime + pid + round(clk) + par_i, pid * par_i), 2^32)); % 現在時刻をシードにする



    torque_param = {
        2, zeros(1,6), zeros(1,6);
        2, zeros(1,6), zeros(1,6);
        };
    length(torque_param)

    x0 = torque_serialize(torque_param); % 後で乱数で初期化する

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

    max_torque = 50; % 最大トルク

    [rows, cols] = size(torque_param);
    for i = 1:rows
        lb = [lb 0.5 -max_torque.*ones(1,6) -max_torque.*ones(1,6)]; % 各トルクの時間は0.5秒以上
        ub = [ub 15 max_torque.*ones(1,6) max_torque.*ones(1,6)]; % 各トルクの時間は0.5秒以上
    end

    for i = 1:rows
        x0(i) = lb(i) + (ub(i) - lb(i)) * rand;
    end

    % disp(["x0初期値:", x0]);



    options = optimoptions("fmincon",...
        'HonorBounds', true, ...                   % 境界制約を常に守る
        'Display', 'iter', ...                     % 進行状況を表示
        'MaxIterations', 1000, ...                 % 最大反復回数
        'MaxFunctionEvaluations', 3000, ...        % 最大関数評価回数
        'ConstraintTolerance', 1e-6, ...           % 制約の許容誤差
        'StepTolerance', 1e-12, ...                % ステップ幅の許容誤差（小さくして粘る）
        'HessianApproximation', 'lbfgs', ...       % ヘッセ行列を近似
        'ScaleProblem', true, ...                  % 問題をスケーリング
        'SpecifyObjectiveGradient', false, ...
        'SpecifyConstraintGradient', false, ...
        Algorithm="interior-point",...
        EnableFeasibilityMode=true,...
        SubproblemAlgorithm="cg");

    exitflag = -2;
    output.iterations = 123;
    output.funcCount = 345;
    x=x0;
    fval = 1.23;
    [x, fval, exitflag, output] = fmincon(@sum_torque_param_first_column, x0, A, bb, Aeq, beq, lb, ub, @nonlinear_con, options);
    disp(torque_deserialize(x))

    % 結果の確認
    fprintf('最適化結果:\n');
    fprintf('終了フラグ: %d\n', exitflag);
    fprintf('反復回数: %d\n', output.iterations);
    fprintf('関数評価回数: %d\n', output.funcCount);
    fprintf('目的関数値: %.6f\n', fval);

    % 終了フラグの判定
    switch exitflag
        case 1
            fprintf('収束しました（1次最適性条件を満たす）\n');
        case 2
            fprintf('変数の変化が許容値以下で収束\n');
        case 0
            fprintf('最大反復回数に達しました\n');
        case -1
            fprintf('アルゴリズムが終了（収束していない可能性）\n');
        case -2
            fprintf('実行可能解が見つかりません\n');
        case -3
            fprintf('目的関数が無限に発散\n');
        otherwise
            fprintf('その他のエラー（exitflag: %d）\n', exitflag);
    end

    if exitflag ~= -2
        s=rng;
        seed_value = s.Seed;
        row = [exitflag, output.iterations, output.funcCount, fval, int64(seed_value)];
        fid = fopen('result.csv', 'a');
        fprintf(fid, '%ld,', row(1:end));
        fprintf(fid, '%f,', x(1:end-1));
        fprintf(fid, '%f\n', x(end));
        fclose(fid);
        %ets7_dyn(torque_param)
    end
    if onetime_execution
        break
    end
end
end