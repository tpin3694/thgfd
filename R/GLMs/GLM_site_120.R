rm(list = ls())
library(caret)
library(dplyr)
library(DMwR)
library(unbalanced)
library(ROCR)
library(corrplot)

setwd("C:/Users/Luke/Documents/University/Lancaster/Data Fundamentals/thgfd/data/stratified")
glm_data <- read.csv("dataset_120.csv")
#glm_data$fraud_status <- as.factor((glm_data$fraud_status))
glm_data <- select(glm_data, -Site_Key, -Ordered_Product_Key)


#Removing zero variance variables
glm_data <- Filter(function(x) var(x)!=0, glm_data)


glm_data <- select(glm_data, -(1:16), -Campaign_Key, -Ordered_Qty, -Cancelled_Qty, -prop,
                   -canc_prop, -count)

# After building GLM
glm_data <- select(glm_data, -Medium_Key)


set.seed(123)
Tomek <- ubTomek(select(glm_data, -fraud_status), glm_data$fraud_status, verbose = TRUE)
glm_data <- cbind(Tomek$X, Tomek$Y)
glm_data <- rename(glm_data, fraud_status = "Tomek$Y")




#Test for colinearity:
X <- cor(glm_data)
corrplot(X, method="circle", type = "lower")



temp <- select(glm_data, -Product_Charge_Price, -num_valid,  -Order_Sequence_No)
temp[,(1:ncol(temp))] <- lapply(temp[,(1:ncol(temp))],as.factor)
temp <- temp[, sapply(temp, nlevels) > 1]
nums <- select(glm_data, Product_Charge_Price, num_valid,  Order_Sequence_No)
glm_data <- cbind(temp, nums)




new_data <- glm_data



set.seed(123)
index <- createDataPartition(new_data$fraud_status, p = 0.7, list = FALSE)
train <- new_data[index, ]
test <- new_data[-index, ]


set.seed(123)
train <- SMOTE(fraud_status ~., train, perc.over = 10000, perc.under = 150)
table(train$fraud_status)
prop.table(table(train$fraud_status))


# Building a GLM
start <- Sys.time()
model <- glm(fraud_status ~., data = train, family = binomial(link = "logit"))
end <- Sys.time()
time <- end - start
time
summary(model)



# model_predict <- predict(model, test, type = "response")
# ROC_predict <- prediction(model_predict, test$fraud_status)
# ROC_performance <- performance(ROC_predict, "tpr", "fpr")
# plot(ROC_performance, colorize = TRUE, text.adj = c(-0.2,1.7), lwd = 5)
# area_under_curve <- performance(ROC_predict, measure = "auc")
# area_under_curve@y.values[[1]]
# 
# 
#  
# # TEN FOLD CROSS VALIDATION
# ctrl <- trainControl(method = "repeatedcv", number = 10, savePredictions = TRUE)
# model_fit <- caret::train(fraud_status ~ customer_status + Product_Charge_Price,
#                    data = train, method = "glm", family = binomial(link ="logit"),
#                    trControl = ctrl, tuneLength = 10)
# pred <- predict(model_fit, newdata = test)
# conf <- confusionMatrix(data = pred, test$fraud_status)
# conf
# conf$byClass













