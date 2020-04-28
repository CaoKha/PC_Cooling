% Fichier general de preparation des donnees d'un probleme 2D par elements finis 2D 
%
%--- Identification et lecture  du maillage genere par Gmsh
% vcorg = table des coordonnees nodales
% kconec = table des connectivites
% ktype = numero logique des elements
%           chiffre des dizaines=1 (Neumann), 2(Cauchy), =3 (Triangle)
%           chiffre des unites = pour distinguer differents materiaux d'un meme type d'element
% typ_nod = numero logique des noeuds du contour (identique aux elements de contour)
%
fprintf(1,'  -------- Lecture de vcorg, kconec, ktype, typ_nod \n')
nom_du_maillage='contour_projet.geo.msh';
[vcorg, kconec, ktype, typ_nod] = get_mesh(nom_du_maillage);

%--- nbre de noeuds et dimension du probleme
[nnt, ndim]=size(vcorg);
nelt=size(kconec,1);    
nbarres=size(find(kconec(:,3)==0),1);  % calcul du nombre d'elements de contour
ndln=1;                 % nbre de ddl par noeud
ndlt=ndln*nnt;       % nb de ddl total
%
fprintf(1,'            + Description du maillage genere par Gmsh : %s    \n',nom_du_maillage)
fprintf(1,'            + Nombre de noeuds  : nnt  =  %5i\n',nnt)
fprintf(1,'            + Nombre d elements : nelt =  %5i\n',nelt)
fprintf(1,'            + ... dont elements barres:  =  %5i\n',nbarres)
%
% Vecteur de proprietes physiques : plusieurs mat?riaux possibles !
%
% Element triangle : -1- cap. therm ro*c, -2- conductivite, -3- force volumique  ,
% -4- echange convectif de surface
% Element barre Neumann : -1- flux impose, 
% Element barre Cauchy : -1- coeff convectif , -2- temperature exterieure 
% 
fprintf(1,'  -------- Lecture des proprietes physiques\n')
vprel_T3=[    3434.2 0.386 2700 90 0 0    % proprietes materiau 1 pour T3
              3750  0.050 2700 90 0 0]; % proprietes materiau 2 pour T3
vprel_Neumann=[ 0 0 0    %  proprietes 1 pour Neumann
                -75 0 0]; % proprietes 2 pour Neumann
vprel_Cauchy=[  45 30 0    % proprietes 1 pour Cauchy
                0  0  0  ]; % proprietes 2 pour Cauchy
%
% conditions aux limites:  Dirichlet
% cond: vecteur d indication de cond lim (1= cond, 0= pas de cond)
% vcond : sa valeur coresspondante 
fprintf(1,'  -------- Lecture des conditions de Dirichlet\n')
kcond=zeros(1,nnt);
vcond=zeros(1,nnt);
% Retirer les commentaires ci-dessous si besoin d imposer des conditions de Dirichlet
for i=1:nnt
     switch typ_nod(i)
         case {1} % condition de Dirichlet associee au No logique '1'
             kcond(i)=1; vcond(i)=0.5;  % modifier les valeurs en consequences
         case {2}	% condition de Dirichlet associee au No logique '2'
             kcond(i)=1; vcond(i)=2.5;  % modifier les valeurs en consequences
     end
 end

