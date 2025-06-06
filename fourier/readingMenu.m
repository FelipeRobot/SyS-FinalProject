
function readingMenu()

    % Adquisición información de audio
    info = audioinfo(".\SyS-FinalProject\melody.wav");

    % Mostrar la información
    disp(['Duración: ' num2str(info.Duration) ' segundos']);
    disp(['Frecuencia de muestreo: ' num2str(info.SampleRate) ' Hz']);
    disp(['Bits por muestra: ' num2str(info.BitsPerSample) ' bits']);
    disp(['Número de canales: ' num2str(info.NumChannels)]);

end