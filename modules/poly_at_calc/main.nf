process CALC_T_A {
    tag "calculate_T_A on $sample_id"
    label "process_low"

    container "awsecr111/bioinfo:python3.10.12"
    
    input:
    tuple val(sample_id), path(fastq_files)
    
    output:
    path "stats_A_T_*.tsv"

    script:
    def input_files = fastq_files.collect { "-i ${it}" }.join(" ")
    def output_file = "stats_A_T_${sample_id}.tsv"
    println "[CALC_T_A]:$sample_id:${input_files}"
    //println "[CALC_T_A]:$sample_id:${fastq_files}"
    """
    calculate_T_A.py -s ${sample_id} -o ${output_file} ${input_files}
    """
}
