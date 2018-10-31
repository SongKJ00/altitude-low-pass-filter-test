clear all;
clc;

% Figure
figure;
hold on;

% Open Serial Port
delete(instrfindall)
ser = serial('COM10', 'Baudrate', 9600);
fopen(ser);

% Initialize Variables
x = 1:1000;
idx = 1;
firstRun = 0;
altLPF = zeros(2, 1);
dataList = nan(3, 1000);
alpha = [0.6 0.85]';
alphaStr1 = sprintf('alpha : %.2f', alpha(1));
alphaStr2 = sprintf('alpha : %.2f', alpha(2));

% Initialize Graphs
graph = struct('g1', line(x, dataList(1, :), 'Color', 'g'), 'g2', line(x, dataList(2, :), 'Color', 'r'), 'g3', line(x, dataList(3, :), 'Color', 'b'));
xlim([0 1000]);
legend('Raw Data', alphaStr1, alphaStr2);
title('Low Pass Filter Test');
xlabel('Time (10ms)');
ylabel('Altitude (m)');

while(1)
    % Parse data from serial port
    data = fscanf(ser);
    dataLen = size(data, 2);
    alt = str2double(data(1:dataLen-2));
    
    % Check if it is available data
    if( dataLen ~= 9)
        continue;
    end

    fprintf('%.2f\n', alt);
    
    % Set altitude data for LPF only once
    if firstRun == 0
        altLPF(:) = alt;
        firstRun = 1;
    end
    
    % Set data after low pass filter
    altLPF(1) = LPF(alpha(1), altLPF(1), alt);
    altLPF(2) = LPF(alpha(2), altLPF(2), alt);
    
    % Set data for drawing graph
    dataList(1, idx) = alt;
    dataList(2, idx) = altLPF(1);
    dataList(3, idx) = altLPF(2);
    
    idx = idx + 1;
    if idx > length(x)
        idx = 1;
    end

    % Draw Graph
    set(graph.g1, 'ydata', dataList(1, :));
    set(graph.g2, 'ydata', dataList(2, :));
    set(graph.g3, 'ydata', dataList(3, :));
    
    pause(0.001);
end
