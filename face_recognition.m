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
NB_FACES_RECONNAISSANCE = params.NB_FACES_RECONNAISSANCE
NB_IMAGES_RECONNAISSANCE = params.NB_IMAGES_RECONNAISSANCE
DC_MEAN_ALL = params.DC_MEAN_ALL
DIR = params.DIR
%load('G_Patterns.mat');
%G_Patterns

%% extraction des blocs DCT
[h,w] = size(img);
n_blocks = 0;
dc_somme = 0;
for i=1:2:(h-3)
    for j=1:2:(w-3)
        n_blocks = n_blocks+1;
        aux = dct2(img(i:(i+3),j:(j+3)));
        %aux = aux(:);
        AC_image(n_blocks,:) = aux(2:16);
        dc_somme = dc_somme+aux(1);
    end
end

%% Normalisation et quantification
dc_means=dc_somme/size(AC_image,1);
for i=1:size(AC_image,1)
    a = AC_image(i,:)*DC_MEAN_ALL;
    b=a/dc_means/QP;
    AC_image(i,:) = round(b);
end

%% Comptage des occurrences des motifs globaux
load('G_Patterns.mat');
AC_Signatures = zeros(N_AC_PATTERNS,1);
for idx = 1:N_AC_PATTERNS
    AC_Signatures(idx) = sum(ismember(AC_image(:,1:15),G_Patterns(idx,1:15) ,'rows'));
    %AC_Signatures(idx) = find_Pattern(G_Patterns(idx,1:15),QAC);
end
%% Sélection des KPP meilleures AC_Patterns_Histo par PVH
load('AC_Patterns_Histo_List.mat');
SAD_list = zeros(NB_FACES_RECONNAISSANCE,NB_IMAGES_RECONNAISSANCE);
for f = 1:NB_FACES_RECONNAISSANCE
    for fi = 1:NB_IMAGES_RECONNAISSANCE
        AC_Patterns_Histo = AC_Patterns_Histo_List{f,fi};
        city_block = 0;
        for i=1:N_AC_PATTERNS
            val = abs(AC_Patterns_Histo(i)-AC_Signatures(i));
            city_block = city_block + val;
        end
        SAD_list(f,fi) = city_block;
    end
end
best = ones(KPP,3)*-1; % chaque ligne est <SAD,N°individu,N°profil>
for i=1:KPP  
    [ligne,indice_face] = min(SAD_list);
    [valeur,indice_image] = min(ligne);
    best(i,1) = valeur;
    best(i,3) = indice_image+5;
    best(i,2) = indice_face(indice_image);
    SAD_list(indice_face,indice_image) = intmax;
end
best = best(:,2:end);
%% visualisation des visages possiblement identifiés
if( visu)
    figure;
    subplot(1,KPP+1,1);
    imshow(img);
    for b = 1:KPP
        subplot(1,KPP+1,b+1);
        filename = sprintf('%s/base_tests/s%d/%d.png',params.DIR,best(b,1),best(b,2));
        imreco = imread(filename);
        imshow(imreco);
    end
end
end

