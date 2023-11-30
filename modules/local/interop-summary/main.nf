process INTEROP_SUMMARY {
    label 'process_low'

    container "quay.io/biocontainers/illumina-interop:1.2.4--hdbdd923_2"

    input:
    path run_dir
    //path output_dir

    output:
    path "*.csv", emit: interop_csv
    path "versions.yml"           , emit: versions
    path "interop_step_controller"           , emit: interop_step_controller

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    interop_summary "$run_dir" --csv=1 > "./interop_summary.csv"
    interop_index-summary "$run_dir" --csv=1 > "./interop_index-summary.csv"
    cat  > interop_step_controller
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        interop: \$( interop_summary | sed -e "s/# Version: v//g" )
    END_VERSIONS
    """
}
