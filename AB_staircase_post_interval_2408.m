% 相比于6月的版本，466和483行有变动
function [] = AB_staircase_post_interval_2408()
clearvars; close all; clc;
%% Get sub&Exp information
expinfo   = [];
dlgprompt = {'Subject ID:',...
    'Age:'...
    'Reversal:'...
    'Count_rev:'...
    'Target color:'...
    'Quitcase:'};
dlgname       = 'Sub&Exp Information';
numlines      = 1;
defaultanswer = {'S20','0','5','3','0','20'};
ans1          = inputdlg(dlgprompt,dlgname,numlines,defaultanswer);
expinfo.id        = ans1{1};
expinfo.age       = str2num(ans1{2});
expinfo.reversal  = str2num(ans1{3});
expinfo.countrev  = str2num(ans1{4});
expinfo.tarcolr   = [0 str2num(ans1{5}) 0];
expinfo.outtrials = str2num(ans1{6});


expinfo.stdura    = 6;%6 frames = 100ms when the fresh rate is 60 Hz
expinfo.stimdura  = 2;
expinfo.visangle  = 1.5;
expinfo.backcolr  = [0;0;0];
expinfo.instcolr  = [105;105;105];
expinfo.seqlength = 9;
expinfo.stepsize  = 1;
expinfo.steprange = [3 10];
expinfo.withnblk  = 60 * 1;

sexStrList    = {'Female','Male'};
handStrList   = {'Right','Left'};
[sexidx,v]    = listdlg('PromptString','Gender:','SelectionMode','Single','ListString',sexStrList);
expinfo.sex   = sexStrList{sexidx};
if ~v; expinfo.sex  = 'NA'; end
[handidx,v]   = listdlg('PromptString','Handedness:','SelectionMode','Single','ListString',handStrList);
expinfo.hand  = handStrList{handidx};
if ~v; expinfo.hand = 'NA'; end

% Key assignment
KbName('UnifyKeyNames');
spaceKey   = KbName('space');
enterKey   = KbName('return');
quitKey    = KbName('escape');
respKey1   = KbName('7');
respKey2   = KbName('8');
respKey3   = KbName('9');
respKey4   = KbName('4');
respKey5   = KbName('5');
respKey6   = KbName('6');
respKey7   = KbName('1');
respKey8   = KbName('2');
respKey9   = KbName('3');
respKeys   = [respKey1, respKey2, respKey3, respKey4, respKey5, respKey6, respKey7, respKey8, respKey9];
while KbCheck; end
ListenChar(2);

% Set the folder and filename for data save
destdir = './interval/posttest/';
if ~exist(destdir,'dir'), mkdir(destdir); end
expinfo.path2save = strcat(destdir,expinfo.id,'post_',mfilename,'_',datestr(now,30));

data         = [];
data.expinfo = expinfo;
save(expinfo.path2save,'data');

