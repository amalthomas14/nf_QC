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
    def list_size   = fastq_files.size()
    println "[CALC_T_A]:$sample_id:${list_size}"
    //println "[CALC_T_A]:$sample_id:${fastq_files}"
    """
    if [ ${list_size} -eq 2 ]; then
        echo "paired"
        gzip -cd ${fastq_files[0]} > temp_s1
        gzip -cd ${fastq_files[1]} > temp_s2
        cat temp_s1 temp_s2 | calculate_T_A.py ${sample_id} -
        rm temp_s1 temp_s2
    else
        echo "single"
        gzip -cd ${fastq_files[0]} > temp_s1
        cat temp_s1 | calculate_T_A.py ${sample_id} -
        rm temp_s1
    fi
    """
}
