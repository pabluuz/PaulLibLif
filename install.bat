@echo off
pushd ..
if not exist "PaulMods" (
    mkdir "PaulMods"
)
if not exist "PaulIndustries" (
    mkdir "PaulIndustries"
)
popd
python -m venv venv
call venv\Scripts\activate
pip install -r requirements.txt