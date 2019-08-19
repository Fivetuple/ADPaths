%
% Purpose:
%
% Create a test set formed of AD,NL and MCI participants.  
% The time series have at least three measurements of all the
% variables WholeBrain, Hippocampus and Ventricles in the period
% from 12 to 36 months.  The AD set has the first diagnosis of 
% AD at 48 months, with an NL or MCI diagnosis at
% 36 months.  The NL and MCI sets have only those respective 
% diagnoses at all points, with one at or later than 72 months.
% 
%
% The set of participants is disjoint with that of the training set.
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

function create_test_set()

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
    load('./data/training_set','sadrids','snlrids','smcirids');
        
    % random seed
    rng(37);     
    fullset.adrids = randsample(adrids,numel(adrids));        
    fullset.nlrids = randsample(nlrids,numel(nlrids));        
    fullset.mcirids = randsample(mcirids,numel(mcirids));     
    
    testset.adrids = getADSet(tpd,fullset);  
    testset.nlrids = getNNset(tpd,fullset.nlrids,snlrids,1);  
    testset.mcirids = getNNset(tpd,fullset.mcirids,smcirids,2);   %#ok<STRNU>

    save('./data/test_set','testset');
       
end



% function
function tsadrids = getADSet(tpd,fullset)
     
    adrids = fullset.adrids;
    tsadrids = [];
    minpoints = 3;
    
    for i=1:length(adrids)

        % find participant
        rid = adrids(i);
        ridsat = tpd(tpd(:,1)==rid,:);
        ridsat = sortrows(ridsat,4);
        
        % find position of first DX==3
        f = find(ridsat(:,5)==3);        
        dxind = f(1);
        dxvc = ridsat(dxind,4);
                    
        % look for a DX==3 point at 48 months and check DX>0 at 36 months
        % and that there is a visit at 12 months
        dxok = false;
        if dxvc == 48 
            vcs = ridsat(:,4);
            indstart = find(vcs == 12);       
            indend = find(vcs == 36);      
            if ~isempty(indstart) && ~isempty(indend) 
                dx = ridsat(indend,5);
                dxok = dx > 0;
            end
        end
                
        if dxok

            % get period of interest            
            histat = ridsat(indstart:indend,:);
            wholebrains = histat(:,23);
            hippos = histat(:,22);
            vents = histat(:,34);
            dx = histat(end,5);
   
            % check variable support
            n1 = length(find(~isnan(wholebrains))) >= minpoints && ~isnan(wholebrains(end));
            n2 = length(find(~isnan(hippos))) >= minpoints && ~isnan(hippos(end));
            n3 = length(find(~isnan(vents))) >= minpoints && ~isnan(vents(end));
                       
            if n1 && n2 && n3                 
                %svcs = vcs(indstart:indend);            
                %disp([svcs wholebrains]);
                tsadrids = [tsadrids; rid];  %#ok<AGROW>
            end                        
                                    
        end

    end
end



% function
function srids = getNNset(tpd,nnrids,snnrids,nnid)
   
    srids = [];
    vrids = setdiff(nnrids,snnrids);
    minpoints = 3;
    
    for i=1:length(vrids)

        % find participant
        rid = vrids(i);
        ridsat = tpd(tpd(:,1)==rid,:);
        ridsat = sortrows(ridsat,4);
        
        vcs = ridsat(:,4);
       
        % set dxok if any healthy DX found at or after 7 years since
        % baseline
        dxok = false;
        ids = find(vcs >= 84);
        if ~isempty(ids)
            indstart = find(vcs == 12);       
            indend = find(vcs == 36);      
            if ~isempty(indstart) && ~isempty(indend) 
                dxes = ridsat(ids,5);
                dxok = any(dxes == nnid);
            end
        end
                
        if dxok

            % get period of interest
            histat = ridsat(indstart:indend,:);            
            wholebrains = histat(:,23);
            hippos = histat(:,22);
            vents = histat(:,34);
            
            % check variable support
            n1 = length(find(~isnan(wholebrains))) >= minpoints && ~isnan(wholebrains(end));
            n2 = length(find(~isnan(hippos))) >= minpoints && ~isnan(hippos(end));
            n3 = length(find(~isnan(vents))) >= minpoints && ~isnan(vents(end));
                       
            if n1 && n2 && n3                 
                %svcs = vcs(indstart:indend);            
                %disp([svcs wholebrains]);
                srids = [srids; rid];  %#ok<AGROW>
            end                        
                                    
        end

    end
end



