# Description: This function to predict the for multiple datasets for naive bayes KDE

# Usage: This function is to predict the probability of the covariates belong to
#        class C ={0,1}. The testdata must be (m x p) matrix/ data frame where
#        p is the number of features and m is the number of instances.
#        The traindata must a matris with (n x p+1) matrix where n is the number
#        of training instances and (p+1) is the number of features + target variable.
#        The bandwidth (h) may be NULL,a numeric or a matrix of (C x p) matrix/ data frame where
#        C is the number of class and p is the number of features in the training data
#        The prior is computed from the training data. The prior is obtained by
#        computing the number of observation belonging to a class and divided by the
#        total number of observation/ instances in the class

# install.packages("dplyr")
# install.packages("cvTools")

# Arguments:

# Values:

# Example

traindata = iris[c(1:10, 51:60, 101:110),]
testdata = as.matrix(iris[c(49, 50, 99, 100,149, 150), -5])
h = NULL
h = c(0.1, 0.1, 0.1, 0.3, 0.3, 0.3, 0.4, 0.5, 0.6, 0.6, 0.6, 0.7)
pdf = predict_nbkde(traindata=traindata, testdata=testdata, h = h)
pdf

library(dplyr)
predict_nbkde = function(traindata, testdata, h) {

      n_x = ncol(traindata) # no. of column in test data

      n_variable = ncol(as.matrix(traindata[, -n_x]))  # no. of features

      n_test = nrow(testdata) # no. of instances in testdata

      n_train = nrow(traindata)

      sort_traindata = dplyr::arrange(traindata, traindata[,n_x])

      n_class = length(unique(traindata[,n_x])) # no. of class

      class_name = unique(sort_traindata[, n_x]) #name of the class

      prior = rep(NA, n_class)
      for (k in 1:n_class) {

          class = noquote(as.character(unique(traindata[,n_x])))
          prior[k] = length(which(traindata[, n_x]  == class[k]))/n_train

          }

      length_prior = length(prior) # no. of prior

      if (length_prior != n_class) {

        stop("prior must have the same length as the number or class")

      }

      if (sum(prior) != 1) {

        stop("sum of prior must equal to 1")

      }


      if (is.null(testdata)) {

        testdata = traindata # the covariates

      } else {

        if (is.matrix(testdata) | is.data.frame(testdata)) {

          testdata = as.data.frame(testdata)
        }

        else {

          stop("testdata must be a matrix or data frame")

        }

      }

      if (is.null(traindata)) {

        stop("No train data")

      } else {

        if (is.matrix(traindata) | is.data.frame(traindata)) {

          traindata = as.data.frame(traindata)
        }

        else {

          stop("traindata must be a matrix or data frame")

        }

      }

      subset_traindata = subset.data(sort_traindata)

      if (is.null(h)) {

        bw = 2^seq(from=-4, to= 2, by=0.1)
        ind = list()
        train = list()
        test = list()
        training_data = list()
        testing_data = list()
        loss = array(NA, dim=c(length(bw),  n_variable, n_class))
        h = matrix(NA, ncol = n_class, nrow = n_variable)

        for (k in 1:n_class) {

          ind[[k]] <- sample(2, nrow(subset_traindata[[k]]),
                             replace = T, prob = c(0.8, 0.2))

          train[[k]] <- subset_traindata[[k]][ind[[k]] == 1,]
          test[[k]] <- subset_traindata[[k]][ind[[k]] == 2,]

          for (w in 1:length(bw)) {

            for (j in 1:n_variable) {

              training_data[[k]] = train[[k]][,-n_x]
              testing_data[[k]] = test[[k]][,-n_x]

              loss[w, j, k] = logloss(h = bw[w], traindata = as.matrix(training_data[[k]])[,j],
                                       testdata= as.matrix(testing_data[[k]])[,j])

            }
          }
        }

        for (k in 1:n_class) {

          for (w in 1:length(bw)) {

            for (j in 1:n_variable) {

              h[j, k] =  bw[which(loss[, j, k] == min(loss[,j , k]))]

            }
          }
        }

      } else if (is.numeric(h)) {

        if (length(h) != n_variable * n_class) {

          stop("Number of bandwidth is invalid")

        } else {

          h = matrix(h, byrow = T, ncol = n_class)

        }

      } else if (is.matrix(h)) {

        if (nrow(h) != n_variable) {

          stop("Number of row for bandwidth is invalid. Number of column must equal to number of class")

        }

        if (ncol(h) != n_class) {

          h = matrix(rep(h, n_class), ncol= n_class)

        }

      } else if (is.matrix(h)) {

        if (nrow(h) == n_variable) {

          if (ncol(h) == n_class) {

            h =h
          }

        }

      }

      #   n_h = length(h) # no.of of bandwidth
      #
      #   h_matrix = matrix(h, ncol = n_variable)
      #   # no. of column is the number of class
      #   # no. of row is the number of variable
      #
      #   if (n_h == 1) {
      #
      #     h = matrix(rep(h, (n_variable * n_class)), ncol = n_class,nrow = n_variable, )
      #
      #   } else if (nrow(h_matrix) == 1) {
      #
      #   h = matrix(rep(h_matrix, n_class), ncol= n_class)
      #
      #   } else if (nrow(h_matrix) != n_class)  {
      #
      #   stop("Number of bandwidth is invalid")
      #
      #   } else if (is.numeric(h))  {
      #
      #   h = matrix(h, byrow = T, ncol = n_class )
      #
      #   } else {
      #
      #   h = h
      #   }
      # }

      # h is a matrix of bandwidth with (C x P) dimension:
      # C: no of class
      # P: no of variable



      data = list()
      pdf = list()

      for(k in 1:n_class) {

        data[[k]]= subset_traindata[[k]][, -n_x]
        pdf [[k]] = multiple.pdf(traindata = data[[k]],
                                 testdata = testdata, h = h[,k])

        }

      # prior =  unlist(prior)
      # return (c(pdf, prior))

      prod_pdf = list()

      for (k in 1:n_class) {

        prod_pdf[[k]] = data.frame(unlist(pdf[[k]])) %>% mutate(Prod = Reduce(`*`, .))

      }

      prob_pdf = matrix(NA, nrow = n_test, ncol = n_class)
      for (k in 1:n_class) {

        prob_pdf[, k]  = prod_pdf[[k]]$Prod *  prior[k]
        # this the probability for each pdf
        # the row is the number of test point
        # the column the number of class

      }

      sum_prob = as.matrix(apply(prob_pdf, 1, sum), byrow = T, nrow = n_test)

      p_class = matrix(NA, nrow = n_test, ncol = n_class)

      for (k in 1:n_class) {

        for (i in 1:n_test) {

          p_class[i,k ] = prob_pdf[i ,k]/sum_prob[i,]

        }

      }

    p_class = as.data.frame(p_class)

    colnames(p_class) <- class_name

    h_matrix = h
    # no. of column is number of class
    # no. of row is number of variables
    colnames(h_matrix) <- class_name
    rownames(h_matrix) <- names(traindata[,-n_x])

    result = list("conditional probability" = p_class,
                  "prior probability" = prior,
                  "bandwidth"= h_matrix)
    return(result)

}
