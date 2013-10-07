function [ timeshifted_signal ] = timeshift_OLA(filename, sample_rate, alpha, fps, overlap)
% Speeds up/slows down audio with Overlap and Add (OLA).
    
    % filename A string giving the absolute or relative path of a .wav
    % file. E.g. 'Speech Materials\annelies1.wav' or
    % 'C:\annelies1.wav'.
    % sample_rate E.g. 44100, which means that 44100 samples represent 1
    % second.
    % alpha A value in (0,2) that determines the amount of time
    % stretching. alpha in (0,1) speeds up the signal, alpha
    % in (1,2) slows it down.
    % fps Frames per second. Determines in how many frames the
    % input signal will be chopped and how long they will be.
    % overlap A value in (0,1). E.g. 0.5 means the frames will be
    % overlapped for 50%.
    
    
    tic % For measuring how long this function took to complete.

    input = audioread(filename); % load wav-file
    
    % Y = resample(input, 2, 1); % resample at half the speed
    % player = audioplayer(input, sample_rate); %player element, easy to play/pause sound
    
    % Break into pieces.
    frame_size = round(sample_rate / fps);
    framesl = [];
    framesr = [];
    for i = 1:round(frame_size*overlap):size(input, 1) % size(input,1) is the number of rows (samples) of the input signal.
        if i < size(input, 1) - frame_size
            framesl = [framesl; input(i:i+frame_size-1,1)']; % Because of the 50% overlap, we go from i till i+2*frame_size-1 so we get 2*frame_size values
            framesr = [framesr; input(i:i+frame_size-1,2)'];
        else
            % Add zeros to incomplete frames to match them up with complete frames.
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
        index1 = (i-1) * time_shift; % Index 1 is the index in output of the i'th frame where its overlap starts with its previous frame.
        index2 = size(timeshifted_signal, 2); % Index 2 is the index of the last sample with overlap of the i'th frame and thus the length of the output so far.
        length_overlap = index2 - index1 + 1; % the sample at index1 itself is also overlapping, thus + 1
        fade_out = linspace(0,1,length_overlap);
        fade_in = linspace(1,0,length_overlap);
        timeshifted_signal(1:2, index1:index2) = timeshifted_signal(1:2, index1:index2).*fade_out + [framel(1:length_overlap);framer(1:length_overlap)].*fade_in ; % Summing up the overlapping parts.
        timeshifted_signal = [timeshifted_signal, [framel(length_overlap+1:size(framel, 2)); framer(length_overlap+1:size(framer, 2))]]; % Adding the non-overlapping elements of the following frame to the output.
    end
    timeshifted_signal = timeshifted_signal'; %transpose
    toc
end