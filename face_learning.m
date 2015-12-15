function face_learning
%  Identifier les motifs globaux, G_Patterns, présents dans toutes les
%  images de tous les visages de la base de connaissance ainsi que les
%  occurrences de ces motifs dans chaque image de chaque visage de la base.
%  
%  Chaque image est découpée en N blocs 4x4. Chaque bloc est analysé en
%  fréquences via la DCT2 dont le coefficient DC est ignoré. Ensuite chaque
%  image est réprésentée par une matrice Nx15 qui sert à la fois à
%  identifier les motifs globaux et à construire l'histogramme de ces
%  motifs pour chaque image de chaque visage de la base de connaissance.
%
% Les paramètres dont les motifs globaux, utiles à l'identification d'une
% image inconnue sont enregistrés dans le fichier 'params.mat' ainsi que
% les histogrammes de chaque image de chaque visage de la base de
% connaissance.
%
% Le même traitement peut être fait avec les coefficients DC. Mais ils sont
% ignorés pour ce projet.

%% Réinitialiser l'espace de travail
clear
clc

%% Définir le répertoire de la base de connaisssance #
db_path = uigetdir();

%% Initialiser les paramètres globaux
BSZ = 4;
QP = 22;
N_AC_PATTERNS = 35;
NB_FACES = 5;
NB_IMAGES = 5;
DC_MEAN_ALL = 0;

%% Extraire les N blocs DCT pour chaque image de chaque visage
AC_list = cell(NB_FACES,NB_IMAGES);% les matrices Nx15
dc_means = zeros(NB_FACES,NB_IMAGES);% les moyennes par image des DC
% des constantes
blocSz =  (1:BSZ) - 1;
BZ2 = floor(BSZ/2);
ACSZ = BSZ * BSZ - 1;
% pour chaque visage
for f = 1:NB_FACES
    face_path = sprintf('%s/base_connaissance/s%d',db_path,f);
    face_path
    % pour chaque image
    for fi = 1:NB_IMAGES
        fname = sprintf('%s/%d.png',face_path,fi)
        fname
        img = imread(fname);
        [h,w] = size(img);
        n_blocks = 0;
        dc_somme = 0;
        for i=1:2:(h-3)
            for j=1:2:(w-3)
                n_blocks = n_blocks+1;
                aux = dct2(img(i:(i+3),j:(j+3)));
                aux = aux(:);
                AC_list{f,fi}{n_blocks} = aux(2:16);
                dc_somme = dc_somme+aux(1);
            end
        end
        %AC_list{f,fi}(n_blocks) = tmp;
        dc_means(f,fi) =dc_somme/n_blocks;
    end
end
dc_means
DC_MEAN_ALL = mean2(dc_means);
DC_MEAN_ALL
%% Stockage des paramètres dans une structure
params = struct(...
    'BZS',BSZ,...
    'QP',QP,...
    'N_AC_PATTERNS',N_AC_PATTERNS,...
    'NB_FACES',NB_FACES,...
    'NB_IMAGES',NB_IMAGES,...
    'DC_MEAN_ALL',DC_MEAN_ALL,...
    'DIR',db_path);

%% enregistrement de la structure dans un fichier
save('params.mat','params');
disp('dct done');

%% Identification des motifs globaux, construction de leurs histogrammes
G_Patterns = [];
for f = 1:NB_FACES
    for fi = 1:NB_IMAGES
        % normalisation et quantification des AC
%% CUT HERE ====================================================================
%% CUT HERE ====================================================================
        
        % identification des motifs et comptage de leurs occurrences.
				% QAC est la matrice des vecteurs AC quantifés
        for i = 1:size(QAC,1)
%% CUT HERE ====================================================================
%% CUT HERE ====================================================================
        end
    end
end
% Conserver les N_AC_PATTERNS motifs les plus présents dans toutes les
% images de tous les visages de la base.
[~,Idx] = sort(G_Patterns(:,end),'descend');
G_Patterns = G_Patterns(Idx(1:N_AC_PATTERNS),1:(end-1));

% save G_Patterns
save('G_Patterns.mat','G_Patterns')
disp('G_Patterns done')

%% Construction des histogrammes de toutes les images de chaque visage
AC_Patterns_Histo = zeros(N_AC_PATTERNS,1);
for f = 1:NB_FACES
    for fi = 1:NB_IMAGES
%% CUT HERE ====================================================================
%% CUT HERE ====================================================================
    end
end
disp('AC_Patterns_Histo done');
