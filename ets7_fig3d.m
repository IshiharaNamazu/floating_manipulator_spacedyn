function FIG3D = ets7_fig3d()

%%%%%%%%%%base%%%%%%%%%%%%%%%%
FIG3D.base.dims = [2.6 ,2.3, 2.0]

[X, Y, Z] = ndgrid([-0.5, 0.5], [-0.5, 0.5], [-0.5, 0.5]);
FIG3D.base.vertices_local = [X(:), Y(:), Z(:)] .* FIG3D.base.dims;
% 面の定義（頂点インデックス）
faces = [1 3 7 5; 2 4 8 6; 1 2 6 5;
    3 4 8 7; 1 2 4 3; 5 6 8 7];

% 描画初期化
FIG3D.base.base = patch('Vertices', zeros(8,3), 'Faces', faces, ...
    'FaceColor', [0.6 0.8 1.0], 'FaceAlpha', 0.7);

%%%%%%%%%%link%%%%%%%%%%%%%%%%
link_len = [0.350, 0.870, 0.630, 0.275, 0.277, 0.532];
link_axis=['z','x', 'x', 'x', 'x', 'x']; % 各リンクの関節軸
link_radius = 0.05;
for i = 1:6
    if link_axis(i) == 'z'
        FIG3D.link(i).dims = [link_radius*2, link_radius*2, link_len(i)];
    elseif link_axis(i) == 'x'
        FIG3D.link(i).dims = [link_len(i), link_radius*2, link_radius*2];
    end
    faces = [1 3 7 5; 2 4 8 6; 1 2 6 5;
        3 4 8 7; 1 2 4 3; 5 6 8 7];

    FIG3D.link(i).vertices_local = [X(:), Y(:), Z(:)] .* FIG3D.link(i).dims;
    FIG3D.link(i).link = patch('Vertices', zeros(8,3), 'Faces', faces, ...
        'FaceColor', [0.6 0.8 1.0], 'FaceAlpha', 0.7);
end