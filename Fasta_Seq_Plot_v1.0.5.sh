#!/usr/bin/env bash

func_copyright ()
{
    cat <<COPYRIGHT

This program is free software: you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option)
any later version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
more details.

You should have received a copy of the GNU General Public License along
with this program. If not, see <https://www.gnu.org/licenses/>.

COPYRIGHT
};

func_authors ()
{
    cat <<AUTHORS
Author:                            Rodolfo Aramayo
WORK_EMAIL:                        raramayo@tamu.edu
PERSONAL_EMAIL:                    rodolfo@aramayo.org
AUTHORS
};

func_usage()
{
    cat <<EOF
###########################################################################
ARAMAYO_LAB
$(func_copyright)

SCRIPT_NAME:                    $(basename ${0})
SCRIPT_VERSION:                 ${version}

USAGE: $(basename ${0})
 -p Proteins_Fasta_File.fa      # REQUIRED (Proteins File)
                                 (if '-t' Not Provided)
 -t Transcripts_Fasta_File.fa   # REQUIRED (Transcripts File)
                                 (if '-p' Not Provided)
 -n 'Homo sapiens'              # REQUIRED (Species Name)
 -k 0                           # OPTIONAL (default=0='Do Not Print')
 -z TMPDIR Location             # OPTIONAL (default=0='TMPDIR Run')

TYPICAL COMMANDS:
 $(basename ${0}) -p Proteins_Fasta_File.fa -n 'Homo sapiens'
 $(basename ${0}) -t Transcripts_Fasta_File.fa -n 'Homo sapiens'

INPUT01:          -p FLAG       REQUIRED input
                                 ONLY if the '-t' flag associated file
                                 is not provided
INPUT01_FORMAT:                 Proteome Fasta File
INPUT01_DEFAULT:                No default

INPUT02:          -t FLAG       REQUIRED input
                                 ONLY if the '-p' flag associated file
                                 is not provided
INPUT02_FORMAT:                 Transcriptome Fasta File
INPUT02_DEFAULT:                No default

INPUT03:          -n FLAG       REQUIRED input
INPUT03_FORMAT:                 Text
INPUT03_DEFAULT:                None
INPUT03_NOTES:
 The text should correspond to the species name whose fasta file is being
analyzed.

 If the text provided is composed on more than one word (e.g.,
Genus species), then the text must be enclosed by single or double quotes.

INPUT04:          -k FLAG       OPTIONAL input
INPUT04_FORMAT:                 Numeric: '0' == 'Do Not Print' | '1' == 'Print'
INPUT04_DEFAULT:                '0' == 'Do Not Print'
INPUT04_NOTES:
 If this flag is activated (i.e., set to '1'), then, in addition to the
sequence plots generated, a copy of the R Script files that were used to
generate those figures will also be printed to the output directory.

 In theory, these files could be modified (or not) and re-run in R, to
re-generate the sequence plots.

INPUT05:          -z FLAG       OPTIONAL input
INPUT05_FORMAT:                 Numeric: '0' == TMPDIR Run | '1' == Local Run
INPUT05_DEFAULT:                '0' == TMPDIR Run
INPUT05_NOTES:
 '0' Processes the data in the \$TMPDIR directory of the computer used or of
the node assigned by the SuperComputer scheduler.

 Processing the data in the \$TMPDIR directory of the node assigned by the
SuperComputer scheduler reduces the possibility of file error generation
due to network traffic.

 '1' Processes the data in the same directory where the script is being run.

DEPENDENCIES:
 GNU AWK:       Required (https://www.gnu.org/software/gawk/)
 GNU COREUTILS: Required (https://www.gnu.org/software/coreutils/)
 datamash:      Required (http://www.gnu.org/software/datamash)
 R:             Required (https://www.r-project.org/)
                Assumes that the packages tidyverse, ggplot2, and ggeasy
                are already installed
 R - ggplot2:   Required (https://github.com/tidyverse/ggplot2)
 R - ggeasy:    Required (https://github.com/jonocarroll/ggeasy)


$(func_authors)
###########################################################################
EOF
};

## Defining_Script_Current_Version
version="1.0.5";

## Defining_Script_Initial_Version_Data (date '+DATE:%Y/%m/%d%')
version_date_initial="DATE:2022/11/21";

## Defining_Script_Current_Version_Data (date '+DATE:%Y/%m/%d')
version_date_current="DATE:2024/05/14";

## Testing_Script_Input
## Is the number of arguments null?
if [[ ${#} -eq 0 ]];then
    echo -e "\nPlease enter required arguments";
    func_usage;
    exit 1;
fi

while true;do
    case ${1} in
        -h|--h|-help|--help|-\?|--\?)
            func_usage;
            exit 0;
            ;;
        -v|--v|-version|--version)
            printf "Version: ${version} %s\n" >&2;
            exit 0;
            ;;
        -p|--p|-proteome|--proteome)
            proteinsfile=${2};
            shift;
            ;;
        -t|--t|-transcriptome|--transcriptome)
            transcriptsfile=${2};
            shift;
            ;;
        -n|--n|-name|--name)
            species_name=${2};
            shift;
            ;;
        -k|--k|-keep|--keep)
            keep_r_files=${2};
            shift;
            ;;
	-z|--z|-tmp-dir|--tmp-dir)
            tmp_dir=${2};
            shift;
            ;;
        -?*)
            printf '\nWARNNING: Unknown Option (ignored): %s\n\n' ${1} >&2;
            func_usage;
            exit 0;
            ;;
        :)
            printf '\nWARNING: Invalid Option (ignored): %s\n\n' ${1} >&2;
            func_usage;
            exit 0;
            ;;
        \?)
            printf '\nWARNING: Invalid Option (ignored): %s\n\n' ${1} >&2;
            func_usage;
            exit 0;
            ;;
        *)  # Should not get here
            break;
            exit 1;
            ;;
    esac
    shift;
