
% 初期設定
RR = [1; 2; 3];              % 位置（中心）
dims = [1, 2, 0.5];          % 直方体のサイズ
n_frames = 200;              % アニメーションのフレーム数
theta = linspace(0, 4*pi, n_frames);  % 回転角

% 原点中心の直方体の8頂点（各行が1つの頂点）
[X, Y, Z] = ndgrid([-0.5, 0.5], [-0.5, 0.5], [-0.5, 0.5]);
vertices_local = [X(:), Y(:), Z(:)] .* dims;

% 面の定義（頂点インデックス）
faces = [1 3 7 5; 2 4 8 6; 1 2 6 5;
    3 4 8 7; 1 2 4 3; 5 6 8 7];

% 描画初期化
figure;
base = patch('Vertices', zeros(8,3), 'Faces', faces, ...
    'FaceColor', [0.6 0.8 1.0], 'FaceAlpha', 0.7);
axis equal;
xlabel('X'); ylabel('Y'); zlabel('Z');
view(3); grid on;
xlim([RR(1)-2 RR(1)+2]);
ylim([RR(2)-2 RR(2)+2]);
zlim([RR(3)-2 RR(3)+2]);
title('直方体の回転アニメーション');

% アニメーションループ
for i = 1:n_frames
    % z軸回転行列（例：yaw回転）
    A0 = [cos(theta(i)) -sin(theta(i)) 0;
        sin(theta(i))  cos(theta(i)) 0;
        0              0             1];

    % 姿勢と位置を反映
    vertices_global = (A0 * vertices_local')' + RR';

    % パッチ更新
    set(base, 'Vertices', vertices_global);
    drawnow;
end