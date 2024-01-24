#!/bin/bash

# ejemplo de esperar hasta hoy a las 10
# sleep $(bc <<<s$(date -f - +'t=%s.%N;' <<<$'22:00 today\nnow')'st-t')

fecha_proc=$(/opt/lib_anasac/anasac/get_param.py fecha_proc)

# Python
# De ser necesario Activar VENV
# source /opt/venv_name
echo paso xxx
python3 script.py $@

# deactivate

# R
echo paso yyy
Rscript script.R $@


