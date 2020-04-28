% Fichier de preparation de donnes d'un probleme de thermique
% par elements finis 2D : probleme d'une demi-ailette
%
%  Domaine ci-dessous constitue de 4 elements triangles (1-2-3-4) 
%  +1 barre_neumann (5)
%  +3 barre_cauchy (6-7-8)
%
%     Symetrie        Y  
% *   *__*__* *      |
% |   |2/|3/| |      |__ X
% |5  |/1|/4| |8
% *   *--*--* *
%      6   7
%     *--*--*
%
% Condition en flux sur Neumann : chaleur a evacue du moteur par exemple
% Condition de Cauchy : convection avec l'air ambiant a T_air=20 C

fprintf(1,'  -------- Lecture de vcorg, kconec, ktype, kprop, typ_nod \n')

% lecture des coordonnees
vcorg=[ 0  0 ; 10 0 ; 20 0; 30 0 ; 40 0 ; 0 12.5; 
        15 12.5; 35 12.5  ; 0  25; 10 25; 20 25;
        30 25; 45 5; 45 10; 55 20; 45 25 ;
        55 35  ; 37.5 37.5; 45 50; 55 50] ;
% lecture des connectivites
kconec=[1 2 6; 2 7 6; 2 3 7; 3 8 7; 3 4 8; 
        4 5 8; 6 10 9; 6 7 10; 7 11 10;
        7 8 11; 8 12 11; 5 13 8; 13 14 8; 
        8 14 16; 14 15 16; 15 17 16; 8 16 12;  
        12 16 18; 16 17 18; 18 17 19; 17 20 19;
        1 5 0; 5 13 0; 13 14 0; 14 15 0; 15 20 0;
        20 19 0; 19 12 0; 12 9 0; 9 1 0];
          %triangle
                    %segments: Neumann et Cauchy dernier noeud 0
                    

% Calcul des parametres 
[nnt, ndim]=size(vcorg);   % nombre de noeuds et dimension du domaine
nelt=size(kconec,1);    
nbarres=size(find(kconec(:,3)==0),1);  % calcul du nombre d'elements de contour
ndln=1;                 % nbre de ddl par noeud
ndlt=ndln*nnt;       % nb de ddl total
%
fprintf(1,'            + Description du maillage      \n')
fprintf(1,'            + Nombre de noeuds  : nnt  =  %5i\n',nnt)
fprintf(1,'            + Nombre d elements : nelt =  %5i\n',nelt)
fprintf(1,'            + ... dont elements barres:  =  %5i\n',nbarres)
%
% vecteur de type d elements differents
% ktype = numero logique des elements
%           chiffre des dizaines=1 (Neumann), 2(Cauchy), =3 (Triangle)
%           chiffre des unites = pour distinguer differents materiaux d'un meme type d'element
ktype=[31 31 31 31 31 31 31 31 31 31 31 32 32 32 32 32 32 32 32 32 32 11 21 21 21 11 21 21 21 12];
%
% Vecteur de proprietes physiques
fprintf(1,'  -------- Lecture des proprietes physiques\n')
% Element triangle : -1- cap. therm ro*c, -2- conductivite, -3- force volumique  ,
% -4- echange convectif de surface
vprel_T3=[   0 0.386   2700 90 0 0 % proprietes materiau 1 pour T3
             0 0.050   2700 90 0 0]; % proprietes materiau 2 pour T3
% Element barre Neumann : -1- flux impose, 
vprel_Neumann=[ 0 0 0    %  proprietes 1 pour Neumann
               -75  0 0]; % proprietes 2 pour Neumann
% Element barre Cauchy : -1- coeff convectif , -2- temperature exterieure
vprel_Cauchy=[  45  30  0    % proprietes 1 pour Cauchy
                0  0  0  ]; % proprietes 2 pour Cauchy

% conditions aux limites:  dirichlet
% cond: vecteur d indication de cond lim (1= cond, 0= pas de cond)

% vcond : sa valeur coresspondante 
fprintf(1,'  -------- Lecture des conditions de Dirichlet\n')
kcond=zeros(1,nnt);
vcond=zeros(1,nnt);


