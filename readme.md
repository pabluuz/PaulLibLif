![Logo](readme_logo.png?raw=true)
# PaulLibLif
PaulLibLif is a framework for Life is Feudal mods. What it does:
    - Easily create a new items and don't worry about ID's, transfering to clients and all the hussle.
    - Edit all datablocks (weapons, monsters, etc) and automatically transfer them to clients.
    - Create daily actions (e.g. warehouse produces onion every day). See config/industries.yaml.example for an example.
    - Adds ORM to life is feudal database, enriches those models by missing back-references (e.g. get object from container using root_container_id from either MovableObject or UnmovableObject)

PaulLibLif is modular, so you can use only the parts you need. Refer to step 6 of setup.

This is very early testing, so expect a lot of bugs

## What's PaulMod ?
PaulMod is simplified, human readable package containing mod. PaulLibLif takes away all the hussle of managing mods (unique ID's, transfering to clients, etc), and brings up a simple and easy way to create mods.

### Structure of PaulMod
All files are optional. You can use only the ones you want. Just try to keep readme.md in the root of your mod.
Tip: Try to keep names of objects unique in scope of your mod. This will make it easier to find them later.
../PaulMods/NameOfMod/
    - config/
    - objects.yaml
    - recipes.yaml
    - industries.yaml
    - readme.md

Remember that mods don't have to contain all files. You mod for example can contain only objects.yaml, if you wish to add object without recipes, or you can add only industries.yaml if you wish to add daily actions.

## Setup
It should be fairly easy to setup PaulLibLif. If you have any problems, please open an issue.

What you need:
- Python 3.8+. Use newest version.
- 5 minutes of your time

1. **Clone the repository**:

    ```bash
    git clone git@github.com:pabluuz/paul-lib-lif.git
    cd paul-lib-lif
    ```

2. **Activate a virtual environment and create dirs**:

    **Using `venv`**:

    - On macOS and Linux:

        ```bash
        mkdir ../PaulMods
        python -m venv venv
        source venv/bin/activate
        pip install -r requirements.txt
        ```

    - On Windows:

        ```batch
        install.bat
        ```

3. **Install dependencies**:

    ```bash
    pip install -r requirements.txt
    ```

4. **Run the application once to create configs**:

    ```bash
    python app.py
    ```

5. **Edit the config files**:

    Files are located in `config/` directory.

6. **Run the application**:

    You can run all the parts of PaulLibLif separately. Just choose what you want to run, and follow the instructions below.

    ### Compile mods and run server

    #### Linux
    ```bash
    source venv/bin/activate
    python app.py run_server
    ```

    #### Windows
    ```bash
    call venv/bin/activate
    python app.py run_server
    ```

    ### Daily tick
    Daily tick is done every day at 12:00 AM. Program prevents running it more than once a day.

    Take a look at example industries in templates/industries.yaml.example.
    Place ready industries in life is feudal server/PaulIndustries/some_choosen_name.yaml.
    PaulIndustries can contain multiple industries in one file and/or multiple files, it's up to you.

    #### Linux
    Setup a cronjob to run daily.
    ```bash
    chmod +x /home/yourusername/steamapps/LifeIsFeudalServer/PaulLibLif/run_daily_tick.sh
    (crontab -l 2>/dev/null; echo "*/10 * * * * /home/yourusername/steamapps/LifeIsFeudalServer/PaulLibLif/run_daily_tick.sh") | crontab -
    ```

    or manually add to crontab:
    ```bash
    chmod +x /home/yourusername/steamapps/LifeIsFeudalServer/PaulLibLif/run_daily_tick.sh
    crontab -e
    ```
    and then add entry
    ```bash
    */10 * * * * /home/yourusername/steamapps/LifeIsFeudalServer/PaulLibLif/run_daily_tick.sh
    ```

    #### Windows
    Add scheduled task (for example every 10 minutes) to run `app.py daily_tick`
    ```bash
    schtasks /create /tn "Run Daily Feudal Tick" /tr "C:\Program Files (x86)\Steam\steamapps\common\Life is Feudal Your Own Dedicated Server\PaulLibLif\windows_daily_tick.bat" /sc minute /mo 10 /ru SYSTEM
    ```

## License:
Copyleft (ↄ) 2024. Made with ❤️ by Paul. Use it, abuse it, fork it, steal it, whatever. Just keep it open source with copyleft license.