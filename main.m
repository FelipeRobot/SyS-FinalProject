% # Audio Analysis and Note Detection
% 
% This script implements audio analysis functionality including:
% - Audio file loading and information display
% - Signal visualization
% - Audio playback
% - Fourier Transform analysis
% - Note detection in the diatonic scale (440Hz-880Hz)

%% Audio File Loading
% Function to load and display audio information
function [audioData, fs] = loadAudioFile(filename)
    % Load audio file
    [audioData, fs] = audioread(filename);
    
    % Display audio information
    disp('Audio Information:');
    disp(['Duration: ', num2str(length(audioData)/fs), ' seconds']);
    disp(['Sampling Frequency: ', num2str(fs), ' Hz']);
    disp(['Bits per sample: ', num2str(16), ' bits']); % Assuming 16-bit audio
    disp(['Number of channels: ', num2str(size(audioData,2))]);
end

%% Signal Visualization
% Function to visualize signal segment
function visualizeSignal(audioData, fs, startTime, endTime)
    % Calculate time vector
    t = (0:length(audioData)-1)/fs;
    
    % Get the segment to visualize
    startIdx = round(startTime * fs);
    endIdx = round(endTime * fs);
    
    % Plot the signal
    figure;
    plot(t(startIdx:endIdx), audioData(startIdx:endIdx));
    xlabel('Time (s)');
    ylabel('Amplitude');
    title('Audio Signal');
    grid on;
end

%% Audio Playback
% Function to play audio
function playAudio(audioData, fs)
    player = audioplayer(audioData, fs);
    play(player);
end

%% Fourier Transform Analysis
% Function to calculate and plot Fourier Transform
function plotFFT(audioData, fs, startTime, endTime)
    % Get segment
    startIdx = round(startTime * fs);
    endIdx = round(endTime * fs);
    segment = audioData(startIdx:endIdx);
    
    % Calculate FFT
    N = length(segment);
    Y = fft(segment);
    P2 = abs(Y/N);
    P1 = P2(1:N/2+1);
    P1(2:end-1) = 2*P1(2:end-1);
    f = fs*(0:(N/2))/N;
    
    % Plot
    figure;
    plot(f,P1)
    title('Single-Sided Amplitude Spectrum of Audio Signal')
    xlabel('f (Hz)')
    ylabel('|P1(f)|')
    grid on;
end

%% Note Detection
% Function to detect musical notes in a segment
function note = detectNote(segment, fs)
    % Frequency ranges for notes in the diatonic scale (440Hz-880Hz)
    notes = struct('name', {'A4', 'A#4', 'B4', 'C5', 'C#5', 'D5', 'D#5', 'E5', 'F5', 'F#5', 'G5', 'G#5'}, ...
                  'freq', [440, 466.16, 493.88, 523.25, 554.37, 587.33, 622.25, 659.26, 698.46, 739.99, 783.99, 830.61]);
    
    % Calculate FFT
    N = length(segment);
    Y = fft(segment);
    P2 = abs(Y/N);
    P1 = P2(1:N/2+1);
    f = fs*(0:(N/2))/N;
    
    % Find peak frequency
    [~, maxIdx] = max(P1);
    peakFreq = f(maxIdx);
    
    % Find closest note
    [~, noteIdx] = min(abs(notes.freq - peakFreq));
    note = notes.name{noteIdx};
end

%% Main Analysis Function
function analyzeAudio(filename)

     % Load audio file
     [audioData, fs] = loadAudioFile(filename);
    
     % Get total duration
     totalDuration = length(audioData)/fs;

    % Segment the signal into 1-second segments
    segmentDuration = 1; % seconds
    numSegments = floor(totalDuration / segmentDuration);
    
    % Initialize note sequence
    noteSequence = cell(numSegments, 1);
    
    % Analyze each segment
    for i = 1:numSegments
        % Get current segment
        startIdx = round((i-1)*segmentDuration*fs) + 1;
        endIdx = round(i*segmentDuration*fs);
        segment = audioData(startIdx:endIdx);
        
        % Detect note
        noteSequence{i} = detectNote(segment, fs);
        
        % Visualize segment and FFT
        subplot(2,1,1);
        visualizeSignal(audioData, fs, (i-1)*segmentDuration, i*segmentDuration);
        subplot(2,1,2);
        plotFFT(audioData, fs, (i-1)*segmentDuration, i*segmentDuration);
        
        % Add pause between segments
        pause(1);
    end
    
    % Display note sequence
    disp('Detected Note Sequence:');
    disp(noteSequence');
end



function mainStructure()

    filename = 'melody.wav';
    analyzeAudio(filename);


    while true
        msg = "Proyecto Final SyS Danna Sofia Villa- Felipe Useche "
        
        state = menu(msg, 'Reproducir', 'Fourier', 'Salir');

        switch state
            case 1
                
            case 2
                
            case 3
                break;
        end

    end
end