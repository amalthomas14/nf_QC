process FASTQC {
    tag "FASTQC on ${sample_id}"
    label "process_low"
    
    container "quay.io/biocontainers/fastqc:0.12.1--hdfd78af_0"

    input:
    tuple val(sample_id), path(reads)

    output:
    path "fastqc_${sample_id}"

    script:
    """
    mkdir fastqc_${sample_id}
    fastqc -o fastqc_${sample_id} -f fastq ${reads}
    """

}
