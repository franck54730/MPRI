function face_learning()
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
NB_FACES_RECONNAISSANCE = 20;
NB_IMAGES_RECONNAISSANCE = 5;
DC_MEAN_ALL = 0;

%% Extraire les N blocs DCT pour chaque image de chaque visage
AC_list = cell(NB_FACES_RECONNAISSANCE,NB_IMAGES_RECONNAISSANCE);% les matrices Nx15
AC_list_after = cell(NB_FACES_RECONNAISSANCE,NB_IMAGES_RECONNAISSANCE);%apres calcul
dc_means = zeros(NB_FACES_RECONNAISSANCE,NB_IMAGES_RECONNAISSANCE);% les moyennes par image des DC
% des constantes
blocSz =  (1:BSZ) - 1;
BZ2 = floor(BSZ/2);
ACSZ = BSZ * BSZ - 1;

% pour chaque visage
for f = 1:NB_FACES_RECONNAISSANCE
    face_path = sprintf('%s/base_connaissance/s%d',db_path,f);
    % pour chaque image
    for fi = 1:NB_IMAGES_RECONNAISSANCE
        fname = sprintf('%s/%d.png',face_path,fi);
        img = imread(fname);
        [h,w] = size(img);
        n_blocks = 0;
        dc_somme = 0;
        for i=1:2:(h-3)
            for j=1:2:(w-3)
                n_blocks = n_blocks+1;
                aux = dct2(img(i:(i+3),j:(j+3)));
                %aux = aux(:);
                dc_somme = dc_somme+aux(1,1);
                tmp(n_blocks, 1:ACSZ) = aux(2:16);
            end
        end
        AC_list{f,fi} = tmp;
        dc_means(f,fi) = dc_somme/n_blocks;
    end
end
DC_MEAN_ALL = mean2(dc_means);
%% Stockage des paramètres dans une structure
params = struct(...
    'BZS',BSZ,...
    'QP',QP,...
    'N_AC_PATTERNS',N_AC_PATTERNS,...
    'NB_FACES',NB_FACES,...
    'NB_IMAGES',NB_IMAGES,...
    'NB_FACES_RECONNAISSANCE',NB_FACES_RECONNAISSANCE,...
    'NB_IMAGES_RECONNAISSANCE',NB_IMAGES_RECONNAISSANCE,...
    'DC_MEAN_ALL',DC_MEAN_ALL,...
    'DIR',db_path);

%% enregistrement de la structure dans un fichier
save('params.mat','params');
disp('dct done');

%% Identification des motifs globaux, construction de leurs histogrammes
G_Patterns = [];
for f = 1:NB_FACES_RECONNAISSANCE
    for fi = 1:NB_IMAGES_RECONNAISSANCE
        % normalisation et quantification des AC
        List_PatternAC_current_image = AC_list{f,fi};
        h= size(AC_list{f,fi},1);
        for i = 1:h
            for j = 1:ACSZ
                a = List_PatternAC_current_image(i,j)*DC_MEAN_ALL;
                b=a/dc_means(f,fi)/QP;
                tmp(i,j) = round(b);
            end
            QAC(i,1:ACSZ)=tmp(i,1:ACSZ);
        end
        AC_list_after{f,fi} = QAC; 
    end
end


% identification des motifs et comptage de leurs occurrences.
        % QAC est la matrice des vecteurs AC quantifés
for f = 1:NB_FACES
    for fi = 1:NB_IMAGES
        if(f==1 && fi == 1)
            G_Patterns(1,1:ACSZ) = AC_list_after{f,fi}(1,1:ACSZ);
            G_Patterns(1,ACSZ+1) = 1;
        else
            for i = 1:size(AC_list_after{f,fi},1)
                findtab = ismember(G_Patterns(:,1:ACSZ), AC_list_after{f,fi}(i,1:ACSZ),'rows');
                somme = sum(findtab);
                index = find(findtab,1);
                %G_Patterns(size(G_Patterns,1),1:ACSZ) = QAC{i}(1:ACSZ);
                if somme > 0
                    G_Patterns(index,ACSZ+1) = G_Patterns(index,ACSZ+1)+1;
                else
                    G_Patterns(size(G_Patterns,1)+1,1:ACSZ) = AC_list_after{f,fi}(i,1:ACSZ);
                    G_Patterns(size(G_Patterns,1)+1,ACSZ+1) = 1;
                end
            end
        end
    end
end
% Conserver les N_AC_PATTERNS motifs les plus présents dans toutes les
% images de tous les visages de la base.
[~,Idx] = sort(G_Patterns(:,end),'descend');
G_Patterns = G_Patterns(Idx(1:N_AC_PATTERNS),1:(end));
figure;
plot(G_Patterns)

% save G_Patterns
save('G_Patterns.mat','G_Patterns');
disp('G_Patterns done');

%% Construction des histogrammes de toutes les images de chaque visage
AC_Patterns_Histo_List = cell(NB_FACES_RECONNAISSANCE,NB_IMAGES_RECONNAISSANCE);
AC_Patterns_Histo = zeros(N_AC_PATTERNS,1);
for f = 1:NB_FACES_RECONNAISSANCE
    for fi = 1:NB_IMAGES_RECONNAISSANCE
        for i = 1:N_AC_PATTERNS
           AC_Patterns_Histo(i) = sum(ismember(AC_list_after{f,fi}(:,1:15), G_Patterns(i,1:ACSZ),'rows'));
        end
        AC_Patterns_Histo_List{f,fi} = AC_Patterns_Histo;
    end
end
figure;
%save AC_Patterns_Histo_List
save('AC_Patterns_Histo_List.mat','AC_Patterns_Histo_List');
disp('AC_Patterns_Histo_List done');
