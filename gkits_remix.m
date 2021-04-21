addpath('c:\\femm42\\mfiles');
openfemm
tic

%% Initial Geometry Guess
rso = 90; 		% Stator outer radius 
rsi =0.5*rso; 	% Stator inner radius 
dm = 0.08*rso; 	% Magnet thickness 
dc =1*dm;     % Can thickness 
ds =0.6*dm;     % depth of slot opening 
fm = 0.7;      % Pole fraction spanned by the magnet 
fp = 0.6; 		% Pole fraction spanned by the iron 
ft = 0.4; 		% Width of tooth as a fraction of pole pitch at stator ID 
fb = 0.75; 		% Back iron thickness as a fraction of tooth thickness 
go = 0.5; 		% stator to magnet mechanical clearance 
hh = 25; 		% length in the into-the-page direction 
Jpk = 10.0; 	% peak current density in the winding 

%% Desired Torque
tqdes = 63.0;

%% Set up various parameters internal to the optimization
nmax = 1000;		% Maximum number of iterations in the optimization
nstall = 25;		% Number of iterations before a stall is declared
d = 0.1;			% Starting step size
dmin = 0.025;		% Step size at which it is assumed that we've converged

bestMass = 0;		% Place holder for optimal cost
stall = 0;			% Number of iterations since the last forward progress

for k = 1:nmax
    fprintf('Iteration %i; d = %f; stall = %i\n',k,d,stall);
    
    bOK = 0;
    while (bOK == 0)
        
        % If first time through the loop, evaluate the initial condition
        % Otherwise, randomly pick a nearby geometry
        if (k == 1)
            dd = 0;
        else
            dd = d;
        end
        
        % Randomly pick a new candidate geometry
        newrso = rso* (1 + dd*myrand);
        newrsi = rsi* (1 + dd*myrand);
        newdm  = dm * (1 + dd*myrand);
        newds  = ds * (1 + dd*myrand);
        newdc  = dc * (1 + dd*myrand);
        newfm  = fm * (1 + dd*myrand);
        newfp  = fp * (1 + dd*myrand);
        newft  = ft * (1 + dd*myrand);
        newfb  = fb * (1 + dd*myrand);
        newhh  = hh;
        
        bOK=1;
        
        
        % Check to make sure the candidate geometry isn't bad
        if ((newrsi + newds) > newrso) bOK=0; end
        if (newds < 0) bOK=0; end
        if (newdc < 0) bOK=0; end
        if ((newfm > 1) || (newfm<0)) bOK=0; end
        if ((newfp > 1) || (newfp<0)) bOK=0; end
        if ((newft > 1) || (newft<0)) bOK=0; end
        
        % Check on any other constraints.
        % If your constraint isn't met, just say the geometry isn't OK...
        newrro = (newrso + go + newdm + newdc); % rotor outer radius
        %		if ((2*newrro) > 25) bOK=0; end; % Example constraint on motor OD
    end
    
    % Build and analyze candidate geometry
    BuildMotor(newrso, newrsi, newdm, newdc, newds, newfm, newfp, newft, newfb, go, hh, Jpk);
    mi_saveas('temp.fem');
    mi_analyze(1);
    mi_loadsolution;
    
    % Compute torque for a fixed length to figure out how long the machine
    % needs to be to get the desired torque;
    mo_groupselectblock(1);
    tq = mo_blockintegral(22);
	newhh = max([hh*tqdes/abs(tq),30]);
%     newhh = hh*tqdes/abs(tq);
    mo_clearblock;
    
    
    %Copper Mass
    mo_groupselectblock(3);
    Copper_Mass = 0.5*mo_blockintegral(5)*newhh*8960/1000;
    mo_clearblock;
    
    %Iron Mass
    mo_selectblock((newrsi+newrso)/2,0)
    mo_selectblock(newrso+go+newdm+newdc/2,0)
    Iron_Mass = mo_blockintegral(5)*newhh*7870/1000;
    mo_clearblock;
    
    %Magnet Mass
    mo_selectblock(newrso+go+newdm/2,0)
    Magnet_Mass = 14*mo_blockintegral(5)*newhh*7650/1000;
    mo_clearblock;
    
    %Total Mass
    this_Mass = round(Magnet_Mass+Iron_Mass+Copper_Mass, 2);
    
    
    % See if this candidate is better than the previous optimum.
    % If so, this candidate is the new optimum
    stall = stall + 1;
    if (((this_Mass < bestMass) || (k==1)))
        stall = 0;
        bestMass = this_Mass;
        hh  = newhh;
        rso = newrso;
        rsi = newrsi;
        dm  = newdm;
        ds  = newds;
        dc  = newdc;
        fm  = newfm;
        fp  = newfp;
        ft  = newft;
        fb  = newfb;
        fprintf('bestMass = %f; rro = %f; rso = %f; hh = %f\n',bestMass, newrro, rso, hh);
    end
    
        % save the calculated cost function (mass)
    progress(k) = this_Mass;
    best(k) = bestMass;

    
    % Run through the 'stall logic' to see if the step size should be reduced.
    if (stall > nstall)
        d = d/2;
        stall = 0;
        if (d < dmin)
            break;
        end
    end
    
    % clean up before next iteration
    mo_close
    mi_close
    
end

% round results
rso = round(rso ,3);
rsi = round(rsi, 3);
dm = round(dm, 3);
dc = round(dc, 3);
ds = round(ds, 3);
fm = round(fm, 4);
fp = round(fp, 4);
ft = round(ft, 4);
fb = round(fb, 4);
go = round(go, 3);
hh = round(hh, 3);
Jpk = round(Jpk, 2);

%% Finished! Report the results
fprintf('Optimal volume = %f\n',bestMass);
fprintf('rso = %f\n', rso);
fprintf('rsi = %f\n', rsi);
fprintf('dm  = %f\n', dm);
fprintf('dc  = %f\n', dc);
fprintf('ds  = %f\n', ds);
fprintf('fm  = %f\n', fm);
fprintf('fp  = %f\n', fp);
fprintf('ft  = %f\n', ft);
fprintf('fb  = %f\n', fb);
fprintf('go  = %f\n', go);
fprintf('hh  = %f\n', hh);
fprintf('Jpk = %f\n', Jpk);

%plot(progress,"linewidth", 4);
hold on;
plot(best,"linewidth", 4);
title('Impact of nstall');
xlabel('Iterations') ;
ylabel('Calculated Mass') ;
xlim([0 k]);
legend("nstall = 5","nstall = 10", "nstall = 15", "nstall = 20", "nstall = 25");
closefemm
toc
