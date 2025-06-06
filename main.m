function [audioData, fs] = loadAudioFile(filename)
    try
        [audioData, fs] = audioread(filename);
        
        info = sprintf(['Información del audio:\n' ...
                       'Duración: %.2f segundos\n' ...
                       'Frecuencia de muestreo: %d Hz\n' ...
                       'Bits por muestra: 16 bits\n' ...
                       'Número de canales: %d'], ...
                       length(audioData)/fs, fs, size(audioData,2));
        
        disp(info);
        msgbox(info, 'Información del audio', 'help');
        
    catch ME
        error_msg = sprintf('Error al cargar el archivo de audio: %s', ME.message);
        disp(error_msg);
        msgbox(error_msg, 'Error', 'error');
        error(error_msg);
    end
end

function visualizeSignal(audioData, fs, startTime, endTime)
    try
        t = (0:length(audioData)-1)/fs;
        startIdx = max(1, round(startTime * fs));
        endIdx = min(length(audioData), round(endTime * fs));
        
        figure('Name', sprintf('Señal de audio (%.1f - %.1f segundos)', startTime, endTime));
        plot(t(startIdx:endIdx), audioData(startIdx:endIdx));
        xlabel('Tiempo (s)');
        ylabel('Amplitud');
        title(sprintf('Segmento de la señal: %.1f - %.1f segundos', startTime, endTime));
        grid on;
        
    catch ME
        error_msg = sprintf('Error al visualizar la señal: %s', ME.message);
        disp(error_msg);
        msgbox(error_msg, 'Error de visualización', 'error');
    end
end

function playAudio(audioData, fs)
    try
        play_msg = 'Reproduciendo audio...';
        disp(play_msg);
        msgbox(play_msg, 'Reproducción de audio', 'help');
        
        sound(audioData, fs);
        
    catch ME
        error_msg = sprintf('Error al reproducir el audio: %s', ME.message);
        disp(error_msg);
        msgbox(error_msg, 'Error de reproducción', 'error');
    end
end

function plotFFT(audioData, fs, startTime, endTime)
    try
        startIdx = max(1, round(startTime * fs));
        endIdx = min(length(audioData), round(endTime * fs));
        segment = audioData(startIdx:endIdx);
        
        N = length(segment);
        Y = fft(segment);
        P2 = abs(Y/N);
        P1 = P2(1:N/2+1);
        P1(2:end-1) = 2*P1(2:end-1);
        f = fs*(0:(N/2))/N;
        
        figure('Name', sprintf('Análisis FFT (%.1f - %.1f segundos)', startTime, endTime));
        plot(f, P1);
        title(sprintf('Espectro de amplitud de un solo lado (%.1f - %.1f segundos)', startTime, endTime));
        xlabel('Frecuencia (Hz)');
        ylabel('|P1(f)|');
        grid on;
        xlim([0, 2000]);
        
    catch ME
        error_msg = sprintf('Error en el análisis FFT: %s', ME.message);
        disp(error_msg);
        msgbox(error_msg, 'Error FFT', 'error');
    end
end

function note = detectNote(segment, fs)
    try
        notes = struct('name', {'A4', 'A#4', 'B4', 'C5', 'C#5', 'D5', 'D#5', 'E5', 'F5', 'F#5', 'G5', 'G#5'}, ...
                      'freq', {440, 466.16, 493.88, 523.25, 554.37, 587.33, 622.25, 659.26, 698.46, 739.99, 783.99, 830.61});
        
        N = length(segment);
        Y = fft(segment);
        P2 = abs(Y/N);
        P1 = P2(1:N/2+1);
        f = fs*(0:(N/2))/N;
        
        [~, maxIdx] = max(P1);
        peakFreq = f(maxIdx);
        
        freqs = [notes.freq];
        [~, noteIdx] = min(abs(freqs - peakFreq));
        note = notes(noteIdx).name;
        
    catch ME
        error_msg = sprintf('Error al detectar la nota: %s', ME.message);
        disp(error_msg);
        note = 'Desconocida';
    end
end

function analyzeSegment(audioData, fs, startTime, endTime)
    try
        startIdx = max(1, round(startTime * fs));
        endIdx = min(length(audioData), round(endTime * fs));
        segment = audioData(startIdx:endIdx);
        
        detectedNote = detectNote(segment, fs);
        
        analysis_msg = sprintf('Análisis del segmento (%.1f - %.1f segundos):\nNota detectada: %s', ...
                              startTime, endTime, detectedNote);
        
        disp(analysis_msg);
        msgbox(analysis_msg, 'Análisis del segmento', 'help');
        
        visualizeSignal(audioData, fs, startTime, endTime);
        plotFFT(audioData, fs, startTime, endTime);
        
    catch ME
        error_msg = sprintf('Error en el análisis del segmento: %s', ME.message);
        disp(error_msg);
        msgbox(error_msg, 'Error de análisis', 'error');
    end
end

