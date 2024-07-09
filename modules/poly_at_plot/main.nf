process PLOT_T_A {
    label "process_low"
    
    input:
    path(tables)

    output:
    path("${params.outdir}/combined_data_A_T.tsv")
    path("${params.outdir}/T_nucleotide_plot.pdf")
    path("${params.outdir}/T_nucleotide_plot.png")
    path("${params.outdir}/A_nucleotide_plot.pdf")
    path("${params.outdir}/A_nucleotide_plot.png")

    script:
    """
    Rscript plot_A_T.R ${tables}
    """
}
