process BCL2FASTQ {
    // tag {"$meta.lane" ? "$meta.id"+"."+"$meta.lane" : "$meta.id" }
    label 'process_high'

    container "quay.io/nf-core/bcl2fastq:2.20.0.422"

    input:
    path(samplesheet)
    path(run_dir)
    path(output_dir)

    output:
    path("${output_dir.SimpleName}/**_S[1-9]*_R?_00?.fastq.gz")          , emit: fastq
    // path("${output_dir}/**_S[1-9]*_I?_00?.fastq.gz")          , optional:true, emit: fastq_idx
    path("${output_dir.SimpleName}/**Undetermined_S0*_R?_00?.fastq.gz")  , emit: undetermined
    // path("${output_dir}/**Undetermined_S0*_I?_00?.fastq.gz")  , optional:true, emit: undetermined_idx
    path("${output_dir.SimpleName}/Reports")                             , emit: reports
    path("${output_dir.SimpleName}/Stats")                               , emit: stats
    path("InterOp/*.bin")                       , emit: interop
    path("versions.yml")                        , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    // Exit if running this module with -profile conda / -profile mamba
    if (workflow.profile.tokenize(',').intersect(['conda', 'mamba']).size() >= 1) {
        error "BCL2FASTQ module does not support Conda. Please use Docker / Singularity / Podman instead."
    }
    def args = task.ext.args ?: ''
    def args2 = task.ext.args2 ?: ''
    def args3 = task.ext.args3 ?: ''
    def input_tar = run_dir.toString().endsWith(".tar.gz") ? true : false
    def input_dir = input_tar ? run_dir.toString() - '.tar.gz' : run_dir
    """
    bcl2fastq \\
        $args \\
        --output-dir ${output_dir} \\
        --runfolder-dir ${input_dir} \\
        --sample-sheet ${samplesheet} \\

    cp -r ${input_dir}/InterOp .

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bcl2fastq: \$(bcl2fastq -V 2>&1 | grep -m 1 bcl2fastq | sed 's/^.*bcl2fastq v//')
    END_VERSIONS
    """
}
