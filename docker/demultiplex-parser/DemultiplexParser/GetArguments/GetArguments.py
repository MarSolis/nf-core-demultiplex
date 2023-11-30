import getopt

class GetArguments:
    def __init__(self, argv):
        self.argv = argv

    def arguments(self):
        input_dir = None
        multiqc_file = None
        output_dir = None

        try:
            opts, args = getopt.getopt(self.argv, "i:m:o:")

        except:
            print("Error")

        for opt, arg in opts:
            if opt in ['-i']:
                input_dir = arg
            elif opt in ['-m']:
                multiqc_file = arg
            elif opt in ['-o']:
                output_dir = arg

        return (input_dir, multiqc_file,output_dir)