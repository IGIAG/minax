module block_matrix;

uint[] generate_block_matrix(uint cube,uint[] R){
	uint[] block_matrix = R.dup;
	for(int i = 0;i < block_matrix.length;i++){
		block_matrix[i] = block_matrix[i] ^ cube;
	}
	return block_matrix;
}
