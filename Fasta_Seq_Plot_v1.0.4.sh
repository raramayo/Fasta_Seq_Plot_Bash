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

SCRIPT_NAME:                       $(basename ${0})
SCRIPT_VERSION:                    ${version}

USAGE: $(basename ${0})
  -p Homo_sapiens.GRCh38.pep.all.fa  # REQUIRED (Proteins File)
  -t Homo_sapiens.GRCh38.cds.all.fa  # REQUIRED (Transcripts File)
  -n 'Homo sapiens'                  # REQUIRED (Species Name)
  -z TMPDIR Location                 # OPTIONAL (default=0='TMPDIR Run')

TYPICAL COMMANDS:
  $(basename ${0}) -p Homo_sapiens.GRCh38.pep.all.fa -n 'Homo sapiens'
  $(basename ${0}) -t Homo_sapiens.GRCh38.cds.all.fa -n 'Homo sapiens'

INPUT01:          -p FLAG          REQUIRED input
                                     ONLY if the '-t' flag associated file
                                     is not provided
INPUT01_FORMAT:                    Proteome Fasta File
INPUT01_DEFAULT:                   No default

INPUT02:          -t FLAG          REQUIRED input
                                     ONLY if the '-p' flag associated file
                                     is not provided
INPUT02_FORMAT:                    Transcriptome Fasta File
INPUT02_DEFAULT:                   No default

INPUT03:          -n FLAG          REQUIRED input
INPUT03_FORMAT:                    Text
INPUT03_DEFAULT:                   None
INPUT03_NOTES:
  The text should correspond to the species name whose fasta file is being
  analyzed.
  If the text provided is composed on more than one word (e.g.,
  Genus species), then the text must be within single or double quotes.

INPUT04:          -z FLAG          OPTIONAL input
INPUT04_FORMAT:                    Numeric: 0 == TMPDIR Run | 1 == Normal Run
INPUT04_DEFAULT:                   0 == TMPDIR Run
INPUT04_NOTES:
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
version="1.0.4";

## Defining_Script_Initial_Version_Data (date '+DATE:%Y/%m/%d%tTIME:%R')
version_date_initial="DATE:2022/11/21	TIME:13:13";

## Defining_Script_Current_Version_Data (date '+DATE:%Y/%m/%d%tTIME:%R')
version_date_current="DATE:2024/05/09	TIME:11:05";

## Testing_Script_Input
## Is the number of arguments null?
if [[ $# -eq 0 ]];
then
    echo -e "\nPlease enter required arguments";
    func_usage;
    exit 1;
fi

while true;
do
    case $1 in
        -h|--h|-help|--help|-\?|--\?)
            func_usage;
            exit 0;
            ;;
        -v|--v|-version|--version)
            printf "Version: $version %s\n" >&2;
            exit 0;
            ;;
        -p|--p|-proteome|--proteome)
            proteinsfile="$2";
            shift;
            ;;
        -t|--t|-transcriptome|--transcriptome)
            transcriptsfile="$2";
            shift;
            ;;
        -n|--n|-name|--name)
            species_name="$2";
            shift;
            ;;
	-z|--z|-tmp-dir|--tmp-dir)
            var_tmp_dir="$2";
            shift;
            ;;
        -?*)
            printf '\nWARNNING: Unknown Option (ignored): %s\n\n' "$1" >&2;
            func_usage;
            exit 0;
            ;;
        :)
            printf '\nWARNING: Invalid Option (ignored): %s\n\n' "$1" >&2;
            func_usage;
            exit 0;
            ;;
        \?)
            printf '\nWARNING: Invalid Option (ignored): %s\n\n' "$1" >&2;
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
if [[ ! -z ${proteinsfile} ]];
then
    INFILE01="${proteinsfile}";
    var_INFILE01="proteins_file";
else
    var_INFILE01="transcripts_file";
fi
if [[ ${var_INFILE01} == "proteins_file" ]];
then
    if [[ ! -f ${proteinsfile} ]];
    then
	echo "Please provide a proteome fasta file";
	func_usage;
	exit 1;
    fi
fi
if [[ ! -z ${transcriptsfile} ]];
then
    INFILE01="${transcriptsfile}";
    var_INFILE01="transcripts_file";
else
    var_INFILE01="proteins_file";
fi
if [[ ${var_INFILE01} == "transcripts_file" ]];
then
    if [[ ! -f ${transcriptsfile} ]];
    then
	echo "Please provide a transcriptome fasta file";
	func_usage;
	exit 1;
    fi
fi
if [[ ! -z ${proteinsfile} && ! -z ${transcriptsfile} ]];
then
    echo -e "\nPlease provide either a protein of a transcript file, but not both";
    func_usage;
    exit 1;
fi

## Processing: -n Flag
## Assigning Species Name
if [[ -z ${species_name} ]];
then
    echo -e "\nPlease provide a species name";
    func_usage;
    exit 1;
