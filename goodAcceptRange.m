classdef goodAcceptRange
    % Acceptable ranges for each optimizable property
    % Values randomly chosen from these ranges are **not guaranteed** to be
    % meeting the problem's contraints. The latter is must be verified by
    % myMotor::check_constraints(). Think of it more like the domain of
    % each value.
    
    properties (SetAccess = private)

    end
    
    properties %(Constant)
        rso %= [rso_min, rso_max];              % Stator outer radius                                       
        rsi %= [0.35*rso_min, 0.65*rso_max];    % Stator inner radius                                     
        dm  %= [dm_min, dm_max];                % Magnet thickness                                   
        dc  %= [0.5*dm_min, 1.5*dm_max];        % Can thickness                                             
        ds  %= [0.3*dm_min, 0.9*dm_max];        % depth of slot opening                                     
        fm  %= [0.5, 0.9];                      % Pole fraction spanned by the magnet                       
        fp  %= [0.3, 0.9];                      % Pole fraction spanned by the iron                         
        ft  %= [0.2, 0.6];                      % Width of tooth as a fraction of pole pitch at stator ID   
        fb  %= [0.75, 1.25];                    % Back iron thickness as a fraction of tooth thickness      
    end
    
    methods
        function obj = goodAcceptRange()
            % helper variables
            rso_min = 80;
            rso_max = 80;
            dm_min = 0.06*rso_min;
            dm_max = 0.10*rso_max;
                        
            obj.rso = [77,83]; %[rso_min, rso_max];              % Stator outer radius                                       
            obj.rsi = [0.45*rso_min, 0.7*rso_max];     % Stator inner radius INSTEAD of 0.65*rso_max                                     
            obj.dm  = [dm_min, dm_max];                % Magnet thickness                                   
            obj.dc  = [0.8*dm_min, 1.2*dm_max];        % Can thickness                                             
            obj.ds  = [0.3*dm_min, 0.9*dm_max];        % depth of slot opening                                     
            obj.fm  = [0.7, 0.85];                      % Pole fraction spanned by the magnet                       
            obj.fp  = [0.5, 0.8];                      % Pole fraction spanned by the iron                         
            obj.ft  = [0.2, 0.6];                      % Width of tooth as a fraction of pole pitch at stator ID   
            obj.fb  = [0.75, 1.25];                    % Back iron thickness as a fraction of tooth thickness      
        end
    end
end