#***********  Auteur: Syhem-MS  ***********#
#*********** Prédiction de diabéte chez un individu

#***Chargement des librairies
library(nnet)
library(broom)
installed.packages("ggplot2")
library(ggplot2)
library(GGally)
library(forestmodel)
library(carData)
library(effects)
library(ggeffects)

###### 1/ Analyse statistique de la base de données

diabete=read.csv("/home/users/etudiant/Téléchargements/code/diabetes.csv", header=TRUE)
diabete
M=as.matrix(diabete)
M # transformation de la base en une matrice
dim(diabete)
d0<-diabete[which(diabete$Outcome==0),-9] #-7 pour enlever la variable Outcome
dim(d0) 
d1<-diabete[which(diabete$Outcome==1),-9] #-7 pour enlever la variable Outcome
dim(d1) 
#***Correlation
correlation=cor(M)
correlation
symnum(correlation, abbr.colnames=FALSE)

library(corrplot)
#install.packages("corrplot")
corrplot(correlation, method="color")
hist(diabete$Outcome, col="pink", main="partition des malades et des non malades")
xtabs(Outcome~Age, data=diabete) 


############ 2/faire la regression logistique avec glm 

y=as.factor(diabete$Outcome)   #une variable qui prends des valeures enre 0 et 1
modele=glm(y~Age+Pregnancies+Glucose+BloodPressure+SkinThickness+Insulin+BMI+DiabetesPedigreeFunction,data=diabete,family=binomial(link="logit"))

############# 3/ affichage des résultats du modéle
summary(modele)

########################  4/ calcul  des odds-ratio et leurs intervalles de confiances
modele$coefficients       ##coefficients beta chapeaux
odd_ratio=exp(modele$coefficients )    #reccuperer les odds-ratio
l=confint(modele)              #affichage des intervalles de confiances
g=cbind(odd_ratio,l)


#######################################################################################################
library(broom)
tmp <- tidy(modele, conf.int = TRUE, exponentiate = TRUE)
str(tmp)



##################################  avec forestmodel  
#install.packages("forestmodel")
library(forestmodel)
forest_model(modele)


########################## 5/ réduire le nombre de variables soit avec la fonction stepAIC ou a la main
#*** methode 1)
library(MASS)
reg=stepAIC(modele,scale = 0,k=2) #Age + Pregnancies + Glucose + BloodPressure + Insulin + BMI + 
#DiabetesPedigreeFunction (se sont les variables qui influance le plus sur la maladie du diabéte

#***methode 2)
# autre methode on fixe un seuil a 0.05 puis on fait la regression et avec summary on va s interesser aux valeures propres des variables 
#et on enleve a chaque fois la variable qui a la plus grande valeure propre  puis on refait la regression pour ce nouveau model
#et on repete le processus jusqu'a l'obtention d'un modéle avec que des variables significatives

reg1=glm(y~Age+Pregnancies+Glucose+BloodPressure+Insulin+BMI+DiabetesPedigreeFunction,data=diabete,family=binomial(link="logit"))
summary(reg1)
reg2=glm(y~Age+Pregnancies+Glucose+BloodPressure+BMI+DiabetesPedigreeFunction,data=diabete,family=binomial(link="logit"))
summary(reg2)
reg3=glm(y~+Pregnancies+Glucose+BloodPressure+BMI+DiabetesPedigreeFunction,data=diabete,family=binomial(link="logit"))
summary(reg3)

################################ 6/ analyse des résultats avec ggeffect 
#install.packages("ggeffects")
library(ggeffects)
#install.packages("effects")
library(effects)
ggeffect(modele, "Age")
ggeffect(modele, "Pregnancies")
ggeffect(modele, "Glucose")
ggeffect(modele, "BloodPressure ")
ggeffect(modele, "Insulin")
ggeffect(modele, " BMI")
ggeffect(modele, "DiabetesPedigreeFunction")
plot(allEffects(modele))
############################### 7/prediction 

pred.diab=predict(modele,type="response") 
pred.diab#afficher la probabilité de chaque individu  associée a la variable outcome
#install.packages("pROC")
library(pROC) #courbe roc 
plot(roc(y,pred.diab),col="blue")
legend(0.2, 0.4, legend=c("courbe roc"),
      col=c("blue"), lty=1.0:0.0, cex=0.8)
ggeffect(modele)
plot(ggeffect(modele))
############################ fin ###################
#install.packages("caret")
library(caret)
indtrain <- createDataPartition(diabete$Outcome,p=0.8,list=F)
dtrain <- diabete[indtrain,]
dtest <- diabete[-indtrain,]

# Fonction qui calcule le taux d'erreur
tx_er <- function(pred,vrais){
  mc <- table(pred,vrais)
  1 - sum(diag(mc))/sum(mc)
}

### CART
# Arbre max

library(rpart)
mcartmax <- rpart(as.factor(Outcome)~.,data=dtrain,cp=0,minbucket=1,maxdepth=30)
predcartmax <- predict(mcartmax,newdata=dtest,type="class")
te_cartmax <- tx_er(predcartmax,dtest$Outcome) 
te_cartmax 
library(caret)
library(e1071)
#install.packages("e1071")
confusionMatrix(dtest$Outcome,predcartmax)#erreur=1-accuracy
rpart.plot(mcartmax) #on trouve un arbre compliqué donc il faut élaguer
plotcp(mcartmax)
# Elagage
mcart <- prune(mcartmax,cp=0,044)#cp=?
predcart <- predict(mcart,newdata=dtest,type="class")
te_cart <- tx_er(predcart,dtest$Outcome)
te_cart 
rpart.plot(mcart) 
# Arbre à 1 noeud
mdecstump <- rpart(as.factor(Outcome)~.,data=dtrain,cp=0,maxdepth=1)
preddecstump <- predict(mdecstump,newdata=dtest,type="class")
te_decst <- tx_er(preddecstump,dtest$Outcome) 
te_decst
rpart.plot(mdecstump) 
######################################################################

#knn
library(class)
knn1 = knn(train = dtrain[,1:8],test = dtest[,1:8],cl = dtrain[,9],k = 1)
summary(knn1)
table(dtest$Outcome,knn1)
accuracy = sum((dtest$Outcome==knn1)/length(dtest$Outcome))*100
accuracy

###########
dtest$Outcome=as.factor(dtest$Outcome)
dtrain$Outcome=as.factor(dtrain$Outcome)
knn = list()
accuracy = numeric()
for (i in 1:70) {
  knn = knn(train = dtrain[,1:8],test = dtest[,1:8],cl = dtrain[,9],k = i,
            prob = TRUE)
  summary(knn)
  table(dtest$Outcome,knn)
  accuracy[i] = sum((dtest$Outcome==knn)/length(dtest$Outcome))*100
  accuracy
}
################################################################################################
plot(x = accuracy,pch = 20,col = "red")
abline(h = max(accuracy))
abline(v = which(accuracy==max(accuracy)))
# k=17 et k=23 fournis un bon modele

summary(knn1)
knn1 = knn(train = dtrain[,1:8],test = dtest[,1:8],cl = dtrain[,9],k = 23)
table(dtest$Outcome,knn1)
accuracy = sum((dtest$Outcome==knn1)/length(dtest$Outcome))*100
accuracy

d0<-dtest[which(dtest$Outcome==0),-9] #-7 pour enlever la variable Outcome
dim(d0) #100 de 0
d1<-dtest[which(dtest$Outcome==1),-9] #-7 pour enlever la variable Outcome
dim(d1) #53 de 1
summary(knn1)
#avec knn le taux de mauvaise prediction est de 21% 

