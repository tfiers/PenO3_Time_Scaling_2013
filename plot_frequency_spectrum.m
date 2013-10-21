function  plot_frequency_spectrum(y)
    % Plots frequency spectrum and signal in time domain of the given signal.

    Fs = 44100;                   % Sampling frequency
    L = max(size(y));               % Length of signal
    T = 1/Fs;                     % Sample time
    t = (0:L-1)*T;                % Time vector

    NFFT = 2^nextpow2(L); % Next power of 2 from length of y
    Y = fft(y,NFFT)/L;
    f = Fs/2*linspace(0,1,NFFT/2+1);

    figure
    plot(f,2*abs(Y(1:NFFT/2+1)),'m')
    title('Frequency spectrum')
    xlabel('Frequency (Hz)')
    ylabel('Power')

    figure
    semilogx(f,2*abs(Y(1:NFFT/2+1)),'m')
    title('Frequency spectrum (frequencies on log scale)')
    xlabel('Frequency (Hz)')
    ylabel('Power')

    figure
    plot(t, y,'m')
    title('Audio signal')
    xlabel('Time (s)')
    ylabel('Amplitude')

end
