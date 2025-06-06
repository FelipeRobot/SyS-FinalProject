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
    try
        % Load audio file
        [audioData, fs] = audioread(filename);
        
        % Create audio information message
        info = sprintf(['Audio Information:\n' ...
                       'Duration: %.2f seconds\n' ...
                       'Sampling Frequency: %d Hz\n' ...
                       'Bits per sample: 16 bits\n' ...
                       'Number of channels: %d'], ...
                       length(audioData)/fs, fs, size(audioData,2));
        
        % Display in console
        disp(info);
        
        % Display in popup window
        msgbox(info, 'Audio Information', 'help');
        
    catch ME
        error_msg = sprintf('Error loading audio file: %s', ME.message);
        disp(error_msg);
        msgbox(error_msg, 'Error', 'error');
        error(error_msg);
    end
end

%% Signal Visualization
% Function to visualize signal segment
function visualizeSignal(audioData, fs, startTime, endTime)
    try
        % Calculate time vector
        t = (0:length(audioData)-1)/fs;
        
        % Get the segment to visualize
        startIdx = max(1, round(startTime * fs));
        endIdx = min(length(audioData), round(endTime * fs));
        
        % Plot the signal
        figure('Name', sprintf('Audio Signal (%.1f - %.1f seconds)', startTime, endTime));
        plot(t(startIdx:endIdx), audioData(startIdx:endIdx));
        xlabel('Time (s)');
        ylabel('Amplitude');
        title(sprintf('Audio Signal Segment: %.1f - %.1f seconds', startTime, endTime));
        grid on;
        
    catch ME
        error_msg = sprintf('Error visualizing signal: %s', ME.message);
        disp(error_msg);
        msgbox(error_msg, 'Visualization Error', 'error');
    end
end

%% Audio Playback
% Function to play audio
function playAudio(audioData, fs)
    try
        % Show playback message
        play_msg = 'Playing audio... Press any key to stop.';
        disp(play_msg);
        msgbox(play_msg, 'Audio Playback', 'help');
        
        player = audioplayer(audioData, fs);
        play(player);
        
    catch ME
        error_msg = sprintf('Error playing audio: %s', ME.message);
        disp(error_msg);
        msgbox(error_msg, 'Playback Error', 'error');
    end
end

%% Fourier Transform Analysis
% Function to calculate and plot Fourier Transform
function plotFFT(audioData, fs, startTime, endTime)
    try
        % Get segment
        startIdx = max(1, round(startTime * fs));
        endIdx = min(length(audioData), round(endTime * fs));
        segment = audioData(startIdx:endIdx);
        
        % Calculate FFT
        N = length(segment);
        Y = fft(segment);
        P2 = abs(Y/N);
        P1 = P2(1:N/2+1);
        P1(2:end-1) = 2*P1(2:end-1);
        f = fs*(0:(N/2))/N;
        
        % Plot
        figure('Name', sprintf('FFT Analysis (%.1f - %.1f seconds)', startTime, endTime));
        plot(f, P1);
        title(sprintf('Single-Sided Amplitude Spectrum (%.1f - %.1f seconds)', startTime, endTime));
        xlabel('Frequency (Hz)');
        ylabel('|P1(f)|');
        grid on;
        xlim([0, 2000]); % Limit to relevant frequency range
        
    catch ME
        error_msg = sprintf('Error in FFT analysis: %s', ME.message);
        disp(error_msg);
        msgbox(error_msg, 'FFT Error', 'error');
    end
end

%% Note Detection
% Function to detect musical notes in a segment
function note = detectNote(segment, fs)
    try
        % Frequency ranges for notes in the diatonic scale (440Hz-880Hz)
        notes = struct('name', {'A4', 'A#4', 'B4', 'C5', 'C#5', 'D5', 'D#5', 'E5', 'F5', 'F#5', 'G5', 'G#5'}, ...
                      'freq', {440, 466.16, 493.88, 523.25, 554.37, 587.33, 622.25, 659.26, 698.46, 739.99, 783.99, 830.61});
        
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
        freqs = [notes.freq];
        [~, noteIdx] = min(abs(freqs - peakFreq));
        note = notes(noteIdx).name;
        
    catch ME
        error_msg = sprintf('Error detecting note: %s', ME.message);
        disp(error_msg);
        note = 'Unknown';
    end
end

%% Segment Analysis Function
function analyzeSegment(audioData, fs, startTime, endTime)
    try
        % Get segment
        startIdx = max(1, round(startTime * fs));
        endIdx = min(length(audioData), round(endTime * fs));
        segment = audioData(startIdx:endIdx);
        
        % Detect note
        detectedNote = detectNote(segment, fs);
        
        % Create analysis message
        analysis_msg = sprintf('Segment Analysis (%.1f - %.1f seconds):\nDetected Note: %s', ...
                              startTime, endTime, detectedNote);
        
        % Display in console and popup
        disp(analysis_msg);
        msgbox(analysis_msg, 'Segment Analysis', 'help');
        
        % Visualize
        visualizeSignal(audioData, fs, startTime, endTime);
        plotFFT(audioData, fs, startTime, endTime);
        
    catch ME
        error_msg = sprintf('Error in segment analysis: %s', ME.message);
        disp(error_msg);
        msgbox(error_msg, 'Analysis Error', 'error');
    end
end

