process CALC_T_A {
    tag "calculate_T_A on $sample_id"
    label "process_low"

    input:
    tuple val(sample_id), path(fastq_files)
    
    output:
    path "stats_A_T_*.tsv"

    script:
    //println "[CALC_T_A]:$sample_id:${fastq_files}"
    """
    zcat ${fastq_files.join(' ')} | calculate_T_A.py ${sample_id} -
    """
}
