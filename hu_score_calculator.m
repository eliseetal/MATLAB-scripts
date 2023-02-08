%% Calculate Hu scores: 
% Script that reads in raw data, calculates unbiased hit rates using a for
% loop, and saves each participants' hu scores to separate sheets within an
% excel file 

% Change directory to where the data is stored
cd 'your/file/path'

% List of subjects data you want to process
subs = {
'G101B'
'G102A'
'G102B'
'G103A'
'G103B'
'G104A'
'G104B'
'G105A'
'G105B'
   }; 


for j = 1:length(subs)
    
Datasheet = subs{j};
data = xlsread('data_raw.xlsx', Datasheet, 'B:C'); % Response ANSWER stim_type    
response = data(:, 1);
answer = data(:, 2);


hits_pf = nansum((response == 1) & (answer == 1));
hits_f = nansum((response == 2) & (answer == 2)); 
hits_uf = nansum((response == 3) & (answer == 3)); 

actual_pf = nansum(answer == 1); 
actual_f = nansum(answer == 2); 
actual_uf = nansum(answer == 3); 

total_res_pf = nansum(response == 1);
total_res_f = nansum(response == 2);
total_res_uf = nansum(response == 3);


hu_pf = ((hits_pf/actual_pf) * (hits_pf/total_res_pf));
hu_pf = hu_pf(:);

hu_f = ((hits_f/actual_f) * (hits_f/total_res_f));
hu_f = hu_f(:);

hu_uf = ((hits_uf/actual_uf) * (hits_uf/total_res_uf));
hu_uf = hu_uf(:);


asin_pf = asin(sqrt(hu_pf));
asin_f = asin(sqrt(hu_f));
asin_uf = asin(sqrt(hu_uf));



table1 = table(hu_pf, hu_f, hu_uf, asin_pf, asin_f, asin_uf);
writetable(table1, 'Hu_scores.xlsx', 'sheet', subs{j})

end