done

## Processing: -p and -t Flags
if [[ ! -z ${proteinsfile} ]];then
    INFILE01=${proteinsfile};
    var_INFILE01="proteins_file";
else
    var_INFILE01="transcripts_file";
fi
if [[ ${var_INFILE01} == "proteins_file" ]];then
    if [[ ! -f ${proteinsfile} ]];
    then
	echo "Please provide a proteome fasta file";
	func_usage;
	exit 1;
    fi
fi
if [[ ! -z ${transcriptsfile} ]];then
    INFILE01=${transcriptsfile};
    var_INFILE01="transcripts_file";
else
    var_INFILE01="proteins_file";
fi
if [[ ${var_INFILE01} == "transcripts_file" ]];then
    if [[ ! -f ${transcriptsfile} ]];then
	echo "Please provide a transcriptome fasta file";
	func_usage;
	exit 1;
    fi
fi
if [[ ! -z ${proteinsfile} && ! -z ${transcriptsfile} ]];then
    echo -e "\nPlease provide either a protein of a transcript file, but not both";
    func_usage;
    exit 1;
fi

## Processing: -n Flag
## Assigning Species Name
if [[ -z ${species_name} ]];then
    echo -e "\nPlease provide a species name";
    func_usage;
    exit 1;
fi

## Processing: -k Flag
## Evaluating_Keeping_R_Files
if [[ -z ${keep_r_files} ]];then
    keep_r_files=${keep_r_files:=0};
else
    keep_r_files=${keep_r_files:=1};
fi

var_regex="^[0-1]+$"
if ! [[ ${keep_r_files} =~ ${var_regex} ]];then
    echo "Please provide a valid number (e.g., 0 or 1), for this variable";
    func_usage;
    exit 1;
fi

## Processing '-z' Flag
## Determining Where The TMPDIR Will Be Generated
if [[ -z ${tmp_dir} ]];then
    tmp_dir=${tmp_dir:=0};
fi

var_regex="^[0-1]+$"
if ! [[ ${tmp_dir} =~ ${var_regex} ]];then
    echo "Please provide a valid number (e.g., 0 or 1), for this variable";
    func_usage;
    exit 1;
fi

## Generating Directories
var_script_out_data_dir=""$(pwd)"/"${INFILE01%.fa}"_Fasta_Seq_Plot.dir";
export var_script_out_data_dir=""$(pwd)"/"${INFILE01%.fa}"_Fasta_Seq_Plot.dir";

if [[ ! -d ${var_script_out_data_dir} ]];then
    mkdir ${var_script_out_data_dir};
