process GENERATEPNG {
    tag "GeneratePNG"

    container "interopgnuplot:latest"

    input:
    path compute_script
    path run_dir
    path output_dir
    path path_interop
    each command
    val width
    val height
    val dpi
    val interop_step_controller



    script:
    """
    sh $compute_script --command-name "$path_interop/$command" --input-name $run_dir --output-name "$output_dir$command".png"" --width $width --height $height --dpi $dpi
    echo ${interop_step_controller}
    """
}


compute_script = params.compute_script
run_dir = params.run_dir
output_dir = params.output_dir
path_interop = params.path_interop
command = params.command
width = params.width
height = params.height
dpi = params.dpi



/*
 * main script flow
 */
workflow {
  GENERATEPNG(compute_script,run_dir,output_dir,path_interop,command,width,height,dpi,interop_step_controller)
}
