**[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.10892498.svg)](https://doi.org/10.5281/zenodo.10892498)**
# **Fasta_Seq_Plot_Bash**

## **Motivation**

```
The primary objective behind creating this script was to facilitate the generation of 'pdf' or 'png' image files
depicting the size distribution of transcripts or proteins, excluding genomes, from fasta files.
```

## Documentation

```
########################################################################################################################################################################################################
ARAMAYO_LAB

This program is free software: you can redistribute it and/or modify it under the terms of the GNU
General Public License as published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not,
see <https://www.gnu.org/licenses/>.

SCRIPT_NAME:                       Fasta_Seq_Plot_v1.0.2..sh
SCRIPT_VERSION:                    1.0.2

USAGE: Fasta_Seq_Plot_v1.0.2..sh
       -p Homo_sapiens.GRCh38.pep.all.fa               # REQUIRED if -t Not Provided (Proteins File - Proteome)
       -t Homo_sapiens.GRCh38.cds.all.fa               # REQUIRED if -p Not Provided (Transcripts File - Transcriptome)
       -n 'Homo sapiens'                               # REQUIRED (Species Name)
       -z TMPDIR Location                              # OPTIONAL (default=0='TMPDIR Run')

TYPICAL COMMANDS:
                                   Fasta_Seq_Plot_v1.0.2..sh -p Homo_sapiens.GRCh38.pep.all.fa -n 'Homo sapiens'
                                   Fasta_Seq_Plot_v1.0.2..sh -t Homo_sapiens.GRCh38.cds.all.fa -n 'Homo sapiens'

INPUT01:          -p FLAG          REQUIRED input ONLY if the '-t' flag associated file is not provided
INPUT01_FORMAT:                    Proteome Fasta File
INPUT01_DEFAULT:                   No default

INPUT02:          -t FLAG          REQUIRED input ONLY if the '-p' flag associated file is not provided
INPUT02_FORMAT:                    Transcriptome Fasta File
INPUT02_DEFAULT:                   No default

INPUT03:          -n FLAG          REQUIRED input
INPUT03_FORMAT:                    Text
INPUT03_DEFAULT:                   None
INPUT03_NOTES:                     The text should correspond to the species name whose fasta file is being analyzed
INPUT03_NOTES:                     If the text provided is composed on more than one word (e.g., Genus species), then the text must be within single or double quotes

INPUT04:          -z FLAG          OPTIONAL input
INPUT04_FORMAT:                    Numeric: 0 == TMPDIR Run | 1 == Normal Run
INPUT04_DEFAULT:                   0 == TMPDIR Run
INPUT04_NOTES:                     0 Processes the data in the $TMPDIR directory of the computer used or of the node assigned by the SuperComputer scheduler
INPUT04_NOTES:                     Processing the data in the $TMPDIR directory of the node assigned by the SuperComputer scheduler reduces the possibility of file error generation due to network traffic
INPUT04_NOTES:                     1 Processes the data in the same directory where the script is being run

DEPENDENCIES:                      GNU AWK:       Required (https://www.gnu.org/software/gawk/)
                                   GNU COREUTILS: Required (https://www.gnu.org/software/coreutils/)
                                   datamash:      Required (http://www.gnu.org/software/datamash)
                                   R:             Required (https://www.r-project.org/)
                                   R - ggplot2    Required (https://github.com/tidyverse/ggplot2)
                                   R - ggeasy     Required (https://github.com/jonocarroll/ggeasy)
                                                  Assumes that the packages tidyverse, ggplot2, and ggeasy are already installed

Author:                            Rodolfo Aramayo
WORK_EMAIL:                        raramayo@tamu.edu
PERSONAL_EMAIL:                    rodolfo@aramayo.org
########################################################################################################################################################################################################
```

## Development/Testing Environment:

```
Distributor ID:       Apple, Inc.
Description:          Apple M1 Max
Release:              14.4.1
Codename:             Sonoma
```

```
Distributor ID:       Ubuntu
Description:          Ubuntu 22.04.3 LTS
Release:              22.04
Codename:             jammy
```

## Required Script Dependencies:
### GNU COREUTILS (https://www.gnu.org/software/coreutils/)
#### Version Number: 8.30

```
(GNU coreutils) 9.4
Copyright (C) 2023 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <https://gnu.org/licenses/gpl.html>.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Written by Richard M. Stallman and David MacKenzie.
```

### GNU AWK (https://www.gnu.org/software/gawk/)
#### Version Number: 5.3.0, API 4.0

```
GNU Awk 5.3.0, API 4.0
Copyright (C) 1989, 1991-2023 Free Software Foundation.

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see http://www.gnu.org/licenses/.
```

### DATAMASH ( (http://www.gnu.org/software/datamash)
#### Version Number: datamash (GNU datamash) 1.8-dirty

```
datamash (GNU datamash) 1.8-dirty
Copyright (C) 2022 Assaf Gordon and Tim Rice
License GPLv3+: GNU GPL version 3 or later <https://gnu.org/licenses/gpl.html>.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Written by Assaf Gordon, Tim Rice, Shawn Wagner, Erik Auerswald.
```

### R  (https://www.r-project.org/)
#### Version Number: R version 4.3.3 (2024-02-29) -- "Angel Food Cake"

```
R version 4.3.3 (2024-02-29) -- "Angel Food Cake"
Copyright (C) 2024 The R Foundation for Statistical Computing
Platform: aarch64-apple-darwin20 (64-bit)

R is free software and comes with ABSOLUTELY NO WARRANTY.
You are welcome to redistribute it under the terms of the
GNU General Public License versions 2 or 3.
For more information about these matters see
https://www.gnu.org/licenses/.
```

### R - ggplot2 (https://github.com/tidyverse/ggplot2)
#### Version Number: 3.5.0

```
Package: ggplot2
Version: 3.5.0
Title: Create Elegant Data Visualisations Using the Grammar of Graphics
```

### R - ggeasy (https://github.com/jonocarroll/ggeasy)
#### Version Number: 0.1.4

```
Package: ggeasy
Title: Easy Access to 'ggplot2' Commands
Version: 0.1.4
```
