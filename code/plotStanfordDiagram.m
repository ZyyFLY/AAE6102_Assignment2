function plotStanfordDiagram(horizontal_errors, protection_levels, AL)
    % 创建Stanford图
    figure;
    hold on;
    
    % 分类数据点
    normal = horizontal_errors <= AL & protection_levels <= AL;
    mi = horizontal_errors > AL & protection_levels <= AL;
    fa = horizontal_errors <= AL & protection_levels > AL;
    
    % 绘制数据点
    plot(horizontal_errors(normal), protection_levels(normal), 'g.', 'MarkerSize', 10);
    plot(horizontal_errors(mi), protection_levels(mi), 'r*', 'MarkerSize', 10);
    plot(horizontal_errors(fa), protection_levels(fa), 'y*', 'MarkerSize', 10);
    
    % 添加参考线
    plot([0 AL AL], [AL AL max(protection_levels)*1.1], 'k--');
    plot([AL AL], [0 AL], 'k--');
    plot([0 max(horizontal_errors)*1.1], [AL AL], 'k--');
    
    % 添加45度线
    max_val = max(max(horizontal_errors), max(protection_levels));
    plot([0 max_val], [0 max_val], 'k--');
    
    % 设置图形属性
    xlabel('Horizontal Position Error (m)');
    ylabel('Protection Level (m)');
    title('Stanford Diagram');
    grid on;
    
    % 添加图例
    legend('Normal Operation', 'Missed Detection', 'False Alarm', 'Location', 'northwest');
    
    % 设置轴限制
    axis([0 max(horizontal_errors)*1.1 0 max(protection_levels)*1.1]);
    axis square;
    
    hold off;
end