# Procedure
The topic modeling script in the root directory pulls in the cleaned data created from the files in the Parsing folder. After reading in the data it creates a document term matrix that is used for topic modeling. The topic modeling algorithm used is Latent Dirichlet Allocation.

To run script navigate to root directory and run this line:
```bash
$ python Topic_Modeling.py > Topic_Modeling/output.txt
```

# References
Links below were used for syntax:
* https://de.dariah.eu/tatom/topic_model_python.html
* https://medium.com/@aneesha/topic-modeling-with-scikit-learn-e80d33668730#.nc7n0epiw
* http://scikit-learn.org/stable/modules/generated/sklearn.decomposition.LatentDirichletAllocation.html
* http://graus.co/tag/gensim/
* https://radimrehurek.com/gensim/models/ldamulticore.html
* https://www.cs.princeton.edu/~blei/papers/BleiNgJordan2003.pdf
