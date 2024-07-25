#!/usr/bin/env nextflow

/*
 * pipeline input parameters
 */

if (params.input) { ch_input = file(params.input) } else { exit 1, 'Input samplesheet not specified!' }

include { FASTQC } from '../modules/fastqc'
include { MULTIQC } from '../modules/multiqc'
include { CALC_T_A } from '../modules/poly_at_calc'
include { PLOT_T_A } from '../modules/poly_at_plot'


workflow QC {

log.info """\
         QC   P I P E L I N E    
         ===================================
         samplesheet   : ${params.input}
         outdir        : ${params.outdir}
         outdir_stats  : ${params.outdir_stats}
         fastqc_outdir : ${params.fastqc_outdir}
         multiqc_outdir: ${params.multiqc_outdir}
         ===================================
         """
         .stripIndent()
    
    Channel
        .fromPath(params.input, checkIfExists: true)
        .splitCsv(header: true)
        .filter { it.fastq_2 == "" }
        .map { row -> tuple(row.sample, [row.fastq_1]) }
        .groupTuple()
	.map { sample, fastqs -> tuple(sample, fastqs.flatten()) }   
        .set { single_fq_ch }
    //single_fq_ch.view()
    Channel
        .fromPath(params.input, checkIfExists: true)
        .splitCsv(header: true)
        .filter {it.fastq_2 != ""}
        .map { row -> tuple(row.sample, [row.fastq_1, row.fastq_2]) }
	.groupTuple()
	.map { sample, fastqs -> tuple(sample, fastqs.flatten()) }
        .set { paired_fq_ch }

    //paired_fq_ch.view()
    all_fq_ch = single_fq_ch.mix(paired_fq_ch)
		.groupTuple()
		.map { sample, fastqs -> tuple(sample, fastqs.flatten()) }
    all_fq_ch.view()
/*
    Channel
        .fromPath(params.input, checkIfExists: true)
        .splitCsv(header: true)
        .filter { it.fastq_2 == "" }
        .map { row -> tuple(row.sample, [row.fastq_1]) }
        .set { single_fq_ch }
    //single_fq_ch.view()
    Channel
        .fromPath(params.input, checkIfExists: true)
        .splitCsv(header: true)
        .filter {it.fastq_2 != ""}
        .map { row -> tuple(row.sample, [row.fastq_1, row.fastq_2]) }
        .set { paired_fq_ch }
    //paired_fq_ch.view()
    all_fq_ch = single_fq_ch.mix(paired_fq_ch)
    all_fq_ch.view()
*/
    CALC_T_A(all_fq_ch)
    CALC_T_A.out.collect().view()

    PLOT_T_A(CALC_T_A.out.collect())

    //fastqc_out_ch = FASTQC(all_fq_ch)
    //fastqc_out_ch.view()

    //multiqc_out_ch = MULTIQC(fastqc_out_ch.collect())
    //multiqc_out_ch.view()

}

workflow.onComplete {
    log.info ( workflow.success ? "\nSUCCESS! Open the following report in your browser --> ${params.outdir}/${params.multiqc_outdir}/multiqc_report.html\n" : "FAIL" )
}
