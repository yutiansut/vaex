#!/bin/bash
set -x -e

# if [ -f ${HOME}/.bashrc ]; then
#     source ${HOME}/.bashrc
# else
#     source ${HOME}/.bash_profile
# fi
# conda activate vaex-dev

export VAEX_SERVER_OVERRIDE='{"dataframe.vaex.io":"dataframe-dev.vaex.io"}'
python -m pip install healpy
cd docs/source

# make sure the ~/.ipython dir exists because multiple processes might try to create it
python -c "import IPython.paths as p; p.get_ipython_dir()"

notesbooks=("tutorial.ipynb" "tutorial_ml.ipynb")
# general examples
notesbooks+=("example_dask.ipynb" "example_graphql.ipynb" "example_io.ipynb" "example_dask.ipynb")
# ml examples
notesbooks+=("example_ml_iris.ipynb" "example_ml_titanic.ipynb")
# jupyter examples
notesbooks+=("example_jupyter_ipyvolume.ipynb" "example_jupyter_plotly.ipynb")

# see https://unix.stackexchange.com/a/595838
pids=()
for notebook in ${notesbooks[*]}; do
    python -m nbconvert --TagRemovePreprocessor.remove_cell_tags="('skip-ci',)" --to html --execute $notebook --ExecutePreprocessor.timeout=240 & pids+=($!)
done

error=false
for pid in ${pids[*]}; do
    if ! wait $pid; then
        error=true
    fi
done
if $error; then
    exit 1
fi
