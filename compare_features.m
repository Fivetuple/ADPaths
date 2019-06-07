%
% Purpose: See readme.txt.
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

function compare_features()

    clear;
    close all;
 
 
    c1 = [0.2 0.5 0.8];    % blue
    
    % use log signature
    islog = 0;
    if islog
        disp('Using log signature');
    else
        disp('Using signature');
    end              
       
    if islog
        fn = './data/log_training_features';
        fnoutstem = '../docs/plos_revision1/figures/compare_log_features';
    else
        fn = './data/training_features';
        fnoutstem = '../docs/plos_revision1/figures/compare_features';
    end
    load(fn,'Xtrain_ad','Xtrain_nl','Xtrain_mci');

    % create training set 
    mode = 0;
    if mode == 0        
        Xtrain = [Xtrain_ad; Xtrain_nl]; 
        suff = 'AD_NL';
    elseif mode == 1
        Xtrain = [Xtrain_ad; Xtrain_mci]; 
        suff = 'AD_MCI';
    elseif mode == 2  % not used
        Xtrain = [Xtrain_mci; Xtrain_nl]; 
        suff = 'MCI_NL';
    end    
    %ytrain = [ones(21,1); zeros(21,1)];            
    
    if 1
        ft = 17; % (hippocampus, wholebrain)
        ylimits = [-0.0005 0.0026];
        xlimits = [0 55];
        %ft = 5;  % wholebrain
        %ylimits = [-0.06 0.03];
        %ft = 6;  % hippocampus
        %ylimits = [-0.06 0.03];

%        thesis_figure(1,12,6);
%        figure(1);
        set(gcf,'Units','cent','Position',[10 10 24 4]);  
        exes = [Xtrain(1:21,ft);zeros(12,1);Xtrain(21:42,ft)];
        bar(exes,'FaceColor',c1)       
        xlim(xlimits)        
        ylim(ylimits)        
        set(gca,'XTickLabel',[]);
        ylabel('Area (h,w)','FontSize',16);
        %title('AD features');
        fn = [fnoutstem '.eps'];
        saveas(gcf,fn,'epsc');    

        if 0
        %thesis_figure(2,12,10);
        figure(2);        
        bar(Xtrain(22:42,ft),'FaceColor',c1)
        ylim(ylimits)
        set(gca,'XTickLabel',[]);
        set(gca,'YTickLabel',[]);
        %ylabel('Area (h,w)','FontSize',16);
        
        %title('NL features');
        fn = [fnoutstem suff(4:end) '.eps'];
        saveas(gcf,fn,'epsc');    
        end
    end
    
    
    
end