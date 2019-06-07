%
% Purpose:
% 
%           Creates ./data/tpdata_brain702xt.mat from ./data/TADPOLE_D1_D2.csv, 
%           which is available via https://tadpole.grand-challenge.org/data/
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

% function
function tadpole_save_dataset()

 
    %addpath('../../shared/code/common');

    tadpoleD1D2File = './data/TADPOLE_D1_D2.csv';     
    
    % Features 1:12 - See tadpole_ex for more features
    keys = 'RID,D1,D2,VISCODE,DX,Month_bl,EXAMDATE,AGE,PTGENDER,SITE,PTEDUCAT,APOE4';
    cols1 = strsplit(keys,',');

    % Features 13:21
    % MOCA and ECOG are too sparse to include here
    keys = 'MMSE,CDRSB,ADAS11,ADAS13,RAVLT_immediate,RAVLT_learning,RAVLT_forgetting,RAVLT_perc_forgetting,FAQ';        
    cols2 = strsplit(keys,',');

    % Features 22:25
    keys = 'Hippocampus,WholeBrain,Entorhinal,Fusiform';
    cols3 = strsplit(keys,',');
    
    % Features 26:29   
    % Longitudenal: L,R   Cross-sectional: L,R Hippocampus volume
    keys = 'ST29SV_UCSFFSL_02_01_16_UCSFFSL51ALL_08_01_16,ST88SV_UCSFFSL_02_01_16_UCSFFSL51ALL_08_01_16,ST29SV_UCSFFSX_11_02_15_UCSFFSX51_08_01_16,ST88SV_UCSFFSX_11_02_15_UCSFFSX51_08_01_16';
    cols4 = strsplit(keys,',');

    % Features 30:33   
    % Longitudenal: L,R   Cross-sectional: L,R Entorhinal volume
    keys = 'ST24CV_UCSFFSL_02_01_16_UCSFFSL51ALL_08_01_16,ST83CV_UCSFFSL_02_01_16_UCSFFSL51ALL_08_01_16,ST24CV_UCSFFSX_11_02_15_UCSFFSX51_08_01_16,ST83CV_UCSFFSX_11_02_15_UCSFFSX51_08_01_16';
    cols5 = strsplit(keys,',');

    % Features 34:39   
    keys = 'Ventricles,Ventricles_bl,Hippocampus_bl,WholeBrain_bl,Entorhinal_bl,Fusiform_bl';
    cols6 = strsplit(keys,',');

    % Features 40:42   
    keys = 'DX_bl,FDG,ADAS13_bl';
    cols7 = strsplit(keys,',');
    
    % Features 43:57   
    keys = 'MOCA,EcogPtMem,EcogPtLang,EcogPtVisspat,EcogPtPlan,EcogPtOrgan,EcogPtDivatt,EcogPtTotal,EcogSPMem,EcogSPLang,EcogSPVisspat,EcogSPPlan,EcogSPOrgan,EcogSPDivatt,EcogSPTotal';
    cols8 = strsplit(keys,',');

    % Features 58:69  
    keys = 'MidTemp,ICV,DX,CDRSB_bl,ADAS11_bl,ADAS13_bl,MMSE_bl,RAVLT_immediate_bl,FAQ_bl,MidTemp_bl,ICV_bl,MOCA_bl'; % RAVLT_bl omitted
    cols9 = strsplit(keys,',');

    % Features 70:83   
    keys = 'EcogPtMem_bl,EcogPtLang_bl,EcogPtVisspat_bl,EcogPtPlan_bl,EcogPtOrgan_bl,EcogPtDivatt_bl,EcogPtTotal_bl,EcogSPMem_bl,EcogSPLang_bl,EcogSPVisspat_bl,EcogSPPlan_bl,EcogSPOrgan_bl,EcogSPDivatt_bl,EcogSPTotal_bl';
    cols10 = strsplit(keys,',');

    % Features 84:86       
    keys = 'FDG_bl,PIB_bl,AV45_bl';
    cols11 = strsplit(keys,',');
    
    cols = [cols1 cols2 cols3 cols4 cols5 cols6 cols7 cols8 cols9 cols10 cols11];
    
    % extra variables
    fid = fopen('./data/vars.txt');
    c = textscan(fid,'%s','Delimiter','\n');
    fclose(fid);

    cols = [cols c{:}'];

    % choose experiment tag 
    tag = 'brain702xt';           
    
    TADPOLE_Table = readtable(tadpoleD1D2File); % trying to select cols adds a corrupted line to the table
    TADPOLE_Table = processtable(TADPOLE_Table);      

    for kt=1:length(cols)
        if iscell(TADPOLE_Table.(cols{kt}))
          TADPOLE_Table.(cols{kt}) = str2double(TADPOLE_Table.(cols{kt}));              
        end
    end

    tpdata = table2array(TADPOLE_Table(:,cols)); 
    
    save(['./data/tpdata_' tag],'tpdata');

end
  

% function
function tbl=processtable(tbl)  

    nrows = height(tbl);
    vcd = zeros(nrows,1);    
    vdx = zeros(nrows,1);
    vex = zeros(nrows,1);
    for i=1:nrows
        vc = cell2mat(tbl.VISCODE(i));
        if vc(1) == 'm'
            vcd(i) = str2double(vc(2:end));
        end
        dx = cell2mat(tbl.DX(i));
        if (isempty(dx))
           vdx(i) = 0;
        elseif (dx(end-1:end) == 'NL')
            vdx(i) = 1;
        elseif (dx(end-2:end) == 'MCI')
            vdx(i) = 2;
        elseif (dx(end-7:end) == 'Dementia')
            vdx(i) = 3;
        else
            vdx(i) = -1;
        end        
                        
        %[year, month] = ymd(tbl.EXAMDATE(i));
        % EXAMDATE becomes the number of months before 1 Jan 2018
        year = str2num(tbl.EXAMDATE{i}(1:4)); %#ok<ST2NM>
        month = str2num(tbl.EXAMDATE{i}(6:7)); %#ok<ST2NM>
        vex(i) = 12*(2018-year-1) + 12-month;
        
    end
    tbl.VISCODE = vcd;
    tbl.DX = vdx;
    tbl.EXAMDATE = vex;
    tbl.PTETHCAT = numcat(tbl.PTETHCAT,{'Not Hisp/Latino','Hisp/Latino'});
    tbl.PTRACCAT = numcat(tbl.PTRACCAT,{'White','Black','Asian','More than one'});
    tbl.PTGENDER = numcat(tbl.PTGENDER,{'Male','Female'});
    tbl.PTMARRY = numcat(tbl.PTMARRY,{'Married','Never married','Divorced','Widowed'});
    tbl.DX_bl = numcat(tbl.DX_bl,{'CN','SMC','EMCI','MCI','LMCI','AD'});
end

% function
function numcol=numcat(catcol, cats)

    numcol = zeros(length(catcol),1);
    for i = 1:length(catcol)
        for j=1:length(cats)
            vx = cell2mat(catcol(i));
            if strcmpi(vx,cats{j})
                numcol(i) = j;
            end
        end
    end
end
