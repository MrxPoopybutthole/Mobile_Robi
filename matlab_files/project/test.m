x = [0.2:0.1:1.6];
y = [82, 75, 50, 38, 30, 26, 20, 20, 18, 16, 20, 12, 14, 30, 28];


figure(1);
plot(x,y)
ylim([10 85])
title("Parametersuche: KP (Regelparameter)")
xlabel("KP in Radiant")
ylabel("Anzahl Fehler")