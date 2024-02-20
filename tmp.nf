#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { NF_QC } from './workflows/nf_qc'

workflow NF
