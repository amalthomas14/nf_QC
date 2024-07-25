process CALC_T_A {
    tag "calculate_T_A on $sample_id"
    label "process_low"

    container "awsecr111/bioinfo:python3.10.12"
    
    input:
    tuple val(sample_id), path(fastq_files)
    
    output:
    path "stats_A_T_*.tsv"

    script:
    //println "[CALC_T_A]:$sample_id:${fastq_files}"
    """
    gzip -d -c ${fastq_files.join(' ')} | calculate_T_A.py ${sample_id} -
    """
}
