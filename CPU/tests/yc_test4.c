///////////////////////////
//  Text Justification  //
/////////////////////////

#include <stdio.h>
#include <stdlib.h>

int max(int a, int b) {
    return (a > b) ? a : b;
}

int candy(int* ratings, int ratingsSize) {
    if (ratingsSize == 0) return 0;
    
    int* candies = (int*)malloc(ratingsSize * sizeof(int));
    for (int i = 0; i < ratingsSize; i++) {
        candies[i] = 1; // Each child gets at least one candy
    }
    
    // Left to right
    for (int i = 1; i < ratingsSize; i++) {
        if (ratings[i] > ratings[i - 1]) {
            candies[i] = candies[i - 1] + 1;
        }
    }
    
    // Right to left
    for (int i = ratingsSize - 2; i >= 0; i--) {
        if (ratings[i] > ratings[i + 1]) {
            candies[i] = max(candies[i], candies[i + 1] + 1);
        }
    }
    
    // Sum up the candies
    int totalCandies = 0;
    for (int i = 0; i < ratingsSize; i++) {
        totalCandies += candies[i];
    }
    
    free(candies); // Don't forget to free the allocated memory!
    return totalCandies;
}

int main() {
    int ratings1[] = {1, 0, 2};
    int size1 = sizeof(ratings1) / sizeof(ratings1[0]);
    //printf("Example 1: %d\n", candy(ratings1, size1));

    int ratings2[] = {1, 2, 2};
    int size2 = sizeof(ratings2) / sizeof(ratings2[0]);
    //printf("Example 2: %d\n", candy(ratings2, size2));

    return 0;
}