%
% Purpose:
%           Creates AD, NL and MCI sets.
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

function create_three_sets()
    
    % choose data tag 
    datatag = 'brain702xt';                  
    load(['./data/tpdata_' datatag],'tpdata');
    tpd = tpdata;
    clear tpdata;
   
    rids = unique(tpd(:,1));         

    % find AD set    
    adrids = [];
    nlrids = [];
    mcirids = [];
    for i=1:length(rids)
        rid = rids(i);
        dxes = tpd(tpd(:,1)==rid,5);
        dxes(dxes==0) = [];
        if any(dxes==3) 
            adrids = [adrids; rid];  %#ok<*AGROW>
        elseif (dxes==2)
            mcirids = [mcirids; rid]; 
        elseif (dxes==1)
            nlrids = [nlrids; rid]; 
        else
            1;
        end
    end
    save('./data/three_sets','adrids','mcirids','nlrids');

end