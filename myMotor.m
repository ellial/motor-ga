classdef myMotor < handle
    properties
        rso     {mustBeNumeric}
        rsi     {mustBeNumeric}
        dm      {mustBeNumeric} 	% Magnet thickness 
        dc      {mustBeNumeric}     % Can thickness 
        ds      {mustBeNumeric}     % depth of slot opening 
        fm      {mustBeNumeric}     % Pole fraction spanned by the magnet 
        fp 		{mustBeNumeric}     % Pole fraction spanned by the iron 
        ft 		{mustBeNumeric}     % Width of tooth as a fraction of pole pitch at stator ID 
        fb  	{mustBeNumeric}     % Back iron thickness as a fraction of tooth thickness 
        go  	{mustBeNumeric}     % stator to magnet mechanical clearance 
        hh  	{mustBeNumeric}     % length in the into-the-page direction 
        Jpk  	{mustBeNumeric}
        fitness {mustBeNumeric}
        mass    {mustBeNumeric}
        tqdes   {mustBeNumeric}
    end
    
    
    
    methods
        
        function obj = myMotor(rso,rsi,dm,dc,ds,fm,fp,ft,fb,go,hh,Jpk,tqdes) % constructor
            if nargin == 0 % random initialization - CHECK RANGE WITH GKITS
                           % wtf is newrso on original gkitscode  
                % try random initialization until you meet the constraints
                obj = randinit(obj);
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
                obj.go  = go;
                obj.hh  = hh;
                obj.Jpk = Jpk;          
                obj.tqdes = tqdes;
            end
        end
        
        function mutated = mutate(self, p_m, prop_arr)
            if(randi([1,100]) < (100*p_m))   
                while ~(self.check_constraints())
                    pos = randi([1,length(prop_arr)]); 
                    mutated_param = prop_arr(pos);
                    self.(mutated_param) = randi([1,10]); %check range with gkits

                end
            end
        end
         
        
        function totalMass = compute_mass(self)
            BuildMotor(self.rso, self.rsi, self.dm, self.dc, self.ds, ...
                self.fm, self.fp, self.ft, self.fb, self.go, self.hh, self.Jpk);
            mi_saveas('temp.fem');
            try
                mi_analyze(1);
            catch
                self = randinit(self);
                disp(self.rso);
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
            self.fitness = compute_mass(self);
            
         
        end

    end
    
    methods (Access = private)       
        function obj = randinit(obj)
            while true 
                        obj.rso = rand();
                        obj.rsi = rand();
                        obj.dm  = rand();
                        obj.dc  = rand();
                        obj.ds  = rand();
                        obj.fm  = rand();
                        obj.fp  = rand();
                        obj.ft  = rand();
                        obj.fb  = rand();
                        obj.go  = rand();
                        obj.hh  = rand();
                        obj.Jpk = rand();
                        obj.tqdes = rand();

                        if (obj.check_constraints()) 
                            break;
                        end
            end
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
        end
        
    end
    
end


 
