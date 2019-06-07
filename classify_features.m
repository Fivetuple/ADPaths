%
% Purpose:
%           1. Perform logistic regression to classify NL-AD and MCI-AD.
%           2. Estimate accuracy on test set.
%
%           Set flags islog (which chooses signature or log signature) 
%           and mode (which chooses the sets to compare) in the code.
%
% Input     
%           
% Effects:
%
%          Prints selected features and create figures for Deviance vs. lambda
%
% Usage examples
%
%
% (c) 2018 Paul Moore - moorep@maths.ox.ac.uk 
%
% This software is provided 'as is' with no warranty or other guarantee of
% fitness for the user's purpose.  Please let the author know of any bugs
% or potential improvements.

function classify_features()

    clear;
    close all;
 
    
    % choose classification experiment
    dotrain = 1;
    dotest = 0;
    
    % use log signature
    islog = 0;
    if islog
        disp('Using log signature');
    else
        disp('Using signature');
    end              
       
    if islog
        fn = './data/log_training_features';
        fnoutstem = ['../docs/ieee/figures/log_'];
    else
        fn = './data/training_features';
        fnoutstem = ['../docs/ieee/figures/'];
    end
    load(fn,'Xtrain_ad','Xtrain_nl','Xtrain_mci');

    % create training set - mode 2 does not minimise
    mode = 0;
    if mode == 0        
        Xtrain = [Xtrain_ad; Xtrain_nl]; 
        suff = 'AD_NL';
    elseif mode == 1
        Xtrain = [Xtrain_ad; Xtrain_mci]; 
        suff = 'AD_MCI';
    elseif mode == 2
        Xtrain = [Xtrain_mci; Xtrain_nl]; 
        suff = 'MCI_NL';
    end    
    ytrain = [ones(21,1); zeros(21,1)];            
    
    % train and create Lasso curves
    if dotrain        
        doclassify(Xtrain,ytrain,fnoutstem,suff);
        close all;
    end        
    
    % test set prediction
    if dotest
        
        disp(suff);
        if islog
            load('./data/log_test_features','Xtest');
        else
            load('./data/test_features','Xtest');        
        end

        if mode == 0        
            Xtestset = [Xtest.fvad; Xtest.fvnl]; 
            ytestset = [ones(size(Xtest.fvad,1),1); zeros(size(Xtest.fvnl,1),1)];     
        elseif mode == 1
            Xtestset = [Xtest.fvad; Xtest.fvmci]; 
            ytestset = [ones(size(Xtest.fvad,1),1); zeros(size(Xtest.fvmci,1),1)];     
        elseif mode == 2
            Xtestset = [Xtest.fvmci; Xtest.fvnl]; 
            ytestset = [ones(size(Xtest.fvmci,1),1); zeros(size(Xtest.fvnl,1),1)];     
        end    
    
        % fit model to training set
        rng(37);
        [B,FitInfo] = lassoglm(Xtrain,ytrain,'binomial','LambdaRatio',0.001,'NumLambda',50,'CV',10);
        
        % evaluate on test set
        indx = FitInfo.Index1SE;
        BSE = B(:,indx);
        %find(BSE ~= 0);   
        cnst = FitInfo.Intercept(indx);
        coef = [cnst; BSE];
        %[y ylo yhi] = glmval(coef,Xtestset,'logit',FitInfo);
        y = glmval(coef,Xtestset,'logit');
        [roc, AUC, topt] = compute_roc(ytestset, y, 0, 1);
        fn = '';
        aucstr =['AUC=' num2str(AUC,2)];
        %plot_roc({roc}, {aucstr}, fn, '');
        disp(aucstr);
        cm = confusionmat(ytestset==1,y>topt);
        disp(cm);
    end
        
end



% function
function doclassify(Xtrain,ytrain,fnoutstem,suff)
    
    rng(37);
    [B,FitInfo] = lassoglm(Xtrain,ytrain,'binomial','LambdaRatio',0.001,'NumLambda',50,'CV',10);
    lassoPlot(B,FitInfo,'PlotType','CV');
    title('');
       
    ymin = 0;
    
    fn = [fnoutstem 'lasso_' suff '.eps'];
    xlabel('Shrinkage parameter \lambda','Fontsize',16);
    ylabel('Deviance','Fontsize',16);
    ylim([ymin 100]);

    % debug
    if 0
        saveas(gcf,fn,'epsc');
    end
    
%     lassoPlot(B,FitInfo,'PlotType','Lambda','XScale','log');
%     fn = [fnoutstem 'lambda_' suff '.eps'];
%     saveas(gcf,fn,'epsc');

    if 0
        disp([suff ' Min deviance']);
        indx = FitInfo.IndexMinDeviance;
        B0 = B(:,indx);        
        find(B0 ~= 0)  
        sprintf('%.2f\n', B0(B0 ~= 0))
    end

    indx = FitInfo.Index1SE;
    disp([suff ' One SD']);
    B0 = B(:,indx);        
    [find(B0 ~= 0)  B0(B0 ~= 0)]  
end
