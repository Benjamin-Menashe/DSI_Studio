%% Explorar las relaciones entre dos variables y Estimar los modelos de regresion
clear all; close all; clc;
path ='F:\Experimento1_Manolo\Sesion1';
cd([path,filesep,'forNBS_PPI_WholeModel']);
data = load('WBetweennes_Cent_2020.txt');
Var_dep = data(:,1);
Factor1 = cat(1,ones(44,1),ones(44,1),2.*ones(44,1),2.*ones(44,1)); %Gender
Factor2 = cat(1,ones(44,1),2.*ones(44,1),ones(44,1),2.*ones(44,1)); %Grammaticality
%-------------ANOVA-----------------------------------
[p(nroi),table,stats,terms] = anovan(Var_dep,{Factor1,Factor2},'model','full');
%------------Figure Regress---------------------------
Data_new = dataset(Var_dep,Cov,Group);
figure('Color',[1 1 1]);
gscatter(Var_dep,Cov,Group,'bgr','x.o');
title('Var_dep vs. Cov, Grouped by Group');
%------------Estimating Regressions-------------------
Modelfit = LinearModel.fit(Data_new,'Var_dep~Cov*Group')
anova(Modelfit)
%------------Plot fitted regression lines-------------
w = linspace(min(Cov),max(Cov));
figure('Color',[1 1 1]);
gscatter(Cov,Var_dep,Group,'bg','x.')
% line(w,feval(Modelfit,w,'1'),'Color','b','LineWidth',2);
% line(w,feval(Modelfit,w,'2'),'Color','g','LineWidth',2);
[bls,bint,r,rint,stats] = regress(Var_dep(Group == 1),[ones(size(Cov(Group == 1))) Cov(Group == 1)]);
hold on;
plot(Cov(Group == 1),bls(1)+bls(2)*Cov(Group == 1),'b','LineWidth',2);
[bls,bint,r,rint,stats] = regress(Var_dep(Group == 2),[ones(size(Cov(Group == 2))) Cov(Group == 2)]);
hold on;
plot(Cov(Group == 2),bls(1)+bls(2)*Cov(Group == 2),'g','LineWidth',2);
title('Fitted Regression Lines by Groups');


[FDR, Q, Pi0, R2] = mafdr(PValues,'BHFDR', BHFDRValue,'Lambda', LambdaValue,'Method', MethodValue,'Showplot', ShowplotValue);
