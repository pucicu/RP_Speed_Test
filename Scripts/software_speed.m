%% speed test

%% enable rp tools
% first clone from https://github.com/pucicu/rp to subfolder rp before you can use it
addpath('../Libs/rp')

%% results file
filename = '../Results/time_matlab_vector.csv';

%% the Roessler ODE
r = @(t,x) [-(x(2) + x(3)); 
            x(1) + 0.25 * x(2);
            0.25 + (x(1) - 4) * x(3)];

%% solve the ODE        
options = odeset('RelTol',1e-8,'AbsTol',1e-10);
[t x] = ode45(r,[0:0.05:2500],[0;0;0]);

%% skip first 1000 points
t(1:1000) = []; x(1:1000,:) = [];

%% length of time series for RQA calculation test
N = round(10.^(log10(200):.075:log10(200000)));
N = round(10.^(log10(200):.075:log10(10000)));


%% calculate RP and RQA for different length
tspanRP = zeros(length(N), 1); % result vector computation time
tspanRQA = zeros(length(N), 1); % result vector computation time
K = 10; % number of runs (for averaging time)
maxT = 600; % stop calculations if maxT is exceeded

for i = 1:length(N)
    tRP_ = 0;
    tRQA_ = 0;
    xe = embed(x(1:1+N(i)-1,1), 3, 6);
    for j = 1:K
        %R = squareform(pdist(xe) <= 1.2);
        tic
        R = rp(xe, 1.2, 'fix', 'euc', 'matlabvector'); % a bit slower than previous line because of some testing expressions
        tRP_ = tRP_ + toc;
        tic
        Q = rqa(R, 2, 1, 'non');
        tRQA_ = tRQA_ + toc;
    end
    tspanRP(i) = tRP_ / K; % average calculation time
    tspanRQA(i) = tRQA_ / K; % average calculation time
    disp(sprintf('%i: %f %f', N(i), tspanRP(i), tspanRQA(i)))
    
    % save results
    ex = [N(:) tspanRP(:) tspanRQA(:) tspanRP(:)+tspanRQA(:)];
    save(filename,'ex','-ascii','-tabs')

    if tspanRP(i) + tspanRQA(i) >= maxT, break, end
    
end

exit
