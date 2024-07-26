process CALC_T_A {
    tag "calculate_T_A on $sample_id"
    label "process_low"

    container "awsecr111/bioinfo:python3.10.12"
    
    input:
    tuple val(sample_id), path(fastq_files)
    
    output:
    path "stats_A_T_*.tsv"

    script:
    def temp_file = "${sample_id}" + "_combined"
    //println "[CALC_T_A]:$sample_id:${fastq_files}"
    """
    cat ${fastq_files.join(' ')} > ${temp_file}
    calculate_T_A.py ${sample_id} ${temp_file}
    """
}
