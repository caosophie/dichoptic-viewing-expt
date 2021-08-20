function Answer = mvdlg(prompt,title,position, fig)
%MVDLG moveable input dialog box.

%% set up main window figure
dialogWind = figure('Units','normalized','Position', ...
    position,'MenuBar','none','NumberTitle','off','Name',title);

%% set up GUI controls and text
uicontrol('style','text','String',prompt,'Units','normalized', ...
    'Position',[.2,.25,.6,.3],'HorizontalAlignment','left', 'FontSize', 30);

% uicontrol('style','text','String',prompt,'Units','normalized', ...
%    'Position',[.2,.5,.6,.3],'HorizontalAlignment','center', 'FontSize', 30);

% hedit = uicontrol('style','edit','Units','normalized','Position', ...
%     [.2,.4,.6,.2],'HorizontalAlignment','center', 'FontSize', 40);
% 
% okayButton = uicontrol('style','pushbutton','Units','normalized',...
%     'position', [.2,.1,.2,.1],'string','OK','callback',@okCallback, 'FontSize', 20);
% cancelButton = uicontrol('style','pushbutton','Units','normalized',...
%     'position', [.6,.1,.2,.1],'string','Cancel','callback',@cancCallback, 'FontSize', 20);

%% initialize ANSWER to empty cell array
Answer = {};

%% wait for user input, and close once a button is pressed 
% uiwait(dialogWind);
pause;
pushbutton1_KeyPressFcn()

function pushbutton1_KeyPressFcn()
    key = get(gcf,'CurrentKey');
    
    if (strcmp (key , 'escape'))
        close(dialogWind);
        close(fig);
        return;
    else
        Answer = {key};
        close(dialogWind);
    end
end

%% callbacks for 'OK' and 'Cancel' button    
% function okCallback(hObject,eventdata)
%     Answer = cell(get(hedit,{'String'}));
%     uiresume(dialogWind);
%     close(dialogWind);
% end
% 
% function cancCallback(hObject,eventdata)
%     uiresume(dialogWind);
%     close(dialogWind);
%     close(fig);
% end
end
