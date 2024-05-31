//////////////////////
//  Sudoku Solver  //
////////////////////

#include <stdio.h>
#include <stdbool.h>

#define UNASSIGNED '.'

// Function prototypes within solveSudoku context
bool solve(char** board, int boardSize, int* boardColSize);
bool findUnassignedLocation(char** board, int boardSize, int* row, int* col);
bool isSafe(char** board, int boardSize, char num, int row, int col);
bool usedInRow(char** board, int boardSize, char num, int row);
bool usedInCol(char** board, int boardSize, char num, int col);
bool usedInBox(char** board, int boxStartRow, int boxStartCol, char num);

void solveSudoku(char** board, int boardSize, int* boardColSize) {
    if (solve(board, boardSize, boardColSize)) {
        // If you need to do something after solving the Sudoku, you can do it here
        // For example, print the solved Sudoku
    } else {
        printf("No solution exists.\n");
    }
}

bool solve(char** board, int boardSize, int* boardColSize) {
    int row, col;

    if (!findUnassignedLocation(board, boardSize, &row, &col))
        return true; // Success!

    for (char num = '1'; num <= '9'; num++) {
        if (isSafe(board, boardSize, num, row, col)) {
            board[row][col] = num;

            if (solve(board, boardSize, boardColSize))
                return true;

            board[row][col] = UNASSIGNED; // Undo & try again
        }
    }
    return false; // Triggers backtracking
}

bool findUnassignedLocation(char** board, int boardSize, int* row, int* col) {
    for (*row = 0; *row < boardSize; (*row)++)
        for (*col = 0; *col < boardSize; (*col)++)
            if (board[*row][*col] == UNASSIGNED)
                return true;
    return false;
}

bool isSafe(char** board, int boardSize, char num, int row, int col) {
    return !usedInRow(board, boardSize, num, row) &&
           !usedInCol(board, boardSize, num, col) &&
           !usedInBox(board, row - row % 3, col - col % 3, num);
}

bool usedInRow(char** board, int boardSize, char num, int row) {
    for (int col = 0; col < boardSize; col++)
        if (board[row][col] == num)
            return true;
    return false;
}

bool usedInCol(char** board, int boardSize, char num, int col) {
    for (int row = 0; row < boardSize; row++)
        if (board[row][col] == num)
            return true;
    return false;
}

bool usedInBox(char** board, int boxStartRow, int boxStartCol, char num) {
    for (int row = 0; row < 3; row++)
        for (int col = 0; col < 3; col++)
            if (board[row + boxStartRow][col + boxStartCol] == num)
                return true;
    return false;
}
int main() {
    // Define a sample Sudoku puzzle. '.' represents an empty cell.
    char* board[9] = {
        "53..7....",
        "6..195...",
        ".98....6.",
        "8...6...3",
        "4..8.3..1",
        "7...2...6",
        ".6....28.",
        "...419..5",
        "....8..79"
    };

    // Convert the board to an array of arrays of char to pass to solveSudoku
    char** puzzle = (char**)malloc(9 * sizeof(char*));
    for (int i = 0; i < 9; i++) {
        puzzle[i] = (char*)malloc(10 * sizeof(char)); // 9 characters + null terminator
        for (int j = 0; j < 9; j++) {
            puzzle[i][j] = board[i][j];
        }
        puzzle[i][9] = '\0'; // Null-terminate the strings
    }

    // Assume each row has the same number of columns for simplicity
    int boardColSize[9];
    for (int i = 0; i < 9; i++) {
        boardColSize[i] = 9;
    }

    // printf("Original Sudoku Puzzle:\n");
    // for (int i = 0; i < 9; i++) {
    //     printf("%s\n", puzzle[i]);
    // }

    solveSudoku(puzzle, 9, boardColSize);

    // printf("\nSolved Sudoku Puzzle:\n");
    // for (int i = 0; i < 9; i++) {
    //     printf("%s\n", puzzle[i]);
    // }

    // Free the allocated memory
    for (int i = 0; i < 9; i++) {
        free(puzzle[i]);
    }
    free(puzzle);

    return 0;
}