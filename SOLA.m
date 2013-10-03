%function [ timeshifted_signal ] = Timeshift( bestandsnaam, sample_rate, alpha, )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    % Versnelt/vertraagt audio met Overlap and Add (OLA).
    input = audioread('C:\Users\Nicolas\Dropbox\P&O3 - Time Scaling 2013\van_jszurleys_ftp\Speech materials\annelies1.wav'); % inladen geluid
    % Y = resample(X, 2, 1); % dubbel zo traag resamplen
    SAMPLING_RATE = 44100; % deze sampling rate komt overeen met 1 seconde
    player = audioplayer(input, SAMPLING_RATE);  %player aanmaken (handig om geluid te kunnen stoppen en starten)

    % Break into pieces.
    frames = [];
    STEP = SAMPLING_RATE / 10; % The smaller the step, the smaller the frames and the exacter your signal.
    for i = 1:STEP:size(input, 1) % Size(input,1) is the length of one row of the input signal.
        %i, i+2*STEP
        frames = [frames; input(i:i+2*STEP-1)];
    end

    % Hebben we nu het rechter of het linker signaal?

    % Stukjes zijn 1xn

    % Recombining frames taking into consideration time shift.
    output = [frames(1,:)]; % Output is the array containing all the elements for the output signal.
    ALPHA = 1.5; % Changing alpha will change the amount of overlap and thus the speed.
    FRAME_PIECE = round(ALPHA * STEP); % Hoeveel samples er tussen elk nieuw frame in het outputsignaal zitten. Ss
    for i = 1:size(frames,1)
        stukje = frames(i,:); % Select i'th row.
        index1  = i * FRAME_PIECE; % Index 1 is the index of the first element with overlap of i'th frame. 
        index2 = size(output, 2); % Index 2 is the index of the last element with overlap of the i'th frame and thus the length of the output so far.
        lengte_overlap = index2 - index1;
        correlation = [0,0];%Correlation is the largest value of the cross-correlation function and it's index.
        for j = (index1-74):(index1+74)% Approximately 148 data points in a 300Hz signal period. Typically, the lowest fundamental frequency of human voices is 300Hz.
            sum = 0;% Temporary value.
            for k = 0:(lengte_overlap-j-1)%Represents the sum in the cross-correlation formula.
                sum = sum + output(k, 1)* stukje(k+j, 1);
            end
            sum = sum/lengte_overlap;%Represents the 1/L in the correlation formula.
            if sum > correlation(1,1) % Checks to see whether it may be a peak.
                correlation(1,1) = sum;
                correlation(1,2) = j;
            end
        end
        index1 = index1 + correlation(1, 2); 
        output(index1:index2) = output(index1:index2) + stukje(1:lengte_overlap+1); % Summing up the overlapping parts.
        output = [output, stukje(lengte_overlap:size(stukje, 2))]; % Adding the non-overlapping elements of the following frame to the output.
        index1 = index1 - correlation(1, 2);
    end

    % Resultaat afspelen
    p = audioplayer(output, SAMPLING_RATE);
    play(p);


