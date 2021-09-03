%% Getting User Inputs

prompt = 'Select amblyotic eye : L/R/B ';
tested_eye = lower(input(prompt, 's'));
name = input('Name of participant : ', 's');
participant = input('Ambly/Control : ', 's');

while tested_eye ~= 'r' && tested_eye ~= 'l' && tested_eye ~= 'b'
    tested_eye = lower(input(prompt, 's'));
end

setGlobalx;

%% Get images
folder = '\images';
F = dir(folder);
categories = [];

for k = 3:numel(F)
    subF = fullfile(F(k).folder, '\', F(k).name);
    p = struct2table(dir(fullfile(subF, '*png')));
    categories = [categories, p(:, 1)];
    categories.Properties.VariableNames(k-2) = {F(k).name};
end

%% Setting Screen

screenSize = get(0,'screensize');
screenWidth = screenSize(3);
screenHeight = screenSize(4);

hFig = figure('Name','Screen',...
    'Numbertitle','off',...
    'Position', [0 0 screenWidth screenHeight],...
    'WindowStyle','modal',...
    'Color',[0.5 0.5 0.5],...
    'Toolbar','none');
img = imread('\images\animals\dog.png');
fpos = get(hFig,'Position')
axOffset = (fpos(3:4)-[size(img,2) size(img,1)])/2;
ha = axes('Parent',hFig,'Units','pixels',...
            'Position',[axOffset size(img,2) size(img,1)]);
        
%% Function Call
% Sequence number of blocks
blocks_seq = 10:10:90;

plotIndex = 1;
idx = 1;

prompt = "What did you see? Press 2 for animal, 4 for nature, 6 for object, 8 for human or 0 for city";

for block = blocks_seq
    x = 0;
    while x < 20
        [I, fol] = getimage(categories);
        cell_array = preprocess(I);
        proc_image = pro_disp(cell_array, block, tested_eye);
       
        hImshow = imshow(proc_image,'Parent',ha);
        
        pause(60);
        
        cat = cell2mat(mvdlg(prompt, 'Screen', [0 0 1 1], hFig));
        
        while cat(1) ~= '2' && cat(1) ~= '4' && cat(1) ~= '6' && cat(1) ~= '8' && cat(1) ~= '0'
            cat = cell2mat(mvdlg(prompt, 'Screen', [0 0 1 1]));
        end
        
        keyboard(cat, idx, fol);
        x = x + 1;
        idx = idx + 1;
        temp = getGlobalx;
    end
end

final = getGlobalx;
close;
functionPlot(final, name, participant);

%% Setting up variables
% categories = struct('animal', 2, 'landscape', 4, 'object', 6, 'human', 8); 
function setGlobalx()
    global answer;
    answer = zeros(20, 9);
end

function r = getGlobalx()
    global answer;
    r = answer;
end

%% Get random image
function [image, fol] = getimage(categories)
   col = randi([1 5], 1);
   row = randi([1 10], 1);
   
   map = containers.Map([1 2 3 4 5], {'animals', 'city', 'human', 'nature', 'objects'});
   fol = map(col);
   
   image = categories{row, col};
   image = strcat('images/', fol, '/', string(image)); 
end

%% Preprocess image

function cell_array = preprocess(I)
    % read image
    I = imread(strcat('\dichoptic-expt\', I));

    % make grayscale version of image
    I = im2gray(I);

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
function keyboard(cat, idx, fol)
    global answer;
    
    cont = containers.Map({'2', '4', '6', '8', '0'}, {'animals', 'nature', 'object', 'human', 'city'});
    
    if strcmp(cont(cat), fol)
        answer(idx) = 1;
    else
        answer(idx) = 0;
    end
    
end

%% Process Image
function RD_img = pro_disp(ca, n_blocks, eye)
    % Remove empty rows and columns at edges
    ca(11,:) = [];
    ca(:, 11) = [];
    
    % Random indices
    indices = randperm(numel(ca), n_blocks);
    
    % Apply filter 
    for i = indices
        block = ca{i};
        
        if eye == 'l'
            % Red filter [R 0 0]
            ca{i} = cat(3, block, zeros(size(block)), zeros(size(block)));
        elseif eye == 'r'
            % Green filter [0 G 0]
            ca{i} = cat(3, zeros(size(block)), block, zeros(size(block)));
        elseif eye == 'b'
            ca{i} = zeros(32, 32, 'uint8');
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
                elseif eye == 'r'
                    ca{r,c} = cat(3, rgbBlock, zeros(size(rgbBlock)), zeros(size(rgbBlock)));
                end
            end
        end
    end
    
    % Convert cell back to matrix & display image
    RD_img = cell2mat(ca);
end

