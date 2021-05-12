# diabetes-prediction
L’objectif de ce projet est de prédire la présence de diabète chez un patient en fonction de certaines charactéristiques cliniques. 
Dans ce travail la regression logistique a était testé dont le but d'identifier les facteurs de risque associée au diabète.
***
1/ 

la base de données diabete.csv contient 9 vairiables, et 768 observations; <br/>
les variables sont les suivantes:<br/>
—Pregnancies : Nombre de fois qu'une femme peut tomber enceinte<br/>
—Glucose : Concentration en glucose plasmatique <br/>
—BloodPressure : Pression artérielle diastolique (mm Hg)<br/>
—SkinThickness : Épaisseur du pli cutané des triceps (mm)<br/>
—Insulin : Insuline sérique de 2 heures (mu U / ml)<br/>
—BMI : Indice de masse corporelle (poids en kg / (taille en m 2 )) <br/>
—DiabetesPedigreeFunction : Fonction pedigree du diabète <br/>
—Age<br/>
—Outcome: variable binaire (1=patient malade, 0=patient non malade)<br/>
"Outcome est une autre variable d'interet elle est expliquée par les autres variables".
Voici un apercu de la base: avec la commande head(diabetes)<br/>
![](images/table.png)
***
2/

Aprés avoir construit le premier modèle avec la fonction glm, on a comme résultat toutes les
variables sont significatives sauf "Age", "Insulin" et "SkinThickness". <br/>

3/
calculer l’odds-ratio:

la fonction stepAIC de la librairie MASS on s'est retrouvé avec le modéle suivant 
"Outocom" expliquée par quatre variables seulement : "Glocuse", "Pregnancies", "BMI" et "Diabe-
tesPedigreeFunction".<br/>
![](images/glm.png)

<br/> Avec la librairie forestmodel on a deduit que les variables qui sont des facteurs a risque d'avoir le diabéte sont:
"Pregnancies", "BMI" et "DiabetesPedigreeFunction".<br/>
![](images/score.png)

<br/>


4/Classification suppervisée: arbre de cart et knn
arbre de cart: le model trouvé est trés complexe avec un taux d'erreur de mauvaise prédiction est de 30%
knn : le taux d'erreur de mauvaise prediction est de 21% 

Dans les deux modeles les taux d'erreur sont trés elevés donc on peut pas prendre en considération ces deux modeles.



