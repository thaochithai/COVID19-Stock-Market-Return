install.packages("nortest")
install.packages("ADGofTest")
library(xts)
library(zoo)
library(quantmod)
library(qrmtools)
library(qrmdata)
library(rugarch)
library(tseries)
library(moments)
library(ADGofTest)

#setting up data

DATA <- xts(DATA[, -1], order.by=as.POSIXct(DATA$Date))
VNIP <- DATA$VNIP
VNIRE <- returns(VNIP)
VNIRE=na.omit(VNIRE) 

VNI30P <- DATA$VNI30P
VNI30RE <- returns(VNI30P)
VNI30RE=na.omit(VNI30RE)

HNXP <- DATA$HNXP
HNXRE <- returns(HNXP)
HNXRE=na.omit(HNXRE)

HNX30P <- DATA$HNX30P
HNX30RE <- returns(HNX30P)
HNX30RE=na.omit(HNX30RE)

UPCOMIP <- DATA$UPCOMIP
UPCOMIRE <- returns(UPCOMIP)
UPCOMIRE=na.omit(UPCOMIRE)

X <- merge(VNIRE, VNI30RE,HNXRE,HNX30RE,UPCOMIRE, all = FALSE)
nms <- c("VNIRE", "VNI30RE", "HNXRE", "HNX30RE","UPCOMIRE")
colnames(X) <- nms
plot.zoo(X, xlab = "Time", main = "Log-returns")
pairs(as.zoo(X), gap = 0, cex = 0.4)

#VNIRE
summary(VNIRE)
hist(VNIRE)
sd(VNIRE)
skewness(VNIRE)
kurtosis(VNIRE)
jarque.bera.test(VNIRE)

##unitroottest (stationary test)
#H0:Non stationary
#Ha:Stationary
test.unitroot = adf.test(VNIRE)
test.unitroot

## Ljung-Box Test (Dependence test):
#H0: The data are independently distributed. 
#Ha: The data are not independently distributed; they exhibit serial correlation.
(test.LB   <- Box.test(VNIRE,lag = 10,type = "Ljung-Box"))
(test.LB.abs   <- Box.test(abs(VNIRE),lag = 10,type = "Ljung-Box"))
(test.LB.sqr   <- Box.test(VNIRE^2,lag = 10,type = "Ljung-Box"))

## Tests for the normality (Normality test)
#H0: The data are normal distribution
sh <- shapiro.test(as.numeric(VNIRE)) # Shapiro--Wilk
ag <- agostino.test(as.numeric(VNIRE)) # D'Agostino's test
jb <- jarque.test(as.numeric(VNIRE)) # Jarque--Bera test
cat("p-value: shapiro test",sh$p.value,"    agostino.test", ag$p.value,"    jarque.test", jb$p.value)
stopifnot(min(sh$p.value, ag$p.value, jb$p.value) >= 0.05) 

## Model setting (ARCH(1), GARCH(1,1), TGARCH(1,1))
model.arch<-ugarchspec (variance.model = list(model="sGARCH",garchOrder=c(1,0)), 
                        mean.model = list(armaOrder=c(1,0),include.mean=TRUE), 
                        distribution.model = "std")
model.garch<-ugarchspec(variance.model = list(model="sGARCH",garchOrder=c(1,1)), 
                        mean.model = list(armaOrder=c(1,0),include.mean=TRUE), 
                        distribution.model = "std")
model.egarch<-ugarchspec(variance.model = list(model="eGARCH",garchOrder=c(1,1)), 
                         mean.model = list(armaOrder=c(1,0),include.mean=TRUE), 
                         distribution.model = "std")
model.tgarch<-ugarchspec(variance.model = list(model="fGARCH",garchOrder=c(1,1),submodel="TGARCH"), 
                         mean.model = list(armaOrder=c(1,0),include.mean=TRUE), 
                         distribution.model = "std")

## Modelestimation
# Parameter significance

(fit.arch <- ugarchfit(model.arch, y))
(fit.garch <- ugarchfit(model.garch, y))
(fit.egarch <- ugarchfit(model.egarch, y))
(fit.tgarch <- ugarchfit(model.tgarch, y))


