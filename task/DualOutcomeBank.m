function result=DualOutcomeBank(r)
% Dual outcomes task 2021 - 
%  - derived from reversal learning task 
%  - two currencies of reward, in two purses that can fill up
%  - 
ex.type               = 'Dual Outcome Banking task v1 HC';

%% SETUP 000
ex.skipScreenCheck    = 1;             
ex.displayNumber      = 0;             % for multiple monitors
% ex.practiceTrials     = 0;
ex.useMouse           = 0 ; % show the mouse cursor while touch?
ex.useLabjack = 0; 
ex.subjectNumber         = 043; 
ex.SIMULATE = false; % simulate the keypresses (random)
ex.fMRI = false;

%% STRUCTURE
ex.blockLen      = 256;            
ex.blocks             = 4;
ex.trialVariables.diceIndices   = {[1 2], [2 1]};    % which dice at location 1 and 2
ex.pauseEvery         = 257; % after how many trials shoud we break? = "end of block"

% different probabilities of the two reward types, depending on which
% stimulus was chosen. 
H = 0.85; L = 1-H; % hi and low probabilities, to initialise dice with
% how many trials back to go, when calculating recent preference:
ex.preferenceRecency   = 10; 
% What constitutes a 'preference'? at least 69% of recent choices should conform. 
ex.preferenceThreshold = 0.69; 

% Each row of the reward schedule corresponds to one state of the game.
% We move through the states in series, as governed by the 'until' criteria
ex.rewardScheduleColumns = {
  'A_red','A_green','B_red','B_green','until_full','until_prefer','until_count', 'then_bank','bank_when_full'
  };
% Rules for moving on to the next state:
% 'until_full'   =   0 do nothing when purse full
%                    1 move on when red purse full
%                    2 move on when green purse full
%                    3 move on when either purse full
% 'until_prefer' =   0 do nothing when preference changes
%                    1 move on when prefers A
%                    2 move on when prefers B
%                    3 move on when preference established for either A or B
% 'until_count'  =   0 no limit on number of trials
%                    n move on after number of trials 
% 'then_bank'    =   0 do not bank at the end of this stage
%                    1/2 bank red/green at end of stage
%                    3 bank both purses at the end of this stage
% 'bank_when_full' = 0 no action if purse ful
%                    1/2 bank red/green as soon as they are full
%                    3 bank either purse when it's full
ex.rewardSchedule = {   %        |    UNTIL:           |    BANK
  % A-red A-green  B-red B-green | FULL  PREFER  COUNT | AFTER  WHENFULL
  
  % Reversal learning phase: always bank when full. Use a deadline of 20
  % trials for learning a reversal.
  [  H       0       0      L      0     1      20       0      3  ] % press A, obtain red. 
  [  L       0       0      H      0     2      20       0      3  ] % press B, obtain green
  [  H       0       0      L      0     1      20       0      3  ] % press A, obtain red

  % Devaluation test on Red
  [  H       0       0      L      1     0       0       0      2  ] % now let red purse fill up, keep banking green. 
  [  0       0       0      0      0     0       8       0      2  ] % Extinction! 8 trials
  [  H       0       0      H      0     2      20       1      2  ] % red saturated, switch to B. Then bank red.
  [  H       0       0      H      0     0       8       0      3  ] % wait 8 trials (see if preference remains after banking Red)
  
  % that's about 160 trials = 7 minutes

  % Devaluation test on Green
  [  L       0       0      H      0     2      20       0      3  ] % press B, obtain green
  [  L       0       0      H      2     0       0       0      1  ] % now let green purse fill up, keep banking red. 
  [  0       0       0      0      0     0       8       0      1  ] % Extinction! 8 trials
  [  H       0       0      H      0     1      20       2      1  ] % green saturated, switch to A. Then bank green.
  [  H       0       0      H      0     0       8       0      3  ] % wait 8 trials (see if preference remains after banking Red)  
  
  % now switch contingencies
  [  H       0       0      L      1     0       0       0      2  ] % now let red purse fill up, keep banking green. 
  [  0       0       0      0      0     0       8       0      2  ] % Extinction! 8 trials
  [  H       0       0      H      0     2      20       0      2  ] % red saturated, switch to B
  [  0       H       H      0      0     1      20       1      2  ] % now A gives green, so switch back to A. Then bank red.
  [  0       H       H      0      0     0       8       0      3  ] % wait 8 trials
  
  % devaluation test on green with new contingencies
  [  0       H       L      0      0     2      20       0      3  ] % press A, obtain green
  [  0       H       L      0      2     0       0       0      1  ] % fill up on green
  [  0       0       0      0      0     0       8       0      1  ] % Extinction! 8 trials
  [  0       H       H      0      0     2      20       2      1  ] % wait till prefers B. then bank green.
  [  0       H       H      0      0     0       8       0      3  ] % wait 8 trials 
  
  
};

