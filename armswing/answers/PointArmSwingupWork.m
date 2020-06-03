function output = PointArmSwingupWork(g,l,Tmax,Umax,s)

%-------------------------------------------------------------------%
%-------------------- Data Required by Problem ---------------------%
%-------------------------------------------------------------------%

% specify auxdata if not already done
auxdata.l = l;
auxdata.g = g;
auxdata.Tmax = Tmax;
auxdata.Umax = Umax;
auxdata.s = s;

%-------------------------------------------------------------------%
%------------------------- Variable Bounds -------------------------%
%-------------------------------------------------------------------%
% ----- PHASE 1 ----- %
i = 1;
bounds.phase(i).initialtime.lower = 0;              % scalar
bounds.phase(i).initialtime.upper = 0;              % scalar
bounds.phase(i).finaltime.lower = 1e-6;                % scalar
bounds.phase(i).finaltime.upper = Tmax;                % scalar

bounds.phase(i).initialstate.lower = [0,0];           % row vector, length = numstates
bounds.phase(i).initialstate.upper = [0,0];           % row vector, length = numstates
bounds.phase(i).state.lower = [-pi,-Inf];                  % row vector, length = numstates
bounds.phase(i).state.upper = [pi,Inf];                  % row vector, length = numstates
bounds.phase(i).finalstate.lower = [pi,0];             % row vector, length = numstates
bounds.phase(i).finalstate.upper = [pi,0];             % row vector, length = numstates

bounds.phase(i).control.lower = -Umax;                % row vector, length = numstates
bounds.phase(i).control.upper = Umax;                % row vector, length = numstates

bounds.phase(i).integral.lower = 0;                 % row vector, length = numintegrals
bounds.phase(i).integral.upper = Inf;                 % row vector, length = numintegrals

%-------------------------------------------------------------------------%
%---------------------------- Provide Guess ------------------------------%
%-------------------------------------------------------------------------%
% ----- PHASE 1 ----- %
i = 1;
guess.phase(i).time    = sort(rand(2,1));                % column vector, min length = 2
guess.phase(i).state   = 2*pi*(rand(2,2)-1/2);                % array, min numrows = 2, numcols = numstates
guess.phase(i).control = rand(2,1);                % array, min numrows = 2, numcols = numcontrols
guess.phase(i).integral = rand;               % scalar

%-------------------------------------------------------------------------%
%----------Provide Mesh Refinement Method and Initial Mesh ---------------%
%-------------------------------------------------------------------------%

setup.mesh.maxiterations = 4;

%-------------------------------------------------------------------%
%--------------------------- Problem Setup -------------------------%
%-------------------------------------------------------------------%
setup.name                        = 'PtSwingUp';
setup.functions.continuous        = @Continuous;
setup.functions.endpoint          = @Endpoint;
setup.auxdata                     = auxdata; % not necessary
setup.bounds                      = bounds;
setup.guess                       = guess;
setup.nlp.solver = 'snopt';
%setup.nlp.ipoptoptions.maxiterations = 1000;
setup.derivatives.derivativelevel = 'first';


%-------------------------------------------------------------------%
%------------------- Solve Problem Using GPOPS2 --------------------%
%-------------------------------------------------------------------%
output = gpops2(setup);
end


function phaseout = Continuous(input)
% extract data
X = input.phase(1).state;
U = input.phase(1).control;
auxdata = input.auxdata;

thetadot = X(:,2); % provide derivative
thetaddot = (U - auxdata.g*sin(X(:,1)))/auxdata.l;

phaseout.dynamics = [thetadot,thetaddot];
phaseout.integrand = sqrt((U.*X(:,2)).^2 + auxdata.s);
end

function output = Endpoint(input)
output.objective = input.phase.integral; % objective function (scalar)
end