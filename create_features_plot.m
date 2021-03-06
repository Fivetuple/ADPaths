%
% Purpose: See readme.txt
%
% Input     
%           
% Effects:
%
% Usage examples
%
%
% (c) 2018 Paul Moore - moorep@maths.ox.ac.uk 
%
% This software is provided 'as is' with no warranty or other guarantee of
% fitness for the user's purpose.  Please let the author know of any bugs
% or potential improvements.

% To run this, esig needs to be callable, and on some systems the LD_PRELOAD call made:
% workon sci
% LD_PRELOAD="/usr/lib/x86_64-linux-gnu/libstdc++.so.6" matlab 


function create_features_plot()

    clear;
    close all;
 
    addpath('../../shared/code/common');
    addpath('../../shared/code/util');

    % use log signature
    islog = 0;
    if islog
        disp('Using log signature');
    else
        disp('Using signature');
    end
           
    % choose data tag 
    datatag = 'brain702xt';                  
    load(['./data/tpdata_' datatag],'tpdata');
    
       
    disp('Creating training features');

    load('./data/training_set','sadrids','snlrids','smcirids');   

    [Xtrain_ad, Xtrain_nl, Xtrain_mci] = get_training_feature_vectors(tpdata,sadrids,snlrids,smcirids,islog);     

    
end


% function
function [fvad, fvnl, fvmci] = get_training_feature_vectors(tpd,sadrids,snlrids,smcirids,islog)    
    
    if islog
        fvad = zeros(1,13);
        fvnl = zeros(1,13);
        fvmci = zeros(1,13);
    else
        fvad = zeros(1,23);
        fvnl = zeros(1,23);
        fvmci = zeros(1,23);
    end
    
    % iterate over AD list
    for i=1:length(sadrids)

        disp(i);
        
        % AD set
        adrid = sadrids(i);
        adts = tpd(tpd(:,1)==adrid,:);
        adts = sortrows(adts,4);
        idx = find(adts(:,4)==24);
        adts = adts(1:idx,:);
        % remove 3 month measurements which are exclusive to AD
        id3 = find(adts(:,4)==3);
        if id3
            adts(id3,:) = [];             
        end            
        
        % NL set
        nlrid = snlrids(i);
        nlts = tpd(tpd(:,1)==nlrid,:);
        nlts = sortrows(nlts,4);
        idx = find(nlts(:,4)==24);
        nlts = nlts(1:idx,:); 
                                                
        % MCI set
        mcirid = smcirids(i);
        mcits = tpd(tpd(:,1)==mcirid,:);
        mcits = sortrows(mcits,4);
        idx = find(mcits(:,4)==24);
        mcits = mcits(1:idx,:); 

        disp('AD');
        fvad(i,:) = getfv(adts,islog);
        
        disp('NL');
        fvnl(i,:) = getfv(nlts,islog);
        %fvmci(i,:) = getfv(mcits,islog);

    end
  
end




%function
function fv = getfv(ts,islog)

    c1 = [0 0.6 1]; % blue 
    deg = 2;    

    % estimate hippocampus baseline when it is empty
    if isnan(ts(1,22))
        disp('Estimating Hippocampus baseline measurement.');
        ts(1,22) = ts(2,22); 
    end
    
    % scale wholebrain, hippocampus, ventricles  
    scale = [1000000 10000 100000];
    tsw = ts(:,23)./scale(1);
    tsh = ts(:,22)./scale(2);
    tsv = ts(:,34)./scale(3);
    idx = ~isnan(tsw) & ~isnan(tsh) & ~isnan(tsv);   
    
    t = ts(:,6);     % 6 is the index for month_bl = months since baseline
    f0 = t(idx);
    % scale time
    f0 = f0-f0(1);
    f0 = f0/30;
    f1 = tsw(idx);
    f2 = tsh(idx);
    f3 = tsv(idx);
    
    % the signature is formed from time, wholebrain, hippocampus, ventricles.
    M = [f0 f1 f2 f3];
    
    % plot hippocampus vs wholebrain
    plot_features = 1;
    if plot_features
        
        %figure('visible','on');
        scatter(f1,f2,200,c1,'s','filled','Linewidth',3);
        lsline;
        %fn = [fnstem num2str(i) '.eps' ] ;
        %saveas(gcf,fn,'epsc');
    end        
    sig = matlab_esig_shell(deg, M, islog);                      
    %sig = zeros(1,21);
    if islog
        fv = [f1(1) f2(1) f3(1) sig]; 
    else
        fv = [f1(1) f2(1) f3(1) sig(2:end)]; 
    end
    
     % signature feature set is 
     % 1:3      wholebrain_bl, hippo_bl, vents_bl, 
     % 4:7      incr(t), incr(wholebrain), incr(hippo), incr(vents)
     % 8:11     area(t,t), area(t,w), area(t,h), area(t,v)
     % 12:15    area(w,t), area(w,w), area(w,h), area(w,v)
     % 16:19    area(h,t), area(h,w), area(h,h), area(h,v)
     % 20:23    area(v,t), area(v,w), area(v,h), area(v,v)            
     
     % log signature feature set is 
     % 1:3      wholebrain_bl, hippo_bl, vents_bl, 
     % 4:7      incr(t), incr(wholebrain), incr(hippo), incr(vents)
     % 8:10     area(t,w), area(t,h), area(t,v)
     % 11:12    area(w,h), area(w,v)
     % 13       area(h,v)       
     
end
    


