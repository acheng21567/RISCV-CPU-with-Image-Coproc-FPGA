int main() {
	// Initialize Matricies in Memory for 
    int original_img[256][256];
    int result_img[256][256];
	
	int min = 4;
	int max = 242;
	int diff = max - min;
	int den = (2<<4) - 1;

    // Iterate Through Image & Perform Thresholding
	for (int i = 0; i < 256; i++){
		for (int j = 0; j < 256; j++){
			result_img[i][j] = ((original_img[i][j] - min) / (diff)) * (den);
		}
	}
	
    return 0;
}