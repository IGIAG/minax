module binary_matrix_utils.block_matrix;
/** 
 * Generates an the block matrix for a given cube and R
 * Params:
 *   cube = input vectror
 *   R = function_off_set
 * Returns: 
 */
uint[] generate_block_matrix(uint cube,uint[] R){
	uint[] block_matrix = R.dup;
	for(int i = 0;i < block_matrix.length;i++){
		block_matrix[i] = block_matrix[i] ^ cube;
	}
	return block_matrix;
}
