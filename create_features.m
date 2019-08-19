%
% Purpose:
%           Creates features for both training and test sets.
%           Set flags islog, create_training_features, create_test_features
%           in the code.
%
% Input     
%           
% Effects:
%
% Usage examples
%
%
% (c) 2019 Paul Moore - moorep@maths.ox.ac.uk 
%
% This software is provided 'as is' with no warranty or other guarantee of
% fitness for the user's purpose.  Please let the author know of any bugs
% or potential improvements.

% To run this, esig needs to be callable, and on some systems the LD_PRELOAD call made:
% workon sci
% LD_PRELOAD="/usr/lib/x86_64-linux-gnu/libstdc++.so.6" matlab 


function create_features()

    clear;
    close all;
 
    addpath('../../shared/code/common');
    addpath('../../shared/code/util');

    % choose which features to create
    create_training_features = 0;
    create_test_features = 1;

    % use log signature
    islog = 1;
    if islog
        disp('Using log signature');
    else
        disp('Using signature');
    end
           
    % choose data tag 
    datatag = 'brain702xt';                  
    load(['./data/tpdata_' datatag],'tpdata');
    

    if create_training_features
        
        disp('Creating training features');
        
        load('./data/training_set','sadrids','snlrids','smcirids');   

        [Xtrain_ad, Xtrain_nl, Xtrain_mci] = get_training_feature_vectors(tpdata,sadrids,snlrids,smcirids,islog);     

        if islog
            save('./data/log_training_features','Xtrain_ad','Xtrain_nl','Xtrain_mci');
        else
            save('./data/training_features','Xtrain_ad','Xtrain_nl','Xtrain_mci');        
        end
    end

    if create_test_features
        
        disp('Creating test features');

        load('./data/test_set','testset');
        
        Xtest = get_test_feature_vectors(tpdata,testset,islog);      %#ok<*NASGU>

        if islog
            save('./data/log_test_features','Xtest');
        else
            save('./data/test_features','Xtest');        
        end
    end

    
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
                                                
        fvad(i,:) = getfv(adts,islog);
        fvnl(i,:) = getfv(nlts,islog);
        fvmci(i,:) = getfv(mcits,islog);

    end
  
end



% function
function Xtest = get_test_feature_vectors(tpd,testset,islog)     
    
    if islog
        Xtest.fvad = zeros(1,13);
        Xtest.fvnl = zeros(1,13);
        Xtest.fvmci = zeros(1,13);
    else
        Xtest.fvad = zeros(1,23);
        Xtest.fvnl = zeros(1,23);
        Xtest.fvmci = zeros(1,23);
    end
    
    tpoints = [12 24 36];
    
    % iterate over AD set
    for i=1:length(testset.adrids)
                
        rid = testset.adrids(i);
        ts = tpd(tpd(:,1)==rid,:);
        ts = sortrows(ts,4);
        idxs = find(ismember(ts(:,4),tpoints));
        ts = ts(idxs,:);             %#ok<*FNDSB>                                                        
        Xtest.fvad(i,:) = getfv(ts,islog);
    end 
    
    % iterate over NL set
    for i=1:length(testset.nlrids)
                
        rid = testset.nlrids(i);
        ts = tpd(tpd(:,1)==rid,:);
        ts = sortrows(ts,4);
        idxs = find(ismember(ts(:,4),tpoints));
        ts = ts(idxs,:);                                                                     
        Xtest.fvnl(i,:) = getfv(ts,islog);
    end 
    
    % iterate over MCI set
    for i=1:length(testset.mcirids)
                
        rid = testset.mcirids(i);
        ts = tpd(tpd(:,1)==rid,:);
        ts = sortrows(ts,4);
        idxs = find(ismember(ts(:,4),tpoints));
        ts = ts(idxs,:);                                                                     
        Xtest.fvmci(i,:) = getfv(ts,islog);
    end     
  
end



%function
function fv = getfv(ts,islog)

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
    


