%main%
currentDIr = pwd;

addPath(fullfile(currentDIr, 'fourier'));
addPath(fullfile(currentDIr, 'Reproduction'));
addPath(fullfile(currentDIr, 'Visualization'));

msg = "Proyecto final MATLAB. Señales y Sistemas.- Danna Sofia Villa - Felipe Useche "

while true 
    
    state = menu('Visualizar', 'Reproducir', 'Calcular y graficar Fourier');
    switch state 
        
        case 1
            %Call Visualization menu
            visualMenu();
        case 2
            %Call Reproduction menu
            reproductionMenu();
        case 3
            %Call fourier menu
    end
end 