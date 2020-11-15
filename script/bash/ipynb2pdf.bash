#!/bin/bash -e
#
# Convert a Jupyter Notebook to PDF without code.
#
# See: https://ga7g08.github.io/2015/06/25/ipython-nbconvert-latex-template-to-hide-code/
#
##
if [ -z "$1" ];then
    echo "Please provide path to jupyter notebook"
    exit 1
fi
jupy=$(basename $1)
dir=$(dirname $1)
pushd $dir > /dev/null
cat > hidecode.tplx <<EOF
((*- extends 'article.tplx' -*))
((* block input_group *))
    ((*- if cell.metadata.get('nbconvert', {}).get('show_code', False) -*))
         ((( super() )))
    ((*- endif -*))
((* endblock input_group *))
EOF
ipython nbconvert --to pdf --template hidecode $jupy
rm -f hidecode.tplx
popd > /dev/null
