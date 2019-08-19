%
% Purpose:
%           Creates matched AD, MCI and NL sets for training.
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

function create_training_set()

    clear;
    close all;
 
    addpath('../../shared/code/common');
    addpath('../../shared/code/util');
    
    % see tadpole_save_dataset for variable names           
    
    % choose data tag 
    datatag = 'brain702xt';                  
    load(['./data/tpdata_' datatag],'tpdata');
    tpd = tpdata;
    clear tpdata;
      
    load('./data/three_sets','adrids','nlrids','mcirids');    
        
    % random seed
    rng(37);     
    fullset.adrids = randsample(adrids,numel(adrids));        
    fullset.nlrids = randsample(nlrids,numel(nlrids));        
    fullset.mcirids = randsample(mcirids,numel(mcirids));     
    
    % matched in order
    [sadrids, snlrids, smcirids] = getMatchedSets(tpd,fullset);  

    save('./data/training_set','sadrids','snlrids','smcirids');
    
    doexamine = 1;
    if doexamine 

        disp('----------------- N L -----------------');
        summarise_set(tpd,snlrids,1);

        disp('----------------- A D -----------------');
        summarise_set(tpd,sadrids,1);
                
        disp('----------------- M C I -----------------');
        summarise_set(tpd,smcirids,1);
        
    end
    
end



% function
function [sadrids, snlrids, smcirids] = getMatchedSets(tpd,fullset)

    adrids = fullset.adrids;
    nlrids = fullset.nlrids;
    mcirids = fullset.mcirids;

    sadrids = [];
    snlrids = [];
    smcirids = [];
    trids = [];
    minpoints = 4;
    
    for i=1:length(adrids)

        % find participant
        rid = adrids(i);
        ridsat = tpd(tpd(:,1)==rid,:);
        ridsat = sortrows(ridsat,4);
        
        % find position of first DX==3
        f = find(ridsat(:,5)==3);        
        dxind = f(1);
        dxvc = ridsat(dxind,4);
                    
        % look for a DX==3 point at 36 months and check DX>0 at 24 months.
        dxok = false;
        if dxvc == 36 
            vcs = ridsat(:,4);
            indend = find(vcs == 24);      
            if ~isempty(indend) 
                dx = ridsat(indend,5);
                dxok = dx > 0;
            end
        end
                
        if dxok

            % get variables time series
            histat = ridsat(1:indend,:);            
            wholebrains = histat(:,23);
            hippos = histat(:,22);
            vents = histat(:,34);
            
            % check variable support
            n1 = length(find(~isnan(wholebrains))) >= minpoints && ~isnan(wholebrains(end));
            n2 = length(find(~isnan(hippos))) >= minpoints && ~isnan(hippos(end));
            n3 = length(find(~isnan(vents))) >= minpoints && ~isnan(vents(end));
            
            if n1 && n2 && n3 
                
                % find matching NL rid 
                crid = selectCpartNL(tpd,nlrids,snlrids,rid);                                
                if ~isnan(crid)
                    
                    % find matching MCI rid
                    mrid = selectCpartMCI(tpd,mcirids,smcirids,rid);                                                
                    if ~isnan(mrid)
                        
                        %disp(vcs(1:indend));
                        %svcs = vcs(1:indend);            
                        %disp([svcs wholebrains]);
                        sadrids = [sadrids; rid]; 
                        snlrids = [snlrids; crid];                     
                        smcirids = [smcirids; mrid];
                    end
                end
                trids = [trids; rid]; 
                
            else
                1;
            end                        
            
        end

    end
end


% function
% For each individual in the AD set we find a matching healthy counterpart 
function crid = selectCpartNL(tpd,nlrids,snlrids,rid)

    minpoints = 4;
    crid = NaN;
    ts = tpd(tpd(:,1)==rid,:);
    ts = sortrows(ts,4);
    age_bl = ts(1,8);
     
    % select only from those not already selected
    srids = setdiff(nlrids, snlrids,'stable');
    
    % iterate over candidates
    for k=1:length(srids)
        
        rid = srids(k);
        ridsat = tpd(tpd(:,1)==rid,:);
        ridsat = sortrows(ridsat,4);

        % make sure a measurement at month 24 is present in the candidate        
        vcs = ridsat(:,4);
        id_month24 = find(vcs==24);        
              
        % set dxok if any healthy DX found at or after 6 years since
        % baseline
        dxok = false;
        ids = find(vcs >= 72);
        if ~isempty(ids)
            dxes = ridsat(ids,5);
            dxok = any(dxes == 1);
        end
        
        cage_bl = ridsat(1,8);
        agematch = (abs(age_bl-cage_bl) <= 5);
        
        % condition is that the candidate must match for age, be healthy for 6 years since baseline, 
        % and at least minpoints up to month 24, with valid points at month 24
        if agematch && dxok && ~isempty(id_month24) 
        
            cts = ridsat(1:id_month24,:); 
            wholebrains = cts(:,23);
            hippos = cts(:,22);
            vents = cts(:,34);

            n1 = length(find(~isnan(wholebrains))) >= minpoints && ~isnan(wholebrains(end));
            n2 = length(find(~isnan(hippos))) >= minpoints && ~isnan(hippos(end));
            n3 = length(find(~isnan(vents))) >= minpoints && ~isnan(vents(end));
            
            if n1 && n2 && n3                

                %svcs = vcs(1:id_month24);            
                %disp([svcs wholebrains]);
                crid = rid;
                break;
            end               
        end
    end
    
