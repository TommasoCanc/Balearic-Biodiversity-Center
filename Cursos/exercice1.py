## Module 2. Introduction to Python ##
##Exercice 1

# import libraries 
import random
from statistics import mean

# create variables 
randomlist = []

# create and save 10 random numbers in n list-variable

for i in range(0,10):
    n = random.randint(1,30)
    randomlist.append(n)
print(randomlist)

# 2. Sort the numbers
print(str(sorted(randomlist)))
# 3. Retrieve the maximum number of the list
print(str(max(randomlist)))
# 4. Retrieve the minimum number of the list
print(str(min(randomlist)))
# 5. Print the mean
### Option 5.1, not using library

list_mean = sum(randomlist)/10
print(str(list_mean))

### Option 2, using statistics library
print(str(mean(randomlist)))
