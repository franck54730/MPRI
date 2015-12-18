function best = face_recognition( img, KPP )
% identification dans la base de connaissance des plus proches images (KPP)
% de l'image à identifier (img)

if(nargin < 2)
    KPP = 3;
end
if(nargin < 3)
    visu = true;
end
 
%% lecture des paramètres globaux
load('params.mat'); % params est une structure (cf. face_learning)
BZS = params.BZS
QP = params.QP
N_AC_PATTERNS = params.N_AC_PATTERNS
NB_FACES = params.NB_FACES
NB_IMAGES = params.NB_IMAGES
DC_MEAN_ALL = params.DC_MEAN_ALL
DIR = params.DIR
%load('G_Patterns.mat');
%G_Patterns

%% extraction des blocs DCT
[h,w] = size(img);
n_blocks = 0;
width_blocks = floor((w-1)/2);
height_blocks = floor((h-1)/2);
A = zeros(height_blocks,width_blocks);
for i=1:1:height_blocks
    for j=1:1:height_blocks
        n_blocks = n_blocks+1;
        dct = dct2(img(i:(i+3),j:(j+3)));
        A(i,j) = dct;
    end
end

%% Normalisation et quantification


%% Comptage des occurrences des motifs globaux
load('G_Patterns.mat');
AC_Signatures = zeros(N_AC_PATTERNS,1);
for idx = 1:N_AC_PATTERNS
    AC_Signatures(idx) = find_Pattern(G_Patterns(idx,:),QAC);
end

%% Sélection des KPP meilleures AC_Patterns_Histo par PVH
best = ones(KPP+1,3)*-1; % chaque ligne est <SAD,N°individu,N°profil>
%% CUT HERE ====================================================================
%% CUT HERE ====================================================================
best = best(1:(end-1),2:end);

%% visualisation des visages possiblement identifiés
if( visu)
    figure;
    subplot(1,KPP+1,1);
    imshow(img);
    for b = 1:KPP
        subplot(1,KPP+1,b+1);
        filename = sprintf('%s/s%d/%d.png',...
            params.DIR,best(b,1),best(b,2));
        imreco = imread(filename);
        imshow(imreco);
    end
end
end

