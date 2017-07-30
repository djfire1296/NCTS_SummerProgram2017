function [result, C, frameIndex] = GuessMotion(fr, windowLength, detectionInterval, ...
                                            uniformSampleRate, range, acc, mdl, dMin)
    load('real_time.mat');
    
    newTime = 0:1/100:(t(end)-t(1));
    x = acc(:, 1);
    y = acc(:, 2);
    z = acc(:, 3);
    x = interp1(t, x, newTime);
    y = interp1(t, y, newTime);
    z = interp1(t, z, newTime);
    acc = [x; y; z]';
    t = newTime;

    % Activity Detection
    i = 1;
    lastFrame = find(t>(t(end)-windowLength-0.005), 1);
    % Set default starting activity to idling
    lastDetectedActivity = 0;

    frameIndex = [];
    result = [];
    score = [];

    % Parse through the data in 5 second windows and detect activity for each 5
    % second window
    while (i < lastFrame)
        startIndex = i;
        frameIndex(end+1,:) = startIndex;
        t0 = t(startIndex);
        nextFrameIndex = find(t > t0 + detectionInterval);
        nextFrameIndex = nextFrameIndex(1) - 1;
        stopIndex = find(t > t0 + windowLength);
        stopIndex = stopIndex(1) - 1;
        currentFeature = extractFeatures(acc(startIndex:stopIndex, :, :),...
                         t(startIndex:stopIndex), uniformSampleRate);
        currentFeature = (currentFeature - dMin) ./ range;
        C(i, :) = currentFeature;
        
        [tempResult,tempScore] = predict(mdl, currentFeature);
        % Scores reported by KNN classifier is ranging from 0 to 1. Higher score
        % means greater confidence of detection.
        if max(tempScore) < 0.95 || tempResult ~= lastDetectedActivity 
            % Set result to transition
            result(end+1, :) = -10; 
        else
            result(end+1, :) = tempResult;
        end
        lastDetectedActivity = tempResult;
        score(end+1, :) = tempScore;
        i = nextFrameIndex + 1;
    end
    
    % Generate a plot of raw data and the results
    
    figure(fr);
    plot(t, acc);
    % Raw acceleration data is bounded by +-20, leaving space in bottom of the 
    % graph for activity detection markers.
    ylim([-30 20]);
    xlabel('Timestamp');
    ylabel('Acceleration(m/s^2)');
    hold all;
    
    resWalk =(result == 2);
    resRun  =(result == 3);
    resIdle =(result == 0);
    resDown =(result ==-1);
    resUp   =(result == 1);
    resUnknown =(result == -10);
    
    % Plot activity detection markers below the raw acceleration data
    hWalk = plot(t(frameIndex(resWalk))+windowLength, 0*result(resWalk)-25, 'kx');
    hRun  = plot(t(frameIndex(resRun))+windowLength, 0*result(resRun)-25, 'r*');
    hIdle = plot(t(frameIndex(resIdle))+windowLength, 0*result(resIdle)-25, 'bo');
    hDown = plot(t(frameIndex(resDown))+windowLength, 0*result(resDown)-25, 'cv');
    hUp   = plot(t(frameIndex(resUp))+windowLength, 0*result(resUp)-25, 'm^');
    hTransition = plot(t(frameIndex(resUnknown))+windowLength, 0*result(resUnknown)-25, 'k.');

    % Increase y-axis limit to include the detected marker
    ylim([-30 20]);

    % Add legend to the graph
%     legend([hWalk, hRun, hIdle, hDown, hUp, hTransition], ...
%         'Walking','Running','Idling','Walking Downstairs','Walking Upstairs',...
%         'Transition');
end