## Likelihood ratio test
# H0: model are good enough
# HA: t innovations necessary
# Decision: We reject the null (in favour of the alternative) if the
#           likelihood-ratio test statistic exceeds the 0.99 quantile of a
#           chi-squared distribution with 1 degree of freedom (1 here as that's
#           the difference in the number of parameters for the two model

(LRT <- 2*(fit.garch@fit$LLH-fit.arch@fit$LLH))
LRT > qchisq(0.99, 1) #=> H0 is rejected
(LRT <- 2*(fit.tgarch@fit$LLH-fit.arch@fit$LLH))
LRT > qchisq(0.99, 1) #=> H0 is rejected
(LRT <- 2*(fit.egarch@fit$LLH-fit.garch@fit$LLH))
LRT > qchisq(0.99, 1) #=> H0 is rejected
(LRT <- 2*(fit.tgarch@fit$LLH-fit.garch@fit$LLH))
LRT > qchisq(0.99, 1) #=> H0 is rejected
(LRT <- 2*(fit.egarch@fit$LLH-fit.arch@fit$LLH))
LRT > qchisq(0.99, 1) #=> H0 is rejected

#VNI30RE

summary(VNI30RE)
hist(VNI30RE)
sd(VNI30RE)
skewness(VNI30RE)
kurtosis(VNI30RE)
jarque.bera.test(VNI30RE)

##unitroottest (stationary test)
#H0:Non stationary
#Ha:Stationary
test.unitroot = adf.test(VNI30RE)
test.unitroot

## Ljung-Box Test (Dependence test):
#H0: The data are independently distributed. 
#Ha: The data are not independently distributed; they exhibit serial correlation.
(test.LB   <- Box.test(VNI30RE,lag = 10,type = "Ljung-Box"))
(test.LB.abs   <- Box.test(abs(VNI30RE),lag = 10,type = "Ljung-Box"))
(test.LB.sqr   <- Box.test(VNI30RE^2,lag = 10,type = "Ljung-Box"))

## Tests for the normality (Normality test)
#H0: The data are normal distribution
sh <- shapiro.test(as.numeric(VNI30RE)) # Shapiro--Wilk
ag <- agostino.test(as.numeric(VNI30RE)) # D'Agostino's test
jb <- jarque.test(as.numeric(VNI30RE)) # Jarque--Bera test
cat("p-value: shapiro test",sh$p.value,"    agostino.test", ag$p.value,"    jarque.test", jb$p.value)
stopifnot(min(sh$p.value, ag$p.value, jb$p.value) >= 0.05) 

## Model setting (ARCH(1), GARCH(1,1), TGARCH(1,1))
model.arch<-ugarchspec (variance.model = list(model="sGARCH",garchOrder=c(1,0)), 
                        mean.model = list(armaOrder=c(1,0),include.mean=TRUE), 
                        distribution.model = "std")
model.garch<-ugarchspec(variance.model = list(model="sGARCH",garchOrder=c(1,1)), 
                        mean.model = list(armaOrder=c(1,0),include.mean=TRUE), 
                        distribution.model = "std")
model.egarch<-ugarchspec(variance.model = list(model="eGARCH",garchOrder=c(1,1)), 
                         mean.model = list(armaOrder=c(1,0),include.mean=TRUE), 
                         distribution.model = "std")
model.tgarch<-ugarchspec(variance.model = list(model="fGARCH",garchOrder=c(1,1),submodel="TGARCH"), 
                         mean.model = list(armaOrder=c(1,0),include.mean=TRUE), 
                         distribution.model = "std")

## Modelestimation
# Parameter significance

(fit.arch <- ugarchfit(model.arch, y))
(fit.garch <- ugarchfit(model.garch, y))
(fit.egarch <- ugarchfit(model.egarch, y))
(fit.tgarch <- ugarchfit(model.tgarch, y))


## Likelihood ratio test
# H0: model are good enough
# HA: t innovations necessary
# Decision: We reject the null (in favour of the alternative) if the
#           likelihood-ratio test statistic exceeds the 0.99 quantile of a
#           chi-squared distribution with 1 degree of freedom (1 here as that's
#           the difference in the number of parameters for the two model

