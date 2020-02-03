version development

workflow meta_spades {

    input {
        Array[File] reads
        String destination
    }


    call fastp { input: reads = reads }

    call copy as copy_report {
         input:
            destination = destination + "/report",
            files = [fastp.report_json, fastp.report_html]
        }

    call meta_spades {
        input: reads = reads
    }

    call copy as copy_results {
         input:
            destination = destination,
            files = [meta_spades.out]
        }

    output {
        File out = meta_spades.out
    }
}

task fastp {
    input {
        Array[File] reads
    }

    Boolean is_paired = if(length(reads) > 1) then true else false

    command {
        fastp --cut_front --cut_tail --cut_right --trim_poly_g --trim_poly_x --overrepresentation_analysis \
            -i ~{reads[0]} -o ~{basename(reads[0], ".fq.gz")}_cleaned.fq.gz \
            ~{if( is_paired ) then "--detect_adapter_for_pe " + "--correction -I "+reads[1]+" -O " + basename(reads[1], ".fq.gz") +"_cleaned.fq.gz" else ""}
    }

    runtime {
        docker: "quay.io/biocontainers/fastp@sha256:ac9027b8a8667e80cc1661899fb7e233143b6d1727d783541d6e0efffbb9594e" #0.20.0--hdbcaa40_0
    }

    output {
        File report_json = "fastp.json"
        File report_html = "fastp.html"
        Array[File] reads_cleaned = if( is_paired )
            then [basename(reads[0], ".fq.gz") + "_cleaned.fq.gz", basename(reads[1], ".fq.gz") + "_cleaned.fq.gz"]
            else [basename(reads[0], ".fq.gz") + "_cleaned.fq.gz"]
    }
}

task meta_spades {
    input {
        String results = "results"
        Array[File] reads
        String cut_off = "auto"
    }
    command {
        metaspades.py -m 4048 -1 ~{reads[0]} -2 ~{reads[1]} --cov-cutoff ~{cut_off} -o ~{results}
    }

    runtime {
        docker: "quay.io/biocontainers/spades@sha256:9fc72d13bdd3b33af6c8f9bf03512dc486a50957d41eb27ed98eca0b98fa50ba"#:3.14.0--h2d02072_0"
    }

    output {
        File out = "results"
    }
}

task copy {
    input {
        Array[File] files
        String destination
    }

    String where = sub(destination, ";", "_")

    command {
        mkdir -p ~{where}
        cp -L -R -u ~{sep=' ' files} ~{where}
        declare -a files=(~{sep=' ' files})
        for i in ~{"$"+"{files[@]}"};
          do
              value=$(basename ~{"$"}i)
              echo ~{where}/~{"$"}value
          done
    }

    output {
        Array[File] out = read_lines(stdout())
    }
}