function HR = ECG_HRconverter(E, ts)
    E1 = E.*E.*E;
    [pks, locs] = findpeaks(E1,'MinPeakProminence',0.3);
    hr1 = ones(1,length(pks));

    idx = 2;
    prev = 0;
    tt = 0;

    for l = 1:length(pks) 
        if (prev == 0)
            prev = locs(l);
            continue;
        end
        time = (locs(l) - prev)*ts;
        hr1(idx) = 60/time;
    
        if (hr1(idx) >= 230) 
            hr1(idx) = hr1(idx-1);
        end
    
        tt = [tt, time+((prev)*ts)];
        
        idx = idx + 1;
        prev = locs(l);
    end

    tts = 0:ts:tt(length(tt));
   
    h = interp1(tt,hr1,tts);

    n = floor(tt(length(tt))/60);
    HR = ones(1,n);

    for l = 1:n
        right = 7680*l;

        HR(l) = mean(h(1,(1:right)));
    end
end