fi

## Processing '-z' Flag
## Determining Where The TMPDIR Will Be Generated
if [[ -z ${var_tmp_dir} ]];
then
    var_tmp_dir="${var_tmp_dir:=0}";
fi

var_regex="^[0-1]+$"
if ! [[ ${var_tmp_dir} =~ ${var_regex} ]];
then
    echo "Please provide a valid number (e.g., 0 or 1), for this variable";
    func_usage;
    exit 1;
fi

## Generating Directories
if [[ ! -d ./${INFILE01%.fa}_Fasta_Seq_Plot.dir ]];
then
    mkdir ./${INFILE01%.fa}_Fasta_Seq_Plot.dir;
else
    rm ./${INFILE01%.fa}_Fasta_Seq_Plot.dir/* &>/dev/null;
fi

if [[ -d ./${INFILE01%.fa}_Fasta_Seq_Plot.tmp ]];
then
    rm -fr ./${INFILE01%.fa}_Fasta_Seq_Plot.tmp;
fi

## Generating/Cleaning TMP Data Directory
if [[ ${var_tmp_dir} -eq 0 ]];
then
    ## Defining Script TMP Data Directory
    var_script_tmp_data_dir="$(pwd)/${INFILE01%.fa}_Fasta_Seq_Plot.tmp";
    export var_script_tmp_data_dir="$(pwd)/${INFILE01%.fa}_Fasta_Seq_Plot.tmp";

    if [[ -d $(basename "${var_script_tmp_data_dir}") ]];
    then
        rm -fr $(basename "${var_script_tmp_data_dir}");
    fi

    if [[ -z ${TMPDIR} ]];
    then
        ## echo "TMPDIR not defined";
        TMP=$(mktemp -d -p "${TMP}"); ## &> /dev/null);
        var_script_tmp_data_dir="${TMP}";
        export  var_script_tmp_data_dir="${TMP}";
    fi

    if [[ ! -z ${TMPDIR} ]];
    then
        ## echo "TMPDIR defined";
        TMP=$(mktemp -d -p "${TMPDIR}"); ## &> /dev/null);
        var_script_tmp_data_dir="${TMP}";
        export  var_script_tmp_data_dir="${TMP}";

    fi
fi

if [[ ${var_tmp_dir} -eq 1 ]];
then
    ## Defining Script TMP Data Directory
    var_script_tmp_data_dir="$(pwd)/${INFILE01%.fa}_Fasta_Seq_Plot.tmp";
    export var_script_tmp_data_dir="$(pwd)/${INFILE01%.fa}_Fasta_Seq_Plot.tmp";

    if [[ ! -d $(basename "${var_script_tmp_data_dir}") ]];
    then
        mkdir $(basename "${var_script_tmp_data_dir}");
    else
        rm -fr $(basename "${var_script_tmp_data_dir}");
        mkdir $(basename "${var_script_tmp_data_dir}");
    fi
fi

## Initializing_Log_File
time_execution_start=$(date +%s);
echo -e "Starting Processing on: "$(date)"" \
     > ./${INFILE01%.fa}_Fasta_Seq_Plot.dir/${INFILE01%.fa}_Fasta_Seq_Plot.log;

## Verifying_Software_Dependency_Existence
echo -e "Verifying Software Dependency Existence on: "$(date)"" \
     >> ./${INFILE01%.fa}_Fasta_Seq_Plot.dir/${INFILE01%.fa}_Fasta_Seq_Plot.log;
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
if [[ ${BASH_VERSINFO:-0} -ge 4 ]];
then
    echo "GNU_BASH version 4 or higher is Installed" >> ./${INFILE01%.fa}_Fasta_Seq_Plot.dir/${INFILE01%.fa}_Fasta_Seq_Plot.log;
else
    echo "GNU_BASH version 4 or higher is Not Installed";
    echo "Please Install GNU_BASH version 4 or higher";
    rm -fr ./${INFILE01%.fa}_Fasta_Seq_Plot.dir;
    rm -fr "${var_script_tmp_data_dir}";
    func_usage;
    exit 1;
fi
## Testing_GNU_Awk_Installation
type gawk &> /dev/null;
var_sde=$(echo $?);
if [[ ${var_sde} -eq 0 ]];
then
    echo "GNU_AWK is Installed" >> ./${INFILE01%.fa}_Fasta_Seq_Plot.dir/${INFILE01%.fa}_Fasta_Seq_Plot.log;
else
    echo "GNU_AWK is Not Installed";
    echo "Please Install GNU_AWK";
    rm -fr ./${INFILE01%.fa}_Fasta_Seq_Plot.dir;
    rm -fr "${var_script_tmp_data_dir}";
    func_usage;
    exit 1;
fi
## Testing_DATAMASH_Installation
type datamash &> /dev/null;
var_sde=$(echo $?);
if [[ ${var_sde} -eq 0 ]];
then
    echo "datamash is Installed" >> ./${INFILE01%.fa}_Fasta_Seq_Plot.dir/${INFILE01%.fa}_Fasta_Seq_Plot.log;
else
    echo "DATAMASH is Not Installed";
    echo "Please Install DATAMASH";
    rm -fr ./${INFILE01%.fa}_Fasta_Seq_Plot.dir;
    rm -fr "${var_script_tmp_data_dir}";
    func_usage;
    exit 1;
fi
## Testing_Rscript_Installation
type Rscript &> /dev/null;
var_sde=$(echo $?);
if [[ ${var_sde} -eq 0 ]];
then
    echo "R is Installed" >> ./${INFILE01%.fa}_Fasta_Seq_Plot.dir/${INFILE01%.fa}_Fasta_Seq_Plot.log;
else
    echo "R is Not Installed";
    echo "Please Install R";
    rm -fr ./${INFILE01%.fa}_Fasta_Seq_Plot.dir;
    rm -fr "${var_script_tmp_data_dir}";
    func_usage;
    exit 1;
fi

echo -e "Software Dependencies Verified on: "$(date)"\n" >> ./${INFILE01%.fa}_Fasta_Seq_Plot.dir/${INFILE01%.fa}_Fasta_Seq_Plot.log;
echo -e "Script Running on: "${osname}", "${cputype}"\n" >> ./${INFILE01%.fa}_Fasta_Seq_Plot.dir/${INFILE01%.fa}_Fasta_Seq_Plot.log;

## set LC_ALL to "C"
export LC_ALL="C";

## START
echo -e "Script Name: $(basename ${0})\n" >> ./${INFILE01%.fa}_Fasta_Seq_Plot.dir/${INFILE01%.fa}_Fasta_Seq_Plot.log;

echo -e "Command Issued Was:" >> ./${INFILE01%.fa}_Fasta_Seq_Plot.dir/${INFILE01%.fa}_Fasta_Seq_Plot.log;

if [[ ${var_INFILE01} == "proteins_file" ]];
then
    echo -e "\tFile Type: Proteome" >> ./${INFILE01%.fa}_Fasta_Seq_Plot.dir/${INFILE01%.fa}_Fasta_Seq_Plot.log;
else
    echo -e "\tFile Type: Transcriptome" >> ./${INFILE01%.fa}_Fasta_Seq_Plot.dir/${INFILE01%.fa}_Fasta_Seq_Plot.log;
fi

if [[ ${var_tmp_dir} -eq 0 ]];
then
    echo -e "\t-z Flag: TMPDIR Requested: \$TMPDIR Directory" >> ./${INFILE01%.fa}_Fasta_Seq_Plot.dir/${INFILE01%.fa}_Fasta_Seq_Plot.log;
else
    echo -e "\t-z Flag: TMPDIR Requested: Local Directory" >> ./${INFILE01%.fa}_Fasta_Seq_Plot.dir/${INFILE01%.fa}_Fasta_Seq_Plot.log;
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

for i in "${lines[@]}";
do
    var_field_01=$(echo $i | awk '{print $1}');
    var_field_02=$(echo $i | awk '{print $2}');

    if [[ ${var_counter} -ne ${var_record_number} ]];
    then
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

if [[ ${var_INFILE01} == "proteins_file" ]];
then
    echo -e "\
#!/usr/bin/env R

library(tidyverse)
library(ggeasy)
library(ggplot2)

setwd(\""${var_script_tmp_data_dir}"\")

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

library(tidyverse)
library(ggeasy)
library(ggplot2)

setwd(\""${var_script_tmp_data_dir}"\")

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

library(tidyverse)
library(ggeasy)
library(ggplot2)

setwd(\""${var_script_tmp_data_dir}"\")

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

    echo -e "\n${species_name} Fasta Statistics:\n" >> ./${INFILE01%.fa}_Fasta_Seq_Plot.dir/${INFILE01%.fa}_Fasta_Seq_Plot.log;

    cat ${var_script_tmp_data_dir}/0008_summary_02 >> ./${INFILE01%.fa}_Fasta_Seq_Plot.dir/${INFILE01%.fa}_Fasta_Seq_Plot.log;

    cp ${var_script_tmp_data_dir}/${INFILE01}_Fasta_Seq_Plot_01.pdf ./${INFILE01%.fa}_Fasta_Seq_Plot.dir/${INFILE01}_Proteome_Fasta_Seq_Plot_01.pdf;
    cp ${var_script_tmp_data_dir}/${INFILE01}_Fasta_Seq_Plot_02.pdf ./${INFILE01%.fa}_Fasta_Seq_Plot.dir/${INFILE01}_Proteome_Fasta_Seq_Plot_02.pdf;
    cp ${var_script_tmp_data_dir}/${INFILE01}_Fasta_Seq_Plot_03.pdf ./${INFILE01%.fa}_Fasta_Seq_Plot.dir/${INFILE01}_Proteome_Fasta_Seq_Plot_03.pdf;

    cp ${var_script_tmp_data_dir}/${INFILE01}_Fasta_Seq_Plot_01.png ./${INFILE01%.fa}_Fasta_Seq_Plot.dir/${INFILE01}_Proteome_Fasta_Seq_Plot_01.png;
    cp ${var_script_tmp_data_dir}/${INFILE01}_Fasta_Seq_Plot_02.png ./${INFILE01%.fa}_Fasta_Seq_Plot.dir/${INFILE01}_Proteome_Fasta_Seq_Plot_02.png;
    cp ${var_script_tmp_data_dir}/${INFILE01}_Fasta_Seq_Plot_03.png ./${INFILE01%.fa}_Fasta_Seq_Plot.dir/${INFILE01}_Proteome_Fasta_Seq_Plot_03.png;
else
    echo -e "\
#!/usr/bin/env R

library(tidyverse)
library(ggeasy)
library(ggplot2)

setwd(\""${var_script_tmp_data_dir}"\")

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

library(tidyverse)
library(ggeasy)
library(ggplot2)

setwd(\""${var_script_tmp_data_dir}"\")

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

library(tidyverse)
library(ggeasy)
library(ggplot2)

setwd(\""${var_script_tmp_data_dir}"\")

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

    echo -e "\n${species_name} Fasta Statistics:\n" >> ./${INFILE01%.fa}_Fasta_Seq_Plot.dir/${INFILE01%.fa}_Fasta_Seq_Plot.log;

    cat ${var_script_tmp_data_dir}/0008_summary_02 >> ./${INFILE01%.fa}_Fasta_Seq_Plot.dir/${INFILE01%.fa}_Fasta_Seq_Plot.log;

    cp ${var_script_tmp_data_dir}/${INFILE01}_Fasta_Seq_Plot_01.pdf ./${INFILE01%.fa}_Fasta_Seq_Plot.dir/${INFILE01}_Transcriptome_Fasta_Seq_Plot_01.pdf;
    cp ${var_script_tmp_data_dir}/${INFILE01}_Fasta_Seq_Plot_02.pdf ./${INFILE01%.fa}_Fasta_Seq_Plot.dir/${INFILE01}_Transcriptome_Fasta_Seq_Plot_02.pdf;
    cp ${var_script_tmp_data_dir}/${INFILE01}_Fasta_Seq_Plot_03.pdf ./${INFILE01%.fa}_Fasta_Seq_Plot.dir/${INFILE01}_Transcriptome_Fasta_Seq_Plot_03.pdf;

    cp ${var_script_tmp_data_dir}/${INFILE01}_Fasta_Seq_Plot_01.png ./${INFILE01%.fa}_Fasta_Seq_Plot.dir/${INFILE01}_Transcriptome_Fasta_Seq_Plot_01.png;
    cp ${var_script_tmp_data_dir}/${INFILE01}_Fasta_Seq_Plot_02.png ./${INFILE01%.fa}_Fasta_Seq_Plot.dir/${INFILE01}_Transcriptome_Fasta_Seq_Plot_02.png;
    cp ${var_script_tmp_data_dir}/${INFILE01}_Fasta_Seq_Plot_03.png ./${INFILE01%.fa}_Fasta_Seq_Plot.dir/${INFILE01}_Transcriptome_Fasta_Seq_Plot_03.png;
fi

rm -fr ${var_script_tmp_data_dir};

time_execution_stop=$(date +%s);
echo -e "\nFinishing Processing on: "$(date)"" \
     >> ./${INFILE01%.fa}_Fasta_Seq_Plot.dir/${INFILE01%.fa}_Fasta_Seq_Plot.log;
echo -e "Script Runtime (sec): $(echo "${time_execution_stop}"-"${time_execution_start}"|bc -l) seconds" \
     >> ./${INFILE01%.fa}_Fasta_Seq_Plot.dir/${INFILE01%.fa}_Fasta_Seq_Plot.log;
echo -e "Script Runtime (min): $(echo "scale=2;(${time_execution_stop}"-"${time_execution_start})/60"|bc -l) minutes" \
     >> ./${INFILE01%.fa}_Fasta_Seq_Plot.dir/${INFILE01%.fa}_Fasta_Seq_Plot.log;
echo -e "Script Runtime (hs): $(echo "scale=2;((${time_execution_stop}"-"${time_execution_start})/60)/60"|bc -l) hours" \
     >> ./${INFILE01%.fa}_Fasta_Seq_Plot.dir/${INFILE01%.fa}_Fasta_Seq_Plot.log;

exit 0
