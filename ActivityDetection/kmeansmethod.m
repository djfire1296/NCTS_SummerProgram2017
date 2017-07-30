function kmeansmethod( fr, C, t, X, Y, index, windowlength )
    precise = 10;
    X = X(1: 10: end, :);
    Y = Y(1: 10: end);
    in = find(C(:, 1) ~= 0);
    C = C(in, :);
    t = t(in);
    kms = kmeans([X; C], precise);
    krec = kms(1: length(Y));
    kms = kms(length(Y) + 1: end);
    
    for i = 1 : precise
        r = Y(find(krec == i));
        s = length(r);
        for j = 1: 5
            rec(i, j) = length(find(r == index(j))) / s;
        end
    end
    
    for i = 1 : precise
        [ch, idx(find(kms==i))] = max(rec(i, :));
        if ch < 0.95 || ch == NaN
            idx(find(kms==i)) = -10;
        end
    end
    
    kms = idx;   
    figure(fr);
    
    ind = t(find(kms == 1));
    scatter(ind+windowlength, -28*ones(1, length(ind)), 'bo');
    hold on
    ind = t(find(kms == 2));
    scatter(ind+windowlength, -28*ones(1, length(ind)), 'kx');
    hold on
    ind = t(find(kms == 3));
    scatter(ind+windowlength, -28*ones(1, length(ind)), 'cv');
    hold on
    ind = t(find(kms == 4));
    scatter(ind+windowlength, -28*ones(1, length(ind)), 'r*');
    hold on
    ind = t(find(kms == 5));
    scatter(ind+windowlength, -28*ones(1, length(ind)), 'm^');
    hold on
    ind = t(find(kms == -10));
    scatter(ind+windowlength, -28*ones(1, length(ind)), '.k');
end