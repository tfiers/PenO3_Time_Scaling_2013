function timeshifted_signal = timeshift_PSOLA_test(filename, sample_rate, overlap, fps, alpha, window_overlap)
    % Speeds up/slows down audio with Pitch-Synchronous Overlap and Add (PSOLA).
    
    % filename          A string giving the absolute or relative path of a .wav
    %                   file. E.g. 'Speech Materials\annelies1.wav' or
    %                   'C:\annelies1.wav'.
    % sample_rate       E.g. 44100, which means that 44100 samples represent 1
    %                   second.
    % overlap           A value in (0,1). 0.2 for example means that when the input
    %                   signal is broken into frames, they will overlap for 20%.
    % fps               Frames per second. Determines in how many frames the
    %                   input signal will be chopped and how long the frames will be.
    %                   E.g. 10.
    % alpha             A value in (0,2) that determines the amount of time
    %                   stretching. alpha in (0,1) speeds up the signal, alpha
    %                   in (1,2) slows it down. Alpha must be smaller than 1/(1-overlap),
    %                   (else there would be gaps in the output signal.)
    %                   (See in code, at definiton of 'time_shift' for explanation.)
    % window_overlap    Similar to overlap, but applied to the Hamming
    %                   windows within the frames.
    
    % Provide default argument values.
    if nargin == 0 % Number of arguments in.
        filename = 'Speech Materials/goedele1.wav';
        sample_rate = 44100;
        overlap = 0.5;
        fps = 10;
        alpha = 1.5;
        window_overlap = 0.5
    end
    
    tic
    
    %Determins the band size to look at while looking for a maximum to
    %avoid the effects of outliers.
    MARGIN_OF_ERROR_FOR_MAXIMUM = 2;

    %Number of peaks per Hanning-window
    PEAKS_PER_WINDOW = 2;

    %Define maximum and minumum allowed pitches to avoid extreme values.
    MAX_PITCH = 300;
    MIN_PITCH = 50;
    
    %To avoid the frames getting smaller than the windows.
    if fps > MIN_PITCH/PEAKS_PER_WINDOW
        timeshifted_signal = 0;
    else

        input = audioread(filename); % Load audio file.
        input_left = input(:, 1); % Split channels (for stereo audio)
        input_right = input(:, 2); % We assume the input is nx2.
        % It could be that the left signal is in the second row, of course.

        % Chop the input signals into overlapping frames.
        % framesl/framesr have dimensions num_frames:frame_size
        frames_left = make_frames(input_left, sample_rate, overlap, fps);
        frames_right = make_frames(input_right, sample_rate, overlap, fps);
        number_of_frames = size(frames_left, 1);
        frame_size = size(frames_left, 2);

        %Used to piece together the frames afterwards.
        non_overlap = round(alpha * frame_size * (1-overlap));
        index1 = 1;

        % Pitch detection per frame.
        for i=1:number_of_frames
            pitch = autoCorrelation(frames_right(i,:), sample_rate);
            if pitch > MAX_PITCH
                pitch = MAX_PITCH;
            elseif pitch < MIN_PITCH
                pitch = MIN_PITCH;
            end

            %Look for maximum value as that's definately a peak.
            max_average_value_index = 1+MARGIN_OF_ERROR_FOR_MAXIMUM;
            max_average_value_till_now = sum(frames_left(i,1:1+2*MARGIN_OF_ERROR_FOR_MAXIMUM))/(1 + 2*MARGIN_OF_ERROR_FOR_MAXIMUM);

            for j=1+MARGIN_OF_ERROR_FOR_MAXIMUM:frame_size-MARGIN_OF_ERROR_FOR_MAXIMUM
                average_value = sum(frames_left(i,j-MARGIN_OF_ERROR_FOR_MAXIMUM:j+MARGIN_OF_ERROR_FOR_MAXIMUM))/(1 + 2*MARGIN_OF_ERROR_FOR_MAXIMUM);
                if average_value > max_average_value_till_now
                    max_average_value_till_now = average_value;
                    max_average_value_index = j;
                end
            end

            %Define pitchmarks

            pitchmarks = zeros(1, frame_size);

            %Define upcoming peaks
            for j=max_average_value_index:sample_rate/pitch:frame_size

                pitchmarks(1,round(j)) = 1;

            end
            %Define previous peaks
            for j=max_average_value_index:-sample_rate/pitch:1
                pitchmarks(1,round(j)) = 1;
                first_pitchmark = round(j); %Used later to calculate the location of the final pitchmarks.

            end

            %Make smaller windows
            Hanning_windows_left = make_frames(frames_left(i,:)', sample_rate, window_overlap, pitch/PEAKS_PER_WINDOW);
            Hanning_windows_right = make_frames(frames_right(i,:)', sample_rate, window_overlap, pitch/PEAKS_PER_WINDOW);
            window_pitchmarks = make_frames(pitchmarks', sample_rate, window_overlap, pitch/PEAKS_PER_WINDOW);

            %Conevert to Hanning windows
            Hanning_windows_left = bsxfun(@times, hann(size(Hanning_windows_left,2))', Hanning_windows_left);
            Hanning_windows_right = bsxfun(@times, hann(size(Hanning_windows_left,2))', Hanning_windows_right);

            %The last window tends to contain a large amount of zeros due to the way it is calculated and is
            %removed.
            Hanning_windows_left = Hanning_windows_left(1:end-1,:);
            Hanning_windows_right = Hanning_windows_right(1:end-1,:);
            window_pitchmarks = window_pitchmarks(1:end-1,:);

            %Define start and end indexes for the Hanning windows
            window_indexes = zeros(size(Hanning_windows_left,1),2);
            for j = 1:size(Hanning_windows_left,1)

                window_indexes(j,1) = round((j-1)*(1-window_overlap)*alpha*size(Hanning_windows_left,2)+1);
                window_indexes(j,2) = window_indexes(j,1) + size(Hanning_windows_left,2);

            end

            %The length of the final frame.
            final_frame_size = round(alpha*frame_size);

            %Create array of final frame length with final pitchmarks
            final_pitchmarks = zeros(1,final_frame_size);
            for j = first_pitchmark:round(sample_rate*alpha/pitch):final_frame_size

                final_pitchmarks(1,j) = 1;

            end

            %The final frame
            final_frame = zeros(2,size(final_pitchmarks,2));

            %For each pitchmark:
            %-Find the two windows with the start and end indexes closest to
            %the pitchmark. The begin index must be before the pitchmark and 
            %the end index must be after the pitchmark. (May be the same window.)
            %-Look for the closest pitchmark in those two windows.
            %-Shift the window with the closest pitchmark untill the windows
            %line-up.
            %-Add the window to the final frame.
            for j = 1:size(final_pitchmarks,2)
                if final_pitchmarks(1,j) == 1
                    %Find the closest begin and end index
                    [~, window_before] = min(abs(bsxfun(@minus, window_indexes(:,2), j)));
                    [~, window_after] = min(abs(bsxfun(@minus, window_indexes(:,1), j)));

                    %Make sure the closest end index is after j and the closest
                    %begin index is before j. The second statement is there to
                    %avoid an index out of bounds in the loop in k below.
                    if (window_indexes(window_before, 2) < j) & (window_before ~= size(window_pitchmarks,1))
                        window_before = window_before + 1;
                    end
                    if window_indexes(window_after, 1) > j
                        window_after = window_after - 1;
                    end

                    %Find out how far away the closest pitchmarks are in both
                    %windows.
                    pitchmark_distance_before = inf;
                    pitchmark_distance_after = inf;
                    %To cope with a window without pitchmarks.
                    while pitchmark_distance_before == inf && pitchmark_distance_after == inf

                        for k= 1:size(window_pitchmarks(window_before,:),2)
                            %Both windows are of equal length.
                            if window_pitchmarks(window_before, k) == 1 & abs(j - window_indexes(window_before, 1) - k) < abs(pitchmark_distance_before)
                                pitchmark_distance_before = j - window_indexes(window_before, 1) - k + 1;
                            end
                            if window_pitchmarks(window_after, k) == 1 & abs(j - window_indexes(window_after, 1) - k) < abs(pitchmark_distance_after)
                                pitchmark_distance_after = j - window_indexes(window_after, 1) - k + 1;
                            end
                        end

                        %For use in the next iteration if no pitchmark has been
                        %found.
                        if window_before ~= 1
                            window_before = window_before - 1;
                        end
                        if window_after ~= size(window_indexes, 1)
                            window_after = window_after + 1;    
                        end

                    end

                    if abs(pitchmark_distance_before) > abs(pitchmark_distance_after)
                        %To avoid index out of bounds
                        if (window_indexes(window_after,1) + pitchmark_distance_after + size(Hanning_windows_left, 2) - 1) > size(final_frame, 2)
                            final_frame(1,window_indexes(window_after,1) + pitchmark_distance_after : size(final_frame, 2)) = final_frame(1,window_indexes(window_after,1) + pitchmark_distance_after : size(final_frame, 2)) + Hanning_windows_left(window_after, 1 : size(final_frame, 2) - window_indexes(window_after, 1) - pitchmark_distance_after + 1);
                            final_frame(2,window_indexes(window_after,1) + pitchmark_distance_after : size(final_frame, 2)) = final_frame(2,window_indexes(window_after,1) + pitchmark_distance_after : size(final_frame, 2)) + Hanning_windows_right(window_after, 1 : size(final_frame, 2) - window_indexes(window_after, 1) - pitchmark_distance_after + 1);
                        else
                            final_frame(1,window_indexes(window_after,1) + pitchmark_distance_after : window_indexes(window_after,1) + pitchmark_distance_after + size(Hanning_windows_left, 2) - 1) = final_frame(1,window_indexes(window_after,1) + pitchmark_distance_after : window_indexes(window_after,1) + pitchmark_distance_after + size(Hanning_windows_left, 2) - 1) + Hanning_windows_left(window_after, :);
                            final_frame(2,window_indexes(window_after,1) + pitchmark_distance_after : window_indexes(window_after,1) + pitchmark_distance_after + size(Hanning_windows_right, 2) - 1) = final_frame(2,window_indexes(window_after,1) + pitchmark_distance_after : window_indexes(window_after,1) + pitchmark_distance_after + size(Hanning_windows_right, 2) - 1) + Hanning_windows_right(window_after, :);
                        end
                    else
                        %To avoid index out of bounds
                        if (window_indexes(window_before,1) + pitchmark_distance_before + size(Hanning_windows_left, 2) - 1) > size(final_frame, 2)
                            final_frame(1,window_indexes(window_before,1) + pitchmark_distance_before : size(final_frame, 2)) = final_frame(1,window_indexes(window_before,1) + pitchmark_distance_before : size(final_frame, 2)) + Hanning_windows_left(window_before, 1 : size(final_frame, 2) - window_indexes(window_before, 1) - pitchmark_distance_before + 1);
                            final_frame(2,window_indexes(window_before,1) + pitchmark_distance_before : size(final_frame, 2)) = final_frame(2,window_indexes(window_before,1) + pitchmark_distance_before : size(final_frame, 2)) + Hanning_windows_right(window_before, 1 : size(final_frame, 2) - window_indexes(window_before, 1) - pitchmark_distance_before + 1);
                        elseif (window_indexes(window_before,1) + pitchmark_distance_before < 1)
                            final_frame(1, 1 : window_indexes(window_before,1) + pitchmark_distance_before + size(Hanning_windows_left, 2) - 1) = final_frame(1, 1 : window_indexes(window_before,1) + pitchmark_distance_before + size(Hanning_windows_left, 2) - 1) + Hanning_windows_left(window_before, 2 - window_indexes(window_before,1) - pitchmark_distance_before : size(Hanning_windows_left, 2));
                            final_frame(2, 1 : window_indexes(window_before,1) + pitchmark_distance_before + size(Hanning_windows_left, 2) - 1) = final_frame(2, 1 : window_indexes(window_before,1) + pitchmark_distance_before + size(Hanning_windows_left, 2) - 1) + Hanning_windows_right(window_before, 2 - window_indexes(window_before,1) - pitchmark_distance_before : size(Hanning_windows_left, 2));
                        else
                            final_frame(1,window_indexes(window_before,1) + pitchmark_distance_before : window_indexes(window_before,1) + pitchmark_distance_before + size(Hanning_windows_left, 2) - 1) = final_frame(1,window_indexes(window_before,1) + pitchmark_distance_before : window_indexes(window_before,1) + pitchmark_distance_before + size(Hanning_windows_left, 2) - 1) + Hanning_windows_left(window_before, :);
                            final_frame(2,window_indexes(window_before,1) + pitchmark_distance_before : window_indexes(window_before,1) + pitchmark_distance_before + size(Hanning_windows_right, 2) - 1) = final_frame(2,window_indexes(window_before,1) + pitchmark_distance_before : window_indexes(window_before,1) + pitchmark_distance_before + size(Hanning_windows_right, 2) - 1) + Hanning_windows_right(window_before, :);
                        end
                    end 

                end

            end
            if i==1
                timeshifted_signal = final_frame;
            else
                %Determine the length of the overlap
                index1 = index1 + non_overlap;
                index2 = size(timeshifted_signal, 2);
                length_overlap = index2 - index1 +1;

                % Generate a vector linearly decreasing from 1 to 0.
                fade_out = linspace(1, 0, length_overlap);
                % Generate a vector linearly increasing from 0 to 1.
                fade_in = linspace(0, 1, length_overlap);

                % Sum up the overlapping samples of the output signal and the new frames, 
                % weighted by respectively the fade_in and fade_out vectors.
                timeshifted_signal(1:2, index1:index2) = timeshifted_signal(1:2, index1:index2) .* [fade_out; fade_out] ...
                                                         + final_frame(:,1:length_overlap) .* [fade_in; fade_in];                                
                % Add the rest of the samples of framel/framer to the output (those samples do not overlap). 
                timeshifted_signal = [timeshifted_signal, final_frame(:,length_overlap+1:end)];
            end
        end

        timeshifted_signal = timeshifted_signal';
        
    end
    
    toc
    
end

