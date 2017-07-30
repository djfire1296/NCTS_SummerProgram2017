% Activate connector
connector on; % get IP or DNS

% Define mobile device and set attributes
% mobileSensor = mobiledev();
mobileSensor.SampleRate = 60; % 100 Hz, receive data every 0.01 sec
mobileSensor.AccelerationSensorEnabled = 1; % activate acceleration sensor
mobileSensor.OrientationSensorEnabled = 1; % activate orientation sensor

% Set basic parameters
windowLength = 3; % Detection window length
detectionInterval = 1; % Number of windows between consecutive detections
% Data from phone may not be uniformly sampled, therefore it will be
% resampled at this rate.
uniformSampleRate = 60; % Hz.

% Normalize training data
[X, Y, dMin, range] = normalizeTrainingData('trainingData.mat', [0, 2, -1, 3, 1]);
% Normalize user training data
[X_u, Y_u, dMin_u, range_u] = normalizeTrainingData('userTrainingData.mat', [0, 2, -1, 3, 1]);

% Construct KNN model
mdl = fitcknn(X,Y);
knnK = 30; %num of nearest neighbors using in KNN classifier
mdl.NumNeighbors = knnK;%specify num of nearest neighbors

% Construct user KNN model
mdl_u = fitcknn(X_u,Y_u);
knnK_u = 30; %num of nearest neighbors using in KNN classifier
mdl_u.NumNeighbors = knnK_u;%specify num of nearest neighbors

% begin to collect datas
mobileSensor.Logging = 1;

display('Press ENTER to begin recording current activity.')
pause;
mobileSensor.discardlogs;

fa = figure('Name', 'Acceleration', 'Position', [60, 780, 720, 480]); % acceleration figure
fo = figure('Name', 'Orientation', 'Position', [840, 780, 720, 480]); % orientation figure
fr = figure('Name', 'Detection Result', 'Position', [1620, 780, 720, 480]); % result by trainingdata figure
fna = figure('Name', 'New_Acceleration', 'Position', [60, 120, 720, 480]); % new acceleration figure
fp = figure('Name', 'Phone Position', 'Position', [840, 120, 720, 480]); % phone position figure
fr_u = figure('Name', 'User Detection Result', 'Position', [1620, 120, 720, 480]); % result by usertrainingdata figure

tic;
while toc < 180
    pause(7); % updata every 7 seconds
    
    % Get acceleration and orientation data from log
    [a, t_a] = accellog(mobileSensor);
    [o, t_o] = orientlog(mobileSensor);
    
    % plot acceleration
    figure(fa);
    plot(t_a, a);
    
    ylim([-30 30]);
    % plot(t_a, a(:,1), '-ro', t_a, a(:,2), '-.g', t_a, a(:,3), '-.b');
    grid on;
    xlabel('Timestamp');
    ylabel('Acceleration(m/s^2)');
    % hleg1 = legend('x', 'y', 'z');
    
    
    % plot orientation
    figure(fo);
    plot(t_o, o);
    ylim([-180 360]);
    % plot(t_o, o(:,1), '-ro', t_o, o(:,2), '-.g', t_o, o(:,3), '-.b');
    grid on;
    xlabel('Timestamp');
    ylabel('Angle(degrees)');
    % hleg1 = legend('Azimuth', 'Roll', 'Pitch');
    
    disp(['toc: ', num2str(toc), ', t_size: ', num2str(size(t_a, 1)), ', a_size: ', num2str(size(a, 1))]);
    
    fileName = ['real_time', '.mat'];
    t = t_a;
    save(fileName, 'a', 't');
    
    [result, C, frameIndex] = GuessMotion( fr, windowLength, detectionInterval, ...
                                               uniformSampleRate, range, a, mdl, dMin );
    
    [result_u, C_u, frameIndex_u] = GuessMotion( fr_u, windowLength, detectionInterval, ...
                                               uniformSampleRate, range_u, a, mdl_u, dMin_u );

    
    kmeansmethod( fr, C, t, X, Y,  [0, 2, -1, 3, 1], windowLength );
    kmeansmethod( fr_u, C_u, t, X_u, Y_u,  [0, 2, -1, 3, 1], windowLength );
    draw3DPosition( fna, fp, t_a, a, t_o, o );
end

% [a, t_a] = accellog(mobileSensor);
% figure(fa);
% plot(t_a, a);
% 
% [o, t_o] = orientlog(mobileSensor);
% figure(fo);
% plot(t_o, o);

% GuessMotion( fr, windowLength, detectionInterval, uniformSampleRate, range, a, mdl, dMin )
% draw3DPosition( fna, fp, t_a, a, t_o, o );

pause;
close all;