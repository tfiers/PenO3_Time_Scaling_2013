% function [offsets, correlation] = correlation(signal1, signal2, maximum_offset)
%     % Row vector containing the x-axis values of the correlation function.
%     offsets = -maximum_offset:maximum_offset;
%     % Number of values (offsets) for which the correlation function is evaluated.
%     num_offsets = max(size(offsets));
%     % Row vector containing the correlation function.
%     correlation = zeros(1, num_offsets);
%     % Evaluate cross correlation function (eq. 1 in assignment document) for each point of the overlap.
%     % We start by shifting the new frame to the left by 'maximum_offset'
%     % 'j' is k_m in the assignment document.
%     % for j = 1:maximum_offset
%     %     % Number saying how well the new frame (shifted by j) and the existing output signal overlap:
%     %     % Throughs on throughs / valleys on valleys make positive values, while
%     %     % valleys and througs make negative values (both proportional to amplitude).
%     %     correlation(1, j) = sum(signal1(j:end) .* signal2(1:end-j));
%     % end
%     % for j = 1:maximum_offset
%     %     % Number saying how well the new frame (shifted by j) and the existing output signal overlap:
%     %     % Throughs on throughs / valleys on valleys make positive values, while
%     %     % valleys and througs make negative values (both proportional to amplitude).
%     %     correlation(1, maximum_offset+j+1) = sum(signal2(j:end) .* signal1(1:end-j));
%     % end

%     for i = 1:num_offsets
%         offset = offsets(i);
%     end
% end

function [offsets, corr] = correlation(signal1, signal2, max_left_shift, max_right_shift)
    % Computes and returns the cross correlation function of the given signals,
    % shifting the second signal left to a max of 'max_left_shift' samples, and 
    % right to a max of 'max_right_shift' samples.

    % Row vector containing the x-axis values of the correlation function,
    % determining by how many samples the second signal is shifted à propos the first.
    % Negative values shift the second signal backwards, positive forwards.
    offsets = -max_left_shift:max_right_shift;
    % Number of values (offsets) for which the correlation function is evaluated.
    num_offsets = max(size(offsets));
    % Row vector containing the correlation function.
    % Evaluate cross correlation function (eq. 1 in assignment document) for each point of the overlap.
    % We start by shifting the second signal to the right.
    left_shift = correlation_only_shift_fwd(signal2, signal1, max_left_shift);
    right_shift = correlation_only_shift_fwd(signal1, signal2, max_right_shift);
    corr = [left_shift(end-1:-1:1) right_shift];
end
