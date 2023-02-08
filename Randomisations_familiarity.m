% Randomisations for order of conditions (e.g. PF, F, UF, rest, VIG) 
clear
for m = 1:35 % want to run this for 35 participants
ttype = [];
k = 1; 

while k < 9 % run the randomisation 8 times to get 96 trials
    rand('twister', sum(100*clock));
    WaitSecs(0.2);
    miniblock = [1 1 1 2 2 2 3 3 3 4 4 4]; % want the same number of trials for conditions 1-3 and 5, fewer trials for condition 4 
    miniblockperm = randperm(12); 
    miniblockorder = miniblock(miniblockperm); 
    ttype = [ttype miniblockorder];
    k = k + 1; 
    
%     if k == 30
%         for n = 1:180
%             
%             % if the below conditions are met (do not want), then start
%             % randomisations again
%             if ((ttype(n) == 5 && ttype(n+1) == 4) || (ttype(n) == 4 && ttype(n+1) == 4) || ttype(1) == 4) % we have constraints such as condition 5 can't be followed by condition 4, first trial can't be condition 4 etc. 
%                 ttype = []; 
%                 k = 1;
%                 disp('trying again'); 
%                 
%                 break
%                 
%             end
%         end
%     end
end
    sheet = m;  % create a new sheet in Excel for each participant
    table1 = table(ttype); % create a table from randomisations
writetable(table1, 'trialtype_run4.xlsx', 'sheet', sheet) % write the table to an excel file
% with a new sheet for each participant
end 

%% Randomisations for trial order within each condition (for conditions 1-3 only). 
for i = 1:35 % want randomisations for 30 participants
j = 1;

while j < 4 % want to run this randomisation 3 times, each time filling a new cell in cell array
   rand('twister', sum(100*clock));
    WaitSecs(0.1); 
    miniblock{j} = [1 1 1 2 2 2 3 3 3 4 4 4 5 5 5 6 6 6 7 7 7 8 8 8]; % we have 14 stimuli that we want to randomise per participant. 
    miniblockperm = randperm(24);
    randvec_a{j} = miniblock{j}(miniblockperm);
    
%     
%     randvec_c{j} = randperm(15); % 2nd block of 15
%     rand('twister', sum(100*clock)); 
%     WaitSecs(0.1);
%     
%     randvec_a{j} = [randvec_b{j} randvec_c{j}]; % concatenate
  
 j = j + 1;
    
%     if j == 4
%         for r = 1:29
%             for s = 1:28
%                 for t = 1:3
%                     % we do not want the same stimulus repeating on two
%                     % successive trials or even two trials apart - so we check this. If repeats,
%                     % start process again.
%                     if isequal(randvec_a{t}(r), randvec_a{t}(r+1)) == 1 || isequal(randvec_a{t}(s), randvec_a{t}(s+2)) == 1
%                         j = 1;
%                         randvec_b = [];
%                         randvec_c = [];
%                         disp('trying randomisations again')
%                         
%                         break
%                     end
%                 end
%             end
%         end
%     end
end

% Sanity check that the randomisations have worked.
% for p = 1:30
% for h = 1:3
%      a(p) = randvec_a{h}(p) == 4 && ttype(p+1) == 4;
%      v(p) = ttype(p) == 5 && ttype(p+1) == 5;
%      
%      s = find(a, 120);
%      q = find(v, 120);
%  
% end


sheet = i; % new sheet for each participant
table1 = table(randvec_a{1}); 
table2 = table(randvec_a{2});
table3 = table(randvec_a{3}); 

  writetable(table1, 'stimulus_order_run4_PF.xlsx', 'sheet', sheet); % will do this for each of 3 runs
  writetable(table2, 'stimulus_order_run4_F.xlsx', 'sheet', sheet); 
  writetable(table3, 'stimulus_order_run4_UF.xlsx', 'sheet', sheet);
  
end