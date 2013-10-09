function [ timeshifted_signal ] = timeshift_OLA(filename, sample_rate, overlap, fps, alpha)
    % Speeds up/slows down audio with Overlap and Add (OLA).
    
    % filename      A string giving the absolute or relative path of a .wav
    %               file. E.g. 'Speech Materials\annelies1.wav' or
    %               'C:\annelies1.wav'.
    % sample_rate   E.g. 44100, which means that 44100 samples represent 1
    %               second.
    % overlap       A value in (0,1). 0.2 for example means that when the input
    %               signal is broken into frames, they will overlap for 20%.
    % fps           Frames per second. Determines in how many frames the
    %               input signal will be chopped and how long the frames will be.
    %               E.g. 10.
    % alpha         A value in (0,2) that determines the amount of time
    %               stretching. alpha in (0,1) speeds up the signal, alpha
    %               in (1,2) slows it down. Alpha must be smaller than 1/(1-overlap),
    %               (else there would be gaps in the output signal.)

    
    
    tic % For measuring how long this function took to complete.
    
    % Provide default argument values.
    if nargin == 0 % Number of arguments in.
        filename = 'Speech Materials\devilder1.wav';
        sample_rate = 44100;
        overlap = 0.5;
        alpha = 1.5;
        fps = 10;
    end

    input = audioread(filename); % Load audio file.
    input_left = input(:, 1); % Split channels (for stereo audio)
    input_right = input(:, 2); % We assume the input is nx2.
    % It could be that the left signal is in the second row, of course.
    
    % (For later reference:)
    % Y = resample(input, 2, 1); % resample at half the speed
    % player = audioplayer(input, sample_rate);  %player element, easy to play/pause sound
    
    % Chop the input signals into overlapping frames.
    % framesl/framesr have dimensions num_frames:frame_size
    frames_left = make_frames(input_left, sample_rate, overlap, fps);
    frames_right = make_frames(input_right, sample_rate, overlap, fps);
    frame_size = size(frames_left, 2);


    % Recombine frames with a time shift.

    % This will be our eventual output signal.
    % It's dimensions during construction will be 2xn.
    % We already put in the first frame.
    % (To cut some more milliseconds from execution time, this matrix should
    %  be preallocated with zeros.)
    timeshifted_signal = [frames_left(1,:); frames_right(1,:)];
    % After 'time_shift' samples in the output signal, a new frame begins.
    % 'Ss' in the assignment document.
    % (1-overlap) gives 0.8 for an overlap of e.g. 0.2
    % For there to be no gaps in the output signal, time_shift should be smaller than frame_size,
    % or: alpha * frame_size * (1-overlap) < frame_size
    % or: alpha < 1 / (1-overlap)
    time_shift = round(alpha * frame_size * (1-overlap));
    % Add all remaining frames one by one to the output signal.
    for i = 2:size(frames_left,1)
        % Select i'th row in framesl/framer = i'th frame.
        framel = frames_left(i,:);
        framer = frames_right(i,:);
        % 'index1' is the index in the output signal where the overlap with the next-to-be-added frame (framel/framer) starts.
        index1  = (i-1) * time_shift;
        % 'index2' is the index of the last sample in the output singal, where the overlap stops of course.
        index2 = size(timeshifted_signal, 2);
        % The sample at index1 itself is also overlapping, thus + 1
        length_overlap = index2 - index1 + 1;
        % Sum up the overlapping samples of the output signal and the new frames.
        timeshifted_signal(1:2, index1:index2) = timeshifted_signal(1:2, index1:index2) ...
                                                 + [framel(1:length_overlap); framer(1:length_overlap)]; 
        % Add the rest of the samples of framel/framer to the output (those samples do not overlap). 
        timeshifted_signal = [timeshifted_signal, [framel(length_overlap+1:end); framer(length_overlap+1:end)]];
    end

    % Transpose output signal to match dimensions of input signal.
    timeshifted_signal = timeshifted_signal';

    toc
end
