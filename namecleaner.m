%% convert names %%

dataFile = 'ThesisTable_alldata16-May-2020.xls_clean.xls';
dictFile = 'Dictionary_FAKE.xlsx';

[~,dict,~] = xlsread(dictFile);
[~,~,data] = xlsread(dataFile);

for ii = 1:length(data(:,2))
    namecur = data(ii,2);
    ind = find(strcmp(namecur,dict(:,1)));
    data{ii,2} = dict{ind,2};
    data(ii,32:38) = dict(ind,3:9);
end

xlswrite([dataFile '_clean.xls'], data)
