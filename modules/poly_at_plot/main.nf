process PLOT_T_A {
    label "process_low"
    
    container "awsecr111/bioinfo:python3.10.12"
    
    input:
    path(tables)

    output:
    path("combined_data_A_T.tsv")
    path("T_nucleotide_plot.pdf")
    path("T_nucleotide_plot.png")
    path("A_nucleotide_plot.pdf")
    path("A_nucleotide_plot.png")

    script:
    """
    plot_A_T.R ${tables.join(' ')}
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python3 --version | sed 's/Python //g')
    END_VERSIONS
    """
}