% set other parameters
viewDistance = 600; % viewing distance (mm)
whichScreen  = 0; % screen index for use
winRect      = []; % initial window size, empty indicates a whole screen window
pixelDepth   = 32;
numBuffer    = 2;
stereoMode   = 0;
multiSample  = 0;
imagingMode  = [];
%% Standard coding practice, use try/catch to allow cleanup on error.
try
    % This script calls Psychtoolbox commands available only in
    % OpenGL-based versions of Psychtoolbox. The Psychtoolbox command
    % AssertPsychOpenGL will issue an error message if someone tries to
    % execute this script on a computer without an OpenGL Psychtoolbox.
    AssertOpenGL;
    
    % Screen is able to do a lot of configuration and performance checks on
    % open, and will print out a fair amount of detailed information when
    % it does. These commands supress that checking behavior and just let
    % the program go straight into action. See ScreenTest for an example of
    % how to do detailed checking.
    oldVisualDebugLevel    = Screen('Preference','VisualDebugLevel',3);
    oldSuppressAllWarnings = Screen('Preference','SuppressAllWarnings',1);
    
    % Open a screen window and get window information.
    [winPtr, winRect] = Screen('OpenWindow',whichScreen,expinfo.backcolr,winRect,pixelDepth,numBuffer,stereoMode,multiSample,imagingMode);
    Screen('BlendFunction',winPtr,GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
    Screen('TextSize',winPtr,35);
    Screen('TextFont',winPtr,'Kaiti');
    [x0,y0] = RectCenter(winRect);
    ifi = Screen('GetFlipInterval',winPtr);
    [width_mm, height_mm] = Screen('DisplaySize', whichScreen);
    screenSize    = [width_mm, height_mm];
    winResolution = [winRect(3)-winRect(1),winRect(4)-winRect(2)];
    ppd = viewDistance*tan(pi/180)*winResolution./screenSize;
    ppd = round(ppd);
    stimsize = ppd(1)*expinfo.visangle;
    ovalsize = ppd(1)*expinfo.visangle*1.5;
    
    
    % Hide mouse curser and set the priority level
    HideCursor;
    priorityLevel = MaxPriority(winPtr);
    Priority(priorityLevel);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % TASK SESSION
    % TASK SESSION
    lettlist  = 'ABCDFGHJKMNPQRSTUVWXYZ';
    T1loc     = [5 6 7];
    T1realloc = 4;
    T2realloc = 3;
    textstr2  = ['请在呈现序列中找到两个绿色字母，\n'...
        '序列结束后立刻回答并按回车键确认，\n'...
        '如果不小心输错请按空格键清空答案。\n'...
        '明白要求后请按空格键开始任务。'];
    textstr3  = ['每组开始会呈现一条线段\n'...
        '提示你本次任务两个目标的时间间隔。\n'...
        '线段呈现结束后会出现“+”字注视点\n'...
        '“+”字注视点消失后呈现刺激序列。'];
    textstr4  = '请按顺序输入两个绿色字母:';
    
    for n = 1:length(lettlist)
        Lett{n}   = imread(['.\stim\' lettlist(n) '.png'],'png');
        for i     = 1:size(Lett{n},1)
            for j = 1:size(Lett{n},2)
                if Lett{n}(i,j,1:3) ~= expinfo.backcolr
                    Lett{n}(i,j,1:3) = expinfo.instcolr;
                end
            end
        end
    end
    
    % prepare for the fix figure
    Crossfix = imread(['.\stim\' num2str(1) '.png'],'png');
    for i = 1:size(Crossfix,1)
        for j = 1:size(Crossfix,2)
            if Crossfix(i,j,1:3) ~= expinfo.backcolr
                Crossfix(i,j,1:3) = expinfo.instcolr;
            end
        end
    end
    textCrossfix = Screen('MakeTexture',winPtr,Crossfix);
    % No cue condition  * fix
    fix = imread(['.\stim\' num2str(4) '.png'],'png');
    for i = 1:size(fix,1)
        for j = 1:size(fix,2)
            if fix(i,j,1:3) ~= expinfo.backcolr
                fix(i,j,1:3) = expinfo.instcolr;
            end
        end
    end
    textfix = Screen('MakeTexture',winPtr,fix);
    
    [~,~,alpha] = imread('.\stim\Oval.png','png');
    oval        = MaskImageIn(alpha);
    for i = 1:size(oval,1)
        for j = 1:size(oval,2)
            if oval(i,j,1:3) ~= expinfo.backcolr
                oval(i,j,1:3) = expinfo.instcolr;
            end
        end
    end
    textoval  = Screen('MakeTexture',winPtr,oval);
    %% start pretest
    flag = 0;
    rng('Shuffle');
    data.seq  = Shuffle([1 2 3]) ; % 1 = valid ; 2 = unvalid ; 3 = No cue
    count_of_n_of_reversals = zeros(2,3);
    expthresholds = cell(2,3);%拐点的数量
    trl           = ones(2,3);
    n_threshold   = ones(2,3);
    n_down        = zeros(2,3);
    pos           = zeros(2,3);
    neg           = zeros(2,3);
    rowofoutput   = cell(2,3);
    trldouble     = [];
    
    blk = 1;
    while blk <= length(data.seq)
        % present the instruction
        textstr1    = ['正式测试第' num2str(blk) '组:'];
        BoundsRect1 = Screen('TextBounds',winPtr,double(textstr1));
        DrawFormattedText(winPtr,double(textstr1),x0-400-(BoundsRect1(3)-BoundsRect1(1))/2,y0-300-(BoundsRect1(4)-BoundsRect1(2))/2,expinfo.instcolr);
        BoundsRect2 = RectOfMatrix(double(textstr2));
        DrawFormattedText(winPtr,double(textstr2),x0-350-(BoundsRect2(3)-BoundsRect2(1))/2,y0-200-(BoundsRect2(4)-BoundsRect2(2))/2,expinfo.instcolr,[],[],[],2);
        if data.seq(blk)~= 3
            BoundsRect3 = RectOfMatrix(double(textstr3));
            %           DrawFormattedText(winPtr,double(textstr3),x0-500-(BoundsRect3(3)-BoundsRect3(1))/2,y0+200-(BoundsRect3(4)-BoundsRect3(2))/2,expinfo.instcolr,[],[],[],2);
            DrawFormattedText(winPtr,double(textstr3),x0-350-(BoundsRect3(3)-BoundsRect3(1))/2,y0+200-(BoundsRect3(4)-BoundsRect3(2))/2,expinfo.instcolr,[],[],[],2);
        end
        Screen('Flip',winPtr)
        while 1
            [keydown, ~, keycode] = KbCheck;
            if keydown
                while KbCheck; end
                if keycode(spaceKey)|| keycode(quitKey); break; end
            end
        end
        Screen('FillRect',winPtr,expinfo.backcolr);
        Screen('Flip',winPtr);
        if keycode(quitKey); break; end
        
        % set staircase parameters
        StimulusLevel(1)  = expinfo.steprange(1);
        StimulusLevel(2)  = expinfo.steprange(2);
        
        % start each trial
        trlT          = 0;
        while count_of_n_of_reversals(1,blk) < expinfo.reversal || count_of_n_of_reversals(2,blk) < expinfo.reversal
            lettlist_perm  = Shuffle(lettlist);
            lettlist_perm  = lettlist_perm(1:expinfo.seqlength);
            
            if count_of_n_of_reversals(1,blk) < expinfo.reversal && count_of_n_of_reversals(2,blk) < expinfo.reversal
                trldouble(blk) = randi(2);
            elseif count_of_n_of_reversals(1,blk) >= expinfo.reversal
                trldouble(blk) = 2;
            elseif count_of_n_of_reversals(2,blk) >= expinfo.reversal
                trldouble(blk) = 1;
            end
            
            numstim  = expinfo.stimdura;%frame of stim
            numISI   = expinfo.stdura-numstim;
            T1pos    = T1loc(randperm(length(T1loc),1));
            T2pos    = StimulusLevel(trldouble(blk));
            T1lett   = Lett{ismember(lettlist,lettlist_perm(T1realloc))};
            T2lett   = Lett{ismember(lettlist,lettlist_perm(T1realloc+T2realloc))};
            
            for i = 1:size(T1lett,1)
                for j = 1:size(T1lett,2)
                    if T1lett(i,j,1:3) ~= expinfo.backcolr
                        T1lett(i,j,1:3) = expinfo.tarcolr;
                    end
                end
            end
            for i = 1:size(T2lett,1)
                for j = 1:size(T2lett,2)
                    if T2lett(i,j,1:3) ~= expinfo.backcolr
                        T2lett(i,j,1:3) = expinfo.tarcolr;
                    end
                end
            end
            textt1 = Screen('MakeTexture',winPtr,T1lett);
            textt2 = Screen('MakeTexture',winPtr,T2lett);
            
            ISIframe = length(lettlist_perm);
            ISIseq   = repmat(numISI,1,ISIframe);
            ISIseq(T1realloc-1)  = expinfo.stdura*(T1pos-T1realloc)+ numISI;%the position of T1
            ISIseq(T1realloc+T2realloc-1)  = expinfo.stdura*(T2pos-T2realloc)+ numISI;%the position of T2
            
            %% cue          
            switch data.seq(blk)
                case 1 % 线索有效
                    lineLength = StimulusLevel(trldouble(blk));
                case 2
                    lineLength = randi([3,10]);
                case 3
                    Screen('DrawTexture',winPtr,textfix,[],[x0-stimsize/2,y0-stimsize/2,x0+stimsize/2,y0+stimsize/2]);
                    Screen('Flip', winPtr);
                    WaitSecs(2);
            end
            if data.seq(blk) ~= 3
                lineWidth = 7;
                singleLineLength = 1 * ppd(1); % single Segment length
                gapLength = 0.2 * ppd(1); % Segment interval length
                totalLengthWithGaps = (singleLineLength * lineLength) + (lineLength - 1) * gapLength;
                for i = 1:lineLength
                    startX = x0 - (totalLengthWithGaps / 2) + ((i - 1) * (singleLineLength + gapLength));
                    endX = startX + singleLineLength;
                    Screen('DrawLine', winPtr, [105,105,105], startX, y0, endX, y0, lineWidth);
                end
                Screen('Flip', winPtr);
                WaitSecs(2);
            end
            Screen('DrawTexture',winPtr,textCrossfix,[],[x0-stimsize/2,y0-stimsize/2,x0+stimsize/2,y0+stimsize/2]);
            Screen('Flip', winPtr);
            WaitSecs(0.8);
            
            
            
            time1 = GetSecs;  tpoint = []; ISI = [];
            for stim = 1:length(lettlist_perm)
                isi1 = GetSecs;
                for num = 1:ISIseq(stim)
                    Screen('FillRect',winPtr,expinfo.backcolr);
                    Screen('DrawTexture',winPtr,textoval,[],[x0-ovalsize/2,y0-ovalsize/2,x0+ovalsize/2,y0+ovalsize/2]);
                    Screen('Flip',winPtr);% Screen time of background
                end
                isi2 = GetSecs; ISI = [ISI isi2-isi1]; isi1 = isi2;
                textlett = Screen('MakeTexture',winPtr,Lett{ismember(lettlist,lettlist_perm(stim))});
                Screen('DrawTexture',winPtr,textlett,[],[x0-stimsize/2,y0-stimsize/2,x0+stimsize/2,y0+stimsize/2]);
                if stim == T1realloc
                    Screen('DrawTexture',winPtr,textt1,[],[x0-stimsize/2,y0-stimsize/2,x0+stimsize/2,y0+stimsize/2]);
                    time2 = GetSecs; tpoint = [tpoint time2-time1];
                elseif stim == T1realloc+T2realloc
                    Screen('DrawTexture',winPtr,textt2,[],[x0-stimsize/2,y0-stimsize/2,x0+stimsize/2,y0+stimsize/2]);
                    time2 = GetSecs; tpoint = [tpoint time2-time1];
                end
                Screen('DrawTexture',winPtr,textoval,[],[x0-ovalsize/2,y0-ovalsize/2,x0+ovalsize/2,y0+ovalsize/2]);
                for num = 1:numstim-1
                    Screen('Flip',winPtr,0,1);%前面几帧呈现完不消失
                end
                Screen('Flip',winPtr);%最后一帧呈现完消失
            end
            time3 = GetSecs;
            
            % wait for a response
            resp = []; resptime = []; xlocation = []; ylocation = []; resphistory = []; textshown = [];
            BoundsRect4   = Screen('TextBounds',winPtr,double(textstr4));
            DrawFormattedText(winPtr,double(textstr4),x0-(BoundsRect4(3)-BoundsRect4(1))/2,y0-200-(BoundsRect4(4)-BoundsRect4(2))/2,expinfo.instcolr);
            
            shownstim = Shuffle(lettlist_perm);
            for num = 1:9
                textlett = Screen('MakeTexture',winPtr,Lett{ismember(lettlist,shownstim(num))});
                if num <= 3
                    Screen('DrawTexture',winPtr,textlett,[],[x0+(num-2)*100-stimsize/2,y0-100-stimsize/2,x0+(num-2)*100+stimsize/2,y0-100+stimsize/2]);
                elseif num <= 6
                    Screen('DrawTexture',winPtr,textlett,[],[x0+(num-5)*100-stimsize/2,y0-stimsize/2,x0+(num-5)*100+stimsize/2,y0+stimsize/2]);
                elseif num <= 9
                    Screen('DrawTexture',winPtr,textlett,[],[x0+(num-8)*100-stimsize/2,y0+100-stimsize/2,x0+(num-8)*100+stimsize/2,y0+100+stimsize/2]);
                end
            end
            Screen('Flip',winPtr);
            bodyimage = Screen('GetImage',winPtr,[]);
            texbody   = Screen('MakeTexture',winPtr,bodyimage);
            
            while 1
                [keydown, secs, keycode] = KbCheck;
                if keydown && numel(find(keycode)) == 1
                    while KbCheck; end
                    if numel(find(find(keycode) == respKeys)) == 1
                        target      = find(find(keycode) == respKeys);
                        resp        = [resp shownstim(target)];
                        resptime    = [resptime secs-time3];
                        resphistory = [resphistory shownstim(target)];
                        if (0 < target)&&(target < 4)
                            xlocation = [xlocation x0+(target-2)*100];
                            ylocation = [ylocation y0-100];
                        elseif (3 < target)&&(target < 7)
                            xlocation = [xlocation x0+(target-5)*100];
                            ylocation = [ylocation y0];
                        elseif (6 < target)&&(target < 10)
                            xlocation = [xlocation x0+(target-8)*100];
                            ylocation = [ylocation y0+100];
                        end
                        shownlett = Lett{ismember(lettlist,shownstim(target))};
                        for i = 1:size(shownlett,1)
                            for j = 1:size(shownlett,2)
                                if shownlett(i,j,:) ~= expinfo.backcolr
                                    shownlett(i,j,:) = expinfo.tarcolr;
                                end
                            end
                        end
                        textshown = [textshown Screen('MakeTexture',winPtr,shownlett)];
                    elseif keycode(spaceKey)
                        xlocation = []; ylocation = []; resp = []; textshown =[];
                    end
                    
                    respmax = 2;
                    if length(resp) > respmax %超过最大值无法继续输入
                        resptime  = resptime(1:end+respmax-length(resp)); resphistory = resphistory(1:end+respmax-length(resp));
                        xlocation = xlocation(1:respmax); ylocation = ylocation(1:respmax); resp = resp(1:respmax); textshown = textshown(1:2);
                    elseif length(resp) == respmax && respmax == 2 %同一个字母输入两次只算一次
                        if resp(1) == resp(2)
                            resp      = resp(1); textshown = textshown(1);
                            xlocation = xlocation(1);
                            ylocation = ylocation(1);
                        end
                    end
                    
                    Screen('PreloadTextures',winPtr,texbody);
                    Screen('DrawTexture',winPtr,texbody);
                    for r = 1:length(resp)
                        Screen('DrawTexture',winPtr,textshown(r),[],[xlocation(r)-stimsize/2,ylocation(r)-stimsize/2,xlocation(r)+stimsize/2,ylocation(r)+stimsize/2]);
                    end
                    Screen('Flip',winPtr);
                    if (keycode(enterKey)&&length(resp) == respmax)||(keycode(quitKey)); break; end
                end
            end
            if keycode(quitKey);break; end
            
            if resp(1)-lettlist_perm(T1realloc) == 0 %判断T1回答
                if resp(2) - lettlist_perm(T1realloc+T2realloc) == 0 %判断T2回答
                    acc = 1;
                else
                    acc = 0;
                end
            else
                acc = -1;
            end
            
            for i = 1:2
                if trldouble(blk) == i
                    rowofoutput{i,blk}(trl(i,blk), 1) = trl(i,blk);
                    rowofoutput{i,blk}(trl(i,blk), 2) = StimulusLevel(trldouble(blk));
                    rowofoutput{i,blk}(trl(i,blk), 3) = acc;
                    if acc == 1
                        n_down(i,blk) = n_down(i,blk)+1;
                        if n_down(i,blk) == 4
                            n_down(i,blk) = 0;
                            pos(i,blk)    = 1;
                            trend(i,blk)  = 1;
                            if StimulusLevel(trldouble(blk)) > expinfo.steprange(1)  %T2在300到1000毫秒之间变化
                                StimulusLevel(trldouble(blk)) = StimulusLevel(trldouble(blk)) - expinfo.stepsize;
                            end
                            if pos(i,blk) == 1 && neg(i,blk) == -1 %出现拐点
                                count_of_n_of_reversals(i,blk)    = count_of_n_of_reversals(i,blk) + 1;
                                expthresholds{i,blk}(n_threshold(i,blk)) = (StimulusLevel(trldouble(blk)) + rowofoutput{i,blk}(trl(i,blk), 2))/2;
                                n_threshold(i,blk) = n_threshold(i,blk)+1;
                                pos(i,blk) = trend(i,blk);
                                neg(i,blk) = trend(i,blk) ;
                            end
                        end
                    elseif acc == 0
                        neg(i,blk)    = -1;
                        trend(i,blk)  = -1;
                        n_down(i,blk) = 0;
                        if StimulusLevel(trldouble(blk)) < expinfo.steprange(2)
                            StimulusLevel(trldouble(blk)) = StimulusLevel(trldouble(blk)) + expinfo.stepsize;
                        end
                        if pos(i,blk) == 1 && neg(i,blk)== -1
                            count_of_n_of_reversals(i,blk)  = count_of_n_of_reversals(i,blk)  + 1;
                            expthresholds{i,blk}(n_threshold(i,blk)) = (StimulusLevel(trldouble(blk)) + rowofoutput{i,blk}(trl(i,blk), 2))/2;
                            n_threshold(i,blk)  = n_threshold(i,blk) +1;
                            pos(i,blk)  = trend(i,blk) ;
                            neg(i,blk)  = trend(i,blk) ;
                        end
                    end
                    rowofoutput{i,blk}(trl(i,blk), 4)  = count_of_n_of_reversals(i,blk);
                    
                    % save all the results after each trl  !!!
                    data.double{i,blk}(trl(i,blk),:)      = trldouble(blk); % !!!数据保存
                    data.lettseq{i,blk}{trl(i,blk),:}     = lettlist_perm;
                    data.lett{i,blk}(trl(i,blk),:)        = [lettlist_perm(T1realloc) lettlist_perm(T1realloc+T2realloc)];
                    data.T1T2pos{i,blk}{trl(i,blk),:}     = [T1pos T2pos];
                    data.staircase{i,blk}(trl(i,blk),:)   = rowofoutput{i,blk}(trl(i,blk),:);
                    data.resp{i,blk}(trl(i,blk),:)        = resp;
                    data.resptime{i,blk}{trl(i,blk),:}    = resptime;
                    data.resphistory{i,blk}{trl(i,blk),:} = resphistory;
                    data.letttime{i,blk}(trl(i,blk),:)    = time3-time1;
                    data.T1T2point{i,blk}(trl(i,blk),:)   = tpoint;
                    data.ISI{i,blk}{trl(i,blk),:}         = ISI;
                    save(expinfo.path2save,'data');
                    %                     退出
                    if trl(i,blk) >= expinfo.outtrials
                        if (sum(rowofoutput{i,blk}(trl(i,blk)-expinfo.outtrials+1:trl(i,blk),2)) == expinfo.steprange(1)*expinfo.outtrials)||...%如果连续n个试次都处于最低或者最高难度则退出练习
                        (sum(rowofoutput{i,blk}(trl(i,blk)-expinfo.outtrials+1:trl(i,blk),2)) == expinfo.steprange(2)*expinfo.outtrials)
%                         if sum(rowofoutput{i,blk}(trl(i,blk)-expinfo.outtrials+1:trl(i,blk),2)) == expinfo.steprange(i)*expinfo.outtrials
                            flag = 1;
                        end
                    end
                    trl(i,blk)                            = trl(i,blk)+ 1;
                end
            end
            if flag == 1; break; end
            trlT = trlT + 1 ;
            if trlT == 30
                textstr6    = '请稍作休息,休息结束后，请按空格键自行开始';
                BoundsRect6 = Screen('TextBounds',winPtr,double(textstr6));
                Screen('FillRect',winPtr,expinfo.backcolr);
                DrawFormattedText(winPtr,double(textstr6),x0-50-(BoundsRect6(3)-BoundsRect6(1))/2,y0-(BoundsRect6(4)-BoundsRect6(2))/2,expinfo.instcolr);
                Screen('Flip',winPtr);
                while 1
                    [keydown, ~, keycode] = KbCheck;
                    if keydown
                        while KbCheck; end
                        if keycode(spaceKey)|| keycode(quitKey); break; end
                    end
                end
                trlT = 0;
            end
        end
        for i = 1:2
            data.thresholds{i,blk}(:,:)   = expthresholds{i,blk}; % !!! 数据保存问题
            data.mean_thres(i,blk)        = mean(expthresholds{i,blk}(end-expinfo.countrev+1:end));%取最后几个拐点的平均值计算阈值
            data.mean_acc(i,blk)          = length(find(data.staircase{i,blk}(:,3) == 1))/length(find(data.staircase{i,blk}(:,3) ~= -1));
            save(expinfo.path2save,'data');
        end
        
        Screen('FillRect',winPtr,expinfo.backcolr);
        vbl = Screen('Flip',winPtr);
        frames4break = floor(expinfo.withnblk);
        if blk < length(data.seq)
            for m = 1:frames4break
                showTmin1 = floor(floor((expinfo.withnblk-(m-1))/60)/10);
                showTmin2 = rem(floor((expinfo.withnblk-(m-1))/60),10);
                showTsec1 = floor(rem(expinfo.withnblk-(m-1),60)/10);
                showTsec2 = rem(rem(expinfo.withnblk-(m-1),60),10);
                %                 textstr5  = ['您的正确率是' num2str(data.mean_acc(blk)) ',请继续努力！'];
                if data.mean_acc(1,blk)>= 0.7 && data.mean_acc(2,blk)>= 0.7
                    textstr5 = ['您的表现很好，请继续努力！'];
                else
                    textstr5 = ['您本次正确率偏低，如果您感到疲惫，可以多休息一会儿，再继续实验！'];
                end
                BoundsRect5 = RectOfMatrix(double(textstr5));
                DrawFormattedText(winPtr,double(textstr5),x0-600-(BoundsRect5(3)-BoundsRect5(1))/2,y0-200-(BoundsRect5(4)-BoundsRect5(2))/2,expinfo.instcolr,[],[],[],2);
                textstr6    = '休息一会儿';
                BoundsRect6 = Screen('TextBounds',winPtr,double(textstr6));
                DrawFormattedText(winPtr,double(textstr6),150,y0-(BoundsRect6(4)-BoundsRect6(2))/2,expinfo.instcolr);
                Screen('DrawText',winPtr,[num2str(showTmin1) num2str(showTmin2) ':' num2str(showTsec1) num2str(showTsec2)],150,y0-(BoundsRect6(4)-BoundsRect6(2))/2+50,expinfo.instcolr);
                vbl = Screen('Flip',winPtr,vbl+(1/ifi-0.5)*ifi);
                [~, ~, keycode] = KbCheck;
                if keycode(quitKey); flag = 1; break; end
            end
        end
        if flag == 1; break; end
        blk = blk +1;
    end
    
    %   画图 上面一行都是从200ms开始的，下面一行都是从1000ms开始的，每个blk的图上下对应，方便看
    figure;
    plotNum1 = 1;
    plotNum2 = 4;
    for blk = 1:length(data.seq)
        % % Plot data.staircase1
        subplot(2,ceil(length(data.seq)),plotNum1)
        plot(data.staircase{1,blk}(:,2))
        m = 1;
        reversal = nan(size(data.staircase{1,blk},1),1);
        for i = 1:size(data.staircase{1,blk},1)
            re = find(data.staircase{1,blk}(:,4) == m);
            if ~isempty(re)
                reversal(re(1)) = data.staircase{1,blk}(re(1),2);
            end
            m = m+1;
            if m > data.staircase{1,blk}(end,4)
                break;
            end
        end
        hold on
        plot(reversal,'o')
        legend('stimlevel','reversal point')
        title([num2str(data.seq(blk)) ' ' num2str(data.mean_acc(1,blk)) ' ' num2str(data.mean_thres(1,blk)) ' ' '200' ])
        ylim([2 10]), yticks(2:1:10);
        plotNum1 = plotNum1 + 1;
        % Plot data.staircase2
        subplot(2,ceil(length(data.seq)),plotNum2)
        plot(data.staircase{2,blk}(:,2))
        m = 1;
        reversal = nan(size(data.staircase{2,blk},1),1);
        for i = 1:size(data.staircase{2,blk},1)
            re = find(data.staircase{2,blk}(:,4) == m);
            if ~isempty(re)
                reversal(re(1)) = data.staircase{2,blk}(re(1),2);
            end
            m = m+1;
            if m > data.staircase{2,blk}(end,4)
                break;
            end
        end
        hold on
        plot(reversal,'o')
        legend('stimlevel','reversal point')
        title([num2str(data.seq(blk)) ' ' num2str(data.mean_acc(2,blk)) ' ' num2str(data.mean_thres(2,blk)) ' ' '1000' ])
        ylim([2 10]), yticks(2:1:10);
        plotNum2 = plotNum2 + 1;
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % The end statement of the experiment
    DrawFormattedText(winPtr,double('实验结束。'),150,y0-40,expinfo.instcolr);
    DrawFormattedText(winPtr,double('非常感谢！'),150,y0+40,expinfo.instcolr);
    Screen('Flip',winPtr);
    WaitSecs(2.0);
    Screen('FillRect',winPtr,expinfo.backcolr);
    Screen('Flip',winPtr);
    Screen('CloseAll');
    ShowCursor;
    fclose('all');
    Priority(0);
    % Restore preferences
    Screen('Preference', 'VisualDebugLevel', oldVisualDebugLevel);
    Screen('Preference', 'SuppressAllWarnings', oldSuppressAllWarnings);
    ListenChar(0);
    
catch
    % Catch error.
    Screen('FillRect',winPtr,expinfo.backcolr);
    Screen('Flip',winPtr);
    Screen('CloseAll');
    ShowCursor;
    fclose('all');
    Priority(0);
    % Restore preferences
    Screen('Preference', 'VisualDebugLevel', oldVisualDebugLevel);
    Screen('Preference', 'SuppressAllWarnings', oldSuppressAllWarnings);
    ListenChar(0);
    psychrethrow(psychlasterror);
end % try ... catch %