ex.purseSize = [5,5];

%% DISPLAY
ex.bgColour             = [0 0 0];         % background
ex.fgColour             = [255 255 255];   % text colour
ex.diceColour           = [128 128 0; 64 64 204]; % colour of the A and B dice
ex.betDiscSize          = [80 80];         % x/y radius of the discs for bet values (pixels)
ex.betBackground        = [128 128 128];   % colour of the bet discs
ex.chosenBetBackground  = [255,255,0];     % colour of the outline for chosen bet
ex.diceSize             = [80 80];         % size of the dice x/y square half-size
ex.chosenDiceBackground = [255,255,0];     % outline for selected die.
ex.coinXdistance        = 160;
ex.coinYdistance        = 0.1;
ex.coinSize             = 50; 
ex.coinColour           = { [255 0 0] , [0 255 0] };
%% TIMINGS
ex.foreperiod           = 0.3;             % seconds for bank screen
ex.diceRollTime         = 0.3;           % after choosing bet, before outcome
ex.feedbackTime         = 0.5;               % for outcome sound and money (sec)
ex.purseFullDuration    = 0.5;             % seconds to wait if win when purse full
ex.ITI                  = 0.25;            % seconds after trial
%% GAMBLE
ex.dice              = {'A','B'};          % labels of diaaasdfghjklpouwq12zxvcvcnmlkjhgfds=poiuyteqq rab,. abc  e
ex.keys              = [37,39];            % arrow keys L/R
                       
ex.soundFiles   = {'media_4/click.wav', ...    % 1 = click
                   'media_4/lose.wav', ...     % 2 = lose
                   'media_4/click.wav', ...    % 3 = zero
                   'media_4/win.wav', ...      % 4 = win
                   'media_4/REGISTER2.wav'};   % 5 = bank

%% MONEY
global Game
Game.bank  = 0;          % intial bank balance
Game.purse = [0,0];      % amount of each currency at start
Game.state = 1;          % start in state 1
Game.stateTime = 0;      % number of trials spent so far in current state
Game.choiceHistory = []; % track recent choices


