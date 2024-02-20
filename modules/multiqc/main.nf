process MULTIQC {
    tag "Running MultiQC"
    label "process_low"
   
    container  "quay.io/biocontainers/multiqc:1.18--pyhdfd78af_0"
   
   input:
   path '*'

   output:
   path 'multiqc_report.html'

   script:
   """
   multiqc .
   """
}