end




% function
% For each individual in the AD set we find a matching MCI counterpart 
function crid = selectCpartMCI(tpd,mcirids,smcirids,rid)

    minpoints = 4;
    crid = NaN;
    ts = tpd(tpd(:,1)==rid,:);
    ts = sortrows(ts,4);
    age_bl = ts(1,8);
     
    % select only from those not already selected
    srids = setdiff(mcirids, smcirids,'stable');
    
    % iterate over candidates
    for k=1:length(srids)
        
        rid = srids(k);
        ridsat = tpd(tpd(:,1)==rid,:);
        ridsat = sortrows(ridsat,4);

        % make sure a measurement at month 24 is present in the candidate        
        vcs = ridsat(:,4);
        id_month24 = find(vcs==24);                              
        
        % set dxok if an MCI diagnosis found at month 72 or later         
        dxok = false;
        ids = find(vcs >= 72);
        if ~isempty(ids)
            dxes = ridsat(ids,5);
            dxok = any(dxes == 2);
        end                
        
        cage_bl = ridsat(1,8);
        agematch = (abs(age_bl-cage_bl) <= 5);
        
        % condition is that the candidate must match for age, be healthy for 6 years since baseline, 
        % and at least minpoints up to month 24, with valid points at month 24
        if agematch && dxok && ~isempty(id_month24) 
        
            cts = ridsat(1:id_month24,:); 
            wholebrains = cts(:,23);
            hippos = cts(:,22);
            vents = cts(:,34);
            
            n1 = length(find(~isnan(wholebrains))) >= minpoints && ~isnan(wholebrains(end));
            n2 = length(find(~isnan(hippos))) >= minpoints && ~isnan(hippos(end));
            n3 = length(find(~isnan(vents))) >= minpoints && ~isnan(vents(end));
            
            if n1 && n2 && n3
                              
                %svcs = vcs(1:id_month24);            
                %disp([svcs wholebrains]);
                crid = rid;
                break;
            end               
        end
    end
    
end


% function
function summarise_set(tpd,rids,show)


    % Features 34:39   
    % keys = 'Ventricles,Ventricles_bl,Hippocampus_bl,WholeBrain_bl,Entorhinal_bl,Fusiform_bl';
  
    c = [];
    age = [];
    gender = [];
    apoe = [];
    brain = [];
    vent = [];
    hippo = [];
    dxs = [];
    dxe = [];
    mmse = [];

    for i=1:length(rids)
        
        rid = rids(i);
        ridsat = find(tpd(:,1)==rid);
        b = tpd(ridsat,:); 
        b = sortrows(b,4);  % 4 is VISCODE
        age(i) = b(1,8); %#ok<*AGROW>
        gender(i) = b(1,9);
        apoe(i) = b(1,12);
        brain(i) = b(1,37);
        vent(i) = b(1,35);
        hippo(i) = b(1,36);
        dxs(i) = b(1,5);
        dxe(i) = b(end,5);
        mmse(i) = b(1,13);
        c(i) = length(ridsat);
    end
    
    if show
        disp(['count ' num2str(length(rids))]);        
        disp(['min(c) ' num2str(min(c))]);
        disp(['median(c) ' num2str(median(c))]);
        disp(['iqr(c) ' num2str(iqr(c))]);
        disp(['max(c) ' num2str(max(c))]);
        disp(['min(age) ' num2str(min(age))]);
        disp(['mean(age) ' num2str(mean(age),4)]);
        disp(['max(age) ' num2str(max(age))]);
        disp(['min(brain) ' num2str(min(brain))]);
        disp(['median(brain) ' num2str(median(brain))]);
        disp(['max(brain) ' num2str(max(brain))]);
        disp(['iqr(brain) ' num2str(iqr(brain))]);
        disp(['min(vent) ' num2str(min(vent))]);
        disp(['median(vent) ' num2str(median(vent))]);
        disp(['max(vent) ' num2str(max(vent))]);
        disp(['iqr(vent) ' num2str(iqr(vent))]);
        disp(['min(hippo) ' num2str(min(hippo))]);
        disp(['median(hippo) ' num2str(nanmedian(hippo))]);  % note NaN
        disp(['max(hippo) ' num2str(max(hippo))]);
        disp(['iqr(hippo) ' num2str(iqr(hippo))]);
        disp('apoe');
        tabulate(apoe);
        disp('gender');
        tabulate(gender);
        disp('initial dx');
        tabulate(dxs);
        disp('final dx');
        tabulate(dxe);
        disp(['median(initial mmse) ' num2str(nanmedian(mmse))]);
        %disp('lengths');
        %tabulate(c);
        disp(' ');
        disp(' ');
    end    
end

