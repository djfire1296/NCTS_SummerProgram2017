function [ X, Y, dMin, range ] = normalizeTrainingData( filename, index )
    % Usage: Normalize training data

    % load file of training data
    load(filename);

    % Normalize training data
    data = [featureWalk; featureRun; featureIdle; featureUp; featureDown];
    
    for i = 1:size(data,2)
        range(1,i) = max(data(:,i))-min(data(:,i)); 
        dMin(1,i) = min(data(:,i));
        data(:,i) = (data(:,i)- dMin(i)) / range(i);
    end

    % Activity indexing
    indexIdle =  index(1);
    indexWalk =  index(2);
    indexDown =  index(3);
    indexRun  =  index(4);
    indexUp   =  index(5);

    Idle = indexIdle * zeros(length(featureIdle),1);
    Walk = indexWalk * ones(length(featureWalk),1);
    Down = indexDown * ones(length(featureDown),1);
    Run  = indexRun  * ones(length(featureRun),1);
    Up   = indexUp   * ones(length(featureUp),1);

    % X Y for model training
    X = data;
    Y = [Walk; Run; Idle; Up ;Down];
end

