classdef myMotor
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
    end
    
    
    methods
    
        function obj = myMotor(rso,rsi,dm,dc,ds,fm,fp,ft,fb,go,hh,Jpk) % constructor
            if nargin == 0 % random initialization - CHECK RANGE WITH GKITS
                           % wtf is newrso on original gkitscode  
                % try random initialization until you meet the constraints
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
                    
                    if (obj.check_constraints()) 
                        break;
                    end
                end
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
            end
        end
        
        function mutated = mutate(self, p_m)
            if(randi([1,100]) < (100*p_m))   
                while ~(self.check_constraints())
                    prop_arr = ["rso","rsi","dm","dc","ds","fm","fp","ft","fb","go","hh","Jpk"];
                    pos = randi([1,14]); %num_of_param = 14
                    mutated_param = prop_arr(pos);
                    self.(mutated_param) = randi([1,10]); %check range with gkits

                end
            end
        end
         
        
        function totalMass = compute_mass(self)
            BuildMotor(self.rso, self.rsi, self.dm, self.dc, self.ds, ...
                self.fm, self.fp, self.ft, self.fb, self.go, self.hh, self.Jpk);
            mi_saveas('temp.fem');
            mi_analyze(1);
            mi_loadsolution;

            % Compute torque for a fixed length to figure out how long the machine
            % needs to be to get the desired torque;
            mo_groupselectblock(1);
            tq = mo_blockintegral(22);
            self.hh = max([self.hh*tqdes/abs(tq),30]);
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
        
        function fit = eval_fitness(self)
            fit = calc_mass(self);
        end

    end
    
    methods (Access = private)       
        
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

function [ch1,ch2] = crossover(parent1, parent2 ,p_c)
    %crossover ellis
    pos = randi([1,14]);
    prop_arr = ["rso","rsi","dm","dc","ds","fm","fp","ft","fb","go","hh","Jpk"];
    %check constraints
    
    ch1 = myMotor();  
    ch2 = myMotor();
    %child1 crossover
    if(randi([1,100])< 100*p_c)
        while ~(ch1.check_constraints())
            for i=1:pos
               ch1.(prop_arr(i)) = parent1.(prop_arr(i)); 
            end   
            for i = pos:len(prop_arr)
               ch1.(prop_arr(i)) = parent2.(prop_arr(i)); 
            end
        end
    end
    %child2 crossover
    if(randi([1,100])< 100*p_c)
        while ~(ch2.check_constraints())
            for i=1:pos
               ch1.(prop_arr(i)) = parent2.(prop_arr(i)); 
            end   
            for i = pos:len(prop_arr)
               ch1.(prop_arr(i)) = parent1.(prop_arr(i)); 
            end
        end
    end
    %return list ch1,ch2
end
 
 
