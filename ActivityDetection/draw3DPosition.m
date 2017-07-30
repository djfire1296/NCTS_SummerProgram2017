function [ ] = draw3DPosition( fna, fp, t_a, acceleration, t_o, orientation )
    rt_a = round(t_a,2);
    rt_o = round(t_o,2);
    [intersect_t, intersect_accidx, intersect_oriidx]= intersect(rt_a, rt_o);
    
    if size(t_a, 1) > size(acceleration, 1)
        disp(['t_size: ', num2str(size(t_a, 1)), ', a_size: ', num2str(size(acceleration, 1))]);
        error('wrong dimension')
    end
        
    acceleration = acceleration(intersect_accidx, :);
    orientation = orientation(intersect_oriidx, :);
    
    % modified gravity by phone orientations
    g = [ -sin(orientation(:,3)*pi/180).*cos(orientation(:,2)*pi/180), -sin(orientation(:,2)*pi/180), ...
        cos(orientation(:,3)*pi/180).*cos(orientation(:,2)*pi/180) ] * 9.8;
    newacc = acceleration - g;
    
    figure(fna);
    ylim([-30 20]);
    plot(intersect_t, newacc);
    % plot(intersect_t, newacc(:,1), '-ro', intersect_t, newacc(:,2), '-.g', intersect_t, newacc(:,3), '-.b');
    grid on;
    xlabel('Timestamp');
    ylabel('Acceleration(m/s^2)');
    % hleg1 = legend('x', 'y', 'z');
    
    % position = (cumsum(newacc) - newacc / 2) * (1/100)^2;
    vector = (cumsum(newacc)-newacc/2)*(1/100);
    position = (cumsum(vector)-vector/2)*(1/100);
    n = size(position);
    
    figure(fp);
%     axis([min(position(:, 1)), max(position(:, 1)), min(position(:, 2)), max(position(:, 2)), ...
%         min(position(:, 3)), max(position(:, 3))]);
    plot3([0; position(:, 1)], [0; position(:, 2)], [0; position(:, 3)], 'bx');
    % xlim([0, 1]);
    % ylim([0, 1]);
    % zlim([0, 1]);
    % axis([-5, 10, -5, 10, -5, 5]);
    grid on;
    
%     for i = 2:n
%         set(h, 'xdata', position(1:i,1), 'ydata', position(1:i,2), 'zdata', position(1:i,3));
%         drawnow;
%     end
end

