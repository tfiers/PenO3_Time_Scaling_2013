function  plot_frequency_spectra(filename1, filename2, name1_legend, name2_legend)
    % Plots frequency spectra and signal in time domain of the signals in the files of the given names.

    x = audioread(filename1);
    y = audioread(filename2);
    Fs = 44100;                   % Sampling frequency
    L = size(x, 1);               % Length of signal
    T = 1/Fs;                     % Sample time
    t = (0:L-1)*T;                % Time vector

    NFFT = 2^nextpow2(L); % Next power of 2 from length of y
    X = fft(x,NFFT)/L;
    Y = fft(y,NFFT)/L;
    f = Fs/2*linspace(0,1,NFFT/2+1);

    figure
    plot(f,2*abs(X(1:NFFT/2+1)),'c')
    title('Frequency spectra')
    xlabel('Frequency (Hz)')
    ylabel('Power')
    hold on
    plot(f,2*abs(Y(1:NFFT/2+1)),'b')
    axis([0 1.5*10^4 0 0.01])
    legend(name1_legend, name2_legend)
    hold off


    figure
    plot(x,'c')
    title('Audio signals')
    xlabel('Time (s)')
    ylabel('Amplitude')
    hold on
    plot(y,'b')
    legend(name1_legend, name2_legend)
    hold off

end
