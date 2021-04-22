if ispc %windows
    addpath('c:\\femm42\\mfiles'); 
    savepath;
else %linux - see https://github.com/thalesmaoa/femmLinuxOctaveMatlab
    addpath('/home/c/.wine/drive_c/femm42/mfiles'); 
    s = warning('error', 'MATLAB:SavePath:PathNotSaved'); % set warning to temporarily issue errors (exceptions)
    try         
        savepath;
    catch identifier
        if strcmpi(identifier.identifier, 'MATLAB:SavePath:PathNotSaved')
            system('sudo chmod 666 /usr/local/MATLAB/R2020b/toolbox/local/pathdef.m');
            savepath;
        end
    end
    warning(s); % restore the warning back to its previous (non-error) state
end