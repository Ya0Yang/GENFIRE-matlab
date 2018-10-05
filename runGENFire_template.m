%% run refinement
prefixstr = 'NiPt_Mo_181118BA_t2';
addpath('functions\')

pj_filename              = 'data\vesicle_projections.mat';
angle_filename           = 'data\vesicle_angles.mat';
results_filename         = 'data\vesicle_result.mat';
doGPU = 0;

%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                                                                         %%
%%                        Welcome to GENFIRE!                              %%
%%           GENeralized Fourier Iterative REconstruction                  %%
%%                                                                         %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Author: Alan (AJ) Pryor, Jr.
%% email:  apryor6@gmail.com
%% Jianwei (John) Miao Coherent Imaging Group
%% University of California, Los Angeles
%% Copyright (c) 2015. All Rights Reserved.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if ~isdeployed
    %addpath ../src/
   % addpath ../data/
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                          User Parameters                              %%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


PLOT_YN = 0;

GENFIRE = GENFIRE_Reconstructor();

%%% See the README for description of parameters

GENFIRE.filename_Projections = pj_filename;
GENFIRE.filename_Angles = angle_filename ;
GENFIRE.filename_Results = results_filename;

GENFIRE.numIterations = 100; 
GENFIRE.pixelSize = .5; 
GENFIRE.oversamplingRatio = 3;              % ratio = 4
GENFIRE.griddingMethod = 1;                 % griddingMethod=2 for DFT
GENFIRE.allowMultipleGridMatches = 1;
GENFIRE.constraintEnforcementMode = 3; 
GENFIRE.interpolationCutoffDistance =.1; 
GENFIRE.constraintPositivity = 1;
GENFIRE.constraintSupport = 1;
GENFIRE.ComputeFourierShellCorrelation = 0; 
GENFIRE.numBins = 50;
GENFIRE.percentValuesForRfree = 0.05;
GENFIRE.numBinsRfree = 35;
GENFIRE.doCTFcorrection = 0;
GENFIRE.CTFThrowOutThreshhold = 0;
GENFIRE.calculate_Rfree = 0;
GENFIRE.DFT_doGPU = doGPU;
GENFIRE.dt_type = 1;

%GENFIRE.particleWindowSize = [];
%GENFIRE.phaseErrorSigmaTolerance = [];
%GENFIRE.vector1 = [0 0 1];
%GENFIRE.vector2 = [0 1 0];
GENFIRE.vector3 = [1 0 0];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Begin GENFIRE

% Read data from files. The data can also be directly be fed into GENFIRE
% Class, not necessarily from file
GENFIRE = readFiles(GENFIRE);

% Check if the data is consistent, and prepare reconstruction variables
% based on given parameters
GENFIRE = CheckPrepareData(GENFIRE);

% Run GENFIRE gridding
GENFIRE = runGridding(GENFIRE); 

% Run FSC if flag is on
if GENFIRE.ComputeFourierShellCorrelation
  
    % Do not calculate R_free for FSC calculation
    calculate_Rfree_ori = GENFIRE.calculate_Rfree;
    GENFIRE.calculate_Rfree= 0;
    
    GENFIRE = runFSC(GENFIRE);
    
    % set the R_free flag back go original
    GENFIRE.calculate_Rfree=calculate_Rfree_ori;
end
    
%run reconstruction

GENFIRE = reconstruct_dr(GENFIRE);
final_rec = GENFIRE.reconstruction;

%%
figure(1);img(permute(final_rec,[2,3,1]));
figure(2);img(permute(final_rec,[1,3,2]));
figure(3);img(final_rec);


