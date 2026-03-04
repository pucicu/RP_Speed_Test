%% speed test

%% enable rp tools
% first clone from https://github.com/pucicu/rp to subfolder rp before you can use it
addpath('../Libs/rp')

%% results file
timeResultsfile = '../Results/time_matlab_vector.csv';
rqaResultsfile = '../Results/rqa_matlab_vector.csv';

%% data file
datafile = '../Libs/roessler.csv';

%% import data
x = load(datafile);

%% length of time series for RQA calculation test
N = round(10.^(log10(200):.075:log10(200000)));


%% calculate RP and RQA for different length
tspanRP = zeros(length(N), 1);  % result vector computation time
tspanRQA = zeros(length(N), 1); % result vector computation time
mRQA = NaN * ones(length(N), 6);     % result vector RQA average
vRQA = NaN * ones(length(N), 6);     % result vector RQA variance
K = 10;                         % number of runs (for averaging time)
maxT = 600;                     % stop calculations if maxT is exceeded
m = 3;                          % embedding dimension
tau = 6;                        % embedding delay
e = 1.2;                        % recurrence threshold
lmin = 2;                       % minimal line length

xe = embed(x(1:1+N(10)-1,1), m, tau);
R = rp(xe, e, 'fix', 'euc', 'matlabvector'); 
Q = rqa(R, lmin, 1, 'non');

for i = 1:length(N)
    tRP_ = 0;
    tRQA_ = 0;
    RQA_ = zeros(K, 6);
    xe = embed(x(1:1+N(i)-1,1), m, tau);
    for j = 1:K
        tic
        %R = squareform(pdist(xe) <= e);
        R = rp(xe, e, 'fix', 'euc', 'matlabvector'); % a bit slower than previous line because of some testing expressions
        tRP_ = tRP_ + toc;
        tic
        Q = rqa(R, lmin, 1, 'non');
        tRQA_ = tRQA_ + toc;
        RQA_(j,:) = Q([1 2 3 5 6 7]);
    end
    tspanRP(i) = tRP_ / K;   % average calculation time
    tspanRQA(i) = tRQA_ / K; % average calculation time
    mRQA(i,:) = mean(RQA_);  % average RQA
    vRQA(i,:) = var(RQA_);   % variance RQA
    disp(sprintf('%i: %f %f', N(i), tspanRP(i), tspanRQA(i)))
    
    % save results
    ex = [N(:) tspanRP(:) tspanRP(:)+tspanRQA(:)]; % RQA needs calculated RP
    save(timeResultsfile,'ex','-ascii','-tabs')
    ex = [N(:) mRQA vRQA];
    save(rqaResultsfile,'ex','-ascii','-tabs')

    if tspanRP(i) >= maxT & tspanRQA(i) >= maxT, break, end
    
end

exit