(LRT <- 2*(fit.garch@fit$LLH-fit.arch@fit$LLH))
LRT > qchisq(0.99, 1) #=> H0 is rejected
(LRT <- 2*(fit.tgarch@fit$LLH-fit.arch@fit$LLH))
LRT > qchisq(0.99, 1) #=> H0 is rejected
(LRT <- 2*(fit.egarch@fit$LLH-fit.garch@fit$LLH))
LRT > qchisq(0.99, 1) #=> H0 is rejected
(LRT <- 2*(fit.tgarch@fit$LLH-fit.garch@fit$LLH))
LRT > qchisq(0.99, 1) #=> H0 is rejected
(LRT <- 2*(fit.egarch@fit$LLH-fit.arch@fit$LLH))
LRT > qchisq(0.99, 1) #=> H0 is rejected


#HNXRE

summary(HNXRE)
hist(HNXRE)
sd(HNXRE)
skewness(HNXRE)
kurtosis(HNXRE)
jarque.bera.test(HNXRE)

##unitroottest (stationary test)
#H0:Non stationary
#Ha:Stationary
test.unitroot = adf.test(HNXRE)
test.unitroot

## Ljung-Box Test (Dependence test):
#H0: The data are independently distributed. 
#Ha: The data are not independently distributed; they exhibit serial correlation.
(test.LB   <- Box.test(HNXRE,lag = 10,type = "Ljung-Box"))
(test.LB.abs   <- Box.test(abs(HNXRE),lag = 10,type = "Ljung-Box"))
(test.LB.sqr   <- Box.test(HNXRE^2,lag = 10,type = "Ljung-Box"))

## Tests for the normality (Normality test)
#H0: The data are normal distribution
sh <- shapiro.test(as.numeric(HNXRE)) # Shapiro--Wilk
ag <- agostino.test(as.numeric(HNXRE)) # D'Agostino's test
jb <- jarque.test(as.numeric(HNXRE)) # Jarque--Bera test
cat("p-value: shapiro test",sh$p.value,"    agostino.test", ag$p.value,"    jarque.test", jb$p.value)
stopifnot(min(sh$p.value, ag$p.value, jb$p.value) >= 0.05) 

## Model setting (ARCH(1), GARCH(1,1), TGARCH(1,1))
model.arch<-ugarchspec (variance.model = list(model="sGARCH",garchOrder=c(1,0)), 
                        mean.model = list(armaOrder=c(1,0),include.mean=TRUE), 
                        distribution.model = "std")
model.garch<-ugarchspec(variance.model = list(model="sGARCH",garchOrder=c(1,1)), 
                        mean.model = list(armaOrder=c(1,0),include.mean=TRUE), 
                        distribution.model = "std")
model.egarch<-ugarchspec(variance.model = list(model="eGARCH",garchOrder=c(1,1)), 
                         mean.model = list(armaOrder=c(1,0),include.mean=TRUE), 
                         distribution.model = "std")
model.tgarch<-ugarchspec(variance.model = list(model="fGARCH",garchOrder=c(1,1),submodel="TGARCH"), 
                         mean.model = list(armaOrder=c(1,0),include.mean=TRUE), 
                         distribution.model = "std")

## Modelestimation
# Parameter significance

(fit.arch <- ugarchfit(model.arch, y))
(fit.garch <- ugarchfit(model.garch, y))
(fit.egarch <- ugarchfit(model.egarch, y))
(fit.tgarch <- ugarchfit(model.tgarch, y))


## Likelihood ratio test
# H0: model are good enough
# HA: t innovations necessary
# Decision: We reject the null (in favour of the alternative) if the
#           likelihood-ratio test statistic exceeds the 0.99 quantile of a
#           chi-squared distribution with 1 degree of freedom (1 here as that's
#           the difference in the number of parameters for the two model

