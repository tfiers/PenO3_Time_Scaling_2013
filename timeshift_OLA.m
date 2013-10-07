function [ timeshifted_signal ] = timeshift_OLA(filename, sample_rate, alpha, fps, overlap)
    % Speeds up/slows down audio with Overlap and Add (OLA).
    
    % filename      A string giving the absolute or relative path of a .wav
    %               file. E.g. 'Speech Materials\annelies1.wav' or
    %               'C:\annelies1.wav'.
    % sample_rate   E.g. 44100, which means that 44100 samples represent 1
    %               second.
    % alpha         A value in (0,2) that determines the amount of time
    %               stretching. alpha in (0,1) speeds up the signal, alpha
    %               in (1,2) slows it down.
    % fps           Frames per second. Determines in how many frames the
    %               input signal will be chopped and how long they will be.
    %               E.g. 10.
    % overlap       A value in (0,1). E.g. 0.5 means the frames will be
    %               overlapped for 50%.
    
    
    tic % For measuring how long this function took to complete.
    
    % Provide default argument values.
    if nargin == 0 % Number of arguments in.
        filename = 'Speech Materials\devilder1.wav';
        sample_rate = 44100;
        alpha = 1.5;
        fps = 10;
        overlap = 0.5;
    end

    input = audioread(filename); % Load audio file.
    input_left = input(:, 1); % Split channels (for stereo audio)
                              % We assume the input is nx1 or nx2.
    input_right = input(:, 2);
    
    % Y = resample(input, 2, 1); % resample at half the speed
    % player = audioplayer(input, sample_rate);  %player element, easy to play/pause sound
    
    frames_left = make_frames(input_left, sample_rate, fps, overlap);
    frames_right = make_frames(input_right, sample_rate, fps, overlap);
    
    frame_size = size(frames_left, 2);

    % Recombining frames taking into consideration time shift.
    timeshifted_signal = [frames_left(1,:); frames_right(1,:)]; % We put the first frame in the output signal
    %%%ALPHA = 1.5; % Changing alpha will change the amount of overlap and thus the speed.
    time_shift = round(alpha * frame_size*overlap); % Hoeveel samples er tussen elk nieuw frame in het outputsignaal zitten. Ss
    for i = 2:size(frames_left,1)
        framel = frames_left(i,:); % Select i'th row.
        framer = frames_right(i,:); % Select i'th row.
        index1  = (i-1) * time_shift; % Index 1 is the index in output of the i'th frame where its overlap starts with its previous frame. 
        index2 = size(timeshifted_signal, 2); % Index 2 is the index of the last sample with overlap of the i'th frame and thus the length of the output so far.
        length_overlap = index2 - index1 + 1; % the sample at index1 itself is also overlapping, thus + 1
        timeshifted_signal(1:2, index1:index2) = timeshifted_signal(1:2, index1:index2) + [framel(1:length_overlap);framer(1:length_overlap)] ; % Summing up the overlapping parts.
        timeshifted_signal = [timeshifted_signal, [framel(length_overlap+1:size(framel, 2)); framer(length_overlap+1:size(framer, 2))]]; % Adding the non-overlapping elements of the following frame to the output. 
    end
    timeshifted_signal = timeshifted_signal'; %transpose
    toc
end