function analyzeFullAudio(audioData, fs)
    try
        totalDuration = length(audioData)/fs;
        segmentDuration = 1;
        numSegments = floor(totalDuration / segmentDuration);
        noteSequence = cell(numSegments, 1);
        
        progress_msg = sprintf('Analizando %d segmentos de %.1f segundos cada uno...', numSegments, segmentDuration);
        disp(progress_msg);
        msgbox(progress_msg, 'Análisis completo iniciado', 'help');
        
        for i = 1:numSegments
            startTime = (i-1)*segmentDuration;
            endTime = i*segmentDuration;
            startIdx = round(startTime*fs) + 1;
            endIdx = round(endTime*fs);
            segment = audioData(startIdx:endIdx);
            
            noteSequence{i} = detectNote(segment, fs);
            fprintf('Segmento %d/%d: Nota %s detectada\n', i, numSegments, noteSequence{i});
        end
        
        results_msg = sprintf('¡Análisis completo finalizado!\nSecuencia de notas detectadas:\n%s', strjoin(noteSequence', ' -> '));
        disp('Secuencia de notas detectadas:');
        disp(noteSequence');
        msgbox(results_msg, 'Resultados del análisis', 'help');
        
    catch ME
        error_msg = sprintf('Error en el análisis completo: %s', ME.message);
        disp(error_msg);
        msgbox(error_msg, 'Error de análisis completo', 'error');
    end
end

function filename = selectAudioFile()
    [file, path] = uigetfile({'*.wav;*.mp3;*.m4a;*.flac', 'Archivos de audio (*.wav,*.mp3,*.m4a,*.flac)'; ...
                              '*.wav', 'Archivos WAV (*.wav)'; ...
                              '*.mp3', 'Archivos MP3 (*.mp3)'; ...
                              '*.*', 'Todos los archivos (*.*)'}, ...
                              'Selecciona un archivo de audio');
    
    if isequal(file, 0)
        filename = '';
        disp('Selección de archivo cancelada.');
        return;
    end
                            
    filename = fullfile(path, file);
    
    if ~exist(filename, 'file')
        error_msg = sprintf('El archivo seleccionado no existe: %s', filename);
        disp(error_msg);
        msgbox(error_msg, 'Error de archivo', 'error');
        filename = '';
    end
end

function mainStructure()
    audioData = [];
    fs = [];
    filename = '';
    
    while true
        msg = "Proyecto Final SyS - Danna Sofía Villa - Felipe Useche";
        
        options = {'Cargar archivo de audio', 'Reproducir audio', 'Analizar segmento', 'Análisis completo', 'Transformada de Fourier', 'Salir'};
        state = menu(msg, options);
        
        switch state
            case 1
                filename = selectAudioFile();
                if ~isempty(filename)
                    [audioData, fs] = loadAudioFile(filename);
                end
                
            case 2
                if isempty(audioData)
                    msgbox('Por favor, carga primero un archivo de audio.', 'Audio no cargado', 'warn');
                else
                    playAudio(audioData, fs);
                end
                
            case 3
                if isempty(audioData)
                    msgbox('Por favor, carga primero un archivo de audio.', 'Audio no cargado', 'warn');
                else
                    totalDuration = length(audioData)/fs;
                    prompt = {sprintf('Tiempo de inicio (0 - %.2f segundos):', totalDuration), ...
                             sprintf('Tiempo de fin (0 - %.2f segundos):', totalDuration)};
                    dlgtitle = 'Análisis de segmento';
                    dims = [1 35];
                    definput = {'0', '1'};
                    answer = inputdlg(prompt, dlgtitle, dims, definput);
                    
                    if ~isempty(answer)
                        startTime = str2double(answer{1});
                        endTime = str2double(answer{2});
                        
                        if isnan(startTime) || isnan(endTime) || startTime < 0 || endTime > totalDuration || startTime >= endTime
                            msgbox('Rango de tiempo inválido.', 'Entrada inválida', 'error');
                        else
                            analyzeSegment(audioData, fs, startTime, endTime);
                        end
                    end
                end
                
            case 4
                if isempty(audioData)
                    msgbox('Por favor, carga primero un archivo de audio.', 'Audio no cargado', 'warn');
                else
                    analyzeFullAudio(audioData, fs);
                end
                
            case 5
                if isempty(audioData)
                    msgbox('Por favor, carga primero un archivo de audio.', 'Audio no cargado', 'warn');
                else
                    totalDuration = length(audioData)/fs;
                    prompt = {sprintf('Tiempo de inicio (0 - %.2f segundos):', totalDuration), ...
                             sprintf('Tiempo de fin (0 - %.2f segundos):', totalDuration)};
                    dlgtitle = 'Análisis FFT';
                    dims = [1 35];
                    definput = {'0', '1'};
                    answer = inputdlg(prompt, dlgtitle, dims, definput);
                    
                    if ~isempty(answer)
                        startTime = str2double(answer{1});
                        endTime = str2double(answer{2});
                        
                        if isnan(startTime) || isnan(endTime) || startTime < 0 || endTime > totalDuration || startTime >= endTime
                            msgbox('Rango de tiempo inválido.', 'Entrada inválida', 'error');
                        else
                            plotFFT(audioData, fs, startTime, endTime);
                        end
                    end
                end
                
            case 6
                break;
                
            otherwise
                break;
        end
    end
end

mainStructure();