else
    rm ${var_script_out_data_dir}/* &>/dev/null;
fi

if [[ -d ${INFILE01%.fa}_Fasta_Seq_Plot.tmp ]];then
    rm -fr ${INFILE01%.fa}_Fasta_Seq_Plot.tmp &>/dev/null;
fi

## Generating/Cleaning TMP Data Directory
if [[ ${tmp_dir} -eq 0 ]];then
    ## Defining Script TMP Data Directory
    var_script_tmp_data_dir=""$(pwd)"/"${INFILE01%.fa}"_Fasta_Seq_Plot.tmp";
    export var_script_tmp_data_dir=""$(pwd)"/"${INFILE01%.fa}"_Fasta_Seq_Plot.tmp";

    if [[ -d ${var_script_tmp_data_dir} ]];then
        rm -fr ${var_script_tmp_data_dir};
    fi

    if [[ -z ${TMPDIR} ]];then
        ## echo "TMPDIR not defined";
        TMP=$(mktemp -d -p ${TMP}); ## &> /dev/null);
        var_script_tmp_data_dir=${TMP};
        export  var_script_tmp_data_dir=${TMP};
    fi

    if [[ ! -z ${TMPDIR} ]];then
        ## echo "TMPDIR defined";
        TMP=$(mktemp -d -p ${TMPDIR}); ## &> /dev/null);
        var_script_tmp_data_dir=${TMP};
        export  var_script_tmp_data_dir=${TMP};
    fi
fi

if [[ ${tmp_dir} -eq 1 ]];then
    ## Defining Script TMP Data Directory
    var_script_tmp_data_dir=""$(pwd)"/"${INFILE01%.fa}"_Fasta_Seq_Plot.tmp";
    export var_script_tmp_data_dir=""$(pwd)"/"${INFILE01%.fa}"_Fasta_Seq_Plot.tmp";

    if [[ ! -d ${var_script_tmp_data_dir} ]];then
        mkdir ${var_script_tmp_data_dir};
    else
        rm -fr ${var_script_tmp_data_dir};
        mkdir ${var_script_tmp_data_dir};
    fi
fi

## Initializing_Log_File
time_execution_start=$(date +%s);
echo -e "Starting Processing on: "$(date)"" \
     > ${var_script_out_data_dir}/${INFILE01%.fa}_Fasta_Seq_Plot.log;

## Verifying_Software_Dependency_Existence
echo -e "Verifying Software Dependency Existence on: "$(date)"" \
     >> ${var_script_out_data_dir}/${INFILE01%.fa}_Fasta_Seq_Plot.log;
## Determining_Current_Computer_Platform
osname=$(uname -s);
cputype=$(uname -m);
case "${osname}"-"${cputype}" in
    Linux-x86_64 )           plt=Linux ;;
    Darwin-x86_64 )          plt=Darwin ;;
    Darwin-*arm* )           plt=Silicon ;;
    CYGWIN_NT-* | MINGW*-* ) plt=CYGWIN_NT ;;
    Linux-*arm* )            plt=ARM ;;
esac
## Determining_GNU_Bash_Version
if [[ ${BASH_VERSINFO:-0} -ge 4 ]];then
    echo "GNU_BASH version "${BASH_VERSINFO}" is Installed" >> ${var_script_out_data_dir}/${INFILE01%.fa}_Fasta_Seq_Plot.log;
else
    echo "GNU_BASH version 4 or higher is Not Installed";
    echo "Please Install GNU_BASH version 4 or higher";
    rm -fr ${var_script_out_data_dir};
    rm -fr ${var_script_tmp_data_dir};
    func_usage;
    exit 1;
fi
## Testing_GNU_Awk_Installation
type gawk &> /dev/null;
var_sde=$(echo ${?});
if [[ ${var_sde} -eq 0 ]];then
    echo "GNU_AWK is Installed" >> ${var_script_out_data_dir}/${INFILE01%.fa}_Fasta_Seq_Plot.log;
else
    echo "GNU_AWK is Not Installed";
    echo "Please Install GNU_AWK";
    rm -fr ${var_script_out_data_dir};
    rm -fr ${var_script_tmp_data_dir};
    func_usage;
    exit 1;
fi
## Testing_DATAMASH_Installation
type datamash &> /dev/null;
var_sde=$(echo ${?});
if [[ ${var_sde} -eq 0 ]];then
    echo "datamash is Installed" >> ${var_script_out_data_dir}/${INFILE01%.fa}_Fasta_Seq_Plot.log;
else
    echo "DATAMASH is Not Installed";
    echo "Please Install DATAMASH";
    rm -fr ${var_script_out_data_dir};
    rm -fr ${var_script_tmp_data_dir};
    func_usage;
    exit 1;
fi
## Testing_Rscript_Installation
type Rscript &> /dev/null;
var_sde=$(echo ${?});
if [[ ${var_sde} -eq 0 ]];then
    echo "R is Installed" >> ${var_script_out_data_dir}/${INFILE01%.fa}_Fasta_Seq_Plot.log;
else
    echo "R is Not Installed";
    echo "Please Install R";
    rm -fr ${var_script_out_data_dir};
    rm -fr ${var_script_tmp_data_dir};
    func_usage;
    exit 1;
fi

echo -e "Software Dependencies Verified on: "$(date)"\n" >> ${var_script_out_data_dir}/${INFILE01%.fa}_Fasta_Seq_Plot.log;
echo -e "Script Running on: "${osname}", "${cputype}"\n" >> ${var_script_out_data_dir}/${INFILE01%.fa}_Fasta_Seq_Plot.log;

## set LC_ALL to "C"
export LC_ALL="C";

## START
echo -e "Command Issued Was:" >> ${var_script_out_data_dir}/${INFILE01%.fa}_Fasta_Seq_Plot.log;
echo -e "\tScript Name:\t$(basename ${0})" >> ${var_script_out_data_dir}/${INFILE01%.fa}_Fasta_Seq_Plot.log;

if [[ ${var_INFILE01} == "proteins_file" ]];then
    echo -e "\t-p Flag:\tProteome" >> ${var_script_out_data_dir}/${INFILE01%.fa}_Fasta_Seq_Plot.log;
else
    echo -e "\t-t Flag:\tTranscriptome" >> ${var_script_out_data_dir}/${INFILE01%.fa}_Fasta_Seq_Plot.log;
fi

echo -e "\t-n Flag:\t"${species_name}"" >> ${var_script_out_data_dir}/${INFILE01%.fa}_Fasta_Seq_Plot.log;


if [[ ${keep_r_files} -eq 0 ]];then
    echo -e "\t-k Flag:\tRScript Files Not Requested" >> ${var_script_out_data_dir}/${INFILE01%.fa}_Fasta_Seq_Plot.log;
else
    echo -e "\t-z Flag:\tRScript Files Requested" >> ${var_script_out_data_dir}/${INFILE01%.fa}_Fasta_Seq_Plot.log;
fi

if [[ ${tmp_dir} -eq 0 ]];then
    echo -e "\t-z Flag:\t\$TMPDIR Directory Requested" >> ${var_script_out_data_dir}/${INFILE01%.fa}_Fasta_Seq_Plot.log;
else
    echo -e "\t-z Flag:\tLocal Directory Requested" >> ${var_script_out_data_dir}/${INFILE01%.fa}_Fasta_Seq_Plot.log;
fi

echo -e "#Identifier\tLength" > ${var_script_tmp_data_dir}/0001_${INFILE01%.fa};

## Convert 'spaces' (040) to '=' (075)
awk -F "\t" -v OFS="\t" '{gsub(/\040/,"\075",$1);print $0}' "$INFILE01" | \
    awk -F "\t" -v OFS="\t" 'BEGIN{RS=">"}NR>1{sub("\n","\t"); gsub("\n",""); print RS$0 "\t" length($(NF))}' | \
    awk -F "\t" -v OFS="\t" '{gsub(/\075/,"\040");print $1 "\t" $NF}' | \
    sed 's/>//' \
	>> ${var_script_tmp_data_dir}/0001_${INFILE01%.fa};

var_min=$(datamash --header-in min 2 < ${var_script_tmp_data_dir}/0001_${INFILE01%.fa} );
var_q1=$(datamash --header-in q1 2 < ${var_script_tmp_data_dir}/0001_${INFILE01%.fa} );
var_median=$(datamash --header-in median 2 < ${var_script_tmp_data_dir}/0001_${INFILE01%.fa} );
var_q3=$(datamash --header-in q3 2 < ${var_script_tmp_data_dir}/0001_${INFILE01%.fa} );
var_iqr=$(datamash --header-in iqr 2 < ${var_script_tmp_data_dir}/0001_${INFILE01%.fa} );

var_median_iqr=$(( ${var_median%.*} + ${var_iqr%.*} ));
var_median_iqr_2=$(( ${var_median_iqr%.*} * 2 ))
var_median_iqr_4=$(( ${var_median_iqr%.*} * 4 ))

var_max=$(datamash --header-in max 2 < ${var_script_tmp_data_dir}/0001_${INFILE01%.fa} );

## var_column_A="${var_min%.*} ${var_q1%.*} ${var_median%.*} ${var_q3%.*} ${var_median_iqr%.*} ${var_median_iqr_2%.*} ${var_median_iqr_4%.*}"; ## Rejected x labels
var_column_A="${var_min%.*} $((${var_q1%.*}+1)) $((${var_median%.*}+1)) $((${var_q3%.*}+1)) $((${var_median_iqr%.*}+1)) $((${var_median_iqr_2%.*}+1)) $((${var_median_iqr_4%.*}+1))";

var_column_B="${var_q1%.*} ${var_median%.*} ${var_q3%.*} ${var_median_iqr%.*} ${var_median_iqr_2%.*} ${var_median_iqr_4%.*} ${var_max%.*}";

paste <(for i in $var_column_A;do echo $i;done) <(for i in $var_column_B;do echo $i;done) > ${var_script_tmp_data_dir}/0002_File;

readarray -t lines < ${var_script_tmp_data_dir}/0002_File;

var_counter="1";
var_record_number=$(awk 'END{print NR}' ${var_script_tmp_data_dir}/0002_File);

for i in "${lines[@]}";do
    var_field_01=$(echo $i | awk '{print $1}');
    var_field_02=$(echo $i | awk '{print $2}');

    if [[ ${var_counter} -ne ${var_record_number} ]];then
	echo -n "${var_field_01}," >> ${var_script_tmp_data_dir}/0003_File;
	echo -n "\"${var_field_01}-${var_field_02}\"," >> ${var_script_tmp_data_dir}/0004_File;
	echo -n "Length < ${var_field_02} ~ tags[${var_counter}], " >> ${var_script_tmp_data_dir}/0005_File;
    else
	echo -n "${var_field_01}," >> ${var_script_tmp_data_dir}/0003_File;
	echo -n "${var_field_02}" >> ${var_script_tmp_data_dir}/0003_File;
	echo -n "\"${var_field_01}-${var_field_02}\"" >> ${var_script_tmp_data_dir}/0004_File;
	echo -n "Length < $((${var_field_02}+1)) ~ tags[${var_counter}]" >> ${var_script_tmp_data_dir}/0005_File;
    fi
    ((var_counter++))
done

readarray -t breaks < ${var_script_tmp_data_dir}/0003_File;
readarray -t tags < ${var_script_tmp_data_dir}/0004_File;
readarray -t lengths < ${var_script_tmp_data_dir}/0005_File;

if [[ ${var_INFILE01} == "proteins_file" ]];then
    echo -e "\
#!/usr/bin/env R

# Script produced by Fasta_Seq_Plot script (https://github.com/raramayo/Fasta_Seq_Plot_Bash).
# Author: Rodolfo Aramayo (rodolfo@aramayo.org).
# Released under the GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007.

library(tidyverse)
library(ggeasy)
library(ggplot2)

setwd(\"${var_script_tmp_data_dir}\")

proteome <- read.delim(\"0002_File\", header=FALSE, comment.char=\"#\")
data <- read_delim(file = \"0001_${INFILE01%.fa}\", delim = '\\\t',  show_col_types = 'FALSE' )
v <- data %>% select(Length)

sink(\"0006_summary\")
summary(v)
sink()

breaks <- c(${breaks[*]})
tags <- c(${tags[*]})
group_tags <- cut(v\$Length,breaks=breaks,include.lowest=TRUE,right=FALSE,labels=tags)
v <- data %>% select(Length)

pdf(file = \"${INFILE01}_Fasta_Seq_Plot_01.pdf\", width=10, height=10)

ggplot(data = as_tibble(group_tags), mapping = aes(x=value)) +
geom_bar(fill=\"blue\",color=\"white\",alpha=0.7) +
stat_count(geom=\"text\", aes(label=sprintf(\"%.4f\",after_stat(count)/length(group_tags))), vjust=-0.5) +
labs(x= 'Protein Size (aar)') +
theme_minimal() +
ggtitle(quote(bolditalic(\"${species_name}\"))) +
ggeasy::easy_center_title()

dev.off()

png(file = \"${INFILE01}_Fasta_Seq_Plot_01.png\", width=15000, height=15000, res=1500)

ggplot(data = as_tibble(group_tags), mapping = aes(x=value)) +
geom_bar(fill=\"blue\",color=\"white\",alpha=0.7) +
stat_count(geom=\"text\", aes(label=sprintf(\"%.4f\",after_stat(count)/length(group_tags))), vjust=-0.5) +
labs(x= 'Protein Size (aar)') +
theme_minimal() +
ggtitle(quote(bolditalic(\"${species_name}\"))) +
ggeasy::easy_center_title()

dev.off()

" > ${var_script_tmp_data_dir}/0006_File.R;

    R --vanilla < ${var_script_tmp_data_dir}/0006_File.R &> ${var_script_tmp_data_dir}/0006_File.R.log;

    echo -e "\
#!/usr/bin/env R

# Script produced by Fasta_Seq_Plot script (https://github.com/raramayo/Fasta_Seq_Plot_Bash).
# Author: Rodolfo Aramayo (rodolfo@aramayo.org).
# Released under the GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007.

library(tidyverse)
library(ggeasy)
library(ggplot2)

setwd(\"${var_script_tmp_data_dir}\")

proteome <- read.delim(\"0002_File\", header=FALSE, comment.char=\"#\")
data <- read_delim(file = \"0001_${INFILE01%.fa}\", delim = '\\\t',  show_col_types = 'FALSE' )
v <- data %>% select(Length)

sink(\"0007_summary\")
summary(v)
sink()

pdf(file = \"${INFILE01}_Fasta_Seq_Plot_02.pdf\", width=10, height=10)

ggplot(data = v, mapping = aes(x=Length)) +
geom_histogram(aes(y=..density..), fill = \"dark green\" , color = \"white\", alpha = 0.7) +
geom_density() +
geom_rug() +
labs(x = 'Protein Size (aar)') +
theme_minimal() +
ggtitle(quote(bolditalic(\"${species_name}\"))) +
ggeasy::easy_center_title()

dev.off()

png(file = \"${INFILE01}_Fasta_Seq_Plot_02.png\", width=15000, height=15000, res=1500)

ggplot(data = v, mapping = aes(x=Length)) +
geom_histogram(aes(y=..density..), fill = \"dark green\" , color = \"white\", alpha = 0.7) +
geom_density() +
geom_rug() +
labs(x = 'Protein Size (aar)') +
theme_minimal() +
ggtitle(quote(bolditalic(\"${species_name}\"))) +
ggeasy::easy_center_title()

dev.off()

" > ${var_script_tmp_data_dir}/0007_File.R;

    R --vanilla < ${var_script_tmp_data_dir}/0007_File.R &> ${var_script_tmp_data_dir}/0007_File.R.log;

    echo -e "\
#!/usr/bin/env R

# Script produced by Fasta_Seq_Plot script (https://github.com/raramayo/Fasta_Seq_Plot_Bash).
# Author: Rodolfo Aramayo (rodolfo@aramayo.org).
# Released under the GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007.

library(tidyverse)
library(ggeasy)
library(ggplot2)

setwd(\"${var_script_tmp_data_dir}\")

proteome <- read.delim(\"0002_File\", header=FALSE, comment.char=\"#\")
data <- read_delim(file = \"0001_${INFILE01%.fa}\", delim = '\\\t',  show_col_types = 'FALSE' )
v <- data %>% select(Length)

breaks <- c(${breaks[*]})
tags <- c(${tags[*]})
group_tags <- cut(v\$Length,breaks=breaks,include.lowest=TRUE,right=FALSE,labels=tags)

vgroup <- as_tibble(v) %>% mutate(tag = case_when(${lengths[*]}))

sink(\"0008_summary_01\")
summary(vgroup)
sink()

vgroup\$tag <- factor(vgroup\$tag,levels = tags, ordered = FALSE)

sink(\"0008_summary_02\")
summary(vgroup$tag)
sink()

pdf(file = \"${INFILE01}_Fasta_Seq_Plot_03.pdf\", width=10, height=10)

ggplot(data = vgroup, mapping = aes(x=tag,y=log10(Length))) +
geom_jitter(aes ( color = \"blue\" ), alpha = 0.2) +
geom_boxplot( fill =\"bisque\", color = \"black\", alpha = 0.3) +
labs( x = 'Protein Size (aar)') +
guides(color = FALSE) +
theme_minimal() +
ggtitle(quote(bolditalic(\"${species_name}\"))) +
ggeasy::easy_center_title()

dev.off()

png(file = \"${INFILE01}_Fasta_Seq_Plot_03.png\", width=15000, height=15000, res=1500)

ggplot(data = vgroup, mapping = aes(x=tag,y=log10(Length))) +
geom_jitter(aes ( color = \"blue\" ), alpha = 0.2) +
geom_boxplot( fill =\"bisque\", color = \"black\", alpha = 0.3) +
labs( x = 'Protein Size (aar)') +
guides(color = FALSE) +
theme_minimal() +
ggtitle(quote(bolditalic(\"${species_name}\"))) +
ggeasy::easy_center_title()

dev.off()

" > ${var_script_tmp_data_dir}/0008_File.R;

    R --vanilla < ${var_script_tmp_data_dir}/0008_File.R &> ${var_script_tmp_data_dir}/0008_File.R.log;

    echo -e "\n${species_name} Fasta Statistics:\n" >> ${var_script_out_data_dir}/${INFILE01%.fa}_Fasta_Seq_Plot.log;

    cat ${var_script_tmp_data_dir}/0008_summary_02 >> ${var_script_out_data_dir}/${INFILE01%.fa}_Fasta_Seq_Plot.log;

    cp ${var_script_tmp_data_dir}/${INFILE01}_Fasta_Seq_Plot_01.pdf ${var_script_out_data_dir}/${INFILE01}_Proteome_Fasta_Seq_Plot_01.pdf;
    cp ${var_script_tmp_data_dir}/${INFILE01}_Fasta_Seq_Plot_02.pdf ${var_script_out_data_dir}/${INFILE01}_Proteome_Fasta_Seq_Plot_02.pdf;
    cp ${var_script_tmp_data_dir}/${INFILE01}_Fasta_Seq_Plot_03.pdf ${var_script_out_data_dir}/${INFILE01}_Proteome_Fasta_Seq_Plot_03.pdf;

    cp ${var_script_tmp_data_dir}/${INFILE01}_Fasta_Seq_Plot_01.png ${var_script_out_data_dir}/${INFILE01}_Proteome_Fasta_Seq_Plot_01.png;
    cp ${var_script_tmp_data_dir}/${INFILE01}_Fasta_Seq_Plot_02.png ${var_script_out_data_dir}/${INFILE01}_Proteome_Fasta_Seq_Plot_02.png;
    cp ${var_script_tmp_data_dir}/${INFILE01}_Fasta_Seq_Plot_03.png ${var_script_out_data_dir}/${INFILE01}_Proteome_Fasta_Seq_Plot_03.png;

    if [[ ${keep_r_files} -eq 1 ]];then
	cp ${var_script_tmp_data_dir}/0006_File.R ${var_script_out_data_dir}/${INFILE01}_Proteome_Fasta_Seq_Plot_01.R;
	cp ${var_script_tmp_data_dir}/0007_File.R ${var_script_out_data_dir}/${INFILE01}_Proteome_Fasta_Seq_Plot_02.R;
	cp ${var_script_tmp_data_dir}/0008_File.R ${var_script_out_data_dir}/${INFILE01}_Proteome_Fasta_Seq_Plot_03.R;
    fi
else
    echo -e "\
#!/usr/bin/env R

# Script produced by Fasta_Seq_Plot script (https://github.com/raramayo/Fasta_Seq_Plot_Bash).
# Author: Rodolfo Aramayo (rodolfo@aramayo.org).
# Released under the GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007.

library(tidyverse)
library(ggeasy)
library(ggplot2)

setwd(\"${var_script_tmp_data_dir}\")

transcriptome <- read.delim(\"0002_File\", header=FALSE, comment.char=\"#\")
data <- read_delim(file = \"0001_${INFILE01%.fa}\", delim = '\\\t',  show_col_types = 'FALSE' )
v <- data %>% select(Length)

sink(\"0006_summary\")
summary(v)
sink()

breaks <- c(${breaks[*]})
tags <- c(${tags[*]})
group_tags <- cut(v\$Length,breaks=breaks,include.lowest=TRUE,right=FALSE,labels=tags)
v <- data %>% select(Length)

pdf(file = \"${INFILE01}_Fasta_Seq_Plot_01.pdf\", width=10, height=10)

ggplot(data = as_tibble(group_tags), mapping = aes(x=value)) +
geom_bar(fill=\"blue\",color=\"white\",alpha=0.7) +
stat_count(geom=\"text\", aes(label=sprintf(\"%.4f\",after_stat(count)/length(group_tags))), vjust=-0.5) +
labs(x = 'Transcript Size (nts)') +
theme_minimal() +
ggtitle(quote(bolditalic(\"${species_name}\"))) +
ggeasy::easy_center_title()

dev.off()

png(file = \"${INFILE01}_Fasta_Seq_Plot_01.png\", width=15000, height=15000, res=1500)

ggplot(data = as_tibble(group_tags), mapping = aes(x=value)) +
geom_bar(fill=\"blue\",color=\"white\",alpha=0.7) +
stat_count(geom=\"text\", aes(label=sprintf(\"%.4f\",after_stat(count)/length(group_tags))), vjust=-0.5) +
labs(x = 'Transcript Size (nts)') +
theme_minimal() +
ggtitle(quote(bolditalic(\"${species_name}\"))) +
ggeasy::easy_center_title()

dev.off()

" > ${var_script_tmp_data_dir}/0006_File.R;

    R --vanilla < ${var_script_tmp_data_dir}/0006_File.R &> ${var_script_tmp_data_dir}/0006_File.R.log;

    echo -e "\
#!/usr/bin/env R

# Script produced by Fasta_Seq_Plot script (https://github.com/raramayo/Fasta_Seq_Plot_Bash).
# Author: Rodolfo Aramayo (rodolfo@aramayo.org).
# Released under the GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007.

library(tidyverse)
library(ggeasy)
library(ggplot2)

setwd(\"${var_script_tmp_data_dir}\")

transcriptome <- read.delim(\"0002_File\", header=FALSE, comment.char=\"#\")
data <- read_delim(file = \"0001_${INFILE01%.fa}\", delim = '\\\t',  show_col_types = 'FALSE' )
v <- data %>% select(Length)

sink(\"0007_summary\")
summary(v)
sink()

pdf(file = \"${INFILE01}_Fasta_Seq_Plot_02.pdf\", width=10, height=10)

ggplot(data = v, mapping = aes(x=Length)) +
geom_histogram(aes(y=..density..), fill = \"dark green\" , color = \"white\", alpha = 0.7) +
geom_density() +
geom_rug() +
labs(x = 'Transcript Size (nts)') +
theme_minimal() +
ggtitle(quote(bolditalic(\"${species_name}\"))) +
ggeasy::easy_center_title()

dev.off()

png(file = \"${INFILE01}_Fasta_Seq_Plot_02.png\", width=15000, height=15000, res=1500)

ggplot(data = v, mapping = aes(x=Length)) +
geom_histogram(aes(y=..density..), fill = \"dark green\" , color = \"white\", alpha = 0.7) +
geom_density() +
geom_rug() +
labs(x = 'Transcript Size (nts)') +
theme_minimal() +
ggtitle(quote(bolditalic(\"${species_name}\"))) +
ggeasy::easy_center_title()

dev.off()

" > ${var_script_tmp_data_dir}/0007_File.R;

    R --vanilla < ${var_script_tmp_data_dir}/0007_File.R &> ${var_script_tmp_data_dir}/0007_File.R.log;

    echo -e "\
#!/usr/bin/env R

# Script produced by Fasta_Seq_Plot script (https://github.com/raramayo/Fasta_Seq_Plot_Bash).
# Author: Rodolfo Aramayo (rodolfo@aramayo.org).
# Released under the GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007.

library(tidyverse)
library(ggeasy)
library(ggplot2)

setwd(\"${var_script_tmp_data_dir}\")

transcriptome <- read.delim(\"0002_File\", header=FALSE, comment.char=\"#\")
data <- read_delim(file = \"0001_${INFILE01%.fa}\", delim = '\\\t',  show_col_types = 'FALSE' )
v <- data %>% select(Length)

breaks <- c(${breaks[*]})
tags <- c(${tags[*]})
group_tags <- cut(v\$Length,breaks=breaks,include.lowest=TRUE,right=FALSE,labels=tags)

vgroup <- as_tibble(v) %>% mutate(tag = case_when(${lengths[*]}))

sink(\"0008_summary_01\")
summary(vgroup)
sink()

vgroup\$tag <- factor(vgroup\$tag,levels = tags, ordered = FALSE)

sink(\"0008_summary_02\")
summary(vgroup$tag)
sink()

pdf(file = \"${INFILE01}_Fasta_Seq_Plot_03.pdf\", width=10, height=10)

ggplot(data = vgroup, mapping = aes(x=tag,y=log10(Length))) +
geom_jitter(aes ( color = \"blue\" ), alpha = 0.2) +
geom_boxplot( fill =\"bisque\", color = \"black\", alpha = 0.3) +
labs( x = 'Transcript Size (nts)') +
guides(color = FALSE) +
theme_minimal() +
ggtitle(quote(bolditalic(\"${species_name}\"))) +
ggeasy::easy_center_title()

dev.off()

png(file = \"${INFILE01}_Fasta_Seq_Plot_03.png\", width=15000, height=15000, res=1500)

ggplot(data = vgroup, mapping = aes(x=tag,y=log10(Length))) +
geom_jitter(aes ( color = \"blue\" ), alpha = 0.2) +
geom_boxplot( fill =\"bisque\", color = \"black\", alpha = 0.3) +
labs( x = 'Transcript Size (nts)') +
guides(color = FALSE) +
theme_minimal() +
ggtitle(quote(bolditalic(\"${species_name}\"))) +
ggeasy::easy_center_title()

dev.off()

" > ${var_script_tmp_data_dir}/0008_File.R;

    R --vanilla < ${var_script_tmp_data_dir}/0008_File.R &> ${var_script_tmp_data_dir}/0008_File.R.log;

    echo -e "\n${species_name} Fasta Statistics:\n" >> ${var_script_out_data_dir}/${INFILE01%.fa}_Fasta_Seq_Plot.log;

    cat ${var_script_tmp_data_dir}/0008_summary_02 >> ${var_script_out_data_dir}/${INFILE01%.fa}_Fasta_Seq_Plot.log;

    cp ${var_script_tmp_data_dir}/${INFILE01}_Fasta_Seq_Plot_01.pdf ${var_script_out_data_dir}/${INFILE01}_Transcriptome_Fasta_Seq_Plot_01.pdf;
    cp ${var_script_tmp_data_dir}/${INFILE01}_Fasta_Seq_Plot_02.pdf ${var_script_out_data_dir}/${INFILE01}_Transcriptome_Fasta_Seq_Plot_02.pdf;
    cp ${var_script_tmp_data_dir}/${INFILE01}_Fasta_Seq_Plot_03.pdf ${var_script_out_data_dir}/${INFILE01}_Transcriptome_Fasta_Seq_Plot_03.pdf;

    cp ${var_script_tmp_data_dir}/${INFILE01}_Fasta_Seq_Plot_01.png ${var_script_out_data_dir}/${INFILE01}_Transcriptome_Fasta_Seq_Plot_01.png;
    cp ${var_script_tmp_data_dir}/${INFILE01}_Fasta_Seq_Plot_02.png ${var_script_out_data_dir}/${INFILE01}_Transcriptome_Fasta_Seq_Plot_02.png;
    cp ${var_script_tmp_data_dir}/${INFILE01}_Fasta_Seq_Plot_03.png ${var_script_out_data_dir}/${INFILE01}_Transcriptome_Fasta_Seq_Plot_03.png;

    if [[ ${keep_r_files} -eq 1 ]];
    then
	cp ${var_script_tmp_data_dir}/0006_File.R ${var_script_out_data_dir}/${INFILE01}_Transcriptome_Fasta_Seq_Plot_01.R;
	cp ${var_script_tmp_data_dir}/0007_File.R ${var_script_out_data_dir}/${INFILE01}_Transcriptome_Fasta_Seq_Plot_02.R;
	cp ${var_script_tmp_data_dir}/0008_File.R ${var_script_out_data_dir}/${INFILE01}_Transcriptome_Fasta_Seq_Plot_03.R;
    fi
fi

rm -fr ${var_script_tmp_data_dir};

time_execution_stop=$(date +%s);
echo -e "\nFinishing Processing on: "$(date)"" \
     >> ${var_script_out_data_dir}/${INFILE01%.fa}_Fasta_Seq_Plot.log;
echo -e "Script Runtime (sec): $(echo "${time_execution_stop}"-"${time_execution_start}"|bc -l) seconds" \
     >> ${var_script_out_data_dir}/${INFILE01%.fa}_Fasta_Seq_Plot.log;
echo -e "Script Runtime (min): $(echo "scale=2;(${time_execution_stop}"-"${time_execution_start})/60"|bc -l) minutes" \
     >> ${var_script_out_data_dir}/${INFILE01%.fa}_Fasta_Seq_Plot.log;
echo -e "Script Runtime (hs): $(echo "scale=2;((${time_execution_stop}"-"${time_execution_start})/60)/60"|bc -l) hours" \
     >> ${var_script_out_data_dir}/${INFILE01%.fa}_Fasta_Seq_Plot.log;

exit 0
