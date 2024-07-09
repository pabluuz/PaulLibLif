@echo off
pushd ..
if not exist "PaulMods" (
    mkdir "PaulMods"
)
popd
python -m venv venv
call venv\Scripts\activate
pip install -r requirements.txt