int main() {
	// Initialize Matricies in Memory for 
    int original_img[256][256];
    int result_img[256][256];
	
	int filter[3][3] = {{-1, -1, -1}, {-1, 8, -1}, {-1, -1, -1}};
	
    // Iterate Through Image & Perform Convolution
	for (int i = 0; i < (256 - 3 + 1); i++) {
		for (int j = 0; j < (256 - 3 + 1); j++) {
			for (k = 0; k < 3; k++) {
				for (l = 0; l < 3; l++) {
					result_img[i][j] += original_img[i+k][j+l] * filter[k][l];
				}
			}
		}
	}
	
    return 0;
}