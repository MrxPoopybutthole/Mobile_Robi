function [alpha] = alphahist(xy, old_alpha, k)
    
    alphas = atan2d((xy(1+k:end, 2) - xy(1:end-k, 2)), (xy(1+k:end, 1) - xy(1:end-k, 1))); % Berechnen der Winkel zwischen den Punkten in 'xy' mit Hilfe der Funktion atan2d
    alphas = -alphas; % Invertieren der Winkel, um sie an die entsprechende Konvention anzupassen

    [N, edges] = histcounts(alphas, -180:5:180); % Erstellen eines Histogramms der Winkel mit den angegebenen Bins (-180 bis 180 Grad mit einer Schrittweite von 5 Grad)
    old_alpha_index = round((old_alpha+180)/5); % Berechnen des Index des alten Winkels im Histogramm
    shift_index = 36-old_alpha_index; % Berechnen des Shift-Index basierend auf dem alten Index

    N = circshift(N, shift_index); % Zirkuläres Verschieben der Histogrammwerte um den Shift-Index

    indis = 36-4:36+4; % Festlegen des Bereichs von Bins, die verwendet werden sollen

    sum_N_used = sum(N(indis)); % Berechnen der Summe der Histogrammwerte in den ausgewählten Bins
    %disp(sum_N_used); % Ausgabe der Summe (optional, kann zum Debuggen verwendet werden)

    if sum_N_used < 10 % Überprüfung, ob die Summe der Histogrammwerte unter einem bestimmten Schwellenwert liegt
        N = circshift(N, 36); % Zirkuläres Verschieben aller Histogrammwerte um den maximalen Shift-Index (36)
    end

    N_used = N(indis); % Extrahieren der verwendeten Histogrammwerte
    sum_N_used = sum(N_used); % Berechnen der Summe der verwendeten Histogrammwerte
    %disp(sum_N_used); % Ausgabe der Summe (optional, kann zum Debuggen verwendet werden)

    edges_used = edges(indis) + 2.5; % Extrahieren der Ränder der verwendeten Bins und Hinzufügen einer Verschiebung von 2,5 Grad
    
    % Überprüfung, ob die Summe der verwendeten Histogrammwerte unter einem bestimmten Schwellenwert liegt
    if sum_N_used < 10 
        alpha = old_alpha; % Verwenden des alten Winkels als Ergebnis
    else
        alpha = sum(N_used.*edges_used)/sum_N_used - (shift_index*5); % Berechnen des gewichteten Durchschnitts der Winkel basierend auf den Histogrammwerten und Rändern der verwendeten Bins
        % Überprüfung, ob der berechnete Winkel größer als 180 Grad ist
        if(alpha > 180) 
            alpha = -180 + mod(alpha, 180); % Anpassen des Winkels, um ihn im Bereich von -180 bis 180 Grad zu halten
        % Überprüfung, ob der berechnete Winkel kleiner als -180 Grad ist
        elseif (alpha < -180) 
            alpha = 180 + mod(alpha, -180); % Anpassen des Winkels, um ihn im Bereich von -180 bis 180 Grad zu halten
        end
    end

   
   figure(2);
   %Histogramm plotten
   histogram(alphas, 0:1:180);
   title("Histogramm der Alphas")
   xlabel("Alpha")
   ylabel("Häufigkeit")

end