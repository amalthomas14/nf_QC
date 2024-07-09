process CALC_T_A {
    tag "calculate_T_A on $sample_id"
    label "process_low"

    input:
    tuple val(sample_id), path(fastq_files)
    
    output:
    path "${params.outdir_stats}/stats_A_T_*.tsv"

    script:
    """
    if [ ${fastq_files.size()} -eq 1 ]; then
        # Single-end
        python3 calculate_T_A.py ${params.outdir_stats}/${sample_id} ${fastq_files[0]}
    else
        # Paired-end
        zcat ${fastq_files[0]} ${fastq_files[1]} | python3 calculate_T_A.py ${params.outdir_stats}/${sample_id}_output.tsv -
    fi
    """
}
