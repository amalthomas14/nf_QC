#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { QC } from './workflows/qc'

workflow NF_QC {
    QC ()
    }

workflow {
    NF_QC ()
}
