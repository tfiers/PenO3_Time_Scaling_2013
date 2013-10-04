function [ timeshifted_signal ] = timeshift_SOLA(filename, sample_rate, alpha, fps, overlap)
    tic
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    % Speeds up/slows down audio with Overlap and Add (OLA).
    input = audioread(filename); % load wav-file
    %,Y = resample(input, 2, 1); % resample at half the speed
    %SAMPLING_RATE = 44100; % this sample rate equals 1 second
    % player = audioplayer(input, sample_rate);  %player element, easy to play/pause sound
    % Break into pieces.
    framesl = [];
    framesr = [];
    frame_size = round(sample_rate / fps);
    for i = 1:round(frame_size*overlap):size(input, 1) % Size(input,1) is the number of rows of the input signal.
        if i < size(input, 1) - frame_size
            framesl = [framesl; input(i:i+frame_size-1,1)']; % Because of the 50% overlap, we go from i till i+ 2*frame_size-1 so we get 2*frame_size values
            framesr = [framesr; input(i:i+frame_size-1,2)'];
        else
            % add zeros to incomplete frames to match them up with complete
            % frames.
            add_zeros = frame_size - size(input(i:end,1),1); 
            framesl = [framesl; [input(i:end,1)', zeros([1, add_zeros])]];
            framesr = [framesr; [input(i:end,1)', zeros([1, add_zeros])]];
        end
    end
    
    % framesl and framesr contain an amount of rows equal to the total amount of frames and an amount of columns equal to the frame size      

    % Recombining frames taking into consideration time shift.
    timeshifted_signal = [framesl(1,:); framesr(1,:)]; % We put the first frame in the output signal
    %%%ALPHA = 1.5; % Changing alpha will change the amount of overlap and thus the speed.
    time_shift = round(alpha * frame_size*overlap); % Hoeveel samples er tussen elk nieuw frame in het outputsignaal zitten. Ss
    for i = 2:size(framesl,1)
        framel = framesl(i,:); % Select i'th row.
        framer = framesr(i,:); % Select i'th row.
        index1  = (i-1) * time_shift; % Index 1 is the index in output of the i'th frame where its overlap starts with its previous frame. 
        index2 = size(timeshifted_signal, 2); % Index 2 is the index of the last sample with overlap of the i'th frame and thus the length of the output so far.
        length_overlap = index2 - index1 + 1; % the sample at index1 itself is also overlapping, thus + 1
        
        % Synchronising the existing output and the new frame.
        correlation = [0,0]; %Correlation is the largest value of the cross-correlation function and it's index.
        for j = (index1-74):(index1+74)% Approximately 148 data points in a 300Hz signal period. Typically, the lowest fundamental frequency of human voices is 300Hz.
            sum = 0;% Temporary value.
            for k = 1:(length_overlap-j-1)%Represents the sum in the cross-correlation formula.
                sum = sum + timeshifted_signal(k, 1)* framel(1,k+j);
            end
            sum = sum/length_overlap;%Represents the 1/L in the correlation formula.
            if sum > correlation(1,1) % Checks to see whether it may be a peak.
                correlation(1,1) = sum;
                correlation(1,2) = j;
            end
        end
        index1 = index1 + correlation(1, 2); 
        
        timeshifted_signal(1:2, index1:index2) = timeshifted_signal(1:2, index1:index2) + [framel(1:length_overlap);framer(1:length_overlap)] ; % Summing up the overlapping parts.
        timeshifted_signal = [timeshifted_signal, [framel(length_overlap+1:size(framel, 2)); framer(length_overlap+1:size(framer, 2))]]; % Adding the non-overlapping elements of the following frame to the output. 

        index1 = index1 - correlation(1, 2);
    end
    timeshifted_signal = timeshifted_signal'; %transpose
    toc
end


