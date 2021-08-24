function plotfct(data, name, participant)
    col_means = mean(data)*100;
    x = 10:10:90;
    plot(x, col_means)
    
    folder = 'C:\Users\caoso\OneDrive\Desktop\dichoptic-expt\participant-data\';
    save(strcat(folder, name, participant), 'data');
end