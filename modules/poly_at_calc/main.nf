process CALC_T_A {
    tag "calculate_T_A on $sample_id"
    label "process_med"

    container "awsecr111/bioinfo:python3.10.12"
    
    input:
    tuple val(sample_id), path(fastq_files)
    
    output:
    path "stats_A_T_*.tsv"

    script:
    //def output_file = "stats_A_T_${sample_id}.tsv"
    //def list_size   = fastq_files.size()
    //println "[CALC_T_A]:$sample_id:${list_size}"
    println "[CALC_T_A]:$sample_id:${fastq_files}"
    """
    gzip -cd ${fastq_files.join(' ')} > temp_file
    cat temp_file | calculate_T_A.py ${sample_id} -
    rm temp_file
    """
}
