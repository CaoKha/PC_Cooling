%============================================================
% programme simple d elements finis : dec 18 1994 / 7 avril 95  
% resolution d un probleme lineaire - stationnaire 
%============================================================
%----- parametres
% 	nnt  = nb de nds total, nelt= nb d'elem total
% 	nnel = nb de nds/elem , ndln= nb de ddl/nd, 
% 	nprel= nb de prop/elem, ndim= dimension (1 2 ou 3)
%	ndlt = nb de ddl total(=ndln*nnt)
%	ndle = nb de ddl/elem (=nnel*ndln)
%----- tables:
% 	Coordonnees :   [vcor(ndim,nnt)] 
%   Connectivites:  [conec(nelt,nnel)]
%   Prop elem:      [vprel(1,nprel)]
% 	Cond lim:     	[vcond(1,ndlt)],[cond(1,ndlt)] 
%   Sollic: 		[vfg(1,ndlt)]
%   solution:       [vsol(1,ndlt)] 
%-----  Tables elements finis: 
%   rigidite      : [vke(ndle,ndle)]
%   masse         : [vme(ndle,ndle)]
%   sollicitation : [vfe(ndle,1)]  [vkg[ndlt,ndlt)] 
%   localisation  : [kloce(1,ndle)]
%   coord. elem   : [vcore(ndim,nnel)]
%   rigid assemb  : [vkg(ndlt,ndlt)]   globale
%   masse assemb  : [vmg(ndlt,ndlt)]   globale
%-----  Lecture de donnees
%	param	: nnt,nelt,nnel,ndln,nprel  
%	maillage: vcor, conec
%	cond lim: vcond,cond
%	sollicconcentree	: vfg
%============================================================
fprintf(1,' Script de calcul blin.m : elements finis 2D stationnaire (NF04 Automne, V. 2007) \n')
fprintf(1,' \n ### Initialisation memoire et fermeture des figures \n')
clear all %memoire
close all %fenetres
%
%--- lecture des donnees
fprintf(1,' \n ### Lecture du fichier de donnees et du maillage \n')
Data_projet %donnees: changer le nom, le programme pricipal reste le meme
%
%--- affichage maillage
meshplot(vcorg,kconec);
%
%--- mise a l echelle
axis equal
%
%============================================================
%  calcul element finis     
%============================================================
%----- mettre a zero
vkg=zeros(ndlt );   % matrice rigidite  globale
vmg=zeros(ndlt );   % matrice masse  globale
vfg=zeros(ndlt,1 ); % vecteur sollicitation globale
ndle=3; % nombre maxi de noeuds par element
kloce=0*[1:ndle];   % table de localisation
%
% ----- Assemblage : construire VKG ------------------------ 
%       boucle sur les elements
fprintf(1,' \n ### Procedure d assemblage \n')
for ie=1:nelt     
    inel=2;  % nbre de noeud sur l'element (2 par defaut)   
    %
    if(ktype(ie)>=1)
        % Quel type element : T3, Neumann, Cauchy ?
        itype=mod(floor(ktype(ie)/10),10); % on extrait le chiffre des dizaines
        %
        % Son classement : proprietes 1, 2 ...?
        iclass=mod(floor(ktype(ie)),10); % on extrait le chiffre des unites
        if(iclass==0) iclass=1; end
        %
        if(itype == 3)inel=3; end ; % juste pour le T3
        %
        vcore=vcorg(kconec(ie, 1:inel),:); % coor elementaires
        %
        switch itype
            case 1               % element L2   a 2 noeuds pour Neumann
                vprel=vprel_Neumann(iclass,:);
                barre_neumann;  
            case 2               % element L2   a 2 noeuds pour Cauchy
                vprel=vprel_Cauchy(iclass,:);
                barre_cauchy;
            case 3               % element Triangle T3
                vprel=vprel_T3(iclass,:);
                ther_T3; 
        end;      
        %
        kloce=[];                    % vecteur de localisation
        for in=1:inel
            kloce=[kloce,(kconec(ie, in)-1)*ndln+(1:ndln)]; 
        end;
        % 
        %----- assemblage de vke  
        vkg(kloce,kloce)=vkg(kloce,kloce) + vke;
        %
        %----- assemblage de vme  
        vmg(kloce,kloce)=vmg(kloce,kloce) + vme;
        %
        %----- assemblage de vfe	
        vfg(kloce,1)=vfg(kloce,1) + vfe;
    end
end
%
%----- conditions aux limites de type Dirichlet
fprintf(1,' \n ### Introduction des C.L. de type Dirichlet \n')
for i=1:ndlt
    if kcond(i) == 1
        vkg(i,:)=zeros(1,ndlt);
        vkg(i,i) =1 ;
        vfg(i)= vcond(i); 
    end
end
%
%----- resolution
fprintf(1,' \n ### Resolution \n')
vsol =vkg\vfg;
%
%----- affichage de la solution 
fprintf(1,' \n ### Post-traitement \n')
figure
% degrade(vcorg,vsol,kconec)
% INFO : dernier argument de femplot =0 pour cacher le maillage !
femplot(vcorg,kconec,vsol,1);
colorbar
% isoval(vcorg,vsol,kconec,20); % affichage d'iso-lignes
axis equal