(LRT <- 2*(fit.garch@fit$LLH-fit.arch@fit$LLH))
LRT > qchisq(0.99, 1) #=> H0 is rejected
(LRT <- 2*(fit.tgarch@fit$LLH-fit.arch@fit$LLH))
LRT > qchisq(0.99, 1) #=> H0 is rejected
(LRT <- 2*(fit.egarch@fit$LLH-fit.garch@fit$LLH))
LRT > qchisq(0.99, 1) #=> H0 is rejected
(LRT <- 2*(fit.tgarch@fit$LLH-fit.garch@fit$LLH))
LRT > qchisq(0.99, 1) #=> H0 is rejected
(LRT <- 2*(fit.egarch@fit$LLH-fit.arch@fit$LLH))
LRT > qchisq(0.99, 1) #=> H0 is rejected

#HNX30RE

summary(HNX30RE)
hist(HNX30RE)
sd(HNX30RE)
skewness(HNX30RE)
kurtosis(HNX30RE)
jarque.bera.test(HNX30RE)

##unitroottest (stationary test)
#H0:Non stationary
#Ha:Stationary
test.unitroot = adf.test(HNX30RE)
test.unitroot

## Ljung-Box Test (Dependence test):
#H0: The data are independently distributed. 
#Ha: The data are not independently distributed; they exhibit serial correlation.
(test.LB   <- Box.test(HNX30RE,lag = 10,type = "Ljung-Box"))
(test.LB.abs   <- Box.test(abs(HNX30RE),lag = 10,type = "Ljung-Box"))
(test.LB.sqr   <- Box.test(HNX30RE^2,lag = 10,type = "Ljung-Box"))

## Tests for the normality (Normality test)
#H0: The data are normal distribution
sh <- shapiro.test(as.numeric(HNX30RE)) # Shapiro--Wilk
ag <- agostino.test(as.numeric(HNX30RE)) # D'Agostino's test
jb <- jarque.test(as.numeric(HNX30RE)) # Jarque--Bera test
cat("p-value: shapiro test",sh$p.value,"    agostino.test", ag$p.value,"    jarque.test", jb$p.value)
stopifnot(min(sh$p.value, ag$p.value, jb$p.value) >= 0.05) 

## Model setting (ARCH(1), GARCH(1,1), TGARCH(1,1))
model.arch<-ugarchspec (variance.model = list(model="sGARCH",garchOrder=c(1,0)), 
                        mean.model = list(armaOrder=c(1,0),include.mean=TRUE), 
                        distribution.model = "std")
model.garch<-ugarchspec(variance.model = list(model="sGARCH",garchOrder=c(1,1)), 
                        mean.model = list(armaOrder=c(1,0),include.mean=TRUE), 
                        distribution.model = "std")
model.egarch<-ugarchspec(variance.model = list(model="eGARCH",garchOrder=c(1,1)), 
                         mean.model = list(armaOrder=c(1,0),include.mean=TRUE), 
                         distribution.model = "std")
model.tgarch<-ugarchspec(variance.model = list(model="fGARCH",garchOrder=c(1,1),submodel="TGARCH"), 
                         mean.model = list(armaOrder=c(1,0),include.mean=TRUE), 
                         distribution.model = "std")

## Modelestimation
# Parameter significance

(fit.arch <- ugarchfit(model.arch, y))
(fit.garch <- ugarchfit(model.garch, y))
(fit.egarch <- ugarchfit(model.egarch, y))
(fit.tgarch <- ugarchfit(model.tgarch, y))


## Likelihood ratio test
# H0: model are good enough
# HA: t innovations necessary
# Decision: We reject the null (in favour of the alternative) if the
#           likelihood-ratio test statistic exceeds the 0.99 quantile of a
#           chi-squared distribution with 1 degree of freedom (1 here as that's
#           the difference in the number of parameters for the two model

(LRT <- 2*(fit.garch@fit$LLH-fit.arch@fit$LLH))
LRT > qchisq(0.99, 1) #=> H0 is rejected
(LRT <- 2*(fit.tgarch@fit$LLH-fit.arch@fit$LLH))
LRT > qchisq(0.99, 1) #=> H0 is rejected
(LRT <- 2*(fit.egarch@fit$LLH-fit.garch@fit$LLH))
LRT > qchisq(0.99, 1) #=> H0 is rejected
(LRT <- 2*(fit.tgarch@fit$LLH-fit.garch@fit$LLH))
LRT > qchisq(0.99, 1) #=> H0 is rejected
(LRT <- 2*(fit.egarch@fit$LLH-fit.arch@fit$LLH))
LRT > qchisq(0.99, 1) #=> H0 is rejected

