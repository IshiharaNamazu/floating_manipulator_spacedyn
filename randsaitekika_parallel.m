function randsaitekika_parallel(n)
% デフォルト値の設定
if nargin < 1
    n = 16;  % デフォルトでn個並列実行
end
c = parcluster('local');
if(c.NumWorkers < n)
    c.NumWorkers = n;
    saveProfile(c);
end

% Parallel Computing Toolboxの確認
if ~license('test', 'Distrib_Computing_Toolbox')
    warning('Parallel Computing Toolboxが利用できません。順次実行します。');
    for i = 1:n
        fprintf('実行 %d/%d を開始\n', i, n);
        saitekika();
    end
    return;
end

% 並列プールの開始
try
    parpool('local', n);
catch
    % 既にプールが存在する場合
    current_pool = gcp('nocreate');
    if isempty(current_pool) || current_pool.NumWorkers < n
        delete(gcp('nocreate'));
        parpool('local', n);
    end
end

% 並列実行
fprintf('%d個の最適化を並列実行開始...\n', n);

parfor i = 1:n
    try
        fprintf('ワーカー %d: 最適化開始\n', i);
        saitekika(feature('getpid'), i);
        fprintf('ワーカー %d: 最適化完了\n', i);
    catch ME
        fprintf('ワーカー %d: エラー発生 - %s\n', i, ME.message);
    end
end

fprintf('全ての並列実行が完了しました。\n');
end