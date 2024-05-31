int main() {
	// Initialize Matricies in Memory for 
    int original_img[256][256];
    int result_img[256][256];

    // Iterate Through Image & Perform Thresholding
	for (int i = 0; i < 256; i++){
		for (int j = 0; j < 256; j++){
			if (original_img[i][j] < 32) {
				result_img[i][j] = 0;
			}
			else {
				result_img[i][j] = original_img[i][j];
			}
			
		}
	}
	
    return 0;
}