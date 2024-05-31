int main() {
	// Initialize Matricies in Memory for 
    int original_img[256][256];
    int result_img[256][256];
	
	int value2;
	int value4;
	int value;
	int Rin;
	int Gin;
	int Bin;

    // Iterate Through Image & Perform Thresholding
	for (int i = 0; i < 256; i++){
		for (int j = 0; j < 256; j++){
			Rin = original_img[i][j] & 0x000F;
			Gin = original_img[i][j] & 0x00F0;
			Bin = original_img[i][j] & 0x0F00;
			
			value2 = (Rin + Gin + Bin) >> 1;
			value4 = (Rin + Gin + Bin) >> 2;
			value = (value2 + value4) > 1;
			
			if (value < 30) {
				result_img[i][j] = 0x0000;
			}
			else if (value >= 30 && value <= 70) {
				result_img[i][j] = 0x000F;
			}
			else if (value >= 70 && value <= 190) {
				result_img[i][j] = 0x00F0;
			}
			else if (value >=190 && value <= 249) {
				result_img[i][j] = 0x0F00;
			}
			else{
				result_img[i][j] = 0xF000;
			}
		}
	}
	
    return 0;
}