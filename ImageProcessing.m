%% Getting User Inputs

prompt = 'Select amblyotic eye : L/R ';
tested_eye = lower(input(prompt, 's'));

while tested_eye ~= 'r' && tested_eye ~= 'l'
    tested_eye = lower(input(prompt, 's'));
end

setGlobalx;

%% Get images
folder = 'C:\Users\caoso\OneDrive\Desktop\dichoptic-expt\images';
F = dir(folder);
categories = [];

for k = 3:numel(F)
    subF = fullfile(F(k).folder, '\', F(k).name);
    p = struct2table(dir(fullfile(subF, '*png')));
    categories = [categories, p(:, 1)];
    categories.Properties.VariableNames(k-2) = {F(k).name};
end

%% Function Call
% Sequence number of blocks
blocks_seq = 10:10:90;

plotIndex = 1;
idx = 1;

for block = blocks_seq
    x = 0;
    while x < 10
        I = getimage(categories);
        cell_array = preprocess(I);
        proc_image = pro_disp(cell_array, block, tested_eye);
        % subplot(9, 10, plotIndex);
        
        imshow(proc_image);
        set(gcf, 'Position', get(0, 'Screensize'));
        
        % cat = input('What did you see?', 's');
        cat = cell2mat(inputdlg('What did you see? Press 2 for animal, 4 for nature, 6 for object, 8 for human or 0 for city', 'Input', [1 50]));
        
        while cat(1) ~= '2' && cat(1) ~= '4' && cat(1) ~= '6' && cat(1) ~= '8' && cat(1) ~= '0'
            cat = cell2mat(inputdlg('Enter a valid number', 'Input', [1 50]));
            % cat = input('Enter a valid number. Press 2 for animal, 4 for nature, 6 for object, 8 for human or 0 for city', 's');
        end
        
        keyboard(cat, idx);
        % plotIndex = plotIndex + 1;
        x = x + 1;
        idx = idx + 1;
        temp = getGlobalx;
    end
end

final = getGlobalx;

%% Setting up variables
% categories = struct('animal', 2, 'landscape', 4, 'object', 6, 'human', 8); 
function setGlobalx()
    global answer;
    answer = strings(10, 9);
end

function r = getGlobalx()
    global answer;
    r = answer;
end

%% Get random image
function image = getimage(categories)
   col = randi([1 4], 1);
   row = randi([1 2], 1);
   
   if col == 1
       fol = 'animals';
   elseif col == 2
       fol = 'city';
   elseif col == 3
       fol = 'human';
   elseif col == 4
       fol = 'nature';
   elseif col == 5
       fol = 'objects';
   end
   
   image = categories{row, col};
   image = strcat('images/', fol, '/', string(image)); 
end

%% Preprocess image

function cell_array = preprocess(I)
    % read image
    I = imread(I);

    % make grayscale version of image
    I = rgb2gray(I);

    I = imresize(I, [320, 320]);

    % Get the dimensions of monochrome image
    [rows, columns] = size(I);

    % Size of each block 32x32
    [blockSizeR, blockSizeC] = deal(32); 

    wholeBlockRows = floor(rows / blockSizeR);
    blockVectorR = [blockSizeR * ones(1, wholeBlockRows), rem(rows, blockSizeR)];

    wholeBlockCols = floor(columns / blockSizeC);
    blockVectorC = [blockSizeC * ones(1, wholeBlockCols), rem(columns, blockSizeC)];

    % Create the cell array, ca.  
    cell_array = mat2cell(I, blockVectorR, blockVectorC);
end

%% Keyboard answer inputs
function keyboard(cat, idx)
    global answer;
    if cat == '2'
        answer(idx) = 'animal';
    elseif cat == '4'
        answer(idx) = 'nature';
    elseif cat == '6'
        answer(idx) = 'object';
    elseif cat == '8'
        answer(idx) = 'human';
    elseif cat == '0'
        answer(idx) = 'city';
    end
end

%% Process Image
function RD_img = pro_disp(ca, n_blocks, eye)
    % Remove empty rows and columns at edges
    ca(11,:) = [];
    ca(:, 11) = [];
    
    % Random indices
    indices = randperm(numel(ca), n_blocks);
    
    % Apply filter [R 0 0]
    for i = indices
        block = ca{i};
        
        if eye == 'l'
            % Red filter [R 0 0]
            ca{i} = cat(3, block, zeros(size(block)), zeros(size(block)));
        elseif eye == 'r'
            % Green filter [0 G 0]
            ca{i} = cat(3, zeros(size(block)), block, zeros(size(block)));
        end
    end
    
    numPlotsR = size(ca, 1);
    numPlotsC = size(ca, 2);
    
    for r = 1 : numPlotsR
        for c = 1 : numPlotsC
            % Get block
            rgbBlock = ca{r,c};
            
            % Get size
            col = size(size(rgbBlock), 2);
            
            % If not red, apply green filter
            if col < 3
                if eye == 'l'
                % Green filter
                    ca{r,c} = cat(3, zeros(size(rgbBlock)), rgbBlock, zeros(size(rgbBlock)));
                else
                    ca{r,c} = cat(3, rgbBlock, zeros(size(rgbBlock)), zeros(size(rgbBlock)));
                end
            end
        end
    end
    
    % Convert cell back to matrix & display image
    RD_img = cell2mat(ca);
end