%% Full Audio Analysis Function
function analyzeFullAudio(audioData, fs)
    try
        % Get total duration
        totalDuration = length(audioData)/fs;
        
        % Segment the signal into 1-second segments
        segmentDuration = 1; % seconds
        numSegments = floor(totalDuration / segmentDuration);
        
        % Initialize note sequence
        noteSequence = cell(numSegments, 1);
        
        % Progress message
        progress_msg = sprintf('Analyzing %d segments of %.1f seconds each...', numSegments, segmentDuration);
        disp(progress_msg);
        msgbox(progress_msg, 'Full Analysis Started', 'help');
        
        % Analyze each segment
        for i = 1:numSegments
            % Get current segment
            startTime = (i-1)*segmentDuration;
            endTime = i*segmentDuration;
            startIdx = round(startTime*fs) + 1;
            endIdx = round(endTime*fs);
            segment = audioData(startIdx:endIdx);
            
            % Detect note
            noteSequence{i} = detectNote(segment, fs);
            
            % Progress update
            fprintf('Segment %d/%d: Note %s detected\n', i, numSegments, noteSequence{i});
        end
        
        % Create results message
        results_msg = sprintf('Full Analysis Complete!\nDetected Note Sequence:\n%s', strjoin(noteSequence', ' -> '));
        
        % Display results
        disp('Detected Note Sequence:');
        disp(noteSequence');
        msgbox(results_msg, 'Analysis Results', 'help');
        
    catch ME
        error_msg = sprintf('Error in full analysis: %s', ME.message);
        disp(error_msg);
        msgbox(error_msg, 'Full Analysis Error', 'error');
    end
end

%% File Selection Function
function filename = selectAudioFile()
    % Try to open file dialog
    [file, path] = uigetfile({'*.wav;*.mp3;*.m4a;*.flac', 'Audio Files (*.wav,*.mp3,*.m4a,*.flac)'; ...
                              '*.wav', 'WAV Files (*.wav)'; ...
                              '*.mp3', 'MP3 Files (*.mp3)'; ...
                              '*.*', 'All Files (*.*)'}, ...
                              'Select an audio file');
    
    if isequal(file, 0)
        % User canceled
        filename = '';
        disp('File selection canceled.');
        return;
    end
    
    filename = fullfile(path, file);
    
    % Check if file exists
    if ~exist(filename, 'file')
        error_msg = sprintf('Selected file does not exist: %s', filename);
        disp(error_msg);
        msgbox(error_msg, 'File Error', 'error');
        filename = '';
    end
end

%% Main Structure Function
function mainStructure()
    % Initialize variables
    audioData = [];
    fs = [];
    filename = '';
    
    while true
        msg = "Proyecto Final SyS - Danna Sofia Villa - Felipe Useche";
        
        options = {'Load Audio File', 'Play Audio', 'Analyze Segment', 'Full Analysis', 'Fourier Transform', 'Exit'};
        state = menu(msg, options);
        
        switch state
            case 1 % Load Audio File
                filename = selectAudioFile();
                if ~isempty(filename)
                    [audioData, fs] = loadAudioFile(filename);
                end
                
            case 2 % Play Audio
                if isempty(audioData)
                    msgbox('Please load an audio file first.', 'No Audio Loaded', 'warn');
                else
                    playAudio(audioData, fs);
                end
                
            case 3 % Analyze Segment
                if isempty(audioData)
                    msgbox('Please load an audio file first.', 'No Audio Loaded', 'warn');
                else
                    % Get segment times from user
                    totalDuration = length(audioData)/fs;
                    prompt = {sprintf('Start time (0 - %.2f seconds):', totalDuration), ...
                             sprintf('End time (0 - %.2f seconds):', totalDuration)};
                    dlgtitle = 'Segment Analysis';
                    dims = [1 35];
                    definput = {'0', '1'};
                    answer = inputdlg(prompt, dlgtitle, dims, definput);
                    
                    if ~isempty(answer)
                        startTime = str2double(answer{1});
                        endTime = str2double(answer{2});
                        
                        if isnan(startTime) || isnan(endTime) || startTime < 0 || endTime > totalDuration || startTime >= endTime
                            msgbox('Invalid time range entered.', 'Invalid Input', 'error');
                        else
                            analyzeSegment(audioData, fs, startTime, endTime);
                        end
                    end
                end
                
            case 4 % Full Analysis
                if isempty(audioData)
                    msgbox('Please load an audio file first.', 'No Audio Loaded', 'warn');
                else
                    analyzeFullAudio(audioData, fs);
                end
                
            case 5 % Fourier Transform
                if isempty(audioData)
                    msgbox('Please load an audio file first.', 'No Audio Loaded', 'warn');
                else
                    % Get segment times from user
                    totalDuration = length(audioData)/fs;
                    prompt = {sprintf('Start time (0 - %.2f seconds):', totalDuration), ...
                             sprintf('End time (0 - %.2f seconds):', totalDuration)};
                    dlgtitle = 'FFT Analysis';
                    dims = [1 35];
                    definput = {'0', '1'};
                    answer = inputdlg(prompt, dlgtitle, dims, definput);
                    
                    if ~isempty(answer)
                        startTime = str2double(answer{1});
                        endTime = str2double(answer{2});
                        
                        if isnan(startTime) || isnan(endTime) || startTime < 0 || endTime > totalDuration || startTime >= endTime
                            msgbox('Invalid time range entered.', 'Invalid Input', 'error');
                        else
                            plotFFT(audioData, fs, startTime, endTime);
                        end
                    end
                end
                
            case 6 % Exit
                goodbye_msg = 'Thanks for using the Audio Analysis Tool!';
                disp(goodbye_msg);
                msgbox(goodbye_msg, 'Goodbye', 'help');
                break;
                
            otherwise
                % User closed the menu
                break;
        end
    end
end

% Run the main program
mainStructure();