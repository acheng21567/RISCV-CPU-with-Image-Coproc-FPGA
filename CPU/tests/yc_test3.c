///////////////////////////
//  Text Justification  //
/////////////////////////

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char** fullJustify(char** words, int wordsSize, int maxWidth, int* returnSize) {
    // Initialize result array and counters
    char** result = (char**)malloc(wordsSize * sizeof(char*)); // Allocate max possible lines
    int lineCount = 0;
    int i = 0; // Index to iterate through words
    
    while (i < wordsSize) {
        // start index and length of the first word
        int lineLength = strlen(words[i]);
        int start = i;
        i++;
        
        // Try to fit as many words as possible in the current line
        while (i < wordsSize && (lineLength + strlen(words[i]) + 1) <= maxWidth) {
            lineLength += strlen(words[i]) + 1; // +1 for the space
            i++;
        }
        
        // Calculate spacing
        int spaceSlots = i - start - 1; // Spaces needed
        int extraSpaces = maxWidth - lineLength; // Extra spaces to be distributed
        
        // Allocate and initialize the current line
        result[lineCount] = (char*)malloc((maxWidth + 1) * sizeof(char)); // +1 for '\0'
        result[lineCount][0] = '\0';
        
        for (int j = start; j < i; ++j) {
            strcat(result[lineCount], words[j]); // Add word
            if (j < i - 1) { // If not the last word in the line
                int spacesToAdd = extraSpaces / spaceSlots + (j - start < extraSpaces % spaceSlots ? 1 : 0) + 1;
                for (int k = 0; k < spacesToAdd; ++k) {
                    strcat(result[lineCount], " ");
                }
            }
        }
        
        // For the last line or lines with one word only
        while (strlen(result[lineCount]) < maxWidth) {
            strcat(result[lineCount], " ");
        }
        
        lineCount++;
    }
    
    *returnSize = lineCount;
    return result;
}

int main() {
    char* words[] = {"This", "is", "an", "example", "of", "text", "justification."};
    int wordsSize = sizeof(words) / sizeof(words[0]);
    int maxWidth = 16;
    int returnSize;
    
    char** justifiedText = fullJustify(words, wordsSize, maxWidth, &returnSize);
    
    for (int i = 0; i < returnSize; ++i) {
        //printf("\"%s\"\n", justifiedText[i]);
        free(justifiedText[i]); // Don't forget to free each line
    }
    free(justifiedText); // And the array of lines
    
    return 0;
}
