function LP =  make_lp_from_bb(LP)

% LP.BBからSS, SE, S0定義
LP.BB;

LP.num_q = length(LP.BB);

LP.SS = zeros(LP.num_q, LP.num_q); % 子リンクとの連結関係の行列
LP.S0 = zeros(1, LP.num_q); % 根元リンクの子

LP.SE = ones(1, LP.num_q); % 末端リンクの定義
for i = 1:LP.num_q
    LP.SS(i,i) = -1;
    % 各リンクの質量を定義する
    if LP.BB(i) == 0
        LP.S0(i) = 1;
    else
        LP.SS(LP.BB(i), i) = 1; % 根元側で結合しているリンク番号に対応する行に１を入れる
        LP.SE(LP.BB(i)) = 0; % 末端リンクではない
    end
    % 各リンクの慣性モーメントを定義する
end