%%%%%%%%%%%% RUN EXPERIMENT %%%%%%%%%%%%%
if ~exist('params','var') params=struct(); end;
result = RunExperiment( @doTrial, ex, params, @blockfn);
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function blockfn(scr, el, ex, tr) % remove end-of-block screens
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function tr=doTrial(scr, el, ex, tr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Called for each trial.
% scr: screen handle
% el:  eyelink handle (not required in this experiment)
% ex:  experiment parameters
% tr:  trial parameters (and returned result for this trial)

    %%% 1. Initialise Trial
    % combine trial-wise and experiment-wise parameters into a single
    % parameter structure
    pa = combineStruct(ex, tr);
    global Game
    Game.stateTime =  Game.stateTime + 1;  % keep count of how many trials in this stae
    tr.stateTime   =  Game.stateTime; 
    tr.state       =  Game.state; 
    schedule       =  pa.rewardSchedule{tr.state,1};
    tr.diceWeights =  schedule(1:4);
    tr.criteria    =  schedule(5:end);
    crit           =  array2table(schedule, 'variablenames',ex.rewardScheduleColumns);
    tr.bank = Game.bank;
    tr.purse = Game.purse;
    %%%% added 18-7-2012 - do 'End of Block' after fixed number of trials?
    [x y b]=GetMouse; oldp=[x y];            % check cursor pos
    if(mod(tr.allTrialIndex, pa.pauseEvery)==0) % have we passed the critical number of trials?
      drawTextCentred(scr,'End of block');   % pause expt
      Screen('Flip',scr.w);
      while(x==oldp(1) && y==oldp(2))        % until cursor moves (touched screen)
        [x y b]=GetMouse;
        WaitSecs(0.2);                       % poll cursor every 0.2s
      end
    end
    
    drawScene(scr,pa,tr,1);    % foreperiod: bank money
    WaitSecs(pa.foreperiod)
    
    %%%% 2. Choice of dice
    drawScene(scr,pa,tr,2);    % show choice of dice screen
    if(pa.useMouse)            % can show the mouse pointer if non-touchscreen
      ShowCursor
    end
    SetMouse(scr.centre(1),scr.centre(2));  % centre cursor on screen
    tr.chosenDice = 0;                      % start with no dice chosen
    tr=LogEvent(pa, el, tr,'startDice');    % log start time
    while ~tr.chosenDice                    % while no choice made yet,
      [z z kcode]=KbCheck;                  % check keyboard
      if kcode(27) tr.R=pa.R_ESCAPE; return; end 
      [x y b]=GetMouse;                     % check cursor
      for(i=1:length(pa.dice))            % is it on any of dice?
        % hpos is a function that calculates the x coordinate of the i'th
        % item of a set, if they are centred on the screen.
        d=norm( [x y]-(scr.centre+[hpos(scr,i,length(pa.dice)) -0.25*scr.ssz(2)]) );
        if(d<norm(pa.diceSize)) % is it within the radius?
          tr.chosenDice=i;      % select that item. (1 left/2 right)
        end
        if ex.SIMULATE
            tr.chosenDice=1+(rand>0.5);
        end
      end
      ki = find(kcode(pa.keys)); % use keyboard?
      if length(ki)>0
        tr.chosenDice = ki(1);
      end
    end
    tr.chosenDiceLocation=tr.chosenDice;    % log location of selection
    tr.chosenDice = pa.diceIndices(tr.chosenDice); % convert location to dice index
    tr=LogEvent(pa, el, tr,'endDice');    % log start time
    ap=audioplayer(scr.soundData{1}, scr.soundFs{1}); 
    play(ap);                               % click sound
    
    drawScene(scr,pa,tr,3);   % show chosen dice
    
    %%%% 3. Outcome
    WaitSecs(pa.diceRollTime);                            % dice roll time......
    % choose either elements 1&2 or 3&4 from the dice weights
    % indicating the two currencies for the chosen dice
    tr.chosenWinProbs  = tr.diceWeights( [1,2] + (tr.chosenDice-1)*2 );       % get probability of chosen dice faces
    tr.unchosenDice  = 2-tr.chosenDice;                   % keep track of unchosen dice too
    tr.rand=rand(2,1);                                       % roll the chosen die!
    % if the winProbs are set to negative, this indicates a probability of
    % a loss. 
    for i=1:2 % currencies
      if     (tr.rand(i) <     tr.chosenWinProbs(i)  )  tr.winnings(i) = 1;  % win
      elseif (tr.rand(i) < abs(tr.chosenWinProbs(i)) )  tr.winnings(i) = -1; % lose
      else                                              tr.winnings(i) = 0;  % neither
      end
    end
    drawScene(scr,pa,tr,4);                               % show outcome
    tr=LogEvent(pa, el, tr,'startReward');
    tr.totalWin = sum(tr.winnings);% sum(winnings) should be either -1, 0 or 1
    winSound = tr.totalWin + 3; 
    ap=audioplayer(scr.soundData{winSound}, scr.soundFs{winSound}); % sound 1 = lose, 2 = nothing, 3 = win
    play(ap);
    WaitSecs(pa.feedbackTime)
    tr=LogEvent(pa, el, tr,'endReward');
    
    % added so we don't need ensure structs assignable 
    tr.isWinPurseFull = false; 
    
    %%%% 4. Check if purse is full
    tr.allowedWinnings = tr.winnings; % by default, allow the money in
    tr.isPurseFull = tr.purse >= pa.purseSize; % check if each purse is full
    tr.winCurrency  = find(abs(tr.winnings)); % if we won or lost, what was the currency?
    if isempty(tr.winCurrency), tr.winCurrency = 0; end
    if tr.totalWin>0 % if we won:
      % is the purse corresponding to the win currency full?
      tr.isWinPurseFull = tr.isPurseFull(tr.winCurrency);
      if tr.isWinPurseFull % if so
        % disallow winnings to go above the purse size
        tr.allowedWinnings = min(tr.winnings, pa.purseSize-tr.purse);
        drawScene(scr,pa,tr,5);
        ap=audioplayer(scr.soundData{2}, scr.soundFs{2}); 
        play(ap); % Play lose sound
        WaitSecs(pa.purseFullDuration); % and timeout
      else % winnings fit into purse OK
      end
    end
    
    tr.purse = tr.purse + tr.allowedWinnings;  % accumulate money
    Game.purse = tr.purse;
    tr.isPurseFullAfterReward = tr.purse >= pa.purseSize; % check if each purse is full

    %%%% 5. Next state?
    % store choice history
    h = Game.choiceHistory; 
    Game.choiceHistory = [ h tr.chosenDice];
    % how many recent trials can we select? 
    history_len = min(pa.preferenceRecency, length(h)-1);
    % calculate mean of recent choices
    tr.meanRecentChoice = mean( h(end-history_len : end) ) ;
    % which purse to move to bank? 0 = neither, 1=red, 2=green
    tr.moveToBank = 0;
    tr.goToNextState = 0;
    
    % Now the complicated bit:
    % Check criteria for progressing to next state.
    
    % get recent choice preference
    % this will either be [0 0] (no preference), [1 0], or [0 1]
    % (preference for one of the options).
    tr.recentPreference = [ % recent choice preferences
      tr.meanRecentChoice-1 < (1-pa.preferenceThreshold)  % close to choice 1
      tr.meanRecentChoice-1 > pa.preferenceThreshold      % close to choice 2
      ]; 
    for i=1:2 % for each option
      % these criteria are 0="neither", 1="first", 2="second", and 3="both". 
      % i.e. The bitwise AND with a mask indicates which choice(s)/purse(s) it applies to. 
      if bitand( crit.until_prefer, i ) % do we change when this option is preferred?
        if tr.stateTime > pa.preferenceRecency % check we have at least enough trials in this state
          if tr.recentPreference(i) % is this option preferred?
            tr.goToNextState = true;  
          end
        end
      end
    end
    for i=1:2 % for each currency
      if bitand( crit.until_full, i ) % progress if purse full?
        if tr.isPurseFullAfterReward(i) 
          tr.goToNextState = true;  % then go to next state
        end
      end
      % bank the purse if full?
      if bitand( crit.bank_when_full, i ) 
        if tr.isPurseFullAfterReward(i)  % if it's full
          tr.moveToBank = bitor( tr.moveToBank, i ); % instruct to bank it
        end
      end
    end
    if crit.until_count > 0 % change if been in a state for a given number of trials?
      if tr.stateTime >= crit.until_count % passed the required number of trials?
        tr.goToNextState = true;
      end
    end

    % move to the next state: increment game state, and bank purses if needed
    if tr.goToNextState 
      for i=1:2 % for each currency
        if bitand( crit.then_bank, i ) % should we bank it after this stage?
          tr.moveToBank = bitor( tr.moveToBank, i ); % set the bank flag
        end
      end
      Game.state = Game.state + 1; % increment the game state
      if Game.state > size(pa.rewardSchedule,1)
        Game.state =1; % wrap around if reached the end
      end
      Game.stateTime = 0; % reset the state count
    end
    
    % now move money to the bank if required
    banked = 0; % amount added to bank
    for i=1:2 % for each currency
      if bitand( tr.moveToBank, i ) % are we moving this purse to bank?
        drawScene(scr,pa,tr,4); % redraw new purse and bank balance
        WaitSecs(0.2);
        while tr.purse(i) %
          banked = banked + 1;
          tr.purse(i) = tr.purse(i) -1;
          tr.bank = tr.bank + 1;
          drawScene(scr,pa,tr,4); % redraw new purse and bank balance
          WaitSecs(0.1); % 100ms between animations
        end
        Game.bank  = tr.bank;
        Game.purse = tr.purse;
      end
    end
    if banked>0 % if anything was transferred to the bank,
      drawScene(scr,pa,tr,4); % redraw new purse and bank balance
      ap = audioplayer(scr.soundData{5}, scr.soundFs{5});
      play(ap); % Play cash register sound
      WaitSecs(pa.purseFullDuration);
    end
    
    HideCursor
    tr=LogEvent(pa, el, tr,'startITI');
    WaitSecs(pa.ITI)                                      % ITI


    
    % this is for the experimenter to intervene if necessary. 
    % If you hold down a key eg CTRL at the end of a trial,
    % the 'end of block' screen will be shown. You can then exit the experiment
    % by holding escape.
    if false % ONLY do this if touchscreen
        [z z kcode]=KbCheck;
        if any(kcode) % pause and zero
            drawTextCentred(scr, 'End of block', ex.fgColour);
            Screen('Flip', scr.w)
            while(KbCheck) ;end;
            KbWait;                             % wait for keypress after each block
            Game.bank = 0;
        end
    end
    
    
    
    tr.R=1;
    return
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
function drawScene(scr,pa,tr,stage)
% draw the screen elements for the task.
% Stage tells us what to draw, 0 = nothing but bank, 4 is everything drawn
% at the end of the trial.
    Screen('TextSize',scr.w,40);
    drawTextCentred(scr, sprintf('Bank: £%0.2f', tr.bank) ...
      , pa.fgColour, scr.centre+[ -0.3*scr.ssz(1) 0.3*scr.ssz(2) ]);
    drawTextCentred(scr, 'Purse:' ...
      , pa.fgColour, scr.centre+[ 0.1*scr.ssz(1) 0.1*scr.ssz(2) ]);
    for i=1:2 % for each colour currency
      for j=1:pa.purseSize(i) % for each coin slot in the purse
        if j > tr.purse(i) % if the slot is empty
          cmd = 'FrameOval';
        else
          cmd = 'FillOval'; % if it's full
        end
        % calculate position
        coin_centre = scr.centre + [ (j-1)*pa.coinXdistance ((i-1)*pa.coinYdistance + 0.2)*scr.ssz(2) ];
        % draw coin
        Screen(cmd, scr.w, pa.coinColour{i}, [coin_centre coin_centre]+ [ -1 -1 2 2 ] * pa.coinSize );
      end % next coin
    end % next colour
    
    
    if(stage>1) % draw dice
      drawTextCentred(scr, 'Dice: ', pa.fgColour, scr.centre-[0.4*scr.ssz(1), 0.25*scr.ssz(2)]);
      for(i=1:length(pa.dice))
        hp = (i-0.5)/length(pa.dice)-0.5;
        ce = scr.centre + [hp*scr.ssz(1), -0.25*scr.ssz(2)];
        Screen('FillRect',scr.w, pa.diceColour(pa.diceIndices(i),:), [ce-pa.diceSize ce+pa.diceSize]);
        drawTextCentred(scr, sprintf('%s',pa.dice{pa.diceIndices(i)}), pa.fgColour, ce);
      end      
    end
    if(stage>2) % draw chosen dice
      hp = (tr.chosenDiceLocation-0.5)/length(pa.dice)-0.5;
      ce = scr.centre + [hp*scr.ssz(1), -0.25*scr.ssz(2)];
      Screen('FrameRect',scr.w, pa.chosenDiceBackground, [ce-pa.diceSize ce+pa.diceSize], 6);
      drawTextCentred(scr, sprintf('%s',pa.dice{tr.chosenDice}), pa.fgColour, ce);
    end
    if(stage>3) % draw outcome
      win_colour = find(abs(tr.winnings));
      if numel(win_colour)==1
        win_amount = tr.winnings(win_colour)
      elseif isempty(win_colour)
        win_amount = 0;
      else
        tr.winnings
        error('unexpected winnings vector')
      end
      if (sum(tr.winnings)>0)  
        text=sprintf('You won %0.2f!',win_amount);
      elseif (sum(tr.winnings)==0) text='You won nothing.';
      else            text=sprintf('You lost %0.2f!', -win_amount);
      end
      drawTextCentred(scr, text, pa.fgColour, scr.centre-[0,0.1*scr.ssz(2)] );
      if win_colour > 0
        win_val = tr.winnings(win_colour);
        Screen('FillOval',scr.w,pa.coinColour{win_colour}, [scr.centre scr.centre] + [-1 -1 2 2] * pa.coinSize );
        drawTextCentred(scr, formatMoney(win_val), pa.fgColour, scr.centre+[20 20]);
      end
    end
    if(stage==5) % add purse full text
      drawTextCentred(scr, 'FULL!', pa.fgColour, scr.centre + [0.4*scr.ssz(1), 0.1*scr.ssz(2)]);
    end
    if stage==6
      drawTextCentred(scr, 'Banked', pa.coinColours{tr.moveToBank}, scr.centre + [0,0.1*scr.ssz(2)]);
    end
    %drawTextCentred(scr,sprintf('state=%g',tr.state), pa.fgColour, [200,30]);
    Screen('Flip',scr.w); 
    return
    
function hp=hpos(scr,i,n) % horizontal position of item i of n, from screen centre
   hp = ((i-0.5)/n-0.5) * scr.ssz(1);
   return

function y=formatMoney(x)
   if(x<1) % pence only
       y=sprintf('%gp',floor(x*100));
   elseif(x-floor(x)>0) % pounds and pence
       y=sprintf('£%0.2f',x);
   else % just pounds
       y=sprintf('£%g',x);
   end 
   return
   
   
   % used for speed running
   % function WaitSecs(t)
   %     return
        