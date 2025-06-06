function visualMenu(x,Fs)

    fprintf('Selección de intervalo');
    t1 = input('Ingrese el tiempo inicial (en segundos): ');
    t2 = input('Ingrese el tiempo final (en segundos): ');

    % Convertir a índices de muestra
    n1 = round(t1 * Fs);
    n2 = round(t2 * Fs);

    % Eje en el tiempo
    t = (n1:n2) / Fs;

    % Extraer segmento
    segmento = x(n1:n2);

    % Graficar
    figure;
    plot(t, segmento);
    xlabel('Tiempo (s)');
    ylabel('Amplitud');
    title(sprintf('Señal entre %.2f s y %.2f s', t1, t2));
    grid on;


end