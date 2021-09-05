%% Explorar las relaciones entre dos variables y Estimar los modelos de regresion
clear all; close all; clc;
path ='F:\Experimento1_Manolo\Sesion1';
cd([path,filesep,'forNBS_PPI_WholeModel']);
names_out = {'WBetweennes_Cent_2020','WEdgeBetweennes_Cent_2020','WLinksperNode_2020',...
    'WWeightsperNode_2020','WLocalEffic_2020','WClustering_2020','WModularity_2020',...
    'WStrengths_2020','WDegrees_2020'};
%Defining the factors of the ANOVA
Factor1 = cat(1,ones(44,1),ones(44,1),2.*ones(44,1),2.*ones(44,1)); %Gender
Factor2 = cat(1,ones(44,1),2.*ones(44,1),ones(44,1),2.*ones(44,1)); %Grammaticality
Factor3 = repmat([1:1:44]',[4,1]);
Model = [0 1 0;0 0 1;1 1 0];
for measure = 1: length(names_out)
    %Normalizing the data
    data = load([names_out{measure} '.txt']);
    Zdata = zscore(data);
    %-------------ANOVAs per regions-----------------------------------
    for nroi = 1: size(data,2)
        Var_dep = Zdata(:,nroi);
        [p(:,nroi),table,stats,terms] = anovan(Var_dep,{Factor1,Factor2,Factor3},'model',Model,...
            'random',3,'varnames',{'Gender' 'Grammaticality','Participants'},'display','off');
    end
    pvalues(:,:,measure) = p';
    %Multiple comparison correction
    p_forFDR = squeeze(pvalues(:,:,measure));
    p_forFDR(:,2) = [];
    FDR_BH(:,measure) = mafdr(p_forFDR(:),'BHFDR', 'true');
    [FDR(:,measure),Q,PIO]  = mafdr(p_forFDR(:),'LAMBDA',[0.01:0.01:0.95],'METHOD','bootstrap');
end
pvalues_exp = reshape(permute(pvalues,[1 3 2]),24*9,3);
FDR_exp = reshape(FDR,24,2,9);
FDR_exp = reshape(permute(FDR,[1 3 2]),24*9,2);
save pvalues_Measures2.txt pvalues_exp -ascii
save pvalues_corrFDR_Measures2_L.txt FDR_exp -ascii

%To think, the MANOVAs, I think could be a good idea to combine the measures
% t = table(species,meas(:,1),meas(:,2),meas(:,3),meas(:,4),...
%     'VariableNames',{'species','meas1','meas2','meas3','meas4'});
% Meas = dataset([1:1:24]','VarNames',{'Regions'});
% rm = fitrm(t,'meas1-meas4~species','WithinDesign',Meas);
% [manovatbl,A,C,D] = manova(rm)

%% Repeated Measures ANOVA
clear all; close all; clc;
path ='F:\Experimento1_Manolo\Sesion1';
cd([path,filesep,'forNBS_PPI_WholeModel']);
names_out = {'WBetweennes_Cent_2020','WEdgeBetweennes_Cent_2020','WLinksperNode_2020',...
    'WWeightsperNode_2020','WLocalEffic_2020','WClustering_2020','WModularity_2020',...
    'WStrengths_2020','WDegrees_2020'};
%Defining the factors of the ANOVA
Factor1 = cat(1,ones(24,1),ones(24,1),2.*ones(24,1),2.*ones(24,1)); %Gender
Factor2 = cat(1,ones(24,1),2.*ones(24,1),ones(24,1),2.*ones(24,1)); %Grammaticality
Factor3 = repmat([1:1:24]',[4,1]); %ROIs
Within = dataset(Factor1,Factor2,Factor3,'VarNames',{'Gender','Grammaticality','ROIs'});
for measure = 1: length(names_out)
    %Loading the data
    data = load([names_out{measure} '.txt']);
    data = permute(reshape(data,44,4,24),[3 2 1]);
    data = reshape(data,24*4,44);
    %Dealing with infinite values
    ind = find(isinf(data));
    data(ind) = NaN;
    data(ind) = nanmean(data(:));
%     %Normalizing the data
%     Zdata = zscore(data);
    %Creating the table
    t = array2table(cat(2,Factor1,Factor2,Factor3,data));
    %Adjusting the model
    rm = fitrm(t,'Var4-Var47 ~ Var1+Var2+Var3+Var1*Var2+Var1*Var2*Var3');
    %Estimating the model
    ranovatbl = ranova(rm,'WithinModel','Gender + Grammaticality','WithinDesign',Within);
    Out(:,:,measure) = table2array(ranovatbl);
end
Out = reshape(permute(Out,[1 3 2]),9*9,8);
save RepANOVA.txt Out -ascii