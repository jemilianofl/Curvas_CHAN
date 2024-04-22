tic
% Limpieza de consola y variables
clc
clearvars
% Inicio de codigo
[name,direction]=uigetfile('*.csv');
datos = readtable([direction,name]); % Se leen los  |datos como tabla para tratarlos de forma no unificada
fechaInicio = datos.Fecha; % Se extraen las fechas
dias=caldiff(fechaInicio,"days"); % Se calcula la diferencia entre las fechas en formato de dias
diasTranscurridos=split(dias,"days"); % Se convierte de formato dias a numero
diasTranscurridos=[0;diasTranscurridos]; % Se agrega el día 0
diasTotales=zeros(1,length(diasTranscurridos))'; % Vector de 0 para calculo más rapido
% Ciclo for que suma los valores anteriores con el actual para sacar el acumulado de días
for i=2:length(diasTotales)
    diasTotales(i)=diasTranscurridos(i)+sum(diasTranscurridos(1:i-1));
end
BarrilesPetroleo=datos.Produccion_Petroleo; % Se extraen los barriles de petroleo
BarrilesAgua=datos.BAPD; % Se extraen los barriles de agua
WOR=BarrilesAgua./BarrilesPetroleo; WOR(WOR==inf)=0; % Relación Agua-Petroleo
derivada_WOR=gradient(WOR,diasTotales); % Calculo de la derivada
PetroleoAcumulado=BarrilesPetroleo.*diasTranscurridos;
f = fit(diasTotales,BarrilesPetroleo,'exp1'); % Ajuste exponencial
f_WOR=fit(diasTotales,WOR,'poly2'); % Ajuste polinomial
f_WOR_derivada=fit(diasTotales,derivada_WOR,'poly2'); % Ajuste polinomial

fig=figure('NumberTitle','off','Name','Curvas CHAN','WindowState','maximized');
subplot(1,2,1)
plot(f,diasTotales,BarrilesPetroleo,'o')
axis padded
xlabel('Días')
ylabel('Producción de Petróleo (barriles/día)')
legend('Datos de Producción','Ajuste Exponencial')
title('Declinación de Producción de Petróleo')

subplot(1,2,2)
hold on
plot(diasTotales,WOR,'o')
plot(f_WOR,'m')
plot(diasTotales,derivada_WOR,'o')
plot(f_WOR_derivada,'c')
axis padded
xlabel('Días')
ylabel('WOR / Derivada del WOR')
set(gca, 'YScale', 'log')
set(gca, 'XScale', 'log')
legend('Datos WOR','Ajuste WOR','Derivada WOR','Ajuste Derivada')
title('Relación Agua-Petróleo (WOR) y su Derivada')

exportgraphics(fig,'CHAN-RAP.png')

% Salida de datos
T=table(fechaInicio,diasTranscurridos,diasTotales,BarrilesPetroleo,BarrilesAgua,WOR,PetroleoAcumulado);
writetable(T,[direction,'fechas_output_matlab.csv']);
toc