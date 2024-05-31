int main() {
	// Initialize Matricies in Memory for 
    int original_img[256][256];
    int result_img[256][256];
	
	int min = original_img[0][0];
	int max = original_img[0][0];

    // Iterate Through Image & Perform Thresholding
	for (int i = 0; i < 256; i++){
		for (int j = 0; j < 256; j++){
			result_img[i][j] = original_img[i][j];
			
			if (original_img[i][j] < min){
				min = original_img[i][j];
			}
			else if (original_img[i][j] > max) {
				max = original_img[i][j];
			}
		}
	}
	
    return 0;
}