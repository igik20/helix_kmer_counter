#!/usr/bin/env nextflow

/*
*  This module is created for solving the issue with pairinf input files
*  it usefull in a situation where many couplesof files that have to be paired but fromFilePairs is usable
*  for example there are three files in dir1 that have the names as file1.txt file2.txt file3.txt
*  and there is a correspondance with the three files in dir2 (or dir1 again) myfile1.out myfile2.out myfile3.txt
*  so file1.txt has to be processed only with myfile1.out and no th4e others 
*  same goes for file2 and 3 ecc..
*  this modules basically creates the correct input cuple for other scripts that might need that
*  WARNING  the scripts will search for an asterisc to understand ifthe input is a glob patterm
*       if it does find it will use it to obtain the keyword matcher (in the example above are the numbers)
*       that is basically the item that declares the relationship among the couples this is expected to be 
*       inside an asterisc <*> argument, so glob patterns allowed are only tose using an asterisc
*
* WARNING  if the first file does not have an asteriscs, so is not intended to be a glob pattern
*	the scripts associates such file with all those found in the second pattern in couples like:
*	file1.txt with file2.txt,  file1.txt with file3.txt, ecc.. where file2.txt is the first element found in
*	the second pattern.
*	if by any chanche a . or a ? signs are used for glob patterns the outcome of this script is uncertain,
*	probably all files are matched with all others or it could be some sort of error
*	 
*/


nextflow.enable.dsl=2

params.help = false


// this prints the help in case you use --help parameter in the command line and it stops the pipeline
if (params.help) {
	log.info 'This is the help section of this pipeline'
	log.info 'Here is a brief description of the pipeline itself  : '
	log.info '	This module is created for solving the issue with pairinf input files'
	log.info '	it usefull in a situation where many couplesof files that have to be paired but fromFilePairs is usable'
	log.info '      for example there are three files in dir1 that have the names as file1.txt file2.txt file3.txt'
	log.info '      and there is a correspondance with the three files in dir2 (or dir1 again) myfile1.out myfile2.out myfile3.txt'
	log.info '      so file1.txt has to be processed only with myfile1.out and no th4e others'
	log.info '      same goes for file2 and 3 ecc..'
	log.info '      this modules basically creates the correct input cuple for other scripts that might need that'
	log.info '      WARNING  the scripts will search for an asterisc to understand ifthe input is a glob patterm'
	log.info '      	if it does find it will use it to obtain the keyword matcher (in the example above are the numbers)'
	log.info '              that is basically the item that declares the relationship among the couples this is expected to b'
	log.info '              inside an asterisc <*> argument, so glob patterns allowed are only tose using an asterisc'
	log.info '              '
	log.info '	WARNING  if the first file does not have an asteriscs, so is not intended to be a glob pattern'
	log.info '		the scripts associates such file with all those found in the second pattern in couples like:'
        log.info '              file1.txt with file2.txt,  file1.txt with file3.txt, ecc.. where file2.txt is the first element found in'
        log.info '              the second pattern.'
        log.info '              if by any chanche a . or a ? signs are used for glob patterns the outcome of this script is uncertain,'
        log.info '              probably all files are matched with all others or it could be some sort of error'
        log.info '              '
	exit 1
}


/*
params.INPUT1 = "${params.TEST_DIR}bubbabubba"
params.INPUT2 = "${params.TEST_DIR}bubbabubba"
*/

workflow pairer {
	
	take:
	input_files1
	input_files2

	main:
	if ( "${input_files1}".contains('*') ) {
		prefix1 = "${input_files1}".split('\\*')[0]
		suffix1 = "${input_files1}".split('\\*')[1]
        prefix2 = "${input_files2}".split('\\*')[0]
		suffix2 = "${input_files2}".split('\\*')[1]
		//println(suffix1)
        try {
            println "try"
            Channel.fromPath(input_files1).map{ it -> [("${it}".split("${prefix1}")[1]).split("${suffix1}")[0], it]}.set{tupled_group1}
            Channel.fromPath(input_files2).map{ it -> [("${it}".split("${prefix2}")[1]).split("${suffix2}")[0], it]}.set{tupled_group2}
        } catch(Exception e) {
            println "Index out of bounds"
        } finally {
            println "finally"
        }
        //tupled_group1.view()
		//tupled_group2.view()
		tupled_group1.combine(tupled_group2, by:0).set{right_pairs}
		//right_pairs.view()
	} else {
		Channel.fromPath(input_files1).map{ it -> ["bubba", it]}.set{tupled_1}
		Channel.fromPath(input_files2).map{ it -> ["bubba", it]}.set{tupled_2}
		//tupled_1.view()
		tupled_1.combine(tupled_2, by:0).set{right_pairs}
		//right_pairs.view()
	}
	
	emit:
	right_pairs
}

workflow {
	pairer(params.INPUT1, params.INPUT2)
}