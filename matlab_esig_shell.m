%
% Purpose:
%           Simple MATLAB wrapper for eSig using MATLAB py class
%
% Input     
%           
% Effects:
%
% Usage examples
%
%
% (c) 2017 Paul Moore - moorep@maths.ox.ac.uk 
%
% This software is provided 'as is' with no warranty or other guarantee of
% fitness for the user's purpose.  Please let the author know of any bugs
% or potential improvements.

%
% To use, matlab has to be called as follows
% source activate ker
% LD_PRELOAD="/usr/lib/x86_64-linux-gnu/libstdc++.so.6" matlab
%

function sig = matlab_esig_shell(deg, A, islog)  

    [~, ~, isloaded] = pyversion;
    if ~isloaded
        pyversion('/home/moorep/.virtualenvs/sci/bin/python');
    end
    
    % otherwise, the boolean is converted to a float
    islog = int8(islog);
    
    % set to 1 if esig_shell.py is modified
    if 0
        clear classes;
        mod = py.importlib.import_module('esig_shell');
        py.importlib.reload(mod);
    end
    
    % test code
    if 0
        x = 0:5; %#ok<UNRCH>
        A = [x ;sin(x); sin(x-1)]';
        deg  = 2;
    end
        
    [n,m] = size(A);  % m is the dimension
    npA = py.numpy.array(A(:).');
    siglen = int64(py.esig_shell.siglen(m,deg,islog));
    out = py.esig_shell.run_esig(npA,n,m,deg,islog);
    data = double(py.array.array('d',py.numpy.nditer(out)));
    sig = reshape(data,[1,siglen]);
    
end




