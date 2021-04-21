classdef myMotor
    properties
        rso     {mustBeNumeric}
        rsi     {mustBeNumeric}
        dm      {mustBeNumeric} 	% Magnet thickness 
        dc      {mustBeNumeric}    % Can thickness 
        ds      {mustBeNumeric}     % depth of slot opening 
        fm      {mustBeNumeric}     % Pole fraction spanned by the magnet 
        fp 		{mustBeNumeric}% Pole fraction spanned by the iron 
        ft 		{mustBeNumeric}% Width of tooth as a fraction of pole pitch at stator ID 
        fb  	{mustBeNumeric}	% Back iron thickness as a fraction of tooth thickness 
        go  	{mustBeNumeric}	% stator to magnet mechanical clearance 
        hh  	{mustBeNumeric}	% length in the into-the-page direction 
        Jpk  	{mustBeNumeric}
        fitness {mustBeNumeric}
        mass    {mustBeNumeric}
    
    end
    
    
    methods
    
        function obj = myMotor(rso,rsi,dm,dc,ds,fm,fp,ft,fb,go,hh,Jpk) % constructor
            
        end
        function mutated = mutate(p_m)
           while not check_constraints()
               %do stuff
           end
        end
        function bOK = check_constraints()
            bOK = 1;
            if ((newrsi + newds) > newrso) bOK=0; end
            if (newds < 0) bOK=0; end
            if (newdc < 0) bOK=0; end
            if ((newfm > 1) || (newfm<0)) bOK=0; end
            if ((newfp > 1) || (newfp<0)) bOK=0; end
            if ((newft > 1) || (newft<0)) bOK=0; end
         
        end
        
        function obj = random_init()
        
        end
        
        function fit = eval_fitness()
            
        end
    end
    
end
 
function crossover(motor1,motor2,p_c)
    %crossover ellis
    pos = random(1,num_of_params);
    %check constraints
    %return tuple ch1,ch2
end
 
 