#UPCOMIRE

summary(UPCOMIRE)
hist(UPCOMIRE)
sd(UPCOMIRE)
skewness(UPCOMIRE)
kurtosis(UPCOMIRE)
jarque.bera.test(UPCOMIRE)

##unitroottest (stationary test)
#H0:Non stationary
#Ha:Stationary
test.unitroot = adf.test(UPCOMIRE)
test.unitroot

## Ljung-Box Test (Dependence test):
#H0: The data are independently distributed. 
#Ha: The data are not independently distributed; they exhibit serial correlation.
(test.LB   <- Box.test(UPCOMIRE,lag = 10,type = "Ljung-Box"))
(test.LB.abs   <- Box.test(abs(UPCOMIRE),lag = 10,type = "Ljung-Box"))
(test.LB.sqr   <- Box.test(UPCOMIRE^2,lag = 10,type = "Ljung-Box"))

## Tests for the normality (Normality test)
#H0: The data are normal distribution
sh <- shapiro.test(as.numeric(UPCOMIRE)) # Shapiro--Wilk
ag <- agostino.test(as.numeric(UPCOMIRE)) # D'Agostino's test
jb <- jarque.test(as.numeric(UPCOMIRE)) # Jarque--Bera test
cat("p-value: shapiro test",sh$p.value,"    agostino.test", ag$p.value,"    jarque.test", jb$p.value)
stopifnot(min(sh$p.value, ag$p.value, jb$p.value) >= 0.05) 

## Model setting (ARCH(1), GARCH(1,1), TGARCH(1,1))
model.arch<-ugarchspec (variance.model = list(model="sGARCH",garchOrder=c(1,0)), 
                        mean.model = list(armaOrder=c(1,0),include.mean=TRUE), 
                        distribution.model = "std")
model.garch<-ugarchspec(variance.model = list(model="sGARCH",garchOrder=c(1,1)), 
                        mean.model = list(armaOrder=c(1,0),include.mean=TRUE), 
                        distribution.model = "std")
model.egarch<-ugarchspec(variance.model = list(model="eGARCH",garchOrder=c(1,1)), 
                         mean.model = list(armaOrder=c(1,0),include.mean=TRUE), 
                         distribution.model = "std")
model.tgarch<-ugarchspec(variance.model = list(model="fGARCH",garchOrder=c(1,1),submodel="TGARCH"), 
                         mean.model = list(armaOrder=c(1,0),include.mean=TRUE), 
                         distribution.model = "std")

## Modelestimation
# Parameter significance

(fit.arch <- ugarchfit(model.arch, y))
(fit.garch <- ugarchfit(model.garch, y))
(fit.egarch <- ugarchfit(model.egarch, y))
(fit.tgarch <- ugarchfit(model.tgarch, y))


## Likelihood ratio test
# H0: model are good enough
# HA: t innovations necessary
# Decision: We reject the null (in favour of the alternative) if the
#           likelihood-ratio test statistic exceeds the 0.99 quantile of a
#           chi-squared distribution with 1 degree of freedom (1 here as that's
#           the difference in the number of parameters for the two model

(LRT <- 2*(fit.garch@fit$LLH-fit.arch@fit$LLH))
LRT > qchisq(0.99, 1) #=> H0 is rejected
(LRT <- 2*(fit.tgarch@fit$LLH-fit.arch@fit$LLH))
LRT > qchisq(0.99, 1) #=> H0 is rejected
(LRT <- 2*(fit.egarch@fit$LLH-fit.garch@fit$LLH))
LRT > qchisq(0.99, 1) #=> H0 is rejected
(LRT <- 2*(fit.tgarch@fit$LLH-fit.garch@fit$LLH))
LRT > qchisq(0.99, 1) #=> H0 is rejected
(LRT <- 2*(fit.egarch@fit$LLH-fit.arch@fit$LLH))
LRT > qchisq(0.99, 1) #=> H0 is rejected

