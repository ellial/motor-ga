classdef myMotor < matlab.mixin.Copyable
    properties
        name
        rso     {mustBeNumeric}
        rsi     {mustBeNumeric}
        dm      {mustBeNumeric} 	% Magnet thickness 
        dc      {mustBeNumeric}     % Can thickness 
        ds      {mustBeNumeric}     % depth of slot opening 
        fm      {mustBeNumeric}     % Pole fraction spanned by the magnet 
        fp 		{mustBeNumeric}     % Pole fraction spanned by the iron 
        ft 		{mustBeNumeric}     % Width of tooth as a fraction of pole pitch at stator ID 
        fb  	{mustBeNumeric}     % Back iron thickness as a fraction of tooth thickness 
        go  = 0.5;                  % stator to magnet mechanical clearance 
        hh  = 25;                   % length in the into-the-page direction 
        Jpk = 10.0;                 % peak current density in the winding                  
        fitness {mustBeNumeric}
        mass    {mustBeNumeric}
        tqdes   {mustBeNumeric}
    end
    
    methods
        
        function obj = myMotor(rso,rsi,dm,dc,ds,fm,fp,ft,fb) % constructor
            global epoch;
            global id;
            obj.name = id;
            if nargin == 0 % random initialization - CHECK RANGE WITH GKITS
                           % wtf is newrso on original gkitscode  
                % try random initialization until you meet the constraints
                obj = randinit(obj);
                %epoch_str = rso;
                
            else % initialize on params
                obj.rso = rso;
                obj.rsi = rsi;
                obj.dm  = dm;
                obj.dc  = dc;
                obj.ds  = ds;
                obj.fm  = fm;
                obj.fp  = fp;
                obj.ft  = ft;
                obj.fb  = fb;
            end
            fprintf("motor initialized on epoch: %d\n", epoch);
        end
        
        function mutate(self, p_m, prop_arr)
            global acceptRange;
            %self.(prop_arr(1)) = 42;  
            if(randi([1,100]) < (100*p_m)) 
                pos = randi([1,length(prop_arr)]); 
                mutated_param = prop_arr(pos);
                before = self.(mutated_param);
                while 1
                    self.(mutated_param) = self.randrange(acceptRange.(mutated_param)); %check range with gkits
                    if (self.check_constraints()) break; end
                end
                after = self.(mutated_param);
                fprintf("        %s gene mutated from %f to %f\n", mutated_param, before, after);
            end
        end
         
        function totalMass = compute_mass(self)
            BuildMotor(self.rso, self.rsi, self.dm, self.dc, self.ds, ...
                self.fm, self.fp, self.ft, self.fb, self.go, self.hh, self.Jpk);
            mi_saveas('temp.fem');
            mi_probdef(0,'millimeters','planar',1e-008,self.hh,25,0) %some solver parameters to speed up solutions proccess
            mi_smartmesh(0);                                         %some solver parameters to speed up solutions proccess
            try
                mi_analyze(1);
            catch
                disp("        motor found defective after analysis, reinitializing...");
                self = randinit(self);
                totalMass = compute_mass(self);
                return
            end
            mi_loadsolution;       
            
            
            % Compute torque for a fixed length to figure out how long the machine
            % needs to be to get the desired torque;
            mo_groupselectblock(1);
            tq = mo_blockintegral(22);
            self.hh = max([self.hh*self.tqdes/abs(tq),30]);
            %newhh = hh*tqdes/abs(tq);
            mo_clearblock;

            %Copper Mass
            mo_groupselectblock(3);
            Copper_Mass = 0.5*mo_blockintegral(5)*self.hh*8960/1000;
            mo_clearblock;

            %Iron Mass
            mo_selectblock((self.rsi+self.rso)/2,0)
            mo_selectblock(self.rso+self.go+self.dm+self.dc/2,0)
            Iron_Mass = mo_blockintegral(5)*self.hh*7870/1000;
            mo_clearblock;

            %Magnet Mass
            mo_selectblock(self.rso+self.go+self.dm/2,0)
            Magnet_Mass = 14*mo_blockintegral(5)*self.hh*7650/1000;
            mo_clearblock;

            %Total Mass
            totalMass = round(Magnet_Mass+Iron_Mass+Copper_Mass, 2);
        end
        
        function eval_fitness(self)
            self.mass = compute_mass(self);
            self.fitness = 1/self.mass;
        end
        
        function bOK = check_constraints(self)
            bOK = 1;
            if ((self.rsi + self.ds) > self.rso) 
                bOK=0; end
            if (self.ds < 0) 
                bOK=0; end
            if (self.dc < 0) 
                bOK=0; end
            if ((self.fm > 1) || (self.fm<0)) 
                bOK=0; end
            if ((self.fp > 1) || (self.fp<0)) 
                bOK=0; end
            if ((self.ft > 1) || (self.ft<0)) 
                bOK=0; end    
            
            global total_ch_calls;
            global failed_ch_calls;
            total_ch_calls = total_ch_calls + 1;
            if (bOK == 0) failed_ch_calls = failed_ch_calls + 1; end
        end
         
    end
    
    methods (Access = private)       
        function obj = randinit(obj)
            global acceptRange;
            while true 
                        obj.rso = obj.randrange(acceptRange.rso);
                        obj.rsi = obj.randrange(acceptRange.rsi);
                        obj.dm  = obj.randrange(acceptRange.dm);
                        obj.dc  = obj.randrange(acceptRange.dc);
                        obj.ds  = obj.randrange(acceptRange.ds);
                        obj.fm  = obj.randrange(acceptRange.fm);
                        obj.fp  = obj.randrange(acceptRange.fp);
                        obj.ft  = obj.randrange(acceptRange.ft);
                        obj.fb  = obj.randrange(acceptRange.fb);
                        
                        if (obj.check_constraints()) 
                            break;
                        end
            end
        end
        
        function y = randrange(~, r)
            A = r(2)-r(1);
            y = A*rand+r(1);         
        end
    end
    
end


 
